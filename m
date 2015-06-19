Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 4330C6B0093
	for <linux-mm@kvack.org>; Fri, 19 Jun 2015 13:02:04 -0400 (EDT)
Received: by wibee9 with SMTP id ee9so15270897wib.0
        for <linux-mm@kvack.org>; Fri, 19 Jun 2015 10:02:03 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id m6si5640749wif.81.2015.06.19.10.02.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jun 2015 10:02:02 -0700 (PDT)
Date: Fri, 19 Jun 2015 13:01:39 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH 00/25] Move LRU page reclaim from zones to nodes
Message-ID: <20150619170139.GA11316@cmpxchg.org>
References: <1433771791-30567-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1433771791-30567-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

Hi Mel,

these are cool patches, I very much like the direction this is headed.

On Mon, Jun 08, 2015 at 02:56:06PM +0100, Mel Gorman wrote:
> This is an RFC series against 4.0 that moves LRUs from the zones to the
> node. In concept, this is straight forward but there are a lot of details
> so I'm posting it early to see what people think. The motivations are;
> 
> 1. Currently, reclaim on node 0 behaves differently to node 1 with subtly different
>    aging rules. Workloads may exhibit different behaviour depending on what node
>    it was scheduled on as a result.

How so?  Don't we ultimately age pages in proportion to node size,
regardless of how many zones they are broken into?

> 2. The residency of a page partially depends on what zone the page was
>    allocated from.  This is partially combatted by the fair zone allocation
>    policy but that is a partial solution that introduces overhead in the
>    page allocator paths.

Yeah, it's ugly and I'm happy you're getting rid of this again.  That
being said, in my tests it seemed like a complete solution to remove
any influence from allocation placement on aging behavior.  Where do
you still see aging artifacts?

> 3. kswapd and the page allocator play special games with the order they scan zones
>    to avoid interfering with each other but it's unpredictable.

It would be good to recall here these interference issues, how they
are currently coped with, and how your patches address them.

> 4. The different scan activity and ordering for zone reclaim is very difficult
>    to predict.

I'm not sure what this means.

> 5. slab shrinkers are node-based which makes relating page reclaim to
>    slab reclaim harder than it should be.

Agreed.  And I'm sure dchinner also much prefers moving the VM towards
a node model over moving the shrinkers towards the zone model.

> The reason we have zone-based reclaim is that we used to have
> large highmem zones in common configurations and it was necessary
> to quickly find ZONE_NORMAL pages for reclaim. Today, this is much
> less of a concern as machines with lots of memory will (or should) use
> 64-bit kernels. Combinations of 32-bit hardware and 64-bit hardware are
> rare. Machines that do use highmem should have relatively low highmem:lowmem
> ratios than we worried about in the past.
> 
> Conceptually, moving to node LRUs should be easier to understand. The
> page allocator plays fewer tricks to game reclaim and reclaim behaves
> similarly on all nodes.

Do you think it's feasible to serve the occasional address-restricted
request from CMA, or a similar mechanism based on PFN ranges?  In the
longterm, it would be great to eradicate struct zone entirely, and
have the page allocator and reclaim talk about the same thing again
without having to translate back and forth between zones and nodes.

It would also be much better for DMA allocations that don't align with
the zone model, such as 31-bit address requests, which currently have
to play the lottery with GFP_DMA32 and fall back to GFP_DMA.

> It was tested on a UMA (8 cores single socket) and a NUMA machine (48 cores,
> 4 sockets). The page allocator tests showed marginal differences in aim9,
> page fault microbenchmark, page allocator micro-benchmark and ebizzy. This
> was expected as the affected paths are small in comparison to the overall
> workloads.
> 
> I also tested using fstest on zero-length files to stress slab reclaim. It
> showed no major differences in performance or stats.
> 
> A THP-based test case that stresses compaction was inconclusive. It showed
> differences in the THP allocation success rate and both gains and losses in
> the time it takes to allocate THP depending on the number of threads running.

It would useful to include a "reasonable" highmem test here as well.

> Tests did show there were differences in the pages allocated from each zone.
> This is due to the fact the fair zone allocation policy is removed as with
> node-based LRU reclaim, it *should* not be necessary. It would be preferable
> if the original database workload that motivated the introduction of that
> policy was retested with this series though.

It's as simple as repeatedly reading a file that is ever-so-slightly
bigger than the available memory.  The result should be a perfect
tail-chasing scenario, with the entire file being served from disk
every single time.  If parts of it get activated, that is a problem,
because it means that some pages get aged differently than others.

When I worked on the fair zone allocator, I hacked mincore() to report
PG_active, to be extra sure about where the pages of interest are, but
monitoring pgactivate during the test, or comparing its deltas between
kernels, should be good enough.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
