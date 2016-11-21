Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 655876B026D
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 10:55:44 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id i131so42262777wmf.3
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 07:55:44 -0800 (PST)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id ld3si20899686wjc.127.2016.11.21.07.55.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Nov 2016 07:55:42 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id C5AB61C2E88
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 15:55:40 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [RFC PATCH] mm: page_alloc: High-order per-cpu page allocator
Date: Mon, 21 Nov 2016 15:55:40 +0000
Message-Id: <20161121155540.5327-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

SLUB has been the default small kernel object allocator for quite some time
but it is not universally used due to performance concerns and a reliance
on high-order pages. The high-order concerns has two major components --
high-order pages are not always available and high-order page allocations
potentially contend on the zone->lock. This patch addresses some concerns
about the zone lock contention by extending the per-cpu page allocator to
cache high-order pages. The patch makes the following modifications

o New per-cpu lists are added to cache the high-order pages. This increases
  the cache footprint of the per-cpu allocator and overall usage but for
  some workloads, this will be offset by reduced contention on zone->lock.
  The first MIGRATE_PCPTYPE entries in the list are per-migratetype. The
  remaining are high-order caches up to and including
  PAGE_ALLOC_COSTLY_ORDER

o pcp accounting during free is now confined to free_pcppages_bulk as it's
  impossible for the caller to know exactly how many pages were freed.
  Due to the high-order caches, the number of pages drained for a request
  is no longer precise.

o When draining pages, it'll use the migratetype as a hint about which
  list to drain first. This is to avoid a case where MIGRATE_UNMOVABLE
  order-0 pages are artifically preserved and draining focuses on the
  high-order pages.

o The high watermark for per-cpu pages is increased to reduce the probability
  that a single refill causes a drain on the next free.

The benefit depends on both the workload and the machine as ultimately the
determining factor is whether cache line bounces on zone->lock or contention
is a problem. The patch was tested on a variety of workloads and machines,
some of which are reported here.

This is the result from netperf running UDP_STREAM on localhost. It was
selected on the basis that it is slab-intensive and has been the subject
of previous SLAB vs SLUB comparisons with the caveat that this is not
testing between two physical hosts.

2-socket modern machine
                                4.9.0-rc5             4.9.0-rc5
                                  vanilla           hopcpu-v1r9
Hmean    send-64         178.38 (  0.00%)      189.49 (  6.23%)
Hmean    send-128        351.49 (  0.00%)      379.40 (  7.94%)
Hmean    send-256        671.23 (  0.00%)      735.03 (  9.50%)
Hmean    send-1024      2663.60 (  0.00%)     2842.09 (  6.70%)
Hmean    send-2048      5126.53 (  0.00%)     5547.27 (  8.21%)
Hmean    send-3312      7949.99 (  0.00%)     8515.82 (  7.12%)
Hmean    send-4096      9433.56 (  0.00%)     9964.34 (  5.63%)
Hmean    send-8192     15940.64 (  0.00%)    17120.50 (  7.40%)
Hmean    send-16384    26699.54 (  0.00%)    28307.62 (  6.02%)
Hmean    recv-64         178.38 (  0.00%)      189.48 (  6.23%)
Hmean    recv-128        351.49 (  0.00%)      379.39 (  7.94%)
Hmean    recv-256        671.20 (  0.00%)      734.94 (  9.50%)
Hmean    recv-1024      2663.45 (  0.00%)     2841.86 (  6.70%)
Hmean    recv-2048      5126.26 (  0.00%)     5546.79 (  8.20%)
Hmean    recv-3312      7949.50 (  0.00%)     8515.34 (  7.12%)
Hmean    recv-4096      9433.04 (  0.00%)     9963.78 (  5.63%)
Hmean    recv-8192     15939.64 (  0.00%)    17119.63 (  7.40%)
Hmean    recv-16384    26698.44 (  0.00%)    28305.98 (  6.02%)

1-socket 6 year old machine
                                4.9.0-rc5             4.9.0-rc5
                                  vanilla           hopcpu-v1r9
Hmean    send-64          87.47 (  0.00%)       87.69 (  0.25%)
Hmean    send-128        174.36 (  0.00%)      175.22 (  0.49%)
Hmean    send-256        347.52 (  0.00%)      350.15 (  0.76%)
Hmean    send-1024      1363.03 (  0.00%)     1374.17 (  0.82%)
Hmean    send-2048      2632.68 (  0.00%)     2673.81 (  1.56%)
Hmean    send-3312      4123.19 (  0.00%)     4197.08 (  1.79%)
Hmean    send-4096      5056.48 (  0.00%)     5089.92 (  0.66%)
Hmean    send-8192      8784.22 (  0.00%)     8951.35 (  1.90%)
Hmean    send-16384    15081.60 (  0.00%)    15283.81 (  1.34%)
Hmean    recv-64          86.19 (  0.00%)       87.40 (  1.39%)
Hmean    recv-128        173.93 (  0.00%)      174.71 (  0.44%)
Hmean    recv-256        346.19 (  0.00%)      348.82 (  0.76%)
Hmean    recv-1024      1358.28 (  0.00%)     1369.33 (  0.81%)
Hmean    recv-2048      2623.45 (  0.00%)     2665.06 (  1.59%)
Hmean    recv-3312      4108.63 (  0.00%)     4180.29 (  1.74%)
Hmean    recv-4096      5037.25 (  0.00%)     5073.50 (  0.72%)
Hmean    recv-8192      8762.32 (  0.00%)     8918.69 (  1.78%)
Hmean    recv-16384    15042.36 (  0.00%)    15209.75 (  1.11%)

These are quite different results but illustrate that the patch is
dependent on the CPU. The results are similar for TCP_STREAM on
the two-socket machine but shows more consistent improvements
on the 1-socket old machine highlighting that the impact is both
CPU and workload dependent.

Similar observations are made when using sockperf to send packets of
different sizes over localhost. There are a mix of gains and losses
depending on machine, packet size and protocol which was overall
inconclusive.

hackbench was also tested with both socket and pipes and both processes
and threads and the results are interesting in terms of how variability
is imapcted

1-socket machine -- pipes and processes
                        4.9.0-rc5             4.9.0-rc5
                          vanilla        highmark-v1r12
Amean    1      12.9637 (  0.00%)     12.9570 (  0.05%)
Amean    3      13.4770 (  0.00%)     13.4447 (  0.24%)
Amean    5      18.5333 (  0.00%)     19.0917 ( -3.01%)
Amean    7      24.5690 (  0.00%)     26.1010 ( -6.24%)
Amean    12     39.7990 (  0.00%)     40.6763 ( -2.20%)
Amean    16     56.0520 (  0.00%)     58.2530 ( -3.93%)
Stddev   1       0.3847 (  0.00%)      0.3137 ( 18.45%)
Stddev   3       0.2652 (  0.00%)      0.3697 (-39.41%)
Stddev   5       0.5589 (  0.00%)      0.9438 (-68.88%)
Stddev   7       0.5310 (  0.00%)      0.2699 ( 49.18%)
Stddev   12      1.0780 (  0.00%)      0.3421 ( 68.26%)
Stddev   16      2.1138 (  0.00%)      1.5677 ( 25.84%)

It's not a universal win but the differences are within the noise. What
is interesting is that for high thread counts that variability is much
reduced -- the time when contention would be expected to be high. This
is not consistent across all machines but it mostly applies.

While pipes, sockets and threads were tested, they did not show anything
else interesting.

fsmark was tested with zero-sized files to continually allocate slab objects
but didn't show any differences. This can be explained by the fact that the
workload is only allocating and does not have mix of allocs/frees that would
benefit from the caching. It was tested to ensure no major harm was done.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/mmzone.h |  20 ++++++++-
 mm/page_alloc.c        | 120 +++++++++++++++++++++++++++++--------------------
 2 files changed, 90 insertions(+), 50 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 0f088f3a2fed..02eb24d90d70 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -255,6 +255,24 @@ enum zone_watermarks {
 	NR_WMARK
 };
 
+/*
+ * One per migratetype for order-0 pages and one per high-order up to
+ * and including PAGE_ALLOC_COSTLY_ORDER. This may allow unmovable
+ * allocations to contaminate reclaimable pageblocks if high-order
+ * pages are heavily used.
+ */
+#define NR_PCP_LISTS (MIGRATE_PCPTYPES + PAGE_ALLOC_COSTLY_ORDER + 1)
+
+static inline unsigned int pindex_to_order(unsigned int pindex)
+{
+	return pindex < MIGRATE_PCPTYPES ? 0 : pindex - MIGRATE_PCPTYPES + 1;
+}
+
+static inline unsigned int order_to_pindex(int migratetype, unsigned int order)
+{
+	return (order == 0) ? migratetype : MIGRATE_PCPTYPES - 1 + order;
+}
+
 #define min_wmark_pages(z) (z->watermark[WMARK_MIN])
 #define low_wmark_pages(z) (z->watermark[WMARK_LOW])
 #define high_wmark_pages(z) (z->watermark[WMARK_HIGH])
@@ -265,7 +283,7 @@ struct per_cpu_pages {
 	int batch;		/* chunk size for buddy add/remove */
 
 	/* Lists of pages, one per migrate type stored on the pcp-lists */
-	struct list_head lists[MIGRATE_PCPTYPES];
+	struct list_head lists[NR_PCP_LISTS];
 };
 
 struct per_cpu_pageset {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6de9440e3ae2..a3b3ea92cac3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1050,9 +1050,9 @@ static __always_inline bool free_pages_prepare(struct page *page,
 }
 
 #ifdef CONFIG_DEBUG_VM
-static inline bool free_pcp_prepare(struct page *page)
+static inline bool free_pcp_prepare(struct page *page, unsigned int order)
 {
-	return free_pages_prepare(page, 0, true);
+	return free_pages_prepare(page, order, true);
 }
 
 static inline bool bulkfree_pcp_prepare(struct page *page)
@@ -1060,9 +1060,9 @@ static inline bool bulkfree_pcp_prepare(struct page *page)
 	return false;
 }
 #else
-static bool free_pcp_prepare(struct page *page)
+static bool free_pcp_prepare(struct page *page, unsigned int order)
 {
-	return free_pages_prepare(page, 0, false);
+	return free_pages_prepare(page, order, false);
 }
 
 static bool bulkfree_pcp_prepare(struct page *page)
@@ -1083,10 +1083,12 @@ static bool bulkfree_pcp_prepare(struct page *page)
  * pinned" detection logic.
  */
 static void free_pcppages_bulk(struct zone *zone, int count,
-					struct per_cpu_pages *pcp)
+					struct per_cpu_pages *pcp,
+					int migratetype)
 {
-	int migratetype = 0;
-	int batch_free = 0;
+	unsigned int pindex = 0;
+	struct list_head *list = &pcp->lists[migratetype];
+	unsigned int nr_freed = 0;
 	unsigned long nr_scanned;
 	bool isolated_pageblocks;
 
@@ -1096,28 +1098,29 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 	if (nr_scanned)
 		__mod_node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED, -nr_scanned);
 
-	while (count) {
+	while (count > 0) {
 		struct page *page;
-		struct list_head *list;
+		unsigned int order;
+		int batch_free = 1;
 
 		/*
 		 * Remove pages from lists in a round-robin fashion. A
 		 * batch_free count is maintained that is incremented when an
-		 * empty list is encountered.  This is so more pages are freed
-		 * off fuller lists instead of spinning excessively around empty
-		 * lists
+		 * empty list is encountered. This is not exact due to
+		 * high-order but percision is not required.
 		 */
-		do {
+		while (list_empty(list)) {
 			batch_free++;
-			if (++migratetype == MIGRATE_PCPTYPES)
-				migratetype = 0;
-			list = &pcp->lists[migratetype];
-		} while (list_empty(list));
+			if (++pindex == NR_PCP_LISTS)
+				pindex = 0;
+			list = &pcp->lists[pindex];
+		}
 
 		/* This is the only non-empty list. Free them all. */
-		if (batch_free == MIGRATE_PCPTYPES)
+		if (batch_free == NR_PCP_LISTS)
 			batch_free = count;
 
+		order = pindex_to_order(pindex);
 		do {
 			int mt;	/* migratetype of the to-be-freed page */
 
@@ -1135,11 +1138,14 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			if (bulkfree_pcp_prepare(page))
 				continue;
 
-			__free_one_page(page, page_to_pfn(page), zone, 0, mt);
-			trace_mm_page_pcpu_drain(page, 0, mt);
-		} while (--count && --batch_free && !list_empty(list));
+			__free_one_page(page, page_to_pfn(page), zone, order, mt);
+			trace_mm_page_pcpu_drain(page, order, mt);
+			nr_freed += (1 << order);
+			count -= (1 << order);
+		} while (count > 0 && --batch_free && !list_empty(list));
 	}
 	spin_unlock(&zone->lock);
+	pcp->count -= nr_freed;
 }
 
 static void free_one_page(struct zone *zone,
@@ -2243,10 +2249,8 @@ void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp)
 	local_irq_save(flags);
 	batch = READ_ONCE(pcp->batch);
 	to_drain = min(pcp->count, batch);
-	if (to_drain > 0) {
-		free_pcppages_bulk(zone, to_drain, pcp);
-		pcp->count -= to_drain;
-	}
+	if (to_drain > 0)
+		free_pcppages_bulk(zone, to_drain, pcp, 0);
 	local_irq_restore(flags);
 }
 #endif
@@ -2268,10 +2272,8 @@ static void drain_pages_zone(unsigned int cpu, struct zone *zone)
 	pset = per_cpu_ptr(zone->pageset, cpu);
 
 	pcp = &pset->pcp;
-	if (pcp->count) {
-		free_pcppages_bulk(zone, pcp->count, pcp);
-		pcp->count = 0;
-	}
+	if (pcp->count)
+		free_pcppages_bulk(zone, pcp->count, pcp, 0);
 	local_irq_restore(flags);
 }
 
@@ -2403,18 +2405,18 @@ void mark_free_pages(struct zone *zone)
 #endif /* CONFIG_PM */
 
 /*
- * Free a 0-order page
+ * Free a pcp page
  * cold == true ? free a cold page : free a hot page
  */
-void free_hot_cold_page(struct page *page, bool cold)
+static void __free_hot_cold_page(struct page *page, bool cold, unsigned int order)
 {
 	struct zone *zone = page_zone(page);
 	struct per_cpu_pages *pcp;
 	unsigned long flags;
 	unsigned long pfn = page_to_pfn(page);
-	int migratetype;
+	int migratetype, pindex;
 
-	if (!free_pcp_prepare(page))
+	if (!free_pcp_prepare(page, order))
 		return;
 
 	migratetype = get_pfnblock_migratetype(page, pfn);
@@ -2431,28 +2433,33 @@ void free_hot_cold_page(struct page *page, bool cold)
 	 */
 	if (migratetype >= MIGRATE_PCPTYPES) {
 		if (unlikely(is_migrate_isolate(migratetype))) {
-			free_one_page(zone, page, pfn, 0, migratetype);
+			free_one_page(zone, page, pfn, order, migratetype);
 			goto out;
 		}
 		migratetype = MIGRATE_MOVABLE;
 	}
 
+	pindex = order_to_pindex(migratetype, order);
 	pcp = &this_cpu_ptr(zone->pageset)->pcp;
 	if (!cold)
-		list_add(&page->lru, &pcp->lists[migratetype]);
+		list_add(&page->lru, &pcp->lists[pindex]);
 	else
-		list_add_tail(&page->lru, &pcp->lists[migratetype]);
-	pcp->count++;
+		list_add_tail(&page->lru, &pcp->lists[pindex]);
+	pcp->count += 1 << order;
 	if (pcp->count >= pcp->high) {
 		unsigned long batch = READ_ONCE(pcp->batch);
-		free_pcppages_bulk(zone, batch, pcp);
-		pcp->count -= batch;
+		free_pcppages_bulk(zone, batch, pcp, migratetype);
 	}
 
 out:
 	local_irq_restore(flags);
 }
 
+void free_hot_cold_page(struct page *page, bool cold)
+{
+	__free_hot_cold_page(page, cold, 0);
+}
+
 /*
  * Free a list of 0-order pages
  */
@@ -2588,18 +2595,22 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 	struct page *page;
 	bool cold = ((gfp_flags & __GFP_COLD) != 0);
 
-	if (likely(order == 0)) {
+	if (likely(order <= PAGE_ALLOC_COSTLY_ORDER)) {
 		struct per_cpu_pages *pcp;
 		struct list_head *list;
 
 		local_irq_save(flags);
 		do {
+			unsigned int pindex;
+
+			pindex = order_to_pindex(migratetype, order);
 			pcp = &this_cpu_ptr(zone->pageset)->pcp;
-			list = &pcp->lists[migratetype];
+			list = &pcp->lists[pindex];
 			if (list_empty(list)) {
-				pcp->count += rmqueue_bulk(zone, 0,
+				int nr_pages = rmqueue_bulk(zone, order,
 						pcp->batch, list,
 						migratetype, cold);
+				pcp->count += (nr_pages << order);
 				if (unlikely(list_empty(list)))
 					goto failed;
 			}
@@ -2610,7 +2621,7 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 				page = list_first_entry(list, struct page, lru);
 
 			list_del(&page->lru);
-			pcp->count--;
+			pcp->count -= (1 << order);
 
 		} while (check_new_pcp(page));
 	} else {
@@ -3837,8 +3848,8 @@ EXPORT_SYMBOL(get_zeroed_page);
 void __free_pages(struct page *page, unsigned int order)
 {
 	if (put_page_testzero(page)) {
-		if (order == 0)
-			free_hot_cold_page(page, false);
+		if (order <= PAGE_ALLOC_COSTLY_ORDER)
+			__free_hot_cold_page(page, false, order);
 		else
 			__free_pages_ok(page, order);
 	}
@@ -5160,20 +5171,31 @@ static void pageset_update(struct per_cpu_pages *pcp, unsigned long high,
 /* a companion to pageset_set_high() */
 static void pageset_set_batch(struct per_cpu_pageset *p, unsigned long batch)
 {
-	pageset_update(&p->pcp, 6 * batch, max(1UL, 1 * batch));
+	unsigned long high;
+
+	/*
+	 * per-cpu refills occur when a per-cpu list for a migratetype
+	 * or a high-order is depleted even if pages are free overall.
+	 * Tune the high watermark such that it's unlikely, but not
+	 * impossible, that a single refill event will trigger a
+	 * shrink on the next free to the per-cpu list.
+	 */
+	high = batch * MIGRATE_PCPTYPES + (batch << PAGE_ALLOC_COSTLY_ORDER);
+
+	pageset_update(&p->pcp, high, max(1UL, 1 * batch));
 }
 
 static void pageset_init(struct per_cpu_pageset *p)
 {
 	struct per_cpu_pages *pcp;
-	int migratetype;
+	unsigned int pindex;
 
 	memset(p, 0, sizeof(*p));
 
 	pcp = &p->pcp;
 	pcp->count = 0;
-	for (migratetype = 0; migratetype < MIGRATE_PCPTYPES; migratetype++)
-		INIT_LIST_HEAD(&pcp->lists[migratetype]);
+	for (pindex = 0; pindex < NR_PCP_LISTS; pindex++)
+		INIT_LIST_HEAD(&pcp->lists[pindex]);
 }
 
 static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch)
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
