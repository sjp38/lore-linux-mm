Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 498266B0031
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 17:57:41 -0400 (EDT)
Received: by mail-wg0-f42.google.com with SMTP id z12so1441454wgg.13
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 14:57:40 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q17si4345596wiv.54.2014.06.18.14.57.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Jun 2014 14:57:39 -0700 (PDT)
Date: Wed, 18 Jun 2014 22:57:34 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 3/4] mm: page_alloc: Reset fair zone allocation policy
 when batch counts are expired
Message-ID: <20140618215734.GD10819@suse.de>
References: <1403079807-24690-1-git-send-email-mgorman@suse.de>
 <1403079807-24690-4-git-send-email-mgorman@suse.de>
 <20140618200129.GD7331@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140618200129.GD7331@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>

On Wed, Jun 18, 2014 at 04:01:29PM -0400, Johannes Weiner wrote:
> Hi Mel,
> 
> On Wed, Jun 18, 2014 at 09:23:26AM +0100, Mel Gorman wrote:
> > The fair zone allocation policy round-robins allocations between zones
> > within a node to avoid age inversion problems during reclaim. If the
> > first allocation fails, the batch counts is reset and a second attempt
> > made before entering the slow path.
> > 
> > One assumption made with this scheme is that batches expire at roughly the
> > same time and the resets each time are justified. This assumption does not
> > hold when zones reach their low watermark as the batches will be consumed
> > at uneven rates.
> >
> > Allocation failure due to watermark depletion result in
> > additional zonelist scans for the reset and another watermark check before
> > hitting the slowpath.
> 
> Yes, one consequence of the changes in 3a025760fc15 ("mm: page_alloc:
> spill to remote nodes before waking kswapd") is that on single-node
> systems we have one useless spill cycle to non-existent remote nodes.
> 

Yes.

> Your patch adds a nr_online_nodes check, but it also does another
> zonelist scan if any watermark breaches were detected in the first
> cycle, so I don't see how you actually fix this issue?
> 

In the case any of the watermarks were breached then it was necessary
to rescan the zones that may have met the watermark but did not have a
NR_ALLOC_BATCH available. There were not many good choices on that front
that did not end up adding overhead in other places.

> > On large NUMA machines, the scanning overhead is higher as zones are
> > scanned that are ineligible for zone allocation policy.
> 
> I'm not sure we can use your fix for that because of zone-order
> zonelists, see inline comments below.
> 

At one point I had a comment on that but then deleted it again. In the case
of zone ordering the expectation is that low zones are preserved. The fair
zone allocation policy actually breaks that expectation and violates the zone
ordering rules but in a way that involves scanning zones that cannot be used.

> > This patch makes a number of changes which are all related to each
> > other. First and foremost, the patch resets the fair zone policy counts when
> > all the counters are depleted,
> 
> You also still reset them if any of the low watermarks are breached,
> so the only time we *would* save a reset cycle now is when all
> considered watermarks are fine and there are still some non-depleted
> batches - but in this case the allocation would have succeeded...?
> 

I was also taking into account the possibility that NR_ALLOC_BATCH might
have failed due to per-cpu drift but I get your point. I can see if it be
improved further. It had simply reached the point where the series in had
a sufficiently large impact that I released it.

> > avoids scanning remote nodes unnecessarily
> 
> I don't see how we are scanning them unnecessarily now.
> 
> > and reduces the frequency that resets are required.
> 
> How?
> 

By waiting until all the batches are consumed.

> It would be good to start with an analysis of the problem(s) and then
> propose a solution based on that, otherwise it makes it very hard to
> follow your thought process, and especially match these rather broad
> statements to the code when you change multiple things at once.
> 

I'm not sure what you're looking for here. The problem is that there was a
sizable performance hit due to spending too much time in the allocator fast
path. I suspected there was a secondary hit because the cache footprint is
heavier when switching between the zones but profiles were inconclusive.
There were higher number of cache misses during the copying of data and it
could be inferred that this is partially due to a heavier cache footprint in
the page allocator but profiles are not really suitable for proving that.
The fact is that using vmstat counters increased cache footprint because
of the numbers of spills from the per-cpu counter to the zone counter. Of
course the VM already has a lot of these but the fair zone policy added more.

> > Second, when the fair zone batch counter is expired, the zone is
> > flagged which has a lighter cache footprint than accessing the
> > counters. Lastly, if the local node has only one zone then the fair
> > zone allocation policy is not applied to reduce overall overhead.
> 
> These two are plausible, but they also make the code harder to
> understand and their performance impact is not represented in your
> test results, so we can't compare cost and value.
> 

Do you mean that I hadn't posted results for a NUMA machine? They weren't
available at the time I was writing the changelog but I knew from old results
based on earlier iterations of the patch that it made a difference. The
problem with the NUMA machine is that the results are much more variable
due to locality and the fact that automatic NUMA balancing is enabled
on any tests I do to match what I expect a distribution config to look
like. I felt it was self-evident that applying the fair policy to a node
with a single zone was a bad idea.

> > Comparison is tiobench with data size 2*RAM on a small single-node machine
> > and on an ext3 filesystem although it is known that ext4 sees similar gains.
> > I'm reporting sequental reads only as the other operations are essentially
> > flat.
> > 
> >                                       3.16.0-rc1            3.16.0-rc1            3.16.0-rc1                 3.0.0
> >                                          vanilla          cfq600              fairzone                     vanilla
> > Mean   SeqRead-MB/sec-1         121.88 (  0.00%)      121.60 ( -0.23%)      131.68 (  8.04%)      134.59 ( 10.42%)
> > Mean   SeqRead-MB/sec-2         101.99 (  0.00%)      102.35 (  0.36%)      113.24 ( 11.04%)      122.59 ( 20.20%)
> > Mean   SeqRead-MB/sec-4          97.42 (  0.00%)       99.71 (  2.35%)      107.43 ( 10.28%)      114.78 ( 17.82%)
> > Mean   SeqRead-MB/sec-8          83.39 (  0.00%)       90.39 (  8.39%)       96.81 ( 16.09%)      100.14 ( 20.09%)
> > Mean   SeqRead-MB/sec-16         68.90 (  0.00%)       77.29 ( 12.18%)       81.88 ( 18.85%)       81.64 ( 18.50%)
> > 
> > Where as the CFQ patch helped throughput for higher number of threads, this
> > patch (fairzone) whos performance increases for all thread counts and brings
> > performance much closer to 3.0-vanilla. Note that performance can be further
> > increased by tuning CFQ but the latencies of read operations are then higher
> > but from the IO stats they are still acceptable.
> > 
> >                   3.16.0-rc1  3.16.0-rc1  3.16.0-rc1       3.0.0
> >                      vanilla      cfq600    fairzone     vanilla
> > Mean sda-avgqz        912.29      939.89      947.90     1000.70
> > Mean sda-await       4268.03     4403.99     4450.89     4887.67
> > Mean sda-r_await       79.42       80.33       81.34      108.53
> > Mean sda-w_await    13073.49    11038.81    13217.25    11599.83
> > Max  sda-avgqz       2194.84     2215.01     2307.48     2626.78
> > Max  sda-await      18157.88    17586.08    14189.21    24971.00
> > Max  sda-r_await      888.40      874.22      800.80     5308.00
> > Max  sda-w_await   212563.59   190265.33   173295.33   177698.47
> > 
> > The primary concern with this patch is that it'll break the fair zone
> > allocation policy but it should be still fine as long as the working set
> > fits in memory. When the low watermark is constantly hit and the spread
> > is still even as before. However, the policy is still in force most of the
> > time. This is the allocation spread when running tiobench at 80% of memory
> > 
> >                             3.16.0-rc1  3.16.0-rc1  3.16.0-rc1       3.0.0
> >                                vanilla      cfq600    fairzone     vanilla
> > DMA32 allocs                  11099122    11020083     9459921     7698716
> > Normal allocs                 18823134    18801874    20429838    18787406
> > Movable allocs                       0           0           0           0
> > 
> > Note that the number of pages allocated from the Normal zone is still
> > comparable.
> 
> When you translate them to percentages, it rather looks like fairness
> is closer to pre-fairpolicy levels for this workload:
> 
>                              3.16.0-rc1  3.16.0-rc1  3.16.0-rc1       3.0.0
>                                 vanilla      cfq600    fairzone     vanilla
>  DMA32 allocs                     37.1%       37.0%       31.6%       29.1%
>  Normal allocs                    62.9%       63.0%       68.4%       70.9%
>  Movable allocs                      0%          0%          0%          0%
> 

I can re-examine it again. The key problem here is that once the low
watermark is reached that we can either adhere to the fair zone policy
and stall the allocator by dropping into the slow path and/or waiting for
kswapd to make progress or we can break the fair zone allocation policy,
make progress now and hope that reclaim does not cause problems later. That
is a bleak choice.

Ideally zones would go away altogether and LRU lists and alloctor paths
used the same list with overhead of additional scanning if pages from
a particular zone was required. That would remove the need for the fair
zone policy entirely. However, this would be a heavy reachitecting of the
current infrastructure and not guaranteed to work correctly.

> > @@ -1909,6 +1914,18 @@ static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
> >  
> >  #endif	/* CONFIG_NUMA */
> >  
> > +static void reset_alloc_batches(struct zone *preferred_zone)
> > +{
> > +	struct zone *zone = preferred_zone->zone_pgdat->node_zones;
> > +
> > +	do {
> > +		mod_zone_page_state(zone, NR_ALLOC_BATCH,
> > +			(zone->managed_pages >> 2) -
> > +			atomic_long_read(&zone->vm_stat[NR_ALLOC_BATCH]));
> > +		zone_clear_flag(zone, ZONE_FAIR_DEPLETED);
> > +	} while (zone++ != preferred_zone);
> 
> What is zone->managed_pages >> 2 based on?
> 

Magic number that would allow more progress to be made before switching
to the lower zone.

> The batch size was picked so that after all zones were used according
> to their size, they would also get reclaimed according to their size,
> and the cycle would start over.  This ensures that available memory is
> fully utilized and page lifetime stays independent of zone placement.
> 
> The page allocator depletes the zones to their low watermark, then
> kswapd restores them to their high watermark before the reclaim cycle
> starts over.  This means that a reclaim cycle is high - low watermark
> pages, which is reflected in the current round-robin batch sizes.
> 
> Now, we agree that the batches might drift from the actual reclaim
> cycle due to per-cpu counter inaccuracies, but it's still a better
> match for the reclaim cycle than "quarter zone size"...?
> 

Fair enough, I'll restore it. At the time the priority was to minimise
any cache effect from switching zones.

> > @@ -1926,8 +1943,11 @@ get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
> >  	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
> >  	bool consider_zone_dirty = (alloc_flags & ALLOC_WMARK_LOW) &&
> >  				(gfp_mask & __GFP_WRITE);
> > +	int nr_fair_skipped = 0, nr_fair_eligible = 0, nr_fail_watermark = 0;
> > +	bool zonelist_rescan;
> >  
> >  zonelist_scan:
> > +	zonelist_rescan = false;
> >  	/*
> >  	 * Scan zonelist, looking for a zone with enough free.
> >  	 * See also __cpuset_node_allowed_softwall() comment in kernel/cpuset.c.
> > @@ -1950,11 +1970,15 @@ zonelist_scan:
> >  		 * time the page has in memory before being reclaimed.
> >  		 */
> >  		if (alloc_flags & ALLOC_FAIR) {
> > -			if (!zone_local(preferred_zone, zone))
> > -				continue;
> > -			if (zone_page_state(zone, NR_ALLOC_BATCH) <= 0)
> > +			if (!zone_local(preferred_zone, zone) || !z->fair_enabled)
> > +				break;
> 
> The reason this was a "continue" rather than a "break" was because
> zonelists can be ordered by zone type, where a local zone can show up
> after a remote zone.  It might be worth rethinking the usefulness of
> zone-order in general, but it probably shouldn't be a silent side
> effect of a performance patch.
> 

I know that. Again, zone order is expected to preserve lower zones and
the fair zone allocation policy actually breaks that. This both restores
the expected behaviour of zone-ordered zonelists and reduces overhead.

> All in all, I still don't really understand exactly how your changes
> work and the changelog doesn't clarify much :( I'm just having a hard
> time seeing how you get 10%-20% performance increase for an IO-bound
> workload by making the allocator paths a little leaner.  Your results
> certainly show that you *are* improving this particular workload, but
> I think we should be clear on the mental model and then go from there.
> 

Mental model is that too much overhead in the allocator fast path builds
up over time. Second part is switching between free lists between zones
and skipping the preferred zone when the batch is depleted has a heavier
cache footprint which in turn has additional follow-on effects. Consider
for example that recently freed pages that are potentially cache hot may
get ignored by the fair zone allocation policy in favour of cache cold
pages in a lower zone. The exact impact of this would depend on the CPU
that did the freeing and whether cache was shared so analysing it in the
general sense would be prohibitive.

> I haven't managed to reproduce it locally yet, will continue to play
> around with the parameters.

Does that mean you have tried using tiobench and saw no effect or you
haven't run tiobench yet? FWIW, I've seen this impact on multiple machines.

These are the results from a laptop. cfq600 is patch 1 of this series and
fairzone is this patch so you're looking at the difference between those
kernels. I'm using 3.0 as the baseline to highlight the relative damage
in current kernels. I suspect in some cases that older kernels again would
have been better than 3.0.

tiobench MB/sec
                                           3.0.0            3.16.0-rc1            3.16.0-rc1            3.16.0-rc1
                                         vanilla               vanilla          cfq600-v2r38        fairzone-v2r38
Mean   SeqRead-MB/sec-1          94.82 (  0.00%)       85.03 (-10.32%)       85.02 (-10.34%)       97.33 (  2.65%)
Mean   SeqRead-MB/sec-2          78.22 (  0.00%)       67.55 (-13.64%)       69.06 (-11.71%)       76.63 ( -2.03%)
Mean   SeqRead-MB/sec-4          63.57 (  0.00%)       59.68 ( -6.11%)       63.61 (  0.07%)       70.91 ( 11.56%)
Mean   SeqRead-MB/sec-8          54.51 (  0.00%)       48.48 (-11.07%)       52.15 ( -4.32%)       55.42 (  1.66%)
Mean   SeqRead-MB/sec-16         46.43 (  0.00%)       44.42 ( -4.34%)       49.74 (  7.13%)       51.45 ( 10.80%)
Mean   RandRead-MB/sec-1          0.84 (  0.00%)        0.84 (  0.40%)        0.85 (  1.99%)        0.85 (  1.20%)
Mean   RandRead-MB/sec-2          1.01 (  0.00%)        0.99 ( -1.65%)        0.97 ( -3.63%)        1.00 ( -0.99%)
Mean   RandRead-MB/sec-4          1.16 (  0.00%)        1.23 (  6.34%)        1.20 (  3.46%)        1.17 (  1.15%)
Mean   RandRead-MB/sec-8          1.32 (  0.00%)        1.38 (  4.28%)        1.34 (  1.51%)        1.33 (  0.76%)
Mean   RandRead-MB/sec-16         1.32 (  0.00%)        1.38 (  4.81%)        1.35 (  2.28%)        1.42 (  7.59%)
Mean   SeqWrite-MB/sec-1         73.99 (  0.00%)       76.59 (  3.52%)       77.41 (  4.63%)       78.74 (  6.43%)
Mean   SeqWrite-MB/sec-2         65.83 (  0.00%)       67.45 (  2.47%)       67.52 (  2.57%)       68.14 (  3.51%)
Mean   SeqWrite-MB/sec-4         60.09 (  0.00%)       61.92 (  3.05%)       62.11 (  3.37%)       62.80 (  4.52%)
Mean   SeqWrite-MB/sec-8         51.98 (  0.00%)       54.18 (  4.23%)       54.11 (  4.10%)       54.62 (  5.07%)
Mean   SeqWrite-MB/sec-16        53.20 (  0.00%)       55.98 (  5.23%)       55.98 (  5.24%)       55.58 (  4.48%)
Mean   RandWrite-MB/sec-1         1.01 (  0.00%)        1.05 (  3.62%)        1.07 (  5.59%)        1.05 (  3.29%)
Mean   RandWrite-MB/sec-2         1.03 (  0.00%)        1.00 ( -3.23%)        1.04 (  0.32%)        1.06 (  2.90%)
Mean   RandWrite-MB/sec-4         0.98 (  0.00%)        1.01 (  3.75%)        0.99 (  1.02%)        1.01 (  3.75%)
Mean   RandWrite-MB/sec-8         0.93 (  0.00%)        0.96 (  3.24%)        0.93 (  0.72%)        0.93 (  0.36%)
Mean   RandWrite-MB/sec-16        0.91 (  0.00%)        0.91 (  0.37%)        0.91 ( -0.37%)        0.90 ( -0.73%)

The following is more a slightly better desktop that the machine used
for the changelog figures

tiobench MB/sec
                                           3.0.0            3.16.0-rc1            3.16.0-rc1            3.16.0-rc1
                                         vanilla               vanilla          cfq600-v2r38        fairzone-v2r38
Mean   SeqRead-MB/sec-1         136.66 (  0.00%)      125.09 ( -8.47%)      125.97 ( -7.82%)      135.60 ( -0.77%)
Mean   SeqRead-MB/sec-2         110.52 (  0.00%)       96.78 (-12.44%)       98.92 (-10.50%)      102.64 ( -7.14%)
Mean   SeqRead-MB/sec-4          91.20 (  0.00%)       83.55 ( -8.38%)       86.39 ( -5.27%)       90.74 ( -0.50%)
Mean   SeqRead-MB/sec-8          73.85 (  0.00%)       66.97 ( -9.32%)       72.63 ( -1.66%)       75.32 (  1.99%)
Mean   SeqRead-MB/sec-16         86.45 (  0.00%)       82.15 ( -4.97%)       94.01 (  8.75%)       95.35 ( 10.30%)
Mean   RandRead-MB/sec-1          0.94 (  0.00%)        0.92 ( -1.77%)        0.91 ( -3.19%)        0.93 ( -1.42%)
Mean   RandRead-MB/sec-2          1.07 (  0.00%)        1.05 ( -2.48%)        1.08 (  0.62%)        1.06 ( -0.93%)
Mean   RandRead-MB/sec-4          1.27 (  0.00%)        1.36 (  6.54%)        1.31 (  2.88%)        1.32 (  3.66%)
Mean   RandRead-MB/sec-8          1.35 (  0.00%)        1.41 (  4.20%)        1.49 ( 10.37%)        1.37 (  1.48%)
Mean   RandRead-MB/sec-16         1.68 (  0.00%)        1.74 (  3.17%)        1.77 (  4.95%)        1.72 (  2.18%)
Mean   SeqWrite-MB/sec-1        113.16 (  0.00%)      116.46 (  2.92%)      117.04 (  3.43%)      116.89 (  3.30%)
Mean   SeqWrite-MB/sec-2         96.55 (  0.00%)       94.06 ( -2.58%)       93.69 ( -2.96%)       93.84 ( -2.81%)
Mean   SeqWrite-MB/sec-4         81.35 (  0.00%)       81.98 (  0.77%)       81.84 (  0.59%)       81.69 (  0.41%)
Mean   SeqWrite-MB/sec-8         71.93 (  0.00%)       72.61 (  0.94%)       72.44 (  0.70%)       72.33 (  0.55%)
Mean   SeqWrite-MB/sec-16        94.22 (  0.00%)       96.61 (  2.54%)       96.83 (  2.77%)       96.87 (  2.81%)
Mean   RandWrite-MB/sec-1         1.07 (  0.00%)        1.12 (  4.35%)        1.09 (  1.55%)        1.10 (  2.80%)
Mean   RandWrite-MB/sec-2         1.06 (  0.00%)        1.07 (  0.63%)        1.06 (  0.00%)        1.05 ( -1.26%)
Mean   RandWrite-MB/sec-4         1.03 (  0.00%)        1.01 ( -2.58%)        1.03 ( -0.00%)        1.03 ( -0.32%)
Mean   RandWrite-MB/sec-8         0.98 (  0.00%)        0.99 (  1.71%)        0.98 (  0.00%)        0.98 (  0.34%)
Mean   RandWrite-MB/sec-16        1.02 (  0.00%)        1.03 (  1.31%)        1.02 (  0.66%)        1.01 ( -0.66%)

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
