Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 64B0E6B0031
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 16:01:37 -0400 (EDT)
Received: by mail-wg0-f42.google.com with SMTP id z12so1326284wgg.25
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 13:01:36 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id sh2si17970987wic.40.2014.06.18.13.01.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Jun 2014 13:01:35 -0700 (PDT)
Date: Wed, 18 Jun 2014 16:01:29 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/4] mm: page_alloc: Reset fair zone allocation policy
 when batch counts are expired
Message-ID: <20140618200129.GD7331@cmpxchg.org>
References: <1403079807-24690-1-git-send-email-mgorman@suse.de>
 <1403079807-24690-4-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1403079807-24690-4-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>

Hi Mel,

On Wed, Jun 18, 2014 at 09:23:26AM +0100, Mel Gorman wrote:
> The fair zone allocation policy round-robins allocations between zones
> within a node to avoid age inversion problems during reclaim. If the
> first allocation fails, the batch counts is reset and a second attempt
> made before entering the slow path.
> 
> One assumption made with this scheme is that batches expire at roughly the
> same time and the resets each time are justified. This assumption does not
> hold when zones reach their low watermark as the batches will be consumed
> at uneven rates.
>
> Allocation failure due to watermark depletion result in
> additional zonelist scans for the reset and another watermark check before
> hitting the slowpath.

Yes, one consequence of the changes in 3a025760fc15 ("mm: page_alloc:
spill to remote nodes before waking kswapd") is that on single-node
systems we have one useless spill cycle to non-existent remote nodes.

Your patch adds a nr_online_nodes check, but it also does another
zonelist scan if any watermark breaches were detected in the first
cycle, so I don't see how you actually fix this issue?

> On large NUMA machines, the scanning overhead is higher as zones are
> scanned that are ineligible for zone allocation policy.

I'm not sure we can use your fix for that because of zone-order
zonelists, see inline comments below.

> This patch makes a number of changes which are all related to each
> other. First and foremost, the patch resets the fair zone policy counts when
> all the counters are depleted,

You also still reset them if any of the low watermarks are breached,
so the only time we *would* save a reset cycle now is when all
considered watermarks are fine and there are still some non-depleted
batches - but in this case the allocation would have succeeded...?

> avoids scanning remote nodes unnecessarily

I don't see how we are scanning them unnecessarily now.

> and reduces the frequency that resets are required.

How?

It would be good to start with an analysis of the problem(s) and then
propose a solution based on that, otherwise it makes it very hard to
follow your thought process, and especially match these rather broad
statements to the code when you change multiple things at once.

> Second, when the fair zone batch counter is expired, the zone is
> flagged which has a lighter cache footprint than accessing the
> counters. Lastly, if the local node has only one zone then the fair
> zone allocation policy is not applied to reduce overall overhead.

These two are plausible, but they also make the code harder to
understand and their performance impact is not represented in your
test results, so we can't compare cost and value.

> Comparison is tiobench with data size 2*RAM on a small single-node machine
> and on an ext3 filesystem although it is known that ext4 sees similar gains.
> I'm reporting sequental reads only as the other operations are essentially
> flat.
> 
>                                       3.16.0-rc1            3.16.0-rc1            3.16.0-rc1                 3.0.0
>                                          vanilla          cfq600              fairzone                     vanilla
> Mean   SeqRead-MB/sec-1         121.88 (  0.00%)      121.60 ( -0.23%)      131.68 (  8.04%)      134.59 ( 10.42%)
> Mean   SeqRead-MB/sec-2         101.99 (  0.00%)      102.35 (  0.36%)      113.24 ( 11.04%)      122.59 ( 20.20%)
> Mean   SeqRead-MB/sec-4          97.42 (  0.00%)       99.71 (  2.35%)      107.43 ( 10.28%)      114.78 ( 17.82%)
> Mean   SeqRead-MB/sec-8          83.39 (  0.00%)       90.39 (  8.39%)       96.81 ( 16.09%)      100.14 ( 20.09%)
> Mean   SeqRead-MB/sec-16         68.90 (  0.00%)       77.29 ( 12.18%)       81.88 ( 18.85%)       81.64 ( 18.50%)
> 
> Where as the CFQ patch helped throughput for higher number of threads, this
> patch (fairzone) whos performance increases for all thread counts and brings
> performance much closer to 3.0-vanilla. Note that performance can be further
> increased by tuning CFQ but the latencies of read operations are then higher
> but from the IO stats they are still acceptable.
> 
>                   3.16.0-rc1  3.16.0-rc1  3.16.0-rc1       3.0.0
>                      vanilla      cfq600    fairzone     vanilla
> Mean sda-avgqz        912.29      939.89      947.90     1000.70
> Mean sda-await       4268.03     4403.99     4450.89     4887.67
> Mean sda-r_await       79.42       80.33       81.34      108.53
> Mean sda-w_await    13073.49    11038.81    13217.25    11599.83
> Max  sda-avgqz       2194.84     2215.01     2307.48     2626.78
> Max  sda-await      18157.88    17586.08    14189.21    24971.00
> Max  sda-r_await      888.40      874.22      800.80     5308.00
> Max  sda-w_await   212563.59   190265.33   173295.33   177698.47
> 
> The primary concern with this patch is that it'll break the fair zone
> allocation policy but it should be still fine as long as the working set
> fits in memory. When the low watermark is constantly hit and the spread
> is still even as before. However, the policy is still in force most of the
> time. This is the allocation spread when running tiobench at 80% of memory
> 
>                             3.16.0-rc1  3.16.0-rc1  3.16.0-rc1       3.0.0
>                                vanilla      cfq600    fairzone     vanilla
> DMA32 allocs                  11099122    11020083     9459921     7698716
> Normal allocs                 18823134    18801874    20429838    18787406
> Movable allocs                       0           0           0           0
> 
> Note that the number of pages allocated from the Normal zone is still
> comparable.

When you translate them to percentages, it rather looks like fairness
is closer to pre-fairpolicy levels for this workload:

                             3.16.0-rc1  3.16.0-rc1  3.16.0-rc1       3.0.0
                                vanilla      cfq600    fairzone     vanilla
 DMA32 allocs                     37.1%       37.0%       31.6%       29.1%
 Normal allocs                    62.9%       63.0%       68.4%       70.9%
 Movable allocs                      0%          0%          0%          0%

> @@ -1909,6 +1914,18 @@ static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
>  
>  #endif	/* CONFIG_NUMA */
>  
> +static void reset_alloc_batches(struct zone *preferred_zone)
> +{
> +	struct zone *zone = preferred_zone->zone_pgdat->node_zones;
> +
> +	do {
> +		mod_zone_page_state(zone, NR_ALLOC_BATCH,
> +			(zone->managed_pages >> 2) -
> +			atomic_long_read(&zone->vm_stat[NR_ALLOC_BATCH]));
> +		zone_clear_flag(zone, ZONE_FAIR_DEPLETED);
> +	} while (zone++ != preferred_zone);

What is zone->managed_pages >> 2 based on?

The batch size was picked so that after all zones were used according
to their size, they would also get reclaimed according to their size,
and the cycle would start over.  This ensures that available memory is
fully utilized and page lifetime stays independent of zone placement.

The page allocator depletes the zones to their low watermark, then
kswapd restores them to their high watermark before the reclaim cycle
starts over.  This means that a reclaim cycle is high - low watermark
pages, which is reflected in the current round-robin batch sizes.

Now, we agree that the batches might drift from the actual reclaim
cycle due to per-cpu counter inaccuracies, but it's still a better
match for the reclaim cycle than "quarter zone size"...?

> @@ -1926,8 +1943,11 @@ get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
>  	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
>  	bool consider_zone_dirty = (alloc_flags & ALLOC_WMARK_LOW) &&
>  				(gfp_mask & __GFP_WRITE);
> +	int nr_fair_skipped = 0, nr_fair_eligible = 0, nr_fail_watermark = 0;
> +	bool zonelist_rescan;
>  
>  zonelist_scan:
> +	zonelist_rescan = false;
>  	/*
>  	 * Scan zonelist, looking for a zone with enough free.
>  	 * See also __cpuset_node_allowed_softwall() comment in kernel/cpuset.c.
> @@ -1950,11 +1970,15 @@ zonelist_scan:
>  		 * time the page has in memory before being reclaimed.
>  		 */
>  		if (alloc_flags & ALLOC_FAIR) {
> -			if (!zone_local(preferred_zone, zone))
> -				continue;
> -			if (zone_page_state(zone, NR_ALLOC_BATCH) <= 0)
> +			if (!zone_local(preferred_zone, zone) || !z->fair_enabled)
> +				break;

The reason this was a "continue" rather than a "break" was because
zonelists can be ordered by zone type, where a local zone can show up
after a remote zone.  It might be worth rethinking the usefulness of
zone-order in general, but it probably shouldn't be a silent side
effect of a performance patch.

All in all, I still don't really understand exactly how your changes
work and the changelog doesn't clarify much :( I'm just having a hard
time seeing how you get 10%-20% performance increase for an IO-bound
workload by making the allocator paths a little leaner.  Your results
certainly show that you *are* improving this particular workload, but
I think we should be clear on the mental model and then go from there.

I haven't managed to reproduce it locally yet, will continue to play
around with the parameters.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
