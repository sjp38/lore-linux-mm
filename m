Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 02C996B009C
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 05:44:36 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 26/35] Use the per-cpu allocator for orders up to PAGE_ALLOC_COSTLY_ORDER
Date: Mon, 16 Mar 2009 09:46:21 +0000
Message-Id: <1237196790-7268-27-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1237196790-7268-1-git-send-email-mel@csn.ul.ie>
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

The per-cpu allocator is used to store order-0 pages for fast allocation
without using the zone locks. There are a number of cases where order-1
allocations are frequent. Obviously there are 8K stacks, but also the
signal handlers can be sufficiently large as well as some networking-related
structures.

This patch allows orders up to PAGE_ALLOC_COSTLY_ORDER to be stored on the
per-cpu lists which should help workloads making frequent order-1 allocations
such as fork-heavy workloads on x86-64. It is somewhat simplified in that
no splitting occurs of high-order pages on the lists but care is taken to
account for the larger size of those pages so that the same amount of memory
can end up on the per-cpu lists. If a high-order allocation would fail, then
the lists get drained so it is not expected to cause any unusual OOM problems.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/page_alloc.c |  118 +++++++++++++++++++++++++++++++++++++------------------
 1 files changed, 80 insertions(+), 38 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d76f57d..42280c1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -469,6 +469,7 @@ static inline void __free_one_page(struct page *page,
 	VM_BUG_ON(migratetype == -1);
 
 	page_idx = page_to_pfn(page) & ((1 << MAX_ORDER) - 1);
+	page->index = 0;
 
 	VM_BUG_ON(page_idx & ((1 << order) - 1));
 	VM_BUG_ON(bad_range(zone, page));
@@ -510,8 +511,31 @@ static inline int free_pages_check(struct page *page)
 	return 0;
 }
 
+static inline void rmv_pcp_page(struct per_cpu_pages *pcp, struct page *page)
+{
+	list_del(&page->lru);
+	pcp->count -= 1 << page->index;
+}
+
+static inline void add_pcp_page(struct per_cpu_pages *pcp,
+					struct page *page,
+					int cold)
+{
+	if (cold)
+		list_add_tail(&page->lru, &pcp->list);
+	else
+		list_add(&page->lru, &pcp->list);
+	pcp->count += 1 << page->index;
+}
+
+static inline void bulk_add_pcp_page(struct per_cpu_pages *pcp,
+					int order, int count)
+{
+	pcp->count += count << order;
+}
+
 /*
- * Frees a list of pages. 
+ * Frees a number of pages from the PCP lists
  * Assumes all pages on list are in same zone, and of same order.
  * count is the number of pages to free.
  *
@@ -522,23 +546,28 @@ static inline int free_pages_check(struct page *page)
  * pinned" detection logic.
  */
 static void free_pages_bulk(struct zone *zone, int count,
-					struct list_head *list, int order)
+					struct per_cpu_pages *pcp)
 {
+	unsigned int freed = 0;
+	struct list_head *list = &pcp->list;
+
 	spin_lock(&zone->lock);
 	zone_clear_flag(zone, ZONE_ALL_UNRECLAIMABLE);
 	zone->pages_scanned = 0;
 
-	__mod_zone_page_state(zone, NR_FREE_PAGES, count);
-	while (count--) {
+	while (freed < count) {
 		struct page *page;
 
 		VM_BUG_ON(list_empty(list));
 		page = list_entry(list->prev, struct page, lru);
-		/* have to delete it as __free_one_page list manipulates */
-		list_del(&page->lru);
-		__free_one_page(page, zone, order, page_private(page));
+		rmv_pcp_page(pcp, page);
+
+		freed += 1 << page->index;
+		__free_one_page(page, zone, page->index, page_private(page));
 	}
 	spin_unlock(&zone->lock);
+
+	__mod_zone_page_state(zone, NR_FREE_PAGES, freed);
 }
 
 static void free_one_page(struct zone *zone, struct page *page, int order,
@@ -655,6 +684,7 @@ static int prep_new_page(struct page *page, int order, gfp_t gfp_flags)
 		return 1;
 	}
 
+	page->index = 0;
 	set_page_private(page, 0);
 	set_page_refcounted(page);
 
@@ -903,9 +933,10 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 		 */
 		list_add(&page->lru, list);
 		set_page_private(page, migratetype);
+		page->index = order;
 		list = &page->lru;
 	}
-	__mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order) * i);
+	__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
 	spin_unlock(&zone->lock);
 	return i;
 }
@@ -929,8 +960,7 @@ void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp)
 		to_drain = pcp->batch;
 	else
 		to_drain = pcp->count;
-	free_pages_bulk(zone, to_drain, &pcp->list, 0);
-	pcp->count -= to_drain;
+	free_pages_bulk(zone, to_drain, &pcp->list);
 	local_irq_restore(flags);
 }
 #endif
@@ -958,8 +988,8 @@ static void drain_pages(unsigned int cpu)
 
 		pcp = &pset->pcp;
 		local_irq_save(flags);
-		free_pages_bulk(zone, pcp->count, &pcp->list, 0);
-		pcp->count = 0;
+		free_pages_bulk(zone, pcp->count, pcp);
+		BUG_ON(pcp->count);
 		local_irq_restore(flags);
 	}
 }
@@ -1019,13 +1049,18 @@ void mark_free_pages(struct zone *zone)
 /*
  * Free a 0-order page
  */
-static void free_hot_cold_page(struct page *page, int cold)
+static void free_hot_cold_page(struct page *page, int order, int cold)
 {
 	struct zone *zone = page_zone(page);
 	struct per_cpu_pages *pcp;
 	unsigned long flags;
 	int clearMlocked = PageMlocked(page);
 
+	/* SLUB can return lowish-order compound pages that need handling */
+	if (order > 0 && unlikely(PageCompound(page)))
+		if (unlikely(destroy_compound_page(page, order)))
+			return;
+
 	if (PageAnon(page))
 		page->mapping = NULL;
 	if (free_pages_check(page))
@@ -1035,8 +1070,8 @@ static void free_hot_cold_page(struct page *page, int cold)
 		debug_check_no_locks_freed(page_address(page), PAGE_SIZE);
 		debug_check_no_obj_freed(page_address(page), PAGE_SIZE);
 	}
-	arch_free_page(page, 0);
-	kernel_map_pages(page, 1, 0);
+	arch_free_page(page, order);
+	kernel_map_pages(page, 1 << order, 0);
 
 	pcp = &zone_pcp(zone, get_cpu())->pcp;
 	local_irq_save(flags);
@@ -1044,28 +1079,24 @@ static void free_hot_cold_page(struct page *page, int cold)
 	if (clearMlocked)
 		free_page_mlock(page);
 
-	if (cold)
-		list_add_tail(&page->lru, &pcp->list);
-	else
-		list_add(&page->lru, &pcp->list);
 	set_page_private(page, get_pageblock_migratetype(page));
-	pcp->count++;
-	if (pcp->count >= pcp->high) {
-		free_pages_bulk(zone, pcp->batch, &pcp->list, 0);
-		pcp->count -= pcp->batch;
-	}
+	page->index = order;
+	add_pcp_page(pcp, page, cold);
+
+	if (pcp->count >= pcp->high)
+		free_pages_bulk(zone, pcp->batch, pcp);
 	local_irq_restore(flags);
 	put_cpu();
 }
 
 void free_hot_page(struct page *page)
 {
-	free_hot_cold_page(page, 0);
+	free_hot_cold_page(page, 0, 0);
 }
 	
 void free_cold_page(struct page *page)
 {
-	free_hot_cold_page(page, 1);
+	free_hot_cold_page(page, 0, 1);
 }
 
 /*
@@ -1086,6 +1117,11 @@ void split_page(struct page *page, unsigned int order)
 		set_page_refcounted(page + i);
 }
 
+static inline int pcp_page_suit(struct page *page, int migratetype, int order)
+{
+	return page_private(page) == migratetype && page->index == order;
+}
+
 /*
  * Really, prep_compound_page() should be called from __rmqueue_bulk().  But
  * we cheat by calling it from here, in the order > 0 path.  Saves a branch
@@ -1102,14 +1138,18 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 
 again:
 	cpu  = get_cpu();
-	if (likely(order == 0)) {
+	if (likely(order <= PAGE_ALLOC_COSTLY_ORDER)) {
 		struct per_cpu_pages *pcp;
+		int batch;
+		int delta;
 
 		pcp = &zone_pcp(zone, cpu)->pcp;
+		batch = max(1, pcp->batch >> order);
 		local_irq_save(flags);
 		if (!pcp->count) {
-			pcp->count = rmqueue_bulk(zone, 0,
-					pcp->batch, &pcp->list, migratetype);
+			delta = rmqueue_bulk(zone, order, batch,
+					&pcp->list, migratetype);
+			bulk_add_pcp_page(pcp, order, delta);
 			if (unlikely(!pcp->count))
 				goto failed;
 		}
@@ -1117,23 +1157,25 @@ again:
 		/* Find a page of the appropriate migrate type */
 		if (cold) {
 			list_for_each_entry_reverse(page, &pcp->list, lru)
-				if (page_private(page) == migratetype)
+				if (pcp_page_suit(page, migratetype, order))
 					break;
 		} else {
 			list_for_each_entry(page, &pcp->list, lru)
-				if (page_private(page) == migratetype)
+				if (pcp_page_suit(page, migratetype, order))
 					break;
 		}
 
 		/* Allocate more to the pcp list if necessary */
 		if (unlikely(&page->lru == &pcp->list)) {
-			pcp->count += rmqueue_bulk(zone, 0,
-					pcp->batch, &pcp->list, migratetype);
+			delta = rmqueue_bulk(zone, order, batch,
+					&pcp->list, migratetype);
+			bulk_add_pcp_page(pcp, order, delta);
 			page = list_entry(pcp->list.next, struct page, lru);
+			if (!pcp_page_suit(page, migratetype, order))
+				goto failed;
 		}
 
-		list_del(&page->lru);
-		pcp->count--;
+		rmv_pcp_page(pcp, page);
 	} else {
 		LIST_HEAD(list);
 		local_irq_save(flags);
@@ -1884,14 +1926,14 @@ void __pagevec_free(struct pagevec *pvec)
 	int i = pagevec_count(pvec);
 
 	while (--i >= 0)
-		free_hot_cold_page(pvec->pages[i], pvec->cold);
+		free_hot_cold_page(pvec->pages[i], 0, pvec->cold);
 }
 
 void __free_pages(struct page *page, unsigned int order)
 {
 	if (put_page_testzero(page)) {
-		if (order == 0)
-			free_hot_page(page);
+		if (order <= PAGE_ALLOC_COSTLY_ORDER)
+			free_hot_cold_page(page, order, 0);
 		else
 			__free_pages_ok(page, order);
 	}
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
