Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1E7A36B0169
	for <linux-mm@kvack.org>; Fri, 29 Jul 2011 04:51:50 -0400 (EDT)
Date: Fri, 29 Jul 2011 09:50:43 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 1/3]vmscan: clear ZONE_CONGESTED for zone with good
 watermark
Message-ID: <20110729085043.GO3010@suse.de>
References: <1311840781.15392.407.camel@sli10-conroe>
 <20110728105611.GJ3010@suse.de>
 <1311899725.15392.416.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1311899725.15392.416.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Minchan Kim <minchan.kim@gmail.com>

On Fri, Jul 29, 2011 at 08:35:25AM +0800, Shaohua Li wrote:
> On Thu, 2011-07-28 at 18:56 +0800, Mel Gorman wrote:
> > On Thu, Jul 28, 2011 at 04:13:01PM +0800, Shaohua Li wrote:
> > > correctly clear ZONE_CONGESTED. If a zone watermark is ok, we
> > > should clear ZONE_CONGESTED regardless if this is a high order
> > > allocation, because pages can be reclaimed in other tasks but
> > > ZONE_CONGESTED is only cleared in kswapd.
> > > 
> > 
> > What problem does this solve?
> > 
> > As it is, for high order allocations it takes the following steps
> > 
> > If reclaiming at high order {
> > 	for each zone {
> > 		if all_unreclaimable
> > 			skip
> > 		if watermark is not met
> > 			order = 0
> > 			loop again
> > 		
> > 		/* watermark is met */
> > 		clear congested
> > 	}
> > }
> > 
> > If high orders are failing, kswapd balances for order-0 where there
> > is already a cleaning of ZONE_CONGESTED if the zone was shrunk and
> > became balanced. I see the case for hunk 1 of the patch because now
> > it'll clear ZONE_CONGESTED for zones that are already balanced which
> > might have a noticable effect on wait_iff_congested. Is this what
> > you see? Even if it is, it does not explain hunk 2 of the patch.
> I first looked at the hunk 2 place and thought we don't clear
> ZONE_CONGESTED there. I then figured out we need do the same thing for
> the hunk 1. But you are correct, with hunk 1, hunk 2 isn't required.
> updated patch.
> 
> 
> 
> correctly clear ZONE_CONGESTED. If a zone watermark is ok, we
> should clear ZONE_CONGESTED because pages can be reclaimed in
> other tasks but ZONE_CONGESTED is only cleared in kswapd.
> 
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>

It would be nice if the changelog was expanded a bit to explain
why the patch is necessary. You say this is to "correctly clear
ZONE_CONGESTED" but do not explain why the current code is wrong
or what the user-visible impact is. For example, even cutting and
pasting bits of the discussion like the following would have been
an improvement.

==== CUT HERE ===
kswapd is responsible for clearing ZONE_CONGESTED after it balances
a zone. Unfortunately, if ZONE_CONGESTED was set during a high-order
allocation, it is possible that kswapd misses clearing it.

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
as that only happens after a zone is shrunk. This can mean that
wait_iff_congested() stalls unnecessarily. This patch makes kswapd
clear ZONE_CONGESTED during its initial highmem->dma scan for zones
that are already balanced.

==== CUT HERE ====

This makes review a lot easier and will be helpful in the future if
someone uses git blame.

Whether you update the changelog or not;

Acked-by: Mel Gorman <mgorman@suse.de>

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
