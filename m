Date: Wed, 18 Jul 2001 16:51:10 +0200 (CEST)
From: Mike Galbraith <mikeg@wen-online.de>
Subject: Re: [PATCH] Separate global/perzone inactive/free shortage
In-Reply-To: <20010718111818.D6826@redhat.com>
Message-ID: <Pine.LNX.4.33.0107181454270.1484-100000@mikeg.weiden.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Bulent Abali <abali@us.ibm.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, Rik van Riel <riel@conectiva.com.br>, Dirk Wetter <dirkw@rentec.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 18 Jul 2001, Stephen C. Tweedie wrote:

> Hi,

Greetings,

> On Wed, Jul 18, 2001 at 10:54:52AM +0200, Mike Galbraith wrote:
>
> > Much worse is the case of Dirk's two 2gig simulations on a dual cpu
> > 4gig box.  It will guaranteed allocate all of the dma zone to his two
> > tasks vm.  It will also guaranteed unbalance the zone.  Doesn't that
> > also guarantee that we will walk pagetables endlessly each and every
> > time a ZONE_DMA page is issued?  Try to write out a swapcache page,
> > and you might get a dma page, try to do _anything_ and you might get
> > a ZONE_DMA page.  With per zone balancing, you will turn these pages
> > over much much faster than before, and the aging will be unfair in
> > the extreme.. it absolutely has to be.  SCT's suggestion would make
> > the total pressure equal, but it would not (could not) correct the
> > problem of searching for this handful of pages, the very serious cost
> > of owning a ZONE_DMA page, nor the problem of a specific request for
> > GFP_DMA pages having a reasonable chance of succeeding.
>
> The round-robin scheme would result in 16MB worth of allocations ever
> 2GB of requests coming from ZONE_DMA.  That's one in 128.
>
> But the impact of this on memory pressure depends on how we distribute
> PAGES_HIGH/PAGES_LOW allocation requests, and at what point we wake up
> the reclaim code.  If we have 50 pages between PAGES_HIGH and
> PAGES_LOW for DMA zone, and the reclaim target is PAGES_HIGH, then we
> won't start the reclaim until (50*128) allocations have been done
> since the last one --- that's 25MB of allocations.  Plus, the reclaim
> that does kick off won't be scanning the VM for just one DMA page, it
> will keep scanning for a bunch of them, so it's just one VM pass for
> that whole 25MB of allocation.  At the very least, this helps spread
> the load.

Yes it would.  It would also distribute those pages much wider (+-?).

With 4gig of simulation running/swappimg though, 25MB of allocation
could come around very quickly.  I don't know exactly how expensive it
is to search that much space, but it's definitely cheaper to not have
to bother most of the time.  In the simulation case, that would be all
of the time.

If fallback allocations couldn't get at enough to trigger a zone specific
inactive/free shortage, normal global aging/laundering could handle it
exactly as before for free.  If some DMA pages get picked up (demand is
generally being serviced well enough or we'd see more gripes) cool, if
not, it's no big deal until a zone specific demand comes along.  Instead
of eating the cost repeatedly just to make the bean counter happy, it'd
be defered until genuine demand for these specific beans hit.

> But on top of that, we need to make a distinction between directed
> reclaim and opportunistic reclaim.  What I mean by that is this: we
> need not force the memory reclaim logic to try to balance the DMA
> zone unnecessarily; hence we should not force it to scavenge in DMA if
> the (free+inactive) count is above pages_low.  However, we *should*
> still age DMA pages if we happen to be triggering the aging loop
> anyway.  If pressure on the NORMAL zone triggers aging, then sure, we
> can top up the DMA zone.  So, for page aging, if the memory pressure
> is balanced, the aging should not have to do a specific pass over the
> DMA zone at all --- the aging done in response to pressure elsewhere
> ought to have a proportionate impact on the DMA zone's inactive queue
> too.

Ah yes.  That could reduce the cost a lot.  But not as much as ignoring
it until real demand happens.  In both cases, when that happens, a full
blown effort is needed.  I'm not hung up on my workaround suggestion by
any means though.. if there's a cleaner way to deal with the problems,
I'm all for it.

The really nasty problem that my suggestion helps with is DMA pages going
down an invisible rathole.  If that happens, the cost is high indeed because
the invested effort can fail to produce any result.. possibly forever.

> > IMHO, it is really really bad, that any fallback allocation can also
> > bring the dma zone into critical, and these allocations may end up in
> > kernel structures which are invisible to the balancing logic
>
> That is the crux of the problem.  ext3's journaling, XFS with deferred

Fully agree with that.  (don't have a clue what an rmap even is, so I'll
just shut up and listen now:)

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
