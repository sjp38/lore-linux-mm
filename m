Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id A9A776B007E
	for <linux-mm@kvack.org>; Fri, 15 Jul 2011 11:09:05 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 1/2] mm: page allocator: Initialise ZLC for first zone eligible for zone_reclaim
Date: Fri, 15 Jul 2011 16:08:59 +0100
Message-Id: <1310742540-22780-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1310742540-22780-1-git-send-email-mgorman@suse.de>
References: <1310742540-22780-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The zonelist cache (ZLC) is used among other things to record if
zone_reclaim() failed for a particular zone recently. The intention
is to avoid a high cost scanning extremely long zonelists or scanning
within the zone uselessly.

Currently the zonelist cache is setup only after the first zone has
been considered and zone_reclaim() has been called. The objective was
to avoid a costly setup but zone_reclaim is itself quite expensive. If
it is failing regularly such as the first eligible zone having mostly
mapped pages, the cost in scanning and allocation stalls is far higher
than the ZLC initialisation step.

This patch initialises ZLC before the first eligible zone calls
zone_reclaim(). Once initialised, it is checked whether the zone
failed zone_reclaim recently. If it has, the zone is skipped. As the
first zone is now being checked, additional care has to be taken about
zones marked full. A zone can be marked "full" because it should not
have enough unmapped pages for zone_reclaim but this is excessive as
direct reclaim or kswapd may succeed where zone_reclaim fails. Only
mark zones "full" after zone_reclaim fails if it failed to reclaim
enough pages after scanning.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c |   35 ++++++++++++++++++++++-------------
 1 files changed, 22 insertions(+), 13 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4e8985a..6913854 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1664,7 +1664,7 @@ zonelist_scan:
 				continue;
 		if ((alloc_flags & ALLOC_CPUSET) &&
 			!cpuset_zone_allowed_softwall(zone, gfp_mask))
-				goto try_next_zone;
+				continue;
 
 		BUILD_BUG_ON(ALLOC_NO_WATERMARKS < NR_WMARK);
 		if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {
@@ -1676,17 +1676,36 @@ zonelist_scan:
 				    classzone_idx, alloc_flags))
 				goto try_this_zone;
 
+			if (NUMA_BUILD && !did_zlc_setup && nr_online_nodes > 1) {
+				/*
+				 * we do zlc_setup if there are multiple nodes
+				 * and before considering the first zone allowed
+				 * by the cpuset.
+				 */
+				allowednodes = zlc_setup(zonelist, alloc_flags);
+				zlc_active = 1;
+				did_zlc_setup = 1;
+			}
+
 			if (zone_reclaim_mode == 0)
 				goto this_zone_full;
 
+			/*
+			 * As we may have just activated ZLC, check if the first
+			 * eligible zone has failed zone_reclaim recently.
+			 */
+			if (NUMA_BUILD && zlc_active &&
+				!zlc_zone_worth_trying(zonelist, z, allowednodes))
+				continue;
+
 			ret = zone_reclaim(zone, gfp_mask, order);
 			switch (ret) {
 			case ZONE_RECLAIM_NOSCAN:
 				/* did not scan */
-				goto try_next_zone;
+				continue;
 			case ZONE_RECLAIM_FULL:
 				/* scanned but unreclaimable */
-				goto this_zone_full;
+				continue;
 			default:
 				/* did we reclaim enough */
 				if (!zone_watermark_ok(zone, order, mark,
@@ -1703,16 +1722,6 @@ try_this_zone:
 this_zone_full:
 		if (NUMA_BUILD)
 			zlc_mark_zone_full(zonelist, z);
-try_next_zone:
-		if (NUMA_BUILD && !did_zlc_setup && nr_online_nodes > 1) {
-			/*
-			 * we do zlc_setup after the first zone is tried but only
-			 * if there are multiple nodes make it worthwhile
-			 */
-			allowednodes = zlc_setup(zonelist, alloc_flags);
-			zlc_active = 1;
-			did_zlc_setup = 1;
-		}
 	}
 
 	if (unlikely(NUMA_BUILD && page == NULL && zlc_active)) {
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
