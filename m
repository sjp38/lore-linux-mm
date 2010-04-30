Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B4A7E6004BA
	for <linux-mm@kvack.org>; Fri, 30 Apr 2010 19:06:03 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 3/5] vmscan: remove all_unreclaimable scan control
Date: Sat,  1 May 2010 01:05:31 +0200
Message-Id: <20100430224316.056084208@cmpxchg.org>
In-Reply-To: <20100430222009.379195565@cmpxchg.org>
References: <20100430222009.379195565@cmpxchg.org>
References: <20100430222009.379195565@cmpxchg.org>
Content-Disposition: inline; filename=vmscan-remove-all_unreclaimable-scan-control.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This scan control is abused to communicate a return value from
shrink_zones().  Write this idiomatically and remove the knob.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c |   14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -70,8 +70,6 @@ struct scan_control {
 
 	int swappiness;
 
-	int all_unreclaimable;
-
 	int order;
 
 	int lumpy_reclaim;
@@ -1701,14 +1699,14 @@ static void shrink_zone(int priority, st
  * If a zone is deemed to be full of pinned pages then just give it a light
  * scan then give up on it.
  */
-static void shrink_zones(int priority, struct zonelist *zonelist,
+static int shrink_zones(int priority, struct zonelist *zonelist,
 					struct scan_control *sc)
 {
 	enum zone_type high_zoneidx = gfp_zone(sc->gfp_mask);
 	struct zoneref *z;
 	struct zone *zone;
+	int progress = 0;
 
-	sc->all_unreclaimable = 1;
 	for_each_zone_zonelist_nodemask(zone, z, zonelist, high_zoneidx,
 					sc->nodemask) {
 		if (!populated_zone(zone))
@@ -1724,19 +1722,19 @@ static void shrink_zones(int priority, s
 
 			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
 				continue;	/* Let kswapd poll it */
-			sc->all_unreclaimable = 0;
 		} else {
 			/*
 			 * Ignore cpuset limitation here. We just want to reduce
 			 * # of used pages by us regardless of memory shortage.
 			 */
-			sc->all_unreclaimable = 0;
 			mem_cgroup_note_reclaim_priority(sc->mem_cgroup,
 							priority);
 		}
 
 		shrink_zone(priority, zone, sc);
+		progress = 1;
 	}
+	return progress;
 }
 
 /*
@@ -1789,7 +1787,7 @@ static unsigned long do_try_to_free_page
 		sc->nr_scanned = 0;
 		if (!priority)
 			disable_swap_token();
-		shrink_zones(priority, zonelist, sc);
+		ret = shrink_zones(priority, zonelist, sc);
 		/*
 		 * Don't shrink slabs when reclaiming memory from
 		 * over limit cgroups
@@ -1826,7 +1824,7 @@ static unsigned long do_try_to_free_page
 			congestion_wait(BLK_RW_ASYNC, HZ/10);
 	}
 	/* top priority shrink_zones still had more to do? don't OOM, then */
-	if (!sc->all_unreclaimable && scanning_global_lru(sc))
+	if (ret && scanning_global_lru(sc))
 		ret = sc->nr_reclaimed;
 out:
 	/*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
