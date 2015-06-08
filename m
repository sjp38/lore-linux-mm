Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id EF601900015
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 09:56:54 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so86280616wib.1
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 06:56:54 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cw10si5288827wjc.154.2015.06.08.06.56.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 06:56:52 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 08/25] mm, vmscan: By default have direct reclaim only shrink once per node
Date: Mon,  8 Jun 2015 14:56:14 +0100
Message-Id: <1433771791-30567-9-git-send-email-mgorman@suse.de>
In-Reply-To: <1433771791-30567-1-git-send-email-mgorman@suse.de>
References: <1433771791-30567-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Direct reclaim iterates over all zones in the zonelist and shrinking them
but this is in conflict with node-based reclaim. In the default case,
only shrink once per node.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 4d7ddaf4f2f4..50aa650ac206 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2468,14 +2468,6 @@ static inline bool compaction_ready(struct zone *zone, int order)
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
@@ -2490,6 +2482,7 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc,
 	unsigned long nr_soft_scanned;
 	gfp_t orig_mask;
 	bool reclaimable = false;
+	pg_data_t *last_pgdat = NULL;
 
 	/*
 	 * If the number of buffer_heads in the machine exceeds the maximum
@@ -2502,11 +2495,18 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc,
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 					classzone_idx, sc->nodemask) {
-		if (!populated_zone(zone)) {
-			reclaim_idx--;
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
+		reclaim_idx = zone_idx(zone);
 
 		/*
 		 * Take care memory controller reclaiming has small influence
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
