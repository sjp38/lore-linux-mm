Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f48.google.com (mail-la0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id E03316B009E
	for <linux-mm@kvack.org>; Fri, 12 Dec 2014 11:13:45 -0500 (EST)
Received: by mail-la0-f48.google.com with SMTP id gf13so6453324lab.35
        for <linux-mm@kvack.org>; Fri, 12 Dec 2014 08:13:45 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id eg2si3362266wib.50.2014.12.12.08.13.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 12 Dec 2014 08:13:42 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH V3 2/4] mm, page_alloc: reduce number of alloc_pages* functions' parameters
Date: Fri, 12 Dec 2014 17:13:23 +0100
Message-Id: <1418400805-4661-3-git-send-email-vbabka@suse.cz>
In-Reply-To: <1418400805-4661-1-git-send-email-vbabka@suse.cz>
References: <1418400805-4661-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>

Introduce struct alloc_context to accumulate the numerous parameters passed
between the alloc_pages* family of functions and get_page_from_freelist().
This excludes gfp_flags and alloc_info, which mutate too much along the way,
and allocation order, which is conceptually different.

The result is shorter function signatures, as well as overal code size and
stack usage reductions.

bloat-o-meter:

add/remove: 0/0 grow/shrink: 1/2 up/down: 70/-472 (-402)                                                                                                                                                           
function                                     old     new   delta
get_page_from_freelist                      2490    2560     +70
__alloc_pages_direct_compact                 332     284     -48
__alloc_pages_nodemask                      2618    2194    -424

checkstack.pl:

function                            old    new
__alloc_pages_nodemask              240    168
get_page_from_freelist              152    160
__alloc_pages_direct_compact         32     16

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Hocko <mhocko@suse.cz>
---
 mm/page_alloc.c | 226 +++++++++++++++++++++++++-------------------------------
 1 file changed, 102 insertions(+), 124 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bfc00c3..963f9c0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -232,6 +232,19 @@ EXPORT_SYMBOL(nr_node_ids);
 EXPORT_SYMBOL(nr_online_nodes);
 #endif
 
+/*
+ * Structure for holding the mostly immutable allocation parameters passed
+ * between alloc_pages* family of functions.
+ */
+struct alloc_context {
+	struct zonelist *zonelist;
+	nodemask_t *nodemask;
+	struct zone *preferred_zone;
+	int classzone_idx;
+	int migratetype;
+	enum zone_type high_zoneidx;
+};
+
 int page_group_by_mobility_disabled __read_mostly;
 
 void set_pageblock_migratetype(struct page *page, int migratetype)
@@ -2037,10 +2050,10 @@ static void reset_alloc_batches(struct zone *preferred_zone)
  * a page.
  */
 static struct page *
-get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
-		struct zonelist *zonelist, int high_zoneidx, int alloc_flags,
-		struct zone *preferred_zone, int classzone_idx, int migratetype)
+get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
+						const struct alloc_context *ac)
 {
+	struct zonelist *zonelist = ac->zonelist;
 	struct zoneref *z;
 	struct page *page = NULL;
 	struct zone *zone;
@@ -2059,8 +2072,8 @@ zonelist_scan:
 	 * Scan zonelist, looking for a zone with enough free.
 	 * See also __cpuset_node_allowed() comment in kernel/cpuset.c.
 	 */
-	for_each_zone_zonelist_nodemask(zone, z, zonelist,
-						high_zoneidx, nodemask) {
+	for_each_zone_zonelist_nodemask(zone, z, zonelist, ac->high_zoneidx,
+								ac->nodemask) {
 		unsigned long mark;
 
 		if (IS_ENABLED(CONFIG_NUMA) && zlc_active &&
@@ -2077,7 +2090,7 @@ zonelist_scan:
 		 * time the page has in memory before being reclaimed.
 		 */
 		if (alloc_flags & ALLOC_FAIR) {
-			if (!zone_local(preferred_zone, zone))
+			if (!zone_local(ac->preferred_zone, zone))
 				break;
 			if (test_bit(ZONE_FAIR_DEPLETED, &zone->flags)) {
 				nr_fair_skipped++;
@@ -2115,7 +2128,7 @@ zonelist_scan:
 
 		mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
 		if (!zone_watermark_ok(zone, order, mark,
-				       classzone_idx, alloc_flags)) {
+				       ac->classzone_idx, alloc_flags)) {
 			int ret;
 
 			/* Checked here to keep the fast path fast */
@@ -2136,7 +2149,7 @@ zonelist_scan:
 			}
 
 			if (zone_reclaim_mode == 0 ||
-			    !zone_allows_reclaim(preferred_zone, zone))
+			    !zone_allows_reclaim(ac->preferred_zone, zone))
 				goto this_zone_full;
 
 			/*
@@ -2158,7 +2171,7 @@ zonelist_scan:
 			default:
 				/* did we reclaim enough */
 				if (zone_watermark_ok(zone, order, mark,
-						classzone_idx, alloc_flags))
+						ac->classzone_idx, alloc_flags))
 					goto try_this_zone;
 
 				/*
@@ -2179,8 +2192,8 @@ zonelist_scan:
 		}
 
 try_this_zone:
-		page = buffered_rmqueue(preferred_zone, zone, order,
-						gfp_mask, migratetype);
+		page = buffered_rmqueue(ac->preferred_zone, zone, order,
+						gfp_mask, ac->migratetype);
 		if (page) {
 			if (prep_new_page(page, order, gfp_mask, alloc_flags))
 				goto try_this_zone;
@@ -2203,7 +2216,7 @@ this_zone_full:
 		alloc_flags &= ~ALLOC_FAIR;
 		if (nr_fair_skipped) {
 			zonelist_rescan = true;
-			reset_alloc_batches(preferred_zone);
+			reset_alloc_batches(ac->preferred_zone);
 		}
 		if (nr_online_nodes > 1)
 			zonelist_rescan = true;
@@ -2325,14 +2338,12 @@ should_alloc_retry(gfp_t gfp_mask, unsigned int order,
 
 static inline struct page *
 __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
-	struct zonelist *zonelist, enum zone_type high_zoneidx,
-	nodemask_t *nodemask, struct zone *preferred_zone,
-	int classzone_idx, int migratetype)
+					const struct alloc_context *ac)
 {
 	struct page *page;
 
 	/* Acquire the per-zone oom lock for each zone */
-	if (!oom_zonelist_trylock(zonelist, gfp_mask)) {
+	if (!oom_zonelist_trylock(ac->zonelist, gfp_mask)) {
 		schedule_timeout_uninterruptible(1);
 		return NULL;
 	}
@@ -2342,10 +2353,8 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	 * here, this is only to catch a parallel oom killing, we must fail if
 	 * we're still under heavy pressure.
 	 */
-	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask,
-		order, zonelist, high_zoneidx,
-		ALLOC_WMARK_HIGH|ALLOC_CPUSET,
-		preferred_zone, classzone_idx, migratetype);
+	page = get_page_from_freelist(gfp_mask | __GFP_HARDWALL, order,
+					ALLOC_WMARK_HIGH|ALLOC_CPUSET, ac);
 	if (page)
 		goto out;
 
@@ -2354,7 +2363,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 		if (order > PAGE_ALLOC_COSTLY_ORDER)
 			goto out;
 		/* The OOM killer does not needlessly kill tasks for lowmem */
-		if (high_zoneidx < ZONE_NORMAL)
+		if (ac->high_zoneidx < ZONE_NORMAL)
 			goto out;
 		/*
 		 * GFP_THISNODE contains __GFP_NORETRY and we never hit this.
@@ -2367,10 +2376,10 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 			goto out;
 	}
 	/* Exhausted what can be done so it's blamo time */
-	out_of_memory(zonelist, gfp_mask, order, nodemask, false);
+	out_of_memory(ac->zonelist, gfp_mask, order, ac->nodemask, false);
 
 out:
-	oom_zonelist_unlock(zonelist, gfp_mask);
+	oom_zonelist_unlock(ac->zonelist, gfp_mask);
 	return page;
 }
 
@@ -2378,10 +2387,9 @@ out:
 /* Try memory compaction for high-order allocations before reclaim */
 static struct page *
 __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
-	struct zonelist *zonelist, enum zone_type high_zoneidx,
-	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
-	int classzone_idx, int migratetype, enum migrate_mode mode,
-	int *contended_compaction, bool *deferred_compaction)
+		int alloc_flags, const struct alloc_context *ac,
+		enum migrate_mode mode, int *contended_compaction,
+		bool *deferred_compaction)
 {
 	unsigned long compact_result;
 	struct page *page;
@@ -2390,10 +2398,10 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 		return NULL;
 
 	current->flags |= PF_MEMALLOC;
-	compact_result = try_to_compact_pages(zonelist, order, gfp_mask,
-						nodemask, mode,
+	compact_result = try_to_compact_pages(ac->zonelist, order, gfp_mask,
+						ac->nodemask, mode,
 						contended_compaction,
-						alloc_flags, classzone_idx);
+						alloc_flags, ac->classzone_idx);
 	current->flags &= ~PF_MEMALLOC;
 
 	switch (compact_result) {
@@ -2412,10 +2420,8 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	 */
 	count_vm_event(COMPACTSTALL);
 
-	page = get_page_from_freelist(gfp_mask, nodemask,
-			order, zonelist, high_zoneidx,
-			alloc_flags & ~ALLOC_NO_WATERMARKS,
-			preferred_zone, classzone_idx, migratetype);
+	page = get_page_from_freelist(gfp_mask, order,
+					alloc_flags & ~ALLOC_NO_WATERMARKS, ac);
 
 	if (page) {
 		struct zone *zone = page_zone(page);
@@ -2439,10 +2445,9 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 #else
 static inline struct page *
 __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
-	struct zonelist *zonelist, enum zone_type high_zoneidx,
-	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
-	int classzone_idx, int migratetype, enum migrate_mode mode,
-	int *contended_compaction, bool *deferred_compaction)
+		int alloc_flags, const struct alloc_context *ac,
+		enum migrate_mode mode, int *contended_compaction,
+		bool *deferred_compaction)
 {
 	return NULL;
 }
@@ -2450,8 +2455,8 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 
 /* Perform direct synchronous page reclaim */
 static int
-__perform_reclaim(gfp_t gfp_mask, unsigned int order, struct zonelist *zonelist,
-		  nodemask_t *nodemask)
+__perform_reclaim(gfp_t gfp_mask, unsigned int order,
+					const struct alloc_context *ac)
 {
 	struct reclaim_state reclaim_state;
 	int progress;
@@ -2465,7 +2470,8 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order, struct zonelist *zonelist,
 	reclaim_state.reclaimed_slab = 0;
 	current->reclaim_state = &reclaim_state;
 
-	progress = try_to_free_pages(zonelist, order, gfp_mask, nodemask);
+	progress = try_to_free_pages(ac->zonelist, order, gfp_mask,
+								ac->nodemask);
 
 	current->reclaim_state = NULL;
 	lockdep_clear_current_reclaim_state();
@@ -2479,28 +2485,23 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order, struct zonelist *zonelist,
 /* The really slow allocator path where we enter direct reclaim */
 static inline struct page *
 __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
-	struct zonelist *zonelist, enum zone_type high_zoneidx,
-	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
-	int classzone_idx, int migratetype, unsigned long *did_some_progress)
+		int alloc_flags, const struct alloc_context *ac,
+		unsigned long *did_some_progress)
 {
 	struct page *page = NULL;
 	bool drained = false;
 
-	*did_some_progress = __perform_reclaim(gfp_mask, order, zonelist,
-					       nodemask);
+	*did_some_progress = __perform_reclaim(gfp_mask, order, ac);
 	if (unlikely(!(*did_some_progress)))
 		return NULL;
 
 	/* After successful reclaim, reconsider all zones for allocation */
 	if (IS_ENABLED(CONFIG_NUMA))
-		zlc_clear_zones_full(zonelist);
+		zlc_clear_zones_full(ac->zonelist);
 
 retry:
-	page = get_page_from_freelist(gfp_mask, nodemask, order,
-					zonelist, high_zoneidx,
-					alloc_flags & ~ALLOC_NO_WATERMARKS,
-					preferred_zone, classzone_idx,
-					migratetype);
+	page = get_page_from_freelist(gfp_mask, order,
+					alloc_flags & ~ALLOC_NO_WATERMARKS, ac);
 
 	/*
 	 * If an allocation failed after direct reclaim, it could be because
@@ -2521,36 +2522,30 @@ retry:
  */
 static inline struct page *
 __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
-	struct zonelist *zonelist, enum zone_type high_zoneidx,
-	nodemask_t *nodemask, struct zone *preferred_zone,
-	int classzone_idx, int migratetype)
+				const struct alloc_context *ac)
 {
 	struct page *page;
 
 	do {
-		page = get_page_from_freelist(gfp_mask, nodemask, order,
-			zonelist, high_zoneidx, ALLOC_NO_WATERMARKS,
-			preferred_zone, classzone_idx, migratetype);
+		page = get_page_from_freelist(gfp_mask, order,
+						ALLOC_NO_WATERMARKS, ac);
 
 		if (!page && gfp_mask & __GFP_NOFAIL)
-			wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/50);
+			wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC,
+									HZ/50);
 	} while (!page && (gfp_mask & __GFP_NOFAIL));
 
 	return page;
 }
 
-static void wake_all_kswapds(unsigned int order,
-			     struct zonelist *zonelist,
-			     enum zone_type high_zoneidx,
-			     struct zone *preferred_zone,
-			     nodemask_t *nodemask)
+static void wake_all_kswapds(unsigned int order, const struct alloc_context *ac)
 {
 	struct zoneref *z;
 	struct zone *zone;
 
-	for_each_zone_zonelist_nodemask(zone, z, zonelist,
-						high_zoneidx, nodemask)
-		wakeup_kswapd(zone, order, zone_idx(preferred_zone));
+	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist,
+						ac->high_zoneidx, ac->nodemask)
+		wakeup_kswapd(zone, order, zone_idx(ac->preferred_zone));
 }
 
 static inline int
@@ -2609,9 +2604,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 
 static inline struct page *
 __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
-	struct zonelist *zonelist, enum zone_type high_zoneidx,
-	nodemask_t *nodemask, struct zone *preferred_zone,
-	int classzone_idx, int migratetype)
+						struct alloc_context *ac)
 {
 	const gfp_t wait = gfp_mask & __GFP_WAIT;
 	struct page *page = NULL;
@@ -2647,8 +2640,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 
 restart:
 	if (!(gfp_mask & __GFP_NO_KSWAPD))
-		wake_all_kswapds(order, zonelist, high_zoneidx,
-				preferred_zone, nodemask);
+		wake_all_kswapds(order, ac);
 
 	/*
 	 * OK, we're below the kswapd watermark and have kicked background
@@ -2661,18 +2653,17 @@ restart:
 	 * Find the true preferred zone if the allocation is unconstrained by
 	 * cpusets.
 	 */
-	if (!(alloc_flags & ALLOC_CPUSET) && !nodemask) {
+	if (!(alloc_flags & ALLOC_CPUSET) && !ac->nodemask) {
 		struct zoneref *preferred_zoneref;
-		preferred_zoneref = first_zones_zonelist(zonelist, high_zoneidx,
-				NULL, &preferred_zone);
-		classzone_idx = zonelist_zone_idx(preferred_zoneref);
+		preferred_zoneref = first_zones_zonelist(ac->zonelist,
+				ac->high_zoneidx, NULL, &ac->preferred_zone);
+		ac->classzone_idx = zonelist_zone_idx(preferred_zoneref);
 	}
 
 rebalance:
 	/* This is the last chance, in general, before the goto nopage. */
-	page = get_page_from_freelist(gfp_mask, nodemask, order, zonelist,
-			high_zoneidx, alloc_flags & ~ALLOC_NO_WATERMARKS,
-			preferred_zone, classzone_idx, migratetype);
+	page = get_page_from_freelist(gfp_mask, order,
+				alloc_flags & ~ALLOC_NO_WATERMARKS, ac);
 	if (page)
 		goto got_pg;
 
@@ -2683,11 +2674,10 @@ rebalance:
 		 * the allocation is high priority and these type of
 		 * allocations are system rather than user orientated
 		 */
-		zonelist = node_zonelist(numa_node_id(), gfp_mask);
+		ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
+
+		page = __alloc_pages_high_priority(gfp_mask, order, ac);
 
-		page = __alloc_pages_high_priority(gfp_mask, order,
-				zonelist, high_zoneidx, nodemask,
-				preferred_zone, classzone_idx, migratetype);
 		if (page) {
 			goto got_pg;
 		}
@@ -2716,11 +2706,9 @@ rebalance:
 	 * Try direct compaction. The first pass is asynchronous. Subsequent
 	 * attempts after direct reclaim are synchronous
 	 */
-	page = __alloc_pages_direct_compact(gfp_mask, order, zonelist,
-					high_zoneidx, nodemask, alloc_flags,
-					preferred_zone,
-					classzone_idx, migratetype,
-					migration_mode, &contended_compaction,
+	page = __alloc_pages_direct_compact(gfp_mask, order, alloc_flags, ac,
+					migration_mode,
+					&contended_compaction,
 					&deferred_compaction);
 	if (page)
 		goto got_pg;
@@ -2766,12 +2754,8 @@ rebalance:
 		migration_mode = MIGRATE_SYNC_LIGHT;
 
 	/* Try direct reclaim and then allocating */
-	page = __alloc_pages_direct_reclaim(gfp_mask, order,
-					zonelist, high_zoneidx,
-					nodemask,
-					alloc_flags, preferred_zone,
-					classzone_idx, migratetype,
-					&did_some_progress);
+	page = __alloc_pages_direct_reclaim(gfp_mask, order, alloc_flags, ac,
+							&did_some_progress);
 	if (page)
 		goto got_pg;
 
@@ -2787,10 +2771,7 @@ rebalance:
 			if ((current->flags & PF_DUMPCORE) &&
 			    !(gfp_mask & __GFP_NOFAIL))
 				goto nopage;
-			page = __alloc_pages_may_oom(gfp_mask, order,
-					zonelist, high_zoneidx,
-					nodemask, preferred_zone,
-					classzone_idx, migratetype);
+			page = __alloc_pages_may_oom(gfp_mask, order, ac);
 			if (page)
 				goto got_pg;
 
@@ -2808,7 +2789,7 @@ rebalance:
 				 * allocations to prevent needlessly killing
 				 * innocent tasks.
 				 */
-				if (high_zoneidx < ZONE_NORMAL)
+				if (ac->high_zoneidx < ZONE_NORMAL)
 					goto nopage;
 			}
 
@@ -2821,7 +2802,7 @@ rebalance:
 	if (should_alloc_retry(gfp_mask, order, did_some_progress,
 						pages_reclaimed)) {
 		/* Wait for some write requests to complete then retry */
-		wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/50);
+		wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC, HZ/50);
 		goto rebalance;
 	} else {
 		/*
@@ -2829,11 +2810,9 @@ rebalance:
 		 * direct reclaim and reclaim/compaction depends on compaction
 		 * being called after reclaim so call directly if necessary
 		 */
-		page = __alloc_pages_direct_compact(gfp_mask, order, zonelist,
-					high_zoneidx, nodemask, alloc_flags,
-					preferred_zone,
-					classzone_idx, migratetype,
-					migration_mode, &contended_compaction,
+		page = __alloc_pages_direct_compact(gfp_mask, order,
+					alloc_flags, ac, migration_mode,
+					&contended_compaction,
 					&deferred_compaction);
 		if (page)
 			goto got_pg;
@@ -2856,14 +2835,15 @@ struct page *
 __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 			struct zonelist *zonelist, nodemask_t *nodemask)
 {
-	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
-	struct zone *preferred_zone;
 	struct zoneref *preferred_zoneref;
 	struct page *page = NULL;
-	int migratetype = gfpflags_to_migratetype(gfp_mask);
 	unsigned int cpuset_mems_cookie;
 	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET|ALLOC_FAIR;
-	int classzone_idx;
+	struct alloc_context ac = {
+		.high_zoneidx = gfp_zone(gfp_mask),
+		.nodemask = nodemask,
+		.migratetype = gfpflags_to_migratetype(gfp_mask),
+	};
 
 	gfp_mask &= gfp_allowed_mask;
 
@@ -2882,38 +2862,36 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	if (unlikely(!zonelist->_zonerefs->zone))
 		return NULL;
 
-	if (IS_ENABLED(CONFIG_CMA) && migratetype == MIGRATE_MOVABLE)
+	if (IS_ENABLED(CONFIG_CMA) && ac.migratetype == MIGRATE_MOVABLE)
 		alloc_flags |= ALLOC_CMA;
 
 retry_cpuset:
 	cpuset_mems_cookie = read_mems_allowed_begin();
 
+	/* We set it here, as __alloc_pages_slowpath might have changed it */
+	ac.zonelist = zonelist;
 	/* The preferred zone is used for statistics later */
-	preferred_zoneref = first_zones_zonelist(zonelist, high_zoneidx,
-				nodemask ? : &cpuset_current_mems_allowed,
-				&preferred_zone);
-	if (!preferred_zone)
+	preferred_zoneref = first_zones_zonelist(ac.zonelist, ac.high_zoneidx,
+				ac.nodemask ? : &cpuset_current_mems_allowed,
+				&ac.preferred_zone);
+	if (!ac.preferred_zone)
 		goto out;
-	classzone_idx = zonelist_zone_idx(preferred_zoneref);
+	ac.classzone_idx = zonelist_zone_idx(preferred_zoneref);
 
 	/* First allocation attempt */
-	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
-			zonelist, high_zoneidx, alloc_flags,
-			preferred_zone, classzone_idx, migratetype);
+	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, order,
+							alloc_flags, &ac);
 	if (unlikely(!page)) {
 		/*
 		 * Runtime PM, block IO and its error handling path
 		 * can deadlock because I/O on the device might not
 		 * complete.
 		 */
-		gfp_t mask = memalloc_noio_flags(gfp_mask);
-
-		page = __alloc_pages_slowpath(mask, order,
-				zonelist, high_zoneidx, nodemask,
-				preferred_zone, classzone_idx, migratetype);
+		gfp_mask = memalloc_noio_flags(gfp_mask);
+		page = __alloc_pages_slowpath(gfp_mask, order, &ac);
 	}
 
-	trace_mm_page_alloc(page, order, gfp_mask, migratetype);
+	trace_mm_page_alloc(page, order, gfp_mask, ac.migratetype);
 
 out:
 	/*
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
