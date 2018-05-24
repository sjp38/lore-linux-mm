Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9192C6B0006
	for <linux-mm@kvack.org>; Thu, 24 May 2018 07:28:51 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id d4-v6so830866plr.17
        for <linux-mm@kvack.org>; Thu, 24 May 2018 04:28:51 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n125-v6si21044323pfn.352.2018.05.24.04.28.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 May 2018 04:28:49 -0700 (PDT)
Date: Thu, 24 May 2018 13:28:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] Revert "mm/cma: manage the memory of the CMA area by
 using the ZONE_MOVABLE"
Message-ID: <20180524112845.GC20441@dhcp22.suse.cz>
References: <1527038301-24368-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1527038301-24368-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Laura Abbott <lauraa@codeaurora.org>, Ville =?iso-8859-1?Q?Syrj=E4l=E4?= <ville.syrjala@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Wed 23-05-18 10:18:21, Joonsoo Kim wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> This reverts the following commits that change CMA design in MM.
> 
> Revert "ARM: CMA: avoid double mapping to the CMA area if CONFIG_HIGHMEM=y"
> This reverts commit 3d2054ad8c2d5100b68b0c0405f89fd90bf4107b.
> 
> Revert "mm/cma: remove ALLOC_CMA"
> This reverts commit 1d47a3ec09b5489cd915e8f492aa623cdab5d002.
> 
> Revert "mm/cma: manage the memory of the CMA area by using the ZONE_MOVABLE"
> This reverts commit bad8c6c0b1144694ecb0bc5629ede9b8b578b86e.
> 
> Ville reported a following error on i386.
> 
> [    0.000000] Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
> [    0.000000] microcode: microcode updated early to revision 0x4, date = 2013-06-28
> [    0.000000] Initializing CPU#0
> [    0.000000] Initializing HighMem for node 0 (000377fe:00118000)
> [    0.000000] Initializing Movable for node 0 (00000001:00118000)
> [    0.000000] BUG: Bad page state in process swapper  pfn:377fe
> [    0.000000] page:f53effc0 count:0 mapcount:-127 mapping:00000000 index:0x0
> [    0.000000] flags: 0x80000000()
> [    0.000000] raw: 80000000 00000000 00000000 ffffff80 00000000 00000100 00000200 00000001
> [    0.000000] page dumped because: nonzero mapcount
> [    0.000000] Modules linked in:
> [    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 4.17.0-rc5-elk+ #145
> [    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
> [    0.000000] Call Trace:
> [    0.000000]  dump_stack+0x60/0x96
> [    0.000000]  bad_page+0x9a/0x100
> [    0.000000]  free_pages_check_bad+0x3f/0x60
> [    0.000000]  free_pcppages_bulk+0x29d/0x5b0
> [    0.000000]  free_unref_page_commit+0x84/0xb0
> [    0.000000]  free_unref_page+0x3e/0x70
> [    0.000000]  __free_pages+0x1d/0x20
> [    0.000000]  free_highmem_page+0x19/0x40
> [    0.000000]  add_highpages_with_active_regions+0xab/0xeb
> [    0.000000]  set_highmem_pages_init+0x66/0x73
> [    0.000000]  mem_init+0x1b/0x1d7
> [    0.000000]  start_kernel+0x17a/0x363
> [    0.000000]  i386_start_kernel+0x95/0x99
> [    0.000000]  startup_32_smp+0x164/0x168
> 
> Reason for this error is that the span of MOVABLE_ZONE is extended to
> whole node span for future CMA initialization, and, normal memory is
> wrongly freed here. I submitted the fix and it seems to work, but,
> the other problem happened. It's so late time to fix the later problem
> so I decide to reverting the series.
> 
> Reported-by: Ville Syrjala <ville.syrjala@linux.intel.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

OK, if the fix is not straightforward then the revert is the right way
to go.

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  arch/arm/mm/dma-mapping.c      | 16 +-------
>  include/linux/memory_hotplug.h |  3 ++
>  include/linux/mm.h             |  1 -
>  mm/cma.c                       | 83 ++++++------------------------------------
>  mm/compaction.c                |  4 +-
>  mm/internal.h                  |  4 +-
>  mm/page_alloc.c                | 83 +++++++++++++++---------------------------
>  7 files changed, 49 insertions(+), 145 deletions(-)
> 
> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> index 8c398fe..ada8eb2 100644
> --- a/arch/arm/mm/dma-mapping.c
> +++ b/arch/arm/mm/dma-mapping.c
> @@ -466,12 +466,6 @@ void __init dma_contiguous_early_fixup(phys_addr_t base, unsigned long size)
>  void __init dma_contiguous_remap(void)
>  {
>  	int i;
> -
> -	if (!dma_mmu_remap_num)
> -		return;
> -
> -	/* call flush_cache_all() since CMA area would be large enough */
> -	flush_cache_all();
>  	for (i = 0; i < dma_mmu_remap_num; i++) {
>  		phys_addr_t start = dma_mmu_remap[i].base;
>  		phys_addr_t end = start + dma_mmu_remap[i].size;
> @@ -504,15 +498,7 @@ void __init dma_contiguous_remap(void)
>  		flush_tlb_kernel_range(__phys_to_virt(start),
>  				       __phys_to_virt(end));
>  
> -		/*
> -		 * All the memory in CMA region will be on ZONE_MOVABLE.
> -		 * If that zone is considered as highmem, the memory in CMA
> -		 * region is also considered as highmem even if it's
> -		 * physical address belong to lowmem. In this case,
> -		 * re-mapping isn't required.
> -		 */
> -		if (!is_highmem_idx(ZONE_MOVABLE))
> -			iotable_init(&map, 1);
> +		iotable_init(&map, 1);
>  	}
>  }
>  
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index e0e49b5..2b02652 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -216,6 +216,9 @@ void put_online_mems(void);
>  void mem_hotplug_begin(void);
>  void mem_hotplug_done(void);
>  
> +extern void set_zone_contiguous(struct zone *zone);
> +extern void clear_zone_contiguous(struct zone *zone);
> +
>  #else /* ! CONFIG_MEMORY_HOTPLUG */
>  #define pfn_to_online_page(pfn)			\
>  ({						\
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index c6fa9a2..02a616e 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2109,7 +2109,6 @@ extern void setup_per_cpu_pageset(void);
>  
>  extern void zone_pcp_update(struct zone *zone);
>  extern void zone_pcp_reset(struct zone *zone);
> -extern void setup_zone_pageset(struct zone *zone);
>  
>  /* page_alloc.c */
>  extern int min_free_kbytes;
> diff --git a/mm/cma.c b/mm/cma.c
> index aa40e6c..5809bbe 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -39,7 +39,6 @@
>  #include <trace/events/cma.h>
>  
>  #include "cma.h"
> -#include "internal.h"
>  
>  struct cma cma_areas[MAX_CMA_AREAS];
>  unsigned cma_area_count;
> @@ -110,25 +109,23 @@ static int __init cma_activate_area(struct cma *cma)
>  	if (!cma->bitmap)
>  		return -ENOMEM;
>  
> +	WARN_ON_ONCE(!pfn_valid(pfn));
> +	zone = page_zone(pfn_to_page(pfn));
> +
>  	do {
>  		unsigned j;
>  
>  		base_pfn = pfn;
> -		if (!pfn_valid(base_pfn))
> -			goto err;
> -
> -		zone = page_zone(pfn_to_page(base_pfn));
>  		for (j = pageblock_nr_pages; j; --j, pfn++) {
> -			if (!pfn_valid(pfn))
> -				goto err;
> -
> +			WARN_ON_ONCE(!pfn_valid(pfn));
>  			/*
> -			 * In init_cma_reserved_pageblock(), present_pages
> -			 * is adjusted with assumption that all pages in
> -			 * the pageblock come from a single zone.
> +			 * alloc_contig_range requires the pfn range
> +			 * specified to be in the same zone. Make this
> +			 * simple by forcing the entire CMA resv range
> +			 * to be in the same zone.
>  			 */
>  			if (page_zone(pfn_to_page(pfn)) != zone)
> -				goto err;
> +				goto not_in_zone;
>  		}
>  		init_cma_reserved_pageblock(pfn_to_page(base_pfn));
>  	} while (--i);
> @@ -142,7 +139,7 @@ static int __init cma_activate_area(struct cma *cma)
>  
>  	return 0;
>  
> -err:
> +not_in_zone:
>  	pr_err("CMA area %s could not be activated\n", cma->name);
>  	kfree(cma->bitmap);
>  	cma->count = 0;
> @@ -152,41 +149,6 @@ static int __init cma_activate_area(struct cma *cma)
>  static int __init cma_init_reserved_areas(void)
>  {
>  	int i;
> -	struct zone *zone;
> -	pg_data_t *pgdat;
> -
> -	if (!cma_area_count)
> -		return 0;
> -
> -	for_each_online_pgdat(pgdat) {
> -		unsigned long start_pfn = UINT_MAX, end_pfn = 0;
> -
> -		zone = &pgdat->node_zones[ZONE_MOVABLE];
> -
> -		/*
> -		 * In this case, we cannot adjust the zone range
> -		 * since it is now maximum node span and we don't
> -		 * know original zone range.
> -		 */
> -		if (populated_zone(zone))
> -			continue;
> -
> -		for (i = 0; i < cma_area_count; i++) {
> -			if (pfn_to_nid(cma_areas[i].base_pfn) !=
> -				pgdat->node_id)
> -				continue;
> -
> -			start_pfn = min(start_pfn, cma_areas[i].base_pfn);
> -			end_pfn = max(end_pfn, cma_areas[i].base_pfn +
> -						cma_areas[i].count);
> -		}
> -
> -		if (!end_pfn)
> -			continue;
> -
> -		zone->zone_start_pfn = start_pfn;
> -		zone->spanned_pages = end_pfn - start_pfn;
> -	}
>  
>  	for (i = 0; i < cma_area_count; i++) {
>  		int ret = cma_activate_area(&cma_areas[i]);
> @@ -195,32 +157,9 @@ static int __init cma_init_reserved_areas(void)
>  			return ret;
>  	}
>  
> -	/*
> -	 * Reserved pages for ZONE_MOVABLE are now activated and
> -	 * this would change ZONE_MOVABLE's managed page counter and
> -	 * the other zones' present counter. We need to re-calculate
> -	 * various zone information that depends on this initialization.
> -	 */
> -	build_all_zonelists(NULL);
> -	for_each_populated_zone(zone) {
> -		if (zone_idx(zone) == ZONE_MOVABLE) {
> -			zone_pcp_reset(zone);
> -			setup_zone_pageset(zone);
> -		} else
> -			zone_pcp_update(zone);
> -
> -		set_zone_contiguous(zone);
> -	}
> -
> -	/*
> -	 * We need to re-init per zone wmark by calling
> -	 * init_per_zone_wmark_min() but doesn't call here because it is
> -	 * registered on core_initcall and it will be called later than us.
> -	 */
> -
>  	return 0;
>  }
> -pure_initcall(cma_init_reserved_areas);
> +core_initcall(cma_init_reserved_areas);
>  
>  /**
>   * cma_init_reserved_mem() - create custom contiguous area from reserved memory
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 028b721..29bd1df 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1450,12 +1450,14 @@ static enum compact_result __compaction_suitable(struct zone *zone, int order,
>  	 * if compaction succeeds.
>  	 * For costly orders, we require low watermark instead of min for
>  	 * compaction to proceed to increase its chances.
> +	 * ALLOC_CMA is used, as pages in CMA pageblocks are considered
> +	 * suitable migration targets
>  	 */
>  	watermark = (order > PAGE_ALLOC_COSTLY_ORDER) ?
>  				low_wmark_pages(zone) : min_wmark_pages(zone);
>  	watermark += compact_gap(order);
>  	if (!__zone_watermark_ok(zone, 0, watermark, classzone_idx,
> -						0, wmark_target))
> +						ALLOC_CMA, wmark_target))
>  		return COMPACT_SKIPPED;
>  
>  	return COMPACT_CONTINUE;
> diff --git a/mm/internal.h b/mm/internal.h
> index 62d8c34..502d141 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -168,9 +168,6 @@ extern void post_alloc_hook(struct page *page, unsigned int order,
>  					gfp_t gfp_flags);
>  extern int user_min_free_kbytes;
>  
> -extern void set_zone_contiguous(struct zone *zone);
> -extern void clear_zone_contiguous(struct zone *zone);
> -
>  #if defined CONFIG_COMPACTION || defined CONFIG_CMA
>  
>  /*
> @@ -498,6 +495,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
>  #define ALLOC_HARDER		0x10 /* try to alloc harder */
>  #define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
>  #define ALLOC_CPUSET		0x40 /* check for correct cpuset */
> +#define ALLOC_CMA		0x80 /* allow allocations from CMA areas */
>  
>  enum ttu_flags;
>  struct tlbflush_unmap_batch;
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 905db9d..511a712 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1743,38 +1743,16 @@ void __init page_alloc_init_late(void)
>  }
>  
>  #ifdef CONFIG_CMA
> -static void __init adjust_present_page_count(struct page *page, long count)
> -{
> -	struct zone *zone = page_zone(page);
> -
> -	/* We don't need to hold a lock since it is boot-up process */
> -	zone->present_pages += count;
> -}
> -
>  /* Free whole pageblock and set its migration type to MIGRATE_CMA. */
>  void __init init_cma_reserved_pageblock(struct page *page)
>  {
>  	unsigned i = pageblock_nr_pages;
> -	unsigned long pfn = page_to_pfn(page);
>  	struct page *p = page;
> -	int nid = page_to_nid(page);
> -
> -	/*
> -	 * ZONE_MOVABLE will steal present pages from other zones by
> -	 * changing page links so page_zone() is changed. Before that,
> -	 * we need to adjust previous zone's page count first.
> -	 */
> -	adjust_present_page_count(page, -pageblock_nr_pages);
>  
>  	do {
>  		__ClearPageReserved(p);
>  		set_page_count(p, 0);
> -
> -		/* Steal pages from other zones */
> -		set_page_links(p, ZONE_MOVABLE, nid, pfn);
> -	} while (++p, ++pfn, --i);
> -
> -	adjust_present_page_count(page, pageblock_nr_pages);
> +	} while (++p, --i);
>  
>  	set_pageblock_migratetype(page, MIGRATE_CMA);
>  
> @@ -2889,7 +2867,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
>  		 * exists.
>  		 */
>  		watermark = min_wmark_pages(zone) + (1UL << order);
> -		if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
> +		if (!zone_watermark_ok(zone, 0, watermark, 0, ALLOC_CMA))
>  			return 0;
>  
>  		__mod_zone_freepage_state(zone, -(1UL << order), mt);
> @@ -3165,6 +3143,12 @@ bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
>  	}
>  
>  
> +#ifdef CONFIG_CMA
> +	/* If allocation can't use CMA areas don't use free CMA pages */
> +	if (!(alloc_flags & ALLOC_CMA))
> +		free_pages -= zone_page_state(z, NR_FREE_CMA_PAGES);
> +#endif
> +
>  	/*
>  	 * Check watermarks for an order-0 allocation request. If these
>  	 * are not met, then a high-order request also cannot go ahead
> @@ -3191,8 +3175,10 @@ bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
>  		}
>  
>  #ifdef CONFIG_CMA
> -		if (!list_empty(&area->free_list[MIGRATE_CMA]))
> +		if ((alloc_flags & ALLOC_CMA) &&
> +		    !list_empty(&area->free_list[MIGRATE_CMA])) {
>  			return true;
> +		}
>  #endif
>  		if (alloc_harder &&
>  			!list_empty(&area->free_list[MIGRATE_HIGHATOMIC]))
> @@ -3212,6 +3198,13 @@ static inline bool zone_watermark_fast(struct zone *z, unsigned int order,
>  		unsigned long mark, int classzone_idx, unsigned int alloc_flags)
>  {
>  	long free_pages = zone_page_state(z, NR_FREE_PAGES);
> +	long cma_pages = 0;
> +
> +#ifdef CONFIG_CMA
> +	/* If allocation can't use CMA areas don't use free CMA pages */
> +	if (!(alloc_flags & ALLOC_CMA))
> +		cma_pages = zone_page_state(z, NR_FREE_CMA_PAGES);
> +#endif
>  
>  	/*
>  	 * Fast check for order-0 only. If this fails then the reserves
> @@ -3220,7 +3213,7 @@ static inline bool zone_watermark_fast(struct zone *z, unsigned int order,
>  	 * the caller is !atomic then it'll uselessly search the free
>  	 * list. That corner case is then slower but it is harmless.
>  	 */
> -	if (!order && free_pages > mark + z->lowmem_reserve[classzone_idx])
> +	if (!order && (free_pages - cma_pages) > mark + z->lowmem_reserve[classzone_idx])
>  		return true;
>  
>  	return __zone_watermark_ok(z, order, mark, classzone_idx, alloc_flags,
> @@ -3856,6 +3849,10 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
>  	} else if (unlikely(rt_task(current)) && !in_interrupt())
>  		alloc_flags |= ALLOC_HARDER;
>  
> +#ifdef CONFIG_CMA
> +	if (gfpflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
> +		alloc_flags |= ALLOC_CMA;
> +#endif
>  	return alloc_flags;
>  }
>  
> @@ -4322,6 +4319,9 @@ static inline bool prepare_alloc_pages(gfp_t gfp_mask, unsigned int order,
>  	if (should_fail_alloc_page(gfp_mask, order))
>  		return false;
>  
> +	if (IS_ENABLED(CONFIG_CMA) && ac->migratetype == MIGRATE_MOVABLE)
> +		*alloc_flags |= ALLOC_CMA;
> +
>  	return true;
>  }
>  
> @@ -6204,7 +6204,6 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
>  {
>  	enum zone_type j;
>  	int nid = pgdat->node_id;
> -	unsigned long node_end_pfn = 0;
>  
>  	pgdat_resize_init(pgdat);
>  #ifdef CONFIG_NUMA_BALANCING
> @@ -6232,13 +6231,9 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
>  		struct zone *zone = pgdat->node_zones + j;
>  		unsigned long size, realsize, freesize, memmap_pages;
>  		unsigned long zone_start_pfn = zone->zone_start_pfn;
> -		unsigned long movable_size = 0;
>  
>  		size = zone->spanned_pages;
>  		realsize = freesize = zone->present_pages;
> -		if (zone_end_pfn(zone) > node_end_pfn)
> -			node_end_pfn = zone_end_pfn(zone);
> -
>  
>  		/*
>  		 * Adjust freesize so that it accounts for how much memory
> @@ -6287,30 +6282,12 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
>  		zone_seqlock_init(zone);
>  		zone_pcp_init(zone);
>  
> -		/*
> -		 * The size of the CMA area is unknown now so we need to
> -		 * prepare the memory for the usemap at maximum.
> -		 */
> -		if (IS_ENABLED(CONFIG_CMA) && j == ZONE_MOVABLE &&
> -			pgdat->node_spanned_pages) {
> -			movable_size = node_end_pfn - pgdat->node_start_pfn;
> -		}
> -
> -		if (!size && !movable_size)
> +		if (!size)
>  			continue;
>  
>  		set_pageblock_order();
> -		if (movable_size) {
> -			zone->zone_start_pfn = pgdat->node_start_pfn;
> -			zone->spanned_pages = movable_size;
> -			setup_usemap(pgdat, zone,
> -				pgdat->node_start_pfn, movable_size);
> -			init_currently_empty_zone(zone,
> -				pgdat->node_start_pfn, movable_size);
> -		} else {
> -			setup_usemap(pgdat, zone, zone_start_pfn, size);
> -			init_currently_empty_zone(zone, zone_start_pfn, size);
> -		}
> +		setup_usemap(pgdat, zone, zone_start_pfn, size);
> +		init_currently_empty_zone(zone, zone_start_pfn, size);
>  		memmap_init(size, nid, j, zone_start_pfn);
>  	}
>  }
> @@ -7951,7 +7928,7 @@ void free_contig_range(unsigned long pfn, unsigned nr_pages)
>  }
>  #endif
>  
> -#if defined CONFIG_MEMORY_HOTPLUG || defined CONFIG_CMA
> +#ifdef CONFIG_MEMORY_HOTPLUG
>  /*
>   * The zone indicated has a new number of managed_pages; batch sizes and percpu
>   * page high values need to be recalulated.
> -- 
> 2.7.4
> 

-- 
Michal Hocko
SUSE Labs
