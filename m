Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 5DF206B0269
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 07:21:52 -0400 (EDT)
Received: by mail-wm0-f49.google.com with SMTP id l6so60361892wml.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 04:21:52 -0700 (PDT)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id fw7si2665182wjb.240.2016.04.06.04.21.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 04:21:45 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id 6E7511C1B52
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 12:21:45 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 21/27] mm, vmscan: Only wakeup kswapd once per node for the requested classzone
Date: Wed,  6 Apr 2016 12:20:20 +0100
Message-Id: <1459941626-3290-22-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1459941626-3290-1-git-send-email-mgorman@techsingularity.net>
References: <1459941626-3290-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

kswapd is woken when zones are below the low watermark but the wakeup
decision is not taking the classzone into account.  Now that reclaim is
node-based, it is only required to wake kswapd once per node and only if
all zones are unbalanced for the requested classzone.

Note that one node might be checked multiple times but there is no cheap
way of tracking what nodes have already been visited for zoneslists that
be ordered by either zone or node.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/vmscan.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0298c0977eac..9a1653fedd88 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3426,6 +3426,7 @@ static int kswapd(void *p)
 void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
 {
 	pg_data_t *pgdat;
+	int z;
 
 	if (!populated_zone(zone))
 		return;
@@ -3439,8 +3440,16 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
 	pgdat->kswapd_order = max(pgdat->kswapd_order, order);
 	if (!waitqueue_active(&pgdat->kswapd_wait))
 		return;
-	if (zone_balanced(zone, order, 0, 0))
-		return;
+
+	/* Only wake kswapd if all zones are unbalanced */
+	for (z = 0; z <= zone_idx(zone); z++) {
+		zone = pgdat->node_zones + z;
+		if (!populated_zone(zone))
+			continue;
+
+		if (zone_balanced(zone, order, 0, classzone_idx))
+			return;
+	}
 
 	trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, zone_idx(zone), order);
 	wake_up_interruptible(&pgdat->kswapd_wait);
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
