Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 464786B0035
	for <linux-mm@kvack.org>; Mon, 14 Jul 2014 09:21:07 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id z12so4127211wgg.24
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 06:21:06 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id fm4si10860360wib.2.2014.07.14.06.21.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 14 Jul 2014 06:21:04 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/3] mm: vmscan: remove all_unreclaimable() fix
Date: Mon, 14 Jul 2014 09:20:48 -0400
Message-Id: <1405344049-19868-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1405344049-19868-1-git-send-email-hannes@cmpxchg.org>
References: <1405344049-19868-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

As per Mel, use bool for reclaimability throughout and simplify the
reclaimability tracking in shrink_zones().

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c | 29 +++++++++++++++--------------
 1 file changed, 15 insertions(+), 14 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 6dac1310e5e4..74a9e0ae09b0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2244,10 +2244,10 @@ static inline bool should_continue_reclaim(struct zone *zone,
 	}
 }
 
-static unsigned long shrink_zone(struct zone *zone, struct scan_control *sc)
+static bool shrink_zone(struct zone *zone, struct scan_control *sc)
 {
 	unsigned long nr_reclaimed, nr_scanned;
-	unsigned long zone_reclaimed = 0;
+	bool reclaimable = false;
 
 	do {
 		struct mem_cgroup *root = sc->target_mem_cgroup;
@@ -2291,12 +2291,13 @@ static unsigned long shrink_zone(struct zone *zone, struct scan_control *sc)
 			   sc->nr_scanned - nr_scanned,
 			   sc->nr_reclaimed - nr_reclaimed);
 
-		zone_reclaimed += sc->nr_reclaimed - nr_reclaimed;
+		if (sc->nr_reclaimed - nr_reclaimed)
+			reclaimable = true;
 
 	} while (should_continue_reclaim(zone, sc->nr_reclaimed - nr_reclaimed,
 					 sc->nr_scanned - nr_scanned, sc));
 
-	return zone_reclaimed;
+	return reclaimable;
 }
 
 /* Returns true if compaction should go ahead for a high-order request */
@@ -2346,7 +2347,7 @@ static inline bool compaction_ready(struct zone *zone, int order)
  * If a zone is deemed to be full of pinned pages then just give it a light
  * scan then give up on it.
  *
- * Returns whether the zones overall are reclaimable or not.
+ * Returns true if a zone was reclaimable.
  */
 static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 {
@@ -2361,7 +2362,7 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 		.gfp_mask = sc->gfp_mask,
 	};
 	enum zone_type requested_highidx = gfp_zone(sc->gfp_mask);
-	bool all_unreclaimable = true;
+	bool reclaimable = false;
 
 	/*
 	 * If the number of buffer_heads in the machine exceeds the maximum
@@ -2376,8 +2377,6 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 					gfp_zone(sc->gfp_mask), sc->nodemask) {
-		unsigned long zone_reclaimed = 0;
-
 		if (!populated_zone(zone))
 			continue;
 		/*
@@ -2424,15 +2423,17 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 						&nr_soft_scanned);
 			sc->nr_reclaimed += nr_soft_reclaimed;
 			sc->nr_scanned += nr_soft_scanned;
-			zone_reclaimed += nr_soft_reclaimed;
+			if (nr_soft_reclaimed)
+				reclaimable = true;
 			/* need some check for avoid more shrink_zone() */
 		}
 
-		zone_reclaimed += shrink_zone(zone, sc);
+		if (shrink_zone(zone, sc))
+			reclaimable = true;
 
-		if (zone_reclaimed ||
-		    (global_reclaim(sc) && zone_reclaimable(zone)))
-			all_unreclaimable = false;
+		if (global_reclaim(sc) &&
+		    !reclaimable && zone_reclaimable(zone))
+			reclaimable = true;
 	}
 
 	/*
@@ -2455,7 +2456,7 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 	 */
 	sc->gfp_mask = orig_mask;
 
-	return !all_unreclaimable;
+	return reclaimable;
 }
 
 /*
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
