Message-ID: <3B668629.34797B3F@zip.com.au>
Date: Tue, 31 Jul 2001 20:19:21 +1000
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: strange locking __find_get_swapcache_page()
References: <Pine.LNX.4.33L.0107301542230.5582-100000@duckman.distro.conectiva> <Pine.LNX.4.33.0107301839440.19638-100000@penguin.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> On Mon, 30 Jul 2001, Rik van Riel wrote:
> >
> > I've encountered a suspicious piece of code in filemap.c:
> >
> > struct page * __find_get_swapcache_page( ... )
> 
> Hmm. I thin the whole PageSwapCache() test is bogus - if we found it on
> the swapper_space address space, then the page had better be a swap-cache
> page, and testing for it explicitly is silly.
> 
> Also, it appears that the only caller of this is
> find_get_swapcache_page(), which in itself really doesn't even care: it
> just uses the lookup as a boolen on whether to add a new page to the swap
> cache, and does even _that_ completely wrong. There's a big race there,
> see if you can spot it.

read_swap_cache_async()?  All code paths in that area are
under lock_kernel().

> The fix, I suspect, is to pretty much get rid of the code altogether, and
> make it use add_to_page_cache_unique() or whatever it is called that gets
> the duplicate check _right_.

The whole lot needed spring cleaning 1-2 years ago, but I see no
bugs in there.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
