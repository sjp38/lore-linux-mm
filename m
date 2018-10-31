Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D1E016B026B
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 12:06:49 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id g26-v6so11075871edp.13
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 09:06:49 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id 10-v6si3530421ejo.30.2018.10.31.09.06.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 09:06:47 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id E514D1C23C5
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 16:06:46 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 4/5] mm: Stall movable allocations until kswapd progresses during serious external fragmentation event
Date: Wed, 31 Oct 2018 16:06:44 +0000
Message-Id: <20181031160645.7633-5-mgorman@techsingularity.net>
In-Reply-To: <20181031160645.7633-1-mgorman@techsingularity.net>
References: <20181031160645.7633-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

An external fragmentation causing events as already been described. A
serious external fragmentation causing event is described as one that steals
a contiguous range of pages of an order lower than fragment_stall_order
(PAGE_ALLOC_COSTLY_ORDER by default). If fragmentation would steal a
block smaller than this, this patch causes a movable allocation request
that is allowed to sleep to until kswapd makes progress. As kswapd has
just been woken due to a boosted watermark, it's expected to return quickly.

This stall is not guaranteed to avoid serious fragmentation causing events.
If memory pressure is high enough, the pages freed by kswapd may still
be used or they may not be in pageblocks that contain only movable
pages. Furthermore an allocation request that cannot stall (e.g. atomic
allocations) or if for unmovable/reclaimable pages will still proceed
without stalling.

1-socket Skylake machine
config-global-dhp__workload_thpfioscale XFS (no special madvise)
4 fio threads, 1 THP allocating thread
--------------------------------------

4.19 extfrag events < order 0:  71227
4.19+patch1:                    36456 (49% reduction)
4.19+patch1-3:                   4510 (94% reduction)
4.19+patch1-4:                    548 (99% reduction)

Fragmentation events reduced further. The latency and allocation rates
were similar so are not included for brevity.

1-socket Skylake machine
global-dhp__workload_thpfioscale-madvhugepage-xfs (MADV_HUGEPAGE)
-----------------------------------------------------------------

4.19 extfrag events < order 0:  40761
4.19+patch1:                    36085 (11% reduction)
4.19+patch1-3:                   1887 (95% reduction)
4.19+patch1-4:                    394 (99% reduction)

thpfioscale Fault Latencies
                                       4.19.0                 4.19.0
                                   boost-v1r5             stall-v1r6
Amean     fault-base-1     1863.70 (   0.00%)     3943.28 *-111.58%*
Amean     fault-huge-1      776.07 (   0.00%)     2739.80 *-253.03%*

                                  4.19.0                 4.19.0
                              boost-v1r5             stall-v1r6
Percentage huge-1       86.92 (   0.00%)       98.55 (  13.39%)

Similar to the first case, the reduction in fragmentation events
is notable. However, on this occasion the latencies are much higher
but the allocation success rate is also way higher at 98% success
rate. This is a case where the increased success rate causing pressure
elsewhere but the reduced external framentation events means that
compaction is more effective. This is a classic trade-off on whether
allocation success rate is higher but if problematic, the behaviour
can be tuned.

2-socket Haswell machine
config-global-dhp__workload_thpfioscale XFS (no special madvise)
4 fio threads, 5 THP allocating threads
----------------------------------------------------------------

4.19 extfrag events < order 0:  882868
4.19+patch1:                    476937 (46% reduction)
4.19+patch1-3:                   29044 (97% reduction)
4.19+patch1-4:                   29290 (97% reduction)

There is little impact on fragmentation causing events but the
latency and allocation rates were similar.

2-socket Haswell machine
global-dhp__workload_thpfioscale-madvhugepage-xfs (MADV_HUGEPAGE)
-----------------------------------------------------------------

4.19 extfrag events < order 0: 803099
4.19+patch1:                   654671 (23% reduction)
4.19+patch1-3:                  24352 (97% reduction)
4.19+patch1-4:                  16698 (98% reduction)

thpfioscale Fault Latencies
                                       4.19.0                 4.19.0
                                   boost-v1r5             stall-v1r6
Amean     fault-base-5     5935.74 (   0.00%)     8649.60 * -45.72%*
Amean     fault-huge-5     2611.69 (   0.00%)     2799.82 (  -7.20%)

                                  4.19.0                 4.19.0
                              boost-v1r5             stall-v1r6
Percentage huge-5       66.18 (   0.00%)       77.80 (  17.56%)

Similar to the 1-socket case, the fragmentation events are reduced
but the higher THP allocation success rates also impact the latencies
as compaction goes to work.

This patch does reduce fragmentation rates overall but it's not free as
some allocataions can stall for short periods of time. While it's within
acceptable limits for the adverse test case, there may be other workloads
that cannot tolerate the stalls. Either it can be tuned to disable the
feature or more ideally, the test case is made available for analysis
to see if the stall behaviour can be reduced while still limiting the
fragmentation events. On the flip-side, it has been checked that setting
the fragment_stall_order to 9 eliminated fragmentation events entirely
on the 1-socket machine and by 99.71% on the 2-socket machine.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 Documentation/sysctl/vm.txt | 23 +++++++++++++++
 include/linux/mm.h          |  1 +
 include/linux/mmzone.h      |  2 ++
 kernel/sysctl.c             | 10 +++++++
 mm/internal.h               |  1 +
 mm/page_alloc.c             | 68 +++++++++++++++++++++++++++++++++++++++------
 6 files changed, 97 insertions(+), 8 deletions(-)

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
index 036bba4b84af..a1a2e2833986 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2176,6 +2176,7 @@ extern void zone_pcp_reset(struct zone *zone);
 extern int min_free_kbytes;
 extern int watermark_boost_factor;
 extern int watermark_scale_factor;
+extern int fragment_stall_order;
 
 /* nommu.c */
 extern atomic_long_t mmap_pages_allocated;
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 30595df513c4..66e71a8ac8a6 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -891,6 +891,8 @@ int watermark_boost_factor_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
 int watermark_scale_factor_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
+int fragment_stall_order_sysctl_handler(struct ctl_table *, int,
+					void __user *, size_t *, loff_t *);
 extern int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES];
 int lowmem_reserve_ratio_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 6886c7928bb4..d26f3d9a6400 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -125,6 +125,7 @@ static int zero;
 static int __maybe_unused one = 1;
 static int __maybe_unused two = 2;
 static int __maybe_unused four = 4;
+static int __maybe_unused max_order = MAX_ORDER;
 static unsigned long one_ul = 1;
 static int one_hundred = 100;
 static int one_thousand = 1000;
@@ -1467,6 +1468,15 @@ static struct ctl_table vm_table[] = {
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
index 0dd659cf2a7e..4f159a3b5c4f 100644
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
index f799c5510789..63de66b893d3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -265,6 +265,7 @@ int min_free_kbytes = 1024;
 int user_min_free_kbytes = -1;
 int watermark_boost_factor __read_mostly = 15000;
 int watermark_scale_factor = 10;
+int fragment_stall_order __read_mostly = (PAGE_ALLOC_COSTLY_ORDER + 1);
 
 static unsigned long nr_kernel_pages __meminitdata;
 static unsigned long nr_all_pages __meminitdata;
@@ -2134,6 +2135,21 @@ static inline void boost_watermark(struct zone *zone)
 		max_boost);
 }
 
+static void stall_fragmentation(pg_data_t *pgdat)
+{
+	DEFINE_WAIT(wait);
+	long remaining = 0;
+
+	if (current->flags & PF_MEMALLOC)
+		return;
+
+	prepare_to_wait(&pgdat->pfmemalloc_wait, &wait, TASK_INTERRUPTIBLE);
+	if (waitqueue_active(&pgdat->kswapd_wait))
+		wake_up_interruptible(&pgdat->kswapd_wait);
+	remaining = schedule_timeout(HZ/10);
+	finish_wait(&pgdat->pfmemalloc_wait, &wait);
+}
+
 /*
  * This function implements actual steal behaviour. If order is large enough,
  * we can steal whole pageblock. If not, we first move freepages in this
@@ -2142,8 +2158,9 @@ static inline void boost_watermark(struct zone *zone)
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
@@ -2173,6 +2190,11 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
 	boost_watermark(zone);
 	wakeup_kswapd(zone, 0, 0, zone_idx(zone));
 
+	if ((alloc_flags & ALLOC_FRAGMENT_STALL) &&
+	    current_order < fragment_stall_order) {
+		return false;
+	}
+
 	/* We are not allowed to try stealing from the whole block */
 	if (!whole_block)
 		goto single_page;
@@ -2213,11 +2235,12 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
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
@@ -2456,13 +2479,14 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype,
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
@@ -3331,6 +3355,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 	struct zone *zone;
 	struct pglist_data *last_pgdat_dirty_limit = NULL;
 	bool no_fallback;
+	bool fragment_stall;
 
 retry:
 	/*
@@ -3338,6 +3363,8 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 	 * See also __cpuset_node_allowed() comment in kernel/cpuset.c.
 	 */
 	no_fallback = alloc_flags & ALLOC_NOFRAGMENT;
+	fragment_stall = alloc_flags & ALLOC_FRAGMENT_STALL;
+
 	for_next_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx,
 								ac->nodemask) {
 		struct page *page;
@@ -3376,18 +3403,21 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 			}
 		}
 
-		if (no_fallback) {
+		if (no_fallback || fragment_stall) {
+			pg_data_t *pgdat = zone->zone_pgdat;
 			int local_nid;
 
 			/*
 			 * If moving to a remote node, retry but allow
 			 * fragmenting fallbacks. Locality is more important
 			 * than fragmentation avoidance.
-			 *
 			 */
+			if (fragment_stall)
+				stall_fragmentation(pgdat);
 			local_nid = zone_to_nid(ac->preferred_zoneref->zone);
 			if (zone_to_nid(zone) != local_nid) {
 				alloc_flags &= ~ALLOC_NOFRAGMENT;
+				alloc_flags &= ~ALLOC_FRAGMENT_STALL;
 				goto retry;
 			}
 		}
@@ -3463,8 +3493,9 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 	 * It's possible on a UMA machine to get through all zones that are
 	 * fragmented. If avoiding fragmentation, reset and try again
 	 */
-	if (no_fallback) {
+	if (no_fallback || fragment_stall) {
 		alloc_flags &= ~ALLOC_NOFRAGMENT;
+		alloc_flags &= ~ALLOC_FRAGMENT_STALL;
 		goto retry;
 	}
 
@@ -4192,6 +4223,14 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
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
@@ -4213,6 +4252,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
 	if (page)
 		goto got_pg;
+	alloc_flags &= ~ALLOC_FRAGMENT_STALL;
 
 	/*
 	 * For costly allocations, try direct compaction first, as it's likely
@@ -7489,6 +7529,18 @@ int watermark_boost_factor_sysctl_handler(struct ctl_table *table, int write,
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
-- 
2.16.4
