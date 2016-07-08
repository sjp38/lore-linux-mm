Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6FDE86B0266
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 05:37:25 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id j134so64987409oib.1
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 02:37:25 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id r3si6509807wmf.2.2016.07.08.02.37.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 08 Jul 2016 02:37:24 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 4087399433
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 09:37:24 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 12/34] mm: vmscan: do not reclaim from kswapd if there is any eligible zone
Date: Fri,  8 Jul 2016 10:34:48 +0100
Message-Id: <1467970510-21195-13-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

kswapd scans from highest to lowest for a zone that requires balancing.
This was necessary when reclaim was per-zone to fairly age pages on lower
zones.  Now that we are reclaiming on a per-node basis, any eligible zone
can be used and pages will still be aged fairly.  This patch avoids
reclaiming excessively unless buffer_heads are over the limit and it's
necessary to reclaim from a higher zone than requested by the waker of
kswapd to relieve low memory pressure.

[hillf.zj@alibaba-inc.com: Force kswapd reclaim no more than needed]
Link: http://lkml.kernel.org/r/1466518566-30034-12-git-send-email-mgorman@techsingularity.net
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Hillf Danton <hillf.zj@alibaba-inc.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/vmscan.c | 59 +++++++++++++++++++++++++++--------------------------------
 1 file changed, 27 insertions(+), 32 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8b39b903bd14..b7a276f4b1b0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3144,31 +3144,39 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 
 		sc.nr_reclaimed = 0;
 
-		/* Scan from the highest requested zone to dma */
-		for (i = classzone_idx; i >= 0; i--) {
-			zone = pgdat->node_zones + i;
-			if (!populated_zone(zone))
-				continue;
-
-			/*
-			 * If the number of buffer_heads in the machine
-			 * exceeds the maximum allowed level and this node
-			 * has a highmem zone, force kswapd to reclaim from
-			 * it to relieve lowmem pressure.
-			 */
-			if (buffer_heads_over_limit && is_highmem_idx(i)) {
-				classzone_idx = i;
-				break;
-			}
+		/*
+		 * If the number of buffer_heads in the machine exceeds the
+		 * maximum allowed level then reclaim from all zones. This is
+		 * not specific to highmem as highmem may not exist but it is
+		 * it is expected that buffer_heads are stripped in writeback.
+		 */
+		if (buffer_heads_over_limit) {
+			for (i = MAX_NR_ZONES - 1; i >= 0; i--) {
+				zone = pgdat->node_zones + i;
+				if (!populated_zone(zone))
+					continue;
 
-			if (!zone_balanced(zone, order, 0)) {
 				classzone_idx = i;
 				break;
 			}
 		}
 
-		if (i < 0)
-			goto out;
+		/*
+		 * Only reclaim if there are no eligible zones. Check from
+		 * high to low zone as allocations prefer higher zones.
+		 * Scanning from low to high zone would allow congestion to be
+		 * cleared during a very small window when a small low
+		 * zone was balanced even under extreme pressure when the
+		 * overall node may be congested.
+		 */
+		for (i = classzone_idx; i >= 0; i--) {
+			zone = pgdat->node_zones + i;
+			if (!populated_zone(zone))
+				continue;
+
+			if (zone_balanced(zone, sc.order, classzone_idx))
+				goto out;
+		}
 
 		/*
 		 * Do some background aging of the anon list, to give
@@ -3214,19 +3222,6 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 			break;
 
 		/*
-		 * Stop reclaiming if any eligible zone is balanced and clear
-		 * node writeback or congested.
-		 */
-		for (i = 0; i <= classzone_idx; i++) {
-			zone = pgdat->node_zones + i;
-			if (!populated_zone(zone))
-				continue;
-
-			if (zone_balanced(zone, sc.order, classzone_idx))
-				goto out;
-		}
-
-		/*
 		 * Raise priority if scanning rate is too low or there was no
 		 * progress in reclaiming pages
 		 */
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
