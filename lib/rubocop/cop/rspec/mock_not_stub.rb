# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks that stubs aren't added to mocks.
      #
      # @example
      #
      #   # bad
      #   expect(foo).to receive(:bar).with(42).and_return("hello world")
      #
      #   # good (without spies)
      #   allow(foo).to receive(:bar).with(42).and_return("hello world")
      #   expect(foo).to receive(:bar).with(42)
      #
      #   # good (with spies)
      #   allow(foo).to receive(:bar).with(42).and_return("hello world")
      #   expect(foo).to have_received(:bar).with(42)
      #
      class MockNotStub < Cop
        include RuboCop::RSpec::SpecOnly

        MSG = "Don't stub your mock.".freeze

        def_node_matcher :message_expectation_with_return_block, <<-PATTERN
          (send
            (send nil :expect ...) :to
            {
              (send #receive :and_return $_)
              (block #receive (args) $_)
            }
          )
        PATTERN

        def_node_matcher :receive, <<-PATTERN
          {
            (send nil :receive ...)
            (send (send nil :receive ...) :with ...)
          }
        PATTERN

        def on_send(node)
          message_expectation_with_return_block(node) do |match|
            add_offense(match, :expression)
          end
        end
      end
    end
  end
end