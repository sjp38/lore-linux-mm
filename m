Message-ID: <39D3F272.BC026A47@sgi.com>
Date: Thu, 28 Sep 2000 18:37:54 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: Re: lru_cache_add() -> deactivate_page_nolock()?
References: <8r0dot$13eak9$1@fido.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@conectiva.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[ Bad form: replying to my own post, etc. ... ]

Rajagopal Ananthanarayanan wrote:
> 
> Few questions on aging & deactivation:
> 
> Suppose a page has to be freshly allocated
> (no cache hit) in __grab_cache_page() in generic_file_write().
> What is the age of the page at the time of its lru_cache_add?
> Won't the age be zero?

Two cases here, depending on what happened in __alloc_pages():

1. page->age will be PAGE_AGE_START if page was previously
   freed (__free_pages_ok() sets the age)

2. page->age will be zero if page was obtained through
   a reclaim_page().

I can't believe this was a design choice. Simply
code like this is missing at the bottom of reclaim_page():

---------
struct page * reclaim_page(zone_t * zone)
{
	[ ... ]
	if (page)
		page->age = PAGE_START_AGE;
	return page;
}
----------

This will avoid nasty deactivation immediately on
entering the page into the cache.

... btw, I have tried the above fix, and it does
improve dbench performance in cases where few
clients (1-2) are used on my 64MB system.

Rik, what do you think?

		


> If so, won't it be the case that deactive_page_nolock() will be
> called _every_ time such a page is lru_cache_add'ed,
> and that this call will be the one from here:
> 
> --------
> void lru_cache_add(struct page * page)
> {
>         [ ... ]
>         /* This should be relatively rare */
>         if (!page->age)
>                 deactivate_page_nolock(page);
>         [ ... ]
> }
> ----------
> 
> If so, I fail to understand the motivation behind
> the "relatively rare" comment ...
> 
> --------------------------------------------------------------------------
> Rajagopal Ananthanarayanan ("ananth")
> Member Technical Staff, SGI.
> --------------------------------------------------------------------------
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/

-- 
--------------------------------------------------------------------------
Rajagopal Ananthanarayanan ("ananth")
Member Technical Staff, SGI.
--------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
