Date: Mon, 30 Jul 2001 18:44:01 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: strange locking __find_get_swapcache_page()
In-Reply-To: <Pine.LNX.4.33L.0107301542230.5582-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.33.0107301839440.19638-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, Andrea Arcangeli <andrea@suse.de>, Andrew Morton <andrewm@uow.edu.au>, Marcelo Tosatti <marcelo@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

On Mon, 30 Jul 2001, Rik van Riel wrote:
>
> I've encountered a suspicious piece of code in filemap.c:
>
> struct page * __find_get_swapcache_page( ... )

Hmm. I thin the whole PageSwapCache() test is bogus - if we found it on
the swapper_space address space, then the page had better be a swap-cache
page, and testing for it explicitly is silly.

Also, it appears that the only caller of this is
find_get_swapcache_page(), which in itself really doesn't even care: it
just uses the lookup as a boolen on whether to add a new page to the swap
cache, and does even _that_ completely wrong. There's a big race there,
see if you can spot it.

The fix, I suspect, is to pretty much get rid of the code altogether, and
make it use add_to_page_cache_unique() or whatever it is called that gets
the duplicate check _right_.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
