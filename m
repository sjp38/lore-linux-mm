Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 13F088E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 09:22:40 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id l12-v6so9404914ljb.11
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 06:22:40 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r16-v6sor31631756ljr.41.2019.01.03.06.22.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 Jan 2019 06:22:38 -0800 (PST)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Subject: [RFC PATCH 3/3] selftests/vm: add script helper for CONFIG_TEST_VMALLOC_MODULE
Date: Thu,  3 Jan 2019 15:21:08 +0100
Message-Id: <20190103142108.20744-4-urezki@gmail.com>
In-Reply-To: <20190103142108.20744-1-urezki@gmail.com>
References: <20190103142108.20744-1-urezki@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, Shuah Khan <shuah@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Thomas Gleixner <tglx@linutronix.de>, "Uladzislau Rezki (Sony)" <urezki@gmail.com>

Add the test script for the kernel test driver to analyse vmalloc
allocator for benchmarking and stressing purposes. It is just a kernel
module loader. You can specify and pass different parameters in order
to investigate allocations behaviour. See "usage" output for more
details.

Also add basic vmalloc smoke test to the "run_vmtests" suite.

Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
---
 tools/testing/selftests/vm/run_vmtests     |  16 +++
 tools/testing/selftests/vm/test_vmalloc.sh | 176 +++++++++++++++++++++++++++++
 2 files changed, 192 insertions(+)
 create mode 100755 tools/testing/selftests/vm/test_vmalloc.sh

diff --git a/tools/testing/selftests/vm/run_vmtests b/tools/testing/selftests/vm/run_vmtests
index 584a91ae4a8f..951c507a27f7 100755
--- a/tools/testing/selftests/vm/run_vmtests
+++ b/tools/testing/selftests/vm/run_vmtests
@@ -211,4 +211,20 @@ else
     echo "[PASS]"
 fi
 
+echo "------------------------------------"
+echo "running vmalloc stability smoke test"
+echo "------------------------------------"
+./test_vmalloc.sh smoke
+ret_val=$?
+
+if [ $ret_val -eq 0 ]; then
+	echo "[PASS]"
+elif [ $ret_val -eq $ksft_skip ]; then
+	 echo "[SKIP]"
+	 exitcode=$ksft_skip
+else
+	echo "[FAIL]"
+	exitcode=1
+fi
+
 exit $exitcode
diff --git a/tools/testing/selftests/vm/test_vmalloc.sh b/tools/testing/selftests/vm/test_vmalloc.sh
new file mode 100755
index 000000000000..06d2bb109f06
--- /dev/null
+++ b/tools/testing/selftests/vm/test_vmalloc.sh
@@ -0,0 +1,176 @@
+#!/bin/bash
+# SPDX-License-Identifier: GPL-2.0
+#
+# Copyright (C) 2018 Uladzislau Rezki (Sony) <urezki@gmail.com>
+#
+# This is a test script for the kernel test driver to analyse vmalloc
+# allocator. Therefore it is just a kernel module loader. You can specify
+# and pass different parameters in order to:
+#     a) analyse performance of vmalloc allocations;
+#     b) stressing and stability check of vmalloc subsystem.
+
+TEST_NAME="vmalloc"
+DRIVER="test_${TEST_NAME}"
+
+# 1 if fails
+exitcode=1
+
+# Kselftest framework requirement - SKIP code is 4.
+ksft_skip=4
+
+#
+# Static templates for performance, stressing and smoke tests.
+# Also it is possible to pass any supported parameters manualy.
+#
+PERF_PARAM="single_cpu_test=1 sequential_test_order=1 test_repeat_count=3"
+SMOKE_PARAM="single_cpu_test=1 test_loop_count=10000 test_repeat_count=10"
+STRESS_PARAM="test_repeat_count=20"
+
+check_test_requirements()
+{
+	uid=$(id -u)
+	if [ $uid -ne 0 ]; then
+		echo "$0: Must be run as root"
+		exit $ksft_skip
+	fi
+
+	if ! which modprobe > /dev/null 2>&1; then
+		echo "$0: You need modprobe installed"
+		exit $ksft_skip
+	fi
+
+	if ! modinfo $DRIVER > /dev/null 2>&1; then
+		echo "$0: You must have the following enabled in your kernel:"
+		echo "CONFIG_TEST_VMALLOC=m"
+		exit $ksft_skip
+	fi
+}
+
+run_perfformance_check()
+{
+	echo "Run performance tests to evaluate how fast vmalloc allocation is."
+	echo "It runs all test cases on one single CPU with sequential order."
+
+	modprobe $DRIVER $PERF_PARAM > /dev/null 2>&1
+	echo "Done."
+	echo "Ccheck the kernel message buffer to see the summary."
+}
+
+run_stability_check()
+{
+	echo "Run stability tests. In order to stress vmalloc subsystem we run"
+	echo "all available test cases on all available CPUs simultaneously."
+	echo "It will take time, so be patient."
+
+	modprobe $DRIVER $STRESS_PARAM > /dev/null 2>&1
+	echo "Done."
+	echo "Check the kernel ring buffer to see the summary."
+}
+
+run_smoke_check()
+{
+	echo "Run smoke test. Note, this test provides basic coverage."
+	echo "Please check $0 output how it can be used"
+	echo "for deep performance analysis as well as stress testing."
+
+	modprobe $DRIVER $SMOKE_PARAM > /dev/null 2>&1
+	echo "Done."
+	echo "Check the kernel ring buffer to see the summary."
+}
+
+usage()
+{
+	echo -n "Usage: $0 [ performance ] | [ stress ] | | [ smoke ] | "
+	echo "manual parameters"
+	echo
+	echo "Valid tests and parameters:"
+	echo
+	modinfo $DRIVER
+	echo
+	echo "Example usage:"
+	echo
+	echo "# Shows help message"
+	echo "./${DRIVER}.sh"
+	echo
+	echo "# Runs 1 test(id_1), repeats it 5 times on all online CPUs"
+	echo "./${DRIVER}.sh run_test_mask=1 test_repeat_count=5"
+	echo
+	echo -n "# Runs 4 tests(id_1|id_2|id_4|id_16) on one CPU with "
+	echo "sequential order"
+	echo -n "./${DRIVER}.sh single_cpu_test=1 sequential_test_order=1 "
+	echo "run_test_mask=23"
+	echo
+	echo -n "# Runs all tests on all online CPUs, shuffled order, repeats "
+	echo "20 times"
+	echo "./${DRIVER}.sh test_repeat_count=20"
+	echo
+	echo "# Performance analysis"
+	echo "./${DRIVER}.sh performance"
+	echo
+	echo "# Stress testing"
+	echo "./${DRIVER}.sh stress"
+	echo
+	exit 0
+}
+
+function validate_passed_args()
+{
+	VALID_ARGS=`modinfo $DRIVER | awk '/parm:/ {print $2}' | sed 's/:.*//'`
+
+	#
+	# Something has been passed, check it.
+	#
+	for passed_arg in $@; do
+		key=${passed_arg//=*/}
+		val="${passed_arg:$((${#key}+1))}"
+		valid=0
+
+		for valid_arg in $VALID_ARGS; do
+			if [[ $key = $valid_arg ]] && [[ $val -gt 0 ]]; then
+				valid=1
+				break
+			fi
+		done
+
+		if [[ $valid -ne 1 ]]; then
+			echo "Error: key or value is not correct: ${key} $val"
+			exit $exitcode
+		fi
+	done
+}
+
+function run_manual_check()
+{
+	#
+	# Validate passed parameters. If there is wrong one,
+	# the script exists and does not execute further.
+	#
+	validate_passed_args $@
+
+	echo "Run the test with following parameters: $@"
+	modprobe $DRIVER $@ > /dev/null 2>&1
+	echo "Done."
+	echo "Check the kernel ring buffer to see the summary."
+}
+
+function run_test()
+{
+	if [ $# -eq 0 ]; then
+		usage
+	else
+		if [[ "$1" = "performance" ]]; then
+			run_perfformance_check
+		elif [[ "$1" = "stress" ]]; then
+			run_stability_check
+		elif [[ "$1" = "smoke" ]]; then
+			run_smoke_check
+		else
+			run_manual_check $@
+		fi
+	fi
+}
+
+check_test_requirements
+run_test $@
+
+exit 0
-- 
2.11.0
