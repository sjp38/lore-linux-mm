Date: Wed, 9 Feb 2005 13:05:43 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: [hugh@veritas.com: Re: Q: shrink_cache() vs release_pages() page->lru management]]
Message-ID: <20050209150543.GI14129@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oleg Nesterov <oleg@tv-sign.ru>, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


FYI

----- Forwarded message from Hugh Dickins <hugh@veritas.com> -----

From: Hugh Dickins <hugh@veritas.com>
Date: Wed, 2 Feb 2005 21:56:53 +0000 (GMT)
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
In-Reply-To: <20050202153501.GB19615@logos.cnet>
Subject: Re: [marcelo.tosatti@cyclades.com: Re: Q: shrink_cache() vs

> ----- Forwarded message from Marcelo Tosatti <marcelo.tosatti@cyclades.com> -----
> 
> From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
> Date: Mon, 17 Jan 2005 07:17:23 -0200
> To: Oleg Nesterov <oleg@tv-sign.ru>, akpm@osdl.org
> Cc: linux-mm@kvack.org
> Subject: Re: Q: shrink_cache() vs release_pages() page->lru management
> 
> Hi Oleg,
> 
> On Sun, Jan 16, 2005 at 08:34:20PM +0300, Oleg Nesterov wrote:
> > Another attempt, message was truncated...
> > 
> > shrink_cache:
> > 	if (get_page_testone(page)) {
> > 		__put_page(page);
> > 		SetPageLRU(page);
> > 		list_add(&page->lru, &zone->inactive_list);
> > 		continue;
> > 	}
> > 
> > Is it really necessary to re-add the page to inactive_list?
> > 
> > It seems to me that shrink_cache() can just do:
> > 
> > 	if (get_page_testone(page)) {
> > 		__put_page(page);
> > 		--zone->nr_inactive;
> > 		continue;
> > 	}
> > 
> > When the __page_cache_release (or whatever) takes zone->lru_lock
> > it must check PG_lru before del_page_from_lru().
> > 
> > The same question applies to refill_inactive_zone().
> 
> Yes it seems OK to not re-add the page to LRU if "zero" page (-1 count) 
> is found, since all callers which set page count to zero (release_pages and 
> __page_cache_release()) are going to remove the page from LRU and most likely 
> free it anyway. 

Yes, I agree with both of you that it can equally be done his way.

No huge incentive to change it, and this no-page-count-for-the-LRU
area has given 2.4 and 2.6 trouble and trouble, bugs lurking for years.
I just re-read Andrew's ChangeLog-2.6.7 entry about get_page_testone
(which I always read as "get_page_testosterone"!), and that certainly
wasn't the first bug hereabouts, remember all the PageLRU headaches
in 2.4's __free_pages_ok.

But I don't think it'd be introducing any bug, and it is good
practice to remove unnecessary magic, so I'd back Oleg on this.

Though Andrew might object that this then makes the vmscan.c
side even more dependent on knowing what the swap.c side does.

> The original code is just being safe I guess...

Yes, it think it's based on the principle that the side which brings
page_count down to 0 (-1) should have control, and the other side
which finds this should restore all state before dropping the lock.

But as Oleg observes, it simply isn't state which needs restoring.

I haven't fully thought through the (anyway buggy) pre-2.6.7
situation, but perhaps there was a race perceived there, whereby
the page_count 0 (-1) page could get left behind unfreeable if it
wasn't put back onto the LRU.  Hmm, no, I don't think putting back
on the LRU would solve anything if so.  But it could be a relic of
an even earlier version, where it did play an important part.

> /*
>  * This path almost never happens for VM activity - pages are normally
>  * freed via pagevecs.  But it gets used by networking.
>  */
> void fastcall __page_cache_release(struct page *page)
> {
>         unsigned long flags;
>         struct zone *zone = page_zone(page);
> 
>         spin_lock_irqsave(&zone->lru_lock, flags);
>         if (TestClearPageLRU(page))
>                 del_page_from_lru(zone, page);
>         if (page_count(page) != 0)
>                 page = NULL;
>         spin_unlock_irqrestore(&zone->lru_lock, flags);
>         if (page)
>                 free_hot_page(page);
> }
> 
> Looking at __page_cache_release() it handles the case where another reference count
> is grabbed in the meantime (see the page_count(page) != 0 check).
> 
> Now that makes me wonder: in what case page_count(page) != 0 can happen 
> during __page_cache_release()? Any user who has a direct pointer to the page 
> could do that - pagecache pages have already been removed from the radix 
> tree and can't be reached through it at this point in time.
> 
> And when that happens, does the reference grabber has to re-add the page to LRU 
> since it has just been removed from LRU by __page_cache_release ?  Looks cheesy.

I was looking at the sources and framing my reply before reading this
far down your mail.  And I too was thinking that those two page_count
checks in swap.c ought to be unnecessary now (though needed pre-2.6.7).

Do BUG_ON(page_count(page))?  Shouldn't even need that, would hit the
"Bad page state" message very soon.  Best test for a while under load
before removing those page_count checks, though!

Hugh
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
