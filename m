Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2BCCB60021B
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 16:18:22 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
References: <200912081016.198135742@firstfloor.org>
In-Reply-To: <200912081016.198135742@firstfloor.org>
Subject: [PATCH] [14/31] HWPOISON: Add unpoisoning support
Message-Id: <20091208211630.68D59B151F@basil.firstfloor.org>
Date: Tue,  8 Dec 2009 22:16:30 +0100 (CET)
Sender: owner-linux-mm@kvack.org
To: fengguang.wu@intel.comfengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


From: Wu Fengguang <fengguang.wu@intel.com>

The unpoisoning interface is useful for stress testing tools to 
reclaim poisoned pages (to prevent OOM)

There is no hardware level unpoisioning, so this
cannot be used for real memory errors, only for software injected errors.

Note that it may leak pages silently - those who have been removed from
LRU cache, but not isolated from page cache/swap cache at hwpoison time.
Especially the stress test of dirty swap cache pages shall reboot system
before exhausting memory.

AK: Fix comments, add documentation, add printks, rename symbol

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 Documentation/vm/hwpoison.txt |   16 ++++++++-
 include/linux/mm.h            |    1 
 include/linux/page-flags.h    |    2 -
 mm/hwpoison-inject.c          |   36 ++++++++++++++++++----
 mm/memory-failure.c           |   68 ++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 114 insertions(+), 9 deletions(-)

Index: linux/mm/hwpoison-inject.c
===================================================================
--- linux.orig/mm/hwpoison-inject.c
+++ linux/mm/hwpoison-inject.c
@@ -4,7 +4,7 @@
 #include <linux/kernel.h>
 #include <linux/mm.h>
 
-static struct dentry *hwpoison_dir, *corrupt_pfn;
+static struct dentry *hwpoison_dir;
 
 static int hwpoison_inject(void *data, u64 val)
 {
@@ -14,7 +14,16 @@ static int hwpoison_inject(void *data, u
 	return __memory_failure(val, 18, 0);
 }
 
+static int hwpoison_unpoison(void *data, u64 val)
+{
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	return unpoison_memory(val);
+}
+
 DEFINE_SIMPLE_ATTRIBUTE(hwpoison_fops, NULL, hwpoison_inject, "%lli\n");
+DEFINE_SIMPLE_ATTRIBUTE(unpoison_fops, NULL, hwpoison_unpoison, "%lli\n");
 
 static void pfn_inject_exit(void)
 {
@@ -24,16 +33,31 @@ static void pfn_inject_exit(void)
 
 static int pfn_inject_init(void)
 {
+	struct dentry *dentry;
+
 	hwpoison_dir = debugfs_create_dir("hwpoison", NULL);
 	if (hwpoison_dir == NULL)
 		return -ENOMEM;
-	corrupt_pfn = debugfs_create_file("corrupt-pfn", 0600, hwpoison_dir,
+
+	/*
+	 * Note that the below poison/unpoison interfaces do not involve
+	 * hardware status change, hence do not require hardware support.
+	 * They are mainly for testing hwpoison in software level.
+	 */
+	dentry = debugfs_create_file("corrupt-pfn", 0600, hwpoison_dir,
 					  NULL, &hwpoison_fops);
-	if (corrupt_pfn == NULL) {
-		pfn_inject_exit();
-		return -ENOMEM;
-	}
+	if (!dentry)
+		goto fail;
+
+	dentry = debugfs_create_file("unpoison-pfn", 0600, hwpoison_dir,
+				     NULL, &unpoison_fops);
+	if (!dentry)
+		goto fail;
+
 	return 0;
+fail:
+	pfn_inject_exit();
+	return -ENOMEM;
 }
 
 module_init(pfn_inject_init);
Index: linux/include/linux/mm.h
===================================================================
--- linux.orig/include/linux/mm.h
+++ linux/include/linux/mm.h
@@ -1321,6 +1321,7 @@ enum mf_flags {
 };
 extern void memory_failure(unsigned long pfn, int trapno);
 extern int __memory_failure(unsigned long pfn, int trapno, int flags);
+extern int unpoison_memory(unsigned long pfn);
 extern int sysctl_memory_failure_early_kill;
 extern int sysctl_memory_failure_recovery;
 extern void shake_page(struct page *p);
Index: linux/mm/memory-failure.c
===================================================================
--- linux.orig/mm/memory-failure.c
+++ linux/mm/memory-failure.c
@@ -840,6 +840,16 @@ int __memory_failure(unsigned long pfn,
 	 * and in many cases impossible, so we just avoid it here.
 	 */
 	lock_page_nosync(p);
+
+	/*
+	 * unpoison always clear PG_hwpoison inside page lock
+	 */
+	if (!PageHWPoison(p)) {
+		action_result(pfn, "unpoisoned", IGNORED);
+		res = 0;
+		goto out;
+	}
+
 	wait_on_page_writeback(p);
 
 	/*
@@ -895,3 +905,61 @@ void memory_failure(unsigned long pfn, i
 {
 	__memory_failure(pfn, trapno, 0);
 }
+
+/**
+ * unpoison_memory - Unpoison a previously poisoned page
+ * @pfn: Page number of the to be unpoisoned page
+ *
+ * Software-unpoison a page that has been poisoned by
+ * memory_failure() earlier.
+ *
+ * This is only done on the software-level, so it only works
+ * for linux injected failures, not real hardware failures
+ *
+ * Returns 0 for success, otherwise -errno.
+ */
+int unpoison_memory(unsigned long pfn)
+{
+	struct page *page;
+	struct page *p;
+	int freeit = 0;
+
+	if (!pfn_valid(pfn))
+		return -ENXIO;
+
+	p = pfn_to_page(pfn);
+	page = compound_head(p);
+
+	if (!PageHWPoison(p)) {
+		pr_debug("MCE: Page was already unpoisoned %#lx\n", pfn);
+		return 0;
+	}
+
+	if (!get_page_unless_zero(page)) {
+		if (TestClearPageHWPoison(p))
+			atomic_long_dec(&mce_bad_pages);
+		pr_debug("MCE: Software-unpoisoned free page %#lx\n", pfn);
+		return 0;
+	}
+
+	lock_page_nosync(page);
+	/*
+	 * This test is racy because PG_hwpoison is set outside of page lock.
+	 * That's acceptable because that won't trigger kernel panic. Instead,
+	 * the PG_hwpoison page will be caught and isolated on the entrance to
+	 * the free buddy page pool.
+	 */
+	if (TestClearPageHWPoison(p)) {
+		pr_debug("MCE: Software-unpoisoned page %#lx\n", pfn);
+		atomic_long_dec(&mce_bad_pages);
+		freeit = 1;
+	}
+	unlock_page(page);
+
+	put_page(page);
+	if (freeit)
+		put_page(page);
+
+	return 0;
+}
+EXPORT_SYMBOL(unpoison_memory);
Index: linux/include/linux/page-flags.h
===================================================================
--- linux.orig/include/linux/page-flags.h
+++ linux/include/linux/page-flags.h
@@ -277,7 +277,7 @@ PAGEFLAG_FALSE(Uncached)
 
 #ifdef CONFIG_MEMORY_FAILURE
 PAGEFLAG(HWPoison, hwpoison)
-TESTSETFLAG(HWPoison, hwpoison)
+TESTSCFLAG(HWPoison, hwpoison)
 #define __PG_HWPOISON (1UL << PG_hwpoison)
 #else
 PAGEFLAG_FALSE(HWPoison)
Index: linux/Documentation/vm/hwpoison.txt
===================================================================
--- linux.orig/Documentation/vm/hwpoison.txt
+++ linux/Documentation/vm/hwpoison.txt
@@ -98,10 +98,22 @@ madvise(MADV_POISON, ....)
 
 
 hwpoison-inject module through debugfs
-	/sys/debug/hwpoison/corrupt-pfn
 
-Inject hwpoison fault at PFN echoed into this file
+/sys/debug/hwpoison/
 
+corrupt-pfn
+
+Inject hwpoison fault at PFN echoed into this file.
+
+unpoison-pfn
+
+Software-unpoison page at PFN echoed into this file. This
+way a page can be reused again.
+This only works for Linux injected failures, not for real
+memory failures.
+
+Note these injection interfaces are not stable and might change between
+kernel versions
 
 Architecture specific MCE injector
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
