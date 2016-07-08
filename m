Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 462676B0270
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 05:38:58 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id a2so26999639lfe.0
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 02:38:58 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id y200si2061840wme.141.2016.07.08.02.38.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jul 2016 02:38:57 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id AD4901C0F74
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 10:38:56 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 21/34] mm, vmscan: only wakeup kswapd once per node for the requested classzone
Date: Fri,  8 Jul 2016 10:34:57 +0100
Message-Id: <1467970510-21195-22-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

kswapd is woken when zones are below the low watermark but the wakeup
decision is not taking the classzone into account.  Now that reclaim is
node-based, it is only required to wake kswapd once per node and only if
all zones are unbalanced for the requested classzone.

Note that one node might be checked multiple times if the zonelist is
ordered by node because there is no cheap way of tracking what nodes have
already been visited.  For zone-ordering, each node should be checked only
once.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_alloc.c |  8 ++++++--
 mm/vmscan.c     | 13 +++++++++++--
 2 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index fd34b305c8ee..bb261885c121 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3410,10 +3410,14 @@ static void wake_all_kswapds(unsigned int order, const struct alloc_context *ac)
 {
 	struct zoneref *z;
 	struct zone *zone;
+	pg_data_t *last_pgdat = NULL;
 
 	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist,
-						ac->high_zoneidx, ac->nodemask)
-		wakeup_kswapd(zone, order, ac_classzone_idx(ac));
+					ac->high_zoneidx, ac->nodemask) {
+		if (last_pgdat != zone->zone_pgdat)
+			wakeup_kswapd(zone, order, ac_classzone_idx(ac));
+		last_pgdat = zone->zone_pgdat;
+	}
 }
 
 static inline unsigned int
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5ad670881d8d..cc820bbe9c01 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3419,6 +3419,7 @@ static int kswapd(void *p)
 void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
 {
 	pg_data_t *pgdat;
+	int z;
 
 	if (!populated_zone(zone))
 		return;
@@ -3430,8 +3431,16 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
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
