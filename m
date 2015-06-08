Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 1F212900020
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 09:57:32 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so86303236wib.1
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 06:57:31 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ex9si5325823wjb.90.2015.06.08.06.57.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 06:57:09 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 23/25] mm, page_alloc: Delete the zonelist_cache
Date: Mon,  8 Jun 2015 14:56:29 +0100
Message-Id: <1433771791-30567-24-git-send-email-mgorman@suse.de>
In-Reply-To: <1433771791-30567-1-git-send-email-mgorman@suse.de>
References: <1433771791-30567-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

The zonelist cache (zlc) was introduced to quickly skip over full zones
when zone_reclaim was active. This made some sense before there were zone
flags and when zone_reclaim was the default. Now reclaim is node-based and
zone_reclaim is disabled by default. If it was being implemented today,
it would use a pgdat flag with a timeout to reset it but as zone_reclaim
is extraordinarily expensive the entire concept is of dubious merit. This
patch deletes it entirely.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h |  78 +-----------------
 mm/page_alloc.c        | 210 +------------------------------------------------
 mm/vmstat.c            |   8 +-
 3 files changed, 8 insertions(+), 288 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 84fcb7aafb2b..89a88ba096f3 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -558,84 +558,14 @@ static inline bool zone_is_empty(struct zone *zone)
 #define MAX_ZONES_PER_ZONELIST (MAX_NUMNODES * MAX_NR_ZONES)
 
 #ifdef CONFIG_NUMA
-
 /*
  * The NUMA zonelists are doubled because we need zonelists that restrict the
  * allocations to a single node for __GFP_THISNODE.
  *
- * [0]	: Zonelist with fallback
- * [1]	: No fallback (__GFP_THISNODE)
+ * [0] : Zonelist with fallback
+ * [1] : No fallback (__GFP_THISNODE)
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
@@ -665,11 +595,7 @@ struct zoneref {
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
index 47e6332d7566..4108743eb801 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1846,154 +1846,16 @@ bool zone_watermark_ok_safe(struct zone *z, unsigned int order,
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
 static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
 {
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
 static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
 {
 	return true;
 }
-
 #endif	/* CONFIG_NUMA */
 
 /*
@@ -2008,17 +1870,10 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 	struct zoneref *z;
 	struct page *page = NULL;
 	struct zone *zone;
-	nodemask_t *allowednodes = NULL;/* zonelist_cache approximation */
-	int zlc_active = 0;		/* set if using zonelist_cache */
-	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
 	bool consider_zone_dirty = (alloc_flags & ALLOC_WMARK_LOW) &&
 				(gfp_mask & __GFP_WRITE);
-	bool zonelist_rescan;
 	struct pglist_data *last_pgdat = NULL;
 
-zonelist_scan:
-	zonelist_rescan = false;
-
 	/*
 	 * Scan zonelist, looking for a zone with enough free.
 	 * See also __cpuset_node_allowed() comment in kernel/cpuset.c.
@@ -2027,9 +1882,6 @@ zonelist_scan:
 								ac->nodemask) {
 		unsigned long mark;
 
-		if (IS_ENABLED(CONFIG_NUMA) && zlc_active &&
-			!zlc_zone_worth_trying(zonelist, z, allowednodes))
-				continue;
 		if (cpusets_enabled() &&
 			(alloc_flags & ALLOC_CPUSET) &&
 			!cpuset_zone_allowed(zone, gfp_mask))
@@ -2079,26 +1931,6 @@ zonelist_scan:
 			    !zone_allows_reclaim(ac->preferred_zone, zone))
 				goto this_zone_full;
 
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
-			/*
-			 * As we may have just activated ZLC, check if the first
-			 * eligible zone has failed node_reclaim recently.
-			 */
-			if (IS_ENABLED(CONFIG_NUMA) && zlc_active &&
-				!zlc_zone_worth_trying(zonelist, z, allowednodes))
-				continue;
-
 			/* Skip if we have already attemped node_reclaim */
 			if (last_pgdat == zone->zone_pgdat)
 				goto try_this_zone;
@@ -2145,19 +1977,8 @@ try_this_zone:
 		}
 this_zone_full:
 		last_pgdat = zone->zone_pgdat;
-		if (IS_ENABLED(CONFIG_NUMA) && zlc_active)
-			zlc_mark_zone_full(zonelist, z);
 	}
 
-	if (unlikely(IS_ENABLED(CONFIG_NUMA) && zlc_active)) {
-		/* Disable zlc cache for second zonelist scan */
-		zlc_active = 0;
-		zonelist_rescan = true;
-	}
-
-	if (zonelist_rescan)
-		goto zonelist_scan;
-
 	return NULL;
 }
 
@@ -2440,10 +2261,6 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 	if (unlikely(!(*did_some_progress)))
 		return NULL;
 
-	/* After successful reclaim, reconsider all zones for allocation */
-	if (IS_ENABLED(CONFIG_NUMA))
-		zlc_clear_zones_full(ac->zonelist);
-
 retry:
 	page = get_page_from_freelist(gfp_mask, order,
 					alloc_flags & ~ALLOC_NO_WATERMARKS, ac);
@@ -2757,7 +2574,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	gfp_t alloc_mask; /* The gfp_t that was actually used for allocation */
 	struct alloc_context ac = {
 		.high_zoneidx = gfp_zone(gfp_mask),
-		.nodemask = nodemask,
+		.nodemask = nodemask ? : &cpuset_current_mems_allowed,
 		.migratetype = gfpflags_to_migratetype(gfp_mask),
 	};
 
@@ -2788,8 +2605,7 @@ retry_cpuset:
 	ac.zonelist = zonelist;
 	/* The preferred zone is used for statistics later */
 	preferred_zoneref = first_zones_zonelist(ac.zonelist, ac.high_zoneidx,
-				ac.nodemask ? : &cpuset_current_mems_allowed,
-				&ac.preferred_zone);
+				ac.nodemask, &ac.preferred_zone);
 	if (!ac.preferred_zone)
 		goto out;
 	ac.classzone_idx = zonelist_zone_idx(preferred_zoneref);
@@ -3674,20 +3490,6 @@ static void build_zonelists(pg_data_t *pgdat)
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
@@ -3748,12 +3550,6 @@ static void build_zonelists(pg_data_t *pgdat)
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
@@ -3794,14 +3590,12 @@ static int __build_all_zonelists(void *data)
 
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
diff --git a/mm/vmstat.c b/mm/vmstat.c
index c3fdd88961ff..30b17cf07197 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1500,14 +1500,14 @@ static void *vmstat_start(struct seq_file *m, loff_t *pos)
 		v[i] = global_page_state(i);
 	v += NR_VM_ZONE_STAT_ITEMS;
 
-	for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
-		v[i] = global_node_page_state(i);
-	v += NR_VM_NODE_STAT_ITEMS;
-
 	global_dirty_limits(v + NR_DIRTY_BG_THRESHOLD,
 			    v + NR_DIRTY_THRESHOLD);
 	v += NR_VM_WRITEBACK_STAT_ITEMS;
 
+	for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
+		v[i] = global_node_page_state(i);
+	v += NR_VM_NODE_STAT_ITEMS;
+
 #ifdef CONFIG_VM_EVENT_COUNTERS
 	all_vm_events(v);
 	v[PGPGIN] /= 2;		/* sectors -> kbytes */
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
