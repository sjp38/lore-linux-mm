Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f46.google.com (mail-ee0-f46.google.com [74.125.83.46])
	by kanga.kvack.org (Postfix) with ESMTP id 4EEAA6B0038
	for <linux-mm@kvack.org>; Wed, 14 May 2014 16:29:37 -0400 (EDT)
Received: by mail-ee0-f46.google.com with SMTP id t10so66846eei.19
        for <linux-mm@kvack.org>; Wed, 14 May 2014 13:29:36 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r44si2483126eeo.64.2014.05.14.13.29.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 May 2014 13:29:36 -0700 (PDT)
Date: Wed, 14 May 2014 21:29:28 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 05/19] mm: page_alloc: Calculate classzone_idx once from
 the zonelist ref
Message-ID: <20140514202928.GB23991@suse.de>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
 <1399974350-11089-6-git-send-email-mgorman@suse.de>
 <20140513152556.d14e3eaff8949a7010c02686@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140513152556.d14e3eaff8949a7010c02686@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Tue, May 13, 2014 at 03:25:56PM -0700, Andrew Morton wrote:
> On Tue, 13 May 2014 10:45:36 +0100 Mel Gorman <mgorman@suse.de> wrote:
> 
> > There is no need to calculate zone_idx(preferred_zone) multiple times
> > or use the pgdat to figure it out.
> > 
> 
> This one falls afoul of pending mm/next changes in non-trivial ways.

This should apply on top of what you already have. Thanks.

---8<---
mm: page_alloc: Calculate classzone_idx once from the zonelist ref

There is no need to calculate zone_idx(preferred_zone) multiple times
or use the pgdat to figure it out.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Rik van Riel <riel@redhat.com>
---
 mm/page_alloc.c | 60 +++++++++++++++++++++++++++++++++------------------------
 1 file changed, 35 insertions(+), 25 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7ce44f9..606eecf 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1948,11 +1948,10 @@ static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
 static struct page *
 get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 		struct zonelist *zonelist, int high_zoneidx, int alloc_flags,
-		struct zone *preferred_zone, int migratetype)
+		struct zone *preferred_zone, int classzone_idx, int migratetype)
 {
 	struct zoneref *z;
 	struct page *page = NULL;
-	int classzone_idx;
 	struct zone *zone;
 	nodemask_t *allowednodes = NULL;/* zonelist_cache approximation */
 	int zlc_active = 0;		/* set if using zonelist_cache */
@@ -1960,7 +1959,6 @@ get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 	bool consider_zone_dirty = (alloc_flags & ALLOC_WMARK_LOW) &&
 				(gfp_mask & __GFP_WRITE);
 
-	classzone_idx = zone_idx(preferred_zone);
 zonelist_scan:
 	/*
 	 * Scan zonelist, looking for a zone with enough free.
@@ -2218,7 +2216,7 @@ static inline struct page *
 __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
 	nodemask_t *nodemask, struct zone *preferred_zone,
-	int migratetype)
+	int classzone_idx, int migratetype)
 {
 	struct page *page;
 
@@ -2236,7 +2234,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask,
 		order, zonelist, high_zoneidx,
 		ALLOC_WMARK_HIGH|ALLOC_CPUSET,
-		preferred_zone, migratetype);
+		preferred_zone, classzone_idx, migratetype);
 	if (page)
 		goto out;
 
@@ -2271,7 +2269,7 @@ static struct page *
 __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
 	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
-	int migratetype, enum migrate_mode mode,
+	int classzone_idx, int migratetype, enum migrate_mode mode,
 	bool *contended_compaction, bool *deferred_compaction,
 	unsigned long *did_some_progress)
 {
@@ -2299,7 +2297,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 		page = get_page_from_freelist(gfp_mask, nodemask,
 				order, zonelist, high_zoneidx,
 				alloc_flags & ~ALLOC_NO_WATERMARKS,
-				preferred_zone, migratetype);
+				preferred_zone, classzone_idx, migratetype);
 		if (page) {
 			preferred_zone->compact_blockskip_flush = false;
 			compaction_defer_reset(preferred_zone, order, true);
@@ -2331,7 +2329,8 @@ static inline struct page *
 __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
 	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
-	int migratetype, enum migrate_mode mode, bool *contended_compaction,
+	int classzone_idx, int migratetype,
+	enum migrate_mode mode, bool *contended_compaction,
 	bool *deferred_compaction, unsigned long *did_some_progress)
 {
 	return NULL;
@@ -2387,7 +2386,7 @@ static inline struct page *
 __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
 	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
-	int migratetype, unsigned long *did_some_progress)
+	int classzone_idx, int migratetype, unsigned long *did_some_progress)
 {
 	struct page *page = NULL;
 	bool drained = false;
@@ -2405,7 +2404,8 @@ retry:
 	page = get_page_from_freelist(gfp_mask, nodemask, order,
 					zonelist, high_zoneidx,
 					alloc_flags & ~ALLOC_NO_WATERMARKS,
-					preferred_zone, migratetype);
+					preferred_zone, classzone_idx,
+					migratetype);
 
 	/*
 	 * If an allocation failed after direct reclaim, it could be because
@@ -2430,14 +2430,14 @@ static inline struct page *
 __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
 	nodemask_t *nodemask, struct zone *preferred_zone,
-	int migratetype)
+	int classzone_idx, int migratetype)
 {
 	struct page *page;
 
 	do {
 		page = get_page_from_freelist(gfp_mask, nodemask, order,
 			zonelist, high_zoneidx, ALLOC_NO_WATERMARKS,
-			preferred_zone, migratetype);
+			preferred_zone, classzone_idx, migratetype);
 
 		if (!page && gfp_mask & __GFP_NOFAIL)
 			wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/50);
@@ -2538,7 +2538,7 @@ static inline struct page *
 __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
 	nodemask_t *nodemask, struct zone *preferred_zone,
-	int migratetype)
+	int classzone_idx, int migratetype)
 {
 	const gfp_t wait = gfp_mask & __GFP_WAIT;
 	struct page *page = NULL;
@@ -2587,15 +2587,19 @@ restart:
 	 * Find the true preferred zone if the allocation is unconstrained by
 	 * cpusets.
 	 */
-	if (!(alloc_flags & ALLOC_CPUSET) && !nodemask)
-		first_zones_zonelist(zonelist, high_zoneidx, NULL,
-					&preferred_zone);
+	if (!(alloc_flags & ALLOC_CPUSET) && !nodemask) {
+		struct zoneref *preferred_zoneref;
+		preferred_zoneref = first_zones_zonelist(zonelist, high_zoneidx,
+				nodemask ? : &cpuset_current_mems_allowed,
+				&preferred_zone);
+		classzone_idx = zonelist_zone_idx(preferred_zoneref);
+	}
 
 rebalance:
 	/* This is the last chance, in general, before the goto nopage. */
 	page = get_page_from_freelist(gfp_mask, nodemask, order, zonelist,
 			high_zoneidx, alloc_flags & ~ALLOC_NO_WATERMARKS,
-			preferred_zone, migratetype);
+			preferred_zone, classzone_idx, migratetype);
 	if (page)
 		goto got_pg;
 
@@ -2610,7 +2614,7 @@ rebalance:
 
 		page = __alloc_pages_high_priority(gfp_mask, order,
 				zonelist, high_zoneidx, nodemask,
-				preferred_zone, migratetype);
+				preferred_zone, classzone_idx, migratetype);
 		if (page) {
 			goto got_pg;
 		}
@@ -2641,7 +2645,8 @@ rebalance:
 	 */
 	page = __alloc_pages_direct_compact(gfp_mask, order, zonelist,
 					high_zoneidx, nodemask, alloc_flags,
-					preferred_zone, migratetype,
+					preferred_zone,
+					classzone_idx, migratetype,
 					migration_mode, &contended_compaction,
 					&deferred_compaction,
 					&did_some_progress);
@@ -2671,7 +2676,8 @@ rebalance:
 					zonelist, high_zoneidx,
 					nodemask,
 					alloc_flags, preferred_zone,
-					migratetype, &did_some_progress);
+					classzone_idx, migratetype,
+					&did_some_progress);
 	if (page)
 		goto got_pg;
 
@@ -2690,7 +2696,7 @@ rebalance:
 			page = __alloc_pages_may_oom(gfp_mask, order,
 					zonelist, high_zoneidx,
 					nodemask, preferred_zone,
-					migratetype);
+					classzone_idx, migratetype);
 			if (page)
 				goto got_pg;
 
@@ -2731,7 +2737,8 @@ rebalance:
 		 */
 		page = __alloc_pages_direct_compact(gfp_mask, order, zonelist,
 					high_zoneidx, nodemask, alloc_flags,
-					preferred_zone, migratetype,
+					preferred_zone,
+					classzone_idx, migratetype,
 					migration_mode, &contended_compaction,
 					&deferred_compaction,
 					&did_some_progress);
@@ -2760,10 +2767,12 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 {
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
 	struct zone *preferred_zone;
+	struct zoneref *preferred_zoneref;
 	struct page *page = NULL;
 	int migratetype = allocflags_to_migratetype(gfp_mask);
 	unsigned int cpuset_mems_cookie;
 	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET|ALLOC_FAIR;
+	int classzone_idx;
 
 	gfp_mask &= gfp_allowed_mask;
 
@@ -2786,11 +2795,12 @@ retry_cpuset:
 	cpuset_mems_cookie = read_mems_allowed_begin();
 
 	/* The preferred zone is used for statistics later */
-	first_zones_zonelist(zonelist, high_zoneidx,
+	preferred_zoneref = first_zones_zonelist(zonelist, high_zoneidx,
 				nodemask ? : &cpuset_current_mems_allowed,
 				&preferred_zone);
 	if (!preferred_zone)
 		goto out;
+	classzone_idx = zonelist_zone_idx(preferred_zoneref);
 
 #ifdef CONFIG_CMA
 	if (allocflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
@@ -2800,7 +2810,7 @@ retry:
 	/* First allocation attempt */
 	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
 			zonelist, high_zoneidx, alloc_flags,
-			preferred_zone, migratetype);
+			preferred_zone, classzone_idx, migratetype);
 	if (unlikely(!page)) {
 		/*
 		 * The first pass makes sure allocations are spread
@@ -2826,7 +2836,7 @@ retry:
 		gfp_mask = memalloc_noio_flags(gfp_mask);
 		page = __alloc_pages_slowpath(gfp_mask, order,
 				zonelist, high_zoneidx, nodemask,
-				preferred_zone, migratetype);
+				preferred_zone, classzone_idx, migratetype);
 	}
 
 	trace_mm_page_alloc(page, order, gfp_mask, migratetype);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
