Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 7456F6B0078
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:09:02 -0500 (EST)
Received: from int-mx04.intmail.prod.int.phx2.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.17])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o1QK90B5016365
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:09:00 -0500
Message-Id: <20100226200859.012738067@redhat.com>
Date: Fri, 26 Feb 2010 21:04:35 +0100
From: aarcange@redhat.com
Subject: [patch 02/35] compound_lock
References: <20100226200433.516502198@redhat.com>
Content-Disposition: inline; filename=compound_lock
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Add a new compound_lock() needed to serialize put_page against
__split_huge_page_refcount().

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
---
 include/linux/mm.h         |   15 +++++++++++++++
 include/linux/page-flags.h |   12 +++++++++++-
 2 files changed, 26 insertions(+), 1 deletion(-)

--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -12,6 +12,7 @@
 #include <linux/prio_tree.h>
 #include <linux/debug_locks.h>
 #include <linux/mm_types.h>
+#include <linux/bit_spinlock.h>
 
 struct mempolicy;
 struct anon_vma;
@@ -296,6 +297,20 @@ static inline int is_vmalloc_or_module_a
 }
 #endif
 
+static inline void compound_lock(struct page *page)
+{
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	bit_spin_lock(PG_compound_lock, &page->flags);
+#endif
+}
+
+static inline void compound_unlock(struct page *page)
+{
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	bit_spin_unlock(PG_compound_lock, &page->flags);
+#endif
+}
+
 static inline struct page *compound_head(struct page *page)
 {
 	if (unlikely(PageTail(page)))
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -108,6 +108,9 @@ enum pageflags {
 #ifdef CONFIG_MEMORY_FAILURE
 	PG_hwpoison,		/* hardware poisoned page. Don't touch */
 #endif
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	PG_compound_lock,
+#endif
 	__NR_PAGEFLAGS,
 
 	/* Filesystems */
@@ -399,6 +402,12 @@ static inline void __ClearPageTail(struc
 #define __PG_MLOCKED		0
 #endif
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#define __PG_COMPOUND_LOCK		(1 << PG_compound_lock)
+#else
+#define __PG_COMPOUND_LOCK		0
+#endif
+
 /*
  * Flags checked when a page is freed.  Pages being freed should not have
  * these flags set.  It they are, there is a problem.
@@ -408,7 +417,8 @@ static inline void __ClearPageTail(struc
 	 1 << PG_private | 1 << PG_private_2 | \
 	 1 << PG_buddy	 | 1 << PG_writeback | 1 << PG_reserved | \
 	 1 << PG_slab	 | 1 << PG_swapcache | 1 << PG_active | \
-	 1 << PG_unevictable | __PG_MLOCKED | __PG_HWPOISON)
+	 1 << PG_unevictable | __PG_MLOCKED | __PG_HWPOISON | \
+	 __PG_COMPOUND_LOCK)
 
 /*
  * Flags checked when a page is prepped for return by the page allocator.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
