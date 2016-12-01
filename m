Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0541C6B0069
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 19:24:43 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id o2so28397384wje.5
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 16:24:42 -0800 (PST)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id c74si9559210wme.33.2016.11.30.16.24.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 Nov 2016 16:24:41 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id DA22498A1B
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 00:24:40 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH] mm: page_alloc: High-order per-cpu page allocator v4
Date: Thu,  1 Dec 2016 00:24:40 +0000
Message-Id: <20161201002440.5231-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Changelog since v3
o Allow high-order atomic allocations to use reserves

Changelog since v2
o Correct initialisation to avoid -Woverflow warning

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
                                  vanilla             hopcpu-v4
Hmean    send-64         178.38 (  0.00%)      259.91 ( 45.70%)
Hmean    send-128        351.49 (  0.00%)      532.46 ( 51.49%)
Hmean    send-256        671.23 (  0.00%)     1022.99 ( 52.40%)
Hmean    send-1024      2663.60 (  0.00%)     3995.17 ( 49.99%)
Hmean    send-2048      5126.53 (  0.00%)     7587.05 ( 48.00%)
Hmean    send-3312      7949.99 (  0.00%)    11697.16 ( 47.13%)
Hmean    send-4096      9433.56 (  0.00%)    13188.14 ( 39.80%)
Hmean    send-8192     15940.64 (  0.00%)    22023.98 ( 38.16%)
Hmean    send-16384    26699.54 (  0.00%)    32703.27 ( 22.49%)
Hmean    recv-64         178.38 (  0.00%)      259.89 ( 45.70%)
Hmean    recv-128        351.49 (  0.00%)      532.43 ( 51.48%)
Hmean    recv-256        671.20 (  0.00%)     1022.75 ( 52.38%)
Hmean    recv-1024      2663.45 (  0.00%)     3994.49 ( 49.97%)
Hmean    recv-2048      5126.26 (  0.00%)     7585.38 ( 47.97%)
Hmean    recv-3312      7949.50 (  0.00%)    11695.43 ( 47.12%)
Hmean    recv-4096      9433.04 (  0.00%)    13186.34 ( 39.79%)
Hmean    recv-8192     15939.64 (  0.00%)    22021.41 ( 38.15%)
Hmean    recv-16384    26698.44 (  0.00%)    32699.75 ( 22.48%)

1-socket 6 year old machine
                                4.9.0-rc5             4.9.0-rc5
                                  vanilla             hopcpu-v4
Hmean    send-64          87.47 (  0.00%)      129.07 ( 47.56%)
Hmean    send-128        174.36 (  0.00%)      258.53 ( 48.27%)
Hmean    send-256        347.52 (  0.00%)      511.02 ( 47.05%)
Hmean    send-1024      1363.03 (  0.00%)     1990.02 ( 46.00%)
Hmean    send-2048      2632.68 (  0.00%)     3775.89 ( 43.42%)
Hmean    send-3312      4123.19 (  0.00%)     5915.77 ( 43.48%)
Hmean    send-4096      5056.48 (  0.00%)     7152.31 ( 41.45%)
Hmean    send-8192      8784.22 (  0.00%)    12089.53 ( 37.63%)
Hmean    send-16384    15081.60 (  0.00%)    19650.42 ( 30.29%)
Hmean    recv-64          86.19 (  0.00%)      128.43 ( 49.01%)
Hmean    recv-128        173.93 (  0.00%)      257.28 ( 47.92%)
Hmean    recv-256        346.19 (  0.00%)      508.40 ( 46.86%)
Hmean    recv-1024      1358.28 (  0.00%)     1979.21 ( 45.71%)
Hmean    recv-2048      2623.45 (  0.00%)     3747.30 ( 42.84%)
Hmean    recv-3312      4108.63 (  0.00%)     5873.42 ( 42.95%)
Hmean    recv-4096      5037.25 (  0.00%)     7101.54 ( 40.98%)
Hmean    recv-8192      8762.32 (  0.00%)    12009.88 ( 37.06%)
Hmean    recv-16384    15042.36 (  0.00%)    19513.27 ( 29.72%)

This is somewhat dramatic but it's also not universal. For example, it was
observed on an older HP machine using pcc-cpufreq that there was almost
no difference but pcc-cpufreq is also a known performance hazard.

These are quite different results but illustrate that the patch is
dependent on the CPU. The results are similar for TCP_STREAM on
the two-socket machine.

The observations on sockperf are different.

2-socket modern machine
sockperf-tcp-throughput
                         4.9.0-rc5             4.9.0-rc5
                           vanilla             hopcpu-v4
Hmean    14        93.90 (  0.00%)       92.74 ( -1.23%)
Hmean    100     1211.02 (  0.00%)     1284.36 (  6.05%)
Hmean    300     6016.95 (  0.00%)     6149.26 (  2.20%)
Hmean    500     8846.20 (  0.00%)     8988.84 (  1.61%)
Hmean    850    12280.71 (  0.00%)    12434.78 (  1.25%)
Stddev   14         5.32 (  0.00%)        4.79 (  9.88%)
Stddev   100       35.32 (  0.00%)       74.20 (-110.06%)
Stddev   300      132.63 (  0.00%)       65.50 ( 50.61%)
Stddev   500      152.90 (  0.00%)      188.67 (-23.40%)
Stddev   850      221.46 (  0.00%)      257.61 (-16.32%)

sockperf-udp-throughput
                         4.9.0-rc5             4.9.0-rc5
                           vanilla             hopcpu-v4
Hmean    14        36.32 (  0.00%)       51.25 ( 41.09%)
Hmean    100      258.41 (  0.00%)      355.76 ( 37.67%)
Hmean    300      773.96 (  0.00%)     1054.13 ( 36.20%)
Hmean    500     1291.07 (  0.00%)     1758.21 ( 36.18%)
Hmean    850     2137.88 (  0.00%)     2939.52 ( 37.50%)
Stddev   14         0.75 (  0.00%)        1.21 (-61.36%)
Stddev   100        9.02 (  0.00%)       11.53 (-27.89%)
Stddev   300       13.66 (  0.00%)       31.24 (-128.62%)
Stddev   500       25.01 (  0.00%)       53.44 (-113.67%)
Stddev   850       37.72 (  0.00%)       70.05 (-85.71%)

Note that the improvements for TCP are nowhere near as dramatic as netperf,
there is a slight loss for small packets and it's much more variable. While
it's not presented here, it's known that running sockperf "under load"
that packet latency is generally lower but not universally so. On the
other hand, UDP improves performance but again, is much more variable.

This highlights that the patch is not necessarily a universal win and is
going to depend heavily on both the workload and the CPU used.

hackbench was also tested with both socket and pipes and both processes
and threads and the results are interesting in terms of how variability
is imapcted

1-socket machine
hackbench-process-pipes
                        4.9.0-rc5             4.9.0-rc5
                          vanilla           highmark-v3
Amean    1      12.9637 (  0.00%)     13.1807 ( -1.67%)
Amean    3      13.4770 (  0.00%)     13.6803 ( -1.51%)
Amean    5      18.5333 (  0.00%)     18.7383 ( -1.11%)
Amean    7      24.5690 (  0.00%)     23.0550 (  6.16%)
Amean    12     39.7990 (  0.00%)     36.7207 (  7.73%)
Amean    16     56.0520 (  0.00%)     48.2890 ( 13.85%)
Stddev   1       0.3847 (  0.00%)      0.5853 (-52.15%)
Stddev   3       0.2652 (  0.00%)      0.0295 ( 88.89%)
Stddev   5       0.5589 (  0.00%)      0.2466 ( 55.87%)
Stddev   7       0.5310 (  0.00%)      0.6680 (-25.79%)
Stddev   12      1.0780 (  0.00%)      0.3230 ( 70.04%)
Stddev   16      2.1138 (  0.00%)      0.6835 ( 67.66%)

hackbench-process-sockets
Amean    1       4.8873 (  0.00%)      4.7180 (  3.46%)
Amean    3      14.1157 (  0.00%)     14.3643 ( -1.76%)
Amean    5      22.5537 (  0.00%)     23.1380 ( -2.59%)
Amean    7      30.3743 (  0.00%)     31.1520 ( -2.56%)
Amean    12     49.1773 (  0.00%)     50.3060 ( -2.30%)
Amean    16     64.0873 (  0.00%)     66.2633 ( -3.40%)
Stddev   1       0.2360 (  0.00%)      0.2201 (  6.74%)
Stddev   3       0.0539 (  0.00%)      0.0780 (-44.72%)
Stddev   5       0.1463 (  0.00%)      0.1579 ( -7.90%)
Stddev   7       0.1260 (  0.00%)      0.3091 (-145.31%)
Stddev   12      0.2169 (  0.00%)      0.4822 (-122.36%)
Stddev   16      0.0529 (  0.00%)      0.4513 (-753.20%)

It's not a universal win for pipes but the differences are within the
noise. What is interesting is that variability shows both gains and losses
in stark contrast to the sockperf results. On the other hand, sockets
generally show small losses albeit within the noise with more variability.
Once again, the workload and CPU gets different results.

fsmark was tested with zero-sized files to continually allocate slab objects
but didn't show any differences. This can be explained by the fact that the
workload is only allocating and does not have mix of allocs/frees that would
benefit from the caching. It was tested to ensure no major harm was done.

While it is recognised that this is a mixed bag of results, the patch
helps a lot more workloads than it hurts and intuitively, avoiding the
zone->lock in some cases is a good thing.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 include/linux/mmzone.h |  20 ++++++++-
 mm/page_alloc.c        | 117 +++++++++++++++++++++++++++++++------------------
 2 files changed, 93 insertions(+), 44 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 0f088f3a2fed..54032ab2f4f9 100644
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
+#define NR_PCP_LISTS (MIGRATE_PCPTYPES + PAGE_ALLOC_COSTLY_ORDER)
+
+static inline unsigned int pindex_to_order(unsigned int pindex)
+{
+	return pindex < MIGRATE_PCPTYPES ? 0 : pindex - MIGRATE_PCPTYPES + 1;
+}
+
+static inline unsigned int order_to_pindex(int migratetype, unsigned int order)
+{
+	return (order == 0) ? migratetype : MIGRATE_PCPTYPES + order - 1;
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
index 6de9440e3ae2..94808f565f74 100644
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
@@ -1085,8 +1085,9 @@ static bool bulkfree_pcp_prepare(struct page *page)
 static void free_pcppages_bulk(struct zone *zone, int count,
 					struct per_cpu_pages *pcp)
 {
-	int migratetype = 0;
-	int batch_free = 0;
+	unsigned int pindex = UINT_MAX;	/* Reclaim will start at 0 */
+	unsigned int batch_free = 0;
+	unsigned int nr_freed = 0;
 	unsigned long nr_scanned;
 	bool isolated_pageblocks;
 
@@ -1096,28 +1097,29 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 	if (nr_scanned)
 		__mod_node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED, -nr_scanned);
 
-	while (count) {
+	while (count > 0) {
 		struct page *page;
 		struct list_head *list;
+		unsigned int order;
 
 		/*
 		 * Remove pages from lists in a round-robin fashion. A
 		 * batch_free count is maintained that is incremented when an
-		 * empty list is encountered.  This is so more pages are freed
-		 * off fuller lists instead of spinning excessively around empty
-		 * lists
+		 * empty list is encountered. This is not exact due to
+		 * high-order but percision is not required.
 		 */
 		do {
 			batch_free++;
-			if (++migratetype == MIGRATE_PCPTYPES)
-				migratetype = 0;
-			list = &pcp->lists[migratetype];
+			if (++pindex == NR_PCP_LISTS)
+				pindex = 0;
+			list = &pcp->lists[pindex];
 		} while (list_empty(list));
 
 		/* This is the only non-empty list. Free them all. */
-		if (batch_free == MIGRATE_PCPTYPES)
+		if (batch_free == NR_PCP_LISTS)
 			batch_free = count;
 
+		order = pindex_to_order(pindex);
 		do {
 			int mt;	/* migratetype of the to-be-freed page */
 
@@ -1135,11 +1137,14 @@ static void free_pcppages_bulk(struct zone *zone, int count,
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
@@ -2243,10 +2248,8 @@ void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp)
 	local_irq_save(flags);
 	batch = READ_ONCE(pcp->batch);
 	to_drain = min(pcp->count, batch);
-	if (to_drain > 0) {
+	if (to_drain > 0)
 		free_pcppages_bulk(zone, to_drain, pcp);
-		pcp->count -= to_drain;
-	}
 	local_irq_restore(flags);
 }
 #endif
@@ -2268,10 +2271,8 @@ static void drain_pages_zone(unsigned int cpu, struct zone *zone)
 	pset = per_cpu_ptr(zone->pageset, cpu);
 
 	pcp = &pset->pcp;
-	if (pcp->count) {
+	if (pcp->count)
 		free_pcppages_bulk(zone, pcp->count, pcp);
-		pcp->count = 0;
-	}
 	local_irq_restore(flags);
 }
 
@@ -2403,18 +2404,18 @@ void mark_free_pages(struct zone *zone)
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
@@ -2431,28 +2432,33 @@ void free_hot_cold_page(struct page *page, bool cold)
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
 		free_pcppages_bulk(zone, batch, pcp);
-		pcp->count -= batch;
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
@@ -2588,20 +2594,33 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
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
-				if (unlikely(list_empty(list)))
+				if (unlikely(list_empty(list))) {
+					/*
+					 * Retry high-order atomic allocs
+					 * from the buddy list which may
+					 * use MIGRATE_HIGHATOMIC.
+					 */
+					if (order && (alloc_flags & ALLOC_HARDER))
+						goto try_buddylist;
+
 					goto failed;
+				}
+				pcp->count += (nr_pages << order);
 			}
 
 			if (cold)
@@ -2610,10 +2629,11 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 				page = list_first_entry(list, struct page, lru);
 
 			list_del(&page->lru);
-			pcp->count--;
+			pcp->count -= (1 << order);
 
 		} while (check_new_pcp(page));
 	} else {
+try_buddylist:
 		/*
 		 * We most definitely don't want callers attempting to
 		 * allocate greater than order-1 page units with __GFP_NOFAIL.
@@ -3837,8 +3857,8 @@ EXPORT_SYMBOL(get_zeroed_page);
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
@@ -5160,20 +5180,31 @@ static void pageset_update(struct per_cpu_pages *pcp, unsigned long high,
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
