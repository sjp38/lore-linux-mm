From: Rik van Riel <riel@nl.linux.org>
Subject: Re: [RFC] [RFT] [PATCH] memory zone balancing
In-Reply-To: <200001061528.HAA05974@pizda.ninka.net>
Message-ID: <Pine.LNX.4.10.10001061926150.584-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Date: Thu, 6 Jan 2000 20:14:53 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: mingo@chiara.csoma.elte.hu, kanoj@google.engr.sgi.com, andrea@suse.de, torvalds@transmeta.com, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 6 Jan 2000, David S. Miller wrote:
>    Date:   Thu, 6 Jan 2000 17:05:41 +0100 (CET)
>    From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
> 
>    i think this is pretty much 'type-dependent'. In earlier versions
>    of the zone allocator i added a zone->memory_balanced() function
>    (but removed it later because it first needed the things your patch
>    adds). Then every zone can decide for itself wether it's
>    balanced. Eg. the DMA zone is rather critical and we want to keep
>    it free aggressively (part of that is already achieved by placing
>    it at the end of the zone chain), the highmem zone might not need
>    any balancing at all, the normal zone wants some high/low watermark
>    stuff.
> 
> Let's be careful not to design any balancing heuristics which will
> fall apart on architectures where only one zone ever exists (because
> GFP_DMA is completely meaningless).

We'll have to keep the current constraint (freepages.{min,low,high})
stuff as our overall target anyway. We simply need to add some limits
that the special zones have to target for.

And it won't just be tested from kswapd(); swap_tick() and maybe
even __get_pages() will have to check for the constraints too and
wake up kswapd() or take action themselves...

Possible heuristics (using d for dma, n for normal and high for
high free mem; limit = freepages.*) could use the following targets:

d + n > limit
d     > limit/4
n     > limit/4
h     < limit * 2 (because we don't care about free high pages
                   and we do care about free normal and dma pages)

Another possibility is to include the highmem (d + n + h > limit)
and keep the single low-mem limits.

IMHO there should be a number of constraints for a heuristic
like this:
- simple
- not force too much memory free
- the algorithm should have freedom in what to free, in order
  to avoid excessive scanning (alt: separate queues per zone)
- the limits for dma and normal memory should be high enough
  to be able to fulfill kernel allocations
- should have no impact on non-zoned machines

The (extremely simple) constraints above should probably be
enough to actually get the job done. At least, I wouldn't
know why we'd need more...

cheers,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
