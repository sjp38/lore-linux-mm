Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 92FD2828E4
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 07:21:31 -0400 (EDT)
Received: by mail-wm0-f42.google.com with SMTP id 191so54343766wmq.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 04:21:31 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id t185si24356506wme.111.2016.04.06.04.21.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 04:21:26 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 77C311C1C7A
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 12:21:26 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 11/27] mm: vmscan: Do not reclaim from kswapd if there is any eligible zone
Date: Wed,  6 Apr 2016 12:20:10 +0100
Message-Id: <1459941626-3290-12-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1459941626-3290-1-git-send-email-mgorman@techsingularity.net>
References: <1459941626-3290-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
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
index c62505f9e8be..9752252bdd63 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3139,24 +3139,30 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 
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
-			if (!zone_balanced(zone, order, 0, 0)) {
+			if (!zone_balanced(zone, sc.order, 0, classzone_idx)) {
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
