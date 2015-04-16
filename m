Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 228D86B0038
	for <linux-mm@kvack.org>; Thu, 16 Apr 2015 10:34:29 -0400 (EDT)
Received: by wiax7 with SMTP id x7so13185877wia.0
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 07:34:28 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id n10si32265022wiy.56.2015.04.16.07.34.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Apr 2015 07:34:27 -0700 (PDT)
Date: Thu, 16 Apr 2015 10:34:13 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm: vmscan: invoke slab shrinkers from shrink_zone()
Message-ID: <20150416143413.GA9228@cmpxchg.org>
References: <1416939830-20289-1-git-send-email-hannes@cmpxchg.org>
 <20141128160637.GH6948@esperanza>
 <20150416035736.GA1203@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150416035736.GA1203@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

Hi Joonsoo,

On Thu, Apr 16, 2015 at 12:57:36PM +0900, Joonsoo Kim wrote:
> Hello, Johannes.
> 
> Ccing Vlastimil, because this patch causes some regression on
> stress-highalloc test in mmtests and he is a expert on compaction
> and would have interest on it. :)
> 
> On Fri, Nov 28, 2014 at 07:06:37PM +0300, Vladimir Davydov wrote:
> > If the highest zone (zone_idx=requested_highidx) is not populated, we
> > won't scan slab caches on direct reclaim, which may result in OOM kill
> > even if there are plenty of freeable dentries available.
> > 
> > It's especially relevant for VMs, which often have less than 4G of RAM,
> > in which case we will only have ZONE_DMA and ZONE_DMA32 populated and
> > empty ZONE_NORMAL on x86_64.
> 
> I got similar problem mentioned above by Vladimir when I test stress-highest
> benchmark. My test system has ZONE_DMA and ZONE_DMA32 and ZONE_NORMAL zones
> like as following.
> 
> Node 0, zone      DMA
>         spanned  4095
>         present  3998
>         managed  3977
> Node 0, zone    DMA32
>         spanned  1044480
>         present  782333
>         managed  762561
> Node 0, zone   Normal
>         spanned  262144
>         present  262144
>         managed  245318
> 
> Perhaps, requested_highidx would be ZONE_NORMAL for almost normal
> allocation request.
> 
> When I test stress-highalloc benchmark, shrink_zone() on requested_highidx
> zone in kswapd_shrink_zone() is frequently skipped because this zone is
> already balanced. But, another zone, for example, DMA32, which has more memory,
> isn't balanced so kswapd try to reclaim on that zone. But,
> zone_idx(zone) == classzone_idx isn't true for that zone so
> shrink_slab() is skipped and we can't age slab objects with same ratio
> of lru pages.

No, kswapd_shrink_zone() has the highest *unbalanced* zone as the
classzone.  When Normal is balanced but DMA32 is not, then kswapd
scans DMA and DMA32 and invokes the shrinkers for DMA32.

> This could be also possible on direct reclaim path as Vladimir
> mentioned.

Direct reclaim ignores watermarks and always scans a zone.  The
problem is only with completely unpopulated zones, but Vladimir
addressed that.

> This causes following success rate regression of phase 1,2 on stress-highalloc
> benchmark. The situation of phase 1,2 is that many high order allocations are
> requested while many threads do kernel build in parallel.

Yes, the patch made the shrinkers on multi-zone nodes less aggressive.
>From the changelog:

    This changes kswapd behavior, which used to invoke the shrinkers for each
    zone, but with scan ratios gathered from the entire node, resulting in
    meaningless pressure quantities on multi-zone nodes.

So the previous code *did* apply more pressure on the shrinkers, but
it didn't make any sense.  The number of slab objects to scan for each
scanned LRU page depended on how many zones there were in a node, and
their relative sizes.  So a node with a large DMA32 and a small Normal
would receive vastly different relative slab pressure than a node with
only one big zone Normal.  That's not something we should revert to.

If we are too weak on objects compared to LRU pages then we should
adjust DEFAULT_SEEKS or individual shrinker settings.

If we think our pressure ratio is accurate but we don't reclaim enough
compared to our compaction efforts, then any adjustments to improve
huge page successrate should come from the allocator/compaction side.

> Base: Run 1
> Ops 1       33.00 (  0.00%)
> Ops 2       43.00 (  0.00%)
> Ops 3       80.00 (  0.00%)
> Base: Run 2
> Ops 1       33.00 (  0.00%)
> Ops 2       44.00 (  0.00%)
> Ops 3       80.00 (  0.00%)
> Base: Run 3
> Ops 1       30.00 (  0.00%)
> Ops 2       44.00 (  0.00%)
> Ops 3       80.00 (  0.00%)
> 
> Revert offending commit: Run 1
> Ops 1       46.00 (  0.00%)
> Ops 2       53.00 (  0.00%)
> Ops 3       80.00 (  0.00%)
> Revert offending commit: Run 2
> Ops 1       48.00 (  0.00%)
> Ops 2       55.00 (  0.00%)
> Ops 3       80.00 (  0.00%)
> Revert offending commit: Run 3
> Ops 1       48.00 (  0.00%)
> Ops 2       55.00 (  0.00%)
> Ops 3       81.00 (  0.00%)
> 
> I'm not sure whether we should consider this benchmark's regression very much,
> because real life's compaction behavious would be different with this
> benchmark. Anyway, I have some questions related to this patch. I don't know
> this code very well so please correct me if I'm wrong.
> 
> I read the patch carefully and there is two main differences between before
> and after. One is the way of aging ratio calculation. Before, we use number of
> lru pages in node, but, this patch uses number of lru pages in zone. As I
> understand correctly, shrink_slab() works for a node range rather than
> zone one. And, I guess that calculated ratio with zone's number of lru pages
> could be more fluctuate than node's one. Is it reasonable to use zone's one?

The page allocator distributes allocations evenly among the zones in a
node, so the fluctuation should be fairly low.

And we scan the LRUs in chunks of 32 pages, which gives us good enough
ratio granularity on even tiny zones (1/8th on a hypothetical 1M zone).

> And, should we guarantee one time invocation of shrink_slab() in above cases?
> When I tested it, benchmark result is restored a little.
> 
> Guarantee one time invocation: Run 1
> Ops 1       30.00 (  0.00%)
> Ops 2       47.00 (  0.00%)
> Ops 3       80.00 (  0.00%)
> Guarantee one time invocation: Run 2
> Ops 1       43.00 (  0.00%)
> Ops 2       45.00 (  0.00%)
> Ops 3       78.00 (  0.00%)
> Guarantee one time invocation: Run 3
> Ops 1       39.00 (  0.00%)
> Ops 2       45.00 (  0.00%)
> Ops 3       80.00 (  0.00%)

It should already invoke the shrinkers at least once per node.  Could
you tell me how you changed the code for this test?

Thanks,
Johannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
