Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 116F66B0037
	for <linux-mm@kvack.org>; Wed,  4 Jun 2014 10:56:36 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id r20so1650284wiv.3
        for <linux-mm@kvack.org>; Wed, 04 Jun 2014 07:56:35 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id eu11si5136805wjc.119.2014.06.04.07.56.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 04 Jun 2014 07:56:30 -0700 (PDT)
Date: Wed, 4 Jun 2014 10:56:10 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: page_alloc: Reset fair zone allocation policy only
 when batch counts are expired
Message-ID: <20140604145610.GS2878@cmpxchg.org>
References: <20140529090432.GY23991@suse.de>
 <20140529143832.GJ2878@cmpxchg.org>
 <20140529171608.GB23991@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140529171608.GB23991@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Thu, May 29, 2014 at 06:16:08PM +0100, Mel Gorman wrote:
> On Thu, May 29, 2014 at 10:38:32AM -0400, Johannes Weiner wrote:
> > Hi Mel!
> > 
> > On Thu, May 29, 2014 at 10:04:32AM +0100, Mel Gorman wrote:
> > > The fair zone allocation policy round-robins allocations between zones on
> > > a node to avoid age inversion problems during reclaim using a counter to
> > > manage the round-robin. If the first allocation fails, the batch counts get
> > > reset and the allocation is attempted again before going into the slow path.
> > > There are at least two problems with this
> > > 
> > > 1. If the eligible zones are below the low watermark we reset the counts
> > >    even though the batches might be fine.
> > 
> > The idea behind setting the batches to high-low was that they should
> > be roughly exhausted by the time the low watermark is hit.  And that
> > misconception must be the crux of this patch, because if they *were*
> > to exhaust together this patch wouldn't make a difference.
> > 
> > But once they diverge, we reset the batches prematurely, which means
> > not everybody is getting their fair share, and that reverts us back to
> > an imbalance in zone utilization.
> > 
> > So I think the changelog should include why this assumption was wrong.
> > 
> 
> They won't exhaust together when there are multiple allocation requests
> simply on the basis that there is no lock there and there is per-cpu
> accounting drift for vmstats. You'd at least expect them to drift by the
> per-cpu update threshold.

Yeah, that's true.  I just didn't think it would make such a big
difference, and the numbers I gathered on my local machines showed
that allocation distribution was reliably proportional to zone size.
But it might really depend on the machine, and definitely on the
workload, which why I was curious about the allocation numbers.

> > > When resetting batch counts, it was expected that the count would be <=
> > > 0 but the bizarre side-effect is that we are resetting counters that were
> > > initially postive so (high - low - batch) potentially sets a high positive
> > > batch count to close to 0. This leads to a premature reset in the near
> > > future, more overhead and more ... screwing around.
> > 
> > We're just adding the missing delta between the "should" and "is"
> > value to the existing batch, so a high batch value means small delta,
> > and we *add* a value close to 0, we don't *set* the batch close to 0.
> > 
> > I think this one is a red herring as well.
> > 
> 
> There are still boundary issues that results in screwing around and
> maybe I should have focused on this one instead. The situation I had in
> mind started out as follows
> 
> high zone alloc batch	1000	low watermark not ok
> low zone alloc batch	   0	low watermark     ok
> 
> during the fairness cycle, no action can take place. The higher zone is not
> allowed to allcoate at below the low watermark and must always enter the
> slow path. The lower zone also temporarily cannot be used. At this point, a
> reset takes place and the system continues until the low watermark is reached
> 
> high zone alloc batch	1000	low watermark not ok
> low zone allooc batch	 100	low watermark not ok
> 
> During this window, every ALLOC_FAIR is going to fail to due watermarks but
> still do another zone batch reset and recycle every time before falling
> into the slow path.  It ends up being more zonelist traversals which is
> why I moved the reset check inside get_page_from_freelist to detect the
> difference between ALLOC_FAIL failures and watermarks failures.
> 
> The differences in timing when watermarks are hit may also account for
> some of the drift for when the alloc batches get depleted.

That makes sense, especially in a highly concurrent workload where the
batches might be reset over and over between the first allocator
entering the slowpath and kswapd actually restoring any of the
watermarks.

> > > The user-visible effect depends on zone sizes and a host of other effects
> > > the obvious one is that single-node machines with multiple zones will see
> > > degraded performance for streaming readers at least. The effect is also
> > > visible on NUMA machines but it may be harder to identify in the midst of
> > > other noise.
> > > 
> > > Comparison is tiobench with data size 2*RAM on ext3 on a small single-node
> > > machine and on an ext3 filesystem. Baseline kernel is mmotm with the
> > > shrinker and proportional reclaim patches on top.
> > > 
> > >                                       3.15.0-rc5            3.15.0-rc5
> > >                                   mmotm-20140528         fairzone-v1r1
> > > Mean   SeqRead-MB/sec-1         120.95 (  0.00%)      133.59 ( 10.45%)
> > > Mean   SeqRead-MB/sec-2         100.81 (  0.00%)      113.61 ( 12.70%)
> > > Mean   SeqRead-MB/sec-4          93.75 (  0.00%)      104.75 ( 11.74%)
> > > Mean   SeqRead-MB/sec-8          85.35 (  0.00%)       91.21 (  6.86%)
> > > Mean   SeqRead-MB/sec-16         68.91 (  0.00%)       74.77 (  8.49%)
> > > Mean   RandRead-MB/sec-1          1.08 (  0.00%)        1.07 ( -0.93%)
> > > Mean   RandRead-MB/sec-2          1.28 (  0.00%)        1.25 ( -2.34%)
> > > Mean   RandRead-MB/sec-4          1.54 (  0.00%)        1.51 ( -1.73%)
> > > Mean   RandRead-MB/sec-8          1.67 (  0.00%)        1.70 (  2.20%)
> > > Mean   RandRead-MB/sec-16         1.74 (  0.00%)        1.73 ( -0.19%)
> > > Mean   SeqWrite-MB/sec-1        113.73 (  0.00%)      113.88 (  0.13%)
> > > Mean   SeqWrite-MB/sec-2        103.76 (  0.00%)      104.13 (  0.36%)
> > > Mean   SeqWrite-MB/sec-4         98.45 (  0.00%)       98.44 ( -0.01%)
> > > Mean   SeqWrite-MB/sec-8         93.11 (  0.00%)       92.79 ( -0.34%)
> > > Mean   SeqWrite-MB/sec-16        87.64 (  0.00%)       87.85 (  0.24%)
> > > Mean   RandWrite-MB/sec-1         1.38 (  0.00%)        1.36 ( -1.21%)
> > > Mean   RandWrite-MB/sec-2         1.35 (  0.00%)        1.35 (  0.25%)
> > > Mean   RandWrite-MB/sec-4         1.33 (  0.00%)        1.35 (  1.00%)
> > > Mean   RandWrite-MB/sec-8         1.31 (  0.00%)        1.29 ( -1.53%)
> > > Mean   RandWrite-MB/sec-16        1.27 (  0.00%)        1.28 (  0.79%)
> > > 
> > > Streaming readers see a huge boost. Random random readers, sequential
> > > writers and random writers are all in the noise.
> > 
> > Impressive, but I would really like to understand what's going on
> > there.
> > 
> > Did you record the per-zone allocation numbers by any chance as well,
> > so we can see the difference in zone utilization?
> 
> No, I didn't record per-zone usage because at the time when the low
> watermarks are being hit, it would have been less useful anyway.

I just meant the pgalloc_* numbers from /proc/vmstat before and after
the workload to see if the distribution really runs out of whack and
are not in proportion to the zone sizes over the course of the load.

> > > @@ -1960,11 +1982,13 @@ zonelist_scan:
> > >  		 * time the page has in memory before being reclaimed.
> > >  		 */
> > >  		if (alloc_flags & ALLOC_FAIR) {
> > > -			if (!zone_local(preferred_zone, zone))
> > > -				continue;
> > >  			if (zone_page_state(zone, NR_ALLOC_BATCH) <= 0)
> > >  				continue;
> > > +			batch_depleted = false;
> > > +			if (!zone_local(preferred_zone, zone))
> > > +				continue;
> > 
> > This only resets the local batches once the first non-local zone's
> > batch is exhausted as well.  Which means that once we start spilling,
> > the fairness pass will never consider local zones again until the
> > first spill-over target is exhausted too. 
> 
> Yes, you're right. The intent was that the reset would only task place
> after all local zones had used their allocation batch but it got mucked
> up along the way.

I thought this might have been an intentional change as per the NUMA
spilling behavior mentioned in the changelog.  Very well, then :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
