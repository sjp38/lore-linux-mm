Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A46946B01FF
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 13:21:49 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 05/10] vmscan: Remove unnecessary temporary vars in do_try_to_free_pages
Date: Thu, 15 Apr 2010 18:21:38 +0100
Message-Id: <1271352103-2280-6-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1271352103-2280-1-git-send-email-mel@csn.ul.ie>
References: <1271352103-2280-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Remove temporary variable that is only used once and does not help
clarify code.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/vmscan.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 838ac8b..1ace7c6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1685,13 +1685,12 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
  */
 static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 {
-	enum zone_type high_zoneidx = gfp_zone(sc->gfp_mask);
 	struct zoneref *z;
 	struct zone *zone;
 
 	sc->all_unreclaimable = 1;
-	for_each_zone_zonelist_nodemask(zone, z, zonelist, high_zoneidx,
-					sc->nodemask) {
+	for_each_zone_zonelist_nodemask(zone, z, zonelist,
+				gfp_zone(sc->gfp_mask), sc->nodemask) {
 		if (!populated_zone(zone))
 			continue;
 		/*
@@ -1741,7 +1740,6 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 	unsigned long lru_pages = 0;
 	struct zoneref *z;
 	struct zone *zone;
-	enum zone_type high_zoneidx = gfp_zone(sc->gfp_mask);
 	unsigned long writeback_threshold;
 
 	delayacct_freepages_start();
@@ -1752,7 +1750,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 	 * mem_cgroup will not do shrink_slab.
 	 */
 	if (scanning_global_lru(sc)) {
-		for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
+		for_each_zone_zonelist(zone, z, zonelist, gfp_zone(sc->gfp_mask)) {
 
 			if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 				continue;
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
