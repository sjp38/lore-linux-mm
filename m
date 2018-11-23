Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D97166B2CFD
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 06:45:33 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id w15so5664180edl.21
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 03:45:33 -0800 (PST)
Received: from outbound-smtp13.blacknight.com (outbound-smtp13.blacknight.com. [46.22.139.230])
        by mx.google.com with ESMTPS id q23si7992209eds.78.2018.11.23.03.45.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 03:45:30 -0800 (PST)
Received: from mail.blacknight.com (unknown [81.17.254.17])
	by outbound-smtp13.blacknight.com (Postfix) with ESMTPS id 0A9C01C2CF3
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 11:45:30 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 4/5] mm: Reclaim small amounts of memory when an external fragmentation event occurs
Date: Fri, 23 Nov 2018 11:45:27 +0000
Message-Id: <20181123114528.28802-5-mgorman@techsingularity.net>
In-Reply-To: <20181123114528.28802-1-mgorman@techsingularity.net>
References: <20181123114528.28802-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

An external fragmentation event was previously described as

    When the page allocator fragments memory, it records the event using
    the mm_page_alloc_extfrag event. If the fallback_order is smaller
    than a pageblock order (order-9 on 64-bit x86) then it's considered
    an event that will cause external fragmentation issues in the future.

The kernel reduces the probability of such events by increasing the
watermark sizes by calling set_recommended_min_free_kbytes early in the
lifetime of the system. This works reasonably well in general but if there
are enough sparsely populated pageblocks then the problem can still occur
as enough memory is free overall and kswapd stays asleep.

This patch introduces a watermark_boost_factor sysctl that allows a zone
watermark to be temporarily boosted when an external fragmentation causing
events occurs. The boosting will stall allocations that would decrease
free memory below the boosted low watermark and kswapd is woken if the
calling context allows to reclaim an amount of memory relative to the
size of the high watermark and the watermark_boost_factor until the boost
is cleared. When kswapd finishes, it wakes kcompactd at the pageblock
order to clean some of the pageblocks that may have been affected by
the fragmentation event. kswapd avoids any writeback, slab shrinkage and
swap from reclaim context during this operation to avoid excessive system
disruption in the name of fragmentation avoidance. Care is taken so that
kswapd will do normal reclaim work if the system is really low on memory.

This was evaluated using the same workloads as "mm, page_alloc: Spread
allocations across zones before introducing fragmentation".

1-socket Skylake machine
config-global-dhp__workload_thpfioscale XFS (no special madvise)
4 fio threads, 1 THP allocating thread
--------------------------------------

4.20-rc3 extfrag events < order 9:   804694
4.20-rc3+patch:                      408912 (49% reduction)
4.20-rc3+patch1-4:                    18421 (98% reduction)

                                   4.20.0-rc3             4.20.0-rc3
                                 lowzone-v5r8             boost-v5r8
Amean     fault-base-1      653.58 (   0.00%)      652.71 (   0.13%)
Amean     fault-huge-1        0.00 (   0.00%)      178.93 * -99.00%*

                              4.20.0-rc3             4.20.0-rc3
                            lowzone-v5r8             boost-v5r8
Percentage huge-1        0.00 (   0.00%)        5.12 ( 100.00%)

Note that external fragmentation causing events are massively reduced
by this path whether in comparison to the previous kernel or the vanilla
kernel. The fault latency for huge pages appears to be increased but that
is only because THP allocations were successful with the patch applied.

1-socket Skylake machine
global-dhp__workload_thpfioscale-madvhugepage-xfs (MADV_HUGEPAGE)
-----------------------------------------------------------------

4.20-rc3 extfrag events < order 9:  291392
4.20-rc3+patch:                     191187 (34% reduction)
4.20-rc3+patch1-4:                   13464 (95% reduction)

thpfioscale Fault Latencies
                                   4.20.0-rc3             4.20.0-rc3
                                 lowzone-v5r8             boost-v5r8
Min       fault-base-1      912.00 (   0.00%)      905.00 (   0.77%)
Min       fault-huge-1      127.00 (   0.00%)      135.00 (  -6.30%)
Amean     fault-base-1     1467.55 (   0.00%)     1481.67 (  -0.96%)
Amean     fault-huge-1     1127.11 (   0.00%)     1063.88 *   5.61%*

                              4.20.0-rc3             4.20.0-rc3
                            lowzone-v5r8             boost-v5r8
Percentage huge-1       77.64 (   0.00%)       83.46 (   7.49%)

As before, massive reduction in external fragmentation events, some jitter
on latencies and an increase in THP allocation success rates.

2-socket Haswell machine
config-global-dhp__workload_thpfioscale XFS (no special madvise)
4 fio threads, 5 THP allocating threads
----------------------------------------------------------------

4.20-rc3 extfrag events < order 9:  215698
4.20-rc3+patch:                     200210 (7% reduction)
4.20-rc3+patch1-4:                   14263 (93% reduction)

                                   4.20.0-rc3             4.20.0-rc3
                                 lowzone-v5r8             boost-v5r8
Amean     fault-base-5     1346.45 (   0.00%)     1306.87 (   2.94%)
Amean     fault-huge-5     3418.60 (   0.00%)     1348.94 (  60.54%)

                              4.20.0-rc3             4.20.0-rc3
                            lowzone-v5r8             boost-v5r8
Percentage huge-5        0.78 (   0.00%)        7.91 ( 910.64%)

There is a 93% reduction in fragmentation causing events, there
is a big reduction in the huge page fault latency and allocation
success rate is higher.

2-socket Haswell machine
global-dhp__workload_thpfioscale-madvhugepage-xfs (MADV_HUGEPAGE)
-----------------------------------------------------------------

4.20-rc3 extfrag events < order 9: 166352
4.20-rc3+patch:                    147463 (11% reduction)
4.20-rc3+patch1-4:                  11095 (93% reduction)

thpfioscale Fault Latencies
                                   4.20.0-rc3             4.20.0-rc3
                                 lowzone-v5r8             boost-v5r8
Amean     fault-base-5     6217.43 (   0.00%)     7419.67 * -19.34%*
Amean     fault-huge-5     3163.33 (   0.00%)     3263.80 (  -3.18%)

                              4.20.0-rc3             4.20.0-rc3
                            lowzone-v5r8             boost-v5r8
Percentage huge-5       95.14 (   0.00%)       87.98 (  -7.53%)

There is a large reduction in fragmentation events with some jitter around
the latencies and success rates. As before, the high THP allocation
success rate does mean the system is under a lot of pressure. However,
as the fragmentation events are reduced, it would be expected that the
long-term allocation success rate would be higher.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 Documentation/sysctl/vm.txt |  21 +++++++
 include/linux/mm.h          |   1 +
 include/linux/mmzone.h      |  11 ++--
 kernel/sysctl.c             |   8 +++
 mm/page_alloc.c             |  43 +++++++++++++-
 mm/vmscan.c                 | 133 +++++++++++++++++++++++++++++++++++++++++---
 6 files changed, 202 insertions(+), 15 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 7d73882e2c27..187ce4f599a2 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -63,6 +63,7 @@ files can be found in mm/swap.c.
 - swappiness
 - user_reserve_kbytes
 - vfs_cache_pressure
+- watermark_boost_factor
 - watermark_scale_factor
 - zone_reclaim_mode
 
@@ -856,6 +857,26 @@ ten times more freeable objects than there are.
 
 =============================================================
 
+watermark_boost_factor:
+
+This factor controls the level of reclaim when memory is being fragmented.
+It defines the percentage of the high watermark of a zone that will be
+reclaimed if pages of different mobility are being mixed within pageblocks.
+The intent is that compaction has less work to do in the future and to
+increase the success rate of future high-order allocations such as SLUB
+allocations, THP and hugetlbfs pages.
+
+To make it sensible with respect to the watermark_scale_factor parameter,
+the unit is in fractions of 10,000. The default value of 15,000 means
+that up to 150% of the high watermark will be reclaimed in the event of
+a pageblock being mixed due to fragmentation. The level of reclaim is
+determined by the number of fragmentation events that occurred in the
+recent past. If this value is smaller than a pageblock then a pageblocks
+worth of pages will be reclaimed (e.g.  2MB on 64-bit x86). A boost factor
+of 0 will disable the feature.
+
+=============================================================
+
 watermark_scale_factor:
 
 This factor controls the aggressiveness of kswapd. It defines the
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5411de93a363..2c4c69508413 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2202,6 +2202,7 @@ extern void zone_pcp_reset(struct zone *zone);
 
 /* page_alloc.c */
 extern int min_free_kbytes;
+extern int watermark_boost_factor;
 extern int watermark_scale_factor;
 
 /* nommu.c */
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index e43e8e79db99..d352c1dab486 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -269,10 +269,10 @@ enum zone_watermarks {
 	NR_WMARK
 };
 
-#define min_wmark_pages(z) (z->_watermark[WMARK_MIN])
-#define low_wmark_pages(z) (z->_watermark[WMARK_LOW])
-#define high_wmark_pages(z) (z->_watermark[WMARK_HIGH])
-#define wmark_pages(z, i) (z->_watermark[i])
+#define min_wmark_pages(z) (z->_watermark[WMARK_MIN] + z->watermark_boost)
+#define low_wmark_pages(z) (z->_watermark[WMARK_LOW] + z->watermark_boost)
+#define high_wmark_pages(z) (z->_watermark[WMARK_HIGH] + z->watermark_boost)
+#define wmark_pages(z, i) (z->_watermark[i] + z->watermark_boost)
 
 struct per_cpu_pages {
 	int count;		/* number of pages in the list */
@@ -364,6 +364,7 @@ struct zone {
 
 	/* zone watermarks, access with *_wmark_pages(zone) macros */
 	unsigned long _watermark[NR_WMARK];
+	unsigned long watermark_boost;
 
 	unsigned long nr_reserved_highatomic;
 
@@ -885,6 +886,8 @@ static inline int is_highmem(struct zone *zone)
 struct ctl_table;
 int min_free_kbytes_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
+int watermark_boost_factor_sysctl_handler(struct ctl_table *, int,
+					void __user *, size_t *, loff_t *);
 int watermark_scale_factor_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
 extern int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES];
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 5fc724e4e454..1825f712e73b 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1462,6 +1462,14 @@ static struct ctl_table vm_table[] = {
 		.proc_handler	= min_free_kbytes_sysctl_handler,
 		.extra1		= &zero,
 	},
+	{
+		.procname	= "watermark_boost_factor",
+		.data		= &watermark_boost_factor,
+		.maxlen		= sizeof(watermark_boost_factor),
+		.mode		= 0644,
+		.proc_handler	= watermark_boost_factor_sysctl_handler,
+		.extra1		= &zero,
+	},
 	{
 		.procname	= "watermark_scale_factor",
 		.data		= &watermark_scale_factor,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e44eb68744ed..f9af2a79b1cd 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -263,6 +263,7 @@ compound_page_dtor * const compound_page_dtors[] = {
 
 int min_free_kbytes = 1024;
 int user_min_free_kbytes = -1;
+int watermark_boost_factor __read_mostly = 15000;
 int watermark_scale_factor = 10;
 
 static unsigned long nr_kernel_pages __meminitdata;
@@ -2129,6 +2130,21 @@ static bool can_steal_fallback(unsigned int order, int start_mt)
 	return false;
 }
 
+static inline void boost_watermark(struct zone *zone)
+{
+	unsigned long max_boost;
+
+	if (!watermark_boost_factor)
+		return;
+
+	max_boost = mult_frac(zone->_watermark[WMARK_HIGH],
+			watermark_boost_factor, 10000);
+	max_boost = max(pageblock_nr_pages, max_boost);
+
+	zone->watermark_boost = min(zone->watermark_boost + pageblock_nr_pages,
+		max_boost);
+}
+
 /*
  * This function implements actual steal behaviour. If order is large enough,
  * we can steal whole pageblock. If not, we first move freepages in this
@@ -2138,7 +2154,7 @@ static bool can_steal_fallback(unsigned int order, int start_mt)
  * itself, so pages freed in the future will be put on the correct free list.
  */
 static void steal_suitable_fallback(struct zone *zone, struct page *page,
-					int start_type, bool whole_block)
+		unsigned int alloc_flags, int start_type, bool whole_block)
 {
 	unsigned int current_order = page_order(page);
 	struct free_area *area;
@@ -2160,6 +2176,15 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
 		goto single_page;
 	}
 
+	/*
+	 * Boost watermarks to increase reclaim pressure to reduce the
+	 * likelihood of future fallbacks. Wake kswapd now as the node
+	 * may be balanced overall and kswapd will not wake naturally.
+	 */
+	boost_watermark(zone);
+	if (alloc_flags & ALLOC_KSWAPD)
+		wakeup_kswapd(zone, 0, 0, zone_idx(zone));
+
 	/* We are not allowed to try stealing from the whole block */
 	if (!whole_block)
 		goto single_page;
@@ -2443,7 +2468,8 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype,
 	page = list_first_entry(&area->free_list[fallback_mt],
 							struct page, lru);
 
-	steal_suitable_fallback(zone, page, start_migratetype, can_steal);
+	steal_suitable_fallback(zone, page, alloc_flags, start_migratetype,
+								can_steal);
 
 	trace_mm_page_alloc_extfrag(page, order, current_order,
 		start_migratetype, fallback_mt);
@@ -7451,6 +7477,7 @@ static void __setup_per_zone_wmarks(void)
 
 		zone->_watermark[WMARK_LOW]  = min_wmark_pages(zone) + tmp;
 		zone->_watermark[WMARK_HIGH] = min_wmark_pages(zone) + tmp * 2;
+		zone->watermark_boost = 0;
 
 		spin_unlock_irqrestore(&zone->lock, flags);
 	}
@@ -7551,6 +7578,18 @@ int min_free_kbytes_sysctl_handler(struct ctl_table *table, int write,
 	return 0;
 }
 
+int watermark_boost_factor_sysctl_handler(struct ctl_table *table, int write,
+	void __user *buffer, size_t *length, loff_t *ppos)
+{
+	int rc;
+
+	rc = proc_dointvec_minmax(table, write, buffer, length, ppos);
+	if (rc)
+		return rc;
+
+	return 0;
+}
+
 int watermark_scale_factor_sysctl_handler(struct ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
 {
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 62ac0c488624..4c96b6356398 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -87,6 +87,9 @@ struct scan_control {
 	/* Can pages be swapped as part of reclaim? */
 	unsigned int may_swap:1;
 
+	/* e.g. boosted watermark reclaim leaves slabs alone */
+	unsigned int may_shrinkslab:1;
+
 	/*
 	 * Cgroups are not reclaimed below their configured memory.low,
 	 * unless we threaten to OOM. If any cgroups are skipped due to
@@ -2755,8 +2758,10 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 			shrink_node_memcg(pgdat, memcg, sc, &lru_pages);
 			node_lru_pages += lru_pages;
 
-			shrink_slab(sc->gfp_mask, pgdat->node_id,
+			if (sc->may_shrinkslab) {
+				shrink_slab(sc->gfp_mask, pgdat->node_id,
 				    memcg, sc->priority);
+			}
 
 			/* Record the group's reclaim efficiency */
 			vmpressure(sc->gfp_mask, memcg, false,
@@ -3238,6 +3243,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 		.may_writepage = !laptop_mode,
 		.may_unmap = 1,
 		.may_swap = 1,
+		.may_shrinkslab = 1,
 	};
 
 	/*
@@ -3282,6 +3288,7 @@ unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
 		.may_unmap = 1,
 		.reclaim_idx = MAX_NR_ZONES - 1,
 		.may_swap = !noswap,
+		.may_shrinkslab = 1,
 	};
 	unsigned long lru_pages;
 
@@ -3328,6 +3335,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 		.may_writepage = !laptop_mode,
 		.may_unmap = 1,
 		.may_swap = may_swap,
+		.may_shrinkslab = 1,
 	};
 
 	/*
@@ -3378,6 +3386,30 @@ static void age_active_anon(struct pglist_data *pgdat,
 	} while (memcg);
 }
 
+static bool pgdat_watermark_boosted(pg_data_t *pgdat, int classzone_idx)
+{
+	int i;
+	struct zone *zone;
+
+	/*
+	 * Check for watermark boosts top-down as the higher zones
+	 * are more likely to be boosted. Both watermarks and boosts
+	 * should not be checked at the time time as reclaim would
+	 * start prematurely when there is no boosting and a lower
+	 * zone is balanced.
+	 */
+	for (i = classzone_idx; i >= 0; i--) {
+		zone = pgdat->node_zones + i;
+		if (!managed_zone(zone))
+			continue;
+
+		if (zone->watermark_boost)
+			return true;
+	}
+
+	return false;
+}
+
 /*
  * Returns true if there is an eligible zone balanced for the request order
  * and classzone_idx
@@ -3388,6 +3420,10 @@ static bool pgdat_balanced(pg_data_t *pgdat, int order, int classzone_idx)
 	unsigned long mark = -1;
 	struct zone *zone;
 
+	/*
+	 * Check watermarks bottom-up as lower zones are more likely to
+	 * meet watermarks.
+	 */
 	for (i = 0; i <= classzone_idx; i++) {
 		zone = pgdat->node_zones + i;
 
@@ -3516,14 +3552,14 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 	unsigned long nr_soft_reclaimed;
 	unsigned long nr_soft_scanned;
 	unsigned long pflags;
+	unsigned long nr_boost_reclaim;
+	unsigned long zone_boosts[MAX_NR_ZONES] = { 0, };
+	bool boosted;
 	struct zone *zone;
 	struct scan_control sc = {
 		.gfp_mask = GFP_KERNEL,
 		.order = order,
-		.priority = DEF_PRIORITY,
-		.may_writepage = !laptop_mode,
 		.may_unmap = 1,
-		.may_swap = 1,
 	};
 
 	psi_memstall_enter(&pflags);
@@ -3531,9 +3567,28 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 
 	count_vm_event(PAGEOUTRUN);
 
+	/*
+	 * Account for the reclaim boost. Note that the zone boost is left in
+	 * place so that parallel allocations that are near the watermark will
+	 * stall or direct reclaim until kswapd is finished.
+	 */
+	nr_boost_reclaim = 0;
+	for (i = 0; i <= classzone_idx; i++) {
+		zone = pgdat->node_zones + i;
+		if (!managed_zone(zone))
+			continue;
+
+		nr_boost_reclaim += zone->watermark_boost;
+		zone_boosts[i] = zone->watermark_boost;
+	}
+	boosted = nr_boost_reclaim;
+
+restart:
+	sc.priority = DEF_PRIORITY;
 	do {
 		unsigned long nr_reclaimed = sc.nr_reclaimed;
 		bool raise_priority = true;
+		bool balanced;
 		bool ret;
 
 		sc.reclaim_idx = classzone_idx;
@@ -3560,13 +3615,40 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 		}
 
 		/*
-		 * Only reclaim if there are no eligible zones. Note that
-		 * sc.reclaim_idx is not used as buffer_heads_over_limit may
-		 * have adjusted it.
+		 * If the pgdat is imbalanced then ignore boosting and preserve
+		 * the watermarks for a later time and restart. Note that the
+		 * zone watermarks will be still reset at the end of balancing
+		 * on the grounds that the normal reclaim should be enough to
+		 * re-evaluate if boosting is required when kswapd next wakes.
+		 */
+		balanced = pgdat_balanced(pgdat, sc.order, classzone_idx);
+		if (!balanced && nr_boost_reclaim) {
+			nr_boost_reclaim = 0;
+			goto restart;
+		}
+
+		/*
+		 * If boosting is not active then only reclaim if there are no
+		 * eligible zones. Note that sc.reclaim_idx is not used as
+		 * buffer_heads_over_limit may have adjusted it.
 		 */
-		if (pgdat_balanced(pgdat, sc.order, classzone_idx))
+		if (!nr_boost_reclaim && balanced)
 			goto out;
 
+		/* Limit the priority of boosting to avoid reclaim writeback */
+		if (nr_boost_reclaim && sc.priority == DEF_PRIORITY - 2)
+			raise_priority = false;
+
+		/*
+		 * Do not writeback or swap pages for boosted reclaim. The
+		 * intent is to relieve pressure not issue sub-optimal IO
+		 * from reclaim context. If no pages are reclaimed, the
+		 * reclaim will be aborted.
+		 */
+		sc.may_writepage = !laptop_mode && !nr_boost_reclaim;
+		sc.may_swap = !nr_boost_reclaim;
+		sc.may_shrinkslab = !nr_boost_reclaim;
+
 		/*
 		 * Do some background aging of the anon list, to give
 		 * pages a chance to be referenced before reclaiming. All
@@ -3618,6 +3700,16 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 		 * progress in reclaiming pages
 		 */
 		nr_reclaimed = sc.nr_reclaimed - nr_reclaimed;
+		nr_boost_reclaim -= min(nr_boost_reclaim, nr_reclaimed);
+
+		/*
+		 * If reclaim made no progress for a boost, stop reclaim as
+		 * IO cannot be queued and it could be an infinite loop in
+		 * extreme circumstances.
+		 */
+		if (nr_boost_reclaim && !nr_reclaimed)
+			break;
+
 		if (raise_priority || !nr_reclaimed)
 			sc.priority--;
 	} while (sc.priority >= 1);
@@ -3626,6 +3718,28 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 		pgdat->kswapd_failures++;
 
 out:
+	/* If reclaim was boosted, account for the reclaim done in this pass */
+	if (boosted) {
+		unsigned long flags;
+
+		for (i = 0; i <= classzone_idx; i++) {
+			if (!zone_boosts[i])
+				continue;
+
+			/* Increments are under the zone lock */
+			zone = pgdat->node_zones + i;
+			spin_lock_irqsave(&zone->lock, flags);
+			zone->watermark_boost -= min(zone->watermark_boost, zone_boosts[i]);
+			spin_unlock_irqrestore(&zone->lock, flags);
+		}
+
+		/*
+		 * As there is now likely space, wakeup kcompact to defragment
+		 * pageblocks.
+		 */
+		wakeup_kcompactd(pgdat, pageblock_order, classzone_idx);
+	}
+
 	snapshot_refaults(NULL, pgdat);
 	__fs_reclaim_release();
 	psi_memstall_leave(&pflags);
@@ -3854,7 +3968,8 @@ void wakeup_kswapd(struct zone *zone, gfp_t gfp_flags, int order,
 
 	/* Hopeless node, leave it to direct reclaim if possible */
 	if (pgdat->kswapd_failures >= MAX_RECLAIM_RETRIES ||
-	    pgdat_balanced(pgdat, order, classzone_idx)) {
+	    (pgdat_balanced(pgdat, order, classzone_idx) &&
+	     !pgdat_watermark_boosted(pgdat, classzone_idx))) {
 		/*
 		 * There may be plenty of free memory available, but it's too
 		 * fragmented for high-order allocations.  Wake up kcompactd
-- 
2.16.4
