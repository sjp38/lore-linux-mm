Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id AC38C900016
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 11:19:20 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id kq14so12411804pab.3
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 08:19:20 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id yb6si2764103pbc.219.2015.02.12.08.19.05
        for <linux-mm@kvack.org>;
        Thu, 12 Feb 2015 08:19:05 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 20/24] mm, thp: remove compound_lock
Date: Thu, 12 Feb 2015 18:18:34 +0200
Message-Id: <1423757918-197669-21-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We don't need a compound lock anymore: split_huge_page() doesn't need it
anymore.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h         |  35 ------------
 include/linux/page-flags.h |  12 +---
 mm/debug.c                 |   3 -
 mm/swap.c                  | 135 +++++++++++++++------------------------------
 4 files changed, 46 insertions(+), 139 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 655d2bfabdd9..44e1d7f48158 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -398,41 +398,6 @@ static inline int is_vmalloc_or_module_addr(const void *x)
 
 extern void kvfree(const void *addr);
 
-static inline void compound_lock(struct page *page)
-{
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	VM_BUG_ON_PAGE(PageSlab(page), page);
-	bit_spin_lock(PG_compound_lock, &page->flags);
-#endif
-}
-
-static inline void compound_unlock(struct page *page)
-{
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	VM_BUG_ON_PAGE(PageSlab(page), page);
-	bit_spin_unlock(PG_compound_lock, &page->flags);
-#endif
-}
-
-static inline unsigned long compound_lock_irqsave(struct page *page)
-{
-	unsigned long uninitialized_var(flags);
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	local_irq_save(flags);
-	compound_lock(page);
-#endif
-	return flags;
-}
-
-static inline void compound_unlock_irqrestore(struct page *page,
-					      unsigned long flags)
-{
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	compound_unlock(page);
-	local_irq_restore(flags);
-#endif
-}
-
 static inline struct page *compound_head(struct page *page)
 {
 	if (unlikely(PageTail(page)))
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index d471370f27e8..32e893f2fd4d 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -106,9 +106,6 @@ enum pageflags {
 #ifdef CONFIG_MEMORY_FAILURE
 	PG_hwpoison,		/* hardware poisoned page. Don't touch */
 #endif
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	PG_compound_lock,
-#endif
 	__NR_PAGEFLAGS,
 
 	/* Filesystems */
@@ -516,12 +513,6 @@ static inline void ClearPageSlabPfmemalloc(struct page *page)
 #define __PG_MLOCKED		0
 #endif
 
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-#define __PG_COMPOUND_LOCK		(1 << PG_compound_lock)
-#else
-#define __PG_COMPOUND_LOCK		0
-#endif
-
 /*
  * Flags checked when a page is freed.  Pages being freed should not have
  * these flags set.  It they are, there is a problem.
@@ -531,8 +522,7 @@ static inline void ClearPageSlabPfmemalloc(struct page *page)
 	 1 << PG_private | 1 << PG_private_2 | \
 	 1 << PG_writeback | 1 << PG_reserved | \
 	 1 << PG_slab	 | 1 << PG_swapcache | 1 << PG_active | \
-	 1 << PG_unevictable | __PG_MLOCKED | __PG_HWPOISON | \
-	 __PG_COMPOUND_LOCK)
+	 1 << PG_unevictable | __PG_MLOCKED | __PG_HWPOISON)
 
 /*
  * Flags checked when a page is prepped for return by the page allocator.
diff --git a/mm/debug.c b/mm/debug.c
index 13d2b8146ef9..4a82f639b964 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -45,9 +45,6 @@ static const struct trace_print_flags pageflag_names[] = {
 #ifdef CONFIG_MEMORY_FAILURE
 	{1UL << PG_hwpoison,		"hwpoison"	},
 #endif
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	{1UL << PG_compound_lock,	"compound_lock"	},
-#endif
 };
 
 static void dump_flags(unsigned long flags,
diff --git a/mm/swap.c b/mm/swap.c
index 7b4fbb26cc2c..6c9e764f95d7 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -80,16 +80,9 @@ static void __put_compound_page(struct page *page)
 	(*dtor)(page);
 }
 
-static inline bool compound_lock_needed(struct page *page)
-{
-	return IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) &&
-		!PageSlab(page) && !PageHeadHuge(page);
-}
-
 static void put_compound_page(struct page *page)
 {
 	struct page *page_head;
-	unsigned long flags;
 
 	if (likely(!PageTail(page))) {
 		if (put_page_testzero(page)) {
@@ -108,58 +101,33 @@ static void put_compound_page(struct page *page)
 	/* __split_huge_page_refcount can run under us */
 	page_head = compound_head(page);
 
-	if (!compound_lock_needed(page_head)) {
-		/*
-		 * If "page" is a THP tail, we must read the tail page flags
-		 * after the head page flags. The split_huge_page side enforces
-		 * write memory barriers between clearing PageTail and before
-		 * the head page can be freed and reallocated.
-		 */
-		smp_rmb();
-		if (likely(PageTail(page))) {
-			/* __split_huge_page_refcount cannot race here. */
-			VM_BUG_ON_PAGE(!PageHead(page_head), page_head);
-			VM_BUG_ON_PAGE(page_mapcount(page) != 0, page);
-			if (put_page_testzero(page_head)) {
-				/*
-				 * If this is the tail of a slab compound page,
-				 * the tail pin must not be the last reference
-				 * held on the page, because the PG_slab cannot
-				 * be cleared before all tail pins (which skips
-				 * the _mapcount tail refcounting) have been
-				 * released. For hugetlbfs the tail pin may be
-				 * the last reference on the page instead,
-				 * because PageHeadHuge will not go away until
-				 * the compound page enters the buddy
-				 * allocator.
-				 */
-				VM_BUG_ON_PAGE(PageSlab(page_head), page_head);
-				__put_compound_page(page_head);
-			}
-		} else if (put_page_testzero(page))
-			__put_single_page(page);
-		return;
-	}
-
-	flags = compound_lock_irqsave(page_head);
-	/* here __split_huge_page_refcount won't run anymore */
-	if (likely(page != page_head && PageTail(page))) {
-		bool free;
-
-		free = put_page_testzero(page_head);
-		compound_unlock_irqrestore(page_head, flags);
-		if (free) {
-			if (PageHead(page_head))
-				__put_compound_page(page_head);
-			else
-				__put_single_page(page_head);
+	/*
+	 * If "page" is a THP tail, we must read the tail page flags after the
+	 * head page flags. The split_huge_page side enforces write memory
+	 * barriers between clearing PageTail and before the head page can be
+	 * freed and reallocated.
+	 */
+	smp_rmb();
+	if (likely(PageTail(page))) {
+		/* __split_huge_page_refcount cannot race here. */
+		VM_BUG_ON_PAGE(!PageHead(page_head), page_head);
+		if (put_page_testzero(page_head)) {
+			/*
+			 * If this is the tail of a slab compound page, the
+			 * tail pin must not be the last reference held on the
+			 * page, because the PG_slab cannot be cleared before
+			 * all tail pins (which skips the _mapcount tail
+			 * refcounting) have been released. For hugetlbfs the
+			 * tail pin may be the last reference on the page
+			 * instead, because PageHeadHuge will not go away until
+			 * the compound page enters the buddy allocator.
+			 */
+			VM_BUG_ON_PAGE(PageSlab(page_head), page_head);
+			__put_compound_page(page_head);
 		}
-	} else {
-		compound_unlock_irqrestore(page_head, flags);
-		VM_BUG_ON_PAGE(PageTail(page), page);
-		if (put_page_testzero(page))
-			__put_single_page(page);
-	}
+	} else if (put_page_testzero(page))
+		__put_single_page(page);
+	return;
 }
 
 void put_page(struct page *page)
@@ -178,42 +146,29 @@ EXPORT_SYMBOL(put_page);
 void __get_page_tail(struct page *page)
 {
 	struct page *page_head = compound_head(page);
-	unsigned long flags;
 
-	if (!compound_lock_needed(page_head)) {
-		smp_rmb();
-		if (likely(PageTail(page))) {
-			/*
-			 * This is a hugetlbfs page or a slab page.
-			 * __split_huge_page_refcount cannot race here.
-			 */
-			VM_BUG_ON_PAGE(!PageHead(page_head), page_head);
-			VM_BUG_ON(page_head != page->first_page);
-			VM_BUG_ON_PAGE(atomic_read(&page_head->_count) <= 0,
-					page);
-			atomic_inc(&page_head->_count);
-		} else {
-			/*
-			 * __split_huge_page_refcount run before us, "page" was
-			 * a thp tail. the split page_head has been freed and
-			 * reallocated as slab or hugetlbfs page of smaller
-			 * order (only possible if reallocated as slab on x86).
-			 */
-			VM_BUG_ON_PAGE(atomic_read(&page->_count) <= 0, page);
-			atomic_inc(&page->_count);
-		}
-		return;
-	}
-
-	flags = compound_lock_irqsave(page_head);
-	/* here __split_huge_page_refcount won't run anymore */
-	if (unlikely(page == page_head || !PageTail(page) ||
-				!get_page_unless_zero(page_head))) {
-		/* page is not part of THP page anymore */
+	smp_rmb();
+	if (likely(PageTail(page))) {
+		/*
+		 * This is a hugetlbfs page or a slab page.
+		 * __split_huge_page_refcount cannot race here.
+		 */
+		VM_BUG_ON_PAGE(!PageHead(page_head), page_head);
+		VM_BUG_ON(page_head != page->first_page);
+		VM_BUG_ON_PAGE(atomic_read(&page_head->_count) <= 0,
+				page);
+		atomic_inc(&page_head->_count);
+	} else {
+		/*
+		 * __split_huge_page_refcount run before us, "page" was
+		 * a thp tail. the split page_head has been freed and
+		 * reallocated as slab or hugetlbfs page of smaller
+		 * order (only possible if reallocated as slab on x86).
+		 */
 		VM_BUG_ON_PAGE(atomic_read(&page->_count) <= 0, page);
 		atomic_inc(&page->_count);
 	}
-	compound_unlock_irqrestore(page_head, flags);
+	return;
 }
 EXPORT_SYMBOL(__get_page_tail);
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
