Date: Mon, 23 Apr 2001 10:10:27 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] swap-speedup-2.4.3-A1, massive swapping speedup
In-Reply-To: <l03130301b70a0e4c4676@[192.168.239.105]>
Message-ID: <Pine.LNX.4.21.0104231003480.13206-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Morton <chromi@cyberspace.org>
Cc: Rik van Riel <riel@conectiva.com.br>, Ingo Molnar <mingo@elte.hu>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Marcelo Tosatti <marcelo@conectiva.com.br>, Szabolcs Szakacsits <szaka@f-secure.com>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Apr 2001, Jonathan Morton wrote:
> >There seems to be one more reason, take a look at the function
> >read_swap_cache_async() in swap_state.c, around line 240:
> >
> >        /*
> >         * Add it to the swap cache and read its contents.
> >         */
> >        lock_page(new_page);
> >        add_to_swap_cache(new_page, entry);
> >        rw_swap_page(READ, new_page, wait);
> >        return new_page;
> >
> >Here we add an "empty" page to the swap cache and use the
> >page lock to protect people from reading this non-up-to-date
> >page.
> 
> How about reversing the order of the calls - ie. add the page to the cache
> only when it's been filled?  That would fix the race.

No. The page cache is used as the IO synchronization point, both for
swapping and for regular IO. You have to add the page in _first_, because
otherwise you may end up doing multiple IO's from different pages.

The proper fix is to do the equivalent of this on all the lookup paths
that want a valid page:

	if (!PageUptodate(page)) {
		lock_page(page);
		if (PageUptodate(page)) {
			unlock_page(page);
			return 0;
		}
		rw_swap_page(page, 0);
		wait_on_page(page);
		if (!PageUptodate(page))
			return -EIO;
	}
	return 0;

This is the whole point of the "uptodate" flag, and for all I know we may
already do all of this (it's certainly the normal setup).

Note how we do NOT block on write-backs in the above: the page will be
up-to-date from the bery beginning (it had _better_ be, it's hard to write
back a swap page that isn't up-to-date ;).

The above is how all the file paths work. 

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
