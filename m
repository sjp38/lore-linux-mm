Date: Mon, 25 Sep 2000 19:06:57 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
Message-ID: <20000925190657.N2615@redhat.com>
References: <20000924231240.D5571@athlon.random> <Pine.LNX.4.21.0009242310510.8705-100000@elte.hu> <20000924224303.C2615@redhat.com> <20000925001342.I5571@athlon.random> <20000925003650.A20748@home.ds9a.nl> <20000925014137.B6249@athlon.random> <20000925172442.J2615@redhat.com> <20000925190347.E27677@athlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000925190347.E27677@athlon.random>; from andrea@suse.de on Mon, Sep 25, 2000 at 07:03:47PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Sep 25, 2000 at 07:03:47PM +0200, Andrea Arcangeli wrote:
> 
> > This really seems to be the biggest difference between the two
> > approaches right now.  The FreeBSD folks believe fervently that one of
> > [ aging cache and mapped pages in the same cycle ]
> 
> Right.
> 
> And since you move the page into the active list only once you reach it from
> the cache recycler and you find it with page->age != 0, you also spend time
> putting those pages back and forth from those LRU lists while in my approch the
> mapped pages are never seen from the cycle recylcer and no cycle is spent on
> them. This mean in a pure fs read test with cache pollution going on, there's
> _no_way_ that classzone touches or notice _any_ mapped page in its path.

The "age==0" pages are basically just "pages we are ready to get rid
of right away".  The alternative to having that inactive list is to do
what we do today --- which is to throw away the pages immediately.
Having that extra list is simply giving pages a last chance before
evicting them.  It allows us to run reliably with fewer physically
free pages --- we can reap inactive pages with no IO so those pages
are as good as free for most purposes.

The alternative to moving pages to the inactive list would be freeing
them completely.  Moving a page back to the active list from inactive
is equivalent to avoiding a disk IO to pull in the page from backing
store.  It's supposed to be an optimisation to save physically
freeing things unless we really, really need to.  It is _not_ a
transition which recently referenced pages encounter.

> > the main reasons that their VM rocks is that it ages cache pages and
> > mapped pages at the same rate.  Having both on the same aging list
> > achieves that.  Separating the two raises the question of how to
> > balance the aging of cache vs. swap in a fair manner.
> 
> I believe increasing the aging in the unmapped cache should take care of that
> fine. (it was working pretty much fine also with only 1 bit of most
> frequently used aging plus the LRU order of the list)

Good.  One of the problems we always had in the past, though, was that
getting the relative aging of cache vs. vmas was easy if you had a
small set of test loads, but it was really, really hard to find a
balance that didn't show pathological behaviour in the worst cases.

> > > In classzone the aging exists too but it's _completly_ orthogonal to how
> > > rest of the VM works.
> > 
> > Umm, that applies to Rik's stuff too!
> 
> I may be overlooking something but where do you notice when a page
> gets unmapped from the last mapping and put it back into a place
> that can be reached from shrink_mmap (or whatever the cache recycler is)?

It doesn't --- that is part of the design.  The vm scanner propagates
referenced bits to the struct page, so the new shrink_mmap can do its
aging based on whether a page has been referenced at all recently, not
caring whether the reference was a VM reference or a page cache
reference.  That is done specifically to address the balance issue
between VM and filesystem memory pressure.

> Since none mapped page can in any way be freed by the cache recycler
> (you need to unmap it first from swap_out at the moment) if you
> should reach those pages from the cache recyler someway it means
> thus you're wasting CPU (I couldn't reach any mapped page from the
> cache recylcer in classzone and infact the mapped pages wasn't
> linked in any LRU at all to save even more CPU).

That's not how the current VM is supposed to work.  The cache scanner
isn't meant to reclaim pages --- it is meant to update the age
information on pages, which is not quite the same job.  If it finds
pages whose age becomes zero, those are shifted to the inactive list,
and once that list is large enough (ie. we have enough freeable
pages), it can give up.  The inactive list then gets physically freed
on demand.

The fact that we have a common loop in the VM for updating all age
information is central to the design, and requires the cache recycler
to pass over all those pages.  By doing it that way, rather than from
the VM scan, we can avoid one of the really bad properties of the old
2.0 aging code --- it means that for shared pages, we only do the
aging once per walk over the pages regardless of how many ptes refer
to the page.  This avoids the nasty worst-case behaviour of having a
recently-referenced page thrown out of memory just because there also
happened to be a lot of old, unused references to it too. 

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
