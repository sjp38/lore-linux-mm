Message-ID: <403FDEAA.1000802@cyberone.com.au>
Date: Sat, 28 Feb 2004 11:19:54 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: [RFC] VM batching patch problems?
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,
Here are a couple of things I think are wrong with balancing-batching
patch. Comments? Maybe I'm wrong?


1. kswapd always balances all zones. With your patch, balance_pgdat from
kswapd will continue to balance all zones while any one of them is above
the pages_high watermark. Strictly, this means it puts exactly equal
pressure on all zones (disregarding problem #2). But it somewhat defeats
the purpose of zones, which is to be able to selectively put more pressure
on one area when needed.

Example: 8MB cache in ZONE_DMA, 8000MB cache in ZONE_HIGHMEM and we'll
assume pages are reclaimed from each zone at the same rate. Now suppose
ZONE_DMA goes 10 pages under the watermark. kswapd will free 10000 pages
from highmem while freeing the 10 ZONE_DMA pages.


2. "batch pressure" is proportional to total size of the zone. It should
be proportional to the size of the freeable LRU cache.

Example: 1GB ZONE_NORMAL, 1GB ZONE_HIGHMEM. Both will have the same batch
pressure, so the scanners will attempt to free the same amount of LRU cache
per run from each zone. Now say ZONE_NORMAL is filled with 750MB of slab
cache and pinned memory. The 250MB of LRU cache will be scanned at the
same rate as the 1GB of highmem LRU cache.


3. try_to_free_pages is now too lazy or sleepy. This seems to be what is
causing the lowend kbuild problems. There is a significant and very
repeatable performance drop of around 40% when moving from mm2 -> mm3 for
medium and heavy swapping kbuild.

I have a batch that addresses these problems and others. It needs to be
a bit smarter about problem #3 though. My patch gets better -j10
performance than mm2 but still slightly worse -j15 performance, though
still much better than mm3.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
