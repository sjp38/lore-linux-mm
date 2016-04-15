Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4759B82F60
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 05:17:20 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id l15so64198438lfg.2
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 02:17:20 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id cz8si9207416wjd.11.2016.04.15.02.17.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Apr 2016 02:17:19 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id B1B842F8309
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 09:17:18 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 21/27] mm, vmscan: Only wakeup kswapd once per node for the requested classzone
Date: Fri, 15 Apr 2016 10:13:27 +0100
Message-Id: <1460711613-2761-22-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460711613-2761-1-git-send-email-mgorman@techsingularity.net>
References: <1460711613-2761-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

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
index 9f2376ad4ce3..1931e98d2f67 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3423,6 +3423,7 @@ static int kswapd(void *p)
 void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
 {
 	pg_data_t *pgdat;
+	int z;
 
 	if (!populated_zone(zone))
 		return;
@@ -3436,8 +3437,16 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
 	pgdat->kswapd_order = max(pgdat->kswapd_order, order);
 	if (!waitqueue_active(&pgdat->kswapd_wait))
 		return;
-	if (zone_balanced(zone, order, 0))
-		return;
+
+	/* Only wake kswapd if all zones are unbalanced */
+	for (z = 0; z <= classzone_idx; z++) {
+		zone = pgdat->node_zones + z;
+		if (!populated_zone(zone))
+			continue;
+
+		if (zone_balanced(zone, order, classzone_idx))
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
