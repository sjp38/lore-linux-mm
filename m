Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id E955F6B0264
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 07:21:23 -0400 (EDT)
Received: by mail-wm0-f41.google.com with SMTP id f198so68800935wme.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 04:21:23 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id n69si24419892wmd.25.2016.04.06.04.21.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Apr 2016 04:21:19 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id DF58F98E46
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 11:21:18 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 09/27] mm, vmscan: By default have direct reclaim only shrink once per node
Date: Wed,  6 Apr 2016 12:20:08 +0100
Message-Id: <1459941626-3290-10-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1459941626-3290-1-git-send-email-mgorman@techsingularity.net>
References: <1459941626-3290-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Direct reclaim iterates over all zones in the zonelist and shrinking them
but this is in conflict with node-based reclaim. In the default case,
only shrink once per node.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c | 23 +++++++++++------------
 1 file changed, 11 insertions(+), 12 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 132d9a04de6b..a631972d49e1 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2547,14 +2547,6 @@ static inline bool compaction_ready(struct zone *zone, int order)
  * try to reclaim pages from zones which will satisfy the caller's allocation
  * request.
  *
- * We reclaim from a zone even if that zone is over high_wmark_pages(zone).
- * Because:
- * a) The caller may be trying to free *extra* pages to satisfy a higher-order
- *    allocation or
- * b) The target zone may be at high_wmark_pages(zone) but the lower zones
- *    must go *over* high_wmark_pages(zone) to satisfy the `incremental min'
- *    zone defense algorithm.
- *
  * If a zone is deemed to be full of pinned pages then just give it a light
  * scan then give up on it.
  *
@@ -2569,6 +2561,7 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc,
 	unsigned long nr_soft_scanned;
 	gfp_t orig_mask;
 	bool reclaimable = false;
+	pg_data_t *last_pgdat = NULL;
 
 	/*
 	 * If the number of buffer_heads in the machine exceeds the maximum
@@ -2581,11 +2574,17 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc,
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 					classzone_idx, sc->nodemask) {
-		if (!populated_zone(zone)) {
-			sc->reclaim_idx--;
-			classzone_idx--;
+		BUG_ON(!populated_zone(zone));
+
+		/*
+		 * Shrink each node in the zonelist once. If the zonelist is
+		 * ordered by zone (not the default) then a node may be
+		 * shrunk multiple times but in that case the user prefers
+		 * lower zones being preserved
+		 */
+		if (zone->zone_pgdat == last_pgdat)
 			continue;
-		}
+		last_pgdat = zone->zone_pgdat;
 
 		/*
 		 * Take care memory controller reclaiming has small influence
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
