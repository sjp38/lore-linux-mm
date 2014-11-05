Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 8D9A06B00A2
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 09:50:32 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id g10so872435pdj.38
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 06:50:32 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id qd3si3316359pac.23.2014.11.05.06.50.19
        for <linux-mm@kvack.org>;
        Wed, 05 Nov 2014 06:50:20 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 19/19] mm, thp: remove compound_lock
Date: Wed,  5 Nov 2014 16:49:54 +0200
Message-Id: <1415198994-15252-20-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We don't need a compound lock anymore: split_huge_page() doesn't need it
anymore.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h         |  35 ------------
 include/linux/page-flags.h |  12 +---
 mm/page_alloc.c            |   3 -
 mm/swap.c                  | 135 +++++++++++++++------------------------------
 4 files changed, 46 insertions(+), 139 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index f2f95469f1c3..61f745f1fb2e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -378,41 +378,6 @@ static inline int is_vmalloc_or_module_addr(const void *x)
 
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
index 676f72d29ac2..46ebd9c05a59 100644
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
@@ -511,12 +508,6 @@ static inline void ClearPageSlabPfmemalloc(struct page *page)
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
@@ -526,8 +517,7 @@ static inline void ClearPageSlabPfmemalloc(struct page *page)
 	 1 << PG_private | 1 << PG_private_2 | \
 	 1 << PG_writeback | 1 << PG_reserved | \
 	 1 << PG_slab	 | 1 << PG_swapcache | 1 << PG_active | \
-	 1 << PG_unevictable | __PG_MLOCKED | __PG_HWPOISON | \
-	 __PG_COMPOUND_LOCK)
+	 1 << PG_unevictable | __PG_MLOCKED | __PG_HWPOISON)
 
 /*
  * Flags checked when a page is prepped for return by the page allocator.
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b19d1e69ca12..cf3096f97c6d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6598,9 +6598,6 @@ static const struct trace_print_flags pageflag_names[] = {
 #ifdef CONFIG_MEMORY_FAILURE
 	{1UL << PG_hwpoison,		"hwpoison"	},
 #endif
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	{1UL << PG_compound_lock,	"compound_lock"	},
-#endif
 };
 
 static void dump_page_flags(unsigned long flags)
diff --git a/mm/swap.c b/mm/swap.c
index da28e0767088..537592dfc6c4 100644
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
2.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
