Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6B72F6B0266
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 14:06:27 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id c82so25629655wme.2
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 11:06:27 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id e84si39498263wmi.10.2016.06.09.11.06.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Jun 2016 11:06:26 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 18B082F8053
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 18:06:26 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 09/27] mm, vmscan: By default have direct reclaim only shrink once per node
Date: Thu,  9 Jun 2016 19:04:25 +0100
Message-Id: <1465495483-11855-10-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Direct reclaim iterates over all zones in the zonelist and shrinking them
but this is in conflict with node-based reclaim. In the default case,
only shrink once per node.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 14b34eebedff..dd68e3154732 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2522,14 +2522,6 @@ static inline bool compaction_ready(struct zone *zone, int order, int classzone_
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
@@ -2541,6 +2533,7 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc,
 	unsigned long nr_soft_reclaimed;
 	unsigned long nr_soft_scanned;
 	gfp_t orig_mask;
+	pg_data_t *last_pgdat = NULL;
 
 	/*
 	 * If the number of buffer_heads in the machine exceeds the maximum
@@ -2560,10 +2553,19 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc,
 							classzone_idx)) {
 			sc->reclaim_idx--;
 			classzone_idx--;
-			continue;
 		}
 
 		/*
+		 * Shrink each node in the zonelist once. If the zonelist is
+		 * ordered by zone (not the default) then a node may be
+		 * shrunk multiple times but in that case the user prefers
+		 * lower zones being preserved
+		 */
+		if (zone->zone_pgdat == last_pgdat)
+			continue;
+		last_pgdat = zone->zone_pgdat;
+
+		/*
 		 * Take care memory controller reclaiming has small influence
 		 * to global LRU.
 		 */
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
