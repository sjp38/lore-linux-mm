Date: Mon, 17 Jan 2005 07:17:23 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: Q: shrink_cache() vs release_pages() page->lru management
Message-ID: <20050117091723.GB18785@logos.cnet>
References: <41EAA2AD.C7D37D1B@tv-sign.ru> <41EAA59C.B6987930@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <41EAA59C.B6987930@tv-sign.ru>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oleg Nesterov <oleg@tv-sign.ru>, akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Oleg,

On Sun, Jan 16, 2005 at 08:34:20PM +0300, Oleg Nesterov wrote:
> Another attempt, message was truncated...
> 
> shrink_cache:
> 	if (get_page_testone(page)) {
> 		__put_page(page);
> 		SetPageLRU(page);
> 		list_add(&page->lru, &zone->inactive_list);
> 		continue;
> 	}
> 
> Is it really necessary to re-add the page to inactive_list?
> 
> It seems to me that shrink_cache() can just do:
> 
> 	if (get_page_testone(page)) {
> 		__put_page(page);
> 		--zone->nr_inactive;
> 		continue;
> 	}
> 
> When the __page_cache_release (or whatever) takes zone->lru_lock
> it must check PG_lru before del_page_from_lru().
> 
> The same question applies to refill_inactive_zone().

Yes it seems OK to not re-add the page to LRU if "zero" page (-1 count) 
is found, since all callers which set page count to zero (release_pages and 
__page_cache_release()) are going to remove the page from LRU and most likely 
free it anyway. 

The original code is just being safe I guess...

/*
 * This path almost never happens for VM activity - pages are normally
 * freed via pagevecs.  But it gets used by networking.
 */
void fastcall __page_cache_release(struct page *page)
{
        unsigned long flags;
        struct zone *zone = page_zone(page);

        spin_lock_irqsave(&zone->lru_lock, flags);
        if (TestClearPageLRU(page))
                del_page_from_lru(zone, page);
        if (page_count(page) != 0)
                page = NULL;
        spin_unlock_irqrestore(&zone->lru_lock, flags);
        if (page)
                free_hot_page(page);
}

Looking at __page_cache_release() it handles the case where another reference count
is grabbed in the meantime (see the page_count(page) != 0 check).

Now that makes me wonder: in what case page_count(page) != 0 can happen 
during __page_cache_release()? Any user who has a direct pointer to the page 
could do that - pagecache pages have already been removed from the radix 
tree and can't be reached through it at this point in time.

And when that happens, does the reference grabber has to re-add the page to LRU 
since it has just been removed from LRU by __page_cache_release ?  Looks cheesy.

Andrew?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
