Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 574B69003C7
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 04:00:26 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so8402883wic.0
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 01:00:25 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id sa13si33750671wjb.198.2015.07.20.01.00.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 20 Jul 2015 01:00:22 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 5002C98641
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 08:00:21 +0000 (UTC)
From: Mel Gorman <mgorman@suse.com>
Subject: [PATCH 01/10] mm, page_alloc: Delete the zonelist_cache
Date: Mon, 20 Jul 2015 09:00:10 +0100
Message-Id: <1437379219-9160-2-git-send-email-mgorman@suse.com>
In-Reply-To: <1437379219-9160-1-git-send-email-mgorman@suse.com>
References: <1437379219-9160-1-git-send-email-mgorman@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Pintu Kumar <pintu.k@samsung.com>, Xishi Qiu <qiuxishi@huawei.com>, Gioh Kim <gioh.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

From: Mel Gorman <mgorman@suse.de>

The zonelist cache (zlc) was introduced to skip over zones that were
recently known to be full. At the time the paths it bypassed were the
cpuset checks, the watermark calculations and zone_reclaim. The situation
today is different and the complexity of zlc is harder to justify.

1) The cpuset checks are no-ops unless a cpuset is active and in general are
   a lot cheaper.

2) zone_reclaim is now disabled by default and I suspect that was a large
   source of the cost that zlc wanted to avoid. When it is enabled, it's
   known to be a major source of stalling when nodes fill up and it's
   unwise to hit every other user with the overhead.

3) Watermark checks are expensive to calculate for high-order
   allocation requests. Later patches in this series will reduce the cost of
   the watermark checking.

4) The most important issue is that in the current implementation it
   is possible for a failed THP allocation to mark a zone full for order-0
   allocations and cause a fallback to remote nodes.

The last issue could be addressed with additional complexity but it's
not clear that we need zlc at all so this patch deletes it. If stalls
due to repeated zone_reclaim are ever reported as an issue then we should
introduce deferring logic based on a timeout inside zone_reclaim itself
and leave the page allocator fast paths alone.

Impact on page-allocator microbenchmarks is negligible as they don't hit
the paths where the zlc comes into play. The impact was noticable in
a workload called "stutter". One part uses a lot of anonymous memory,
a second measures mmap latency and a third copies a large file. In an
ideal world the latency application would not notice the mmap latency.
On a 4-node machine the results of this patch are

4-node machine stutter
                             4.2.0-rc1             4.2.0-rc1
                               vanilla           nozlc-v1r20
Min         mmap     53.9902 (  0.00%)     49.3629 (  8.57%)
1st-qrtle   mmap     54.6776 (  0.00%)     54.1201 (  1.02%)
2nd-qrtle   mmap     54.9242 (  0.00%)     54.5961 (  0.60%)
3rd-qrtle   mmap     55.1817 (  0.00%)     54.9338 (  0.45%)
Max-90%     mmap     55.3952 (  0.00%)     55.3929 (  0.00%)
Max-93%     mmap     55.4766 (  0.00%)     57.5712 ( -3.78%)
Max-95%     mmap     55.5522 (  0.00%)     57.8376 ( -4.11%)
Max-99%     mmap     55.7938 (  0.00%)     63.6180 (-14.02%)
Max         mmap   6344.0292 (  0.00%)     67.2477 ( 98.94%)
Mean        mmap     57.3732 (  0.00%)     54.5680 (  4.89%)

Note the maximum stall latency which was 6 seconds and becomes 67ms with
this patch applied. However, also note that it is not guaranteed this
benchmark always hits pathelogical cases and the milage varies. There is
a secondary impact with more direct reclaim because zones are now being
considered instead of being skipped by zlc.

                                 4.1.0       4.1.0
                               vanilla  nozlc-v1r4
Swap Ins                           838         502
Swap Outs                      1149395     2622895
DMA32 allocs                  17839113    15863747
Normal allocs                129045707   137847920
Direct pages scanned           4070089    29046893
Kswapd pages scanned          17147837    17140694
Kswapd pages reclaimed        17146691    17139601
Direct pages reclaimed         1888879     4886630
Kswapd efficiency                  99%         99%
Kswapd velocity              17523.721   17518.928
Direct efficiency                  46%         16%
Direct velocity               4159.306   29687.854
Percentage direct scans            19%         62%
Page writes by reclaim     1149395.000 2622895.000
Page writes file                     0           0
Page writes anon               1149395     2622895

The direct page scan and reclaim rates are noticable. It is possible
this will not be a universal win on all workloads but cycling through
zonelists waiting for zlc->last_full_zap to expire is not the right
decision.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h |  73 -----------------
 mm/page_alloc.c        | 217 +------------------------------------------------
 2 files changed, 2 insertions(+), 288 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 754c25966a0a..754289f371fa 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -585,75 +585,6 @@ static inline bool zone_is_empty(struct zone *zone)
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
-#else
-#define MAX_ZONELISTS 1
-struct zonelist_cache;
 #endif
 
 /*
@@ -683,11 +614,7 @@ struct zoneref {
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
index 506eac8b38af..8db0b6d66165 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2248,122 +2248,6 @@ bool zone_watermark_ok_safe(struct zone *z, unsigned int order,
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
@@ -2374,28 +2258,7 @@ static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
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
@@ -2405,7 +2268,6 @@ static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
 {
 	return true;
 }
-
 #endif	/* CONFIG_NUMA */
 
 static void reset_alloc_batches(struct zone *preferred_zone)
@@ -2432,9 +2294,6 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 	struct zoneref *z;
 	struct page *page = NULL;
 	struct zone *zone;
-	nodemask_t *allowednodes = NULL;/* zonelist_cache approximation */
-	int zlc_active = 0;		/* set if using zonelist_cache */
-	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
 	bool consider_zone_dirty = (alloc_flags & ALLOC_WMARK_LOW) &&
 				(gfp_mask & __GFP_WRITE);
 	int nr_fair_skipped = 0;
@@ -2451,9 +2310,6 @@ zonelist_scan:
 								ac->nodemask) {
 		unsigned long mark;
 
-		if (IS_ENABLED(CONFIG_NUMA) && zlc_active &&
-			!zlc_zone_worth_trying(zonelist, z, allowednodes))
-				continue;
 		if (cpusets_enabled() &&
 			(alloc_flags & ALLOC_CPUSET) &&
 			!cpuset_zone_allowed(zone, gfp_mask))
@@ -2511,28 +2367,8 @@ zonelist_scan:
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
@@ -2549,19 +2385,6 @@ zonelist_scan:
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
@@ -2574,9 +2397,6 @@ try_this_zone:
 				goto try_this_zone;
 			return page;
 		}
-this_zone_full:
-		if (IS_ENABLED(CONFIG_NUMA) && zlc_active)
-			zlc_mark_zone_full(zonelist, z);
 	}
 
 	/*
@@ -2597,12 +2417,6 @@ this_zone_full:
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
 
@@ -2842,10 +2656,6 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 	if (unlikely(!(*did_some_progress)))
 		return NULL;
 
-	/* After successful reclaim, reconsider all zones for allocation */
-	if (IS_ENABLED(CONFIG_NUMA))
-		zlc_clear_zones_full(ac->zonelist);
-
 retry:
 	page = get_page_from_freelist(gfp_mask, order,
 					alloc_flags & ~ALLOC_NO_WATERMARKS, ac);
@@ -3155,7 +2965,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	gfp_t alloc_mask; /* The gfp_t that was actually used for allocation */
 	struct alloc_context ac = {
 		.high_zoneidx = gfp_zone(gfp_mask),
-		.nodemask = nodemask,
+		.nodemask = nodemask ? : &cpuset_current_mems_allowed,
 		.migratetype = gfpflags_to_migratetype(gfp_mask),
 	};
 
@@ -3186,8 +2996,7 @@ retry_cpuset:
 	ac.zonelist = zonelist;
 	/* The preferred zone is used for statistics later */
 	preferred_zoneref = first_zones_zonelist(ac.zonelist, ac.high_zoneidx,
-				ac.nodemask ? : &cpuset_current_mems_allowed,
-				&ac.preferred_zone);
+				ac.nodemask, &ac.preferred_zone);
 	if (!ac.preferred_zone)
 		goto out;
 	ac.classzone_idx = zonelist_zone_idx(preferred_zoneref);
@@ -4167,20 +3976,6 @@ static void build_zonelists(pg_data_t *pgdat)
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
@@ -4241,12 +4036,6 @@ static void build_zonelists(pg_data_t *pgdat)
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
@@ -4287,14 +4076,12 @@ static int __build_all_zonelists(void *data)
 
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
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
