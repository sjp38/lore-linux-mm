Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D8CC46B0047
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 04:57:20 -0500 (EST)
Date: Tue, 17 Feb 2009 09:57:17 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch] vmscan: initialize sc.order in indirect shrink_list()
	users
Message-ID: <20090217095716.GD31264@csn.ul.ie>
References: <20090210165134.GA2457@cmpxchg.org> <20090210162948.bd20d853.akpm@linux-foundation.org> <20090211015227.GA4605@cmpxchg.org> <20090216145349.GC16153@csn.ul.ie> <20090216220302.GA3415@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090216220302.GA3415@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 16, 2009 at 11:03:02PM +0100, Johannes Weiner wrote:
> On Mon, Feb 16, 2009 at 02:53:49PM +0000, Mel Gorman wrote:
> > On Wed, Feb 11, 2009 at 02:52:27AM +0100, Johannes Weiner wrote:
> > > [added Mel to CC]
> > > 
> > > On Tue, Feb 10, 2009 at 04:29:48PM -0800, Andrew Morton wrote:
> > > > On Tue, 10 Feb 2009 17:51:35 +0100
> > > > Johannes Weiner <hannes@cmpxchg.org> wrote:
> > > > 
> > > > > shrink_all_memory() and __zone_reclaim() currently don't initialize
> > > > > the .order field of their scan control.
> > > > > 
> > > > > Both of them call into functions which use that field and make certain
> > > > > decisions based on a random value.
> > > > > 
> > > > > The functions depending on the .order field are marked with a star,
> > > > > the faulty entry points are marked with a percentage sign:
> > > > > 
> > > > > * shrink_page_list()
> > > > >   * shrink_inactive_list()
> > > > >   * shrink_active_list()
> > > > >     shrink_list()
> > > > >       shrink_all_zones()
> > > > >         % shrink_all_memory()
> > > > >       shrink_zone()
> > > > >         % __zone_reclaim()
> > > > > 
> > > > > Initialize .order to zero in shrink_all_memory().  Initialize .order
> > > > > to the order parameter in __zone_reclaim().
> > > > > 
> > > > > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > > > > ---
> > > > >  mm/vmscan.c |    2 ++
> > > > >  1 files changed, 2 insertions(+), 0 deletions(-)
> > > > > 
> > > > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > > > index 4422301..9ce85ea 100644
> > > > > --- a/mm/vmscan.c
> > > > > +++ b/mm/vmscan.c
> > > > > @@ -2112,6 +2112,7 @@ unsigned long shrink_all_memory(unsigned long nr_pages)
> > > > >  		.may_unmap = 0,
> > > > >  		.swap_cluster_max = nr_pages,
> > > > >  		.may_writepage = 1,
> > > > > +		.order = 0,
> > > > >  		.isolate_pages = isolate_pages_global,
> > > > >  	};
> > > > >  
> > > > > @@ -2294,6 +2295,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
> > > > >  					SWAP_CLUSTER_MAX),
> > > > >  		.gfp_mask = gfp_mask,
> > > > >  		.swappiness = vm_swappiness,
> > > > > +		.order = order,
> > > > >  		.isolate_pages = isolate_pages_global,
> > > > >  	};
> > > > >  	unsigned long slab_reclaimable;
> > > > 
> > > > The second hunk might fix something, but it would need a correcter
> > > > changelog, and some thought about what its runtimes effects are likely
> > > > to be, please.
> > > 
> > > zone_reclaim() is used by the watermark rebalancing of the buddy
> > > allocator right before trying to do an allocation.  Even though it
> > > tries to reclaim at least 1 << order pages, it doesn't raise sc.order
> > > to increase clustering efforts.
> > > 
> > 
> > This affects lumpy reclaim. Direct reclaim via try_to_free_pages() and
> > kswapd() is still working but the earlier reclaim attempt via zone_reclaim()
> > on unmapped file and slab pages is ignoring teh order. While it'd be tricky
> > to measure any difference, it does make sense that __zone_reclaim() initialse
> > the order with what the caller requested.
> > 
> > > I think this happens with the assumption that the upcoming allocation
> > > can still succeed and in that case we don't want to lump too
> > > aggressively to refill the zone. 
> > 
> > I don't get what you mean here. The caller requested the higher order so
> > the work has been requested.
> 
> I meant the buffered_rmqueue() might still succeed even without lumpy
> reclaim in the case of low watermarks reached. 

I think I get you now. You are saying that reclaiming order-0 pages increases
the free count so we might get over the watermarks and the allocation would
succeed. Thing is, watermarks calculated in zone_watermark_ok() take order
as a parameter and has this in it.

        for (o = 0; o < order; o++) {
                /* At the next order, this order's pages become * unavailable */
                free_pages -= z->free_area[o].nr_free << o;

So, to reach the low watermarks for a high-order allocation, we still
need lumpy reclaim.

> And if it does, we
> reclaimed 'in aggressive mode without reason'.  If it does NOT, we
> still drop into direct reclaim with lumpy reclaim.  Well, this is at
> least what I had in mind when writing the above.
> 
> > > The allocation might succeed on
> > > another zone and now we have evicted precious pages due to clustering
> > > while we are still not sure it's even needed.
> > > 
> > 
> > Also not sure what you are getting at here. zone_reclaim() is called for the
> > preferred zones in order. Attempts are made to free within the preferred zone
> > and then allocate from it. Granted, it might evict pages and the clustering
> > was ineffective, but this is the cost of high-order reclaim.
> 
> Sure, agreed.  I was just wondering whether higher-order reclaim was
> needed up-front when the low watermarks are reached or if it was
> enough when direct reclaim is lumpy in case the allocation fails.
> 

It's needed up front because order is also taken into account for the
watermark calculations.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
