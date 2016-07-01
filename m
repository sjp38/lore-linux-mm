Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 67854828E1
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 11:39:51 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id l184so84330543lfl.3
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 08:39:51 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id j198si4497127wmj.110.2016.07.01.08.39.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jul 2016 08:39:50 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id CE9201C221C
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 16:39:49 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 11/31] mm: vmscan: do not reclaim from kswapd if there is any eligible zone
Date: Fri,  1 Jul 2016 16:37:26 +0100
Message-Id: <1467387466-10022-12-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1467387466-10022-1-git-send-email-mgorman@techsingularity.net>
References: <1467387466-10022-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

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
 mm/vmscan.c | 56 ++++++++++++++++++++++++--------------------------------
 1 file changed, 24 insertions(+), 32 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 911142d25de2..2f898ba2ee2e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3141,31 +3141,36 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 
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
+		 * high to low zone to avoid prematurely clearing pgdat
+		 * congested state.
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
@@ -3211,19 +3216,6 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
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
