Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id E125F6B026A
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 10:16:46 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id h77-v6so3988570lji.10
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 07:16:46 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x25sor827019lfe.65.2018.11.13.07.16.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Nov 2018 07:16:43 -0800 (PST)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Subject: [RFC PATCH 1/1] vmalloc: add test driver to analyse vmalloc allocator
Date: Tue, 13 Nov 2018 16:16:29 +0100
Message-Id: <20181113151629.14826-2-urezki@gmail.com>
In-Reply-To: <20181113151629.14826-1-urezki@gmail.com>
References: <20181113151629.14826-1-urezki@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Kees Cook <keescook@chromium.org>, Shuah Khan <shuah@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: LKML <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Thomas Gleixner <tglx@linutronix.de>, "Uladzislau Rezki (Sony)" <urezki@gmail.com>

This adds a new kernel module for analysis of vmalloc allocator. It is
only enabled as a module. There are two main reasons this module should
be used for. Those are performance evaluation and stressing of vmalloc
subsystem.

It consists of several test cases. As of now there are 8. The module
has four parameters we can specify, therefore change the behaviour.

1) run_test_mask - set of tests to be run

0 fix_size_alloc_test
1 full_fit_alloc_test
2 long_busy_list_alloc_test
3 random_size_alloc_test
4 fix_align_alloc_test
5 random_size_align_alloc_test
6 align_shift_alloc_test
7 pcpu_alloc_test

By default all tests are in run test mask. If you want to select some
specific tests it is possible to pass the mask. For example for first,
second and fourth tests we go with (1 << 0 | 1 << 1 | 1 << 3) that is
11 value.

2) test_repeat_count - how many times each test should be repeated
By default it is one time per test. It is possible to pass any number.
As high the value is the test duration gets increased.

3) single_cpu_test - use one CPU to run the tests
By default this parameter is set to false. It means that all online
CPUs execute tests. By setting it to 1, the tests are executed by
first online CPU only.

4) sequential_test_order - run tests in sequential order
By default this parameter is set to false. It means that before running
tests the order is shuffled. It is possible to make it sequential, just
set it to 1.

Performance analysis:
In order to evaluate performance of vmalloc allocations, usually it
makes sense to use only one CPU that runs tests, use sequential order,
number of repeat tests can be different as well as set of test mask.

For example if we want to run all tests, to use one CPU and repeat each
test 3 times. Insert the module passing following parameters:

single_cpu_test=1 sequential_test_order=1 test_repeat_count=3

with following output:

<snip>
Summary: fix_size_alloc_test 3 passed, 0 failed, test_count: 3, average: 918249 usec
Summary: full_fit_alloc_test 3 passed, 0 failed, test_count: 3, average: 1046232 usec
Summary: long_busy_list_alloc_test 3 passed, 0 failed, test_count: 3, average: 12000280 usec
Summary: random_size_alloc_test 3 passed, 0 failed, test_count: 3, average: 6184357 usec
Summary: fix_align_alloc_test 3 passed, 0 failed, test_count: 3, average: 2319067 usec
Summary: random_size_align_alloc_test 3 passed, 0 failed, test_count: 3, average: 2858425 usec
Summary: align_shift_alloc_test 0 passed, 3 failed, test_count: 3, average: 373 usec
Summary: pcpu_alloc_test 3 passed, 0 failed, test_count: 3, average: 93407 usec
All test took CPU0=197829986888 cycles
<snip>

The align_shift_alloc_test is expected to be failed.

Stressing:
In order to stress the vmalloc subsystem we run all available test cases
on all available CPUs simultaneously. In order to prevent constant behaviour
pattern, the test cases array is shuffled by default to randomize the order
of test execution.

For example if we want to run all tests(default), use all online CPUs(default)
with shuffled order(default) and to repeat each test 30 times. The command
would be like:

modprobe vmalloc_test test_repeat_count=30

Expected results are the system is alive, there are no any BUG_ONs or Kernel
Panics the tests are completed, no memory leaks.

Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
---
 lib/Kconfig.debug  |  12 ++
 lib/Makefile       |   1 +
 lib/test_vmalloc.c | 546 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 559 insertions(+)
 create mode 100644 lib/test_vmalloc.c

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 8838d1158d19..ca8a1a55d777 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1851,6 +1851,18 @@ config TEST_LKM
 
 	  If unsure, say N.
 
+config TEST_VMALLOC
+	tristate "Test module for stress/performance analysis of vmalloc allocator"
+	default n
+	depends on m
+	help
+	  This builds the "vmalloc_test" module that should be used for
+	  stress and performance analysis. So, any new change for vmalloc
+	  subsystem can be evaluated from performance and stability point
+	  of view.
+
+	  If unsure, say N.
+
 config TEST_USER_COPY
 	tristate "Test user/kernel boundary protections"
 	default n
diff --git a/lib/Makefile b/lib/Makefile
index 90dc5520b784..2caa6161b417 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -57,6 +57,7 @@ UBSAN_SANITIZE_test_ubsan.o := y
 obj-$(CONFIG_TEST_KSTRTOX) += test-kstrtox.o
 obj-$(CONFIG_TEST_LIST_SORT) += test_list_sort.o
 obj-$(CONFIG_TEST_LKM) += test_module.o
+obj-$(CONFIG_TEST_VMALLOC) += test_vmalloc.o
 obj-$(CONFIG_TEST_OVERFLOW) += test_overflow.o
 obj-$(CONFIG_TEST_RHASHTABLE) += test_rhashtable.o
 obj-$(CONFIG_TEST_SORT) += test_sort.o
diff --git a/lib/test_vmalloc.c b/lib/test_vmalloc.c
new file mode 100644
index 000000000000..e61293c53f4d
--- /dev/null
+++ b/lib/test_vmalloc.c
@@ -0,0 +1,546 @@
+/*
+ * Test module for stress and analyze performance of vmalloc allocator.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation; either version 2 of the License, or at your option any
+ * later version; or, when distributed separately from the Linux kernel or
+ * when incorporated into other software packages, subject to the following
+ * license:
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of copyleft-next (version 0.3.1 or later) as published
+ * at http://copyleft-next.org/.
+ *
+ * (C) 2018 Uladzislau Rezki (Sony) <urezki@gmail.com>
+ */
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/vmalloc.h>
+#include <linux/random.h>
+#include <linux/completion.h>
+#include <linux/kthread.h>
+#include <linux/kallsyms.h>
+#include <linux/moduleparam.h>
+
+#define __param(type, name, init, msg)		\
+	static type name = init;				\
+	module_param(name, type, 0444);			\
+	MODULE_PARM_DESC(name, msg);
+
+__param(bool, single_cpu_test, false,
+	"Use single first online CPU to run tests");
+
+__param(bool, sequential_test_order, false,
+	"Use sequential stress tests order");
+
+__param(int, run_test_mask, INT_MAX,
+	"Run tests specified in the mask");
+
+__param(int, test_repeat_count, 1,
+	"How many times to repeat each test");
+
+static void *((*__my_vmalloc_node_range)(unsigned long size,
+	unsigned long align, unsigned long start,
+	unsigned long end, gfp_t gfp_mask, pgprot_t prot,
+	unsigned long vm_flags, int node, const void *caller));
+
+static int random_size_align_alloc_test(void)
+{
+	unsigned long size, align, rnd;
+	void *ptr;
+	int i;
+
+	for (i = 0; i < 1000000; i++) {
+		get_random_bytes(&rnd, sizeof(rnd));
+
+		/*
+		 * Maximum 1024 pages, if PAGE_SIZE is 4096.
+		 */
+		align = 1 << (rnd % 23);
+
+		/*
+		 * Maximum 10 pages.
+		 */
+		size = ((rnd % 10) + 1) * PAGE_SIZE;
+
+		ptr = __my_vmalloc_node_range(size, align,
+		   VMALLOC_START, VMALLOC_END,
+		   GFP_KERNEL | __GFP_ZERO,
+		   PAGE_KERNEL,
+		   0, 0, __builtin_return_address(0));
+
+		if (!ptr)
+			return -1;
+
+		vfree(ptr);
+	}
+
+	return 0;
+}
+
+/*
+ * This test case is supposed to be failed.
+ */
+static int align_shift_alloc_test(void)
+{
+	unsigned long align;
+	void *ptr;
+	int i;
+
+	for (i = 0; i < BITS_PER_LONG; i++) {
+		align = ((unsigned long) 1) << i;
+
+		ptr = __my_vmalloc_node_range(PAGE_SIZE, align,
+			VMALLOC_START, VMALLOC_END,
+			GFP_KERNEL | __GFP_ZERO,
+			PAGE_KERNEL,
+			0, 0, __builtin_return_address(0));
+
+		if (!ptr)
+			return -1;
+
+		vfree(ptr);
+	}
+
+	return 0;
+}
+
+static int fix_align_alloc_test(void)
+{
+	void *ptr;
+	int i;
+
+	for (i = 0; i < 1000000; i++) {
+		ptr = __my_vmalloc_node_range(5 * PAGE_SIZE,
+			THREAD_ALIGN << 1,
+			VMALLOC_START, VMALLOC_END,
+			GFP_KERNEL | __GFP_ZERO,
+			PAGE_KERNEL,
+			0, 0, __builtin_return_address(0));
+
+		if (!ptr)
+			return -1;
+
+		vfree(ptr);
+	}
+
+	return 0;
+}
+
+static int random_size_alloc_test(void)
+{
+	unsigned int n;
+	void *p;
+	int i;
+
+	for (i = 0; i < 1000000; i++) {
+		get_random_bytes(&n, sizeof(i));
+		n = (n % 100) + 1;
+
+		p = vmalloc(n * PAGE_SIZE);
+
+		if (!p)
+			return -1;
+
+		*((__u8 *)p) = 1;
+		vfree(p);
+	}
+
+	return 0;
+}
+
+static int long_busy_list_alloc_test(void)
+{
+	void *ptr_1, *ptr_2;
+	void **ptr;
+	int rv = -1;
+	int i;
+
+	ptr = vmalloc(sizeof(void *) * 15000);
+	if (!ptr)
+		return rv;
+
+	for (i = 0; i < 15000; i++)
+		ptr[i] = vmalloc(1 * PAGE_SIZE);
+
+	for (i = 0; i < 1000000; i++) {
+		ptr_1 = vmalloc(100 * PAGE_SIZE);
+		if (!ptr_1)
+			goto leave;
+
+		ptr_2 = vmalloc(1 * PAGE_SIZE);
+		if (!ptr_2) {
+			vfree(ptr_1);
+			goto leave;
+		}
+
+		*((__u8 *)ptr_1) = 0;
+		*((__u8 *)ptr_2) = 1;
+
+		vfree(ptr_1);
+		vfree(ptr_2);
+	}
+
+	/*  Success */
+	rv = 0;
+
+leave:
+	for (i = 0; i < 15000; i++)
+		vfree(ptr[i]);
+
+	vfree(ptr);
+	return rv;
+}
+
+static int full_fit_alloc_test(void)
+{
+	void **ptr, **junk_ptr, *tmp;
+	int junk_length;
+	int rv = -1;
+	int i;
+
+	junk_length = fls(num_online_cpus());
+	junk_length *= (32 * 1024 * 1024 / PAGE_SIZE);
+
+	ptr = vmalloc(sizeof(void *) * junk_length);
+	if (!ptr)
+		return rv;
+
+	junk_ptr = vmalloc(sizeof(void *) * junk_length);
+	if (!junk_ptr) {
+		vfree(ptr);
+		return rv;
+	}
+
+	for (i = 0; i < junk_length; i++) {
+		ptr[i] = vmalloc(1 * PAGE_SIZE);
+		junk_ptr[i] = vmalloc(1 * PAGE_SIZE);
+	}
+
+	for (i = 0; i < junk_length; i++)
+		vfree(junk_ptr[i]);
+
+	for (i = 0; i < 1000000; i++) {
+		tmp = vmalloc(1 * PAGE_SIZE);
+
+		if (!tmp)
+			goto error;
+
+		*((__u8 *)tmp) = 1;
+		vfree(tmp);
+	}
+
+	/* Success */
+	rv = 0;
+
+error:
+	for (i = 0; i < junk_length; i++)
+		vfree(ptr[i]);
+
+	vfree(ptr);
+	vfree(junk_ptr);
+
+	return rv;
+}
+
+static int fix_size_alloc_test(void)
+{
+	void *ptr;
+	int i;
+
+	for (i = 0; i < 1000000; i++) {
+		ptr = vmalloc(3 * PAGE_SIZE);
+
+		if (!ptr)
+			return -1;
+
+		*((__u8 *)ptr) = 0;
+
+		vfree(ptr);
+	}
+
+	return 0;
+}
+
+static int
+pcpu_alloc_test(void)
+{
+	int rv = 0;
+#ifndef CONFIG_NEED_PER_CPU_KM
+	void __percpu **pcpu;
+	size_t size, align;
+	int i;
+
+	pcpu = vmalloc(sizeof(void __percpu *) * 35000);
+	if (!pcpu)
+		return -1;
+
+	for (i = 0; i < 35000; i++) {
+		unsigned int r;
+
+		get_random_bytes(&r, sizeof(i));
+		size = (r % (PAGE_SIZE / 4)) + 1;
+
+		/*
+		 * Maximum PAGE_SIZE
+		 */
+		get_random_bytes(&r, sizeof(i));
+		align = 1 << ((i % 11) + 1);
+
+		pcpu[i] = __alloc_percpu(size, align);
+		if (!pcpu[i])
+			rv = -1;
+	}
+
+	for (i = 0; i < 35000; i++)
+		free_percpu(pcpu[i]);
+
+	vfree(pcpu);
+#endif
+	return rv;
+}
+
+struct test_case_desc {
+	const char *test_name;
+	int (*test_func)(void);
+};
+
+static struct test_case_desc test_case_array[] = {
+	{ "fix_size_alloc_test", fix_size_alloc_test },
+	{ "full_fit_alloc_test", full_fit_alloc_test },
+	{ "long_busy_list_alloc_test", long_busy_list_alloc_test },
+	{ "random_size_alloc_test", random_size_alloc_test },
+	{ "fix_align_alloc_test", fix_align_alloc_test },
+	{ "random_size_align_alloc_test", random_size_align_alloc_test },
+	{ "align_shift_alloc_test", align_shift_alloc_test },
+	{ "pcpu_alloc_test", pcpu_alloc_test },
+};
+
+struct test_case_data {
+	/* Configuration part. */
+	int test_count;
+
+	/* Results part. */
+	int test_failed;
+	int test_passed;
+	s64 time;
+};
+
+/* Split it to get rid of: WARNING: line over 80 characters */
+static struct test_case_data
+	per_cpu_test_data[NR_CPUS][ARRAY_SIZE(test_case_array)];
+
+static struct test_driver {
+	struct task_struct *task;
+	unsigned long start;
+	unsigned long stop;
+	int cpu;
+} per_cpu_test_driver[NR_CPUS];
+
+static atomic_t tests_running;
+static atomic_t phase1_complete;
+static DECLARE_COMPLETION(completion1);
+static DECLARE_COMPLETION(completion2);
+
+static void shuffle_array(int *arr, int n)
+{
+	unsigned int rnd;
+	int i, j, x;
+
+	for (i = n - 1; i > 0; i--)  {
+		get_random_bytes(&rnd, sizeof(rnd));
+
+		/* Cut the range. */
+		j = rnd % i;
+
+		/* Swap indexes. */
+		x = arr[i];
+		arr[i] = arr[j];
+		arr[j] = x;
+	}
+}
+
+static int test_func(void *private)
+{
+	struct test_driver *t = private;
+	cpumask_t newmask = CPU_MASK_NONE;
+	int random_array[ARRAY_SIZE(test_case_array)];
+	int index, repeat, i, j, ret;
+	ktime_t kt;
+
+	cpumask_set_cpu(t->cpu, &newmask);
+	set_cpus_allowed_ptr(current, &newmask);
+
+	atomic_inc(&tests_running);
+	wait_for_completion(&completion1);
+
+	for (i = 0; i < ARRAY_SIZE(test_case_array); i++)
+		random_array[i] = i;
+
+	if (!sequential_test_order)
+		shuffle_array(random_array, ARRAY_SIZE(test_case_array));
+
+	t->start = get_cycles();
+	for (i = 0; i < ARRAY_SIZE(test_case_array); i++) {
+		index = random_array[i];
+
+		/*
+		 * Skip tests if run_test_mask has been specified.
+		 */
+		if (!((run_test_mask & (1 << index)) >> index))
+			continue;
+
+		repeat = per_cpu_test_data[t->cpu][index].test_count;
+
+		kt = ktime_get();
+		for (j = 0; j < repeat; j++) {
+			ret = test_case_array[index].test_func();
+			if (!ret)
+				per_cpu_test_data[t->cpu][index].test_passed++;
+			else
+				per_cpu_test_data[t->cpu][index].test_failed++;
+		}
+
+		/*
+		 * Take an average time that test took.
+		 */
+		per_cpu_test_data[t->cpu][index].time =
+			ktime_us_delta(ktime_get(), kt) / repeat;
+	}
+	t->stop = get_cycles();
+
+	atomic_inc(&phase1_complete);
+	wait_for_completion(&completion2);
+
+	atomic_dec(&tests_running);
+	set_current_state(TASK_UNINTERRUPTIBLE);
+	schedule();
+	return 0;
+}
+
+static void
+set_test_configurtion(void)
+{
+	int i, j;
+
+	/*
+	 * Reset all data of all CPUs.
+	 */
+	memset(per_cpu_test_data, 0, sizeof(per_cpu_test_data));
+
+	/*
+	 * Here we set different test parameters per CPU.
+	 * There is only one so far. That is a number of times
+	 * each test has to be repeated.
+	 */
+	for (i = 0; i < NR_CPUS; i++)
+		for (j = 0; j < ARRAY_SIZE(test_case_array); j++)
+			per_cpu_test_data[i][j].test_count = test_repeat_count;
+}
+
+static void do_concurrent_test(void)
+{
+	cpumask_t cpus_run_test_mask;
+	int cpu;
+
+	atomic_set(&tests_running, 0);
+	atomic_set(&phase1_complete, 0);
+	init_completion(&completion1);
+	init_completion(&completion2);
+
+	/*
+	 * Set some basic configurations, like repeat counter.
+	 */
+	set_test_configurtion();
+
+	cpumask_and(&cpus_run_test_mask,
+		cpu_online_mask, cpu_online_mask);
+
+	if (single_cpu_test) {
+		cpumask_clear(&cpus_run_test_mask);
+
+		cpumask_set_cpu(cpumask_first(cpu_online_mask),
+			&cpus_run_test_mask);
+	}
+
+	for_each_cpu(cpu, &cpus_run_test_mask) {
+		struct test_driver *t = &per_cpu_test_driver[cpu];
+
+		t->cpu = cpu;
+		t->task = kthread_run(test_func, t, "test%d", cpu);
+		if (IS_ERR(t->task)) {
+			pr_err("Failed to start test func\n");
+			return;
+		}
+	}
+
+	/* Wait till all processes are running */
+	while (atomic_read(&tests_running) <
+			cpumask_weight(&cpus_run_test_mask)) {
+		set_current_state(TASK_UNINTERRUPTIBLE);
+		schedule_timeout(10);
+	}
+	complete_all(&completion1);
+
+	/* Wait till all processes have completed phase 1 */
+	while (atomic_read(&phase1_complete) <
+			cpumask_weight(&cpus_run_test_mask)) {
+		set_current_state(TASK_UNINTERRUPTIBLE);
+		schedule_timeout(10);
+	}
+	complete_all(&completion2);
+
+	while (atomic_read(&tests_running)) {
+		set_current_state(TASK_UNINTERRUPTIBLE);
+		schedule_timeout(10);
+	}
+
+	for_each_cpu(cpu, &cpus_run_test_mask) {
+		struct test_driver *t = &per_cpu_test_driver[cpu];
+		int i;
+
+		kthread_stop(t->task);
+
+		for (i = 0; i < ARRAY_SIZE(test_case_array); i++) {
+			if (!((run_test_mask & (1 << i)) >> i))
+				continue;
+
+			pr_info(
+				"Summary: %s %d passed, %d failed, test_count: %d, average: %llu usec\n",
+				test_case_array[i].test_name,
+				per_cpu_test_data[cpu][i].test_passed,
+				per_cpu_test_data[cpu][i].test_failed,
+				per_cpu_test_data[cpu][i].test_count,
+				per_cpu_test_data[cpu][i].time);
+		}
+
+		pr_info("All test took CPU%d=%lu cycles\n",
+			cpu, t->stop - t->start);
+	}
+
+	schedule_timeout(200);
+}
+
+static int vmalloc_test_init(void)
+{
+	__my_vmalloc_node_range =
+		(void *) kallsyms_lookup_name("__vmalloc_node_range");
+
+	if (__my_vmalloc_node_range)
+		do_concurrent_test();
+
+	return -EAGAIN; /* Fail will directly unload the module */
+}
+
+static void vmalloc_test_exit(void)
+{
+}
+
+module_init(vmalloc_test_init)
+module_exit(vmalloc_test_exit)
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Uladzislau Rezki");
+MODULE_DESCRIPTION("vmalloc test module");
-- 
2.11.0
