Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 417C7828E1
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 10:18:11 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id na2so14940522lbb.1
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 07:18:11 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id vo2si36510783wjb.79.2016.06.21.07.18.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jun 2016 07:18:09 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 67AB71C19B6
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 15:18:09 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 11/27] mm: vmscan: Do not reclaim from kswapd if there is any eligible zone
Date: Tue, 21 Jun 2016 15:15:50 +0100
Message-Id: <1466518566-30034-12-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
References: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
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
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/vmscan.c | 32 +++++++++++++++++++-------------
 1 file changed, 19 insertions(+), 13 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8347406c75fa..d42a86e603e8 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3132,24 +3132,30 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 
 		sc.nr_reclaimed = 0;
 
-		/* Scan from the highest requested zone to dma */
+		/*
+		 * If the number of buffer_heads in the machine exceeds the
+		 * maximum allowed level and this node has a highmem zone,
+		 * force kswapd to reclaim from it to relieve lowmem pressure.
+		 */
+		if (buffer_heads_over_limit) {
+			for (i = MAX_NR_ZONES - 1; i >= 0; i--) {
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
