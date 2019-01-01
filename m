Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5E06C8E0002
	for <linux-mm@kvack.org>; Tue,  1 Jan 2019 12:13:06 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id g92-v6so8378319ljg.23
        for <linux-mm@kvack.org>; Tue, 01 Jan 2019 09:13:06 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 142sor8235408lfz.23.2019.01.01.09.13.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 01 Jan 2019 09:13:04 -0800 (PST)
From: Uladzislau Rezki <urezki@gmail.com>
Date: Tue, 1 Jan 2019 18:12:54 +0100
Subject: Re: [RFC v2 3/3] selftests/vm: add script helper for
 CONFIG_TEST_VMALLOC_MODULE
Message-ID: <20190101171254.okatzvgezwkxrvxz@pc636>
References: <20181231132640.21898-1-urezki@gmail.com>
 <20181231132640.21898-4-urezki@gmail.com>
 <5c40e334-f8ae-7fbf-fde1-44bc390ee6a7@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5c40e334-f8ae-7fbf-fde1-44bc390ee6a7@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: shuah <shuah@kernel.org>
Cc: "Uladzislau Rezki (Sony)" <urezki@gmail.com>, Michal Hocko <mhocko@suse.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Thomas Gleixner <tglx@linutronix.de>

On Mon, Dec 31, 2018 at 10:47:55AM -0700, shuah wrote:
> On 12/31/18 6:26 AM, Uladzislau Rezki (Sony) wrote:
> > Add the test script for the kernel test driver to analyse vmalloc
> > allocator for benchmarking and stressing purposes. It is just a kernel
> > module loader. You can specify and pass different parameters in order
> > to investigate allocations behaviour. See "usage" output for more
> > details.
> > 
> > Also add basic vmalloc smoke test to the "run_vmtests" suite.
> 
> Thanks for the test. A few comments below.
> 
> > 
> > Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
> > ---
> >   tools/testing/selftests/vm/run_vmtests     |  11 ++
> >   tools/testing/selftests/vm/test_vmalloc.sh | 173 +++++++++++++++++++++++++++++
> >   2 files changed, 184 insertions(+)
> >   create mode 100755 tools/testing/selftests/vm/test_vmalloc.sh
> > 
> > diff --git a/tools/testing/selftests/vm/run_vmtests b/tools/testing/selftests/vm/run_vmtests
> > index 88cbe5575f0c..56053ac2bf47 100755
> > --- a/tools/testing/selftests/vm/run_vmtests
> > +++ b/tools/testing/selftests/vm/run_vmtests
> > @@ -200,4 +200,15 @@ else
> >       echo "[PASS]"
> >   fi
> > +echo "------------------------------------"
> > +echo "running vmalloc stability smoke test"
> > +echo "------------------------------------"
> > +./test_vmalloc.sh smoke
> > +if [ $? -ne 0 ]; then
> > +	echo "[FAIL]"
> > +	exitcode=1
> 
> Please handle skil cases - exit code for skip is 4.
> 
Will add skip case.


> > +else
> > +	echo "[PASS]"
> > +fi
> > +
> >   exit $exitcode
> > diff --git a/tools/testing/selftests/vm/test_vmalloc.sh b/tools/testing/selftests/vm/test_vmalloc.sh
> > new file mode 100755
> > index 000000000000..f4f0d3990f2c
> > --- /dev/null
> > +++ b/tools/testing/selftests/vm/test_vmalloc.sh
> > @@ -0,0 +1,173 @@
> > +#!/bin/bash
> > +# SPDX-License-Identifier: GPL-2.0
> > +#
> > +# Copyright (C) 2018 Uladzislau Rezki (Sony) <urezki@gmail.com>
> > +#
> > +# This is a test script for the kernel test driver to analyse vmalloc
> > +# allocator. Therefore it is just a kernel module loader. You can specify
> > +# and pass different parameters in order to:
> > +#     a) analyse performance of vmalloc allocations;
> > +#     b) stressing and stability check of vmalloc subsystem.
> > +
> > +TEST_NAME="vmalloc"
> > +DRIVER="test_${TEST_NAME}"
> > +
> > +# 1 if fails
> > +exitcode=1
> > +
> > +#
> > +# Static templates for performance, stressing and smoke tests.
> > +# Also it is possible to pass any supported parameters manualy.
> > +#
> > +PERF_PARAM="single_cpu_test=1 sequential_test_order=1 test_repeat_count=3"
> > +SMOKE_PARAM="single_cpu_test=1 test_loop_count=10000 test_repeat_count=10"
> > +STRESS_PARAM="test_repeat_count=20"
> > +
> > +check_test_requirements()
> > +{
> > +	uid=$(id -u)
> > +	if [ $uid -ne 0 ]; then
> > +		echo "$0: Must be run as root"
> > +		exit $exitcode
> 
> This is a skip and not a fail.
> 
Will update it. Agree it should not interrupt test sequence.

> > +	fi
> > +
> > +	if ! which modprobe > /dev/null 2>&1; then
> > +		echo "$0: You need modprobe installed"
> > +		exit $exitcode
> 
> This is a skip and not a fail.
> 
Will update it.

> > +	fi
> > +
> > +	if ! modinfo $DRIVER > /dev/null 2>&1; then
> > +		echo "$0: You must have the following enabled in your kernel:"
> > +		echo "CONFIG_TEST_VMALLOC=m"
> > +		exit $exitcode
> 
> This is a skip and not a fail.
> 
Will update it.

> > +	fi
> > +}
> > +
> > +run_perfformance_check()
> > +{
> > +	echo "Run performance tests to evaluate how fast vmalloc allocation is."
> > +	echo "It runs all test cases on one single CPU with sequential order."
> > +
> > +	modprobe $DRIVER $PERF_PARAM > /dev/null 2>&1
> > +	echo "Done."
> > +	echo "Ccheck the kernel message buffer to see the summary."
> > +}
> > +
> > +run_stability_check()
> > +{
> > +	echo "Run stability tests. In order to stress vmalloc subsystem we run"
> > +	echo "all available test cases on all available CPUs simultaneously."
> > +	echo "It will take time, so be patient."
> > +
> > +	modprobe $DRIVER $STRESS_PARAM > /dev/null 2>&1
> > +	echo "Done."
> > +	echo "Check the kernel ring buffer to see the summary."
> > +}
> > +
> > +run_smoke_check()
> > +{
> > +	echo "Run smoke test. Note, this test provides basic coverage."
> > +	echo "Please check $0 output how it can be used"
> > +	echo "for deep performance analysis as well as stress testing."
> > +
> > +	modprobe $DRIVER $SMOKE_PARAM > /dev/null 2>&1
> > +	echo "Done."
> > +	echo "Check the kernel ring buffer to see the summary."
> > +}
> > +
> > +usage()
> > +{
> > +	echo -n "Usage: $0 [ performance ] | [ stress ] | | [ smoke ] | "
> > +	echo "manual parameters"
> > +	echo
> > +	echo "Valid tests and parameters:"
> > +	echo
> > +	modinfo $DRIVER
> > +	echo
> > +	echo "Example usage:"
> > +	echo
> > +	echo "# Shows help message"
> > +	echo "./${DRIVER}.sh"
> > +	echo
> > +	echo "# Runs 1 test(id_1), repeats it 5 times on all online CPUs"
> > +	echo "./${DRIVER}.sh run_test_mask=1 test_repeat_count=5"
> > +	echo
> > +	echo -n "# Runs 4 tests(id_1|id_2|id_4|id_16) on one CPU with "
> > +	echo "sequential order"
> > +	echo -n "./${DRIVER}.sh single_cpu_test=1 sequential_test_order=1 "
> > +	echo "run_test_mask=23"
> > +	echo
> > +	echo -n "# Runs all tests on all online CPUs, shuffled order, repeats "
> > +	echo "20 times"
> > +	echo "./${DRIVER}.sh test_repeat_count=20"
> > +	echo
> > +	echo "# Performance analysis"
> > +	echo "./${DRIVER}.sh performance"
> > +	echo
> > +	echo "# Stress testing"
> > +	echo "./${DRIVER}.sh stress"
> > +	echo
> > +	exit $exitcode
> > +}
> > +
> > +function validate_passed_args()
> > +{
> > +	VALID_ARGS=`modinfo $DRIVER | awk '/parm:/ {print $2}' | sed 's/:.*//'`
> > +
> > +	#
> > +	# Something has been passed, check it.
> > +	#
> > +	for passed_arg in $@; do
> > +		key=${passed_arg//=*/}
> > +		val="${passed_arg:$((${#key}+1))}"
> > +		valid=0
> > +
> > +		for valid_arg in $VALID_ARGS; do
> > +			if [[ $key = $valid_arg ]] && [[ $val -gt 0 ]]; then
> > +				valid=1
> > +				break
> > +			fi
> > +		done
> > +
> > +		if [[ $valid -ne 1 ]]; then
> > +			echo "Error: key or value is not correct: ${key} $val"
> > +			exit $exitcode
> > +		fi
> > +	done
> > +}
> > +
> > +function run_manual_check()
> > +{
> > +	#
> > +	# Validate passed parameters. If there is wrong one,
> > +	# the script exists and does not execute further.
> > +	#
> > +	validate_passed_args $@
> > +
> > +	echo "Run the test with following parameters: $@"
> > +	modprobe $DRIVER $@ > /dev/null 2>&1
> > +	echo "Done."
> > +	echo "Check the kernel ring buffer to see the summary."
> > +}
> > +
> > +function run_test()
> > +{
> > +	if [ $# -eq 0 ]; then
> > +		usage
> > +	else
> > +		if [[ "$1" = "performance" ]]; then
> > +			run_perfformance_check
> > +		elif [[ "$1" = "stress" ]]; then
> > +			run_stability_check
> > +		elif [[ "$1" = "smoke" ]]; then
> > +			run_smoke_check
> > +		else
> > +			run_manual_check $@
> > +		fi
> > +	fi
> > +}
> > +
> > +check_test_requirements
> > +run_test $@
> > +
> > +exit 0
> > 
> 
> thanks,
> -- Shuah
