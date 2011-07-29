Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 51AFF6B0169
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 20:35:28 -0400 (EDT)
Subject: Re: [patch 1/3]vmscan: clear ZONE_CONGESTED for zone with good
 watermark
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <20110728105611.GJ3010@suse.de>
References: <1311840781.15392.407.camel@sli10-conroe>
	 <20110728105611.GJ3010@suse.de>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 29 Jul 2011 08:35:25 +0800
Message-ID: <1311899725.15392.416.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Minchan Kim <minchan.kim@gmail.com>

On Thu, 2011-07-28 at 18:56 +0800, Mel Gorman wrote:
> On Thu, Jul 28, 2011 at 04:13:01PM +0800, Shaohua Li wrote:
> > correctly clear ZONE_CONGESTED. If a zone watermark is ok, we
> > should clear ZONE_CONGESTED regardless if this is a high order
> > allocation, because pages can be reclaimed in other tasks but
> > ZONE_CONGESTED is only cleared in kswapd.
> > 
> 
> What problem does this solve?
> 
> As it is, for high order allocations it takes the following steps
> 
> If reclaiming at high order {
> 	for each zone {
> 		if all_unreclaimable
> 			skip
> 		if watermark is not met
> 			order = 0
> 			loop again
> 		
> 		/* watermark is met */
> 		clear congested
> 	}
> }
> 
> If high orders are failing, kswapd balances for order-0 where there
> is already a cleaning of ZONE_CONGESTED if the zone was shrunk and
> became balanced. I see the case for hunk 1 of the patch because now
> it'll clear ZONE_CONGESTED for zones that are already balanced which
> might have a noticable effect on wait_iff_congested. Is this what
> you see? Even if it is, it does not explain hunk 2 of the patch.
I first looked at the hunk 2 place and thought we don't clear
ZONE_CONGESTED there. I then figured out we need do the same thing for
the hunk 1. But you are correct, with hunk 1, hunk 2 isn't required.
updated patch.



correctly clear ZONE_CONGESTED. If a zone watermark is ok, we
should clear ZONE_CONGESTED because pages can be reclaimed in
other tasks but ZONE_CONGESTED is only cleared in kswapd.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 mm/vmscan.c |    3 +++
 1 file changed, 3 insertions(+)

Index: linux/mm/vmscan.c
===================================================================
--- linux.orig/mm/vmscan.c	2011-07-29 08:24:10.000000000 +0800
+++ linux/mm/vmscan.c	2011-07-29 08:26:29.000000000 +0800
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


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
