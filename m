Date: Fri, 12 May 2000 02:08:19 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [patch] balanced highmem subsystem under pre7-9
In-Reply-To: <Pine.LNX.4.10.10005111638260.1319-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.10.10005120156350.10429-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

On Thu, 11 May 2000, Linus Torvalds wrote:

> > IMO high memory should not be balanced. Stock pre7-9 tried to balance high
> > memory once it got below the treshold (causing very bad VM behavior and
> > high kswapd usage) - this is incorrect because there is nothing special
> > about the highmem zone, it's more like an 'extension' of the normal zone,
> > from which specific caches can turn. (patch attached)
> 
> Hmm.. I think the patch is wrong. It's much easier to make

yep, it does work (and fixes the 'kswapd storm'), but it's wrong.

> 	zone_balance_max[HIGHMEM] = 0;
> 
> and that will do the same thing, no?

yep - or in fact just changing the constant initialization to ', 0 } ',
right?

> > another problem is that even during a mild test the DMA zone gets emptied
> > easily - but on a big RAM box kswapd has to work _alot_ to fill it up. In
> > fact on an 8GB box it's completely futile to fill up the DMA zone. What
> > worked for me is this zone-chainlist trick in the zone setup code:
> 
> Ok. This is a real problem. My inclination would be to say that your patch
> is right, but only for large-memory configurations. Ie just say that if
> the dang machine has more than half a gig of memory, we shouldn't touch
> the 16 low megs at all unless explicitly asked for.

i think there are two fundamental problems here:

	1) highmem should not be balanced (period)

	2) once all easily allocatable RAM is gone to some high-flux
	   allocator, the DMA zone is emptied at last and is never
	   refilled effectively, causing a pointless 'kswapd storm' again.

1) is more or less trivially solved by fixing zone_balance_max[]
initialization. 2):

> > allocate 5% of total RAM or 16MB to the DMA zone (via fixing up zone sizes
> > on bootup), whichever is smaller, in 2MB increments. Disadvantage of this
> > method: eg. it wastes 2MB RAM on a 8MB box.
> 
> This may be part of the solution - make it more gradual than a complete
> cut-off at some random point (eg half a gig).
> 
> After all, this is why we zoned memory in the first place, so I think it
> makes sense to be much more dynamic with the zones.

ok, so the rule would be to put:

	zone_dma_size := max(total_pages/32,16MB) &~(64k-1) + 64k

pages into the DMA zone, do the normal zone from this point up to highmem.
This gradually (linearly) increases the DMA zone's size from 64k on 1MB
boxes to 16MB on 512MB boxes and up. (in steps of 64k) This not only
serves as a DMA pool, but as an atomic allocation pool as well (which was
an ever burning problem on low memory NFS boxes).

i hope nothing relies on getting better than 64k physically aligned pages?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
