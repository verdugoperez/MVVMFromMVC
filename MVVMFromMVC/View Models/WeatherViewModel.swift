/// Copyright (c) 2021 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

/*
 First, add an import for UIKit.UIImage. No other UIKit types need to be permitted in the view model. A general rule of thumb is to never import UIKit in your view models.
 Then, set WeatherViewModel???s class modifier to public. You make it public in order for it to be accessible for testing.

 */

// 1
import UIKit.UIImage
// 2
public class WeatherViewModel {
  private let geocoder = LocationGeocoder()
  private static let defaultAddress = "Culiac??n"
  let locationName = Box("Cargando...")
  let date = Box(" ")
  let icon: Box<UIImage?> = Box(nil)  //no image initially
  let summary = Box(" ")
  let forecastSummary = Box(" ")
  
  private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE, d MMMM"
    dateFormatter.locale = .init(identifier: "es_ES")
    return dateFormatter
  }()
  
  private let tempFormatter: NumberFormatter = {
    let tempFormatter = NumberFormatter()
    tempFormatter.numberStyle = .none
    return tempFormatter
  }()
  
  init() {
    changeLocation(to: Self.defaultAddress)
  }
  
  private func fetchWeatherForLocation(_ location: Location) {
    WeatherbitService.weatherDataForLocation(
      latitude: location.latitude,
      longitude: location.longitude) { [weak self] (weatherData, error) in
        guard
          let self = self,
          let weatherData = weatherData
      
          else {
            return
          }
      
        self.date.value = self.dateFormatter.string(from: weatherData.date)
        self.icon.value = UIImage(named: weatherData.iconName)
        let temp = self.tempFormatter.string(from: weatherData.currentTemp as NSNumber) ?? ""
        self.summary.value = "\(weatherData.description) - \(temp)???"
        self.forecastSummary.value = "\nSummary: \(weatherData.description)"
    }
  }
  
  func changeLocation(to newLocation: String) {
    locationName.value = "Cargando..."
    geocoder.geocode(addressString: newLocation) { [weak self] locations in
      guard let self = self else { return }
      if let location = locations.first {
        self.locationName.value = location.name
        self.fetchWeatherForLocation(location)
        return
      }
      
      self.locationName.value = "Not found"
      self.date.value = ""
      self.icon.value = nil
      self.summary.value = ""
      self.forecastSummary.value = ""
    }
  }
}
