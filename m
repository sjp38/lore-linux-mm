Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5847C6B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 13:30:25 -0500 (EST)
Date: Thu, 18 Nov 2010 18:30:07 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/8] mm: vmscan: Reclaim order-0 and use compaction
	instead of lumpy reclaim
Message-ID: <20101118183006.GO8135@csn.ul.ie>
References: <1290010969-26721-1-git-send-email-mel@csn.ul.ie> <1290010969-26721-4-git-send-email-mel@csn.ul.ie> <20101118180956.GA30376@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101118180956.GA30376@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 18, 2010 at 07:09:56PM +0100, Andrea Arcangeli wrote:
> On Wed, Nov 17, 2010 at 04:22:44PM +0000, Mel Gorman wrote:
> > +	 */
> > +	if (sc->lumpy_reclaim_mode & LUMPY_MODE_COMPACTION)
> > +		nr_to_scan = max(nr_to_scan, (1UL << sc->order));
> 
> Just one nitpick: I'm not sure this is a good idea. We can scan quite
> some pages and we may do nothing on them.

True, I could loop based on nr_taken taking care to not infinite loop in
there.

> First I guess for symmetry
> this should be 2UL << sc->oder to match the 2UL << order in the
> watermark checks in compaction.c (maybe it should be 3UL if something
> considering the probability at least one page is mapped and won't be
> freed is quite high). But SWAP_CLUSTER_MAX is only 32 pages.. not even
> close to 1UL << 9 (hugepage order 9).

True again, the scan rate gets bumped up for compaction recognising that
more pages are required.

> So I think this can safely be
> removed... it only makes a difference for the stack with order 2. And
> for order 2 when we take the spinlocks we can take all 32 pages
> without screwing the "free" levels in any significant way, considering
> maybe only 4 pages are really freed in the end, and if all 32 pages
> are really freed (i.e. all plain clean cache), all that matters to
> avoid freeing more cache is to stick to compaction next time around
> (i.e. at the next allocation). And if compaction fails again next time
> around, then it's all right to shrink 32 more pages even for order
> 2...
> 

Well, I'm expecting the exit of direct reclaim and another full
allocation loop so this is taken into account.

> In short I'd delete the above chunk and to run the shrinker unmodified
> as this is a too lowlevel idea, and the only real life effect is to
> decrease VM scalability for kernel stack allocation a tiny bit, with
> no benefit whatsoever.
> 

I'm not sure I get this. If it reclaims too few pages then compaction
will just fail the next time so we'll take the larger loop more
frequently. This in itself is not too bad although it interferes with
the patches later in the series that has try_to_compact_pages() do a
faster scan than this inner compaction loop.

> It's subtle because the difference it'd makes it so infinitesimal and
> I can only imagine it's a worsening overall difference.

I can try it out to be sure but right now I'm not convinced. Then again,
I'm burned out after reviewing THP so I'm not at my best either :)

> > @@ -1425,6 +1438,9 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
> >  
> >  	putback_lru_pages(zone, sc, nr_anon, nr_file, &page_list);
> >  
> > +	if (sc->lumpy_reclaim_mode & LUMPY_MODE_COMPACTION)
> > +		reclaimcompact_zone_order(zone, sc->order, sc->gfp_mask);
> > +
> >  	trace_mm_vmscan_lru_shrink_inactive(zone->zone_pgdat->node_id,
> >  		zone_idx(zone),
> >  		nr_scanned, nr_reclaimed,
> 
> I'm worried about this one as the objective here is to increase the
> amount of free pages, and the loop won't stop until we reach
> nr_reclaimed >= nr_to_reclaim.

Which remains at SWAP_CLUSTER_MAX. shrink_inactive_list is doing more
work than requested to satisfy the compaction requirements. It could be
fed directly into nr_to_reclaim though if necessary.

> I'm afraid it'd lead sometime to be
> doing an overwork of compaction here for no good. In short there is no
> feedback check into the loop to verify if this newly introduced
> compaction work in the shrinker lead us to get the hugepage and stop
> the loop. It sounds some pretty random compaction invocation here just
> to run it more frequently.
> 

While we enter compaction, we also use compaction_suitable() to predict
if compaction would be a waste of time. If it would be, we don't compact
and instead go all the way out to the allocator again. From this
perspective, it makes more sense to have altered nr_to_reclaim than
nr_to_scan.

> nr_to_reclaim is only 32 anyway. So my suggestion is to remove it and
> let the shrinker do its thing without interleaving compaction inside
> the shrinker, without feedback check if the compaction actually
> succeeded (maybe 100% of free ram is contiguous already), and then try
> compaction again outside of the shrinker interleaving it with the
> shrinker as usual if the watermarks aren't satisfied yet after
> shrinker freed nr_to_reclaim pages.
> 

I'll try it but again it busts the idea of try_to_compact_page() doing an
optimistic compaction of a subset of pages. It also puts a bit of a hole in
the idea of developing lumpy compaction later because the outer allocation
loop is unsuitable and I'm not keen on the idea of putting reclaim logic
in mm/compaction.c

> I prefer we keep separated the job of freeing more pages from the job
> of compacting the single free pages into higher order pages. It's only
> 32 pages being freed we're talking about here so no need to calling
> compaction more frequently

Compaction doesn't happen if enough pages are not free. Yes, I call into
compaction but it shouldn't do any heavy work. It made more sense to do
it that way than embed more compaction awareness into vmscan.c

> (if something we should increase
> nr_to_reclaim to 512 and to call compaction less frequently). If the
> interleaving of the caller isn't ok then fix it in the caller and also
> update the nr_to_reclaim, but I think keeping those separated is way
> cleaner and the mixture is unnecessary.
> 

I'll look closer at altering nr_to_reclaim instead of nr_to_scan. Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
