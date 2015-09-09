Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id BA78A6B0255
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 08:39:08 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so155271772wic.1
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 05:39:08 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id co6si12307702wjb.32.2015.09.09.05.39.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 09 Sep 2015 05:39:07 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 61B72F40CF
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 12:39:05 +0000 (UTC)
Date: Wed, 9 Sep 2015 13:39:01 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 12/12] mm, page_alloc: Only enforce watermarks for
 order-0 allocations
Message-ID: <20150909123901.GA12432@techsingularity.net>
References: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
 <20150824123015.GJ12432@techsingularity.net>
 <CAAmzW4NbjqOpDhNKp7POVLZyaoUJa6YU5-B9Xz2b+crkzD25+g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAAmzW4NbjqOpDhNKp7POVLZyaoUJa6YU5-B9Xz2b+crkzD25+g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Sep 08, 2015 at 05:26:13PM +0900, Joonsoo Kim wrote:
> 2015-08-24 21:30 GMT+09:00 Mel Gorman <mgorman@techsingularity.net>:
> > The primary purpose of watermarks is to ensure that reclaim can always
> > make forward progress in PF_MEMALLOC context (kswapd and direct reclaim).
> > These assume that order-0 allocations are all that is necessary for
> > forward progress.
> >
> > High-order watermarks serve a different purpose. Kswapd had no high-order
> > awareness before they were introduced (https://lkml.org/lkml/2004/9/5/9).
> > This was particularly important when there were high-order atomic requests.
> > The watermarks both gave kswapd awareness and made a reserve for those
> > atomic requests.
> >
> > There are two important side-effects of this. The most important is that
> > a non-atomic high-order request can fail even though free pages are available
> > and the order-0 watermarks are ok. The second is that high-order watermark
> > checks are expensive as the free list counts up to the requested order must
> > be examined.
> >
> > With the introduction of MIGRATE_HIGHATOMIC it is no longer necessary to
> > have high-order watermarks. Kswapd and compaction still need high-order
> > awareness which is handled by checking that at least one suitable high-order
> > page is free.
> 
> I still don't think that this one suitable high-order page is enough.
> If fragmentation happens, there would be no order-2 freepage. If kswapd
> prepares only 1 order-2 freepage, one of two successive process forks
> (AFAIK, fork in x86 and ARM require order 2 page) must go to direct reclaim
> to make order-2 freepage. Kswapd cannot make order-2 freepage in that
> short time. It causes latency to many high-order freepage requestor
> in fragmented situation.
> 

So what do you suggest instead? A fixed number, some other heuristic?
You have pushed several times now for the series to focus on the latency
of standard high-order allocations but again I will say that it is outside
the scope of this series. If you want to take steps to reduce the latency
of ordinary high-order allocation requests that can sleep then it should
be a separate series.

> > With the patch applied, there was little difference in the allocation
> > failure rates as the atomic reserves are small relative to the number of
> > allocation attempts. The expected impact is that there will never be an
> > allocation failure report that shows suitable pages on the free lists.
> 
> Due to highatomic pageblock and freepage count mismatch per allocation
> flag, allocation failure with suitable pages can still be possible.
> 

An allocation failure of this type would be a !atomic allocation that
cannot access the reserve. If such allocations requests can access the
reserve then it defeats the whole point of the pageblock type.

> > + * Return true if free base pages are above 'mark'. For high-order checks it
> > + * will return true of the order-0 watermark is reached and there is at least
> > + * one free page of a suitable size. Checking now avoids taking the zone lock
> > + * to check in the allocation paths if no pages are free.
> >   */
> >  static bool __zone_watermark_ok(struct zone *z, unsigned int order,
> >                         unsigned long mark, int classzone_idx, int alloc_flags,
> > @@ -2289,7 +2291,7 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
> >  {
> >         long min = mark;
> >         int o;
> > -       long free_cma = 0;
> > +       const bool atomic = (alloc_flags & ALLOC_HARDER);
> >
> >         /* free_pages may go negative - that's OK */
> >         free_pages -= (1 << order) - 1;
> > @@ -2301,7 +2303,7 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
> >          * If the caller is not atomic then discount the reserves. This will
> >          * over-estimate how the atomic reserve but it avoids a search
> >          */
> > -       if (likely(!(alloc_flags & ALLOC_HARDER)))
> > +       if (likely(!atomic))
> >                 free_pages -= z->nr_reserved_highatomic;
> >         else
> >                 min -= min / 4;
> > @@ -2309,22 +2311,30 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
> >  #ifdef CONFIG_CMA
> >         /* If allocation can't use CMA areas don't use free CMA pages */
> >         if (!(alloc_flags & ALLOC_CMA))
> > -               free_cma = zone_page_state(z, NR_FREE_CMA_PAGES);
> > +               free_pages -= zone_page_state(z, NR_FREE_CMA_PAGES);
> >  #endif
> >
> > -       if (free_pages - free_cma <= min + z->lowmem_reserve[classzone_idx])
> > +       if (free_pages <= min + z->lowmem_reserve[classzone_idx])
> >                 return false;
> > -       for (o = 0; o < order; o++) {
> > -               /* At the next order, this order's pages become unavailable */
> > -               free_pages -= z->free_area[o].nr_free << o;
> >
> > -               /* Require fewer higher order pages to be free */
> > -               min >>= 1;
> > +       /* order-0 watermarks are ok */
> > +       if (!order)
> > +               return true;
> > +
> > +       /* Check at least one high-order page is free */
> > +       for (o = order; o < MAX_ORDER; o++) {
> > +               struct free_area *area = &z->free_area[o];
> > +               int mt;
> > +
> > +               if (atomic && area->nr_free)
> > +                       return true;
> 
> How about checking area->nr_free first?
> In both atomic and !atomic case, nr_free == 0 means
> there is no appropriate pages.
> 
> So,
> if (!area->nr_free)
>     continue;
> if (atomic)
>     return true;
> ...
> 
> 
> > -               if (free_pages <= min)
> > -                       return false;
> > +               for (mt = 0; mt < MIGRATE_PCPTYPES; mt++) {
> > +                       if (!list_empty(&area->free_list[mt]))
> > +                               return true;
> > +               }
> 
> I'm not sure this is really faster than previous.
> We need to check three lists on each order.
> 
> Think about order-2 case. I guess order-2 is usually on movable
> pageblock rather than unmovable pageblock. In this case,
> we need to check three lists so cost is more.
> 

Ok, the extra check makes sense. Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
