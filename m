Date: Mon, 25 Sep 2000 21:32:42 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
Message-ID: <20000925213242.A30832@athlon.random>
References: <20000924231240.D5571@athlon.random> <Pine.LNX.4.21.0009242310510.8705-100000@elte.hu> <20000924224303.C2615@redhat.com> <20000925001342.I5571@athlon.random> <20000925003650.A20748@home.ds9a.nl> <20000925014137.B6249@athlon.random> <20000925172442.J2615@redhat.com> <20000925190347.E27677@athlon.random> <20000925190657.N2615@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000925190657.N2615@redhat.com>; from sct@redhat.com on Mon, Sep 25, 2000 at 07:06:57PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 07:06:57PM +0100, Stephen C. Tweedie wrote:
> Good.  One of the problems we always had in the past, though, was that
> getting the relative aging of cache vs. vmas was easy if you had a
> small set of test loads, but it was really, really hard to find a
> balance that didn't show pathological behaviour in the worst cases.

Yep, that's not trivial.

> > I may be overlooking something but where do you notice when a page
> > gets unmapped from the last mapping and put it back into a place
> > that can be reached from shrink_mmap (or whatever the cache recycler is)?
> 
> It doesn't --- that is part of the design.  The vm scanner propagates

And that's the inferior part of the design IMHO.

> referenced bits to the struct page, so the new shrink_mmap can do its
> aging based on whether a page has been referenced at all recently, not

shrink_mmap could can care less about pages that it can't do anything
with them. When it notice it can't do anything it kicks in swap_out.

Having shrink_mmap that browse the mapped page cache is useless
as having shrink_mmap browsing kernel memory and anonymous pages
as it does in 2.2.x as far I can tell. It's an algorithm
complexity problem and it will waste lots of CPU.

Now think this simple real life example. A 2G RAM machine running an executable
image of 1.5G, 300M in shm and 200M in cache.

No memory pressure, no need to swap anything anytime.

Now the application starts to read heavily from disk some giga of data.

Why should shrink_mmap waste an huge amount of time rolling back
and forth from the LRUs the 384000 mapped pages? There's no memory pressure
there's no need to check those mapped pages at all.

Classzone will make an huge difference in numbers in this scenario since
it will only work on the 300M of cache (it will never see the 1.5G of
mapped .text).

> caring whether the reference was a VM reference or a page cache
> reference.  That is done specifically to address the balance issue
> between VM and filesystem memory pressure.

I think it's not necessary to pay all that huge overhead to only learn
when it's time to kick swap_out in. When we're short in unmapped cache
we can just startup swap_out. That apparently works.

> That's not how the current VM is supposed to work.  The cache scanner
> isn't meant to reclaim pages --- it is meant to update the age
> information on pages, which is not quite the same job.  If it finds

So it will be the cache scanner (not the recycler) that will waste the CPU
cycles.

> pages whose age becomes zero, those are shifted to the inactive list,
> and once that list is large enough (ie. we have enough freeable
> pages), it can give up.  The inactive list then gets physically freed
> on demand.

So in a long cache-polluting read from disk the inactive list will return empty
all the time and so cache scanner will have to waste the CPU as described.

> The fact that we have a common loop in the VM for updating all age
> information is central to the design, and requires the cache recycler
> to pass over all those pages.  By doing it that way, rather than from

That's a waste IMHO. We don't need to pass over the mapped pages.

> 2.0 aging code --- it means that for shared pages, we only do the
> aging once per walk over the pages regardless of how many ptes refer
> to the page.  This avoids the nasty worst-case behaviour of having a

You'll still refresh the referenced bit too often for those pages because
they're referenced multiple times so it will still be unfair. Said that it's
probably not that bad property since a very shared library is more justified to
live in cache than a page that is mapped only once.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
