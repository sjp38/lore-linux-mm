Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id 373256B0035
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 04:38:57 -0400 (EDT)
Received: by mail-ee0-f50.google.com with SMTP id c13so4249351eek.23
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 01:38:56 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g47si58661196eet.324.2014.04.22.01.38.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 01:38:55 -0700 (PDT)
Date: Tue, 22 Apr 2014 09:38:52 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: vmscan: Do not throttle based on pfmemalloc reserves if
 node has no ZONE_NORMAL
Message-ID: <20140422083852.GB23991@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

throttle_direct_reclaim() is meant to trigger during swap-over-network
during which the min watermark is treated as a pfmemalloc reserve. It
throttes on the first node in the zonelist but this is flawed.

On a NUMA machine running a 32-bit kernel (I know) allocation requests
freom CPUs on node 1 would detect no pfmemalloc reserves and the process
gets throttled. This patch adjusts throttling of direct reclaim to throttle
based on the first node in the zonelist that has a usable ZONE_NORMAL or
lower zone.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c | 33 +++++++++++++++++++++++++++------
 1 file changed, 27 insertions(+), 6 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3f56c8d..9c4918e9 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2507,10 +2507,17 @@ static bool pfmemalloc_watermark_ok(pg_data_t *pgdat)
 
 	for (i = 0; i <= ZONE_NORMAL; i++) {
 		zone = &pgdat->node_zones[i];
+		if (!populated_zone(zone))
+			continue;
+
 		pfmemalloc_reserve += min_wmark_pages(zone);
 		free_pages += zone_page_state(zone, NR_FREE_PAGES);
 	}
 
+	/* If there are no reserves (unexpected config) then do not throttle */
+	if (!pfmemalloc_reserve)
+		return true;
+
 	wmark_ok = free_pages > pfmemalloc_reserve / 2;
 
 	/* kswapd must be awake if processes are being throttled */
@@ -2535,9 +2542,9 @@ static bool pfmemalloc_watermark_ok(pg_data_t *pgdat)
 static bool throttle_direct_reclaim(gfp_t gfp_mask, struct zonelist *zonelist,
 					nodemask_t *nodemask)
 {
+	struct zoneref *z;
 	struct zone *zone;
-	int high_zoneidx = gfp_zone(gfp_mask);
-	pg_data_t *pgdat;
+	pg_data_t *pgdat = NULL;
 
 	/*
 	 * Kernel threads should not be throttled as they may be indirectly
@@ -2556,10 +2563,24 @@ static bool throttle_direct_reclaim(gfp_t gfp_mask, struct zonelist *zonelist,
 	if (fatal_signal_pending(current))
 		goto out;
 
-	/* Check if the pfmemalloc reserves are ok */
-	first_zones_zonelist(zonelist, high_zoneidx, NULL, &zone);
-	pgdat = zone->zone_pgdat;
-	if (pfmemalloc_watermark_ok(pgdat))
+	/*
+	 * Check if the pfmemalloc reserves are ok by finding the first node
+	 * with a usable ZONE_NORMAL or lower zone
+	 */
+        for_each_zone_zonelist_nodemask(zone, z, zonelist,
+                                        gfp_mask, nodemask) {
+		if (zone_idx(zone) > ZONE_NORMAL)
+			continue;
+
+		/* Throttle based on the first usable node */
+		pgdat = zone->zone_pgdat;
+		if (pfmemalloc_watermark_ok(pgdat))
+			goto out;
+		break;
+	}
+
+	/* If no zone was usable by the allocation flags then do not throttle */
+	if (!pgdat)
 		goto out;
 
 	/* Account for the throttling */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
