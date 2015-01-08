Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id B00B66B006C
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 05:33:27 -0500 (EST)
Received: by mail-wg0-f54.google.com with SMTP id z12so1792981wgg.13
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 02:33:27 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c6si12174478wix.107.2015.01.08.02.33.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 Jan 2015 02:33:25 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH V5 2/4] mm, page_alloc: reduce number of alloc_pages* functions' parameters
Date: Thu,  8 Jan 2015 11:33:09 +0100
Message-Id: <1420713191-17509-3-git-send-email-vbabka@suse.cz>
In-Reply-To: <1420713191-17509-1-git-send-email-vbabka@suse.cz>
References: <1420713191-17509-1-git-send-email-vbabka@suse.cz>
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

add/remove: 0/0 grow/shrink: 1/2 up/down: 127/-310 (-183)
function                                     old     new   delta
get_page_from_freelist                      2525    2652    +127
__alloc_pages_direct_compact                 329     283     -46
__alloc_pages_nodemask                      2564    2300    -264

checkstack.pl:

function                            old    new
__alloc_pages_nodemask              248    200
get_page_from_freelist              168    184
__alloc_pages_direct_compact         40     24

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Michal Hocko <mhocko@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_alloc.c | 229 ++++++++++++++++++++++++++------------------------------
 1 file changed, 108 insertions(+), 121 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4060ad2b..bdbae0a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -232,6 +232,27 @@ EXPORT_SYMBOL(nr_node_ids);
 EXPORT_SYMBOL(nr_online_nodes);
 #endif
 
+/*
+ * Structure for holding the mostly immutable allocation parameters passed
+ * between alloc_pages* family of functions.
+ *
+ * nodemask, migratetype and high_zoneidx are initialized only once in
+ * __alloc_pages_nodemask() and then never change.
+ *
+ * zonelist, preferred_zone and classzone_idx are set first in
+ * __alloc_pages_nodemask() for the fast path, and might be later changed
+ * in __alloc_pages_slowpath(). All other functions pass the whole strucure
+ * by a const pointer.
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
@@ -2004,10 +2025,10 @@ static void reset_alloc_batches(struct zone *preferred_zone)
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
@@ -2026,8 +2047,8 @@ zonelist_scan:
 	 * Scan zonelist, looking for a zone with enough free.
 	 * See also __cpuset_node_allowed() comment in kernel/cpuset.c.
 	 */
-	for_each_zone_zonelist_nodemask(zone, z, zonelist,
-						high_zoneidx, nodemask) {
+	for_each_zone_zonelist_nodemask(zone, z, zonelist, ac->high_zoneidx,
+								ac->nodemask) {
 		unsigned long mark;
 
 		if (IS_ENABLED(CONFIG_NUMA) && zlc_active &&
@@ -2044,7 +2065,7 @@ zonelist_scan:
 		 * time the page has in memory before being reclaimed.
 		 */
 		if (alloc_flags & ALLOC_FAIR) {
-			if (!zone_local(preferred_zone, zone))
+			if (!zone_local(ac->preferred_zone, zone))
 				break;
 			if (test_bit(ZONE_FAIR_DEPLETED, &zone->flags)) {
 				nr_fair_skipped++;
@@ -2082,7 +2103,7 @@ zonelist_scan:
 
 		mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
 		if (!zone_watermark_ok(zone, order, mark,
-				       classzone_idx, alloc_flags)) {
+				       ac->classzone_idx, alloc_flags)) {
 			int ret;
 
 			/* Checked here to keep the fast path fast */
@@ -2103,7 +2124,7 @@ zonelist_scan:
 			}
 
 			if (zone_reclaim_mode == 0 ||
-			    !zone_allows_reclaim(preferred_zone, zone))
+			    !zone_allows_reclaim(ac->preferred_zone, zone))
 				goto this_zone_full;
 
 			/*
@@ -2125,7 +2146,7 @@ zonelist_scan:
 			default:
 				/* did we reclaim enough */
 				if (zone_watermark_ok(zone, order, mark,
-						classzone_idx, alloc_flags))
+						ac->classzone_idx, alloc_flags))
 					goto try_this_zone;
 
 				/*
@@ -2146,8 +2167,8 @@ zonelist_scan:
 		}
 
 try_this_zone:
-		page = buffered_rmqueue(preferred_zone, zone, order,
-						gfp_mask, migratetype);
+		page = buffered_rmqueue(ac->preferred_zone, zone, order,
+						gfp_mask, ac->migratetype);
 		if (page) {
 			if (prep_new_page(page, order, gfp_mask, alloc_flags))
 				goto try_this_zone;
@@ -2170,7 +2191,7 @@ this_zone_full:
 		alloc_flags &= ~ALLOC_FAIR;
 		if (nr_fair_skipped) {
 			zonelist_rescan = true;
-			reset_alloc_batches(preferred_zone);
+			reset_alloc_batches(ac->preferred_zone);
 		}
 		if (nr_online_nodes > 1)
 			zonelist_rescan = true;
@@ -2292,9 +2313,7 @@ should_alloc_retry(gfp_t gfp_mask, unsigned int order,
 
 static inline struct page *
 __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
-	struct zonelist *zonelist, enum zone_type high_zoneidx,
-	nodemask_t *nodemask, struct zone *preferred_zone,
-	int classzone_idx, int migratetype, unsigned long *did_some_progress)
+	const struct alloc_context *ac, unsigned long *did_some_progress)
 {
 	struct page *page;
 
@@ -2307,7 +2326,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	 * Acquire the per-zone oom lock for each zone.  If that
 	 * fails, somebody else is making progress for us.
 	 */
-	if (!oom_zonelist_trylock(zonelist, gfp_mask)) {
+	if (!oom_zonelist_trylock(ac->zonelist, gfp_mask)) {
 		*did_some_progress = 1;
 		schedule_timeout_uninterruptible(1);
 		return NULL;
@@ -2326,10 +2345,8 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
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
 
@@ -2341,7 +2358,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 		if (order > PAGE_ALLOC_COSTLY_ORDER)
 			goto out;
 		/* The OOM killer does not needlessly kill tasks for lowmem */
-		if (high_zoneidx < ZONE_NORMAL)
+		if (ac->high_zoneidx < ZONE_NORMAL)
 			goto out;
 		/* The OOM killer does not compensate for light reclaim */
 		if (!(gfp_mask & __GFP_FS))
@@ -2357,10 +2374,10 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 			goto out;
 	}
 	/* Exhausted what can be done so it's blamo time */
-	out_of_memory(zonelist, gfp_mask, order, nodemask, false);
+	out_of_memory(ac->zonelist, gfp_mask, order, ac->nodemask, false);
 	*did_some_progress = 1;
 out:
-	oom_zonelist_unlock(zonelist, gfp_mask);
+	oom_zonelist_unlock(ac->zonelist, gfp_mask);
 	return page;
 }
 
@@ -2368,10 +2385,9 @@ out:
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
@@ -2380,10 +2396,10 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
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
@@ -2402,10 +2418,8 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
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
@@ -2429,10 +2443,9 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
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
@@ -2440,8 +2453,8 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 
 /* Perform direct synchronous page reclaim */
 static int
-__perform_reclaim(gfp_t gfp_mask, unsigned int order, struct zonelist *zonelist,
-		  nodemask_t *nodemask)
+__perform_reclaim(gfp_t gfp_mask, unsigned int order,
+					const struct alloc_context *ac)
 {
 	struct reclaim_state reclaim_state;
 	int progress;
@@ -2455,7 +2468,8 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order, struct zonelist *zonelist,
 	reclaim_state.reclaimed_slab = 0;
 	current->reclaim_state = &reclaim_state;
 
-	progress = try_to_free_pages(zonelist, order, gfp_mask, nodemask);
+	progress = try_to_free_pages(ac->zonelist, order, gfp_mask,
+								ac->nodemask);
 
 	current->reclaim_state = NULL;
 	lockdep_clear_current_reclaim_state();
@@ -2469,28 +2483,23 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order, struct zonelist *zonelist,
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
@@ -2511,36 +2520,30 @@ retry:
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
@@ -2599,9 +2602,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 
 static inline struct page *
 __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
-	struct zonelist *zonelist, enum zone_type high_zoneidx,
-	nodemask_t *nodemask, struct zone *preferred_zone,
-	int classzone_idx, int migratetype)
+						struct alloc_context *ac)
 {
 	const gfp_t wait = gfp_mask & __GFP_WAIT;
 	struct page *page = NULL;
@@ -2637,8 +2638,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 
 retry:
 	if (!(gfp_mask & __GFP_NO_KSWAPD))
-		wake_all_kswapds(order, zonelist, high_zoneidx,
-				preferred_zone, nodemask);
+		wake_all_kswapds(order, ac);
 
 	/*
 	 * OK, we're below the kswapd watermark and have kicked background
@@ -2651,17 +2651,16 @@ retry:
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
 
 	/* This is the last chance, in general, before the goto nopage. */
-	page = get_page_from_freelist(gfp_mask, nodemask, order, zonelist,
-			high_zoneidx, alloc_flags & ~ALLOC_NO_WATERMARKS,
-			preferred_zone, classzone_idx, migratetype);
+	page = get_page_from_freelist(gfp_mask, order,
+				alloc_flags & ~ALLOC_NO_WATERMARKS, ac);
 	if (page)
 		goto got_pg;
 
@@ -2672,11 +2671,10 @@ retry:
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
@@ -2705,11 +2703,9 @@ retry:
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
@@ -2755,12 +2751,8 @@ retry:
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
 
@@ -2774,17 +2766,15 @@ retry:
 		 * start OOM killing tasks.
 		 */
 		if (!did_some_progress) {
-			page = __alloc_pages_may_oom(gfp_mask, order, zonelist,
-						high_zoneidx, nodemask,
-						preferred_zone, classzone_idx,
-						migratetype,&did_some_progress);
+			page = __alloc_pages_may_oom(gfp_mask, order, ac,
+							&did_some_progress);
 			if (page)
 				goto got_pg;
 			if (!did_some_progress)
 				goto nopage;
 		}
 		/* Wait for some write requests to complete then retry */
-		wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/50);
+		wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC, HZ/50);
 		goto retry;
 	} else {
 		/*
@@ -2792,11 +2782,9 @@ retry:
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
@@ -2815,15 +2803,16 @@ struct page *
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
 	gfp_t alloc_mask; /* The gfp_t that was actually used for allocation */
+	struct alloc_context ac = {
+		.high_zoneidx = gfp_zone(gfp_mask),
+		.nodemask = nodemask,
+		.migratetype = gfpflags_to_migratetype(gfp_mask),
+	};
 
 	gfp_mask &= gfp_allowed_mask;
 
@@ -2842,25 +2831,25 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
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
 	alloc_mask = gfp_mask|__GFP_HARDWALL;
-	page = get_page_from_freelist(alloc_mask, nodemask, order, zonelist,
-			high_zoneidx, alloc_flags, preferred_zone,
-			classzone_idx, migratetype);
+	page = get_page_from_freelist(alloc_mask, order, alloc_flags, &ac);
 	if (unlikely(!page)) {
 		/*
 		 * Runtime PM, block IO and its error handling path
@@ -2869,15 +2858,13 @@ retry_cpuset:
 		 */
 		alloc_mask = memalloc_noio_flags(gfp_mask);
 
-		page = __alloc_pages_slowpath(alloc_mask, order,
-				zonelist, high_zoneidx, nodemask,
-				preferred_zone, classzone_idx, migratetype);
+		page = __alloc_pages_slowpath(alloc_mask, order, &ac);
 	}
 
 	if (kmemcheck_enabled && page)
 		kmemcheck_pagealloc_alloc(page, order, gfp_mask);
 
-	trace_mm_page_alloc(page, order, alloc_mask, migratetype);
+	trace_mm_page_alloc(page, order, alloc_mask, ac.migratetype);
 
 out:
 	/*
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
