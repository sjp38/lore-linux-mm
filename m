Date: Mon, 25 Sep 2000 17:24:42 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
Message-ID: <20000925172442.J2615@redhat.com>
References: <20000924231240.D5571@athlon.random> <Pine.LNX.4.21.0009242310510.8705-100000@elte.hu> <20000924224303.C2615@redhat.com> <20000925001342.I5571@athlon.random> <20000925003650.A20748@home.ds9a.nl> <20000925014137.B6249@athlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000925014137.B6249@athlon.random>; from andrea@suse.de on Mon, Sep 25, 2000 at 01:41:37AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Sep 25, 2000 at 01:41:37AM +0200, Andrea Arcangeli wrote:
> 
> Since you're talking about this I'll soon (as soon as I'll finish some other
> thing that is just work in progress) release a classzone against latest's
> 2.4.x. My approch is _quite_ different from the curren VM. Current approch is
> very imperfect and it's based solely on aging whereas classzone had hooks into
> pagefaults paths and all other map/unmap points to have perfect accounting of
> the amount of active/inactive stuff.

Andrea, I'm not quite sure what you're saying here.  Could you be a
bit more specific?

The current VM _does_ track the amount of active/inactive stuff.  It
does so by keeping separate list of active and inactive stuff.
Accounting on memory pressure on these different lists is used to
generate dynamic targets for how many pages we aim to have on those
lists, so aging/reclaim activity is tuned to the current memory load.

Your other recent complaint, that newly-swapped pages end up on the
wrong end of the LRU lists and can't be reclaimed without cycling the
rest of the pages in shrink_mmap, is also cured in Rik's code, by
placing pages which are queued for swapout on a different list
altogether.  I thought we had managed to agree in Ottawa that such a
cure for the old 2.4 VM was desirable.

> The mapped pages was never seen by
> anything except swap_out, if they was mapped (it's not a if page->age then move
> into the active list, with classzone the page was _just_ in the active list in
> first place since it was mapped).

This really seems to be the biggest difference between the two
approaches right now.  The FreeBSD folks believe fervently that one of
the main reasons that their VM rocks is that it ages cache pages and
mapped pages at the same rate.  Having both on the same aging list
achieves that.  Separating the two raises the question of how to
balance the aging of cache vs. swap in a fair manner.

> In classzone the aging exists too but it's _completly_ orthogonal to how rest
> of the VM works.

Umm, that applies to Rik's stuff too!

> This is my humble opinion at least. I may be wrong. I'll let you know
> once I'll have a patch I'll happy with and some real life number to proof my
> theory.

Good, the best theoretical VM in the world can fall apart instantly on
contact with the real world. :-)

Cheers, 
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
