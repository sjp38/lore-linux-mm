Date: Thu, 11 May 2000 16:46:13 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] balanced highmem subsystem under pre7-9
In-Reply-To: <Pine.LNX.4.10.10005120113520.10596-200000@elte.hu>
Message-ID: <Pine.LNX.4.10.10005111638260.1319-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


On Fri, 12 May 2000, Ingo Molnar wrote:
> 
> IMO high memory should not be balanced. Stock pre7-9 tried to balance high
> memory once it got below the treshold (causing very bad VM behavior and
> high kswapd usage) - this is incorrect because there is nothing special
> about the highmem zone, it's more like an 'extension' of the normal zone,
> from which specific caches can turn. (patch attached)

Hmm.. I think the patch is wrong. It's much easier to make

	zone_balance_max[HIGHMEM] = 0;

and that will do the same thing, no?

> another problem is that even during a mild test the DMA zone gets emptied
> easily - but on a big RAM box kswapd has to work _alot_ to fill it up. In
> fact on an 8GB box it's completely futile to fill up the DMA zone. What
> worked for me is this zone-chainlist trick in the zone setup code:

Ok. This is a real problem. My inclination would be to say that your patch
is right, but only for large-memory configurations. Ie just say that if
the dang machine has more than half a gig of memory, we shouldn't touch
the 16 low megs at all unless explicitly asked for.

But the static thing ("never touch ZONE_DMA" when doing a normal
allocation) is obviously bogus on smaller-memory machines. So make it
conditional. 

> allocate 5% of total RAM or 16MB to the DMA zone (via fixing up zone sizes
> on bootup), whichever is smaller, in 2MB increments. Disadvantage of this
> method: eg. it wastes 2MB RAM on a 8MB box.

This may be part of the solution - make it more gradual than a complete
cut-off at some random point (eg half a gig).

After all, this is why we zoned memory in the first place, so I think it
makes sense to be much more dynamic with the zones.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
