Message-ID: <3D2501FA.4B14EB14@zip.com.au>
Date: Thu, 04 Jul 2002 19:18:34 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: vm lock contention reduction
References: <3D24F869.2538BC08@zip.com.au> <Pine.LNX.4.44L.0207042244590.6047-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Andrea Arcangeli <andrea@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> ...
> > > Now we just need to get Arjan to tune the O(1) page launder
> > > thing he was looking at ;)
> >
> > We keep seeing mysterious references to this. What is the idea
> > behind it?
> 
> The idea is that when pages are evicted from the system they
> traverse the inactive list _once_.
> 
> If a page is dirty, IO is started and the page is added to the
> laundry list, if a page is clean it is moved to the clean list.
> 
> Every time we need more free pages we first check the clean list
> (all pages there are freeable, guaranteed) and the first (few?)
> pages of the laundry list. We continue taking pages off of the
> laundry list until we've run into {a, too many} unfreeable pages.
> 
> This way we won't scan the inactive pages over and over again
> every time we free a few.
> 

OK.

One of the changes I made to pagemap_lru_lock was to always
take it with spin_lock_irq().  It's never held for more than
10-20 microseconds, and disabling interrupts while holding it
decreased contention by around 30% with four (slow) CPUs.

So that's a good change regardless, and it lets us move pages
off the laundry list within the IO completion interrupt (but
not one-at-a-time!).

In fact, they don't need to be on any list at all while under
writeback.

Of course, that change means that we wouldn't be able to throttle
page allocators against IO any more, and we'd have to do something
smarter.  What a shame ;)

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
