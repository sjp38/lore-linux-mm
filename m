Date: Sat, 22 Apr 2000 15:29:08 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: [patch] take 2 Re: PG_swap_entry bug in recent kernels
In-Reply-To: <Pine.LNX.4.10.10004211845340.821-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0004221520310.16974-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, Ben LaHaise <bcrl@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 21 Apr 2000, Linus Torvalds wrote:
> On Sat, 22 Apr 2000, Andrea Arcangeli wrote:
> > On Fri, 21 Apr 2000, Rik van Riel wrote:
> > 
> > >you could use the PageClearSwapCache and related macros for
> > >changing the bitflags.
> > 
> > BTW, thinking more I think the clearbit in shrink_mmap should really be
> > atomic (lookup_swap_cache can run from under it and try to lock the page
> > playing with the page->flags while we're clearing the swap_entry bitflag).
> 
> Actually, I was toying with the much simpler rule:
>  - "PG_locked" is always atomic
>  - all other flags can only be tested/changed if PG_locked holds
> 
> This simple rule would allow for not using the (slow) atomic operations,
> because the other bits are always protected by the one-bit lock.

It all depends on the source code. If we're holding the page
lock anyway in places where we play with the other flags, that's
probably the best strategy, but if we're updating the page flags
in a lot of places without holding the page lock, then it's
probably better to just do everything with the current atomic
bitops.

Btw, here's a result from 2.3.99-pre6-3 ... line number 3 and
4 are extremely suspect...

[riel@duckman mm]$ grep 'page->flags' *.c
filemap.c:              if (test_and_clear_bit(PG_referenced, &page->flags)) 
filemap.c:      set_bit(PG_referenced, &page->flags);
filemap.c:      flags = page->flags & ~((1 << PG_uptodate) | (1 << PG_error) | (1 << PG_dirty));
filemap.c:      page->flags = flags | (1 << PG_locked) | (1 << PG_referenced);
page_io.c:              set_bit(PG_decr_after, &page->flags);
vmscan.c:               set_bit(PG_referenced, &page->flags);


Here's the suspect piece of code (filemap.c::__add_to_page_cache()):

        flags = page->flags & ~((1 << PG_uptodate) | (1 << PG_error) | (1 << PG_dirty));
        page->flags = flags | (1 << PG_locked) | (1 << PG_referenced);
        get_page(page);

So here we play with a number of page flags _before_ taking
the page or locking it. It's probably safe because of some
circumstances under which we are called, but somehow it
just doesn't look clean to me ;)

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
