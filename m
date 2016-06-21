Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id A14C86B0266
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 10:17:50 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id a4so13593625lfa.1
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 07:17:50 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id 125si4080601wmo.123.2016.06.21.07.17.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jun 2016 07:17:49 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 0917D1C192E
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 15:17:49 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 09/27] mm, vmscan: By default have direct reclaim only shrink once per node
Date: Tue, 21 Jun 2016 15:15:48 +0100
Message-Id: <1466518566-30034-10-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
References: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Direct reclaim iterates over all zones in the zonelist and shrinking them
but this is in conflict with node-based reclaim. In the default case,
only shrink once per node.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/vmscan.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index ce712ca1f696..2dafaa06884b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2546,14 +2546,6 @@ static inline bool compaction_ready(struct zone *zone, int order, int classzone_
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
@@ -2565,6 +2557,7 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc,
 	unsigned long nr_soft_reclaimed;
 	unsigned long nr_soft_scanned;
 	gfp_t orig_mask;
+	pg_data_t *last_pgdat = NULL;
 
 	/*
 	 * If the number of buffer_heads in the machine exceeds the maximum
@@ -2589,10 +2582,19 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc,
 		while (!populated_zone(zone->zone_pgdat->node_zones +
 							classzone_idx)) {
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
