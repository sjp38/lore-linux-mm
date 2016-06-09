Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D5B64828E1
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 14:06:47 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r5so25662090wmr.0
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 11:06:47 -0700 (PDT)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id v1si9208525wjp.44.2016.06.09.11.06.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Jun 2016 11:06:46 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id 6FC9798EA6
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 18:06:46 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 11/27] mm: vmscan: Do not reclaim from kswapd if there is any eligible zone
Date: Thu,  9 Jun 2016 19:04:27 +0100
Message-Id: <1465495483-11855-12-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

kswapd scans from highest to lowest for a zone that requires balancing.
This was necessary when reclaim was per-zone to fairly age pages on
lower zones. Now that we are reclaiming on a per-node basis, any eligible
zone can be used and pages will still be aged fairly. This patch avoids
reclaiming excessively unless buffer_heads are over the limit and it's
necessary to reclaim from a higher zone than requested by the waker of
kswapd to relieve low memory pressure.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/vmscan.c | 32 +++++++++++++++++++-------------
 1 file changed, 19 insertions(+), 13 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index e4f3e068b7a0..6663fc75c3bc 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3102,24 +3102,30 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 
 		sc.nr_reclaimed = 0;
 
-		/* Scan from the highest requested zone to dma */
+		/*
+		 * If the number of buffer_heads in the machine exceeds the
+		 * maximum allowed level and this node has a highmem zone,
+		 * force kswapd to reclaim from it to relieve lowmem pressure.
+		 */
+		if (buffer_heads_over_limit) {
+			for (i = MAX_NR_ZONES - 1; i >= 0; i++) {
+				zone = pgdat->node_zones + i;
+				if (!populated_zone(zone))
+					continue;
+
+				if (is_highmem_idx(i))
+					classzone_idx = i;
+				break;
+			}
+		}
+
+		/* Only reclaim if there are no eligible zones */
 		for (i = classzone_idx; i >= 0; i--) {
 			zone = pgdat->node_zones + i;
 			if (!populated_zone(zone))
 				continue;
 
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
-
-			if (!zone_balanced(zone, order, 0)) {
+			if (!zone_balanced(zone, sc.order, classzone_idx)) {
 				classzone_idx = i;
 				break;
 			}
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
