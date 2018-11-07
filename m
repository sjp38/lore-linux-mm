Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4241A6B053B
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 13:38:27 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id x14-v6so7760537edr.7
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 10:38:27 -0800 (PST)
Received: from outbound-smtp13.blacknight.com (outbound-smtp13.blacknight.com. [46.22.139.230])
        by mx.google.com with ESMTPS id y30-v6si1022063edb.128.2018.11.07.10.38.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 10:38:24 -0800 (PST)
Received: from mail.blacknight.com (unknown [81.17.255.152])
	by outbound-smtp13.blacknight.com (Postfix) with ESMTPS id 613971C23D4
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 18:38:24 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 4/5] mm: Stall movable allocations until kswapd progresses during serious external fragmentation event
Date: Wed,  7 Nov 2018 18:38:21 +0000
Message-Id: <20181107183822.15567-5-mgorman@techsingularity.net>
In-Reply-To: <20181107183822.15567-1-mgorman@techsingularity.net>
References: <20181107183822.15567-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

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
proceed without stalling.

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

4.20-rc1 extfrag events < order 9:  1023463
4.20-rc1+patch:                      358574 (65% reduction)
4.20-rc1+patch1-3:                    19274 (98% reduction)
4.20-rc1+patch1-4:                     1351 (99.9% reduction)

                                   4.20.0-rc1             4.20.0-rc1
                                   boost-v2r4             stall-v2r6
Amean     fault-base-1      659.85 (   0.00%)      648.66 *   1.70%*
Amean     fault-huge-1      172.19 (   0.00%)      167.79 (   2.56%)

thpfioscale Percentage Faults Huge
                              4.20.0-rc1             4.20.0-rc1
                              boost-v2r4             stall-v2r6
Percentage huge-1        1.68 (   0.00%)        1.16 ( -30.69%)

Fragmentation events are now reduced to negligible levels.

The latencies and allocation success rates are roughly similar.  Over the
course of 16 minutes, there were 100 stalls due to fragmentation avoidance
with a total stall time of 0.4 seconds.

1-socket Skylake machine
global-dhp__workload_thpfioscale-madvhugepage-xfs (MADV_HUGEPAGE)
-----------------------------------------------------------------

4.20-rc1 extfrag events < order 9:  342549
4.20-rc1+patch:                     337890 ( 1% reduction)
4.20-rc1+patch1-3:                   12801 (96% reduction)
4.20-rc1+patch1-4:                    1117 (99.7% reduction)

                                   4.20.0-rc1             4.20.0-rc1
                                   boost-v2r4             stall-v2r6
Amean     fault-base-1     1578.91 (   0.00%)    43404.60 (-2649.02%)
Amean     fault-huge-1     1090.23 (   0.00%)     1424.32 * -30.64%*

                              4.20.0-rc1             4.20.0-rc1
                              boost-v2r4             stall-v2r6
Percentage huge-1       82.59 (   0.00%)       99.92 (  20.97%)

The fragmentation events were reduced but the latencies went a bit crazy.
The "problem" is that the allocation success rates were very high and
forward progress was being made. This put the system under further pressure
and while compactions were succeeding, the latencies were high in cases
where compaction failed. The THP allocation vm stats are illustrative in this case

                         4.20.0-rc1  4.20.0-rc1
                         boost-v2r4  stall-v2r6
THP fault alloc                4974        6016
THP fault fallback             1048           5
THP collapse alloc               65          56
THP collapse fail                 4           4
THP split                         0        3719
THP split failed                  0         224

Note the THP fault alloc stats where they almost all succeeded relative
to the baseline. While the latencies are much higher, it is the case that
the application specifically requested THP while the system was under
heavy memory pressure.

There were 314 stalls over the course of 16 minutes for a total stall
time of roughly 11 seconds. The distribution of stalls is as follows

    205 4000
      1 8000
      1 20000
      1 32000
      1 36000
      6 40000
      1 56000
     98 100000

This is showing that 98 of the stalls waited until the timeout expired
at 25 jiffies which 100000 microseconds on this particular configuration.
If this is considered problematic, the timeout can be reduced to tradeoff
fault times against fragmentation avoidance.

2-socket Haswell machine
config-global-dhp__workload_thpfioscale XFS (no special madvise)
4 fio threads, 5 THP allocating threads
----------------------------------------------------------------

4.20-rc1 extfrag events < order 9:  209820
4.20-rc1+patch:                     185923 (11% reduction)
4.20-rc1+patch1-3:                   11240 (95% reduction)
4.20-rc1+patch1-4:                   13241 (93% reduction)

                                   4.20.0-rc1             4.20.0-rc1
                                   boost-v2r4             stall-v2r6
Amean     fault-base-5     1395.28 (   0.00%)     1508.94 *  -8.15%*
Amean     fault-huge-5      539.69 (   0.00%)      614.88 * -13.93%*

                              4.20.0-rc1             4.20.0-rc1
                              boost-v2r4             stall-v2r6
Percentage huge-5        0.53 (   0.00%)        3.38 ( 534.38%

There is a slight increase in fragmentation events but given that it's
already heavily reduced, there are elements of luck. There is a small
increase in latencies which is partially offset by a slight increase in
THP allocation success rates. There were 65 stalls over the course of 87
minutes with stall time of a total of roughly 0.4 milliseconds.

2-socket Haswell machine
global-dhp__workload_thpfioscale-madvhugepage-xfs (MADV_HUGEPAGE)
-----------------------------------------------------------------

4.20-rc1 extfrag events < order 9: 167464
4.20-rc1+patch:                    130081 (22% reduction)
4.20-rc1+patch1-3:                  12057 (92% reduction)
4.20-rc1+patch1-4:                  11060 (93% reduction)

thpfioscale Fault Latencies
                                   4.20.0-rc1             4.20.0-rc1
                                   boost-v2r4             stall-v2r6
Amean     fault-base-5     8691.83 (   0.00%)     9363.89 (  -7.73%)
Amean     fault-huge-5     2899.83 (   0.00%)     3638.29 * -25.47%*

                              4.20.0-rc1             4.20.0-rc1
                              boost-v2r4             stall-v2r6
Percentage huge-5       95.55 (   0.00%)       99.27 (   3.89%)

The fragmentation events are reduced and while there is some hit on
the latency, the success rate is near 100% while under heavy pressure.
There were 2486 stalls over the course of 85 minutes with a total stall
time of roughly 12 seconds.

This patch does reduce fragmentation rates overall but it's not free
as some allocataions can stall for short periods of time and there
are knock-on effects to latency when THP allocation success rates are
higher. While it's within acceptable limits for the adverse test case,
there may be other workloads that cannot tolerate the stalls. If this
occurs, it can be tuned to disable the feature or more ideally, the test
case is made available for analysis to see if the stall behaviour can be
reduced while still limiting the fragmentation events. On the flip-side,
it has been checked that setting the fragment_stall_order to 9 eliminated
fragmentation events entirely.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 Documentation/sysctl/vm.txt   | 23 +++++++++++
 include/linux/mm.h            |  1 +
 include/linux/mmzone.h        |  2 +
 include/linux/vm_event_item.h |  1 +
 include/trace/events/kmem.h   | 21 ++++++++++
 kernel/sysctl.c               | 10 +++++
 mm/internal.h                 |  1 +
 mm/page_alloc.c               | 94 +++++++++++++++++++++++++++++++++++++------
 mm/vmstat.c                   |  1 +
 9 files changed, 142 insertions(+), 12 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 2244520d7913..f7d3fcb9d4ce 100644
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
+The default will stall for fragmenting allocations smaller than the
+PAGE_ALLOC_COSTLY_ORDER (defined as order-3 at the time of writing).
+
+==============================================================
+
 hugetlb_shm_group
 
 hugetlb_shm_group contains group id that is allowed to create SysV
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 81926daf6dfb..ef98eb3f8360 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2196,6 +2196,7 @@ extern void zone_pcp_reset(struct zone *zone);
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
index 544355156c92..5506a4596d59 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -489,6 +489,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 #else
 #define ALLOC_NOFRAGMENT	  0x0
 #endif
+#define ALLOC_FRAGMENT_STALL	0x200 /* stall if fragmenting heavily */
 
 enum ttu_flags;
 struct tlbflush_unmap_batch;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4abac725a149..86a6e86c51bb 100644
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
+static inline void boost_watermark(struct zone *zone, bool fast_boost)
 {
 	unsigned long max_boost;
+	unsigned long nr;
 
 	if (!watermark_boost_factor)
 		return;
@@ -2140,9 +2142,36 @@ static inline void boost_watermark(struct zone *zone)
 	max_boost = mult_frac(wmark_pages(zone, WMARK_HIGH),
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
+static void stall_fragmentation(struct zone *pzone)
+{
+	DEFINE_WAIT(wait);
+	long remaining = 0;
+	long timeout = HZ/10;
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
@@ -2153,8 +2182,9 @@ static inline void boost_watermark(struct zone *zone)
  * of pages are free or compatible, we can change migratetype of the pageblock
  * itself, so pages freed in the future will be put on the correct free list.
  */
-static void steal_suitable_fallback(struct zone *zone, struct page *page,
-					int start_type, bool whole_block)
+static bool steal_suitable_fallback(struct zone *zone, struct page *page,
+					int start_type, bool whole_block,
+					unsigned int alloc_flags)
 {
 	unsigned int current_order = page_order(page);
 	struct free_area *area;
@@ -2181,9 +2211,14 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
 	 * likelihood of future fallbacks. Wake kswapd now as the node
 	 * may be balanced overall and kswapd will not wake naturally.
 	 */
-	boost_watermark(zone);
+	boost_watermark(zone, false);
 	wakeup_kswapd(zone, 0, 0, zone_idx(zone));
 
+	if ((alloc_flags & ALLOC_FRAGMENT_STALL) &&
+	    current_order < fragment_stall_order) {
+		return false;
+	}
+
 	/* We are not allowed to try stealing from the whole block */
 	if (!whole_block)
 		goto single_page;
@@ -2224,11 +2259,12 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
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
@@ -2467,13 +2503,14 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype,
 	page = list_first_entry(&area->free_list[fallback_mt],
 							struct page, lru);
 
-	steal_suitable_fallback(zone, page, start_migratetype, can_steal);
+	if (!steal_suitable_fallback(zone, page, start_migratetype, can_steal,
+								alloc_flags))
+		return false;
 
 	trace_mm_page_alloc_extfrag(page, order, current_order,
 		start_migratetype, fallback_mt);
 
 	return true;
-
 }
 
 /*
@@ -3340,9 +3377,12 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 						const struct alloc_context *ac)
 {
 	struct zoneref *z = ac->preferred_zoneref;
+	struct zone *pzone = z->zone;
 	struct zone *zone;
 	struct pglist_data *last_pgdat_dirty_limit = NULL;
 	bool no_fallback;
+	bool fragment_stall;
+	int wmark_idx = alloc_flags & ALLOC_WMARK_MASK;
 
 retry:
 	/*
@@ -3350,6 +3390,8 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 	 * See also __cpuset_node_allowed() comment in kernel/cpuset.c.
 	 */
 	no_fallback = alloc_flags & ALLOC_NOFRAGMENT;
+	fragment_stall = alloc_flags & ALLOC_FRAGMENT_STALL;
+
 	for_next_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx,
 								ac->nodemask) {
 		struct page *page;
@@ -3388,7 +3430,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 			}
 		}
 
-		if (no_fallback) {
+		if (no_fallback || fragment_stall) {
 			int local_nid;
 
 			/*
@@ -3396,9 +3438,12 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
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
@@ -3474,8 +3519,12 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 	 * It's possible on a UMA machine to get through all zones that are
 	 * fragmented. If avoiding fragmentation, reset and try again
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
 
@@ -4197,6 +4246,14 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	 */
 	alloc_flags = gfp_to_alloc_flags(gfp_mask);
 
+	/*
+	 * Consider stalling on heavy for movable allocations in preference to
+	 * fragmenting unmovable/reclaimable pageblocks.
+	 */
+	if ((gfp_mask & (__GFP_MOVABLE|__GFP_DIRECT_RECLAIM)) ==
+			(__GFP_MOVABLE|__GFP_DIRECT_RECLAIM))
+		alloc_flags |= ALLOC_FRAGMENT_STALL;
+
 	/*
 	 * We need to recalculate the starting point for the zonelist iterator
 	 * because we might have used different nodemask in the fast path, or
@@ -4218,6 +4275,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
 	if (page)
 		goto got_pg;
+	alloc_flags &= ~ALLOC_FRAGMENT_STALL;
 
 	/*
 	 * For costly allocations, try direct compaction first, as it's likely
@@ -7585,6 +7643,18 @@ int watermark_boost_factor_sysctl_handler(struct ctl_table *table, int write,
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
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 6038ce593ce3..9bb78adf4445 100644
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
