Date: Tue, 26 Sep 2000 00:44:29 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
Message-ID: <20000926004429.D5010@athlon.random>
References: <Pine.LNX.4.21.0009242310510.8705-100000@elte.hu> <20000924224303.C2615@redhat.com> <20000925001342.I5571@athlon.random> <20000925003650.A20748@home.ds9a.nl> <20000925014137.B6249@athlon.random> <20000925172442.J2615@redhat.com> <20000925190347.E27677@athlon.random> <20000925190657.N2615@redhat.com> <20000925213242.A30832@athlon.random> <20000925205457.Y2615@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000925205457.Y2615@redhat.com>; from sct@redhat.com on Mon, Sep 25, 2000 at 08:54:57PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 08:54:57PM +0100, Stephen C. Tweedie wrote:
> OK, and here's another simple real life example.  A 2GB RAM machine
> running something like Oracle with a hundred client processes all
> shm-mapping the same shared memory segment.

Oracle takes the SHM locked, and it will never run on a machine without
enough memory.

> Oh, and you're also doing lots of file IO.  How on earth do you decide
> what to swap and what to page out in this sort of scenario, where
> basically the whole of memory is data cache, some of which is mapped
> and some of which is not?

As as said in the last email aging on the cache is supposed to that.

Wasting CPU and incrasing the complexity of the algorithm is a price
that I won't pay just to get the information on when it's time
to recall swap_out().

If the cache have no age it means I'd better throw it out instead
of swapping/unmapping out stuff, simple?

> anything since last time.  Anything that only ages per-pte, not
> per-page, is simply going to die horribly under such load, and any

The aging on the fs cache is done per-page.

The per-pte issue happens when we just took the difficult decision (that it was
time to swap-out) and you have the same problem because you don't know the
chain of pte that point to the physical page (so you're refresh the referenced
bit more often). Once we'll have the chain of pte pointing to the page
classzone will only need a real lru for the mapped pages to use it instead of
walking pagetables.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
