Message-ID: <403FF15E.3040800@cyberone.com.au>
Date: Sat, 28 Feb 2004 12:39:42 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] VM batching patch problems?
References: <403FDEAA.1000802@cyberone.com.au> <20040227165244.25648122.akpm@osdl.org>
In-Reply-To: <20040227165244.25648122.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Andrew Morton wrote:

>Nick Piggin <piggin@cyberone.com.au> wrote:
>
>>Hi,
>>Here are a couple of things I think are wrong with balancing-batching
>>patch. Comments? Maybe I'm wrong?
>>
>>
>>1. kswapd always balances all zones. With your patch, balance_pgdat from
>>kswapd will continue to balance all zones while any one of them is above
>>the pages_high watermark. Strictly, this means it puts exactly equal
>>pressure on all zones (disregarding problem #2). But it somewhat defeats
>>the purpose of zones, which is to be able to selectively put more pressure
>>on one area when needed.
>>
>>Example: 8MB cache in ZONE_DMA, 8000MB cache in ZONE_HIGHMEM and we'll
>>assume pages are reclaimed from each zone at the same rate. Now suppose
>>ZONE_DMA goes 10 pages under the watermark. kswapd will free 10000 pages
>>from highmem while freeing the 10 ZONE_DMA pages.
>>
>
>Maybe.  It's still a relatively small amount of the zone.
>
>

But that is with a relatively small amount of ZONE_DMA. Either way,
kswapd will now bring ZONE_DMA above water 1000 times slower than
it would if it didn't need to scan ZONE_HIGHMEM. Doing it this way
has 0 benefits that I can see.

>With an understanding of a problem it should be possible to construt a
>testcase which demonstrates that problem, no?
>
>

I can tell you that kswapd will be much less responsive in keeping
small zones with free memory available in the presence of larger
zones (eg ZONE_DMA vs ZONE_NORMAL, or ZONE_NORMAL vs ZONE_HIGHMEM).
I guess this could be measured with a test case: keep track of total
time each zone is under water.

>>2. "batch pressure" is proportional to total size of the zone. It should
>>be proportional to the size of the freeable LRU cache.
>>
>>Example: 1GB ZONE_NORMAL, 1GB ZONE_HIGHMEM. Both will have the same batch
>>pressure, so the scanners will attempt to free the same amount of LRU cache
>>per run from each zone. Now say ZONE_NORMAL is filled with 750MB of slab
>>cache and pinned memory. The 250MB of LRU cache will be scanned at the
>>same rate as the 1GB of highmem LRU cache.
>>
>>
>
>hmm, yes.  But the increased ZONE_NORMAL scanning will cause increased slab
>reclaim.  Bear in mind that the batching does not balance the amount of
>scanning scross the zones (maybe it should).  It balances the amount of
>reclaiming across the zones.  So we can if we want incorporate the number
>of reclaimed slab pages into the arithmetic.
>

No it doesn't increase ZONE_NORMAL scanning. The scanning is the same rate,
but because ZONE_NORMAL is 1/4 the size, it has quadruple the pressure. If
you don't like logic, just pretend it is pinned by mem_map and other things.
Your batching patch is conceptually wrong and it adds complexity.

And *reclaiming* across zones is a silly notion, it applies more pressure
to zones with hotter pages. You want to balance *scanning*, and reclaim
will take care of itself. This notion is embedded all through the scanner
though, not just in your patch. I have ripped it out.


>
>
>
>>3. try_to_free_pages is now too lazy or sleepy. This seems to be what is
>>causing the lowend kbuild problems.
>>
>
>What makes you think that?
>
>

Because if I make it sleep less and reclaim more, I drop kbuild time
from 15 minutes with your scheme to 10 minutes. I don't know what more
I can say. Your patch causes big regressions here in an area that I
am trying to fix up. I am not making this up.

>>I have a batch that addresses these problems and others.
>>
>
>Sorry, I dropped most of your patches.  I was reorganising things and it
>just became impossible to work with them.  One of them did eight unrelated
>things!  It's impossible to select different parts, to understand what the
>different parts are doing, to instrument them, etc.
>
>

OK most of them did one thing, but one did a number of pretty trivial
things which I guess should have been broken out.

>Some of the changes (such as in vm-tune-throttle) looked like random
>empirical hacks.  Without any description of what they're doing and of what
>experimentation/testing/instrumentation went into them I'm not able to work
>with them.
>
>

I have been testing and posting results for the last month or two.

vm-tune-throttle is actually one of those patches that does one thing,
and it is documented exactly what it does at the top of the patch. I
admit this is the one patch I wasn't able to measure an improvement
from, but I like it anyway and I'll keep it.

>So I picked out a couple of bits which were useful and obvious and dropped
>the rest.  Please, no more megahumongopatches.  One concept per patch.
>
>I probably screwed up a few things and may have lost some bugfixes in the
>process.
>
>The one patch which I don't particularly like is
>vm-dont-rotate-active-list.patch.  The theory makes sense but all that
>mucking with false marker pages is a bit yuk.  As I am unable to
>demonstrate any improvement from that patch (slight regressions, in fact)
>based on admittedly inexhaustive testing, I'd prefer that we be able to
>demonstrate a good reason for bringing it back.
>

I already have, multiple times, which is why I sent it to you.
I really have done quite a lot of testing. From the feedback I
have got through your being in your tree I can say I'm on the
right track with the patches, so I'll have to maintain my own
rollup.

I don't understand why your tests aren't showing any improvement.
I know better than to question your testing methodology, but I
don't believe the patches are so fragile that they only work for
me. In fact, there has been quite a bit of feedback about how they
help in real usage as well as benchmarks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
