Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1EBD16B006A
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 05:44:38 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 28/35] Batch free pages from migratetype per-cpu lists
Date: Mon, 16 Mar 2009 09:46:23 +0000
Message-Id: <1237196790-7268-29-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1237196790-7268-1-git-send-email-mel@csn.ul.ie>
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

When the PCP lists are too large, a number of pages are freed in bulk.
Currently the free lists are examined in a round-robin fashion but this
touches more cache lines than necessary. This patch frees pages from one
list at a time and uses the migratetype most recently used as the
starting point.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/page_alloc.c |   36 +++++++++++++++++++++++-------------
 1 files changed, 23 insertions(+), 13 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3516b87..edadab1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -547,32 +547,42 @@ static inline void bulk_add_pcp_page(struct per_cpu_pages *pcp,
  * pinned" detection logic.
  */
 static void free_pcppages_bulk(struct zone *zone, int count,
-					struct per_cpu_pages *pcp)
+					struct per_cpu_pages *pcp,
+					int migratetype)
 {
-	int migratetype = 0;
 	unsigned int freed = 0;
+	unsigned int bulkcount;
+	struct list_head *list;
 
 	spin_lock(&zone->lock);
 	zone_clear_flag(zone, ZONE_ALL_UNRECLAIMABLE);
 	zone->pages_scanned = 0;
 
+	list = &pcp->lists[migratetype];
+	bulkcount = 1 + (count / (MIGRATE_PCPTYPES * 2));
 	while (freed < count) {
 		struct page *page;
-		struct list_head *list;
+		int thisfreed;
 
-		/* Remove pages from lists in a round-robin fashion */
-		do {
-			if (migratetype == MIGRATE_PCPTYPES)
+		/*
+		 * Move to another migratetype if this list is depleted or
+		 * we've freed enough in this batch
+		 */
+		while (list_empty(list) || bulkcount < 0) {
+			bulkcount = 1 + (count / (MIGRATE_PCPTYPES * 2));
+			if (++migratetype == MIGRATE_PCPTYPES)
 				migratetype = 0;
 			list = &pcp->lists[migratetype];
-			migratetype++;
-		} while (list_empty(list));
+		}
 
+		/* Remove from list and update counters */
 		page = list_entry(list->prev, struct page, lru);
 		rmv_pcp_page(pcp, page);
+		thisfreed = 1 << page->index;
+		freed += thisfreed;
+		bulkcount -= thisfreed;
 
-		freed += 1 << page->index;
-		__free_one_page(page, zone, page->index, page_private(page));
+		__free_one_page(page, zone, page->index, migratetype);
 	}
 	spin_unlock(&zone->lock);
 
@@ -969,7 +979,7 @@ void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp)
 		to_drain = pcp->batch;
 	else
 		to_drain = pcp->count;
-	free_pcppages_bulk(zone, to_drain, pcp);
+	free_pcppages_bulk(zone, to_drain, pcp, 0);
 	local_irq_restore(flags);
 }
 #endif
@@ -997,7 +1007,7 @@ static void drain_pages(unsigned int cpu)
 
 		pcp = &pset->pcp;
 		local_irq_save(flags);
-		free_pcppages_bulk(zone, pcp->count, pcp);
+		free_pcppages_bulk(zone, pcp->count, pcp, 0);
 		BUG_ON(pcp->count);
 		local_irq_restore(flags);
 	}
@@ -1110,7 +1120,7 @@ static void free_hot_cold_page(struct page *page, int order, int cold)
 	page->index = order;
 	add_pcp_page(pcp, page, cold);
 	if (pcp->count >= pcp->high)
-		free_pcppages_bulk(zone, pcp->batch, pcp);
+		free_pcppages_bulk(zone, pcp->batch, pcp, migratetype);
 
 out:
 	local_irq_restore(flags);
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
