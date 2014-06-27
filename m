Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 521DB6B0039
	for <linux-mm@kvack.org>; Fri, 27 Jun 2014 13:27:05 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id hi2so3203869wib.7
        for <linux-mm@kvack.org>; Fri, 27 Jun 2014 10:27:04 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id cg7si14893756wjc.57.2014.06.27.10.27.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 27 Jun 2014 10:27:03 -0700 (PDT)
Date: Fri, 27 Jun 2014 13:26:57 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/5] mm: vmscan: Do not reclaim from lower zones if they
 are balanced
Message-ID: <20140627172657.GU7331@cmpxchg.org>
References: <1403856880-12597-1-git-send-email-mgorman@suse.de>
 <1403856880-12597-4-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1403856880-12597-4-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Fri, Jun 27, 2014 at 09:14:38AM +0100, Mel Gorman wrote:
> Historically kswapd scanned from DMA->Movable in the opposite direction
> to the page allocator to avoid allocating behind kswapd direction of
> progress. The fair zone allocation policy altered this in a non-obvious
> manner.
> 
> Traditionally, the page allocator prefers to use the highest eligible zone
> until the watermark is depleted, woke kswapd and moved onto the next zone.

That's not quite right, the page allocator tries all zones in the
zonelist, then wakes up kswapd, then tries again from the beginning.

> kswapd scans zones in the opposite direction so the scanning lists on
> 64-bit look like this;
> 
> Page alloc		Kswapd
> ----------              ------
> Movable			DMA
> Normal			DMA32
> DMA32			Normal
> DMA			Movable
> 
> If kswapd scanned in the same direction as the page allocator then it is
> possible that kswapd would proportionally reclaim the lower zones that
> were never used as the page allocator was always allocating behind the
> reclaim. This would work as follows
> 
> 	pgalloc hits Normal low wmark
> 					kswapd reclaims Normal
> 					kswapd reclaims DMA32
> 	pgalloc hits Normal low wmark
> 					kswapd reclaims Normal
> 					kswapd reclaims DMA32
> 
> The introduction of the fair zone allocation policy fundamentally altered
> this problem by interleaving between zones until the low watermark is
> reached. There are at least two issues with this
> 
> o The page allocator can allocate behind kswapds progress (scans/reclaims
>   lower zone and fair zone allocation policy then uses those pages)
> o When the low watermark of the high zone is reached there may recently
>   allocated pages allocated from the lower zone but as kswapd scans
>   dma->highmem to the highest zone needing balancing it'll reclaim the
>   lower zone even if it was balanced.
> 
> Let N = high_wmark(Normal) + high_wmark(DMA32). Of the last N allocations,
> some percentage will be allocated from Normal and some from DMA32. The
> percentage depends on the ratio of the zone sizes and when their watermarks
> were hit. If Normal is unbalanced, DMA32 will be shrunk by kswapd. If DMA32
> is unbalanced only DMA32 will be shrunk. This leads to a difference of
> ages between DMA32 and Normal. Relatively young pages are then continually
> rotated and reclaimed from DMA32 due to the higher zone being unbalanced.
> Some of these pages may be recently read-ahead pages requiring that the page
> be re-read from disk and impacting overall performance.
> 
> The problem is fundamental to the fact we have per-zone LRU and allocation
> policies and ideally we would only have per-node allocation and LRU lists.
> This would avoid the need for the fair zone allocation policy but the
> low-memory-starvation issue would have to be addressed again from scratch.
> 
> This patch will only scan/reclaim from lower zones if they have not
> reached their watermark. This should not break the normal page aging
> as the proportional allocations due to the fair zone allocation policy
> should compensate.

That's already the case, kswapd_shrink_zone() checks whether the zone
is balanced before scanning in, so something in this analysis is off -
but I have to admit that I have trouble following it.

The only difference in the two checks is that the outer one you add
does not enforce the balance gap, which means that we stop reclaiming
zones a little earlier than before.  I guess this is where the
throughput improvements come from, but there is a chance it will
regress latency for bursty allocations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
