Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id C50A06B025A
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 10:05:13 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id b205so203613880wmb.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 07:05:13 -0800 (PST)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id x17si45244148wju.26.2016.02.23.07.04.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 23 Feb 2016 07:04:53 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 9013798E79
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 15:04:53 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 10/27] mm, vmscan: By default have direct reclaim only shrink once per node
Date: Tue, 23 Feb 2016 15:04:33 +0000
Message-Id: <1456239890-20737-11-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
References: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Direct reclaim iterates over all zones in the zonelist and shrinking them
but this is in conflict with node-based reclaim. In the default case,
only shrink once per node.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/vmscan.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0417f20aead7..fe004cb11b71 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2549,14 +2549,6 @@ static inline bool compaction_ready(struct zone *zone, int order)
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
  */
@@ -2568,6 +2560,7 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc,
 	unsigned long nr_soft_reclaimed;
 	unsigned long nr_soft_scanned;
 	gfp_t orig_mask;
+	pg_data_t *last_pgdat = NULL;
 
 	/*
 	 * If the number of buffer_heads in the machine exceeds the maximum
@@ -2580,11 +2573,18 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc,
 
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
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
