Date: Fri, 21 Apr 2000 18:51:01 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] take 2 Re: PG_swap_entry bug in recent kernels
In-Reply-To: <Pine.LNX.4.21.0004220306410.584-100000@alpha.random>
Message-ID: <Pine.LNX.4.10.10004211845340.821-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: riel@nl.linux.org, Kanoj Sarcar <kanoj@google.engr.sgi.com>, Ben LaHaise <bcrl@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Sat, 22 Apr 2000, Andrea Arcangeli wrote:
>
> On Fri, 21 Apr 2000, Rik van Riel wrote:
> 
> >you could use the PageClearSwapCache and related macros for
> >changing the bitflags.
> 
> BTW, thinking more I think the clearbit in shrink_mmap should really be
> atomic (lookup_swap_cache can run from under it and try to lock the page
> playing with the page->flags while we're clearing the swap_entry bitflag).

Actually, I was toying with the much simpler rule:
 - "PG_locked" is always atomic
 - all other flags can only be tested/changed if PG_locked holds

This simple rule would allow for not using the (slow) atomic operations,
because the other bits are always protected by the one-bit lock.

PG_accessed is probably a special case, as it's just a hint bit - so it
might be ok to say something like "you can change PG_accessed without
holding the PG_locked bit, but then you have to use an atomic operation".
That way changes to PG_accessed might be lost (by other non-atomic
updaters that hold the PG_lock), but at least changing PG_accessed without
holding PG_lock cannot cause other bits to become lost.

Does the above sound sane? It might be reasonably easy to verify that the
rule holds (ie make all the macros check that PG_locked is set, and
hand-check the few places where we access page->flags directly). The rules
sound safe to me, and means that most of the updates could be non-atomic.
Comments?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
