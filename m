Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 5D13C6B010C
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 16:41:25 -0400 (EDT)
Received: by iajr24 with SMTP id r24so13650211iaj.14
        for <linux-mm@kvack.org>; Mon, 19 Mar 2012 13:41:24 -0700 (PDT)
Date: Mon, 19 Mar 2012 13:41:22 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: object allocation benchmark
In-Reply-To: <alpine.DEB.2.00.1203191028160.19189@router.home>
Message-ID: <alpine.DEB.2.00.1203191339470.27517@chino.kir.corp.google.com>
References: <4F6743C2.3090906@parallels.com> <alpine.DEB.2.00.1203191028160.19189@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@parallels.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Suleiman Souhlal <suleiman@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon, 19 Mar 2012, Christoph Lameter wrote:

> I have some in kernel benchmarking tools for page allocator and slab
> allocators. But they are not really clean patches.
> 

This is the latest version of your tools that I have based on 3.3.  Load 
the modules with insmod and it will produce an error to automatically 
unloaded (by design) and check dmesg for the results.
---
 Makefile               |    2 +-
 include/Kbuild         |    1 +
 lib/Kconfig.debug      |    1 +
 tests/Kconfig          |   32 +++++
 tests/Makefile         |    3 +
 tests/pagealloc_test.c |  334 +++++++++++++++++++++++++++++++++++++++++++
 tests/slab_test.c      |  372 ++++++++++++++++++++++++++++++++++++++++++++++++
 tests/vmstat_test.c    |   96 +++++++++++++
 8 files changed, 840 insertions(+), 1 deletion(-)
 create mode 100644 tests/Kconfig
 create mode 100644 tests/Makefile
 create mode 100644 tests/pagealloc_test.c
 create mode 100644 tests/slab_test.c
 create mode 100644 tests/vmstat_test.c

diff --git a/Makefile b/Makefile
--- a/Makefile
+++ b/Makefile
@@ -708,7 +708,7 @@ export mod_strip_cmd
 
 
 ifeq ($(KBUILD_EXTMOD),)
-core-y		+= kernel/ mm/ fs/ ipc/ security/ crypto/ block/
+core-y		+= kernel/ mm/ fs/ ipc/ security/ crypto/ block/ tests/
 
 vmlinux-dirs	:= $(patsubst %/,%,$(filter %/, $(init-y) $(init-m) \
 		     $(core-y) $(core-m) $(drivers-y) $(drivers-m) \
diff --git a/include/Kbuild b/include/Kbuild
--- a/include/Kbuild
+++ b/include/Kbuild
@@ -10,3 +10,4 @@ header-y += video/
 header-y += drm/
 header-y += xen/
 header-y += scsi/
+header-y += tests/
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1123,6 +1123,7 @@ config SYSCTL_SYSCALL_CHECK
 
 source mm/Kconfig.debug
 source kernel/trace/Kconfig
+source tests/Kconfig
 
 config PROVIDE_OHCI1394_DMA_INIT
 	bool "Remote debugging over FireWire early on boot"
diff --git a/tests/Kconfig b/tests/Kconfig
new file mode 100644
--- /dev/null
+++ b/tests/Kconfig
@@ -0,0 +1,32 @@
+menuconfig BENCHMARKS
+	bool "In kernel benchmarks"
+	def_bool n
+	help
+	  Includes in kernel benchmark modules in the build. These modules can
+	  be loaded later to trigger benchmarking kernel subsystems.
+	  Output will be generated in the system log.
+
+if BENCHMARKS
+
+config BENCHMARK_SLAB
+	tristate "Slab allocator Benchmark"
+	depends on m
+	default m
+	help
+	  A benchmark that measures slab allocator performance.
+
+config BENCHMARK_VMSTAT
+	tristate "VM statistics Benchmark"
+	depends on m
+	default m
+	help
+	  A benchmark measuring the performance of vm statistics.
+
+config BENCHMARK_PAGEALLOC
+	tristate "Page Allocator Benchmark"
+	depends on m
+	default m
+	help
+	  A benchmark measuring the performance of the page allocator.
+
+endif # BENCHMARKS
diff --git a/tests/Makefile b/tests/Makefile
new file mode 100644
--- /dev/null
+++ b/tests/Makefile
@@ -0,0 +1,3 @@
+obj-$(CONFIG_BENCHMARK_SLAB) += slab_test.o
+obj-$(CONFIG_BENCHMARK_VMSTAT) += vmstat_test.o
+obj-$(CONFIG_BENCHMARK_PAGEALLOC) += pagealloc_test.o
diff --git a/tests/pagealloc_test.c b/tests/pagealloc_test.c
new file mode 100644
--- /dev/null
+++ b/tests/pagealloc_test.c
@@ -0,0 +1,334 @@
+/* pagealloc_test.c
+ *
+ * Test module for in kernel synthetic page allocator testing.
+ *
+ * Compiled as a module. The module needs to be loaded to run.
+ *
+ * (C) 2009 Linux Foundation, Christoph Lameter <cl@linux-foundation.org>
+ */
+
+
+#include <linux/jiffies.h>
+#include <linux/init.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/slab.h>
+#include <asm/timex.h>
+#include <asm/system.h>
+
+#define TEST_COUNT 1000
+
+#define CONCURRENT_MAX_ORDER 6
+
+#ifdef CONFIG_SMP
+#include <linux/completion.h>
+#include <linux/sched.h>
+#include <linux/workqueue.h>
+#include <linux/kthread.h>
+
+static struct test_struct {
+	struct task_struct *task;
+	int cpu;
+	int order;
+	int count;
+	struct page **v;
+	void (*test_p1)(struct test_struct *);
+	void (*test_p2)(struct test_struct *);
+	unsigned long start1;
+	unsigned long stop1;
+	unsigned long start2;
+	unsigned long stop2;
+} test[NR_CPUS];
+
+/*
+ * Allocate TEST_COUNT objects on cpus > 0 and then all the
+ * objects later on cpu 0
+ */
+static void remote_free_test_p1(struct test_struct *t)
+{
+	int i;
+
+	/* Perform no allocations on cpu 0 */
+	for (i = 0; i < t->count; i++) {
+		struct page *p;
+
+		if (smp_processor_id()) {
+			p = alloc_pages(GFP_KERNEL | __GFP_COMP, t->order);
+			/* Use object */
+			memset(page_address(p), 17, 4);
+		} else
+			p = NULL;
+		t->v[i] = p;
+	}
+}
+
+static void remote_free_test_p2(struct test_struct *t)
+{
+	int i;
+	int cpu;
+
+	/* All frees are completed on cpu zero */
+	if (smp_processor_id())
+		return;
+
+	for_each_online_cpu(cpu)
+		for (i = 0; i < t->count; i++) {
+			struct page *p = test[cpu].v[i];
+
+			if (!p)
+				continue;
+
+			__free_pages(p, t->order);
+		}
+}
+
+/*
+ * Allocate TEST_COUNT objects and later free them all again
+ */
+static void alloc_then_free_test_p1(struct test_struct *t)
+{
+	int i;
+
+	for (i = 0; i < t->count; i++) {
+		struct page *p = alloc_pages(GFP_KERNEL | __GFP_COMP, t->order);
+
+		memset(page_address(p), 14, 4);
+		t->v[i] = p;
+	}
+}
+
+static void alloc_then_free_test_p2(struct test_struct *t)
+{
+	int i;
+
+	for (i = 0; i < t->count; i++) {
+		struct page *p = t->v[i];
+
+		__free_pages(p, t->order);
+	}
+}
+
+/*
+ * Allocate TEST_COUNT objects. Free them immediately.
+ */
+static void alloc_free_test_p1(struct test_struct *t)
+{
+	int i;
+
+	for (i = 0; i < TEST_COUNT; i++) {
+		struct page *p = alloc_pages(GFP_KERNEL | __GFP_COMP, t->order);
+
+		memset(page_address(p), 12, 4);
+		__free_pages(p, t->order);
+	}
+}
+
+static atomic_t tests_running;
+static atomic_t phase1_complete;
+static DECLARE_COMPLETION(completion1);
+static DECLARE_COMPLETION(completion2);
+static int started;
+
+static int test_func(void *private)
+{
+	struct test_struct *t = private;
+	cpumask_t newmask = CPU_MASK_NONE;
+
+	cpu_set(t->cpu, newmask);
+	set_cpus_allowed(current, newmask);
+	t->v = kmalloc(t->count * sizeof(struct page *), GFP_KERNEL);
+
+	atomic_inc(&tests_running);
+	wait_for_completion(&completion1);
+	t->start1 = get_cycles();
+	t->test_p1(t);
+	t->stop1 = get_cycles();
+	atomic_inc(&phase1_complete);
+	wait_for_completion(&completion2);
+	t->start2 = get_cycles();
+	if (t->test_p2)
+		t->test_p2(t);
+	t->stop2 = get_cycles();
+	kfree(t->v);
+	atomic_dec(&tests_running);
+	set_current_state(TASK_UNINTERRUPTIBLE);
+	schedule();
+	return 0;
+}
+
+static void do_concurrent_test(void (*p1)(struct test_struct *),
+		void (*p2)(struct test_struct *),
+		int order, const char *name)
+{
+	int cpu;
+	unsigned long time1 = 0;
+	unsigned long time2 = 0;
+	unsigned long sum1 = 0;
+	unsigned long sum2 = 0;
+
+	atomic_set(&tests_running, 0);
+	atomic_set(&phase1_complete, 0);
+	started = 0;
+	init_completion(&completion1);
+	init_completion(&completion2);
+
+	for_each_online_cpu(cpu) {
+		struct test_struct *t = &test[cpu];
+
+		t->cpu = cpu;
+		t->count = TEST_COUNT;
+		t->test_p1 = p1;
+		t->test_p2 = p2;
+		t->order = order;
+		t->task = kthread_run(test_func, t, "test%d", cpu);
+		if (IS_ERR(t->task)) {
+			printk("Failed to start test func\n");
+			return;
+		}
+	}
+
+	/* Wait till all processes are running */
+	while (atomic_read(&tests_running) < num_online_cpus()) {
+		set_current_state(TASK_UNINTERRUPTIBLE);
+		schedule_timeout(10);
+	}
+	complete_all(&completion1);
+
+	/* Wait till all processes have completed phase 1 */
+	while (atomic_read(&phase1_complete) < num_online_cpus()) {
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
+	for_each_online_cpu(cpu)
+		kthread_stop(test[cpu].task);
+
+	printk(KERN_ALERT "%s(%d):", name, order);
+	for_each_online_cpu(cpu) {
+		struct test_struct *t = &test[cpu];
+
+		time1 = t->stop1 - t->start1;
+		time2 = t->stop2 - t->start2;
+		sum1 += time1;
+		sum2 += time2;
+		printk(" %d=%lu", cpu, time1 / TEST_COUNT);
+		if (p2)
+			printk("/%lu", time2 / TEST_COUNT);
+	}
+	printk(" Average=%lu", sum1 / num_online_cpus() / TEST_COUNT);
+	if (p2)
+		printk("/%lu", sum2 / num_online_cpus() / TEST_COUNT);
+	printk("\n");
+	schedule_timeout(200);
+}
+#endif
+
+static int pagealloc_test_init(void)
+{
+	void **v = kmalloc(TEST_COUNT * sizeof(void *), GFP_KERNEL);
+	unsigned int i;
+	cycles_t time1, time2, time;
+	int rem;
+	int order;
+
+	printk(KERN_ALERT "test init\n");
+
+	printk(KERN_ALERT "Single thread testing\n");
+	printk(KERN_ALERT "=====================\n");
+	printk(KERN_ALERT "1. Repeatedly allocate then free test\n");
+	for (order = 0; order < MAX_ORDER; order++) {
+		time1 = get_cycles();
+		for (i = 0; i < TEST_COUNT; i++) {
+			struct page *p = alloc_pages(GFP_KERNEL | __GFP_COMP,
+						order);
+
+			if (!p) {
+				printk("Cannot allocate order=%d\n", order);
+				break;
+			}
+
+			/* Touch page */
+			memset(page_address(p), 22, 4);
+			v[i] = p;
+		}
+		time2 = get_cycles();
+		time = time2 - time1;
+
+		printk(KERN_ALERT "%i times alloc_page(,%d) ", i, order);
+		time = div_u64_rem(time, TEST_COUNT, &rem);
+		printk("-> %llu cycles ", time);
+
+		time1 = get_cycles();
+		for (i = 0; i < TEST_COUNT; i++) {
+			struct page *p = v[i];
+
+			__free_pages(p, order);
+		}
+		time2 = get_cycles();
+		time = time2 - time1;
+
+		printk("__free_pages(,%d)", order);
+		time = div_u64_rem(time, TEST_COUNT, &rem);
+		printk("-> %llu cycles\n", time);
+	}
+
+	printk(KERN_ALERT "2. alloc/free test\n");
+	for (order = 0; order < MAX_ORDER; order++) {
+		time1 = get_cycles();
+		for (i = 0; i < TEST_COUNT; i++) {
+			struct page *p = alloc_pages(GFP_KERNEL| __GFP_COMP, order);
+
+			__free_pages(p, order);
+		}
+		time2 = get_cycles();
+		time = time2 - time1;
+
+		printk(KERN_ALERT "%i times alloc( ,%d)/free ", i, order);
+		time = div_u64_rem(time, TEST_COUNT, &rem);
+		printk("-> %llu cycles\n", time);
+	}
+	kfree(v);
+#ifdef CONFIG_SMP
+	printk(KERN_INFO "Concurrent allocs\n");
+	printk(KERN_INFO "=================\n");
+	for (order = 0; order < CONCURRENT_MAX_ORDER; order++) {
+		do_concurrent_test(alloc_then_free_test_p1,
+			alloc_then_free_test_p2,
+			order, "Page alloc N*alloc N*free");
+	}
+	printk("----Fastpath---\n");
+	for (order = 0; order < CONCURRENT_MAX_ORDER; order++) {
+		do_concurrent_test(alloc_free_test_p1, NULL,
+			order, "Page N*(alloc free)");
+	}
+
+	printk(KERN_INFO "Remote free test\n");
+	printk(KERN_INFO "================\n");
+	for (order = 0; order < CONCURRENT_MAX_ORDER; order++) {
+		do_concurrent_test(remote_free_test_p1,
+				remote_free_test_p2,
+			order, "N*remote free");
+	}
+
+#endif
+
+	return -EAGAIN; /* Fail will directly unload the module */
+}
+
+static void pagealloc_test_exit(void)
+{
+	printk(KERN_ALERT "test exit\n");
+}
+
+module_init(pagealloc_test_init)
+module_exit(pagealloc_test_exit)
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Christoph Lameter");
+MODULE_DESCRIPTION("page allocator performance test");
diff --git a/tests/slab_test.c b/tests/slab_test.c
new file mode 100644
--- /dev/null
+++ b/tests/slab_test.c
@@ -0,0 +1,372 @@
+/* test-slab.c
+ *
+ * Test module for synthetic in kernel slab allocator testing.
+ *
+ * The test is triggered by loading the module (which will fail).
+ *
+ * (C) 2009 Linux Foundation <cl@linux-foundation.org>
+ */
+
+
+#include <linux/jiffies.h>
+#include <linux/compiler.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/slab.h>
+#include <asm/timex.h>
+#include <asm/system.h>
+
+#define TEST_COUNT 10000
+
+#ifdef CONFIG_SMP
+#include <linux/completion.h>
+#include <linux/sched.h>
+#include <linux/workqueue.h>
+#include <linux/kthread.h>
+
+static struct test_struct {
+	struct task_struct *task;
+	int cpu;
+	int size;
+	int count;
+	void **v;
+	void (*test_p1)(struct test_struct *);
+	void (*test_p2)(struct test_struct *);
+	unsigned long start1;
+	unsigned long stop1;
+	unsigned long start2;
+	unsigned long stop2;
+} test[NR_CPUS];
+
+/*
+ * Allocate TEST_COUNT objects on cpus > 0 and then all the
+ * objects later on cpu 0
+ */
+static void remote_free_test_p1(struct test_struct *t)
+{
+	int i;
+
+	/* Perform no allocations on cpu 0 */
+	for (i = 0; i < t->count; i++) {
+		u8 *p;
+
+		if (smp_processor_id()) {
+			p = kmalloc(t->size, GFP_KERNEL);
+			/* Use object */
+			*p = 17;
+		} else
+			p = NULL;
+		t->v[i] = p;
+	}
+}
+
+static void remote_free_test_p2(struct test_struct *t)
+{
+	int i;
+	int cpu;
+
+	/* All frees are completed on cpu zero */
+	if (smp_processor_id())
+		return;
+
+	for_each_online_cpu(cpu)
+		for (i = 0; i < t->count; i++) {
+			u8 *p = test[cpu].v[i];
+
+			if (!p)
+				continue;
+
+			*p = 16;
+			kfree(p);
+		}
+}
+
+/*
+ * Allocate TEST_COUNT objects on cpu 0 and free them immediately on the
+ * other processors.
+ */
+static void alloc_n_free_test_p1(struct test_struct *t)
+{
+	int i;
+	int cpu;
+	char *p;
+
+	if (smp_processor_id()) {
+		/* Consumer */
+		for (i = 0; i < t->count / num_online_cpus(); i++) {
+			do {
+				p = t->v[i];
+				if (!p)
+					cpu_relax();
+				else
+					*p = 17;
+			} while (!p);
+			kfree(p);
+			t->v[i] = NULL;
+		}
+		return;
+	}
+	/* Producer */
+	for (i = 0; i < t->count; i++) {
+		for_each_online_cpu(cpu) {
+			if (cpu) {
+				p = kmalloc(t->size, GFP_KERNEL);
+				/* Use object */
+				*p = 17;
+				test[cpu].v[i] = p;
+			}
+		}
+	}
+}
+
+/*
+ * Allocate TEST_COUNT objects and later free them all again
+ */
+static void kmalloc_alloc_then_free_test_p1(struct test_struct *t)
+{
+	int i;
+
+	for (i = 0; i < t->count; i++) {
+		u8 *p = kmalloc(t->size, GFP_KERNEL);
+
+		*p = 14;
+		t->v[i] = p;
+	}
+}
+
+static void kmalloc_alloc_then_free_test_p2(struct test_struct *t)
+{
+	int i;
+
+	for (i = 0; i < t->count; i++) {
+		u8 *p = t->v[i];
+
+		*p = 13;
+		kfree(p);
+	}
+}
+
+/*
+ * Allocate TEST_COUNT objects. Free them immediately.
+ */
+static void kmalloc_alloc_free_test_p1(struct test_struct *t)
+{
+	int i;
+
+	for (i = 0; i < TEST_COUNT; i++) {
+		u8 *p = kmalloc(t->size, GFP_KERNEL);
+
+		*p = 12;
+		kfree(p);
+	}
+}
+
+static atomic_t tests_running;
+static atomic_t phase1_complete;
+static DECLARE_COMPLETION(completion1);
+static DECLARE_COMPLETION(completion2);
+static int started;
+
+static int test_func(void *private)
+{
+	struct test_struct *t = private;
+	cpumask_t newmask = CPU_MASK_NONE;
+
+        cpu_set(t->cpu, newmask);
+        set_cpus_allowed(current, newmask);
+	t->v = kzalloc(t->count * sizeof(void *), GFP_KERNEL);
+
+	atomic_inc(&tests_running);
+	wait_for_completion(&completion1);
+	t->start1 = get_cycles();
+	t->test_p1(t);
+	t->stop1 = get_cycles();
+	atomic_inc(&phase1_complete);
+	wait_for_completion(&completion2);
+	t->start2 = get_cycles();
+	if (t->test_p2)
+		t->test_p2(t);
+	t->stop2 = get_cycles();
+	kfree(t->v);
+	atomic_dec(&tests_running);
+	set_current_state(TASK_UNINTERRUPTIBLE);
+	schedule();
+	return 0;
+}
+
+static void do_concurrent_test(void (*p1)(struct test_struct *),
+		void (*p2)(struct test_struct *),
+		int size, const char *name)
+{
+	int cpu;
+	unsigned long time1 = 0;
+	unsigned long time2 = 0;
+	unsigned long sum1 = 0;
+	unsigned long sum2 = 0;
+
+	atomic_set(&tests_running, 0);
+	atomic_set(&phase1_complete, 0);
+	started = 0;
+	init_completion(&completion1);
+	init_completion(&completion2);
+
+	for_each_online_cpu(cpu) {
+		struct test_struct *t = &test[cpu];
+
+		t->cpu = cpu;
+		t->count = TEST_COUNT;
+		t->test_p1 = p1;
+		t->test_p2 = p2;
+		t->size = size;
+		t->task = kthread_run(test_func, t, "test%d", cpu);
+		if (IS_ERR(t->task)) {
+			printk("Failed to start test func\n");
+			return;
+		}
+	}
+
+	/* Wait till all processes are running */
+	while (atomic_read(&tests_running) < num_online_cpus()) {
+		set_current_state(TASK_UNINTERRUPTIBLE);
+		schedule_timeout(10);
+	}
+	complete_all(&completion1);
+
+	/* Wait till all processes have completed phase 1 */
+	while (atomic_read(&phase1_complete) < num_online_cpus()) {
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
+	for_each_online_cpu(cpu)
+		kthread_stop(test[cpu].task);
+
+	printk(KERN_ALERT "%s(%d):", name, size);
+	for_each_online_cpu(cpu) {
+		struct test_struct *t = &test[cpu];
+
+		time1 = t->stop1 - t->start1;
+		time2 = t->stop2 - t->start2;
+		sum1 += time1;
+		sum2 += time2;
+		printk(" %d=%lu", cpu, time1 / TEST_COUNT);
+		if (p2)
+			printk("/%lu", time2 / TEST_COUNT);
+	}
+	printk(" Average=%lu", sum1 / num_online_cpus() / TEST_COUNT);
+	if (p2)
+		printk("/%lu", sum2 / num_online_cpus() / TEST_COUNT);
+	printk("\n");
+	schedule_timeout(200);
+}
+#endif
+
+static int slab_test_init(void)
+{
+	void **v = kmalloc(TEST_COUNT * sizeof(void *), GFP_KERNEL);
+	unsigned int i;
+	cycles_t time1, time2, time;
+	int rem;
+	int size;
+
+	printk(KERN_ALERT "test init\n");
+
+	printk(KERN_ALERT "Single thread testing\n");
+	printk(KERN_ALERT "=====================\n");
+	printk(KERN_ALERT "1. Kmalloc: Repeatedly allocate then free test\n");
+	for (size = 8; size <= PAGE_SIZE << 2; size <<= 1) {
+		time1 = get_cycles();
+		for (i = 0; i < TEST_COUNT; i++) {
+			u8 *p = kmalloc(size, GFP_KERNEL);
+
+			*p = 22;
+			v[i] = p;
+		}
+		time2 = get_cycles();
+		time = time2 - time1;
+
+		printk(KERN_ALERT "%i times kmalloc(%d) ", i, size);
+		time = div_u64_rem(time, TEST_COUNT, &rem);
+		printk("-> %llu cycles ", time);
+
+		time1 = get_cycles();
+		for (i = 0; i < TEST_COUNT; i++) {
+			u8 *p = v[i];
+
+			*p = 23;
+			kfree(p);
+		}
+		time2 = get_cycles();
+		time = time2 - time1;
+
+		printk("kfree ");
+		time = div_u64_rem(time, TEST_COUNT, &rem);
+		printk("-> %llu cycles\n", time);
+	}
+
+	printk(KERN_ALERT "2. Kmalloc: alloc/free test\n");
+	for (size = 8; size <= PAGE_SIZE << 2; size <<= 1) {
+		time1 = get_cycles();
+		for (i = 0; i < TEST_COUNT; i++) {
+			u8 *p = kmalloc(size, GFP_KERNEL);
+
+			kfree(p);
+		}
+		time2 = get_cycles();
+		time = time2 - time1;
+
+		printk(KERN_ALERT "%i times kmalloc(%d)/kfree ", i, size);
+		time = div_u64_rem(time, TEST_COUNT, &rem);
+		printk("-> %llu cycles\n", time);
+	}
+	kfree(v);
+#ifdef CONFIG_SMP
+	printk(KERN_INFO "Concurrent allocs\n");
+	printk(KERN_INFO "=================\n");
+	for (i = 3; i <= PAGE_SHIFT; i++) {
+		do_concurrent_test(kmalloc_alloc_then_free_test_p1,
+			kmalloc_alloc_then_free_test_p2,
+			1 << i, "Kmalloc N*alloc N*free");
+	}
+	for (i = 3; i <= PAGE_SHIFT; i++) {
+		do_concurrent_test(kmalloc_alloc_free_test_p1, NULL,
+			1 << i, "Kmalloc N*(alloc free)");
+	}
+
+	printk(KERN_INFO "Remote free test\n");
+	printk(KERN_INFO "================\n");
+	for (i = 3; i <= PAGE_SHIFT; i++) {
+		do_concurrent_test(remote_free_test_p1,
+				remote_free_test_p2,
+			1 << i, "N*remote free");
+	}
+
+	printk(KERN_INFO "1 alloc N free test\n");
+	printk(KERN_INFO "===================\n");
+	for (i = 3; i <= PAGE_SHIFT; i++) {
+		do_concurrent_test(alloc_n_free_test_p1,
+				NULL,
+			1 << i, "1 alloc N free");
+	}
+
+#endif
+	return -EAGAIN; /* Fail will directly unload the module */
+}
+
+static void slab_test_exit(void)
+{
+	printk(KERN_ALERT "test exit\n");
+}
+
+module_init(slab_test_init)
+module_exit(slab_test_exit)
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Christoph Lameter and Mathieu Desnoyers");
+MODULE_DESCRIPTION("SLAB test");
diff --git a/tests/vmstat_test.c b/tests/vmstat_test.c
new file mode 100644
--- /dev/null
+++ b/tests/vmstat_test.c
@@ -0,0 +1,96 @@
+/* test-vmstat.c
+ *
+ * Test module for in kernel synthetic vm statistics performance.
+ *
+ * execute
+ *
+ * 	modprobe test-vmstat
+ *
+ * to run this test
+ *
+ * (C) 2009 Linux Foundation, Christoph Lameter <cl@linux-foundation.org>
+ */
+
+#include <linux/jiffies.h>
+#include <linux/compiler.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/mm.h>
+#include <asm/timex.h>
+#include <asm/system.h>
+
+#define TEST_COUNT 10000
+
+static int vmstat_test_init(void)
+{
+	unsigned int i;
+	cycles_t time1, time2, time;
+	int rem;
+	struct page *page = alloc_page(GFP_KERNEL);
+
+	printk(KERN_ALERT "VMstat testing\n");
+	printk(KERN_ALERT "=====================\n");
+	printk(KERN_ALERT "1. inc_zone_page_state() then dec_zone_page_state()\n");
+	time1 = get_cycles();
+	for (i = 0; i < TEST_COUNT; i++)
+		inc_zone_page_state(page, NR_BOUNCE);
+
+	time2 = get_cycles();
+	time = time2 - time1;
+
+	printk(KERN_ALERT "%i times inc_zone_page_state() ", i);
+	time = div_u64_rem(time, TEST_COUNT, &rem);
+	printk("-> %llu cycles ", time);
+
+	time1 = get_cycles();
+	for (i = 0; i < TEST_COUNT; i++)
+		__dec_zone_page_state(page, NR_BOUNCE);
+
+	time2 = get_cycles();
+	time = time2 - time1;
+
+	printk("__dec_z_p_s() ");
+	time = div_u64_rem(time, TEST_COUNT, &rem);
+	printk("-> %llu cycles\n", time);
+
+	printk(KERN_ALERT "2. inc_zone_page_state()/dec_zone_page_state()\n");
+	time1 = get_cycles();
+	for (i = 0; i < TEST_COUNT; i++) {
+		inc_zone_page_state(page, NR_BOUNCE);
+		dec_zone_page_state(page, NR_BOUNCE);
+	}
+
+	time2 = get_cycles();
+	time = time2 - time1;
+
+	printk(KERN_ALERT "%i times inc/dec ", i);
+	time = div_u64_rem(time, TEST_COUNT, &rem);
+	printk("-> %llu cycles\n", time);
+
+	printk(KERN_ALERT "3. count_vm_event()\n");
+	time1 = get_cycles();
+	for (i = 0; i < TEST_COUNT; i++)
+		count_vm_event(SLABS_SCANNED);
+
+	time2 = get_cycles();
+	time = time2 - time1;
+
+	count_vm_events(SLABS_SCANNED, -TEST_COUNT);
+	printk(KERN_ALERT "%i count_vm_events ", i);
+	time = div_u64_rem(time, TEST_COUNT, &rem);
+	printk("-> %llu cycles\n", time);
+	__free_page(page);
+	return -EAGAIN; /* Fail will directly unload the module */
+}
+
+static void vmstat_test_exit(void)
+{
+	printk(KERN_ALERT "test exit\n");
+}
+
+module_init(vmstat_test_init)
+module_exit(vmstat_test_exit)
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Christoph Lameter");
+MODULE_DESCRIPTION("VM statistics test");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
