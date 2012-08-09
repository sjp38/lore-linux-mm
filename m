Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id E5F446B0044
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 03:49:55 -0400 (EDT)
Date: Thu, 9 Aug 2012 08:49:50 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/6] mm: vmscan: Scale number of pages reclaimed by
 reclaim/compaction based on failures
Message-ID: <20120809074949.GA12690@suse.de>
References: <1344342677-5845-1-git-send-email-mgorman@suse.de>
 <1344342677-5845-3-git-send-email-mgorman@suse.de>
 <20120808014824.GB4247@bbox>
 <20120808075526.GI29814@suse.de>
 <20120808082738.GF4247@bbox>
 <20120808085112.GJ29814@suse.de>
 <20120808235127.GA17835@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120808235127.GA17835@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Jim Schutt <jaschut@sandia.gov>, LKML <linux-kernel@vger.kernel.org>

On Thu, Aug 09, 2012 at 08:51:27AM +0900, Minchan Kim wrote:
> > > > > Just out of curiosity.
> > > > > What's the problem did you see? (ie, What's the problem do this patch solve?)
> > > > 
> > > > Everythign in this series is related to the problem in the leader - high
> > > > order allocation success rates are lower. This patch increases the success
> > > > rates when allocating under load.
> > > > 
> > > > > AFAIUC, it seem to solve consecutive allocation success ratio through
> > > > > getting several free pageblocks all at once in a process/kswapd
> > > > > reclaim context. Right?
> > > > 
> > > > Only pageblocks if it is order-9 on x86, it reclaims an amount that depends
> > > > on an allocation size. This only happens during reclaim/compaction context
> > > > when we know that a high-order allocation has recently failed. The objective
> > > > is to reclaim enough order-0 pages so that compaction can succeed again.
> > > 
> > > Your patch increases the number of pages to be reclaimed with considering
> > > the number of fail case during deferring period and your test proved it's
> > > really good. Without your patch, why can't VM reclaim enough pages?
> > 
> > It could reclaim enough pages but it doesn't. nr_to_reclaim is
> > SWAP_CLUSTER_MAX and that gets short-cutted in direct reclaim at least
> > by 
> > 
> >                 if (sc->nr_reclaimed >= sc->nr_to_reclaim)
> >                         goto out;
> > 
> > I could set nr_to_reclaim in try_to_free_pages() of course and drive
> > it from there but that's just different, not better. If driven from
> > do_try_to_free_pages(), it is also possible that priorities will rise.
> > When they reach DEF_PRIORITY-2, it will also start stalling and setting
> > pages for immediate reclaim which is more disruptive than not desirable
> > in this case. That is a more wide-reaching change than I would expect for
> > this problem and could cause another regression related to THP requests
> > causing interactive jitter.
> 
> Agreed.
> I hope it should be added by changelog.
> 

I guess but it's not really part of this patch is it? The decision on
where to drive should_continue_reclaim from was made in commit [3e7d3449:
mm: vmscan: reclaim order-0 and use compaction instead of lumpy reclaim].

Anyway changelog now reads as

If allocation fails after compaction then compaction may be deferred
for a number of allocation attempts. If there are subsequent failures,
compact_defer_shift is increased to defer for longer periods. This
patch uses that information to scale the number of pages reclaimed with
compact_defer_shift until allocations succeed again. The rationale is
that reclaiming the normal number of pages still allowed compaction to
fail and its success depends on the number of pages. If it's failing,
reclaim more pages until it succeeds again.

Note that this is not implying that VM reclaim is not reclaiming enough
pages or that its logic is broken. try_to_free_pages() always asks for
SWAP_CLUSTER_MAX pages to be reclaimed regardless of order and that is
what it does. Direct reclaim stops normally with this check.

        if (sc->nr_reclaimed >= sc->nr_to_reclaim)
                goto out;

should_continue_reclaim delays when that check is made until a minimum number
of pages for reclaim/compaction are reclaimed. It is possible that this patch
could instead set nr_to_reclaim in try_to_free_pages() and drive it from
there but that's behaves differently and not necessarily for the better.
If driven from do_try_to_free_pages(), it is also possible that priorities
will rise. When they reach DEF_PRIORITY-2, it will also start stalling
and setting pages for immediate reclaim which is more disruptive than not
desirable in this case. That is a more wide-reaching change that could
cause another regression related to THP requests causing interactive jitter.

> > 
> > > Other processes steal the pages reclaimed?
> > 
> > Or the page it reclaimed were in pageblocks that could not be used.
> > 
> > > Why I ask a question is that I want to know what's the problem at current
> > > VM.
> > > 
> > 
> > We cannot reliably tell in advance whether compaction is going to succeed
> > in the future without doing a full scan of the zone which would be both
> > very heavy and race with any allocation requests. Compaction needs free
> > pages to succeed so the intention is to scale the number of pages reclaimed
> > with the number of recent compaction failures.
> 
> > If allocation fails after compaction then compaction may be deferred for
> > a number of allocation attempts. If there are subsequent failures,
> > compact_defer_shift is increased to defer for longer periods. This patch
> > uses that information to scale the number of pages reclaimed with
> > compact_defer_shift until allocations succeed again.
> > 
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > ---
> >  mm/vmscan.c |   10 ++++++++++
> >  1 file changed, 10 insertions(+)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 66e4310..0cb2593 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1708,6 +1708,7 @@ static inline bool should_continue_reclaim(struct lruvec *lruvec,
> >  {
> >       unsigned long pages_for_compaction;
> >       unsigned long inactive_lru_pages;
> > +     struct zone *zone;
> >  
> >       /* If not in reclaim/compaction mode, stop */
> >       if (!in_reclaim_compaction(sc))
> > @@ -1741,6 +1742,15 @@ static inline bool should_continue_reclaim(struct lruvec *lruvec,
> >        * inactive lists are large enough, continue reclaiming
> >        */
> >       pages_for_compaction = (2UL << sc->order);
> > +
> > +     /*
> > +      * If compaction is deferred for this order then scale the number of
> 
> this order? sc->order?
> 

yes. Comment changed to clarify.

> > +      * pages reclaimed based on the number of consecutive allocation
> > +      * failures
> > +      */
> > +     zone = lruvec_zone(lruvec);
> > +     if (zone->compact_order_failed >= sc->order)
> 
> I can't understand this part.
> We don't defer lower order than compact_order_failed by aff62249.
> Do you mean lower order compaction context should be a lamb for
> deferred higher order allocation request success? I think it's not fair
> and even I can't understand rationale why it has to scale the number of pages
> reclaimed with the number of recent compaction failture.
> Your changelog just says "What we have to do, NOT Why we have to do".
> 

I'm a moron, that should be <=, not >=. All my tests were based on order==9
and that was the only order using reclaim/compaction so it happened to
work as expected. Thanks! I fixed that and added the following
clarification to the changelog

The rationale is that reclaiming the normal number of pages still allowed
compaction to fail and its success depends on the number of pages. If it's
failing, reclaim more pages until it succeeds again.

Does that make more sense?

> 
> > +             pages_for_compaction <<= zone->compact_defer_shift;
> 
> 
> >       inactive_lru_pages = get_lru_size(lruvec, LRU_INACTIVE_FILE);
> >       if (nr_swap_pages > 0)
> >               inactive_lru_pages += get_lru_size(lruvec, LRU_INACTIVE_ANON);

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
