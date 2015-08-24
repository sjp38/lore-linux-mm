Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id F076882F5F
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 08:10:15 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so48121285wid.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 05:10:15 -0700 (PDT)
Received: from outbound-smtp01.blacknight.com (outbound-smtp01.blacknight.com. [81.17.249.7])
        by mx.google.com with ESMTPS id cz4si31637973wjb.208.2015.08.24.05.09.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Mon, 24 Aug 2015 05:09:55 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp01.blacknight.com (Postfix) with ESMTPS id CA47299122
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 12:09:54 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 09/12] mm, page_alloc: Delete the zonelist_cache
Date: Mon, 24 Aug 2015 13:09:48 +0100
Message-Id: <1440418191-10894-10-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
References: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

The zonelist cache (zlc) was introduced to skip over zones that were
recently known to be full. This avoided expensive operations such as the
cpuset checks, watermark calculations and zone_reclaim. The situation
today is different and the complexity of zlc is harder to justify.

1) The cpuset checks are no-ops unless a cpuset is active and in general are
   a lot cheaper.

2) zone_reclaim is now disabled by default and I suspect that was a large
   source of the cost that zlc wanted to avoid. When it is enabled, it's
   known to be a major source of stalling when nodes fill up and it's
   unwise to hit every other user with the overhead.

3) Watermark checks are expensive to calculate for high-order
   allocation requests. Later patches in this series will reduce the cost
   of the watermark checking.

4) The most important issue is that in the current implementation it
   is possible for a failed THP allocation to mark a zone full for order-0
   allocations and cause a fallback to remote nodes.

The last issue could be addressed with additional complexity but as the
benefit of zlc is questionable, it is better to remove it.  If stalls
due to zone_reclaim are ever reported then an alternative would be to
introduce deferring logic based on a timeout inside zone_reclaim itself
and leave the page allocator fast paths alone.

The impact on page-allocator microbenchmarks is negligible as they don't
hit the paths where the zlc comes into play. Most page-reclaim related
workloads showed no noticable difference as a result of the removal.

The impact was noticeable in a workload called "stutter". One part uses a
lot of anonymous memory, a second measures mmap latency and a third copies
a large file. In an ideal world the latency application would not notice
the mmap latency.  On a 2-node machine the results of this patch are

2-node machine stutter
                             4.2.0-rc7             4.2.0-rc7
                               vanilla            nozlc-v3r8
Min         mmap     21.2266 (  0.00%)     21.0431 (  0.86%)
1st-qrtle   mmap     24.3096 (  0.00%)     28.6013 (-17.65%)
2nd-qrtle   mmap     28.5789 (  0.00%)     29.2909 ( -2.49%)
3rd-qrtle   mmap     29.1970 (  0.00%)     29.9426 ( -2.55%)
Max-90%     mmap     33.6982 (  0.00%)     34.0195 ( -0.95%)
Max-93%     mmap     34.1751 (  0.00%)     34.3753 ( -0.59%)
Max-95%     mmap     38.7323 (  0.00%)     35.0257 (  9.57%)
Max-99%     mmap     93.7964 (  0.00%)     89.8644 (  4.19%)
Max         mmap 494274.6891 (  0.00%)  47520.4050 ( 90.39%)
Mean        mmap     48.2708 (  0.00%)     46.5963 (  3.47%)
Best99%Mean mmap     29.0087 (  0.00%)     30.2834 ( -4.39%)
Best95%Mean mmap     27.3926 (  0.00%)     29.2582 ( -6.81%)
Best90%Mean mmap     27.0060 (  0.00%)     28.9746 ( -7.29%)
Best50%Mean mmap     24.9743 (  0.00%)     27.8092 (-11.35%)
Best10%Mean mmap     22.9546 (  0.00%)     24.7627 ( -7.88%)
Best5%Mean  mmap     21.9682 (  0.00%)     23.3681 ( -6.37%)
Best1%Mean  mmap     21.3082 (  0.00%)     21.2479 (  0.28%)

Note that the maximum stall latency went from 494 seconds to 47 seconds
which is still awful but an improvement. The milage here varies considerably
as a 4-node machine that tested an earlier version of this patch went from
a worst case stall time of 6 seconds to 67ms. The nature of the benchmark
is inherently unpredictable as it is hammering the system and the milage
will vary between machines.

There is a secondary impact with potentially more direct reclaim because
zones are now being considered instead of being skipped by zlc. In this
particular test run it did not occur so will not be described. However,
in at least one test the following was observed

1. Direct reclaim rates were higher. This was likely due to direct reclaim
  being entered instead of the zlc disabling a zone and busy looping.
  Busy looping may have the effect of allowing kswapd to make more
  progress and in some cases may be better overall. If this is found then
  the correct action is to put direct reclaimers to sleep on a waitqueue
  and allow kswapd make forward progress. Busy looping on the zlc is even
  worse than when the allocator used to blindly call congestion_wait().

2. There was higher swap activity as direct reclaim was active.

3. Direct reclaim efficiency was lower. This is related to 1 as more
  scanning activity also encountered more pages that could not be
  immediately reclaimed

In that case, the direct page scan and reclaim rates are noticeable but
it is not considered a problem for a few reasons

1. The test is primarily concerned with latency. The mmap attempts are also
   faulted which means there are THP allocation requests. The ZLC could
   cause zones to be disabled causing the process to busy loop instead
   of reclaiming.  This looks like elevated direct reclaim activity but
   it's the correct action to take based on what processes requested.

2. The test hammers reclaim and compaction heavily. The number of successful
   THP faults is highly variable but affects the reclaim stats. It's not a
   realistic or reasonable measure of page reclaim activity.

3. No other page-reclaim intensive workload that was tested showed a problem.

4. If a workload is identified that benefitted from the busy looping then it
   should be fixed by having direct reclaimers sleep on a wait queue until
   woken by kswapd instead of busy looping. We had this class of problem before
   when congestion_waits() with a fixed timeout was a brain damaged decision
   but happened to benefit some workloads.

If a workload is identified that relied on the zlc to busy loop then it
should be fixed correctly and have a direct reclaimer sleep on a waitqueue
until woken by kswapd.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: David Rientjes <rientjes@google.com>
Acked-by: Christoph Lameter <cl@linux.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/mmzone.h |  74 -----------------
 mm/page_alloc.c        | 212 -------------------------------------------------
 2 files changed, 286 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index fc0457d005f8..aef62cc11c80 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -585,75 +585,8 @@ static inline bool zone_is_empty(struct zone *zone)
  * [1]	: No fallback (__GFP_THISNODE)
  */
 #define MAX_ZONELISTS 2
-
-
-/*
- * We cache key information from each zonelist for smaller cache
- * footprint when scanning for free pages in get_page_from_freelist().
- *
- * 1) The BITMAP fullzones tracks which zones in a zonelist have come
- *    up short of free memory since the last time (last_fullzone_zap)
- *    we zero'd fullzones.
- * 2) The array z_to_n[] maps each zone in the zonelist to its node
- *    id, so that we can efficiently evaluate whether that node is
- *    set in the current tasks mems_allowed.
- *
- * Both fullzones and z_to_n[] are one-to-one with the zonelist,
- * indexed by a zones offset in the zonelist zones[] array.
- *
- * The get_page_from_freelist() routine does two scans.  During the
- * first scan, we skip zones whose corresponding bit in 'fullzones'
- * is set or whose corresponding node in current->mems_allowed (which
- * comes from cpusets) is not set.  During the second scan, we bypass
- * this zonelist_cache, to ensure we look methodically at each zone.
- *
- * Once per second, we zero out (zap) fullzones, forcing us to
- * reconsider nodes that might have regained more free memory.
- * The field last_full_zap is the time we last zapped fullzones.
- *
- * This mechanism reduces the amount of time we waste repeatedly
- * reexaming zones for free memory when they just came up low on
- * memory momentarilly ago.
- *
- * The zonelist_cache struct members logically belong in struct
- * zonelist.  However, the mempolicy zonelists constructed for
- * MPOL_BIND are intentionally variable length (and usually much
- * shorter).  A general purpose mechanism for handling structs with
- * multiple variable length members is more mechanism than we want
- * here.  We resort to some special case hackery instead.
- *
- * The MPOL_BIND zonelists don't need this zonelist_cache (in good
- * part because they are shorter), so we put the fixed length stuff
- * at the front of the zonelist struct, ending in a variable length
- * zones[], as is needed by MPOL_BIND.
- *
- * Then we put the optional zonelist cache on the end of the zonelist
- * struct.  This optional stuff is found by a 'zlcache_ptr' pointer in
- * the fixed length portion at the front of the struct.  This pointer
- * both enables us to find the zonelist cache, and in the case of
- * MPOL_BIND zonelists, (which will just set the zlcache_ptr to NULL)
- * to know that the zonelist cache is not there.
- *
- * The end result is that struct zonelists come in two flavors:
- *  1) The full, fixed length version, shown below, and
- *  2) The custom zonelists for MPOL_BIND.
- * The custom MPOL_BIND zonelists have a NULL zlcache_ptr and no zlcache.
- *
- * Even though there may be multiple CPU cores on a node modifying
- * fullzones or last_full_zap in the same zonelist_cache at the same
- * time, we don't lock it.  This is just hint data - if it is wrong now
- * and then, the allocator will still function, perhaps a bit slower.
- */
-
-
-struct zonelist_cache {
-	unsigned short z_to_n[MAX_ZONES_PER_ZONELIST];		/* zone->nid */
-	DECLARE_BITMAP(fullzones, MAX_ZONES_PER_ZONELIST);	/* zone full? */
-	unsigned long last_full_zap;		/* when last zap'd (jiffies) */
-};
 #else
 #define MAX_ZONELISTS 1
-struct zonelist_cache;
 #endif
 
 /*
@@ -671,9 +604,6 @@ struct zoneref {
  * allocation, the other zones are fallback zones, in decreasing
  * priority.
  *
- * If zlcache_ptr is not NULL, then it is just the address of zlcache,
- * as explained above.  If zlcache_ptr is NULL, there is no zlcache.
- * *
  * To speed the reading of the zonelist, the zonerefs contain the zone index
  * of the entry being read. Helper functions to access information given
  * a struct zoneref are
@@ -683,11 +613,7 @@ struct zoneref {
  * zonelist_node_idx()	- Return the index of the node for an entry
  */
 struct zonelist {
-	struct zonelist_cache *zlcache_ptr;		     // NULL or &zlcache
 	struct zoneref _zonerefs[MAX_ZONES_PER_ZONELIST + 1];
-#ifdef CONFIG_NUMA
-	struct zonelist_cache zlcache;			     // optional ...
-#endif
 };
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d176be999b26..aa52a91a7d44 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2266,122 +2266,6 @@ bool zone_watermark_ok_safe(struct zone *z, unsigned int order,
 }
 
 #ifdef CONFIG_NUMA
-/*
- * zlc_setup - Setup for "zonelist cache".  Uses cached zone data to
- * skip over zones that are not allowed by the cpuset, or that have
- * been recently (in last second) found to be nearly full.  See further
- * comments in mmzone.h.  Reduces cache footprint of zonelist scans
- * that have to skip over a lot of full or unallowed zones.
- *
- * If the zonelist cache is present in the passed zonelist, then
- * returns a pointer to the allowed node mask (either the current
- * tasks mems_allowed, or node_states[N_MEMORY].)
- *
- * If the zonelist cache is not available for this zonelist, does
- * nothing and returns NULL.
- *
- * If the fullzones BITMAP in the zonelist cache is stale (more than
- * a second since last zap'd) then we zap it out (clear its bits.)
- *
- * We hold off even calling zlc_setup, until after we've checked the
- * first zone in the zonelist, on the theory that most allocations will
- * be satisfied from that first zone, so best to examine that zone as
- * quickly as we can.
- */
-static nodemask_t *zlc_setup(struct zonelist *zonelist, int alloc_flags)
-{
-	struct zonelist_cache *zlc;	/* cached zonelist speedup info */
-	nodemask_t *allowednodes;	/* zonelist_cache approximation */
-
-	zlc = zonelist->zlcache_ptr;
-	if (!zlc)
-		return NULL;
-
-	if (time_after(jiffies, zlc->last_full_zap + HZ)) {
-		bitmap_zero(zlc->fullzones, MAX_ZONES_PER_ZONELIST);
-		zlc->last_full_zap = jiffies;
-	}
-
-	allowednodes = !in_interrupt() && (alloc_flags & ALLOC_CPUSET) ?
-					&cpuset_current_mems_allowed :
-					&node_states[N_MEMORY];
-	return allowednodes;
-}
-
-/*
- * Given 'z' scanning a zonelist, run a couple of quick checks to see
- * if it is worth looking at further for free memory:
- *  1) Check that the zone isn't thought to be full (doesn't have its
- *     bit set in the zonelist_cache fullzones BITMAP).
- *  2) Check that the zones node (obtained from the zonelist_cache
- *     z_to_n[] mapping) is allowed in the passed in allowednodes mask.
- * Return true (non-zero) if zone is worth looking at further, or
- * else return false (zero) if it is not.
- *
- * This check -ignores- the distinction between various watermarks,
- * such as GFP_HIGH, GFP_ATOMIC, PF_MEMALLOC, ...  If a zone is
- * found to be full for any variation of these watermarks, it will
- * be considered full for up to one second by all requests, unless
- * we are so low on memory on all allowed nodes that we are forced
- * into the second scan of the zonelist.
- *
- * In the second scan we ignore this zonelist cache and exactly
- * apply the watermarks to all zones, even it is slower to do so.
- * We are low on memory in the second scan, and should leave no stone
- * unturned looking for a free page.
- */
-static int zlc_zone_worth_trying(struct zonelist *zonelist, struct zoneref *z,
-						nodemask_t *allowednodes)
-{
-	struct zonelist_cache *zlc;	/* cached zonelist speedup info */
-	int i;				/* index of *z in zonelist zones */
-	int n;				/* node that zone *z is on */
-
-	zlc = zonelist->zlcache_ptr;
-	if (!zlc)
-		return 1;
-
-	i = z - zonelist->_zonerefs;
-	n = zlc->z_to_n[i];
-
-	/* This zone is worth trying if it is allowed but not full */
-	return node_isset(n, *allowednodes) && !test_bit(i, zlc->fullzones);
-}
-
-/*
- * Given 'z' scanning a zonelist, set the corresponding bit in
- * zlc->fullzones, so that subsequent attempts to allocate a page
- * from that zone don't waste time re-examining it.
- */
-static void zlc_mark_zone_full(struct zonelist *zonelist, struct zoneref *z)
-{
-	struct zonelist_cache *zlc;	/* cached zonelist speedup info */
-	int i;				/* index of *z in zonelist zones */
-
-	zlc = zonelist->zlcache_ptr;
-	if (!zlc)
-		return;
-
-	i = z - zonelist->_zonerefs;
-
-	set_bit(i, zlc->fullzones);
-}
-
-/*
- * clear all zones full, called after direct reclaim makes progress so that
- * a zone that was recently full is not skipped over for up to a second
- */
-static void zlc_clear_zones_full(struct zonelist *zonelist)
-{
-	struct zonelist_cache *zlc;	/* cached zonelist speedup info */
-
-	zlc = zonelist->zlcache_ptr;
-	if (!zlc)
-		return;
-
-	bitmap_zero(zlc->fullzones, MAX_ZONES_PER_ZONELIST);
-}
-
 static bool zone_local(struct zone *local_zone, struct zone *zone)
 {
 	return local_zone->node == zone->node;
@@ -2392,28 +2276,7 @@ static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
 	return node_distance(zone_to_nid(local_zone), zone_to_nid(zone)) <
 				RECLAIM_DISTANCE;
 }
-
 #else	/* CONFIG_NUMA */
-
-static nodemask_t *zlc_setup(struct zonelist *zonelist, int alloc_flags)
-{
-	return NULL;
-}
-
-static int zlc_zone_worth_trying(struct zonelist *zonelist, struct zoneref *z,
-				nodemask_t *allowednodes)
-{
-	return 1;
-}
-
-static void zlc_mark_zone_full(struct zonelist *zonelist, struct zoneref *z)
-{
-}
-
-static void zlc_clear_zones_full(struct zonelist *zonelist)
-{
-}
-
 static bool zone_local(struct zone *local_zone, struct zone *zone)
 {
 	return true;
@@ -2423,7 +2286,6 @@ static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
 {
 	return true;
 }
-
 #endif	/* CONFIG_NUMA */
 
 static void reset_alloc_batches(struct zone *preferred_zone)
@@ -2450,9 +2312,6 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 	struct zoneref *z;
 	struct page *page = NULL;
 	struct zone *zone;
-	nodemask_t *allowednodes = NULL;/* zonelist_cache approximation */
-	int zlc_active = 0;		/* set if using zonelist_cache */
-	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
 	int nr_fair_skipped = 0;
 	bool zonelist_rescan;
 
@@ -2467,9 +2326,6 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 								ac->nodemask) {
 		unsigned long mark;
 
-		if (IS_ENABLED(CONFIG_NUMA) && zlc_active &&
-			!zlc_zone_worth_trying(zonelist, z, allowednodes))
-				continue;
 		if (cpusets_mems_enabled() &&
 			(alloc_flags & ALLOC_CPUSET) &&
 			!cpuset_zone_allowed(zone, gfp_mask))
@@ -2527,28 +2383,8 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 			if (alloc_flags & ALLOC_NO_WATERMARKS)
 				goto try_this_zone;
 
-			if (IS_ENABLED(CONFIG_NUMA) &&
-					!did_zlc_setup && nr_online_nodes > 1) {
-				/*
-				 * we do zlc_setup if there are multiple nodes
-				 * and before considering the first zone allowed
-				 * by the cpuset.
-				 */
-				allowednodes = zlc_setup(zonelist, alloc_flags);
-				zlc_active = 1;
-				did_zlc_setup = 1;
-			}
-
 			if (zone_reclaim_mode == 0 ||
 			    !zone_allows_reclaim(ac->preferred_zone, zone))
-				goto this_zone_full;
-
-			/*
-			 * As we may have just activated ZLC, check if the first
-			 * eligible zone has failed zone_reclaim recently.
-			 */
-			if (IS_ENABLED(CONFIG_NUMA) && zlc_active &&
-				!zlc_zone_worth_trying(zonelist, z, allowednodes))
 				continue;
 
 			ret = zone_reclaim(zone, gfp_mask, order);
@@ -2565,19 +2401,6 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 						ac->classzone_idx, alloc_flags))
 					goto try_this_zone;
 
-				/*
-				 * Failed to reclaim enough to meet watermark.
-				 * Only mark the zone full if checking the min
-				 * watermark or if we failed to reclaim just
-				 * 1<<order pages or else the page allocator
-				 * fastpath will prematurely mark zones full
-				 * when the watermark is between the low and
-				 * min watermarks.
-				 */
-				if (((alloc_flags & ALLOC_WMARK_MASK) == ALLOC_WMARK_MIN) ||
-				    ret == ZONE_RECLAIM_SOME)
-					goto this_zone_full;
-
 				continue;
 			}
 		}
@@ -2590,9 +2413,6 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 				goto try_this_zone;
 			return page;
 		}
-this_zone_full:
-		if (IS_ENABLED(CONFIG_NUMA) && zlc_active)
-			zlc_mark_zone_full(zonelist, z);
 	}
 
 	/*
@@ -2613,12 +2433,6 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 			zonelist_rescan = true;
 	}
 
-	if (unlikely(IS_ENABLED(CONFIG_NUMA) && zlc_active)) {
-		/* Disable zlc cache for second zonelist scan */
-		zlc_active = 0;
-		zonelist_rescan = true;
-	}
-
 	if (zonelist_rescan)
 		goto zonelist_scan;
 
@@ -2858,10 +2672,6 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 	if (unlikely(!(*did_some_progress)))
 		return NULL;
 
-	/* After successful reclaim, reconsider all zones for allocation */
-	if (IS_ENABLED(CONFIG_NUMA))
-		zlc_clear_zones_full(ac->zonelist);
-
 retry:
 	page = get_page_from_freelist(gfp_mask, order,
 					alloc_flags & ~ALLOC_NO_WATERMARKS, ac);
@@ -4198,20 +4008,6 @@ static void build_zonelists(pg_data_t *pgdat)
 	build_thisnode_zonelists(pgdat);
 }
 
-/* Construct the zonelist performance cache - see further mmzone.h */
-static void build_zonelist_cache(pg_data_t *pgdat)
-{
-	struct zonelist *zonelist;
-	struct zonelist_cache *zlc;
-	struct zoneref *z;
-
-	zonelist = &pgdat->node_zonelists[0];
-	zonelist->zlcache_ptr = zlc = &zonelist->zlcache;
-	bitmap_zero(zlc->fullzones, MAX_ZONES_PER_ZONELIST);
-	for (z = zonelist->_zonerefs; z->zone; z++)
-		zlc->z_to_n[z - zonelist->_zonerefs] = zonelist_node_idx(z);
-}
-
 #ifdef CONFIG_HAVE_MEMORYLESS_NODES
 /*
  * Return node id of node used for "local" allocations.
@@ -4272,12 +4068,6 @@ static void build_zonelists(pg_data_t *pgdat)
 	zonelist->_zonerefs[j].zone_idx = 0;
 }
 
-/* non-NUMA variant of zonelist performance cache - just NULL zlcache_ptr */
-static void build_zonelist_cache(pg_data_t *pgdat)
-{
-	pgdat->node_zonelists[0].zlcache_ptr = NULL;
-}
-
 #endif	/* CONFIG_NUMA */
 
 /*
@@ -4318,14 +4108,12 @@ static int __build_all_zonelists(void *data)
 
 	if (self && !node_online(self->node_id)) {
 		build_zonelists(self);
-		build_zonelist_cache(self);
 	}
 
 	for_each_online_node(nid) {
 		pg_data_t *pgdat = NODE_DATA(nid);
 
 		build_zonelists(pgdat);
-		build_zonelist_cache(pgdat);
 	}
 
 	/*
-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
