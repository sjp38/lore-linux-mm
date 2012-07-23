Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 3A9436B005A
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 09:38:56 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 10/34] mm: Abort reclaim/compaction if compaction can proceed
Date: Mon, 23 Jul 2012 14:38:23 +0100
Message-Id: <1343050727-3045-11-git-send-email-mgorman@suse.de>
In-Reply-To: <1343050727-3045-1-git-send-email-mgorman@suse.de>
References: <1343050727-3045-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable <stable@vger.kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

commit e0c23279c9f800c403f37511484d9014ac83adec upstream.

Stable note: Not tracked on Bugzilla. THP and compaction was found to
	aggressively reclaim pages and stall systems under different
	situations that was addressed piecemeal over time.

If compaction can proceed, shrink_zones() stops doing any work but its
callers still call shrink_slab() which raises the priority and potentially
sleeps.  This is unnecessary and wasteful so this patch aborts direct
reclaim/compaction entirely if compaction can proceed.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Acked-by: Johannes Weiner <jweiner@redhat.com>
Cc: Josh Boyer <jwboyer@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
---
 mm/vmscan.c |   32 +++++++++++++++++++++-----------
 1 file changed, 21 insertions(+), 11 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index d11b6c4..65388ac 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2037,14 +2037,19 @@ restart:
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
@@ -2061,19 +2066,20 @@ static void shrink_zones(int priority, struct zonelist *zonelist,
 				continue;	/* Let kswapd poll it */
 			if (COMPACTION_BUILD) {
 				/*
-				 * If we already have plenty of memory
-				 * free for compaction, don't free any
-				 * more.  Even though compaction is
-				 * invoked for any non-zero order,
-				 * only frequent costly order
-				 * reclamation is disruptive enough to
-				 * become a noticable problem, like
-				 * transparent huge page allocations.
+				 * If we already have plenty of memory free for
+				 * compaction in this zone, don't free any more.
+				 * Even though compaction is invoked for any
+				 * non-zero order, only frequent costly order
+				 * reclamation is disruptive enough to become a
+				 * noticable problem, like transparent huge page
+				 * allocations.
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
@@ -2092,6 +2098,8 @@ static void shrink_zones(int priority, struct zonelist *zonelist,
 
 		shrink_zone(priority, zone, sc);
 	}
+
+	return should_abort_reclaim;
 }
 
 static bool zone_reclaimable(struct zone *zone)
@@ -2156,7 +2164,9 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
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
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
