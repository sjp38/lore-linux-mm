Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8E807828E1
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 11:41:23 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id a66so21774301wme.1
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 08:41:23 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id l184si4398424wmg.12.2016.07.01.08.41.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Jul 2016 08:41:22 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 3C8C098E1F
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 15:41:22 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 20/31] mm, vmscan: only wakeup kswapd once per node for the requested classzone
Date: Fri,  1 Jul 2016 16:37:35 +0100
Message-Id: <1467387466-10022-21-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1467387466-10022-1-git-send-email-mgorman@techsingularity.net>
References: <1467387466-10022-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

kswapd is woken when zones are below the low watermark but the wakeup
decision is not taking the classzone into account.  Now that reclaim is
node-based, it is only required to wake kswapd once per node and only if
all zones are unbalanced for the requested classzone.

Note that one node might be checked multiple times if the zonelist is
ordered by node because there is no cheap way of tracking what nodes have
already been visited.  For zone-ordering, each node should be checked only
once.

Link: http://lkml.kernel.org/r/1466518566-30034-22-git-send-email-mgorman@techsingularity.net
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@surriel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 mm/page_alloc.c |  8 ++++++--
 mm/vmscan.c     | 13 +++++++++++--
 2 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 441f482bf9a2..2fe2fbb4f2ad 100644
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
index c1c8b77d8cb4..e02091be0e12 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3420,6 +3420,7 @@ static int kswapd(void *p)
 void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
 {
 	pg_data_t *pgdat;
+	int z;
 
 	if (!populated_zone(zone))
 		return;
@@ -3433,8 +3434,16 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
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
