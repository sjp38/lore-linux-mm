Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id DE337600762
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 16:16:22 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
References: <200912081016.198135742@firstfloor.org>
In-Reply-To: <200912081016.198135742@firstfloor.org>
Subject: [PATCH] [2/31] HWPOISON: Be more aggressive at freeing non LRU caches
Message-Id: <20091208211618.48603B151F@basil.firstfloor.org>
Date: Tue,  8 Dec 2009 22:16:18 +0100 (CET)
Sender: owner-linux-mm@kvack.org
To: fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


shake_page handles more types of page caches than lru_drain_all()

- per cpu page allocator pages
- per CPU LRU

Stops early when the page became free.

Used in followon patches.

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 include/linux/mm.h  |    1 +
 mm/memory-failure.c |   22 ++++++++++++++++++++++
 2 files changed, 23 insertions(+)

Index: linux/mm/memory-failure.c
===================================================================
--- linux.orig/mm/memory-failure.c
+++ linux/mm/memory-failure.c
@@ -83,6 +83,28 @@ static int kill_proc_ao(struct task_stru
 }
 
 /*
+ * When a unknown page type is encountered drain as many buffers as possible
+ * in the hope to turn the page into a LRU or free page, which we can handle.
+ */
+void shake_page(struct page *p)
+{
+	if (!PageSlab(p)) {
+		lru_add_drain_all();
+		if (PageLRU(p))
+			return;
+		drain_all_pages();
+		if (PageLRU(p) || is_free_buddy_page(p))
+			return;
+	}
+	/*
+	 * Could call shrink_slab here (which would also
+	 * shrink other caches). Unfortunately that might
+	 * also access the corrupted page, which could be fatal.
+	 */
+}
+EXPORT_SYMBOL_GPL(shake_page);
+
+/*
  * Kill all processes that have a poisoned page mapped and then isolate
  * the page.
  *
Index: linux/include/linux/mm.h
===================================================================
--- linux.orig/include/linux/mm.h
+++ linux/include/linux/mm.h
@@ -1320,6 +1320,7 @@ extern void memory_failure(unsigned long
 extern int __memory_failure(unsigned long pfn, int trapno, int ref);
 extern int sysctl_memory_failure_early_kill;
 extern int sysctl_memory_failure_recovery;
+extern void shake_page(struct page *p);
 extern atomic_long_t mce_bad_pages;
 
 #endif /* __KERNEL__ */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
