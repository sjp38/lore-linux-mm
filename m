Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1C90B6B004A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 18:09:24 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH] HWPOISON: Implement hwpoison-on-free for soft offlining
Date: Thu,  7 Oct 2010 00:09:11 +0200
Message-Id: <1286402951-1881-2-git-send-email-andi@firstfloor.org>
In-Reply-To: <1286402951-1881-1-git-send-email-andi@firstfloor.org>
References: <1286402951-1881-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, fengguang.wu@intel.com, Andi Kleen <ak@linux.intel.com>
List-ID: <linux-mm.kvack.org>

From: Andi Kleen <ak@linux.intel.com>

Hard offlining was always able to offline most kernel pages by setting the
HWPoison flag on it and waiting for the next free. This works on all
pages that get eventually freed.

This didn't work for soft offlining unfortunately, because it cannot
safely set the HWPoison flag on a still alive page. Handle this
by introducing a second page flag HWPoisonOnFree that is handled
by page free and enables HWPoison then. This does not add any
overhead to page free because it can be handled as a bad flag
which are already checked for.

Since page flags are scarce on 32bit architectures this is only done on
64bit .

Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 include/linux/mm.h         |    1 +
 include/linux/page-flags.h |   15 +++++++++++++-
 mm/Kconfig                 |    4 +++
 mm/memory-failure.c        |   46 +++++++++++++++++++++++++++++++++++++++++++-
 mm/page_alloc.c            |    2 +
 5 files changed, 66 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 74949fb..f7da94d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1481,6 +1481,7 @@ enum mf_flags {
 extern void memory_failure(unsigned long pfn, int trapno);
 extern int __memory_failure(unsigned long pfn, int trapno, int flags);
 extern int unpoison_memory(unsigned long pfn);
+extern void hwpoison_page_on_free(struct page *p);
 extern int sysctl_memory_failure_early_kill;
 extern int sysctl_memory_failure_recovery;
 extern void shake_page(struct page *p, int access);
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 6fa3178..2d4196b 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -107,6 +107,9 @@ enum pageflags {
 #endif
 #ifdef CONFIG_MEMORY_FAILURE
 	PG_hwpoison,		/* hardware poisoned page. Don't touch */
+#ifdef CONFIG_HWPOISON_ON_FREE
+	PG_hwpoison_on_free,	/* hwpoison on free */
+#endif
 #endif
 	__NR_PAGEFLAGS,
 
@@ -280,6 +283,15 @@ PAGEFLAG_FALSE(HWPoison)
 #define __PG_HWPOISON 0
 #endif
 
+#if defined(CONFIG_MEMORY_FAILURE) && BITS_PER_LONG == 64
+PAGEFLAG(HWPoisonOnFree, hwpoison_on_free)
+TESTSCFLAG(HWPoisonOnFree, hwpoison_on_free)
+#define __PG_HWPOISON_ON_FREE (1UL << PG_hwpoison_on_free)
+#else
+PAGEFLAG_FALSE(HWPoisonOnFree)
+#define __PG_HWPOISON_ON_FREE 0
+#endif
+
 u64 stable_page_flags(struct page *page);
 
 static inline int PageUptodate(struct page *page)
@@ -406,7 +418,8 @@ static inline void __ClearPageTail(struct page *page)
 	 1 << PG_private | 1 << PG_private_2 | \
 	 1 << PG_buddy	 | 1 << PG_writeback | 1 << PG_reserved | \
 	 1 << PG_slab	 | 1 << PG_swapcache | 1 << PG_active | \
-	 1 << PG_unevictable | __PG_MLOCKED | __PG_HWPOISON)
+	 1 << PG_unevictable | __PG_MLOCKED | __PG_HWPOISON | \
+	 __PG_HWPOISON_ON_FREE)
 
 /*
  * Flags checked when a page is prepped for return by the page allocator.
diff --git a/mm/Kconfig b/mm/Kconfig
index f0fb912..ede5444 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -269,6 +269,10 @@ config MEMORY_FAILURE
 	  even when some of its memory has uncorrected errors. This requires
 	  special hardware support and typically ECC memory.
 
+config HWPOISON_ON_FREE
+	depends on MEMORY_FAILURE && 64BIT
+	def_bool y	
+
 config HWPOISON_INJECT
 	tristate "HWPoison pages injector"
 	depends on MEMORY_FAILURE && DEBUG_KERNEL && PROC_FS
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 9c26eec..34901f6 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1268,6 +1268,14 @@ int soft_offline_page(struct page *page, int flags)
 	if (ret == 0)
 		goto done;
 
+#ifdef CONFIG_HWPOISON_ON_FREE
+	/*
+	 * When the page gets freed make sure to poison
+	 * it immediately.
+	 */
+	SetPageHWPoisonOnFree(page);
+#endif
+
 	/*
 	 * Page cache page we can handle?
 	 */
@@ -1279,7 +1287,15 @@ int soft_offline_page(struct page *page, int flags)
 		shake_page(page, 1);
 
 		/*
-		 * Did it turn free?
+		 * Did it get poisoned on free?
+		 */
+		if (PageHWPoison(page)) {
+			pr_info("soft_offline: %#lx: Page freed through shaking\n", pfn);
+			return 0;
+		}
+
+		/* 
+		 * Try to grab it as a free page again.
 		 */
 		ret = get_any_page(page, pfn, 0);
 		if (ret < 0)
@@ -1287,12 +1303,23 @@ int soft_offline_page(struct page *page, int flags)
 		if (ret == 0)
 			goto done;
 	}
+
+	if (PageHWPoisonOnFree(page)) {
+		pr_info("soft_offline: %#lx: Delaying poision of unknown page %lx to free\n",
+			pfn, page->flags);
+		return -EIO; /* or 0? */
+	}
+
 	if (!PageLRU(page)) {
 		pr_debug("soft_offline: %#lx: unknown non LRU page type %lx\n",
 				pfn, page->flags);
 		return -EIO;
 	}
 
+	/* 
+	 * Normal page cache page here.
+	 */
+
 	lock_page(page);
 	wait_on_page_writeback(page);
 
@@ -1389,3 +1416,20 @@ int is_hwpoison_address(unsigned long addr)
 	return is_hwpoison_entry(entry);
 }
 EXPORT_SYMBOL_GPL(is_hwpoison_address);
+
+#ifdef CONFIG_HWPOISON_ON_FREE
+
+/* 
+ * HWPoison a page after freeing. 
+ * This is the fallback path for most pages we cannot free early.
+ */
+void hwpoison_page_on_free(struct page *p)
+{
+	get_page(p);
+	SetPageHWPoison(p);
+	ClearPageHWPoisonOnFree(p);
+	pr_info("MCE: %#lx: Delayed poisioning of page after free\n",
+		page_to_pfn(p));
+	atomic_long_inc(&mce_bad_pages);
+}
+#endif
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a8cfa9c..519c24c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -564,6 +564,8 @@ static inline int free_pages_check(struct page *page)
 		(page->mapping != NULL)  |
 		(atomic_read(&page->_count) != 0) |
 		(page->flags & PAGE_FLAGS_CHECK_AT_FREE))) {
+		if (PageHWPoisonOnFree(page))
+			hwpoison_page_on_free(page);
 		bad_page(page);
 		return 1;
 	}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
