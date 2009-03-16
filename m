Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 571076B008C
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 05:44:34 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 23/35] Update NR_FREE_PAGES only as necessary
Date: Mon, 16 Mar 2009 09:46:18 +0000
Message-Id: <1237196790-7268-24-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1237196790-7268-1-git-send-email-mel@csn.ul.ie>
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

When pages are being freed to the buddy allocator, the zone
NR_FREE_PAGES counter must be updated. In the case of bulk per-cpu page
freeing, it's updated once per page. This retouches cache lines more
than necessary. Update the counters one per per-cpu bulk free.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/page_alloc.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 446cefa..bc491fa 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -460,7 +460,6 @@ static inline void __free_one_page(struct page *page,
 		int migratetype)
 {
 	unsigned long page_idx;
-	int order_size = 1 << order;
 
 	if (unlikely(PageCompound(page)))
 		if (unlikely(destroy_compound_page(page, order)))
@@ -470,10 +469,9 @@ static inline void __free_one_page(struct page *page,
 
 	page_idx = page_to_pfn(page) & ((1 << MAX_ORDER) - 1);
 
-	VM_BUG_ON(page_idx & (order_size - 1));
+	VM_BUG_ON(page_idx & ((1 << order) - 1));
 	VM_BUG_ON(bad_range(zone, page));
 
-	__mod_zone_page_state(zone, NR_FREE_PAGES, order_size);
 	while (order < MAX_ORDER-1) {
 		unsigned long combined_idx;
 		struct page *buddy;
@@ -528,6 +526,8 @@ static void free_pages_bulk(struct zone *zone, int count,
 	spin_lock(&zone->lock);
 	zone_clear_flag(zone, ZONE_ALL_UNRECLAIMABLE);
 	zone->pages_scanned = 0;
+
+	__mod_zone_page_state(zone, NR_FREE_PAGES, count);
 	while (count--) {
 		struct page *page;
 
@@ -546,6 +546,8 @@ static void free_one_page(struct zone *zone, struct page *page, int order,
 	spin_lock(&zone->lock);
 	zone_clear_flag(zone, ZONE_ALL_UNRECLAIMABLE);
 	zone->pages_scanned = 0;
+
+	__mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
 	__free_one_page(page, zone, order, migratetype);
 	spin_unlock(&zone->lock);
 }
@@ -690,7 +692,6 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 		list_del(&page->lru);
 		rmv_page_order(page);
 		area->nr_free--;
-		__mod_zone_page_state(zone, NR_FREE_PAGES, - (1UL << order));
 		expand(zone, page, order, current_order, area, migratetype);
 		return page;
 	}
@@ -830,8 +831,6 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 			/* Remove the page from the freelists */
 			list_del(&page->lru);
 			rmv_page_order(page);
-			__mod_zone_page_state(zone, NR_FREE_PAGES,
-							-(1UL << order));
 
 			if (current_order == pageblock_order)
 				set_pageblock_migratetype(page,
@@ -905,6 +904,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 		set_page_private(page, migratetype);
 		list = &page->lru;
 	}
+	__mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order) * i);
 	spin_unlock(&zone->lock);
 	return i;
 }
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
