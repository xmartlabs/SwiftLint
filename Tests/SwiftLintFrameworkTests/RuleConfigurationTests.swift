//
//  RuleConfigurationTests.swift
//  SwiftLint
//
//  Created by Scott Hoyt on 1/20/16.
//  Copyright © 2016 Realm. All rights reserved.
//

// swiftlint:disable file_length

import SourceKittenFramework
@testable import SwiftLintFramework
import XCTest

class RuleConfigurationsTests: XCTestCase {

    func testNameConfigurationSetsCorrectly() {
        let config = [ "min_length": ["warning": 17, "error": 7],
                       "max_length": ["warning": 170, "error": 700],
                       "excluded": "id"] as [String: Any]
        var nameConfig = NameConfiguration(minLengthWarning: 0,
                                           minLengthError: 0,
                                           maxLengthWarning: 0,
                                           maxLengthError: 0)
        let comp = NameConfiguration(minLengthWarning: 17,
                                     minLengthError: 7,
                                     maxLengthWarning: 170,
                                     maxLengthError: 700,
                                     excluded: ["id"])
        do {
            try nameConfig.apply(configuration: config)
            XCTAssertEqual(nameConfig, comp)
        } catch {
            XCTFail("Did not configure correctly")
        }
    }

    func testNameConfigurationThrowsOnBadConfig() {
        let config = 17
        var nameConfig = NameConfiguration(minLengthWarning: 0,
                                           minLengthError: 0,
                                           maxLengthWarning: 0,
                                           maxLengthError: 0)
        checkError(ConfigurationError.unknownConfiguration) {
            try nameConfig.apply(configuration: config)
        }
    }

    func testNameConfigurationMinLengthThreshold() {
        var nameConfig = NameConfiguration(minLengthWarning: 7,
                                           minLengthError: 17,
                                           maxLengthWarning: 0,
                                           maxLengthError: 0,
                                           excluded: [])
        XCTAssertEqual(nameConfig.minLengthThreshold, 17)

        nameConfig.minLength.error = nil
        XCTAssertEqual(nameConfig.minLengthThreshold, 7)
    }

    func testNameConfigurationMaxLengthThreshold() {
        var nameConfig = NameConfiguration(minLengthWarning: 0,
                                           minLengthError: 0,
                                           maxLengthWarning: 17,
                                           maxLengthError: 7,
                                           excluded: [])
        XCTAssertEqual(nameConfig.maxLengthThreshold, 7)

        nameConfig.maxLength.error = nil
        XCTAssertEqual(nameConfig.maxLengthThreshold, 17)
    }

    func testSeverityConfigurationFromString() {
        let config = "Warning"
        let comp = SeverityConfiguration(.warning)
        var severityConfig = SeverityConfiguration(.error)
        do {
            try severityConfig.apply(configuration: config)
            XCTAssertEqual(severityConfig, comp)
        } catch {
            XCTFail()
        }
    }

    func testSeverityConfigurationFromDictionary() {
        let config = ["severity": "warning"]
        let comp = SeverityConfiguration(.warning)
        var severityConfig = SeverityConfiguration(.error)
        do {
            try severityConfig.apply(configuration: config)
            XCTAssertEqual(severityConfig, comp)
        } catch {
            XCTFail()
        }
    }

    func testSeverityConfigurationThrowsOnBadConfig() {
        let config = 17
        var severityConfig = SeverityConfiguration(.warning)
        checkError(ConfigurationError.unknownConfiguration) {
            try severityConfig.apply(configuration: config)
        }
    }

    func testSeverityLevelConfigParams() {
        let severityConfig = SeverityLevelsConfiguration(warning: 17, error: 7)
        XCTAssertEqual(severityConfig.params, [RuleParameter(severity: .error, value: 7),
            RuleParameter(severity: .warning, value: 17)])
    }

    func testSeverityLevelConfigPartialParams() {
        let severityConfig = SeverityLevelsConfiguration(warning: 17, error: nil)
        XCTAssertEqual(severityConfig.params, [RuleParameter(severity: .warning, value: 17)])
    }

    func testRegexConfigurationThrows() {
        let config = 17
        var regexConfig = RegexConfiguration(identifier: "")
        checkError(ConfigurationError.unknownConfiguration) {
            try regexConfig.apply(configuration: config)
        }
    }

    func testRegexRuleDescription() {
        var regexConfig = RegexConfiguration(identifier: "regex")
        XCTAssertEqual(regexConfig.description, RuleDescription(identifier: "regex",
                                                                name: "regex",
                                                                description: ""))
        regexConfig.name = "name"
        XCTAssertEqual(regexConfig.description, RuleDescription(identifier: "regex",
                                                                name: "name",
                                                                description: ""))
    }

    func testTrailingWhitespaceConfigurationThrowsOnBadConfig() {
        let config = "unknown"
        var configuration = TrailingWhitespaceConfiguration(ignoresEmptyLines: false,
                                                            ignoresComments: true)
        checkError(ConfigurationError.unknownConfiguration) {
            try configuration.apply(configuration: config)
        }
    }

    func testTrailingWhitespaceConfigurationInitializerSetsIgnoresEmptyLines() {
        let configuration1 = TrailingWhitespaceConfiguration(ignoresEmptyLines: false,
                                                             ignoresComments: true)
        XCTAssertFalse(configuration1.ignoresEmptyLines)

        let configuration2 = TrailingWhitespaceConfiguration(ignoresEmptyLines: true,
                                                             ignoresComments: true)
        XCTAssertTrue(configuration2.ignoresEmptyLines)
    }

    func testTrailingWhitespaceConfigurationInitializerSetsIgnoresComments() {
        let configuration1 = TrailingWhitespaceConfiguration(ignoresEmptyLines: false,
                                                             ignoresComments: true)
        XCTAssertTrue(configuration1.ignoresComments)

        let configuration2 = TrailingWhitespaceConfiguration(ignoresEmptyLines: false,
                                                             ignoresComments: false)
        XCTAssertFalse(configuration2.ignoresComments)
    }

    func testTrailingWhitespaceConfigurationApplyConfigurationSetsIgnoresEmptyLines() {
        var configuration = TrailingWhitespaceConfiguration(ignoresEmptyLines: false,
                                                            ignoresComments: true)
        do {
            let config1 = ["ignores_empty_lines": true]
            try configuration.apply(configuration: config1)
            XCTAssertTrue(configuration.ignoresEmptyLines)

            let config2 = ["ignores_empty_lines": false]
            try configuration.apply(configuration: config2)
            XCTAssertFalse(configuration.ignoresEmptyLines)
        } catch {
            XCTFail()
        }
    }

    func testTrailingWhitespaceConfigurationApplyConfigurationSetsIgnoresComments() {
        var configuration = TrailingWhitespaceConfiguration(ignoresEmptyLines: false,
                                                            ignoresComments: true)
        do {
            let config1 = ["ignores_comments": true]
            try configuration.apply(configuration: config1)
            XCTAssertTrue(configuration.ignoresComments)

            let config2 = ["ignores_comments": false]
            try configuration.apply(configuration: config2)
            XCTAssertFalse(configuration.ignoresComments)
        } catch {
            XCTFail()
        }
    }

    func testTrailingWhitespaceConfigurationCompares() {
        let configuration1 = TrailingWhitespaceConfiguration(ignoresEmptyLines: false,
                                                             ignoresComments: true)
        let configuration2 = TrailingWhitespaceConfiguration(ignoresEmptyLines: true,
                                                             ignoresComments: true)
        XCTAssertFalse(configuration1 == configuration2)

        let configuration3 = TrailingWhitespaceConfiguration(ignoresEmptyLines: true,
                                                             ignoresComments: true)
        XCTAssertTrue(configuration2 == configuration3)

        let configuration4 = TrailingWhitespaceConfiguration(ignoresEmptyLines: false,
                                                             ignoresComments: false)

        XCTAssertFalse(configuration1 == configuration4)

        let configuration5 = TrailingWhitespaceConfiguration(ignoresEmptyLines: true,
                                                             ignoresComments: false)

        XCTAssertFalse(configuration1 == configuration5)
    }

    func testTrailingWhitespaceConfigurationApplyConfigurationUpdatesSeverityConfiguration() {
        var configuration = TrailingWhitespaceConfiguration(ignoresEmptyLines: false,
                                                            ignoresComments: true)
        configuration.severityConfiguration.severity = .warning

        do {
            try configuration.apply(configuration: ["severity": "error"])
            XCTAssert(configuration.severityConfiguration.severity == .error)
        } catch {
            XCTFail()
        }
    }

    func testOverridenSuperCallConfigurationFromDictionary() {
        var configuration = OverridenSuperCallConfiguration()
        XCTAssertTrue(configuration.resolvedMethodNames.contains("viewWillAppear(_:)"))

        let conf1 = ["severity": "error", "excluded": "viewWillAppear(_:)"]
        do {
            try configuration.apply(configuration: conf1)
            XCTAssert(configuration.severityConfiguration.severity == .error)
            XCTAssertFalse(configuration.resolvedMethodNames.contains("*"))
            XCTAssertFalse(configuration.resolvedMethodNames.contains("viewWillAppear(_:)"))
            XCTAssertTrue(configuration.resolvedMethodNames.contains("viewWillDisappear(_:)"))
        } catch {
            XCTFail()
        }

        let conf2 = [
            "severity": "error",
            "excluded": "viewWillAppear(_:)",
            "included": ["*", "testMethod1()", "testMethod2(_:)"]
        ] as [String: Any]
        do {
            try configuration.apply(configuration: conf2)
            XCTAssert(configuration.severityConfiguration.severity == .error)
            XCTAssertFalse(configuration.resolvedMethodNames.contains("*"))
            XCTAssertFalse(configuration.resolvedMethodNames.contains("viewWillAppear(_:)"))
            XCTAssertTrue(configuration.resolvedMethodNames.contains("viewWillDisappear(_:)"))
            XCTAssertTrue(configuration.resolvedMethodNames.contains("testMethod1()"))
            XCTAssertTrue(configuration.resolvedMethodNames.contains("testMethod2(_:)"))
        } catch {
            XCTFail()
        }

        let conf3 = [
            "severity": "warning",
            "excluded": "*",
            "included": ["testMethod1()", "testMethod2(_:)"]
        ] as [String: Any]
        do {
            try configuration.apply(configuration: conf3)
            XCTAssert(configuration.severityConfiguration.severity == .warning)
            XCTAssert(configuration.resolvedMethodNames.count == 2)
            XCTAssertFalse(configuration.resolvedMethodNames.contains("*"))
            XCTAssertTrue(configuration.resolvedMethodNames.contains("testMethod1()"))
            XCTAssertTrue(configuration.resolvedMethodNames.contains("testMethod2(_:)"))
        } catch {
            XCTFail()
        }
    }
}

// MARK: - ImportsConfiguration tests

extension RuleConfigurationsTests {

    func testImportsConfigurationSetsCorrectly() {
        let data: [String: Any] = [
            "ignore_case": true,
            "ignore_duplicated": true,
            "ignore_order": true,
            "ignore_position": true
        ]

        var config1 = ImportsConfiguration(
            ignoreCase: false,
            ignoreDuplicatedImports: false,
            ignoreImportsOrder: false,
            ignoreImportsPosition: false
        )
        let config2 = ImportsConfiguration(
            ignoreCase: true,
            ignoreDuplicatedImports: true,
            ignoreImportsOrder: true,
            ignoreImportsPosition: true
        )

        do {
            try config1.apply(configuration: data)
            XCTAssertEqual(config1, config2)
        } catch {
            XCTFail("Did not configure correctly")
        }
    }

    func testImportsConfigurationThrowsOnBadConfig() {
        var config1 = ImportsConfiguration(
            ignoreCase: false,
            ignoreDuplicatedImports: false,
            ignoreImportsOrder: false,
            ignoreImportsPosition: false
        )
        checkError(ConfigurationError.unknownConfiguration) {
            try config1.apply(configuration: [true, true])
        }
    }

    func testImportsConfigurationIgnoreCase() {
        let config1 = ImportsConfiguration(
            ignoreCase: true,
            ignoreDuplicatedImports: false,
            ignoreImportsOrder: false,
            ignoreImportsPosition: false
        )
        XCTAssertEqual(config1.ignoreCase, true)

        let config2 = ImportsConfiguration(
            ignoreCase: false,
            ignoreDuplicatedImports: false,
            ignoreImportsOrder: false,
            ignoreImportsPosition: false
        )
        XCTAssertEqual(config2.ignoreCase, false)

        var config3 = ImportsConfiguration(
            ignoreCase: false,
            ignoreDuplicatedImports: false,
            ignoreImportsOrder: false,
            ignoreImportsPosition: false
        )
        do {
            try config3.apply(configuration: ["ignore_case": true])
            XCTAssertEqual(config3.ignoreCase, true)
        } catch {
            XCTFail("Did not configure correctly")
        }

        var config4 = ImportsConfiguration(
            ignoreCase: false,
            ignoreDuplicatedImports: true,
            ignoreImportsOrder: false,
            ignoreImportsPosition: false
        )
        do {
            try config4.apply(configuration: ["ignore_case": false])
            XCTAssertEqual(config4.ignoreCase, false)
        } catch {
            XCTFail("Did not configure correctly")
        }
    }

    func testImportsConfigurationIgnoreDuplicated() {
        let config1 = ImportsConfiguration(
            ignoreCase: false,
            ignoreDuplicatedImports: true,
            ignoreImportsOrder: false,
            ignoreImportsPosition: false
        )
        XCTAssertEqual(config1.ignoreDuplicatedImports, true)

        let config2 = ImportsConfiguration(
            ignoreCase: false,
            ignoreDuplicatedImports: false,
            ignoreImportsOrder: false,
            ignoreImportsPosition: false
        )
        XCTAssertEqual(config2.ignoreDuplicatedImports, false)

        var config3 = ImportsConfiguration(
            ignoreCase: false,
            ignoreDuplicatedImports: false,
            ignoreImportsOrder: false,
            ignoreImportsPosition: false
        )
        do {
            try config3.apply(configuration: ["ignore_duplicated": true])
            XCTAssertEqual(config3.ignoreDuplicatedImports, true)
        } catch {
            XCTFail("Did not configure correctly")
        }

        var config4 = ImportsConfiguration(
            ignoreCase: false,
            ignoreDuplicatedImports: true,
            ignoreImportsOrder: false,
            ignoreImportsPosition: false
        )
        do {
            try config4.apply(configuration: ["ignore_duplicated": false])
            XCTAssertEqual(config4.ignoreDuplicatedImports, false)
        } catch {
            XCTFail("Did not configure correctly")
        }
    }

    func testImportsConfigurationIgnoreOrder() {
        let config1 = ImportsConfiguration(
            ignoreCase: false,
            ignoreDuplicatedImports: false,
            ignoreImportsOrder: true,
            ignoreImportsPosition: false
        )
        XCTAssertEqual(config1.ignoreImportsOrder, true)

        let config2 = ImportsConfiguration(
            ignoreCase: false,
            ignoreDuplicatedImports: false,
            ignoreImportsOrder: false,
            ignoreImportsPosition: false
        )
        XCTAssertEqual(config2.ignoreImportsOrder, false)

        var config3 = ImportsConfiguration(
            ignoreCase: false,
            ignoreDuplicatedImports: false,
            ignoreImportsOrder: false,
            ignoreImportsPosition: false
        )
        do {
            try config3.apply(configuration: ["ignore_order": true])
            XCTAssertEqual(config3.ignoreImportsOrder, true)
        } catch {
            XCTFail("Did not configure correctly")
        }

        var config4 = ImportsConfiguration(
            ignoreCase: true,
            ignoreDuplicatedImports: false,
            ignoreImportsOrder: false,
            ignoreImportsPosition: false
        )
        do {
            try config4.apply(configuration: ["ignore_order": false])
            XCTAssertEqual(config4.ignoreImportsOrder, false)
        } catch {
            XCTFail("Did not configure correctly")
        }
    }

    func testImportsConfigurationIgnorePosition() {
        let config1 = ImportsConfiguration(
            ignoreCase: false,
            ignoreDuplicatedImports: false,
            ignoreImportsOrder: false,
            ignoreImportsPosition: true
        )
        XCTAssertEqual(config1.ignoreImportsPosition, true)

        let config2 = ImportsConfiguration(
            ignoreCase: false,
            ignoreDuplicatedImports: false,
            ignoreImportsOrder: false,
            ignoreImportsPosition: false
        )
        XCTAssertEqual(config2.ignoreImportsPosition, false)

        var config3 = ImportsConfiguration(
            ignoreCase: false,
            ignoreDuplicatedImports: false,
            ignoreImportsOrder: false,
            ignoreImportsPosition: false
        )
        do {
            try config3.apply(configuration: ["ignore_position": true])
            XCTAssertEqual(config3.ignoreImportsPosition, true)
        } catch {
            XCTFail("Did not configure correctly")
        }

        var config4 = ImportsConfiguration(
            ignoreCase: false,
            ignoreDuplicatedImports: false,
            ignoreImportsOrder: false,
            ignoreImportsPosition: true
        )
        do {
            try config4.apply(configuration: ["ignore_order": false])
            XCTAssertEqual(config4.ignoreImportsPosition, false)
        } catch {
            XCTFail("Did not configure correctly")
        }
    }

    func testImportsConfigurationEquality() {
        let possibleTests: [(Bool, Bool, Bool, Bool)] = [
            (false, false, false, false),
            (false, false, false, true),
            (false, false, true, false),
            (false, false, true, true),
            (false, true, false, false),
            (false, true, false, true),
            (false, true, true, false),
            (false, true, true, true),
            (true, false, false, false),
            (true, false, false, true),
            (true, false, true, false),
            (true, false, true, true),
            (true, true, false, false),
            (true, true, false, true),
            (true, true, true, false),
            (true, true, true, true)
        ]

        possibleTests.enumerated().forEach { index, data in
            let config1 = ImportsConfiguration(
                ignoreCase: data.0,
                ignoreDuplicatedImports: data.1,
                ignoreImportsOrder: data.2,
                ignoreImportsPosition: data.3
            )
            let config2 = ImportsConfiguration(
                ignoreCase: data.0,
                ignoreDuplicatedImports: data.1,
                ignoreImportsOrder: data.2,
                ignoreImportsPosition: data.3
            )
            XCTAssertEqual(config1, config2, "Failed imports configuration equality test data #\(index)")
        }
    }

}

extension RuleConfigurationsTests {
    static var allTests: [(String, (RuleConfigurationsTests) -> () throws -> Void)] {
        return [
            ("testImportsConfigurationSetsCorrectly",
             testImportsConfigurationSetsCorrectly),
            ("testImportsConfigurationThrowsOnBadConfig",
             testImportsConfigurationThrowsOnBadConfig),
            ("testImportsConfigurationIgnoreOrder",
             testImportsConfigurationIgnoreOrder),
            ("testImportsConfigurationIgnorePosition",
             testImportsConfigurationIgnorePosition),
            ("testNameConfigurationSetsCorrectly",
                testNameConfigurationSetsCorrectly),
            ("testNameConfigurationThrowsOnBadConfig",
                testNameConfigurationThrowsOnBadConfig),
            ("testNameConfigurationMinLengthThreshold",
                testNameConfigurationMinLengthThreshold),
            ("testNameConfigurationMaxLengthThreshold",
                testNameConfigurationMaxLengthThreshold),
            ("testSeverityConfigurationFromString",
                testSeverityConfigurationFromString),
            ("testSeverityConfigurationFromDictionary",
                testSeverityConfigurationFromDictionary),
            ("testSeverityConfigurationThrowsOnBadConfig",
                testSeverityConfigurationThrowsOnBadConfig),
            ("testSeverityLevelConfigParams",
                testSeverityLevelConfigParams),
            ("testSeverityLevelConfigPartialParams",
                testSeverityLevelConfigPartialParams),
            ("testRegexConfigurationThrows",
                testRegexConfigurationThrows),
            ("testRegexRuleDescription",
                testRegexRuleDescription),
            ("testTrailingWhitespaceConfigurationThrowsOnBadConfig",
                testTrailingWhitespaceConfigurationThrowsOnBadConfig),
            ("testTrailingWhitespaceConfigurationInitializerSetsIgnoresEmptyLines",
                testTrailingWhitespaceConfigurationInitializerSetsIgnoresEmptyLines),
            ("testTrailingWhitespaceConfigurationInitializerSetsIgnoresComments",
                testTrailingWhitespaceConfigurationInitializerSetsIgnoresComments),
            ("testTrailingWhitespaceConfigurationApplyConfigurationSetsIgnoresEmptyLines",
                testTrailingWhitespaceConfigurationApplyConfigurationSetsIgnoresEmptyLines),
            ("testTrailingWhitespaceConfigurationApplyConfigurationSetsIgnoresComments",
                testTrailingWhitespaceConfigurationApplyConfigurationSetsIgnoresComments),
            ("testTrailingWhitespaceConfigurationCompares",
                testTrailingWhitespaceConfigurationCompares),
            ("testTrailingWhitespaceConfigurationApplyConfigurationUpdatesSeverityConfiguration",
                testTrailingWhitespaceConfigurationApplyConfigurationUpdatesSeverityConfiguration),
            ("testOverridenSuperCallConfigurationFromDictionary",
                testOverridenSuperCallConfigurationFromDictionary)
        ]
    }
}
// swiftlint:enable file_length
