Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B9F916B0096
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 07:17:24 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 19/19] Split per-cpu list into one-list-per-migrate-type
Date: Tue, 24 Feb 2009 12:17:15 +0000
Message-Id: <1235477835-14500-20-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1235477835-14500-1-git-send-email-mel@csn.ul.ie>
References: <1235477835-14500-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

Currently the per-cpu page allocator searches the PCP list for pages of the
correct migrate-type to reduce the possibility of pages being inappropriate
placed from a fragmentation perspective. This search is potentially expensive
in a fast-path and undesirable. Splitting the per-cpu list into multiple
lists increases the size of a per-cpu structure and this was potentially
a major problem at the time the search was introduced. These problem has
been mitigated as now only the necessary number of structures is allocated
for the running system.

This patch replaces a list search in the per-cpu allocator with one list
per migrate type.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/mmzone.h |    5 ++-
 mm/page_alloc.c        |   80 +++++++++++++++++++++++++++++------------------
 2 files changed, 53 insertions(+), 32 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 6089393..2a7349a 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -38,6 +38,7 @@
 #define MIGRATE_UNMOVABLE     0
 #define MIGRATE_RECLAIMABLE   1
 #define MIGRATE_MOVABLE       2
+#define MIGRATE_PCPTYPES      3 /* the number of types on the pcp lists */
 #define MIGRATE_RESERVE       3
 #define MIGRATE_ISOLATE       4 /* can't allocate from here */
 #define MIGRATE_TYPES         5
@@ -167,7 +168,9 @@ struct per_cpu_pages {
 	int count;		/* number of pages in the list */
 	int high;		/* high watermark, emptying needed */
 	int batch;		/* chunk size for buddy add/remove */
-	struct list_head list;	/* the list of pages */
+
+	/* Lists of pages, one per migrate type stored on the pcp-lists */
+	struct list_head lists[MIGRATE_TYPES];
 };
 
 struct per_cpu_pageset {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8a8db71..c77ca1b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -514,7 +514,7 @@ static inline int free_pages_check(struct page *page)
 }
 
 /*
- * Frees a list of pages. 
+ * Frees a number of pages from the PCP lists
  * Assumes all pages on list are in same zone, and of same order.
  * count is the number of pages to free.
  *
@@ -524,20 +524,30 @@ static inline int free_pages_check(struct page *page)
  * And clear the zone's pages_scanned counter, to hold off the "all pages are
  * pinned" detection logic.
  */
-static void free_pages_bulk(struct zone *zone, int count,
-					struct list_head *list, int order)
+static void free_pcppages_bulk(struct zone *zone, int count,
+					 struct per_cpu_pages *pcp)
 {
+	int migratetype = 0;
+
 	spin_lock(&zone->lock);
 	zone_clear_flag(zone, ZONE_ALL_UNRECLAIMABLE);
 	zone->pages_scanned = 0;
 	while (count--) {
 		struct page *page;
-
-		VM_BUG_ON(list_empty(list));
+		struct list_head *list;
+
+		/* Remove pages from lists in a round-robin fashion */
+		do {
+			if (migratetype == MIGRATE_PCPTYPES)
+				migratetype = 0;
+			list = &pcp->lists[migratetype];
+			migratetype++;
+		} while (list_empty(list));
+		
 		page = list_entry(list->prev, struct page, lru);
 		/* have to delete it as __free_one_page list manipulates */
 		list_del(&page->lru);
-		__free_one_page(page, zone, order, page_private(page));
+		__free_one_page(page, zone, 0, page_private(page));
 	}
 	spin_unlock(&zone->lock);
 }
@@ -930,7 +940,7 @@ void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp)
 		to_drain = pcp->batch;
 	else
 		to_drain = pcp->count;
-	free_pages_bulk(zone, to_drain, &pcp->list, 0);
+	free_pcppages_bulk(zone, to_drain, pcp);
 	pcp->count -= to_drain;
 	local_irq_restore(flags);
 }
@@ -959,7 +969,7 @@ static void drain_pages(unsigned int cpu)
 
 		pcp = &pset->pcp;
 		local_irq_save(flags);
-		free_pages_bulk(zone, pcp->count, &pcp->list, 0);
+		free_pcppages_bulk(zone, pcp->count, pcp);
 		pcp->count = 0;
 		local_irq_restore(flags);
 	}
@@ -1025,6 +1035,7 @@ static void free_hot_cold_page(struct page *page, int cold)
 	struct zone *zone = page_zone(page);
 	struct per_cpu_pages *pcp;
 	unsigned long flags;
+	int migratetype;
 	int clearMlocked = PageMlocked(page);
 
 	if (PageAnon(page))
@@ -1045,16 +1056,31 @@ static void free_hot_cold_page(struct page *page, int cold)
 	if (clearMlocked)
 		free_page_mlock(page);
 
+	/*
+	 * Only store unreclaimable, reclaimable and movable on pcp lists.
+	 * The one concern is that if the minimum number of free pages is not
+	 * aligned to a pageblock-boundary that allocations/frees from the
+	 * MIGRATE_RESERVE pageblocks may call free_one_page() excessively
+	 */
+	migratetype = get_pageblock_migratetype(page);
+	if (migratetype >= MIGRATE_PCPTYPES) {
+		free_one_page(zone, page, 0, migratetype);
+		goto out;
+	}
+
+	/* Record the migratetype and place on the lists */
+	set_page_private(page, migratetype);
 	if (cold)
-		list_add_tail(&page->lru, &pcp->list);
+		list_add_tail(&page->lru, &pcp->lists[migratetype]);
 	else
-		list_add(&page->lru, &pcp->list);
-	set_page_private(page, get_pageblock_migratetype(page));
+		list_add(&page->lru, &pcp->lists[migratetype]);
+
 	pcp->count++;
 	if (pcp->count >= pcp->high) {
-		free_pages_bulk(zone, pcp->batch, &pcp->list, 0);
+		free_pcppages_bulk(zone, pcp->batch, pcp);
 		pcp->count -= pcp->batch;
 	}
+out:
 	local_irq_restore(flags);
 	put_cpu();
 }
@@ -1109,29 +1135,19 @@ again:
 
 		pcp = &zone_pcp(zone, cpu)->pcp;
 		local_irq_save(flags);
-		if (!pcp->count) {
-			pcp->count = rmqueue_bulk(zone, 0,
-					pcp->batch, &pcp->list, migratetype);
-			if (unlikely(!pcp->count))
+		if (list_empty(&pcp->lists[migratetype])) {
+			pcp->count += rmqueue_bulk(zone, 0, pcp->batch,
+				&pcp->lists[migratetype], migratetype);
+			if (unlikely(list_empty(&pcp->lists[migratetype])))
 				goto failed;
 		}
 
-		/* Find a page of the appropriate migrate type */
 		if (cold) {
-			list_for_each_entry_reverse(page, &pcp->list, lru)
-				if (page_private(page) == migratetype)
-					break;
+			page = list_entry(pcp->lists[migratetype].prev,
+							struct page, lru);
 		} else {
-			list_for_each_entry(page, &pcp->list, lru)
-				if (page_private(page) == migratetype)
-					break;
-		}
-
-		/* Allocate more to the pcp list if necessary */
-		if (unlikely(&page->lru == &pcp->list)) {
-			pcp->count += rmqueue_bulk(zone, 0,
-					pcp->batch, &pcp->list, migratetype);
-			page = list_entry(pcp->list.next, struct page, lru);
+			page = list_entry(pcp->lists[migratetype].next,
+							struct page, lru);
 		}
 
 		list_del(&page->lru);
@@ -2889,6 +2905,7 @@ static int zone_batchsize(struct zone *zone)
 static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch)
 {
 	struct per_cpu_pages *pcp;
+	int migratetype;
 
 	memset(p, 0, sizeof(*p));
 
@@ -2896,7 +2913,8 @@ static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch)
 	pcp->count = 0;
 	pcp->high = 6 * batch;
 	pcp->batch = max(1UL, 1 * batch);
-	INIT_LIST_HEAD(&pcp->list);
+	for (migratetype = 0; migratetype < MIGRATE_TYPES; migratetype++)
+		INIT_LIST_HEAD(&pcp->lists[migratetype]);
 }
 
 /*
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
