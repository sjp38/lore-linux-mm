Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2D5396B2CF6
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 06:45:33 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id q8so495621edd.8
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 03:45:33 -0800 (PST)
Received: from outbound-smtp16.blacknight.com (outbound-smtp16.blacknight.com. [46.22.139.233])
        by mx.google.com with ESMTPS id d1si13139940edb.435.2018.11.23.03.45.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 03:45:30 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp16.blacknight.com (Postfix) with ESMTPS id 3EC961C2CBC
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 11:45:30 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 5/5] mm: Stall movable allocations until kswapd progresses during serious external fragmentation event
Date: Fri, 23 Nov 2018 11:45:28 +0000
Message-Id: <20181123114528.28802-6-mgorman@techsingularity.net>
In-Reply-To: <20181123114528.28802-1-mgorman@techsingularity.net>
References: <20181123114528.28802-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

An event that potentially causes external fragmentation problems has
already been described but there are degrees of severity.  A "serious"
event is defined as one that steals a contiguous range of pages of an order
lower than fragment_stall_order (PAGE_ALLOC_COSTLY_ORDER by default). If a
movable allocation request that is allowed to sleep needs to steal a small
block then it schedules until kswapd makes progress or a timeout passes.
The watermarks are also boosted slightly faster so that kswapd makes
greater effort to reclaim enough pages to avoid the fragmentation event.

This stall is not guaranteed to avoid serious fragmentation events.
If memory pressure is high enough, the pages freed by kswapd may be
reallocated or the free pages may not be in pageblocks that contain
only movable pages. Furthermore an allocation request that cannot stall
(e.g. atomic allocations) or unmovable/reclaimable allocations will still
proceed without stalling. The reason is that movable allocations can be
migrated and stalling for kswapd to make progress means that compaction
has targets. Unmovable/reclaimable allocations on the other hand do not
benefit from stalling as their pages cannot move.

The worst-case scenario for stalling is a combination of both high memory
pressure where kswapd is having trouble keeping free pages over the
pfmemalloc_reserve and movable allocations are fragmenting memory. In this
case, an allocation request may sleep for longer. There are both vmstats
to identify stalls are happening and a tracepoint to quantify what the
stall durations are. Note that the granularity of the stall detection is
a jiffy so the delay accounting is not precise.

1-socket Skylake machine
config-global-dhp__workload_thpfioscale XFS (no special madvise)
4 fio threads, 1 THP allocating thread
--------------------------------------

4.20-rc3 extfrag events < order 9:   804694
4.20-rc3+patch:                      408912 (49% reduction)
4.20-rc3+patch1-4:                    18421 (98% reduction)
4.20-rc3+patch1-5:                    16788 (98% reduction)

                                   4.20.0-rc3             4.20.0-rc3
                                   boost-v5r8             stall-v5r8
Amean     fault-base-1      652.71 (   0.00%)      651.40 (   0.20%)
Amean     fault-huge-1      178.93 (   0.00%)      174.49 *   2.48%*

thpfioscale Percentage Faults Huge
                              4.20.0-rc3             4.20.0-rc3
                              boost-v5r8             stall-v5r8
Percentage huge-1        5.12 (   0.00%)        5.56 (   8.77%)

Fragmentation events are further reduced. Note that in previous versions,
it was reduced to negligible levels but the logic has been corrected
to avoid exceessive reclaim and slab shrinkage in the meantime to avoid
IO regressions that may not be tolerable.

The latencies and allocation success rates are roughly similar.  Over the
course of 16 minutes, there were 2 stalls due to fragmentation avoidance
for 8 microseconds.

1-socket Skylake machine
global-dhp__workload_thpfioscale-madvhugepage-xfs (MADV_HUGEPAGE)
-----------------------------------------------------------------

4.20-rc3 extfrag events < order 9:  291392
4.20-rc3+patch:                     191187 (34% reduction)
4.20-rc3+patch1-4:                   13464 (95% reduction)
4.20-rc3+patch1-5:                   15089 (99.7% reduction)

                                   4.20.0-rc3             4.20.0-rc3
                                   boost-v5r8             stall-v5r8
Amean     fault-base-1     1481.67 (   0.00%)        0.00 * 100.00%*
Amean     fault-huge-1     1063.88 (   0.00%)      540.81 *  49.17%*

                              4.20.0-rc3             4.20.0-rc3
                              boost-v5r8             stall-v5r8
Percentage huge-1       83.46 (   0.00%)      100.00 (  19.82%)

The fragmentation events were increased which is bad, but this is offset
by the fact that THP allocation rates had a lower latency and a perfect
allocation success rate. There were 102 stalls over the course of 16
minutes for a total stall time of roughly 0.4 seconds.

2-socket Haswell machine
config-global-dhp__workload_thpfioscale XFS (no special madvise)
4 fio threads, 5 THP allocating threads
----------------------------------------------------------------

4.20-rc3 extfrag events < order 9:  215698
4.20-rc3+patch:                     200210 (7% reduction)
4.20-rc3+patch1-4:                   14263 (93% reduction)
4.20-rc3+patch1-5:                   11702 (95% reduction)

                                   4.20.0-rc3             4.20.0-rc3
                                   boost-v5r8             stall-v5r8
Amean     fault-base-5     1306.87 (   0.00%)     1340.96 (  -2.61%)
Amean     fault-huge-5     1348.94 (   0.00%)     2089.44 ( -54.89%)

                              4.20.0-rc3             4.20.0-rc3
                              boost-v5r8             stall-v5r8
Percentage huge-5        7.91 (   0.00%)        2.43 ( -69.26%)

There is a slight reduction in fragmentation events but it's slight
enough that it may be due to luck. Unfortunately, both the latencies
and success rates were lower. However, this is highly likely to be due
to luck given that there were just 12 stalls for 76 microseconds. Direct
reclaim was also eliminated but that is likely a co-incidence.

2-socket Haswell machine
global-dhp__workload_thpfioscale-madvhugepage-xfs (MADV_HUGEPAGE)
-----------------------------------------------------------------

4.20-rc3 extfrag events < order 9: 166352
4.20-rc3+patch:                    147463 (11% reduction)
4.20-rc3+patch1-4:                  11095 (93% reduction)
4.20-rc3+patch1-5:                  10677 (94% reduction)

thpfioscale Fault Latencies
                                   4.20.0-rc3             4.20.0-rc3
                                   boost-v5r8             stall-v5r8
Amean     fault-base-5     7419.67 (   0.00%)     6853.97 (   7.62%)
Amean     fault-huge-5     3263.80 (   0.00%)     1799.26 *  44.87%*

                              4.20.0-rc3             4.20.0-rc3
                              boost-v5r8             stall-v5r8
Percentage huge-5       87.98 (   0.00%)       98.97 (  12.49%)

The fragmentation events are slightly reduced with the latencies and
allocation success rates much improved.  There were 462 stalls over the
course of 68 minutes with a total stall time of roughly 1.9 seconds.

This patch has a marginal rate on fragmentation rates as it's rare for
the stall logic to actually trigger but the small stalls can be enough for
kswapd to catch up. How much that helps is variable but probably worthwhile
for long-term allocation success rates. It is possible to eliminate
fragmentation events entirely with tuning due to this patch although that
would require careful evaluation to determine if it's worthwhile.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 Documentation/sysctl/vm.txt   |  23 +++++++++
 include/linux/mm.h            |   1 +
 include/linux/mmzone.h        |   2 +
 include/linux/vm_event_item.h |   1 +
 include/trace/events/kmem.h   |  21 +++++++++
 kernel/sysctl.c               |  10 ++++
 mm/internal.h                 |   1 +
 mm/page_alloc.c               | 105 +++++++++++++++++++++++++++++++++++++-----
 mm/vmscan.c                   |   3 +-
 mm/vmstat.c                   |   1 +
 10 files changed, 155 insertions(+), 13 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 187ce4f599a2..d07e2f01f429 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -31,6 +31,7 @@ files can be found in mm/swap.c.
 - dirty_writeback_centisecs
 - drop_caches
 - extfrag_threshold
+- fragment_stall_order
 - hugetlb_shm_group
 - laptop_mode
 - legacy_va_layout
@@ -275,6 +276,28 @@ any throttling.
 
 ==============================================================
 
+fragment_stall_order
+
+External fragmentation control is managed on a pageblock level where the
+page allocator tries to avoid mixing pages of different mobility within page
+blocks (e.g. order 9 on 64-bit x86). If external fragmentation is perfectly
+controlled then a THP allocation will often succeed up to the number of
+movable pageblocks in the system as reported by /proc/pagetypeinfo.
+
+When memory is low, the system may have to mix pageblocks and will wake
+kswapd to try control future fragmentation. fragment_stall_order controls if
+the allocating task will stall if possible until kswapd makes some progress
+in preference to fragmenting the system. This incurs a small stall penalty
+in exchange for future success at allocating huge pages. If the stalls
+are undesirable and high-order allocations are irrelevant then this can
+be disabled by writing 0 to the tunable. Writing the pageblock order will
+strongly (but not perfectly) control external fragmentation.
+
+The default (4) will stall for fragmenting allocations less than or equal
+to the PAGE_ALLOC_COSTLY_ORDER (defined as order-3 at the time of writing).
+
+==============================================================
+
 hugetlb_shm_group
 
 hugetlb_shm_group contains group id that is allowed to create SysV
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 2c4c69508413..2b72de790ef9 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2204,6 +2204,7 @@ extern void zone_pcp_reset(struct zone *zone);
 extern int min_free_kbytes;
 extern int watermark_boost_factor;
 extern int watermark_scale_factor;
+extern int fragment_stall_order;
 
 /* nommu.c */
 extern atomic_long_t mmap_pages_allocated;
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index d352c1dab486..cffec484ac8a 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -890,6 +890,8 @@ int watermark_boost_factor_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
 int watermark_scale_factor_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
+int fragment_stall_order_sysctl_handler(struct ctl_table *, int,
+					void __user *, size_t *, loff_t *);
 extern int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES];
 int lowmem_reserve_ratio_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 47a3441cf4c4..7661abe5236e 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -43,6 +43,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		PAGEOUTRUN, PGROTATED,
 		DROP_PAGECACHE, DROP_SLAB,
 		OOM_KILL,
+		FRAGMENTSTALL,
 #ifdef CONFIG_NUMA_BALANCING
 		NUMA_PTE_UPDATES,
 		NUMA_HUGE_PTE_UPDATES,
diff --git a/include/trace/events/kmem.h b/include/trace/events/kmem.h
index eb57e3037deb..caadd8681ac5 100644
--- a/include/trace/events/kmem.h
+++ b/include/trace/events/kmem.h
@@ -315,6 +315,27 @@ TRACE_EVENT(mm_page_alloc_extfrag,
 		__entry->change_ownership)
 );
 
+TRACE_EVENT(mm_fragmentation_stall,
+
+	TP_PROTO(int nid, unsigned long duration),
+
+	TP_ARGS(nid, duration),
+
+	TP_STRUCT__entry(
+		__field(	int,		nid		)
+		__field(	unsigned long,	duration	)
+	),
+
+	TP_fast_assign(
+		__entry->nid		= nid;
+		__entry->duration	= duration
+	),
+
+	TP_printk("nid=%d duration=%lu",
+		__entry->nid,
+		__entry->duration)
+);
+
 #endif /* _TRACE_KMEM_H */
 
 /* This part must be outside protection */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 1825f712e73b..eb09c79ddbef 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -126,6 +126,7 @@ static int zero;
 static int __maybe_unused one = 1;
 static int __maybe_unused two = 2;
 static int __maybe_unused four = 4;
+static int __maybe_unused max_order = MAX_ORDER;
 static unsigned long one_ul = 1;
 static int one_hundred = 100;
 static int one_thousand = 1000;
@@ -1479,6 +1480,15 @@ static struct ctl_table vm_table[] = {
 		.extra1		= &one,
 		.extra2		= &one_thousand,
 	},
+	{
+		.procname	= "fragment_stall_order",
+		.data		= &fragment_stall_order,
+		.maxlen		= sizeof(fragment_stall_order),
+		.mode		= 0644,
+		.proc_handler	= fragment_stall_order_sysctl_handler,
+		.extra1		= &zero,
+		.extra2		= &max_order,
+	},
 	{
 		.procname	= "percpu_pagelist_fraction",
 		.data		= &percpu_pagelist_fraction,
diff --git a/mm/internal.h b/mm/internal.h
index be826ee9dc7f..236fa39b9835 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -490,6 +490,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 #define ALLOC_NOFRAGMENT	  0x0
 #endif
 #define ALLOC_KSWAPD		0x200 /* allow waking of kswapd */
+#define ALLOC_FRAGMENT_STALL	0x400 /* stall if fragmenting heavily */
 
 enum ttu_flags;
 struct tlbflush_unmap_batch;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f9af2a79b1cd..da56ecdfffa7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -265,6 +265,7 @@ int min_free_kbytes = 1024;
 int user_min_free_kbytes = -1;
 int watermark_boost_factor __read_mostly = 15000;
 int watermark_scale_factor = 10;
+int fragment_stall_order __read_mostly = (PAGE_ALLOC_COSTLY_ORDER + 1);
 
 static unsigned long nr_kernel_pages __meminitdata;
 static unsigned long nr_all_pages __meminitdata;
@@ -2130,9 +2131,10 @@ static bool can_steal_fallback(unsigned int order, int start_mt)
 	return false;
 }
 
-static inline void boost_watermark(struct zone *zone)
+static inline void __boost_watermark(struct zone *zone, bool fast_boost)
 {
 	unsigned long max_boost;
+	unsigned long nr;
 
 	if (!watermark_boost_factor)
 		return;
@@ -2140,9 +2142,45 @@ static inline void boost_watermark(struct zone *zone)
 	max_boost = mult_frac(zone->_watermark[WMARK_HIGH],
 			watermark_boost_factor, 10000);
 	max_boost = max(pageblock_nr_pages, max_boost);
+	nr = pageblock_nr_pages;
 
-	zone->watermark_boost = min(zone->watermark_boost + pageblock_nr_pages,
-		max_boost);
+	/* Scale relative to the MIGRATE_PCPTYPES similar to min_free_kbytes */
+	if (fast_boost)
+		nr += pageblock_nr_pages * (MIGRATE_PCPTYPES << 1);
+
+	zone->watermark_boost = min(zone->watermark_boost + nr, max_boost);
+}
+
+static inline void boost_watermark(struct zone *zone, bool fast_boost)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&zone->lock, flags);
+	__boost_watermark(zone, fast_boost);
+	spin_unlock_irqrestore(&zone->lock, flags);
+}
+
+static void stall_fragmentation(struct zone *pzone)
+{
+	DEFINE_WAIT(wait);
+	long remaining = 0;
+	long timeout = HZ/50;
+	pg_data_t *pgdat = pzone->zone_pgdat;
+
+	if (current->flags & PF_MEMALLOC)
+		return;
+
+	boost_watermark(pzone, true);
+	prepare_to_wait(&pgdat->pfmemalloc_wait, &wait, TASK_INTERRUPTIBLE);
+	if (waitqueue_active(&pgdat->kswapd_wait))
+		wake_up_interruptible(&pgdat->kswapd_wait);
+	remaining = schedule_timeout(timeout);
+	finish_wait(&pgdat->pfmemalloc_wait, &wait);
+	if (remaining != timeout) {
+		trace_mm_fragmentation_stall(pgdat->node_id,
+			jiffies_to_usecs(timeout - remaining));
+		count_vm_event(FRAGMENTSTALL);
+	}
 }
 
 /*
@@ -2153,7 +2191,7 @@ static inline void boost_watermark(struct zone *zone)
  * of pages are free or compatible, we can change migratetype of the pageblock
  * itself, so pages freed in the future will be put on the correct free list.
  */
-static void steal_suitable_fallback(struct zone *zone, struct page *page,
+static bool steal_suitable_fallback(struct zone *zone, struct page *page,
 		unsigned int alloc_flags, int start_type, bool whole_block)
 {
 	unsigned int current_order = page_order(page);
@@ -2181,10 +2219,15 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
 	 * likelihood of future fallbacks. Wake kswapd now as the node
 	 * may be balanced overall and kswapd will not wake naturally.
 	 */
-	boost_watermark(zone);
+	__boost_watermark(zone, false);
 	if (alloc_flags & ALLOC_KSWAPD)
 		wakeup_kswapd(zone, 0, 0, zone_idx(zone));
 
+	if ((alloc_flags & ALLOC_FRAGMENT_STALL) &&
+	    current_order < fragment_stall_order) {
+		return false;
+	}
+
 	/* We are not allowed to try stealing from the whole block */
 	if (!whole_block)
 		goto single_page;
@@ -2225,11 +2268,12 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
 			page_group_by_mobility_disabled)
 		set_pageblock_migratetype(page, start_type);
 
-	return;
+	return true;
 
 single_page:
 	area = &zone->free_area[current_order];
 	list_move(&page->lru, &area->free_list[start_type]);
+	return true;
 }
 
 /*
@@ -2468,14 +2512,15 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype,
 	page = list_first_entry(&area->free_list[fallback_mt],
 							struct page, lru);
 
-	steal_suitable_fallback(zone, page, alloc_flags, start_migratetype,
-								can_steal);
+	if (!steal_suitable_fallback(zone, page, alloc_flags,
+					start_migratetype, can_steal)) {
+		return false;
+	}
 
 	trace_mm_page_alloc_extfrag(page, order, current_order,
 		start_migratetype, fallback_mt);
 
 	return true;
-
 }
 
 /*
@@ -3343,9 +3388,11 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 						const struct alloc_context *ac)
 {
 	struct zoneref *z;
+	struct zone *pzone;
 	struct zone *zone;
 	struct pglist_data *last_pgdat_dirty_limit = NULL;
 	bool no_fallback;
+	bool fragment_stall;
 
 retry:
 	/*
@@ -3353,7 +3400,10 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 	 * See also __cpuset_node_allowed() comment in kernel/cpuset.c.
 	 */
 	no_fallback = alloc_flags & ALLOC_NOFRAGMENT;
+	fragment_stall = alloc_flags & ALLOC_FRAGMENT_STALL;
 	z = ac->preferred_zoneref;
+	pzone = z->zone;
+
 	for_next_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx,
 								ac->nodemask) {
 		struct page *page;
@@ -3392,7 +3442,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 			}
 		}
 
-		if (no_fallback && nr_online_nodes > 1 &&
+		if ((no_fallback || fragment_stall) && nr_online_nodes > 1 &&
 		    zone != ac->preferred_zoneref->zone) {
 			int local_nid;
 
@@ -3401,9 +3451,12 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 			 * fragmenting fallbacks. Locality is more important
 			 * than fragmentation avoidance.
 			 */
-			local_nid = zone_to_nid(ac->preferred_zoneref->zone);
+			local_nid = zone_to_nid(pzone);
 			if (zone_to_nid(zone) != local_nid) {
+				if (fragment_stall)
+					stall_fragmentation(pzone);
 				alloc_flags &= ~ALLOC_NOFRAGMENT;
+				alloc_flags &= ~ALLOC_FRAGMENT_STALL;
 				goto retry;
 			}
 		}
@@ -3479,8 +3532,12 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 	 * It's possible on a UMA machine to get through all zones that are
 	 * fragmented. If avoiding fragmentation, reset and try again.
 	 */
-	if (no_fallback) {
+	if (no_fallback || fragment_stall) {
+		if (fragment_stall)
+			stall_fragmentation(pzone);
+
 		alloc_flags &= ~ALLOC_NOFRAGMENT;
+		alloc_flags &= ~ALLOC_FRAGMENT_STALL;
 		goto retry;
 	}
 
@@ -4194,6 +4251,17 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	 */
 	alloc_flags = gfp_to_alloc_flags(gfp_mask);
 
+	/*
+	 * Consider stalling on heavy for movable allocations in preference to
+	 * fragmenting unmovable/reclaimable pageblocks. A caller that is
+	 * willing to direct reclaim is already willing to stall.
+	 * Unmovable/reclaimable allocations do not stall as kswapd is not
+	 * guaranteed to free pages in their respective pageblocks.
+	 */
+	if ((gfp_mask & (__GFP_MOVABLE|__GFP_DIRECT_RECLAIM)) ==
+			(__GFP_MOVABLE|__GFP_DIRECT_RECLAIM))
+		alloc_flags |= ALLOC_FRAGMENT_STALL;
+
 	/*
 	 * We need to recalculate the starting point for the zonelist iterator
 	 * because we might have used different nodemask in the fast path, or
@@ -4215,6 +4283,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
 	if (page)
 		goto got_pg;
+	alloc_flags &= ~ALLOC_FRAGMENT_STALL;
 
 	/*
 	 * For costly allocations, try direct compaction first, as it's likely
@@ -7590,6 +7659,18 @@ int watermark_boost_factor_sysctl_handler(struct ctl_table *table, int write,
 	return 0;
 }
 
+int fragment_stall_order_sysctl_handler(struct ctl_table *table, int write,
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
index 4c96b6356398..c3350ed4ff7e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3685,7 +3685,8 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 		 * able to safely make forward progress. Wake them
 		 */
 		if (waitqueue_active(&pgdat->pfmemalloc_wait) &&
-				allow_direct_reclaim(pgdat))
+				((!raise_priority && nr_boost_reclaim) ||
+				 allow_direct_reclaim(pgdat)))
 			wake_up_all(&pgdat->pfmemalloc_wait);
 
 		/* Check if kswapd should be suspending */
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 9c624595e904..6cc7755c6eb1 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1211,6 +1211,7 @@ const char * const vmstat_text[] = {
 	"drop_pagecache",
 	"drop_slab",
 	"oom_kill",
+	"fragment_stall",
 
 #ifdef CONFIG_NUMA_BALANCING
 	"numa_pte_updates",
-- 
2.16.4
