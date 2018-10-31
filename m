Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E02C26B026C
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 12:06:49 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id x44-v6so10727529edd.17
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 09:06:49 -0700 (PDT)
Received: from outbound-smtp26.blacknight.com (outbound-smtp26.blacknight.com. [81.17.249.194])
        by mx.google.com with ESMTPS id p14-v6si3143228edi.343.2018.10.31.09.06.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 Oct 2018 09:06:47 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp26.blacknight.com (Postfix) with ESMTPS id B6EF1B88F8
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 16:06:46 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 3/5] mm: Reclaim small amounts of memory when an external fragmentation event occurs
Date: Wed, 31 Oct 2018 16:06:43 +0000
Message-Id: <20181031160645.7633-4-mgorman@techsingularity.net>
In-Reply-To: <20181031160645.7633-1-mgorman@techsingularity.net>
References: <20181031160645.7633-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

An external fragmentation event was previously described as

    When the page allocator fragments memory, it records the event using
    the mm_page_alloc_extfrag event. If the fallback_order is smaller
    than a pageblock order (order-9 on 64-bit x86) then it's considered
    an event that will cause external fragmentation issues in the future.

The kernel reduces the probability of such events by increasing the
watermark sizes by calling set_recommended_min_free_kbytes early in the
lifetime of the system. This works reasonably well in general but if there
is enough sparsely populated pageblocks then the problem can still occur
as enough memory is free overall and kswapd stays asleep.

This patch introduces a watermark_boost_factor sysctl that allows a zone
watermark to be temporarily boosted when an external fragmentation causing
events occurs. The boosting will stall allocations below the boosted low
watermark and kswapd is woken unconditionally to reclaim an amount of
memory relative to the size of the high watermark and the
watermark_boost_factor until the boost is cleared. When kswapd finishes,
it wakes kcompactd at the pageblock order to clean some of the pageblocks
that may have been affected by the fragmentation event. kswapd avoids
any writeback or swap from reclaim context during this operation to avoid
excessive system disruption in the name of fragmentation avoidance. Care
is taken so that kswapd will do normal reclaim work if the system is
really low on memory.

This was evaluated using the same workloads as "mm, page_alloc: Spread
allocations across zones before introducing fragmentation".

1-socket Skylake machine
config-global-dhp__workload_thpfioscale XFS (no special madvise)
4 fio threads, 1 THP allocating thread
--------------------------------------

4.19 extfrag events < order 0:  71227
4.19+patch1:                    36456 (49% reduction)
4.19+patch1-3:                   4510 (94% reduction)

                                       4.19.0                 4.19.0
                                 lowzone-v1r1             boost-v1r5
Amean     fault-base-1      599.92 (   0.00%)      630.44 *  -5.09%*
Amean     fault-huge-1      179.84 (   0.00%)      179.22 (   0.35%)

                                  4.19.0                 4.19.0
                            lowzone-v1r1             boost-v1r5
Percentage huge-1        1.08 (   0.00%)        2.89 ( 168.75%)

Note that external fragmentation causing events are massively reduced
by this path whether in comparison to the previous kernel or the vanilla
kernel. There is some jitter in the fault latencies and they are a bit
more variable but the slight increase in THP allocation success rates
would account for some of that.

1-socket Skylake machine
global-dhp__workload_thpfioscale-madvhugepage-xfs (MADV_HUGEPAGE)
-----------------------------------------------------------------

4.19 extfrag events < order 0:  40761
4.19+patch1:                    36085 (11% reduction)
4.19+patch1-3:                   1887 (95% reduction)

thpfioscale Fault Latencies
                                       4.19.0                 4.19.0
                                 lowzone-v1r1             boost-v1r5
Amean     fault-base-1     1938.47 (   0.00%)     1863.70 *   3.86%*
Amean     fault-huge-1      749.40 (   0.00%)      776.07 *  -3.56%*

thpfioscale Percentage Faults Huge
                                  4.19.0                 4.19.0
                            lowzone-v1r1             boost-v1r5
Percentage huge-1       83.79 (   0.00%)       86.92 (   3.73%)

As before, massive reduction in external fragmentation events, some
jitter on latencies and a slight increase in THP allocation success
rates.

2-socket Haswell machine
config-global-dhp__workload_thpfioscale XFS (no special madvise)
4 fio threads, 5 THP allocating threads
----------------------------------------------------------------

4.19 extfrag events < order 0:  882868
4.19+patch1:                    476937 (46% reduction)
4.19+patch1-3:                   29044 (97% reduction)

                                       4.19.0                 4.19.0
                                 lowzone-v1r1             boost-v1r5
Amean     fault-base-5     1602.01 (   0.00%)     1595.28 (   0.42%)
Amean     fault-huge-5        0.00 (   0.00%)      435.67 * -99.00%*

                                  4.19.0                 4.19.0
                            lowzone-v1r1             boost-v1r5
Percentage huge-5        0.00 (   0.00%)        0.15 ( 100.00%)

This is an illustration of why latencies are not the primary metric.
There is a 97% reduction in fragmentation causing events but the
huge page latencies are much higher because they went from never
succeeding to a small success.

2-socket Haswell machine
global-dhp__workload_thpfioscale-madvhugepage-xfs (MADV_HUGEPAGE)
-----------------------------------------------------------------

4.19 extfrag events < order 0: 803099
4.19+patch1:                   654671 (23% reduction)
4.19+patch1-3:                  24352 (97% reduction)

thpfioscale Fault Latencies
                                       4.19.0                 4.19.0
                                 lowzone-v1r1             boost-v1r5
Amean     fault-base-5     6678.61 (   0.00%)     5935.74 (  11.12%)
Amean     fault-huge-5     2796.35 (   0.00%)     2611.69 (   6.60%)

                                  4.19.0                 4.19.0
                            lowzone-v1r1             boost-v1r5
Percentage huge-5       57.92 (   0.00%)       66.18 (  14.26%)

There is a large reduction in fragmentation events and is reflected
by a higher THP allocation success rate without a negative impact
on fault latencies.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 Documentation/sysctl/vm.txt |  19 +++++++
 include/linux/mm.h          |   1 +
 include/linux/mmzone.h      |  11 ++--
 kernel/sysctl.c             |   8 +++
 mm/page_alloc.c             |  50 +++++++++++++++++-
 mm/vmscan.c                 | 123 ++++++++++++++++++++++++++++++++++++++++----
 6 files changed, 197 insertions(+), 15 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 7d73882e2c27..2244520d7913 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -63,6 +63,7 @@ files can be found in mm/swap.c.
 - swappiness
 - user_reserve_kbytes
 - vfs_cache_pressure
+- watermark_boost_factor
 - watermark_scale_factor
 - zone_reclaim_mode
 
@@ -856,6 +857,24 @@ ten times more freeable objects than there are.
 
 =============================================================
 
+watermark_boost_factor:
+
+This factor controls the level of reclaim when memory is being fragmented.
+It defines the percentage of the low watermark of a zone that will be
+reclaimed if pages of different mobility are being mixed within pageblocks.
+The intent is so that compaction has less work to do and increase the
+success rate of future high-order allocations such as SLUB allocations,
+THP and hugetlbfs pages.
+
+To make it sensible with respect to the matermark_scale_factor parameter,
+the unit is in fractions of 10,000. The default value of 15000 means
+that 150% of the high watermark will be reclaimed in the event of a
+pageblock being mixed due to fragmentation. If this value is smaller
+than a pageblock then a pageblocks worth of pages will be reclaimed (e.g.
+2MB on 64-bit x86). A boost factor of 0 will disable the feature.
+
+=============================================================
+
 watermark_scale_factor:
 
 This factor controls the aggressiveness of kswapd. It defines the
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0416a7204be3..036bba4b84af 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2174,6 +2174,7 @@ extern void zone_pcp_reset(struct zone *zone);
 
 /* page_alloc.c */
 extern int min_free_kbytes;
+extern int watermark_boost_factor;
 extern int watermark_scale_factor;
 
 /* nommu.c */
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 854d6c188888..30595df513c4 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -267,10 +267,10 @@ enum zone_watermarks {
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
@@ -362,6 +362,7 @@ struct zone {
 
 	/* zone watermarks, access with *_wmark_pages(zone) macros */
 	unsigned long _watermark[NR_WMARK];
+	unsigned long watermark_boost;
 
 	unsigned long nr_reserved_highatomic;
 
@@ -886,6 +887,8 @@ static inline int is_highmem(struct zone *zone)
 struct ctl_table;
 int min_free_kbytes_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
+int watermark_boost_factor_sysctl_handler(struct ctl_table *, int,
+					void __user *, size_t *, loff_t *);
 int watermark_scale_factor_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
 extern int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES];
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index cc02050fd0c4..6886c7928bb4 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1450,6 +1450,14 @@ static struct ctl_table vm_table[] = {
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
index a51887765abc..f799c5510789 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -263,6 +263,7 @@ compound_page_dtor * const compound_page_dtors[] = {
 
 int min_free_kbytes = 1024;
 int user_min_free_kbytes = -1;
+int watermark_boost_factor __read_mostly = 15000;
 int watermark_scale_factor = 10;
 
 static unsigned long nr_kernel_pages __meminitdata;
@@ -2118,6 +2119,21 @@ static bool can_steal_fallback(unsigned int order, int start_mt)
 	return false;
 }
 
+static inline void boost_watermark(struct zone *zone)
+{
+	unsigned long max_boost;
+
+	if (!watermark_boost_factor)
+		return;
+
+	max_boost = mult_frac(wmark_pages(zone, WMARK_HIGH),
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
@@ -2149,6 +2165,14 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
 		goto single_page;
 	}
 
+	/*
+	 * Boost watermarks to increase reclaim pressure to reduce the
+	 * likelihood of future fallbacks. Wake kswapd now as the node
+	 * may be balanced overall and kswapd will not wake naturally.
+	 */
+	boost_watermark(zone);
+	wakeup_kswapd(zone, 0, 0, zone_idx(zone));
+
 	/* We are not allowed to try stealing from the whole block */
 	if (!whole_block)
 		goto single_page;
@@ -3266,11 +3290,19 @@ static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
  * probably too small. It only makes sense to spread allocations to avoid
  * fragmentation between the Normal and DMA32 zones.
  */
-static inline unsigned int alloc_flags_nofragment(struct zone *zone)
+static inline unsigned int alloc_flags_nofragment(struct zone *zone,
+							gfp_t gfp_mask)
 {
 	if (zone_idx(zone) != ZONE_NORMAL)
 		return 0;
 
+	/*
+	 * A fragmenting fallback will try waking kswapd. ALLOC_NOFRAGMENT
+	 * may break that so such callers can introduce fragmentation.
+	 */
+	if (!(gfp_mask & __GFP_KSWAPD_RECLAIM))
+		return 0;
+
 	/*
 	 * If ZONE_DMA32 exists, assume it is the one after ZONE_NORMAL and
 	 * the pointer is within zone->zone_pgdat->node_zones[].
@@ -4443,7 +4475,8 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
 	 * Forbid the first pass from falling back to types that fragment
 	 * memory until all local zones are considered.
 	 */
-	alloc_flags |= alloc_flags_nofragment(ac.preferred_zoneref->zone);
+	alloc_flags |= alloc_flags_nofragment(ac.preferred_zoneref->zone,
+								gfp_mask);
 
 	/* First allocation attempt */
 	page = get_page_from_freelist(alloc_mask, order, alloc_flags, &ac);
@@ -7343,6 +7376,7 @@ static void __setup_per_zone_wmarks(void)
 
 		zone->_watermark[WMARK_LOW]  = min_wmark_pages(zone) + tmp;
 		zone->_watermark[WMARK_HIGH] = min_wmark_pages(zone) + tmp * 2;
+		zone->watermark_boost = 0;
 
 		spin_unlock_irqrestore(&zone->lock, flags);
 	}
@@ -7443,6 +7477,18 @@ int min_free_kbytes_sysctl_handler(struct ctl_table *table, int write,
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
index c5ef7240cbcb..7a8161258f0d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3360,6 +3360,30 @@ static void age_active_anon(struct pglist_data *pgdat,
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
@@ -3370,9 +3394,12 @@ static bool pgdat_balanced(pg_data_t *pgdat, int order, int classzone_idx)
 	unsigned long mark = -1;
 	struct zone *zone;
 
+	/*
+	 * Check watermarks bottom-up as lower zones are more likely to
+	 * meet watermarks.
+	 */
 	for (i = 0; i <= classzone_idx; i++) {
 		zone = pgdat->node_zones + i;
-
 		if (!managed_zone(zone))
 			continue;
 
@@ -3497,23 +3524,42 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 	int i;
 	unsigned long nr_soft_reclaimed;
 	unsigned long nr_soft_scanned;
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
 
 	__fs_reclaim_acquire();
 
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
@@ -3540,13 +3586,39 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
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
+
 		/*
 		 * Do some background aging of the anon list, to give
 		 * pages a chance to be referenced before reclaiming. All
@@ -3598,6 +3670,16 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
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
@@ -3606,6 +3688,28 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
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
 	/*
@@ -3833,7 +3937,8 @@ void wakeup_kswapd(struct zone *zone, gfp_t gfp_flags, int order,
 
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
