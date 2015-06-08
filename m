Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 7D186900020
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 09:57:19 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so86295591wib.1
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 06:57:19 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o19si5331981wjr.59.2015.06.08.06.57.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 06:57:03 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 18/25] mm, vmscan: Only wakeup kswapd once per node for the requested classzone
Date: Mon,  8 Jun 2015 14:56:24 +0100
Message-Id: <1433771791-30567-19-git-send-email-mgorman@suse.de>
In-Reply-To: <1433771791-30567-1-git-send-email-mgorman@suse.de>
References: <1433771791-30567-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

kswapd is woken when zones are below the low watermark but the wakeup
decision is not taking the classzone into account.  Now that reclaim is
node-based, it is only required to wake kswapd once per node and only if
all zones are unbalanced for the requested classzone.

Note that one node might be checked multiple times but there is no cheap
way of tracking what nodes have already been visited for zoneslists that
be ordered by either zone or node.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index e1fbd89ab750..69916bb9acba 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3381,6 +3381,7 @@ static int kswapd(void *p)
 void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
 {
 	pg_data_t *pgdat;
+	int z;
 	bool dummy;
 
 	if (!populated_zone(zone))
@@ -3395,8 +3396,14 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
 	}
 	if (!waitqueue_active(&pgdat->kswapd_wait))
 		return;
-	if (zone_balanced(zone, order, 0, 0, &dummy))
-		return;
+
+	/* Only wake kswapd if all zones are unbalanced */
+	for (z = 0; z <= zone_idx(zone); z++) {
+		zone = pgdat->node_zones + z;
+
+		if (zone_balanced(zone, order, 0, classzone_idx, &dummy))
+			return;
+	}
 
 	trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, zone_idx(zone), order);
 	wake_up_interruptible(&pgdat->kswapd_wait);
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
