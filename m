Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E168A6B254C
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 09:18:32 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id t2so3024869edb.22
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 06:18:32 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a15si7895395edc.169.2018.11.21.06.18.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 06:18:30 -0800 (PST)
Subject: Re: [PATCH 1/4] mm, page_alloc: Spread allocations across zones
 before introducing fragmentation
References: <20181121101414.21301-1-mgorman@techsingularity.net>
 <20181121101414.21301-2-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <7c053d34-fd3f-ca10-6ad7-a9d85652626f@suse.cz>
Date: Wed, 21 Nov 2018 15:18:28 +0100
MIME-Version: 1.0
In-Reply-To: <20181121101414.21301-2-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Linux-MM <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On 11/21/18 11:14 AM, Mel Gorman wrote:
> The page allocator zone lists are iterated based on the watermarks
> of each zone which does not take anti-fragmentation into account. On
> x86, node 0 may have multiple zones while other nodes have one zone. A
> consequence is that tasks running on node 0 may fragment ZONE_NORMAL even
> though ZONE_DMA32 has plenty of free memory. This patch special cases
> the allocator fast path such that it'll try an allocation from a lower
> local zone before fragmenting a higher zone. In this case, stealing of
> pageblocks or orders larger than a pageblock are still allowed in the
> fast path as they are uninteresting from a fragmentation point of view.
> 
> This was evaluated using a benchmark designed to fragment memory
> before attempting THPs.  It's implemented in mmtests as the following
> configurations
> 
> configs/config-global-dhp__workload_thpfioscale
> configs/config-global-dhp__workload_thpfioscale-defrag
> configs/config-global-dhp__workload_thpfioscale-madvhugepage
> 
> e.g. from mmtests
> ./run-mmtests.sh --run-monitor --config configs/config-global-dhp__workload_thpfioscale test-run-1
> 
> The broad details of the workload are as follows;
> 
> 1. Create an XFS filesystem (not specified in the configuration but done
>    as part of the testing for this patch)
> 2. Start 4 fio threads that write a number of 64K files inefficiently.
>    Inefficiently means that files are created on first access and not
>    created in advance (fio parameterr create_on_open=1) and fallocate
>    is not used (fallocate=none). With multiple IO issuers this creates
>    a mix of slab and page cache allocations over time. The total size
>    of the files is 150% physical memory so that the slabs and page cache
>    pages get mixed
> 3. Warm up a number of fio read-only threads accessing the same files
>    created in step 2. This part runs for the same length of time it
>    took to create the files. It'll fault back in old data and further
>    interleave slab and page cache allocations. As it's now low on
>    memory due to step 2, fragmentation occurs as pageblocks get
>    stolen.
> 4. While step 3 is still running, start a process that tries to allocate
>    75% of memory as huge pages with a number of threads. The number of
>    threads is based on a (NR_CPUS_SOCKET - NR_FIO_THREADS)/4 to avoid THP
>    threads contending with fio, any other threads or forcing cross-NUMA
>    scheduling. Note that the test has not been used on a machine with less
>    than 8 cores. The benchmark records whether huge pages were allocated
>    and what the fault latency was in microseconds
> 5. Measure the number of events potentially causing external fragmentation,
>    the fault latency and the huge page allocation success rate.
> 6. Cleanup
> 
> Note that due to the use of IO and page cache that this benchmark is not
> suitable for running on large machines where the time to fragment memory
> may be excessive. Also note that while this is one mix that generates
> fragmentation that it's not the only mix that generates fragmentation.
> Differences in workload that are more slab-intensive or whether SLUB is
> used with high-order pages may yield different results.
> 
> When the page allocator fragments memory, it records the event using the
> mm_page_alloc_extfrag event. If the fallback_order is smaller than a
> pageblock order (order-9 on 64-bit x86) then it's considered an event
> that may cause external fragmentation issues in the future. Hence, the
> primary metric here is the number of external fragmentation events that
> occur with order < 9. The secondary metric is allocation latency and huge
> page allocation success rates but note that differences in latencies and
> what the success rate also can affect the number of external fragmentation
> event which is why it's a secondary metric.
> 
> 1-socket Skylake machine
> config-global-dhp__workload_thpfioscale XFS (no special madvise)
> 4 fio threads, 1 THP allocating thread
> --------------------------------------
> 
> 4.20-rc1 extfrag events < order 9:  1023463
> 4.20-rc1+patch:                      358574 (65% reduction)

It would be nice to have also breakdown of what kind of extfrag events,
mainly distinguish number of unmovable/reclaimable allocations
fragmenting movable pageblocks, as those are the most critical ones.

...

> @@ -3253,6 +3268,36 @@ static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
>  }
>  #endif	/* CONFIG_NUMA */
>  
> +#ifdef CONFIG_ZONE_DMA32
> +/*
> + * The restriction on ZONE_DMA32 as being a suitable zone to use to avoid
> + * fragmentation is subtle. If the preferred zone was HIGHMEM then
> + * premature use of a lower zone may cause lowmem pressure problems that
> + * are wose than fragmentation. If the next zone is ZONE_DMA then it is
> + * probably too small. It only makes sense to spread allocations to avoid
> + * fragmentation between the Normal and DMA32 zones.
> + */
> +static inline unsigned int alloc_flags_nofragment(struct zone *zone)
> +{
> +	if (zone_idx(zone) != ZONE_NORMAL)
> +		return 0;
> +
> +	/*
> +	 * If ZONE_DMA32 exists, assume it is the one after ZONE_NORMAL and
> +	 * the pointer is within zone->zone_pgdat->node_zones[].
> +	 */
> +	if (!populated_zone(--zone))
> +		return 0;

How about something along:
BUILD_BUG_ON(ZONE_NORMAL - ZONE_DMA32 != 1);

Also is this perhaps going against your earlier efforts of speeding up
the fast path, and maybe it would be faster to just stick a bool into
struct zone, which would be set true once during zonelist build, only
for a ZONE_NORMAL with ZONE_DMA32 in the same node?

> +
> +	return ALLOC_NOFRAGMENT;
> +}
> +#else
> +static inline unsigned int alloc_flags_nofragment(struct zone *zone)
> +{
> +	return 0;
> +}
> +#endif
> +
>  /*
>   * get_page_from_freelist goes through the zonelist trying to allocate
>   * a page.
> @@ -3264,11 +3309,14 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
>  	struct zoneref *z = ac->preferred_zoneref;
>  	struct zone *zone;
>  	struct pglist_data *last_pgdat_dirty_limit = NULL;
> +	bool no_fallback;
>  
> +retry:

Ugh, I think 'z = ac->preferred_zoneref' should be moved here under
retry. AFAICS without that, the preference of local node to
fragmentation avoidance doesn't work?

>  	/*
>  	 * Scan zonelist, looking for a zone with enough free.
>  	 * See also __cpuset_node_allowed() comment in kernel/cpuset.c.
>  	 */
> +	no_fallback = alloc_flags & ALLOC_NOFRAGMENT;
>  	for_next_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx,
>  								ac->nodemask) {
>  		struct page *page;
> @@ -3307,6 +3355,21 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
>  			}
>  		}
>  
> +		if (no_fallback) {
> +			int local_nid;
> +
> +			/*
> +			 * If moving to a remote node, retry but allow
> +			 * fragmenting fallbacks. Locality is more important
> +			 * than fragmentation avoidance.
> +			 */
> +			local_nid = zone_to_nid(ac->preferred_zoneref->zone);
> +			if (zone_to_nid(zone) != local_nid) {
> +				alloc_flags &= ~ALLOC_NOFRAGMENT;
> +				goto retry;
> +			}
> +		}
> +
>  		mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
>  		if (!zone_watermark_fast(zone, order, mark,
>  				       ac_classzone_idx(ac), alloc_flags)) {
> @@ -3374,6 +3437,15 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
>  		}
>  	}
>  
> +	/*
> +	 * It's possible on a UMA machine to get through all zones that are
> +	 * fragmented. If avoiding fragmentation, reset and try again
> +	 */
> +	if (no_fallback) {
> +		alloc_flags &= ~ALLOC_NOFRAGMENT;
> +		goto retry;
> +	}
> +
>  	return NULL;
>  }
>  
> @@ -4369,6 +4441,12 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
>  
>  	finalise_ac(gfp_mask, &ac);
>  
> +	/*
> +	 * Forbid the first pass from falling back to types that fragment
> +	 * memory until all local zones are considered.
> +	 */
> +	alloc_flags |= alloc_flags_nofragment(ac.preferred_zoneref->zone);
> +
>  	/* First allocation attempt */
>  	page = get_page_from_freelist(alloc_mask, order, alloc_flags, &ac);
>  	if (likely(page))
> 
