Date: Fri, 27 Feb 2004 16:52:44 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC] VM batching patch problems?
Message-Id: <20040227165244.25648122.akpm@osdl.org>
In-Reply-To: <403FDEAA.1000802@cyberone.com.au>
References: <403FDEAA.1000802@cyberone.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <piggin@cyberone.com.au> wrote:
>
> Hi,
> Here are a couple of things I think are wrong with balancing-batching
> patch. Comments? Maybe I'm wrong?
> 
> 
> 1. kswapd always balances all zones. With your patch, balance_pgdat from
> kswapd will continue to balance all zones while any one of them is above
> the pages_high watermark. Strictly, this means it puts exactly equal
> pressure on all zones (disregarding problem #2). But it somewhat defeats
> the purpose of zones, which is to be able to selectively put more pressure
> on one area when needed.
> 
> Example: 8MB cache in ZONE_DMA, 8000MB cache in ZONE_HIGHMEM and we'll
> assume pages are reclaimed from each zone at the same rate. Now suppose
> ZONE_DMA goes 10 pages under the watermark. kswapd will free 10000 pages
> from highmem while freeing the 10 ZONE_DMA pages.

Maybe.  It's still a relatively small amount of the zone.

With an understanding of a problem it should be possible to construt a
testcase which demonstrates that problem, no?

> 
> 2. "batch pressure" is proportional to total size of the zone. It should
> be proportional to the size of the freeable LRU cache.
> 
> Example: 1GB ZONE_NORMAL, 1GB ZONE_HIGHMEM. Both will have the same batch
> pressure, so the scanners will attempt to free the same amount of LRU cache
> per run from each zone. Now say ZONE_NORMAL is filled with 750MB of slab
> cache and pinned memory. The 250MB of LRU cache will be scanned at the
> same rate as the 1GB of highmem LRU cache.
> 

hmm, yes.  But the increased ZONE_NORMAL scanning will cause increased slab
reclaim.  Bear in mind that the batching does not balance the amount of
scanning scross the zones (maybe it should).  It balances the amount of
reclaiming across the zones.  So we can if we want incorporate the number
of reclaimed slab pages into the arithmetic.



> 3. try_to_free_pages is now too lazy or sleepy. This seems to be what is
> causing the lowend kbuild problems.

What makes you think that?

> I have a batch that addresses these problems and others.

Sorry, I dropped most of your patches.  I was reorganising things and it
just became impossible to work with them.  One of them did eight unrelated
things!  It's impossible to select different parts, to understand what the
different parts are doing, to instrument them, etc.

Some of the changes (such as in vm-tune-throttle) looked like random
empirical hacks.  Without any description of what they're doing and of what
experimentation/testing/instrumentation went into them I'm not able to work
with them.

So I picked out a couple of bits which were useful and obvious and dropped
the rest.  Please, no more megahumongopatches.  One concept per patch.

I probably screwed up a few things and may have lost some bugfixes in the
process.

The one patch which I don't particularly like is
vm-dont-rotate-active-list.patch.  The theory makes sense but all that
mucking with false marker pages is a bit yuk.  As I am unable to
demonstrate any improvement from that patch (slight regressions, in fact)
based on admittedly inexhaustive testing, I'd prefer that we be able to
demonstrate a good reason for bringing it back.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
