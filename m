Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id A7A8F6B0088
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 05:44:37 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 27/35] Split per-cpu list into one-list-per-migrate-type
Date: Mon, 16 Mar 2009 09:46:22 +0000
Message-Id: <1237196790-7268-28-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1237196790-7268-1-git-send-email-mel@csn.ul.ie>
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie>
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
per migrate type. It is still searched but for a page of the correct
order which is expected to be a lot less costly.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/mmzone.h |    5 ++-
 mm/page_alloc.c        |   82 +++++++++++++++++++++++++++++++++--------------
 2 files changed, 61 insertions(+), 26 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index c20c662..eed6867 100644
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
+	struct list_head lists[MIGRATE_PCPTYPES];
 };
 
 struct per_cpu_pageset {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 42280c1..3516b87 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -521,10 +521,11 @@ static inline void add_pcp_page(struct per_cpu_pages *pcp,
 					struct page *page,
 					int cold)
 {
+	int migratetype = page_private(page);
 	if (cold)
-		list_add_tail(&page->lru, &pcp->list);
+		list_add_tail(&page->lru, &pcp->lists[migratetype]);
 	else
-		list_add(&page->lru, &pcp->list);
+		list_add(&page->lru, &pcp->lists[migratetype]);
 	pcp->count += 1 << page->index;
 }
 
@@ -545,11 +546,11 @@ static inline void bulk_add_pcp_page(struct per_cpu_pages *pcp,
  * And clear the zone's pages_scanned counter, to hold off the "all pages are
  * pinned" detection logic.
  */
-static void free_pages_bulk(struct zone *zone, int count,
+static void free_pcppages_bulk(struct zone *zone, int count,
 					struct per_cpu_pages *pcp)
 {
+	int migratetype = 0;
 	unsigned int freed = 0;
-	struct list_head *list = &pcp->list;
 
 	spin_lock(&zone->lock);
 	zone_clear_flag(zone, ZONE_ALL_UNRECLAIMABLE);
@@ -557,8 +558,16 @@ static void free_pages_bulk(struct zone *zone, int count,
 
 	while (freed < count) {
 		struct page *page;
+		struct list_head *list;
+
+		/* Remove pages from lists in a round-robin fashion */
+		do {
+			if (migratetype == MIGRATE_PCPTYPES)
+				migratetype = 0;
+			list = &pcp->lists[migratetype];
+			migratetype++;
+		} while (list_empty(list));
 
-		VM_BUG_ON(list_empty(list));
 		page = list_entry(list->prev, struct page, lru);
 		rmv_pcp_page(pcp, page);
 
@@ -960,7 +969,7 @@ void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp)
 		to_drain = pcp->batch;
 	else
 		to_drain = pcp->count;
-	free_pages_bulk(zone, to_drain, &pcp->list);
+	free_pcppages_bulk(zone, to_drain, pcp);
 	local_irq_restore(flags);
 }
 #endif
@@ -988,7 +997,7 @@ static void drain_pages(unsigned int cpu)
 
 		pcp = &pset->pcp;
 		local_irq_save(flags);
-		free_pages_bulk(zone, pcp->count, pcp);
+		free_pcppages_bulk(zone, pcp->count, pcp);
 		BUG_ON(pcp->count);
 		local_irq_restore(flags);
 	}
@@ -1054,6 +1063,7 @@ static void free_hot_cold_page(struct page *page, int order, int cold)
 	struct zone *zone = page_zone(page);
 	struct per_cpu_pages *pcp;
 	unsigned long flags;
+	int migratetype;
 	int clearMlocked = PageMlocked(page);
 
 	/* SLUB can return lowish-order compound pages that need handling */
@@ -1073,18 +1083,36 @@ static void free_hot_cold_page(struct page *page, int order, int cold)
 	arch_free_page(page, order);
 	kernel_map_pages(page, 1 << order, 0);
 
+	migratetype = get_pageblock_migratetype(page);
+
 	pcp = &zone_pcp(zone, get_cpu())->pcp;
 	local_irq_save(flags);
 	__count_vm_event(PGFREE);
 	if (clearMlocked)
 		free_page_mlock(page);
 
-	set_page_private(page, get_pageblock_migratetype(page));
+	/*
+	 * We only track unreclaimable, reclaimable and movable on pcp lists.
+	 * Free ISOLATE pages back to the allocator because they are being
+	 * offlined but treat RESERVE as movable pages so we can get those
+	 * areas back if necessary. Otherwise, we may have to free
+	 * excessively into the page allocator
+	 */
+	if (migratetype >= MIGRATE_PCPTYPES) {
+		if (unlikely(migratetype == MIGRATE_ISOLATE)) {
+			free_one_page(zone, page, order, migratetype);
+			goto out;
+		}
+		migratetype = MIGRATE_MOVABLE;
+	}
+
+	set_page_private(page, migratetype);
 	page->index = order;
 	add_pcp_page(pcp, page, cold);
-
 	if (pcp->count >= pcp->high)
-		free_pages_bulk(zone, pcp->batch, pcp);
+		free_pcppages_bulk(zone, pcp->batch, pcp);
+
+out:
 	local_irq_restore(flags);
 	put_cpu();
 }
@@ -1117,9 +1145,9 @@ void split_page(struct page *page, unsigned int order)
 		set_page_refcounted(page + i);
 }
 
-static inline int pcp_page_suit(struct page *page, int migratetype, int order)
+static inline int pcp_page_suit(struct page *page, int order)
 {
-	return page_private(page) == migratetype && page->index == order;
+	return page->index == order;
 }
 
 /*
@@ -1142,36 +1170,38 @@ again:
 		struct per_cpu_pages *pcp;
 		int batch;
 		int delta;
+		struct list_head *list;
 
 		pcp = &zone_pcp(zone, cpu)->pcp;
+		list = &pcp->lists[migratetype];
 		batch = max(1, pcp->batch >> order);
 		local_irq_save(flags);
-		if (!pcp->count) {
+		if (list_empty(list)) {
 			delta = rmqueue_bulk(zone, order, batch,
-					&pcp->list, migratetype);
+							list, migratetype);
 			bulk_add_pcp_page(pcp, order, delta);
-			if (unlikely(!pcp->count))
+			if (unlikely(list_empty(list)))
 				goto failed;
 		}
 
-		/* Find a page of the appropriate migrate type */
+		/* Find a page of the appropriate order */
 		if (cold) {
-			list_for_each_entry_reverse(page, &pcp->list, lru)
-				if (pcp_page_suit(page, migratetype, order))
+			list_for_each_entry_reverse(page, list, lru)
+				if (pcp_page_suit(page, order))
 					break;
 		} else {
-			list_for_each_entry(page, &pcp->list, lru)
-				if (pcp_page_suit(page, migratetype, order))
+			list_for_each_entry(page, list, lru)
+				if (pcp_page_suit(page, order))
 					break;
 		}
 
 		/* Allocate more to the pcp list if necessary */
-		if (unlikely(&page->lru == &pcp->list)) {
+		if (unlikely(&page->lru == list)) {
 			delta = rmqueue_bulk(zone, order, batch,
-					&pcp->list, migratetype);
+					list, migratetype);
 			bulk_add_pcp_page(pcp, order, delta);
-			page = list_entry(pcp->list.next, struct page, lru);
-			if (!pcp_page_suit(page, migratetype, order))
+			page = list_entry(list->next, struct page, lru);
+			if (!pcp_page_suit(page, order))
 				goto failed;
 		}
 
@@ -2938,6 +2968,7 @@ static int zone_batchsize(struct zone *zone)
 static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch)
 {
 	struct per_cpu_pages *pcp;
+	int migratetype;
 
 	memset(p, 0, sizeof(*p));
 
@@ -2945,7 +2976,8 @@ static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch)
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
