Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id E61B46B000D
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 15:30:12 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id x11-v6so2567568pgp.20
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 12:30:12 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id 30si817802pgr.396.2018.11.02.12.30.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Nov 2018 12:30:11 -0700 (PDT)
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v8 4/4] Kselftest for module text allocation benchmarking
Date: Fri,  2 Nov 2018 12:25:20 -0700
Message-Id: <20181102192520.4522-5-rick.p.edgecombe@intel.com>
In-Reply-To: <20181102192520.4522-1-rick.p.edgecombe@intel.com>
References: <20181102192520.4522-1-rick.p.edgecombe@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jeyu@kernel.org, akpm@linux-foundation.org, willy@infradead.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, daniel@iogearbox.net, jannh@google.com, keescook@chromium.org
Cc: kristen@linux.intel.com, dave.hansen@intel.com, arjan@linux.intel.com, Rick Edgecombe <rick.p.edgecombe@intel.com>

This adds a test module in lib/, and a script in kselftest that does
benchmarking on the allocation of memory in the module space. Performance here
would have some small impact on kernel module insertions, BPF JIT insertions
and kprobes. In the case of KASLR features for the module space, this module
can be used to measure the allocation performance of different configurations.
This module needs to be compiled into the kernel because module_alloc is not
exported.

With some modification to the code, as explained in the comments, it can be
enabled to measure TLB flushes as well.

There are two tests in the module. One allocates until failure in order to
test module capacity and the other times allocating space in the module area.
They both use module sizes that roughly approximate the distribution of in-tree
X86_64 modules.

You can control the number of modules used in the tests like this:
echo m1000>/dev/mod_alloc_test

Run the test for module capacity like:
echo t1>/dev/mod_alloc_test

The other test will measure the allocation time, and for CONFG_X86_64 and
CONFIG_RANDOMIZE_BASE, also give data on how often the a??backup area" is used.

Run the test for allocation time and backup area usage like:
echo t2>/dev/mod_alloc_test
The output will be something like this:
num		all(ns)		last(ns)
1000		1083		1099
Last module in backup count = 0
Total modules in backup     = 0
>1 module in backup count   = 0

To run a suite of allocation time tests for a collection of module numbers you can run:
tools/testing/selftests/bpf/test_mod_alloc.sh

Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 lib/Kconfig.debug                             |   9 +
 lib/Makefile                                  |   1 +
 lib/test_mod_alloc.c                          | 343 ++++++++++++++++++
 tools/testing/selftests/bpf/test_mod_alloc.sh |  29 ++
 4 files changed, 382 insertions(+)
 create mode 100644 lib/test_mod_alloc.c
 create mode 100755 tools/testing/selftests/bpf/test_mod_alloc.sh

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 4966c4fbe7f7..09273ef32be4 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1883,6 +1883,15 @@ config TEST_BPF
 
 	  If unsure, say N.
 
+config TEST_MOD_ALLOC
+	bool "Tests for module allocator/vmalloc"
+	help
+	  This builds the "test_mod_alloc" module that performs performance
+	  tests on the module text section allocator. The module uses X86_64
+	  module text sizes for simulations.
+
+	  If unsure, say N.
+
 config FIND_BIT_BENCHMARK
 	tristate "Test find_bit functions"
 	help
diff --git a/lib/Makefile b/lib/Makefile
index 423876446810..a994240abf65 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -58,6 +58,7 @@ UBSAN_SANITIZE_test_ubsan.o := y
 obj-$(CONFIG_TEST_KSTRTOX) += test-kstrtox.o
 obj-$(CONFIG_TEST_LIST_SORT) += test_list_sort.o
 obj-$(CONFIG_TEST_LKM) += test_module.o
+obj-$(CONFIG_TEST_MOD_ALLOC) += test_mod_alloc.o
 obj-$(CONFIG_TEST_OVERFLOW) += test_overflow.o
 obj-$(CONFIG_TEST_RHASHTABLE) += test_rhashtable.o
 obj-$(CONFIG_TEST_SORT) += test_sort.o
diff --git a/lib/test_mod_alloc.c b/lib/test_mod_alloc.c
new file mode 100644
index 000000000000..afa13c29746f
--- /dev/null
+++ b/lib/test_mod_alloc.c
@@ -0,0 +1,343 @@
+// SPDX-License-Identifier: GPL-2.0
+
+#include <linux/debugfs.h>
+#include <linux/device.h>
+#include <linux/fs.h>
+#include <linux/kernel.h>
+#include <linux/mm.h>
+#include <linux/moduleloader.h>
+#include <linux/random.h>
+#include <linux/uaccess.h>
+#include <linux/vmalloc.h>
+
+struct mod { int filesize; int coresize; int initsize; };
+
+/* ==== Begin optional logging ==== */
+/*
+ * Note: In order to get an accurate count for the tlb flushes triggered in
+ * vmalloc, create a counter in vmalloc.c: with this method signature and export
+ * it. Then replace the below with: __purge_vmap_area_lazy
+ * extern unsigned long get_tlb_flushes_vmalloc(void);
+ */
+static unsigned long get_tlb_flushes_vmalloc(void)
+{
+	return 0;
+}
+
+/* ==== End optional logging ==== */
+
+
+#define MAX_ALLOC_CNT 20000
+#define ITERS 1000
+
+struct vm_alloc {
+	void *core;
+	unsigned long core_size;
+	void *init;
+};
+
+static struct vm_alloc *allocs_vm;
+static long mod_cnt;
+static DEFINE_MUTEX(test_mod_alloc_mutex);
+
+const static int core_hist[10] = {1, 5, 21, 46, 141, 245, 597, 2224, 1875, 0};
+const static int init_hist[10] = {0, 0, 0, 0, 10, 19, 70, 914, 3906, 236};
+const static int file_hist[10] = {6, 20, 55, 86, 286, 551, 918, 2024, 1028,
+					181};
+
+const static int bins[10] = {5000000, 2000000, 1000000, 500000, 200000, 100000,
+				50000, 20000, 10000, 5000};
+/*
+ * Rough approximation of the X86_64 module size distribution.
+ */
+static int get_mod_rand_size(const int *hist)
+{
+	int area_under = get_random_int() % 5155;
+	int i;
+	int last_bin = bins[0] + 1;
+	int sum = 0;
+
+	for (i = 0; i <= 9; i++) {
+		sum += hist[i];
+		if (area_under <= sum)
+			return bins[i]
+				+ (get_random_int() % (last_bin - bins[i]));
+		last_bin = bins[i];
+	}
+	return 4096;
+}
+
+static struct mod get_rand_module(void)
+{
+	struct mod ret;
+
+	ret.coresize = get_mod_rand_size(core_hist);
+	ret.initsize = get_mod_rand_size(init_hist);
+	ret.filesize = get_mod_rand_size(file_hist);
+	return ret;
+}
+
+static void do_test_alloc_fail(void)
+{
+	struct vm_alloc *cur_alloc;
+	struct mod cur_mod;
+	void *file;
+	int mod_n, free_mod_n;
+	unsigned long fail = 0;
+	int iter;
+
+	for (iter = 0; iter < ITERS; iter++) {
+		pr_info("Running iteration: %d\n", iter);
+		memset(allocs_vm, 0, mod_cnt * sizeof(struct vm_alloc));
+		vm_unmap_aliases();
+		for (mod_n = 0; mod_n < mod_cnt; mod_n++) {
+			cur_mod = get_rand_module();
+			cur_alloc = &allocs_vm[mod_n];
+
+			/* Allocate */
+			file = vmalloc(cur_mod.filesize);
+			cur_alloc->core = module_alloc(cur_mod.coresize);
+			cur_alloc->init = module_alloc(cur_mod.initsize);
+
+			/* Clean up everything except core */
+			if (!cur_alloc->core || !cur_alloc->init) {
+				fail++;
+				vfree(file);
+				if (cur_alloc->init) {
+					module_memfree(cur_alloc->init);
+					vm_unmap_aliases();
+				}
+				break;
+			}
+			module_memfree(cur_alloc->init);
+			vm_unmap_aliases();
+			vfree(file);
+		}
+
+		/* Clean up core sizes */
+		for (free_mod_n = 0; free_mod_n < mod_n; free_mod_n++) {
+			cur_alloc = &allocs_vm[free_mod_n];
+			if (cur_alloc->core)
+				module_memfree(cur_alloc->core);
+		}
+	}
+	pr_info("Failures(%ld modules): %lu\n", mod_cnt, fail);
+}
+
+#ifdef CONFIG_RANDOMIZE_FINE_MODULE
+static int is_in_backup(void *addr)
+{
+	return (unsigned long)addr >= MODULES_VADDR + MODULES_RAND_LEN;
+}
+#else
+static int is_in_backup(void *addr)
+{
+	return 0;
+}
+#endif
+
+static void do_test_last_perf(void)
+{
+	struct vm_alloc *cur_alloc;
+	struct mod cur_mod;
+	void *file;
+	int mod_n, mon_n_free;
+	unsigned long fail = 0;
+	int iter;
+	ktime_t start, diff;
+	ktime_t total_last = 0;
+	ktime_t total_all = 0;
+
+	/*
+	 * The number of last core allocations for each iteration that were
+	 * allocated in the backup area.
+	 */
+	int last_in_bk = 0;
+
+	/*
+	 * The total number of core allocations that were in the backup area for
+	 * all iterations.
+	 */
+	int total_in_bk = 0;
+
+	/* The number of iterations where the count was more than 1 */
+	int cnt_more_than_1 = 0;
+
+	/*
+	 * The number of core allocations that were in the backup area for the
+	 * current iteration.
+	 */
+	int cur_in_bk = 0;
+
+	unsigned long before_tlbs;
+	unsigned long tlb_cnt_total;
+	unsigned long tlb_cur;
+	unsigned long total_tlbs = 0;
+
+	pr_info("Starting %d iterations of %ld modules\n", ITERS, mod_cnt);
+
+	for (iter = 0; iter < ITERS; iter++) {
+		vm_unmap_aliases();
+		before_tlbs = get_tlb_flushes_vmalloc();
+		memset(allocs_vm, 0, mod_cnt * sizeof(struct vm_alloc));
+		tlb_cnt_total = 0;
+		cur_in_bk = 0;
+		for (mod_n = 0; mod_n < mod_cnt; mod_n++) {
+			/* allocate how the module allocator allocates */
+
+			cur_mod = get_rand_module();
+			cur_alloc = &allocs_vm[mod_n];
+			file = vmalloc(cur_mod.filesize);
+
+			tlb_cur = get_tlb_flushes_vmalloc();
+
+			start = ktime_get();
+			cur_alloc->core = module_alloc(cur_mod.coresize);
+			diff = ktime_get() - start;
+
+			cur_alloc->init = module_alloc(cur_mod.initsize);
+
+			/* Collect metrics */
+			if (is_in_backup(cur_alloc->core)) {
+				cur_in_bk++;
+				if (mod_n == mod_cnt - 1)
+					last_in_bk++;
+			}
+			total_all += diff;
+
+			if (mod_n == mod_cnt - 1)
+				total_last += diff;
+
+			tlb_cnt_total += get_tlb_flushes_vmalloc() - tlb_cur;
+
+			/* If there is a failure, quit. init/core freed later */
+			if (!cur_alloc->core || !cur_alloc->init) {
+				fail++;
+				vfree(file);
+				break;
+			}
+			/* Init sections do not last long so free here */
+			module_memfree(cur_alloc->init);
+			vm_unmap_aliases();
+			cur_alloc->init = NULL;
+			vfree(file);
+		}
+
+		/* Collect per iteration metrics */
+		total_in_bk += cur_in_bk;
+		if (cur_in_bk > 1)
+			cnt_more_than_1++;
+		total_tlbs += get_tlb_flushes_vmalloc() - before_tlbs;
+
+		/* Collect per iteration metrics */
+		for (mon_n_free = 0; mon_n_free < mod_cnt; mon_n_free++) {
+			cur_alloc = &allocs_vm[mon_n_free];
+			module_memfree(cur_alloc->init);
+			module_memfree(cur_alloc->core);
+		}
+	}
+
+	if (fail)
+		pr_info("There was an alloc failure, results invalid!\n");
+
+	pr_info("num\t\tall(ns)\t\tlast(ns)");
+	pr_info("%ld\t\t%llu\t\t%llu\n", mod_cnt,
+					div64_s64(total_all, ITERS * mod_cnt),
+					div64_s64(total_last, ITERS));
+
+	if (IS_ENABLED(CONFIG_RANDOMIZE_FINE_MODULE)) {
+		pr_info("Last module in backup count = %d\n", last_in_bk);
+		pr_info("Total modules in backup     = %d\n", total_in_bk);
+		pr_info(">1 module in backup count   = %d\n", cnt_more_than_1);
+	}
+	/*
+	 * This will usually hide info when the instrumentation is not in place.
+	 */
+	if (tlb_cnt_total)
+		pr_info("TLB Flushes: %lu\n", tlb_cnt_total);
+}
+
+static void do_test(int test)
+{
+	switch (test) {
+	case 1:
+		do_test_alloc_fail();
+		break;
+	case 2:
+		do_test_last_perf();
+		break;
+	default:
+		pr_info("Unknown test\n");
+	}
+}
+
+static ssize_t device_file_write(struct file *filp, const char __user *user_buf,
+				size_t count, loff_t *offp)
+{
+	char buf[100];
+	long input_num;
+
+	if (count >= sizeof(buf) - 1) {
+		pr_info("Command too long\n");
+		return count;
+	}
+
+	if (!mutex_trylock(&test_mod_alloc_mutex)) {
+		pr_info("test_mod_alloc busy\n");
+		return count;
+	}
+
+	if (copy_from_user(buf, user_buf, count))
+		goto error;
+
+	buf[count] = 0;
+
+	if (kstrtol(buf+1, 10, &input_num))
+		goto error;
+
+	switch (buf[0]) {
+	case 'm':
+		if (input_num > 0 && input_num <= MAX_ALLOC_CNT) {
+			pr_info("New module count: %ld\n", input_num);
+			mod_cnt = input_num;
+			if (allocs_vm)
+				vfree(allocs_vm);
+			allocs_vm = vmalloc(sizeof(struct vm_alloc) * mod_cnt);
+		} else
+			pr_info("more than %d not supported\n", MAX_ALLOC_CNT);
+		break;
+	case 't':
+		if (!mod_cnt) {
+			pr_info("Set module count first\n");
+			break;
+		}
+
+		do_test(input_num);
+		break;
+	default:
+		pr_info("Unknown command\n");
+	}
+	goto done;
+error:
+	pr_info("Could not process input\n");
+done:
+	mutex_unlock(&test_mod_alloc_mutex);
+	return count;
+}
+
+static const char *dv_name = "mod_alloc_test";
+const static struct file_operations test_mod_alloc_fops = {
+	.owner	= THIS_MODULE,
+	.write	= device_file_write,
+};
+
+static int __init mod_alloc_test_init(void)
+{
+	debugfs_create_file(dv_name, 0400, NULL, NULL, &test_mod_alloc_fops);
+
+	return 0;
+}
+
+MODULE_LICENSE("GPL");
+
+module_init(mod_alloc_test_init);
diff --git a/tools/testing/selftests/bpf/test_mod_alloc.sh b/tools/testing/selftests/bpf/test_mod_alloc.sh
new file mode 100755
index 000000000000..e9aea570de78
--- /dev/null
+++ b/tools/testing/selftests/bpf/test_mod_alloc.sh
@@ -0,0 +1,29 @@
+#!/bin/sh
+# SPDX-License-Identifier: GPL-2.0
+UNMOUNT_DEBUG_FS=0
+if ! mount | grep -q debugfs; then
+	if mount -t debugfs none /sys/kernel/debug/; then
+		UNMOUNT_DEBUG_FS=1
+	else
+		echo "Could not mount debug fs."
+		exit 1
+	fi
+fi
+
+if [ ! -e /sys/kernel/debug/mod_alloc_test ]; then
+	echo "Test module not found, did you build kernel with TEST_MOD_ALLOC?"
+	exit 1
+fi
+
+echo "Beginning module_alloc performance tests."
+
+for i in `seq 1000 1000 8000`; do
+	echo m$i>/sys/kernel/debug/mod_alloc_test
+	echo t2>/sys/kernel/debug/mod_alloc_test
+done
+
+echo "Module_alloc performance tests ended."
+
+if [ $UNMOUNT_DEBUG_FS -eq 1 ]; then
+	umount /sys/kernel/debug/
+fi
-- 
2.17.1
