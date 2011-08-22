Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CD4946B0169
	for <linux-mm@kvack.org>; Sun, 21 Aug 2011 21:06:13 -0400 (EDT)
Subject: [patch]vmscan: clear ZONE_CONGESTED for zone with good watermark
 -resend
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 22 Aug 2011 09:07:26 +0800
Message-ID: <1313975246.29510.11.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, mel <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>

ZONE_CONGESTED is only cleared in kswapd, but pages can be freed in any task.
It's possible ZONE_CONGESTED isn't cleared in some cases:
1. the zone is already balanced just entering balance_pgdat() for order-0 because
concurrent tasks free memory. In this case, later check will skip the zone as
it's balanced so the flag isn't cleared.
2. high order balance fallbacks to order-0. quote from Mel:
At the end of balance_pgdat(), kswapd uses the following logic;

 If reclaiming at high order {
     for each zone {
             if all_unreclaimable
                     skip
             if watermark is not met
                     order = 0
                     loop again

             /* watermark is met */
             clear congested
     }
 }

i.e. it clears ZONE_CONGESTED if it the zone is balanced. if not,
it restarts balancing at order-0. However, if the higher zones are
balanced for order-0, kswapd will miss clearing ZONE_CONGESTED
as that only happens after a zone is shrunk.
This can mean that wait_iff_congested() stalls unnecessarily. This patch
makes kswapd clear ZONE_CONGESTED during its initial highmem->dma scan
for zones that are already balanced.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
Acked-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/vmscan.c |    3 +++
 1 file changed, 3 insertions(+)

Index: linux/mm/vmscan.c
===================================================================
--- linux.orig/mm/vmscan.c	2011-08-11 09:26:37.000000000 +0800
+++ linux/mm/vmscan.c	2011-08-22 09:01:19.000000000 +0800
@@ -2529,6 +2529,9 @@ loop_again:
 					high_wmark_pages(zone), 0, 0)) {
 				end_zone = i;
 				break;
+			} else {
+				/* If balanced, clear the congested flag */
+				zone_clear_flag(zone, ZONE_CONGESTED);
 			}
 		}
 		if (i < 0)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
