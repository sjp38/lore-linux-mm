Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5674E6B0264
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 05:37:05 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f126so8299447wma.3
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 02:37:05 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id gh5si3767792wjd.127.2016.07.08.02.37.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jul 2016 02:37:04 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id D1B271C24CD
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 10:37:03 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 10/34] mm, vmscan: by default have direct reclaim only shrink once per node
Date: Fri,  8 Jul 2016 10:34:46 +0100
Message-Id: <1467970510-21195-11-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Direct reclaim iterates over all zones in the zonelist and shrinking them
but this is in conflict with node-based reclaim.  In the default case,
only shrink once per node.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/vmscan.c | 22 ++++++++++++++--------
 1 file changed, 14 insertions(+), 8 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 905c60473126..01fe4708e404 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2552,14 +2552,6 @@ static inline bool compaction_ready(struct zone *zone, int order, int classzone_
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
@@ -2571,6 +2563,7 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 	unsigned long nr_soft_scanned;
 	gfp_t orig_mask;
 	enum zone_type classzone_idx;
+	pg_data_t *last_pgdat = NULL;
 
 	/*
 	 * If the number of buffer_heads in the machine exceeds the maximum
@@ -2630,6 +2623,15 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 			}
 
 			/*
+			 * Shrink each node in the zonelist once. If the
+			 * zonelist is ordered by zone (not the default) then a
+			 * node may be shrunk multiple times but in that case
+			 * the user prefers lower zones being preserved.
+			 */
+			if (zone->zone_pgdat == last_pgdat)
+				continue;
+
+			/*
 			 * This steals pages from memory cgroups over softlimit
 			 * and returns the number of reclaimed pages and
 			 * scanned pages. This works for global memory pressure
@@ -2644,6 +2646,10 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 			/* need some check for avoid more shrink_zone() */
 		}
 
+		/* See comment about same check for global reclaim above */
+		if (zone->zone_pgdat == last_pgdat)
+			continue;
+		last_pgdat = zone->zone_pgdat;
 		shrink_node(zone->zone_pgdat, sc, classzone_idx);
 	}
 
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
