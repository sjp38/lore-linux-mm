Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id E5BB16B0260
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 08:45:45 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id g62so222897783wme.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 05:45:45 -0800 (PST)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id e124si39681158wma.114.2016.02.23.05.45.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 05:45:19 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id 3AD2E1C1DD8
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 13:45:19 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 12/27] mm: vmscan: Do not reclaim from kswapd if there is any eligible zone
Date: Tue, 23 Feb 2016 13:45:01 +0000
Message-Id: <1456235116-32385-13-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1456235116-32385-1-git-send-email-mgorman@techsingularity.net>
References: <1456235116-32385-1-git-send-email-mgorman@techsingularity.net>
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
index 1f5d3829d35e..39ad2ab76a2b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3123,24 +3123,30 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 
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
+			if (!zone_balanced(zone, order, 0, classzone_idx)) {
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
