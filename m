Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 669BF6B0037
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 14:18:57 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id r20so9820497wiv.14
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 11:18:56 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id lp7si8185131wjb.116.2014.06.19.11.18.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Jun 2014 11:18:55 -0700 (PDT)
Date: Thu, 19 Jun 2014 14:18:50 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/4] mm: page_alloc: Reset fair zone allocation policy
 when batch counts are expired
Message-ID: <20140619181850.GG7331@cmpxchg.org>
References: <1403079807-24690-1-git-send-email-mgorman@suse.de>
 <1403079807-24690-4-git-send-email-mgorman@suse.de>
 <20140618200129.GD7331@cmpxchg.org>
 <20140618215734.GD10819@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140618215734.GD10819@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>

On Wed, Jun 18, 2014 at 10:57:34PM +0100, Mel Gorman wrote:
> > > On large NUMA machines, the scanning overhead is higher as zones are
> > > scanned that are ineligible for zone allocation policy.
> > 
> > I'm not sure we can use your fix for that because of zone-order
> > zonelists, see inline comments below.
> > 
> 
> At one point I had a comment on that but then deleted it again. In the case
> of zone ordering the expectation is that low zones are preserved. The fair
> zone allocation policy actually breaks that expectation and violates the zone
> ordering rules but in a way that involves scanning zones that cannot be used.

That makes a lot of sense.  It would be great to make this a separate,
documented change, though.

> > It would be good to start with an analysis of the problem(s) and then
> > propose a solution based on that, otherwise it makes it very hard to
> > follow your thought process, and especially match these rather broad
> > statements to the code when you change multiple things at once.
> > 
> 
> I'm not sure what you're looking for here. The problem is that there was a
> sizable performance hit due to spending too much time in the allocator fast
> path. I suspected there was a secondary hit because the cache footprint is
> heavier when switching between the zones but profiles were inconclusive.
> There were higher number of cache misses during the copying of data and it
> could be inferred that this is partially due to a heavier cache footprint in
> the page allocator but profiles are not really suitable for proving that.
> The fact is that using vmstat counters increased cache footprint because
> of the numbers of spills from the per-cpu counter to the zone counter. Of
> course the VM already has a lot of these but the fair zone policy added more.

I think mainly I'm asking to split these individual changes out.  It's
a single change that almost doubles the implementation size and
changed the behavior in non-obvious ways, and it was hard to find
descriptions or justification for each change in the changelog.

> > > Second, when the fair zone batch counter is expired, the zone is
> > > flagged which has a lighter cache footprint than accessing the
> > > counters. Lastly, if the local node has only one zone then the fair
> > > zone allocation policy is not applied to reduce overall overhead.
> > 
> > These two are plausible, but they also make the code harder to
> > understand and their performance impact is not represented in your
> > test results, so we can't compare cost and value.
> > 
> 
> Do you mean that I hadn't posted results for a NUMA machine? They weren't
> available at the time I was writing the changelog but I knew from old results
> based on earlier iterations of the patch that it made a difference. The
> problem with the NUMA machine is that the results are much more variable
> due to locality and the fact that automatic NUMA balancing is enabled
> on any tests I do to match what I expect a distribution config to look
> like. I felt it was self-evident that applying the fair policy to a node
> with a single zone was a bad idea.

The single-zone node avoidance does make sense when considered in
isolation, agreed.  The depleted flags come with atomic bit ops and
add an extra conditional in the fast path to avoid a word-sized read,
and writes to that word are batched depending on machine size, so to
me the cost/benefit of it really isn't all that obvious.

> > > Comparison is tiobench with data size 2*RAM on a small single-node machine
> > > and on an ext3 filesystem although it is known that ext4 sees similar gains.
> > > I'm reporting sequental reads only as the other operations are essentially
> > > flat.
> > > 
> > >                                       3.16.0-rc1            3.16.0-rc1            3.16.0-rc1                 3.0.0
> > >                                          vanilla          cfq600              fairzone                     vanilla
> > > Mean   SeqRead-MB/sec-1         121.88 (  0.00%)      121.60 ( -0.23%)      131.68 (  8.04%)      134.59 ( 10.42%)
> > > Mean   SeqRead-MB/sec-2         101.99 (  0.00%)      102.35 (  0.36%)      113.24 ( 11.04%)      122.59 ( 20.20%)
> > > Mean   SeqRead-MB/sec-4          97.42 (  0.00%)       99.71 (  2.35%)      107.43 ( 10.28%)      114.78 ( 17.82%)
> > > Mean   SeqRead-MB/sec-8          83.39 (  0.00%)       90.39 (  8.39%)       96.81 ( 16.09%)      100.14 ( 20.09%)
> > > Mean   SeqRead-MB/sec-16         68.90 (  0.00%)       77.29 ( 12.18%)       81.88 ( 18.85%)       81.64 ( 18.50%)
> > > 
> > > Where as the CFQ patch helped throughput for higher number of threads, this
> > > patch (fairzone) whos performance increases for all thread counts and brings
> > > performance much closer to 3.0-vanilla. Note that performance can be further
> > > increased by tuning CFQ but the latencies of read operations are then higher
> > > but from the IO stats they are still acceptable.
> > > 
> > >                   3.16.0-rc1  3.16.0-rc1  3.16.0-rc1       3.0.0
> > >                      vanilla      cfq600    fairzone     vanilla
> > > Mean sda-avgqz        912.29      939.89      947.90     1000.70
> > > Mean sda-await       4268.03     4403.99     4450.89     4887.67
> > > Mean sda-r_await       79.42       80.33       81.34      108.53
> > > Mean sda-w_await    13073.49    11038.81    13217.25    11599.83
> > > Max  sda-avgqz       2194.84     2215.01     2307.48     2626.78
> > > Max  sda-await      18157.88    17586.08    14189.21    24971.00
> > > Max  sda-r_await      888.40      874.22      800.80     5308.00
> > > Max  sda-w_await   212563.59   190265.33   173295.33   177698.47
> > > 
> > > The primary concern with this patch is that it'll break the fair zone
> > > allocation policy but it should be still fine as long as the working set
> > > fits in memory. When the low watermark is constantly hit and the spread
> > > is still even as before. However, the policy is still in force most of the
> > > time. This is the allocation spread when running tiobench at 80% of memory
> > > 
> > >                             3.16.0-rc1  3.16.0-rc1  3.16.0-rc1       3.0.0
> > >                                vanilla      cfq600    fairzone     vanilla
> > > DMA32 allocs                  11099122    11020083     9459921     7698716
> > > Normal allocs                 18823134    18801874    20429838    18787406
> > > Movable allocs                       0           0           0           0
> > > 
> > > Note that the number of pages allocated from the Normal zone is still
> > > comparable.
> > 
> > When you translate them to percentages, it rather looks like fairness
> > is closer to pre-fairpolicy levels for this workload:
> > 
> >                              3.16.0-rc1  3.16.0-rc1  3.16.0-rc1       3.0.0
> >                                 vanilla      cfq600    fairzone     vanilla
> >  DMA32 allocs                     37.1%       37.0%       31.6%       29.1%
> >  Normal allocs                    62.9%       63.0%       68.4%       70.9%
> >  Movable allocs                      0%          0%          0%          0%
> > 
> 
> I can re-examine it again. The key problem here is that once the low
> watermark is reached that we can either adhere to the fair zone policy
> and stall the allocator by dropping into the slow path and/or waiting for
> kswapd to make progress or we can break the fair zone allocation policy,
> make progress now and hope that reclaim does not cause problems later. That
> is a bleak choice.

I'm not sure I follow entirely, but we definitely do rely on kswapd to
make forward progress right now because the assumption is that once we
allocated high - low wmark pages, kswapd will reclaim that same amount
as well.  And we do break fairness if that's not the case, but I think
that's actually good enough for practical purposes.

An alternative would be to increase the reclaim cycle and make the
distance between low and high watermarks bigger.  That would trade
some memory utilization for CPU time in the allocator.

> Ideally zones would go away altogether and LRU lists and alloctor paths
> used the same list with overhead of additional scanning if pages from
> a particular zone was required. That would remove the need for the fair
> zone policy entirely. However, this would be a heavy reachitecting of the
> current infrastructure and not guaranteed to work correctly.

Good lord, yes please!

But not exactly something we can do now and backport into stable ;-)

> > > @@ -1909,6 +1914,18 @@ static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
> > >  
> > >  #endif	/* CONFIG_NUMA */
> > >  
> > > +static void reset_alloc_batches(struct zone *preferred_zone)
> > > +{
> > > +	struct zone *zone = preferred_zone->zone_pgdat->node_zones;
> > > +
> > > +	do {
> > > +		mod_zone_page_state(zone, NR_ALLOC_BATCH,
> > > +			(zone->managed_pages >> 2) -
> > > +			atomic_long_read(&zone->vm_stat[NR_ALLOC_BATCH]));
> > > +		zone_clear_flag(zone, ZONE_FAIR_DEPLETED);
> > > +	} while (zone++ != preferred_zone);
> > 
> > What is zone->managed_pages >> 2 based on?
> > 
> 
> Magic number that would allow more progress to be made before switching
> to the lower zone.
>
> > The batch size was picked so that after all zones were used according
> > to their size, they would also get reclaimed according to their size,
> > and the cycle would start over.  This ensures that available memory is
> > fully utilized and page lifetime stays independent of zone placement.
> > 
> > The page allocator depletes the zones to their low watermark, then
> > kswapd restores them to their high watermark before the reclaim cycle
> > starts over.  This means that a reclaim cycle is high - low watermark
> > pages, which is reflected in the current round-robin batch sizes.
> > 
> > Now, we agree that the batches might drift from the actual reclaim
> > cycle due to per-cpu counter inaccuracies, but it's still a better
> > match for the reclaim cycle than "quarter zone size"...?
> > 
> 
> Fair enough, I'll restore it. At the time the priority was to minimise
> any cache effect from switching zones.

Unfortunately, for the given tests, this might be the main impact of
this patch.  Here are my tiobench results with ONLY increasing the
batch size to managed_pages >> 2, without even the CFQ patch, which I
understand accounts for the remaining drop at higher concurrency:

tiobench MB/sec
                                               3              3.16-rc1              3.16-rc1
                                             3.0                                  bigbatches
Mean   SeqRead-MB/sec-1         130.39 (  0.00%)      129.69 ( -0.54%)      137.02 (  5.08%)
Mean   SeqRead-MB/sec-2         128.14 (  0.00%)      115.63 ( -9.76%)      127.25 ( -0.69%)
Mean   SeqRead-MB/sec-4         125.06 (  0.00%)      110.03 (-12.02%)      121.35 ( -2.97%)
Mean   SeqRead-MB/sec-8         118.97 (  0.00%)      101.86 (-14.38%)      110.48 ( -7.14%)
Mean   SeqRead-MB/sec-16         96.30 (  0.00%)       86.30 (-10.39%)       94.07 ( -2.32%)

But yeah, they also wreck fairness to prehistoric levels:

                                 3.    3.16-rc1    3.16-rc1
                                3.0              bigbatches
Zone normal velocity      15772.202   11346.939   15234.211
Zone dma32 velocity        3102.806    8196.689    3437.191

> > All in all, I still don't really understand exactly how your changes
> > work and the changelog doesn't clarify much :( I'm just having a hard
> > time seeing how you get 10%-20% performance increase for an IO-bound
> > workload by making the allocator paths a little leaner.  Your results
> > certainly show that you *are* improving this particular workload, but
> > I think we should be clear on the mental model and then go from there.
> > 
> 
> Mental model is that too much overhead in the allocator fast path builds
> up over time. Second part is switching between free lists between zones
> and skipping the preferred zone when the batch is depleted has a heavier
> cache footprint which in turn has additional follow-on effects. Consider
> for example that recently freed pages that are potentially cache hot may
> get ignored by the fair zone allocation policy in favour of cache cold
> pages in a lower zone. The exact impact of this would depend on the CPU
> that did the freeing and whether cache was shared so analysing it in the
> general sense would be prohibitive.

Yes, I think these problems are inherent in a fairness system, it's
just a question how we find the right balance between fairness and
throughput while preserving a meaningful model of how it's supposed to
work, which I think the proposed magic batch sizes don't qualify for.

The expired-flags and skipping single-zone nodes OTOH were immediately
obvious because they optimize while preserving the existing semantics,
although I kind of still want to see these things quantified.

> > I haven't managed to reproduce it locally yet, will continue to play
> > around with the parameters.
> 
> Does that mean you have tried using tiobench and saw no effect or you
> haven't run tiobench yet? FWIW, I've seen this impact on multiple machines.

I tried My Favorite IO Benchmarks first, but they wouldn't yield
anything.  I could reproduce the problem with tiobench and the mmtests
standard configuration.

o bigbatches is increasing the batch to managed_pages >> 2

o bigbatches1node is additionally avoiding the unfair second remote
  spill pass on a single node system and goes straight into the slow
  path, but it looks like that optimization drowns in the noise

tiobench MB/sec
                                              3.              3.16-rc1              3.16-rc1              3.16-rc1
                                             3.0                                  bigbatches       bigbatches1node
Mean   SeqRead-MB/sec-1         130.39 (  0.00%)      129.69 ( -0.54%)      137.02 (  5.08%)      137.19 (  5.21%)
Mean   SeqRead-MB/sec-2         128.14 (  0.00%)      115.63 ( -9.76%)      127.25 ( -0.69%)      127.45 ( -0.53%)
Mean   SeqRead-MB/sec-4         125.06 (  0.00%)      110.03 (-12.02%)      121.35 ( -2.97%)      120.83 ( -3.38%)
Mean   SeqRead-MB/sec-8         118.97 (  0.00%)      101.86 (-14.38%)      110.48 ( -7.14%)      111.06 ( -6.65%)
Mean   SeqRead-MB/sec-16         96.30 (  0.00%)       86.30 (-10.39%)       94.07 ( -2.32%)       94.42 ( -1.96%)
Mean   RandRead-MB/sec-1          1.10 (  0.00%)        1.16 (  4.83%)        1.13 (  2.11%)        1.12 (  1.51%)
Mean   RandRead-MB/sec-2          1.29 (  0.00%)        1.27 ( -1.55%)        1.27 ( -1.81%)        1.27 ( -1.29%)
Mean   RandRead-MB/sec-4          1.51 (  0.00%)        1.48 ( -1.98%)        1.43 ( -5.51%)        1.46 ( -3.30%)
Mean   RandRead-MB/sec-8          1.60 (  0.00%)        1.70 (  6.46%)        1.62 (  1.25%)        1.68 (  5.21%)
Mean   RandRead-MB/sec-16         1.71 (  0.00%)        1.74 (  1.76%)        1.65 ( -3.52%)        1.72 (  0.98%)
Mean   SeqWrite-MB/sec-1        124.36 (  0.00%)      124.53 (  0.14%)      124.48 (  0.09%)      124.41 (  0.04%)
Mean   SeqWrite-MB/sec-2        117.16 (  0.00%)      117.58 (  0.36%)      117.59 (  0.37%)      117.74 (  0.50%)
Mean   SeqWrite-MB/sec-4        112.48 (  0.00%)      113.65 (  1.04%)      113.76 (  1.14%)      113.96 (  1.32%)
Mean   SeqWrite-MB/sec-8        110.40 (  0.00%)      110.76 (  0.33%)      111.28 (  0.80%)      111.65 (  1.14%)
Mean   SeqWrite-MB/sec-16       107.62 (  0.00%)      108.26 (  0.59%)      108.90 (  1.19%)      108.64 (  0.94%)
Mean   RandWrite-MB/sec-1         1.23 (  0.00%)        1.26 (  2.99%)        1.29 (  4.89%)        1.28 (  4.08%)
Mean   RandWrite-MB/sec-2         1.27 (  0.00%)        1.27 ( -0.26%)        1.28 (  0.79%)        1.31 (  3.41%)
Mean   RandWrite-MB/sec-4         1.23 (  0.00%)        1.24 (  0.81%)        1.27 (  3.25%)        1.27 (  3.25%)
Mean   RandWrite-MB/sec-8         1.23 (  0.00%)        1.26 (  2.17%)        1.26 (  2.44%)        1.24 (  0.81%)
Mean   RandWrite-MB/sec-16        1.19 (  0.00%)        1.24 (  4.21%)        1.24 (  4.21%)        1.25 (  5.06%)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
