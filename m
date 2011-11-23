Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1469D6B00C2
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 22:32:47 -0500 (EST)
Received: by yenm12 with SMTP id m12so1251550yen.14
        for <linux-mm@kvack.org>; Tue, 22 Nov 2011 19:32:43 -0800 (PST)
Date: Tue, 22 Nov 2011 19:32:40 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch for-3.2-rc3] cpusets: stall when updating mems_allowed
 for mempolicy or disjoint nodemask
In-Reply-To: <4ECC5FC8.9070500@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1111221902300.30008@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1111161307020.23629@chino.kir.corp.google.com> <4EC4C603.8050704@cn.fujitsu.com> <alpine.DEB.2.00.1111171328120.15918@chino.kir.corp.google.com> <4EC62AEA.2030602@cn.fujitsu.com> <alpine.DEB.2.00.1111181545170.24487@chino.kir.corp.google.com>
 <4ECC5FC8.9070500@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miao Xie <miaox@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Paul Menage <paul@paulmenage.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 23 Nov 2011, Miao Xie wrote:

> Yes, what you said is right.
> But in fact, on the kernel where MAX_NUMNODES <= BITS_PER_LONG, the same problem
> can also occur.
> 	task1			task1's mems	task2
> 	alloc page		2-3
> 	  alloc on node1? NO	2-3
> 				2-3		change mems from 2-3 to 1-2
> 				1-2		rebind task1's mpol
> 				1-2		  set new bits
> 				1-2		change mems from 0-1 to 0
> 				1-2		rebind task1's mpol
> 				0-1		  set new bits
> 	  alloc on node2? NO	0-1
> 	  ...
> 	can't alloc page
> 	  goto oom
> 

One of the major reasons why changing cpuset.mems can take >30s is because 
of lengthy delays in the page allocator because it continuously loops 
while trying reclaim or killing a thread and trying to allocate a page.

I think we should be able to optimize this by dropping it when it's not 
required and moving it to get_page_from_freelist() which is the only thing 
that cares about cpuset_zone_allowed_softwall().

Something like this:

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1643,17 +1643,29 @@ static void zlc_clear_zones_full(struct zonelist *zonelist)
 static struct page *
 get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 		struct zonelist *zonelist, int high_zoneidx, int alloc_flags,
-		struct zone *preferred_zone, int migratetype)
+		struct zone **preferred_zone, int migratetype)
 {
 	struct zoneref *z;
 	struct page *page = NULL;
 	int classzone_idx;
 	struct zone *zone;
-	nodemask_t *allowednodes = NULL;/* zonelist_cache approximation */
+	nodemask_t *allowednodes = NULL;
 	int zlc_active = 0;		/* set if using zonelist_cache */
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
 
-	classzone_idx = zone_idx(preferred_zone);
+	get_mems_allowed();
+	/*
+	 * preferred_zone must come from an allowed node if the allocation is
+	 * constrained to either a mempolicy (nodemask != NULL) or otherwise
+	 * limited by cpusets.
+	 */
+	if (alloc_flags & ALLOC_CPUSET)
+		allowednodes = nodemask ? : &cpuset_current_mems_allowed;
+
+	first_zones_zonelist(zonelist, high_zoneidx, allowednodes, 
+				preferred_zone);
+	classzone_idx = zone_idx(*preferred_zone);
+	allowednodes = NULL;
 zonelist_scan:
 	/*
 	 * Scan zonelist, looking for a zone with enough free.
@@ -1717,7 +1729,7 @@ zonelist_scan:
 		}
 
 try_this_zone:
-		page = buffered_rmqueue(preferred_zone, zone, order,
+		page = buffered_rmqueue(*preferred_zone, zone, order,
 						gfp_mask, migratetype);
 		if (page)
 			break;
@@ -1731,6 +1743,7 @@ this_zone_full:
 		zlc_active = 0;
 		goto zonelist_scan;
 	}
+	put_mems_allowed();
 	return page;
 }
 
@@ -1832,7 +1845,7 @@ should_alloc_retry(gfp_t gfp_mask, unsigned int order,
 static inline struct page *
 __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
-	nodemask_t *nodemask, struct zone *preferred_zone,
+	nodemask_t *nodemask, struct zone **preferred_zone,
 	int migratetype)
 {
 	struct page *page;
@@ -1885,13 +1898,13 @@ out:
 static struct page *
 __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
-	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
+	nodemask_t *nodemask, int alloc_flags, struct zone **preferred_zone,
 	int migratetype, unsigned long *did_some_progress,
 	bool sync_migration)
 {
 	struct page *page;
 
-	if (!order || compaction_deferred(preferred_zone))
+	if (!order || compaction_deferred(*preferred_zone))
 		return NULL;
 
 	current->flags |= PF_MEMALLOC;
@@ -1909,8 +1922,8 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 				alloc_flags, preferred_zone,
 				migratetype);
 		if (page) {
-			preferred_zone->compact_considered = 0;
-			preferred_zone->compact_defer_shift = 0;
+			*preferred_zone->compact_considered = 0;
+			*preferred_zone->compact_defer_shift = 0;
 			count_vm_event(COMPACTSUCCESS);
 			return page;
 		}
@@ -1921,7 +1934,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 		 * but not enough to satisfy watermarks.
 		 */
 		count_vm_event(COMPACTFAIL);
-		defer_compaction(preferred_zone);
+		defer_compaction(*preferred_zone);
 
 		cond_resched();
 	}
@@ -1932,7 +1945,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 static inline struct page *
 __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
-	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
+	nodemask_t *nodemask, int alloc_flags, struct zone **preferred_zone,
 	int migratetype, unsigned long *did_some_progress,
 	bool sync_migration)
 {
@@ -1944,7 +1957,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 static inline struct page *
 __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
-	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
+	nodemask_t *nodemask, int alloc_flags, struct zone **preferred_zone,
 	int migratetype, unsigned long *did_some_progress)
 {
 	struct page *page = NULL;
@@ -2001,7 +2014,7 @@ retry:
 static inline struct page *
 __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
-	nodemask_t *nodemask, struct zone *preferred_zone,
+	nodemask_t *nodemask, struct zone **preferred_zone,
 	int migratetype)
 {
 	struct page *page;
@@ -2012,7 +2025,8 @@ __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
 			preferred_zone, migratetype);
 
 		if (!page && gfp_mask & __GFP_NOFAIL)
-			wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/50);
+			wait_iff_congested(*preferred_zone, BLK_RW_ASYNC,
+					   HZ/50);
 	} while (!page && (gfp_mask & __GFP_NOFAIL));
 
 	return page;
@@ -2075,7 +2089,7 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 static inline struct page *
 __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
-	nodemask_t *nodemask, struct zone *preferred_zone,
+	nodemask_t *nodemask, struct zone **preferred_zone,
 	int migratetype)
 {
 	const gfp_t wait = gfp_mask & __GFP_WAIT;
@@ -2110,7 +2124,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 restart:
 	if (!(gfp_mask & __GFP_NO_KSWAPD))
 		wake_all_kswapd(order, zonelist, high_zoneidx,
-						zone_idx(preferred_zone));
+						zone_idx(*preferred_zone));
 
 	/*
 	 * OK, we're below the kswapd watermark and have kicked background
@@ -2119,14 +2133,6 @@ restart:
 	 */
 	alloc_flags = gfp_to_alloc_flags(gfp_mask);
 
-	/*
-	 * Find the true preferred zone if the allocation is unconstrained by
-	 * cpusets.
-	 */
-	if (!(alloc_flags & ALLOC_CPUSET) && !nodemask)
-		first_zones_zonelist(zonelist, high_zoneidx, NULL,
-					&preferred_zone);
-
 rebalance:
 	/* This is the last chance, in general, before the goto nopage. */
 	page = get_page_from_freelist(gfp_mask, nodemask, order, zonelist,
@@ -2220,7 +2226,7 @@ rebalance:
 	pages_reclaimed += did_some_progress;
 	if (should_alloc_retry(gfp_mask, order, pages_reclaimed)) {
 		/* Wait for some write requests to complete then retry */
-		wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/50);
+		wait_iff_congested(*preferred_zone, BLK_RW_ASYNC, HZ/50);
 		goto rebalance;
 	} else {
 		/*
@@ -2277,25 +2283,17 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	if (unlikely(!zonelist->_zonerefs->zone))
 		return NULL;
 
-	get_mems_allowed();
-	/* The preferred zone is used for statistics later */
-	first_zones_zonelist(zonelist, high_zoneidx,
-				nodemask ? : &cpuset_current_mems_allowed,
-				&preferred_zone);
-	if (!preferred_zone) {
-		put_mems_allowed();
-		return NULL;
-	}
-
 	/* First allocation attempt */
 	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
 			zonelist, high_zoneidx, ALLOC_WMARK_LOW|ALLOC_CPUSET,
-			preferred_zone, migratetype);
-	if (unlikely(!page))
+			&preferred_zone, migratetype);
+	if (unlikely(!page)) {
+		if (!preferred_zone)
+			return NULL;
 		page = __alloc_pages_slowpath(gfp_mask, order,
 				zonelist, high_zoneidx, nodemask,
-				preferred_zone, migratetype);
-	put_mems_allowed();
+				&preferred_zone, migratetype);
+	}
 
 	trace_mm_page_alloc(page, order, gfp_mask, migratetype);
 	return page;

This would significantly reduce the amount of time that it takes to write 
to cpuset.mems because we drop get_mems_allowed() between allocation 
attempts.  We really, really want to do this anyway because it's possible 
that a cpuset is being expanded to a larger set of nodes and they are 
inaccessible to concurrent memory allocations because the page allocator 
is holding get_mems_allowed() while looping and trying to find more 
memory.

Comments?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
