Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1E1A06B009B
	for <linux-mm@kvack.org>; Wed, 31 Dec 2008 07:11:35 -0500 (EST)
Date: Wed, 31 Dec 2008 12:11:31 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] mm: stop kswapd's infinite loop at high order
	allocation
Message-ID: <20081231121130.GD20534@csn.ul.ie>
References: <20081230195006.1286.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081230185919.GA17725@csn.ul.ie> <20081231013233.GB32239@wotan.suse.de> <20081231110619.GA20534@csn.ul.ie> <20081231111647.GF32239@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20081231111647.GF32239@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, wassim dagash <wassim.dagash@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 31, 2008 at 12:16:47PM +0100, Nick Piggin wrote:
> On Wed, Dec 31, 2008 at 11:06:19AM +0000, Mel Gorman wrote:
> > On Wed, Dec 31, 2008 at 02:32:33AM +0100, Nick Piggin wrote:
> > > On Tue, Dec 30, 2008 at 06:59:19PM +0000, Mel Gorman wrote:
> > > > On Tue, Dec 30, 2008 at 07:55:47PM +0900, KOSAKI Motohiro wrote:
> > > > kswapd gets a sc.order when it is known there is a process trying to get
> > > > high-order pages so it can reclaim at that order in an attempt to prevent
> > > > future direct reclaim at a high-order. Your patch does not appear to depend on
> > > > GFP_KERNEL at all so I found the comment misleading. Furthermore, asking it to
> > > > loop again at order-0 means it may scan and reclaim more memory unnecessarily
> > > > seeing as all_zones_ok was calculated based on a high-order value, not order-0.
> > > 
> > > It shouldn't, because it should check all that.
> > > 
> > 
> > Ok, with KOSAKI's patch we
> > 
> > 1. Set order to 0 (and stop kswapd doing what it was asked to do)
> > 2. goto loop_again
> > 3. nr_reclaimed gets set to 0 (meaning we lose that value, but no biggie
> >    as it doesn't get used by the caller anyway)
> > 4. Reset all priorities
> > 5. Do something like the following
> > 
> > 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
> > 		...
> > 		all_zones_ok = 1;
> > 		for (i = pgdat->nr_zones - 1; i >= 0; i--) {
> > 			...
> > 			if (inactive_anon_is_low(zone)) {
> > 				shrink_active_list(SWAP_CLUSTER_MAX, zone,
> > 					&sc, priority, 0);
> > 			}
> > 
> > 			if (!zone_watermark_ok(zone, order, zone->pages_high,
> > 					0, 0)) {
> > 				end_zone = i;
> > 				break;
> > 			}
> > 		}
> > 	}
> > 
> >   So, by looping around, we could end up shrinking the active list again
> >   before we recheck the zone watermarks depending on the size of the
> >   inactive lists.
> 
> If this is a problem, it is a problem with that code, because kswapd
> can be woken up for any zone at any time anyway.
> 
> 
> > > >                 cond_resched();
> > > > 
> > > >                 try_to_freeze();
> > > > 
> > > >                 goto loop_again;
> > > >         }
> > > > 
> > > > I used PAGE_ALLOC_COSTLY_ORDER instead of sc.order == 0 because we are
> > > > expected to support allocations up to that order in a fairly reliable fashion.
> > > 
> > > I actually think it's better to do it for all orders, because that
> > > constant is more or less arbitrary.
> > 
> > i.e.
> > 
> > if (!all_zones_ok && sc.order == 0) {
> > 
> > ? or something else
> 
> Well, I jus tdon't see what's wrong with the original patch.
> 

I've more or less convinced myself it's ok as any anomolies I spotted have
either been described as intentional behaviour or is arguably correct. A
fixed up (or deleted - misleading comments suck) comment and I'm happy.

>  
> > What I did miss was that we have 
> > 
> >                 if (nr_reclaimed >= SWAP_CLUSTER_MAX)
> >                         break;
> > 
> > so with my patch, kswapd is bailing out early without trying to reclaim for
> > high-orders that hard. That was not what I intended as it means we only ever
> > really rebalance the full system for order-0 pages and for everything else we
> > do relatively light scanning. The impact is that high-order users will direct
> > reclaim rather than depending on kswapd scanning very heavily. Arguably,
> > this is a good thing.
> > 
> > However, it also means that KOSAKI's and my patches only differs in that mine
> > bails early and KOSAKI rechecks everything at order-0, possibly reclaiming
> > more. If the comment was not so misleading, I'd have been a lot happier.
> 
> Rechecking everything is fine by me; order-0 is going to be the most
> common and most important. If higher order allocations sometimes have
> to enter direct reclaim or kick off kswapd again, it isn't a big deal.
> 

Grand so. Initially it looked like accidental rather than intentional
behaviour but after thinking about it some more, it should be ok.

> 
> > > IOW, I don't see a big downside, and there is a real upside.
> > > 
> > > I think the patch is good.
> > > 
> > 
> > Which one, KOSAKI's or my one?
> > 
> > Here is my one again which bails out for any high-order allocation after
> > just light scanning.
> > 
> > ====
> > 
> > >From 0e09fe002d8e9956de227b880ef8458842b71ca9 Mon Sep 17 00:00:00 2001
> > From: Mel Gorman <mel@csn.ul.ie>
> > Date: Tue, 30 Dec 2008 18:53:23 +0000
> > Subject: [PATCH] mm: stop kswapd's infinite loop at high order allocation
> > 
> > Wassim Dagash reported the following (editted) kswapd infinite loop problem.
> > 
> >   kswapd runs in some infinite loop trying to swap until order 10 of zone
> >   highmem is OK.... kswapd will continue to try to balance order 10 of zone
> >   highmem forever (or until someone release a very large chunk of highmem).
> > 
> > For costly high-order allocations, the system may never be balanced due to
> > fragmentation but kswapd should not infinitely loop as a result. The
> > following patch lets kswapd stop reclaiming in the event it cannot
> > balance zones and the order is high-order.
> 
> This one bails out if it was a higher order reclaim, but there is still
> an order-0 shortage. I prefer to run the loop again at order==0 to avoid
> that condition. A higher kswapd reclaim order shouldn't weaken kswapd
> postcondition for order-0 memory.
> 
> > 
> > Reported-by: wassim dagash <wassim.dagash@gmail.com>
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > 
> > ---
> >  mm/vmscan.c |   11 ++++++++++-
> >  1 files changed, 10 insertions(+), 1 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 62e7f62..7b0f412 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1867,7 +1867,16 @@ out:
> >  
> >  		zone->prev_priority = temp_priority[i];
> >  	}
> > -	if (!all_zones_ok) {
> > +
> > +	/*
> > +	 * If zones are still not balanced, loop again and continue attempting
> > +	 * to rebalance the system. For high-order allocations, fragmentation
> > +	 * can prevent the zones being rebalanced no matter how hard kswapd
> > +	 * works, particularly on systems with little or no swap. For
> > +	 * high-orders, just give up and assume interested processes will
> > +	 * either direct reclaim or wake up kswapd again as necessary.
> > +	 */
> > +	if (!all_zones_ok && sc.order == 0) {
> >  		cond_resched();
> >  
> >  		try_to_freeze();
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
