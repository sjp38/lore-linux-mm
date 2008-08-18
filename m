Date: Mon, 18 Aug 2008 14:29:57 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] mm: page allocator minor speedup
Message-ID: <20080818122957.GE9062@wotan.suse.de>
References: <20080818122428.GA9062@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080818122428.GA9062@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Now that we don't put a ZERO_PAGE in the pagetables any more, and the
"remove PageReserved from core mm" patch has had a long time to mature,
let's remove the page reserved logic from the allocator.

This saves several branches and about 100 bytes in some important paths.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -449,7 +449,7 @@ static inline void __free_one_page(struc
 	zone->free_area[order].nr_free++;
 }
 
-static inline int free_pages_check(struct page *page)
+static inline void free_pages_check(struct page *page)
 {
 	if (unlikely(page_mapcount(page) |
 		(page->mapping != NULL)  |
@@ -459,12 +459,6 @@ static inline int free_pages_check(struc
 		bad_page(page);
 	if (PageDirty(page))
 		__ClearPageDirty(page);
-	/*
-	 * For now, we report if PG_reserved was found set, but do not
-	 * clear it, and do not free the page.  But we shall soon need
-	 * to do more, for when the ZERO_PAGE count wraps negative.
-	 */
-	return PageReserved(page);
 }
 
 /*
@@ -509,12 +503,9 @@ static void __free_pages_ok(struct page 
 {
 	unsigned long flags;
 	int i;
-	int reserved = 0;
 
 	for (i = 0 ; i < (1 << order) ; ++i)
-		reserved += free_pages_check(page + i);
-	if (reserved)
-		return;
+		free_pages_check(page + i);
 
 	if (!PageHighMem(page)) {
 		debug_check_no_locks_freed(page_address(page),PAGE_SIZE<<order);
@@ -593,7 +584,7 @@ static inline void expand(struct zone *z
 /*
  * This page is about to be returned from the page allocator
  */
-static int prep_new_page(struct page *page, int order, gfp_t gfp_flags)
+static void prep_new_page(struct page *page, int order, gfp_t gfp_flags)
 {
 	if (unlikely(page_mapcount(page) |
 		(page->mapping != NULL)  |
@@ -602,13 +593,6 @@ static int prep_new_page(struct page *pa
 		(page->flags & PAGE_FLAGS_CHECK_AT_PREP)))
 		bad_page(page);
 
-	/*
-	 * For now, we report if PG_reserved was found set, but do not
-	 * clear it, and do not allocate the page: as a safety net.
-	 */
-	if (PageReserved(page))
-		return 1;
-
 	page->flags &= ~(1 << PG_uptodate | 1 << PG_error | 1 << PG_reclaim |
 			1 << PG_referenced | 1 << PG_arch_1 |
 			1 << PG_owner_priv_1 | 1 << PG_mappedtodisk);
@@ -623,8 +607,6 @@ static int prep_new_page(struct page *pa
 
 	if (order && (gfp_flags & __GFP_COMP))
 		prep_compound_page(page, order);
-
-	return 0;
 }
 
 /*
@@ -970,8 +952,7 @@ static void free_hot_cold_page(struct pa
 
 	if (PageAnon(page))
 		page->mapping = NULL;
-	if (free_pages_check(page))
-		return;
+	free_pages_check(page);
 
 	if (!PageHighMem(page)) {
 		debug_check_no_locks_freed(page_address(page), PAGE_SIZE);
@@ -1039,7 +1020,6 @@ static struct page *buffered_rmqueue(str
 	int cpu;
 	int migratetype = allocflags_to_migratetype(gfp_flags);
 
-again:
 	cpu  = get_cpu();
 	if (likely(order == 0)) {
 		struct per_cpu_pages *pcp;
@@ -1087,8 +1067,7 @@ again:
 	put_cpu();
 
 	VM_BUG_ON(bad_range(zone, page));
-	if (prep_new_page(page, order, gfp_flags))
-		goto again;
+	prep_new_page(page, order, gfp_flags);
 	return page;
 
 failed:
Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h
+++ linux-2.6/include/linux/page-flags.h
@@ -330,7 +330,8 @@ static inline void __ClearPageTail(struc
 
 #define PAGE_FLAGS	(1 << PG_lru | 1 << PG_private | 1 << PG_locked | \
 			 1 << PG_waiters | 1 << PG_buddy | 1 << PG_writeback | \
-			 1 << PG_slab | 1 << PG_swapcache | 1 << PG_active)
+			 1 << PG_slab | 1 << PG_swapcache | 1 << PG_active | \
+			 1 << PG_reserved)
 
 /*
  * Flags checked in bad_page().  Pages on the free list should not have
@@ -342,14 +343,14 @@ static inline void __ClearPageTail(struc
  * Flags checked when a page is freed.  Pages being freed should not have
  * these flags set.  It they are, there is a problem.
  */
-#define PAGE_FLAGS_CHECK_AT_FREE (PAGE_FLAGS | 1 << PG_reserved)
+#define PAGE_FLAGS_CHECK_AT_FREE (PAGE_FLAGS)
 
 /*
  * Flags checked when a page is prepped for return by the page allocator.
  * Pages being prepped should not have these flags set.  It they are, there
  * is a problem.
  */
-#define PAGE_FLAGS_CHECK_AT_PREP (PAGE_FLAGS | 1 << PG_reserved | 1 << PG_dirty)
+#define PAGE_FLAGS_CHECK_AT_PREP (PAGE_FLAGS | 1 << PG_dirty)
 
 #endif /* !__GENERATING_BOUNDS_H */
 #endif	/* PAGE_FLAGS_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
