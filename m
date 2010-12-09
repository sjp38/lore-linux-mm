Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6F5936B008A
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 21:04:40 -0500 (EST)
Date: Wed, 8 Dec 2010 18:01:56 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm: skip rebalance of hopeless zones
Message-Id: <20101208180156.91dcd122.akpm@linux-foundation.org>
In-Reply-To: <AANLkTik3KBVZBaOxSeO01N1XXobXTOiSAsZcyv0mJraC@mail.gmail.com>
References: <1291821419-11213-1-git-send-email-hannes@cmpxchg.org>
	<20101209003621.GB3796@hostway.ca>
	<20101208172324.d45911f4.akpm@linux-foundation.org>
	<AANLkTik3KBVZBaOxSeO01N1XXobXTOiSAsZcyv0mJraC@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Simon Kirby <sim@hostway.ca>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 9 Dec 2010 10:55:24 +0900 Minchan Kim <minchan.kim@gmail.com> wrote:

> >> > leaves them to direct reclaim.
> >>
> >> Hi!
> >>
> >> We are experiencing a similar issue, though with a 757 MB Normal zone,
> >> where kswapd tries to rebalance Normal after an order-3 allocation while
> >> page cache allocations (order-0) keep splitting it back up again. __It can
> >> run the whole day like this (SSD storage) without sleeping.
> >
> > People at google have told me they've seen the same thing. __A fork is
> > taking 15 minutes when someone else is doing a dd, because the fork
> > enters direct-reclaim trying for an order-one page. __It successfully
> > frees some order-one pages but before it gets back to allocate one, dd
> > has gone and stolen them, or split them apart.
> >
> > This problem would have got worse when slub came along doing its stupid
> > unnecessary high-order allocations.
> >
> > Billions of years ago a direct-reclaimer had a one-deep cache in the
> > task_struct into which it freed the page to prevent it from getting
> > stolen.
> >
> > Later, we took that out because pages were being freed into the
> > per-cpu-pages magazine, which is effectively task-local anyway. __But
> > per-cpu-pages are only for order-0 pages. __See slub stupidity, above.
> >
> > I expect that this is happening so repeatably because the
> > direct-reclaimer is dong a sleep somewhere after freeing the pages it
> > needs - if it wasn't doing that then surely the window wouldn't be wide
> > enough for it to happen so often. __But I didn't look.
> >
> > Suitable fixes might be
> >
> > a) don't go to sleep after the successful direct-reclaim.
> 
> It can't make sure success since direct reclaim needs sleep with !GFP_AOMIC.

It doesn't necessarily need to sleep *after* successfully freeing
pages.  If it needs to sleep then do it before or during the freeing.

> >
> > b) reinstate the one-deep task-local free page cache.
> 
> I like b) so how about this?
> Just for the concept.
> 
> @@ -1880,7 +1881,7 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask,
> unsigned int order,
>         reclaim_state.reclaimed_slab = 0;
>         p->reclaim_state = &reclaim_state;
> 
> -       *did_some_progress = try_to_free_pages(zonelist, order,
> gfp_mask, nodemask);
> +       *did_some_progress = try_to_free_pages(zonelist, order,
> gfp_mask, nodemask, &ret_pages);
> 
>         p->reclaim_state = NULL;
>         lockdep_clear_current_reclaim_state();
> @@ -1892,10 +1893,11 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask,
> unsigned int order,
>                 return NULL;
> 
>  retry:
> -       page = get_page_from_freelist(gfp_mask, nodemask, order,
> -                                       zonelist, high_zoneidx,
> -                                       alloc_flags, preferred_zone,
> -                                       migratetype);
> +       if(!list_empty(&ret_pages)) {
> +               page = lru_to_page(ret_pages);
> +               list_del(&page->lru);
> +               free_page_list(&ret_pages);
> +       }

Maybe.  Or just pass a page*.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
