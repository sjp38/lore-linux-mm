Date: Wed, 18 Jul 2001 13:09:17 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] Separate global/perzone inactive/free shortage
In-Reply-To: <12670000.995468875@baldur>
Message-ID: <Pine.LNX.4.33L.0107181243490.9022-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmc@austin.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 18 Jul 2001, Dave McCracken wrote:
> --On Wednesday, July 18, 2001 10:54:52 +0200 Mike Galbraith
> <mikeg@wen-online.de> wrote:
>
> > Possible solution:
> >
> > Effectively reserving the last ~meg (pick a number, scaled by ramsize
> > would be better) of ZONE_DMA for real GFP_DMA allocations would cure
> > Dirk's problem I bet, and also cure most of the others too, simply by
>
> Couldn't something similar to this be accomplished by tweaking the
> pages_{min,low,high} values to ZONE_DMA based on the total memory in the
> machine?

I bet we can do this in a much simpler way with less
reliance on magic numbers. My theory goes as follows:

The problem with the current code is that the global
free target (freepages.high) is the same as the sum
of the per-zone free targets.

Because of this, we will always run into the local
free shortages and the VM has to eat free pages from
all zones and has no chance to properly balance usage
bettween the zones depending on VM activity in the
zone and desireability of allocating from this zone.

We could try increasing the _global_ free target to
something like 2 or 3 times the sum of the per-zone
free targets.

By doing that the system would have a much better
chance of leaving eg. the DMA zone alone for allocations
because kswapd doesn't just free the amount of pages
required to bring each zone to the edge, it would free
a whole bunch more pages, to whatever zone they happen
to be in.  That way the VM would do the bulk of the
allocations from the least loaded zone and leave the
DMA zone (at the end of the fallback chain) alone.

I'm not sure if this would work, but just increasing
the global free target to something significantly
higher than the sum of the per-zone free targets
is an easy to test change ;)

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
