Date: Fri, 27 Aug 2004 17:28:11 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: refill_inactive_zone question
Message-ID: <20040827202811.GB4251@logos.cnet>
References: <20040827190714.GB3332@logos.cnet> <Pine.LNX.4.44.0408272213410.2144-100000@localhost.localdomain> <20040827201641.GD3332@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040827201641.GD3332@logos.cnet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 27, 2004 at 05:16:41PM -0300, Marcelo Tosatti wrote:
> On Fri, Aug 27, 2004 at 10:17:35PM +0100, Hugh Dickins wrote:
> > On Fri, 27 Aug 2004, Marcelo Tosatti wrote:
> > > 
> > > Is it possible to have AnonPages without a mapping to them? I dont think so.
> > 
> > It was impossible, but my "remove page_map_lock" patches had to change that.
> > 
> > > Can't the check "if (total_swap_pages == 0 && PageAnon(page))" be moved
> > > inside "if (page_mapped(page))" ? 
> > 
> > Yes: it's like that in -mm, and I believe now in Linus' bk tree too.
> > 
> > Hugh
> 
> Hi Hugh, 
> 
> Oh thanks! I see that. So you just dropped the bit spinlocked and changed
> mapcount to an atomic variable, right?  Cool. Do you have any numbers on 
> big SMP systems for that change? 
> 
> Talking about refill_inactive_zone(), the next stage of the algorithm:
> 
>         while (!list_empty(&l_active)) {
>                 page = lru_to_page(&l_active);
>                 prefetchw_prev_lru_page(page, &l_active, flags);
>                 if (TestSetPageLRU(page))
>                         BUG();
>                 BUG_ON(!PageActive(page));
>                 list_move(&page->lru, &zone->active_list);
>                 pgmoved++;
>                 if (!pagevec_add(&pvec, page)) {
>                         zone->nr_active += pgmoved;
>                         pgmoved = 0;
>                         spin_unlock_irq(&zone->lru_lock);
>                         __pagevec_release(&pvec);
>                         spin_lock_irq(&zone->lru_lock);
>                 }
>         }
> 
> Several things:
> 
> 1) __pagevec_release does lru_add_drain(), which moves pages in the deferred lru 
> queues (active & inactive) to the actual lists. But at that point in refill_inactive()
> thats not a direct benefit (we already moved scanned the inactive list at the beginning
> of the algo). So, we could remove that lru_add_drain from refill_inactive_zone->__pagevec_release.
> 
> The bad part of doing unecessary lru_add_drain's is that we minimize the chance from 
> the queue growing big. And the queues growing big means we batch the list moving, better
> cache locality. 
> 
> Is there any good reason for doing that lru_add_drain from the refill_inactive_zone()
> callchain?
> 
> 
> 2) before calling __pagevec_release we drop the zone lock, to lock it again at 
> __pagevec_release->release_pages. Acquiring locks is usually more expensive 
> then it seems (thanks Paul McKenney!), release_pages handles pagevec's containing pages
>  from different zones, but we know all pages on this pagevec are on the same zone.
> Couldnt it all be under the zone lock?
> 
> 3) What happens if that __pagevec_release frees one or more pages page (and deletes it/them 
> from the LRU list)?  We will still count those pages in "pgmoved" which will then be 
> accounted in zone->nr_active. Whoops.

Note: All of this is also valid for the next step on the algorithm which handles the l_inactive list.

> Hope I'm full of shit. 

!!
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
