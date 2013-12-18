Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0452D6B0037
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 14:42:09 -0500 (EST)
Received: by mail-ee0-f47.google.com with SMTP id e51so37956eek.20
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 11:42:09 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h45si1431747eeo.130.2013.12.18.11.42.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 11:42:09 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 4/6] mm: page_alloc: Use zone node IDs to approximate locality
Date: Wed, 18 Dec 2013 19:42:01 +0000
Message-Id: <1387395723-25391-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1387395723-25391-1-git-send-email-mgorman@suse.de>
References: <1387395723-25391-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

zone_local is using node_distance which is a more expensive call than
necessary. On x86, it's another function call in the allocator fast path
and increases cache footprint. This patch makes the assumption zones on
the preferred node will share the same node ID. The necessary information
should already be cache hot.

Cc: <stable@kernel.org> # 3.12
Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Rik van Riel <riel@redhat.com>
---
 mm/page_alloc.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2cd694c..5aeb2c6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1822,9 +1822,10 @@ static void zlc_clear_zones_full(struct zonelist *zonelist)
 	bitmap_zero(zlc->fullzones, MAX_ZONES_PER_ZONELIST);
 }
 
-static bool zone_local(struct zone *local_zone, struct zone *zone)
+/* Returns if the zone is is on the same node as the preferred node */
+static bool zone_preferred_node(struct zone *preferred_zone, struct zone *zone)
 {
-	return node_distance(local_zone->node, zone->node) == LOCAL_DISTANCE;
+	return zone_to_nid(preferred_zone) == zone_to_nid(zone);
 }
 
 static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
@@ -1864,7 +1865,7 @@ static void zlc_clear_zones_full(struct zonelist *zonelist)
 {
 }
 
-static bool zone_local(struct zone *local_zone, struct zone *zone)
+static bool zone_preferred_node(struct zone *preferred_zone, struct zone *zone)
 {
 	return true;
 }
@@ -1909,7 +1910,7 @@ static bool zone_distribute_age(gfp_t gfp_mask, struct zone *preferred_zone,
 	 * back to remote zones that do not partake in the fairness round-robin
 	 * cycle of this zonelist.
 	 */
-	if (zone_reclaim_mode && !zone_local(preferred_zone, zone))
+	if (zone_reclaim_mode && !zone_preferred_node(preferred_zone, zone))
 		return true;
 
 	return false;
@@ -2420,7 +2421,7 @@ static void prepare_slowpath(gfp_t gfp_mask, unsigned int order,
 		 * thrash fairness information for zones that are not
 		 * actually part of this zonelist's round-robin cycle.
 		 */
-		if (zone_reclaim_mode && !zone_local(preferred_zone, zone))
+		if (zone_reclaim_mode && !zone_preferred_node(preferred_zone, zone))
 			continue;
 		mod_zone_page_state(zone, NR_ALLOC_BATCH,
 				    high_wmark_pages(zone) -
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
