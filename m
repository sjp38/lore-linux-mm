Date: Mon, 25 Sep 2000 19:03:47 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
Message-ID: <20000925190347.E27677@athlon.random>
References: <20000924231240.D5571@athlon.random> <Pine.LNX.4.21.0009242310510.8705-100000@elte.hu> <20000924224303.C2615@redhat.com> <20000925001342.I5571@athlon.random> <20000925003650.A20748@home.ds9a.nl> <20000925014137.B6249@athlon.random> <20000925172442.J2615@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000925172442.J2615@redhat.com>; from sct@redhat.com on Mon, Sep 25, 2000 at 05:24:42PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 05:24:42PM +0100, Stephen C. Tweedie wrote:
> Your other recent complaint, that newly-swapped pages end up on the
> wrong end of the LRU lists and can't be reclaimed without cycling the
> rest of the pages in shrink_mmap, is also cured in Rik's code, by
> placing pages which are queued for swapout on a different list
> altogether.  I thought we had managed to agree in Ottawa that such a
> cure for the old 2.4 VM was desirable.

Yes, I seen and the fix looks ok. It's the deactivate_page call when
we swapout the anonymous page. I overlooked it at first, I apologise.

> > The mapped pages was never seen by anything except swap_out, if they was
> > mapped (it's not a if page->age then move into the active list, with
> > classzone the page was _just_ in the active list in first place since it
> > was mapped).
> 
> This really seems to be the biggest difference between the two
> approaches right now.  The FreeBSD folks believe fervently that one of

Right.

And since you move the page into the active list only once you reach it from
the cache recycler and you find it with page->age != 0, you also spend time
putting those pages back and forth from those LRU lists while in my approch the
mapped pages are never seen from the cycle recylcer and no cycle is spent on
them. This mean in a pure fs read test with cache pollution going on, there's
_no_way_ that classzone touches or notice _any_ mapped page in its path.

I think you can't be faster than classzone here.

When the cache isn't polluted adding some more bit of aging I'll better know
when it's time to unmap/swapout stuff. (it just works this way but with only
literally 1 bit of aging at the moment)

> the main reasons that their VM rocks is that it ages cache pages and
> mapped pages at the same rate.  Having both on the same aging list
> achieves that.  Separating the two raises the question of how to
> balance the aging of cache vs. swap in a fair manner.

I believe increasing the aging in the unmapped cache should take care of that
fine. (it was working pretty much fine also with only 1 bit of most
frequently used aging plus the LRU order of the list)

> > In classzone the aging exists too but it's _completly_ orthogonal to how
> > rest of the VM works.
> 
> Umm, that applies to Rik's stuff too!

I may be overlooking something but where do you notice when a page
gets unmapped from the last mapping and put it back into a place
that can be reached from shrink_mmap (or whatever the cache recycler is)?

Since none mapped page can in any way be freed by the cache recycler
(you need to unmap it first from swap_out at the moment) if you
should reach those pages from the cache recyler someway it means
thus you're wasting CPU (I couldn't reach any mapped page from the
cache recylcer in classzone and infact the mapped pages wasn't
linked in any LRU at all to save even more CPU).

> Good, the best theoretical VM in the world can fall apart instantly on
> contact with the real world. :-)

:))

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
