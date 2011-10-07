Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 324D36B002D
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 11:18:34 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 2/2] mm: Abort reclaim/compaction if compaction can proceed
Date: Fri,  7 Oct 2011 16:17:23 +0100
Message-Id: <1318000643-27996-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1318000643-27996-1-git-send-email-mgorman@suse.de>
References: <1318000643-27996-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, akpm@linux-foundation.org
Cc: Josh Boyer <jwboyer@redhat.com>, aarcange@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

If compaction can proceed, shrink_zones() stops doing any work but
the callers still shrink_slab(), raises the priority and potentially
sleeps.  This patch aborts direct reclaim/compaction entirely if
compaction can proceed.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c |   20 ++++++++++++++++----
 1 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3817fa9..522f205 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2044,14 +2044,19 @@ restart:
  *
  * If a zone is deemed to be full of pinned pages then just give it a light
  * scan then give up on it.
+ *
+ * This function returns true if a zone is being reclaimed for a costly
+ * high-order allocation and compaction is either ready to begin or deferred.
+ * This indicates to the caller that it should retry the allocation or fail.
  */
-static void shrink_zones(int priority, struct zonelist *zonelist,
+static bool shrink_zones(int priority, struct zonelist *zonelist,
 					struct scan_control *sc)
 {
 	struct zoneref *z;
 	struct zone *zone;
 	unsigned long nr_soft_reclaimed;
 	unsigned long nr_soft_scanned;
+	bool should_abort_reclaim = false;
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 					gfp_zone(sc->gfp_mask), sc->nodemask) {
@@ -2069,12 +2074,15 @@ static void shrink_zones(int priority, struct zonelist *zonelist,
 			if (COMPACTION_BUILD) {
 				/*
 				 * If we already have plenty of memory free
-				 * for compaction, don't free any more.
+				 * for compaction in this zone , don't free any
+				 * more.
 				 */
 				if (sc->order > PAGE_ALLOC_COSTLY_ORDER &&
 					(compaction_suitable(zone, sc->order) ||
-					 compaction_deferred(zone)))
+					 compaction_deferred(zone))) {
+					should_abort_reclaim = true;
 					continue;
+				}
 			}
 			/*
 			 * This steals pages from memory cgroups over softlimit
@@ -2093,6 +2101,8 @@ static void shrink_zones(int priority, struct zonelist *zonelist,
 
 		shrink_zone(priority, zone, sc);
 	}
+
+	return should_abort_reclaim;
 }
 
 static bool zone_reclaimable(struct zone *zone)
@@ -2157,7 +2167,9 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		sc->nr_scanned = 0;
 		if (!priority)
 			disable_swap_token(sc->mem_cgroup);
-		shrink_zones(priority, zonelist, sc);
+		if (shrink_zones(priority, zonelist, sc))
+			break;
+
 		/*
 		 * Don't shrink slabs when reclaiming memory from
 		 * over limit cgroups
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
