Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 8EF8B828DF
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 10:19:56 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id g62so214971107wme.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 07:19:56 -0800 (PST)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id d3si45309363wja.39.2016.02.23.07.19.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 07:19:55 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id 51E361C195A
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 15:19:55 +0000 (GMT)
Date: Tue, 23 Feb 2016 15:19:53 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 22/27] mm, vmscan: Only wakeup kswapd once per node for the
 requested classzone
Message-ID: <20160223151953.GH2854@techsingularity.net>
References: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

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
index 9f1492b077be..e92765eb0a1e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3411,6 +3411,7 @@ static int kswapd(void *p)
 void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
 {
 	pg_data_t *pgdat;
+	int z;
 
 	if (!populated_zone(zone))
 		return;
@@ -3424,8 +3425,16 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
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
