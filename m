Date: Wed, 18 Jul 2001 10:54:52 +0200 (CEST)
From: Mike Galbraith <mikeg@wen-online.de>
Subject: Re: [PATCH] Separate global/perzone inactive/free shortage
In-Reply-To: <OF11D0664E.20E72543-ON85256A8B.004B248D@pok.ibm.com>
Message-ID: <Pine.LNX.4.33.0107180808470.724-100000@mikeg.weiden.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bulent Abali <abali@us.ibm.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, Rik van Riel <riel@conectiva.com.br>, Dirk Wetter <dirkw@rentec.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 16 Jul 2001, Bulent Abali wrote:

> >> On Sat, 14 Jul 2001, Marcelo Tosatti wrote:
> >
> >> On highmem machines, wouldn't it save a LOT of time to prevent
> allocation
> >> of ZONE_DMA as VM pages?  Or, if we really need to, get those pages into
> >> the swapcache instantly?  Crawling through nearly 4 gig of VM looking
> for
> >> 16 MB of ram has got to be very expensive.  Besides, those pages are
> just
> >> too precious to allow some user task to sit on them.
> >
> >Can't we balance that automatically?
> >
> >Why not just round-robin between the eligible zones when allocating,
> >biasing each zone based on size?  On a 4GB box you'd basically end up
> >doing 3 times as many allocations from the highmem zone as the normal
> >zone and only very occasionally would you try to dig into the dma
> >zone.
> >Cheers,
> > Stephen
>
> If I understood page_alloc.c:build_zonelists() correctly
> ZONE_HIGHMEM includes ZONE_NORMAL which includes ZONE_DMA.
> Memory allocators (other than ZONE_DMA) will dip in to the dma zone
> only when there are no highmem and/or normal zone pages available.
> So, the current method is more conservative (better) than round-robin
> it seems to me.

Not really.  As soon as ZONE_NORMAL is engaged such that free_pages
hits pages_low, we will pilpher ZONE_DMA.  That's guaranteed to happen
because that's exactly what we balance for.  Once ZONE_NORMAL reaches
pages_low, we will fall back to allocating ZONE_DMA exclusively.

(problem yes?.. if agree, skip to 'possible solution' below;)

Thinking about doing a find /usr on my box:  we commit ZONE_NORMAL,
then transition to exclusive use of ZONE_DMA instantly.  These pages
will go to kernel structures.  (except for metadata.  Metadata will
be aged/laundered, and become available for more kernel structures)
The tendancy is for ever increasing quantities to become invisible
to the balancing mechanisms.

Thinking about Dirk's logs of rsync leads me to believe that this must
be the case.  kreclaimd is eating cpu.  It can't possibly be any other
zone.  When rsync has had 30 minutes of cpu, kswapd has had 40 minutes.
kreclaimd has eaten 15 solid minutes.  It can't possibly accumulate
that much time unless ZONE_DMA is the problem.. the other zones are
just too easy to find/launder/reclaim.

Much worse is the case of Dirk's two 2gig simulations on a dual cpu
4gig box.  It will guaranteed allocate all of the dma zone to his two
tasks vm.  It will also guaranteed unbalance the zone.  Doesn't that
also guarantee that we will walk pagetables endlessly each and every
time a ZONE_DMA page is issued?  Try to write out a swapcache page,
and you might get a dma page, try to do _anything_ and you might get
a ZONE_DMA page.  With per zone balancing, you will turn these pages
over much much faster than before, and the aging will be unfair in
the extreme.. it absolutely has to be.  SCT's suggestion would make
the total pressure equal, but it would not (could not) correct the
problem of searching for this handful of pages, the very serious cost
of owning a ZONE_DMA page, nor the problem of a specific request for
GFP_DMA pages having a reasonable chance of succeeding.

IMHO, it is really really bad, that any fallback allocation can also
bring the dma zone into critical, and these allocations may end up in
kernel structures which are invisible to the balancing logic, making
a search a complete waste of time.  In any case, on a machine with
lots of ram, the search is going to be disproportionately expensive
due to the size of the search area.

Possible solution:

Effectively reserving the last ~meg (pick a number, scaled by ramsize
would be better) of ZONE_DMA for real GFP_DMA allocations would cure
Dirk's problem I bet, and also cure most of the others too, simply by
ensuring that the ONLY thing that could unbalance that zone would be
real GFP_DMA pressure.  That way, you'd only eat the incredible cost
of balancing that zone when it really really had to be done.

> I think Marcello is proposing to make ZONE_DMA exclusive in large
> memory machines, which might make it better for allocators
> needing ZONE_DMA pages...

That would have to save very much time on HIGHMEM boxes.  No box with
>= a gig of ram would even miss (a lousy;) 16MB.  The very small bit of
extra balancing of other zones would easily be paid for by the reduced
search time (supposition).  You'd certainly be doing large tasks a big
favor by refusing to give them ZONE_DMA pages on a fallback allocation.

I'd almost bet money (will bet a bogobeer:) that disabling fallback to
ZONE_DMA entirely on Dirk's box will make his troubles instantly gone.
Not that we don't need per zone balancing anyway mind you.. it's just
the tiny zone case that is an absolute guaranteed performance killer.

Comments?

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
