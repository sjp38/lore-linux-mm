Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A2ADA6B2CF6
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 06:45:32 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id m19so5672027edc.6
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 03:45:32 -0800 (PST)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id g15-v6si5731764ejj.234.2018.11.23.03.45.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 03:45:29 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 6E3C61C2CDC
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 11:45:29 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 1/5] mm, page_alloc: Spread allocations across zones before introducing fragmentation
Date: Fri, 23 Nov 2018 11:45:24 +0000
Message-Id: <20181123114528.28802-2-mgorman@techsingularity.net>
In-Reply-To: <20181123114528.28802-1-mgorman@techsingularity.net>
References: <20181123114528.28802-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

The page allocator zone lists are iterated based on the watermarks
of each zone which does not take anti-fragmentation into account. On
x86, node 0 may have multiple zones while other nodes have one zone. A
consequence is that tasks running on node 0 may fragment ZONE_NORMAL even
though ZONE_DMA32 has plenty of free memory. This patch special cases
the allocator fast path such that it'll try an allocation from a lower
local zone before fragmenting a higher zone. In this case, stealing of
pageblocks or orders larger than a pageblock are still allowed in the
fast path as they are uninteresting from a fragmentation point of view.

This was evaluated using a benchmark designed to fragment memory before
attempting THP allocations. It's implemented in mmtests as the following
configurations

configs/config-global-dhp__workload_thpfioscale
configs/config-global-dhp__workload_thpfioscale-defrag
configs/config-global-dhp__workload_thpfioscale-madvhugepage

e.g. from mmtests
./run-mmtests.sh --run-monitor --config configs/config-global-dhp__workload_thpfioscale test-run-1

The broad details of the workload are as follows;

1. Create an XFS filesystem (not specified in the configuration but done
   as part of the testing for this patch).
2. Start 4 fio threads that write a number of 64K files inefficiently.
   Inefficiently means that files are created on first access and not
   created in advance (fio parameter create_on_open=1) and fallocate
   is not used (fallocate=none). With multiple IO issuers this creates
   a mix of slab and page cache allocations over time. The total size
   of the files is 150% physical memory so that the slabs and page cache
   pages get mixed.
3. Warm up a number of fio read-only processes accessing the same files
   created in step 2. This part runs for the same length of time it
   took to create the files. It'll refault old data and further
   interleave slab and page cache allocations. As it's now low on
   memory due to step 2, fragmentation occurs as pageblocks get
   stolen.
4. While step 3 is still running, start a process that tries to allocate
   75% of memory as huge pages with a number of threads. The number of
   threads is based on a (NR_CPUS_SOCKET - NR_FIO_THREADS)/4 to avoid THP
   threads contending with fio, any other threads or forcing cross-NUMA
   scheduling. Note that the test has not been used on a machine with less
   than 8 cores. The benchmark records whether huge pages were allocated
   and what the fault latency was in microseconds.
5. Measure the number of events potentially causing external fragmentation,
   the fault latency and the huge page allocation success rate.
6. Cleanup the test files.

Note that due to the use of IO and page cache that this benchmark is not
suitable for running on large machines where the time to fragment memory
may be excessive. Also note that while this is one mix that generates
fragmentation that it's not the only mix that generates fragmentation.
Differences in workload that are more slab-intensive or whether SLUB is
used with high-order pages may yield different results.

When the page allocator fragments memory, it records the event using the
mm_page_alloc_extfrag ftrace event. If the fallback_order is smaller than
a pageblock order (order-9 on 64-bit x86) then it's considered to be an
"external fragmentation event" that may cause issues in the future. Hence,
the primary metric here is the number of external fragmentation events that
occur with order < 9. The secondary metric is allocation latency and huge
page allocation success rates but note that differences in latencies and
what the success rate also can affect the number of external fragmentation
event which is why it's a secondary metric.

1-socket Skylake machine
config-global-dhp__workload_thpfioscale XFS (no special madvise)
4 fio threads, 1 THP allocating thread
--------------------------------------

4.20-rc3 extfrag events < order 9:   804694
4.20-rc3+patch:                      408912 (49% reduction)

thpfioscale Fault Latencies
                                   4.20.0-rc3             4.20.0-rc3
                                      vanilla           lowzone-v5r8
Amean     fault-base-1      662.92 (   0.00%)      653.58 *   1.41%*
Amean     fault-huge-1        0.00 (   0.00%)        0.00 (   0.00%)

                              4.20.0-rc3             4.20.0-rc3
                                 vanilla           lowzone-v5r8
Percentage huge-1        0.00 (   0.00%)        0.00 (   0.00%)

Fault latencies are slightly reduced while allocation success rates remain
at zero as this configuration does not make any special effort to allocate
THP and fio is heavily active at the time and either filling memory or
keeping pages resident. However, a 49% reduction of serious fragmentation
events reduces the changes of external fragmentation being a problem in
the future.

Vlastimil asked during review for a breakdown of the allocation types
that are falling back.

vanilla
   3816 MIGRATE_UNMOVABLE
 800845 MIGRATE_MOVABLE
     33 MIGRATE_UNRECLAIMABLE

patch
    735 MIGRATE_UNMOVABLE
 408135 MIGRATE_MOVABLE
     42 MIGRATE_UNRECLAIMABLE

The majority of the fallbacks are due to movable allocations and this is
consistent for the workload throughout the series so will not be presented
again as the primary source of fallbacks are movable allocations.

Movable fallbacks are sometimes considered "ok" to fallback because they can
be migrated. The problem is that they can fill an unmovable/reclaimable
pageblock causing those allocations to fallback later and polluting
pageblocks with pages that cannot move.  If there is a movable fallback,
it is pretty much guaranteed to affect an unmovable/reclaimable pageblock
and while it might not be enough to actually cause a unmovable/reclaimable
fallback in the future, we cannot know that in advance so the patch takes
the only option available to it. Hence, it's important to control them. This
point is also consistent throughout the series and will not be repeated.

1-socket Skylake machine
global-dhp__workload_thpfioscale-madvhugepage-xfs (MADV_HUGEPAGE)
-----------------------------------------------------------------

4.20-rc3 extfrag events < order 9:  291392
4.20-rc3+patch:                     191187 (34% reduction)

thpfioscale Fault Latencies
                                   4.20.0-rc3             4.20.0-rc3
                                      vanilla           lowzone-v5r8
Amean     fault-base-1     1495.14 (   0.00%)     1467.55 (   1.85%)
Amean     fault-huge-1     1098.48 (   0.00%)     1127.11 (  -2.61%)

thpfioscale Percentage Faults Huge
                              4.20.0-rc3             4.20.0-rc3
                                 vanilla           lowzone-v5r8
Percentage huge-1       78.57 (   0.00%)       77.64 (  -1.18%)

Fragmentation events were reduced quite a bit although this is known
to be a little variable. The latencies and allocation success rates
are similar but they were already quite high.

2-socket Haswell machine
config-global-dhp__workload_thpfioscale XFS (no special madvise)
4 fio threads, 5 THP allocating threads
----------------------------------------------------------------

4.20-rc3 extfrag events < order 9:  215698
4.20-rc3+patch:                     200210 (7% reduction)

thpfioscale Fault Latencies
                                   4.20.0-rc3             4.20.0-rc3
                                      vanilla           lowzone-v5r8
Amean     fault-base-5     1350.05 (   0.00%)     1346.45 (   0.27%)
Amean     fault-huge-5     4181.01 (   0.00%)     3418.60 (  18.24%)

                              4.20.0-rc3             4.20.0-rc3
                                 vanilla           lowzone-v5r8
Percentage huge-5        1.15 (   0.00%)        0.78 ( -31.88%)

The reduction of external fragmentation events is slight and this is
partially due to the removal of __GFP_THISNODE in commit ac5b2c18911f ("mm:
thp: relax __GFP_THISNODE for MADV_HUGEPAGE mappings") as THP allocations
can now spill over to remote nodes instead of fragmenting local memory.

2-socket Haswell machine
global-dhp__workload_thpfioscale-madvhugepage-xfs (MADV_HUGEPAGE)
-----------------------------------------------------------------

4.20-rc3 extfrag events < order 9: 166352
4.20-rc3+patch:                    147463 (11% reduction)

thpfioscale Fault Latencies
                                   4.20.0-rc3             4.20.0-rc3
                                      vanilla           lowzone-v5r8
Amean     fault-base-5     6138.97 (   0.00%)     6217.43 (  -1.28%)
Amean     fault-huge-5     2294.28 (   0.00%)     3163.33 * -37.88%*

thpfioscale Percentage Faults Huge
                              4.20.0-rc3             4.20.0-rc3
                                 vanilla           lowzone-v5r8
Percentage huge-5       96.82 (   0.00%)       95.14 (  -1.74%)

There was a slight reduction in external fragmentation events although
the latencies were higher. The allocation success rate is high enough that
the system is struggling and there is quite a lot of parallel reclaim and
compaction activity. There is also a certain degree of luck on whether
processes start on node 0 or not for this patch but the relevance is
reduced later in the series.

Overall, the patch reduces the number of external fragmentation causing
events so the success of THP over long periods of time would be improved
for this adverse workload.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/internal.h   |  13 ++++---
 mm/page_alloc.c | 108 +++++++++++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 105 insertions(+), 16 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 291eb2b6d1d8..544355156c92 100644
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
index 6847177dc4a1..f86638aee96a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2375,20 +2375,30 @@ static bool unreserve_highatomic_pageblock(const struct alloc_context *ac,
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
+	 * i.e. orders < pageblock_order. If there are no local zones free,
+	 * the zonelists will be reiterated without ALLOC_NOFRAGMENT.
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
@@ -2447,7 +2457,8 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
  * Call me with the zone->lock already held.
  */
 static __always_inline struct page *
-__rmqueue(struct zone *zone, unsigned int order, int migratetype)
+__rmqueue(struct zone *zone, unsigned int order, int migratetype,
+						unsigned int alloc_flags)
 {
 	struct page *page;
 
@@ -2457,7 +2468,8 @@ __rmqueue(struct zone *zone, unsigned int order, int migratetype)
 		if (migratetype == MIGRATE_MOVABLE)
 			page = __rmqueue_cma_fallback(zone, order);
 
-		if (!page && __rmqueue_fallback(zone, order, migratetype))
+		if (!page && __rmqueue_fallback(zone, order, migratetype,
+								alloc_flags))
 			goto retry;
 	}
 
@@ -2472,13 +2484,14 @@ __rmqueue(struct zone *zone, unsigned int order, int migratetype)
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
 
@@ -2934,6 +2947,7 @@ static inline void zone_statistics(struct zone *preferred_zone, struct zone *z)
 
 /* Remove page from the per-cpu list, caller must protect the list */
 static struct page *__rmqueue_pcplist(struct zone *zone, int migratetype,
+			unsigned int alloc_flags,
 			struct per_cpu_pages *pcp,
 			struct list_head *list)
 {
@@ -2943,7 +2957,7 @@ static struct page *__rmqueue_pcplist(struct zone *zone, int migratetype,
 		if (list_empty(list)) {
 			pcp->count += rmqueue_bulk(zone, 0,
 					pcp->batch, list,
-					migratetype);
+					migratetype, alloc_flags);
 			if (unlikely(list_empty(list)))
 				return NULL;
 		}
@@ -2959,7 +2973,8 @@ static struct page *__rmqueue_pcplist(struct zone *zone, int migratetype,
 /* Lock and remove page from the per-cpu list */
 static struct page *rmqueue_pcplist(struct zone *preferred_zone,
 			struct zone *zone, unsigned int order,
-			gfp_t gfp_flags, int migratetype)
+			gfp_t gfp_flags, int migratetype,
+			unsigned int alloc_flags)
 {
 	struct per_cpu_pages *pcp;
 	struct list_head *list;
@@ -2969,7 +2984,7 @@ static struct page *rmqueue_pcplist(struct zone *preferred_zone,
 	local_irq_save(flags);
 	pcp = &this_cpu_ptr(zone->pageset)->pcp;
 	list = &pcp->lists[migratetype];
-	page = __rmqueue_pcplist(zone,  migratetype, pcp, list);
+	page = __rmqueue_pcplist(zone,  migratetype, alloc_flags, pcp, list);
 	if (page) {
 		__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);
 		zone_statistics(preferred_zone, zone);
@@ -2992,7 +3007,7 @@ struct page *rmqueue(struct zone *preferred_zone,
 
 	if (likely(order == 0)) {
 		page = rmqueue_pcplist(preferred_zone, zone, order,
-				gfp_flags, migratetype);
+				gfp_flags, migratetype, alloc_flags);
 		goto out;
 	}
 
@@ -3011,7 +3026,7 @@ struct page *rmqueue(struct zone *preferred_zone,
 				trace_mm_page_alloc_zone_locked(page, order, migratetype);
 		}
 		if (!page)
-			page = __rmqueue(zone, order, migratetype);
+			page = __rmqueue(zone, order, migratetype, alloc_flags);
 	} while (page && check_new_pages(page, order));
 	spin_unlock(&zone->lock);
 	if (!page)
@@ -3253,6 +3268,40 @@ static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
 }
 #endif	/* CONFIG_NUMA */
 
+#ifdef CONFIG_ZONE_DMA32
+/*
+ * The restriction on ZONE_DMA32 as being a suitable zone to use to avoid
+ * fragmentation is subtle. If the preferred zone was HIGHMEM then
+ * premature use of a lower zone may cause lowmem pressure problems that
+ * are worse than fragmentation. If the next zone is ZONE_DMA then it is
+ * probably too small. It only makes sense to spread allocations to avoid
+ * fragmentation between the Normal and DMA32 zones.
+ */
+static inline unsigned int
+alloc_flags_nofragment(struct zone *zone)
+{
+	if (zone_idx(zone) != ZONE_NORMAL)
+		return 0;
+
+	/*
+	 * If ZONE_DMA32 exists, assume it is the one after ZONE_NORMAL and
+	 * the pointer is within zone->zone_pgdat->node_zones[]. Also assume
+	 * on UMA that if Normal is populated then so is DMA32.
+	 */
+	BUILD_BUG_ON(ZONE_NORMAL - ZONE_DMA32 != 1);
+	if (nr_online_nodes > 1 && !populated_zone(--zone))
+		return 0;
+
+	return ALLOC_NOFRAGMENT;
+}
+#else
+static inline unsigned int
+alloc_flags_nofragment(struct zone *zone)
+{
+	return 0;
+}
+#endif
+
 /*
  * get_page_from_freelist goes through the zonelist trying to allocate
  * a page.
@@ -3261,14 +3310,18 @@ static struct page *
 get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 						const struct alloc_context *ac)
 {
-	struct zoneref *z = ac->preferred_zoneref;
+	struct zoneref *z;
 	struct zone *zone;
 	struct pglist_data *last_pgdat_dirty_limit = NULL;
+	bool no_fallback;
 
+retry:
 	/*
 	 * Scan zonelist, looking for a zone with enough free.
 	 * See also __cpuset_node_allowed() comment in kernel/cpuset.c.
 	 */
+	no_fallback = alloc_flags & ALLOC_NOFRAGMENT;
+	z = ac->preferred_zoneref;
 	for_next_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx,
 								ac->nodemask) {
 		struct page *page;
@@ -3307,6 +3360,22 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 			}
 		}
 
+		if (no_fallback && nr_online_nodes > 1 &&
+		    zone != ac->preferred_zoneref->zone) {
+			int local_nid;
+
+			/*
+			 * If moving to a remote node, retry but allow
+			 * fragmenting fallbacks. Locality is more important
+			 * than fragmentation avoidance.
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
@@ -3374,6 +3443,15 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 		}
 	}
 
+	/*
+	 * It's possible on a UMA machine to get through all zones that are
+	 * fragmented. If avoiding fragmentation, reset and try again.
+	 */
+	if (no_fallback) {
+		alloc_flags &= ~ALLOC_NOFRAGMENT;
+		goto retry;
+	}
+
 	return NULL;
 }
 
@@ -4369,6 +4447,12 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
 
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
