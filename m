Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7D4046B026A
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 12:06:49 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y5-v6so8327716edp.7
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 09:06:49 -0700 (PDT)
Received: from outbound-smtp27.blacknight.com (outbound-smtp27.blacknight.com. [81.17.249.195])
        by mx.google.com with ESMTPS id c29-v6si1922507eda.227.2018.10.31.09.06.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 Oct 2018 09:06:46 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp27.blacknight.com (Postfix) with ESMTPS id 5CDCAB88E8
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 16:06:46 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 1/5] mm, page_alloc: Spread allocations across zones before introducing fragmentation
Date: Wed, 31 Oct 2018 16:06:41 +0000
Message-Id: <20181031160645.7633-2-mgorman@techsingularity.net>
In-Reply-To: <20181031160645.7633-1-mgorman@techsingularity.net>
References: <20181031160645.7633-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

The page allocator zone lists are iterated based on the watermarks
of each zone which does not take anti-fragmentation into account. On
x86, node 0 may have multiple zones while other nodes have one zone. A
consequence is that tasks running on node 0 may fragment ZONE_NORMAL even
though ZONE_DMA32 has plenty of free memory. This patch special cases
the allocator fast path such that it'll try an allocation from a lower
local zone before fragmenting a higher zone. In this case, stealing of
pageblocks or orders larger than a pageblock are still allowed in the
fast path as they are uninteresting from a fragmentation point of view.

This was evaluated using a benchmark designed to fragment memory
before attempting THPs.  It's implemented in mmtests as the following
configurations

configs/config-global-dhp__workload_thpfioscale
configs/config-global-dhp__workload_thpfioscale-defrag
configs/config-global-dhp__workload_thpfioscale-madvhugepage

e.g. from mmtests
./run-mmtests.sh --run-monitor --config configs/config-global-dhp__workload_thpfioscale test-run-1

The broad details of the workload are as follows;

1. Create an XFS filesystem (not specified in the configuration but done
   as part of the testing for this patch)
2. Start 4 fio threads that write a number of 64K files inefficiently.
   Inefficiently means that files are created on first access and not
   created in advance (fio parameterr create_on_open=1) and fallocate
   is not used (fallocate=none). With multiple IO issuers this creates
   a mix of slab and page cache allocations over time. The total size
   of the files is 150% physical memory so that the slabs and page cache
   pages get mixed
3. Warm up a number of fio read-only threads accessing the same files
   created in step 2. This part runs for the same length of time it
   took to create the files. It'll fault back in old data and further
   interleave slab and page cache allocations. As it's now low on
   memory due to step 2, fragmentation occurs as pageblocks get
   stolen.
4. While step 3 is still running, start a process that tries to allocate
   75% of memory as huge pages with a number of threads. The number of
   threads is based on a (NR_CPUS_SOCKET - NR_FIO_THREADS)/4 to avoid THP
   threads contending with fio, any other threads or forcing cross-NUMA
   scheduling. Note that the test has not been used on a machine with less
   than 8 cores. The benchmark records whether huge pages were allocated
   and what the fault latency was in microseconds
5. Measure the number of events potentially causing external fragmentation,
   the fault latency and the huge page allocation success rate.
6. Cleanup

Note that due to the use of IO and page cache that this benchmark is not
suitable for running on large machines where the time to fragment memory
may be excessive. Also note that while this is one mix that generates
fragmentation that it's not the only mix that generates fragmentation.
Differences in workload that are more slab-intensive or whether SLUB is
used with high-order pages may yield different results.

When the page allocator fragments memory, it records the event using the
mm_page_alloc_extfrag event. If the fallback_order is smaller than a
pageblock order (order-9 on 64-bit x86) then it's considered an event
that may cause external fragmentation issues in the future. Hence, the
primary metric here is the number of external fragmentation events that
occur with order < 9. The secondary metric is allocation latency and huge
page allocation success rates but note that differences in latencies and
what the success rate also can affect the number of external fragmentation
event which is why it's a secondary metric.

1-socket Skylake machine
config-global-dhp__workload_thpfioscale XFS (no special madvise)
4 fio threads, 1 THP allocating thread
--------------------------------------

4.19 extfrag events < order 0:	71227
4.19+patch:                     36456 (49% reduction)

thpfioscale Fault Latencies
                                       4.19.0                 4.19.0
                                      vanilla           lowzone-v1r1
Amean     fault-base-1      605.84 (   0.00%)      599.92 *   0.98%*
Amean     fault-huge-1      296.00 (   0.00%)      179.84 *  39.24%*

                                  4.19.0                 4.19.0
                                 vanilla           lowzone-v1r1
Percentage huge-1        0.44 (   0.00%)        1.08 ( 146.15%)

Fault latencies are reduced. While allocation success rates are not much
higher, this configuration does not make any heavy effort to allocate
THP and fio is heavily active at the time and filling memory.  However,
a 49% reduction of serious fragmentation events reduces the changes of
external fragmentation being a problem in the future.

1-socket Skylake machine
global-dhp__workload_thpfioscale-madvhugepage-xfs (MADV_HUGEPAGE)
-----------------------------------------------------------------

4.19 extfrag events < order 0:  40761
4.19+patch:                     36085 (11.47% reduction)

thpfioscale Fault Latencies
                                       4.19.0                 4.19.0
                                      vanilla           lowzone-v1r1
Amean     fault-base-1     1938.77 (   0.00%)     1938.47 (   0.02%)
Amean     fault-huge-1      774.80 (   0.00%)      749.40 *   3.28%*

thpfioscale Percentage Faults Huge
                                  4.19.0                 4.19.0
                                 vanilla           lowzone-v1r1
Percentage huge-1       83.59 (   0.00%)       83.79 (   0.24%)

Nothing dramatic. Fragmentation events are still reduced but the differences
in fault latencies and allocation success rates are similar.

2-socket Haswell machine
config-global-dhp__workload_thpfioscale XFS (no special madvise)
4 fio threads, 5 THP allocating threads
----------------------------------------------------------------

4.19 extfrag events < order 0:  882868
4.19+patch:                     476937 (46% reduction)

thpfioscale Fault Latencies
                                       4.19.0                 4.19.0
                                      vanilla           lowzone-v1r1
Amean     fault-base-5     1505.76 (   0.00%)     1602.01 (  -6.39%)
Amean     fault-huge-5      687.00 (   0.00%)        0.00 * 100.00%*

                                  4.19.0                 4.19.0
                                 vanilla           lowzone-v1r1
Percentage huge-5        0.07 (   0.00%)        0.00 (   0.00%)

The reduction of external fragmentation events is expected. The
latencies are off because the huge page allocations generally
failed and the patch does not have a direct impact on success
rates.

2-socket Haswell machine
global-dhp__workload_thpfioscale-madvhugepage-xfs (MADV_HUGEPAGE)
-----------------------------------------------------------------

4.19 extfrag events < order 0: 803099
4.19+patch:                    654671 (23% reduction)

thpfioscale Fault Latencies
                                       4.19.0                 4.19.0
                                      vanilla           lowzone-v1r1
Amean     fault-base-5     5389.23 (   0.00%)     6678.61 * -23.93%*
Amean     fault-huge-5     5039.32 (   0.00%)     2796.35 *  44.51%*

thpfioscale Percentage Faults Huge
                                  4.19.0                 4.19.0
                                 vanilla           lowzone-v1r1
Percentage huge-5       30.69 (   0.00%)       57.92 (  88.71%)

In this case, there was both a reduction in the external fragmentation
causing events and the huge page allocation success rates were increased
substantially from 30.69% of attempts to 57.92%.

Overall, the patch significantly reduces the number of external
fragmentation causing events so the success of THP over long
periods of time would be improved for this adverse workload.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/internal.h   |  13 +++++---
 mm/page_alloc.c | 101 ++++++++++++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 99 insertions(+), 15 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 87256ae1bef8..0dd659cf2a7e 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -480,10 +480,15 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 #define ALLOC_OOM		ALLOC_NO_WATERMARKS
 #endif
 
-#define ALLOC_HARDER		0x10 /* try to alloc harder */
-#define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
-#define ALLOC_CPUSET		0x40 /* check for correct cpuset */
-#define ALLOC_CMA		0x80 /* allow allocations from CMA areas */
+#define ALLOC_HARDER		 0x10 /* try to alloc harder */
+#define ALLOC_HIGH		 0x20 /* __GFP_HIGH set */
+#define ALLOC_CPUSET		 0x40 /* check for correct cpuset */
+#define ALLOC_CMA		 0x80 /* allow allocations from CMA areas */
+#ifdef CONFIG_ZONE_DMA32
+#define ALLOC_NOFRAGMENT	0x100 /* avoid mixing pageblock types */
+#else
+#define ALLOC_NOFRAGMENT	  0x0
+#endif
 
 enum ttu_flags;
 struct tlbflush_unmap_batch;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e2ef1c17942f..db5d61868c96 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2364,20 +2364,30 @@ static bool unreserve_highatomic_pageblock(const struct alloc_context *ac,
  * condition simpler.
  */
 static __always_inline bool
-__rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
+__rmqueue_fallback(struct zone *zone, int order, int start_migratetype,
+						unsigned int alloc_flags)
 {
 	struct free_area *area;
 	int current_order;
+	int min_order = order;
 	struct page *page;
 	int fallback_mt;
 	bool can_steal;
 
+	/*
+	 * Do not steal pages from freelists belonging to other pageblocks
+	 * i.e. orders < pageblock_order. In the event there is on local
+	 * zone free, the allocation will retry later.
+	 */
+	if (alloc_flags & ALLOC_NOFRAGMENT)
+		min_order = pageblock_order;
+
 	/*
 	 * Find the largest available free page in the other list. This roughly
 	 * approximates finding the pageblock with the most free pages, which
 	 * would be too costly to do exactly.
 	 */
-	for (current_order = MAX_ORDER - 1; current_order >= order;
+	for (current_order = MAX_ORDER - 1; current_order >= min_order;
 				--current_order) {
 		area = &(zone->free_area[current_order]);
 		fallback_mt = find_suitable_fallback(area, current_order,
@@ -2436,7 +2446,8 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
  * Call me with the zone->lock already held.
  */
 static __always_inline struct page *
-__rmqueue(struct zone *zone, unsigned int order, int migratetype)
+__rmqueue(struct zone *zone, unsigned int order, int migratetype,
+						unsigned int alloc_flags)
 {
 	struct page *page;
 
@@ -2446,7 +2457,8 @@ __rmqueue(struct zone *zone, unsigned int order, int migratetype)
 		if (migratetype == MIGRATE_MOVABLE)
 			page = __rmqueue_cma_fallback(zone, order);
 
-		if (!page && __rmqueue_fallback(zone, order, migratetype))
+		if (!page && __rmqueue_fallback(zone, order, migratetype,
+								alloc_flags))
 			goto retry;
 	}
 
@@ -2461,13 +2473,14 @@ __rmqueue(struct zone *zone, unsigned int order, int migratetype)
  */
 static int rmqueue_bulk(struct zone *zone, unsigned int order,
 			unsigned long count, struct list_head *list,
-			int migratetype)
+			int migratetype, unsigned int alloc_flags)
 {
 	int i, alloced = 0;
 
 	spin_lock(&zone->lock);
 	for (i = 0; i < count; ++i) {
-		struct page *page = __rmqueue(zone, order, migratetype);
+		struct page *page = __rmqueue(zone, order, migratetype,
+								alloc_flags);
 		if (unlikely(page == NULL))
 			break;
 
@@ -2923,6 +2936,7 @@ static inline void zone_statistics(struct zone *preferred_zone, struct zone *z)
 
 /* Remove page from the per-cpu list, caller must protect the list */
 static struct page *__rmqueue_pcplist(struct zone *zone, int migratetype,
+			unsigned int alloc_flags,
 			struct per_cpu_pages *pcp,
 			struct list_head *list)
 {
@@ -2932,7 +2946,7 @@ static struct page *__rmqueue_pcplist(struct zone *zone, int migratetype,
 		if (list_empty(list)) {
 			pcp->count += rmqueue_bulk(zone, 0,
 					pcp->batch, list,
-					migratetype);
+					migratetype, alloc_flags);
 			if (unlikely(list_empty(list)))
 				return NULL;
 		}
@@ -2948,7 +2962,8 @@ static struct page *__rmqueue_pcplist(struct zone *zone, int migratetype,
 /* Lock and remove page from the per-cpu list */
 static struct page *rmqueue_pcplist(struct zone *preferred_zone,
 			struct zone *zone, unsigned int order,
-			gfp_t gfp_flags, int migratetype)
+			gfp_t gfp_flags, int migratetype,
+			unsigned int alloc_flags)
 {
 	struct per_cpu_pages *pcp;
 	struct list_head *list;
@@ -2958,7 +2973,7 @@ static struct page *rmqueue_pcplist(struct zone *preferred_zone,
 	local_irq_save(flags);
 	pcp = &this_cpu_ptr(zone->pageset)->pcp;
 	list = &pcp->lists[migratetype];
-	page = __rmqueue_pcplist(zone,  migratetype, pcp, list);
+	page = __rmqueue_pcplist(zone,  migratetype, alloc_flags, pcp, list);
 	if (page) {
 		__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);
 		zone_statistics(preferred_zone, zone);
@@ -2981,7 +2996,7 @@ struct page *rmqueue(struct zone *preferred_zone,
 
 	if (likely(order == 0)) {
 		page = rmqueue_pcplist(preferred_zone, zone, order,
-				gfp_flags, migratetype);
+				gfp_flags, migratetype, alloc_flags);
 		goto out;
 	}
 
@@ -3000,7 +3015,7 @@ struct page *rmqueue(struct zone *preferred_zone,
 				trace_mm_page_alloc_zone_locked(page, order, migratetype);
 		}
 		if (!page)
-			page = __rmqueue(zone, order, migratetype);
+			page = __rmqueue(zone, order, migratetype, alloc_flags);
 	} while (page && check_new_pages(page, order));
 	spin_unlock(&zone->lock);
 	if (!page)
@@ -3242,6 +3257,36 @@ static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
 }
 #endif	/* CONFIG_NUMA */
 
+#ifdef CONFIG_ZONE_DMA32
+/*
+ * The restriction on ZONE_DMA32 as being a suitable zone to use to avoid
+ * fragmentation is subtle. If the preferred zone was HIGHMEM then
+ * premature use of a lower zone may cause lowmem pressure problems that
+ * are wose than fragmentation. If the next zone is ZONE_DMA then it is
+ * probably too small. It only makes sense to spread allocations to avoid
+ * fragmentation between the Normal and DMA32 zones.
+ */
+static inline unsigned int alloc_flags_nofragment(struct zone *zone)
+{
+	if (zone_idx(zone) != ZONE_NORMAL)
+		return 0;
+
+	/*
+	 * If ZONE_DMA32 exists, assume it is the one after ZONE_NORMAL and
+	 * the pointer is within zone->zone_pgdat->node_zones[].
+	 */
+	if (!populated_zone(--zone))
+		return 0;
+
+	return ALLOC_NOFRAGMENT;
+}
+#else
+static inline unsigned int alloc_flags_nofragment(struct zone *zone)
+{
+	return 0;
+}
+#endif
+
 /*
  * get_page_from_freelist goes through the zonelist trying to allocate
  * a page.
@@ -3253,11 +3298,14 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 	struct zoneref *z = ac->preferred_zoneref;
 	struct zone *zone;
 	struct pglist_data *last_pgdat_dirty_limit = NULL;
+	bool no_fallback;
 
+retry:
 	/*
 	 * Scan zonelist, looking for a zone with enough free.
 	 * See also __cpuset_node_allowed() comment in kernel/cpuset.c.
 	 */
+	no_fallback = alloc_flags & ALLOC_NOFRAGMENT;
 	for_next_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx,
 								ac->nodemask) {
 		struct page *page;
@@ -3296,6 +3344,22 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 			}
 		}
 
+		if (no_fallback) {
+			int local_nid;
+
+			/*
+			 * If moving to a remote node, retry but allow
+			 * fragmenting fallbacks. Locality is more important
+			 * than fragmentation avoidance.
+			 *
+			 */
+			local_nid = zone_to_nid(ac->preferred_zoneref->zone);
+			if (zone_to_nid(zone) != local_nid) {
+				alloc_flags &= ~ALLOC_NOFRAGMENT;
+				goto retry;
+			}
+		}
+
 		mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
 		if (!zone_watermark_fast(zone, order, mark,
 				       ac_classzone_idx(ac), alloc_flags)) {
@@ -3363,6 +3427,15 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 		}
 	}
 
+	/*
+	 * It's possible on a UMA machine to get through all zones that are
+	 * fragmented. If avoiding fragmentation, reset and try again
+	 */
+	if (no_fallback) {
+		alloc_flags &= ~ALLOC_NOFRAGMENT;
+		goto retry;
+	}
+
 	return NULL;
 }
 
@@ -4366,6 +4439,12 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
 
 	finalise_ac(gfp_mask, &ac);
 
+	/*
+	 * Forbid the first pass from falling back to types that fragment
+	 * memory until all local zones are considered.
+	 */
+	alloc_flags |= alloc_flags_nofragment(ac.preferred_zoneref->zone);
+
 	/* First allocation attempt */
 	page = get_page_from_freelist(alloc_mask, order, alloc_flags, &ac);
 	if (likely(page))
-- 
2.16.4
