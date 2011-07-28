Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id DEEC36B0169
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 04:13:05 -0400 (EDT)
Subject: [patch 1/3]vmscan: clear ZONE_CONGESTED for zone with good
 watermark
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 28 Jul 2011 16:13:01 +0800
Message-ID: <1311840781.15392.407.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, mgorman@suse.de, Minchan Kim <minchan.kim@gmail.com>

correctly clear ZONE_CONGESTED. If a zone watermark is ok, we
should clear ZONE_CONGESTED regardless if this is a high order
allocation, because pages can be reclaimed in other tasks but
ZONE_CONGESTED is only cleared in kswapd.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 mm/vmscan.c |   28 +++++++++++++++-------------
 1 file changed, 15 insertions(+), 13 deletions(-)

Index: linux/mm/vmscan.c
===================================================================
--- linux.orig/mm/vmscan.c	2011-07-25 09:37:11.000000000 +0800
+++ linux/mm/vmscan.c	2011-07-28 15:17:56.000000000 +0800
@@ -2494,6 +2494,9 @@ loop_again:
 					high_wmark_pages(zone), 0, 0)) {
 				end_zone = i;
 				break;
+			} else {
+				/* If balanced, clear the congested flag */
+				zone_clear_flag(zone, ZONE_CONGESTED);
 			}
 		}
 		if (i < 0)
@@ -2665,26 +2668,25 @@ out:
 	 * be cleared as kswapd is the only mechanism that clears the flag
 	 * and it is potentially going to sleep here.
 	 */
-	if (order) {
-		for (i = 0; i <= end_zone; i++) {
-			struct zone *zone = pgdat->node_zones + i;
+	for (i = 0; i <= end_zone; i++) {
+		struct zone *zone = pgdat->node_zones + i;
 
-			if (!populated_zone(zone))
-				continue;
+		if (!populated_zone(zone))
+			continue;
 
-			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
-				continue;
+		if (zone->all_unreclaimable && priority != DEF_PRIORITY)
+			continue;
 
-			/* Confirm the zone is balanced for order-0 */
-			if (!zone_watermark_ok(zone, 0,
-					high_wmark_pages(zone), 0, 0)) {
+		/* Confirm the zone is balanced for order-0 */
+		if (!zone_watermark_ok(zone, 0, high_wmark_pages(zone), 0, 0)) {
+			if (order) {
 				order = sc.order = 0;
 				goto loop_again;
 			}
-
-			/* If balanced, clear the congested flag */
-			zone_clear_flag(zone, ZONE_CONGESTED);
 		}
+
+		/* If balanced, clear the congested flag */
+		zone_clear_flag(zone, ZONE_CONGESTED);
 	}
 
 	/*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
