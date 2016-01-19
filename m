Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id 416C16B0009
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 03:32:41 -0500 (EST)
Received: by mail-qk0-f172.google.com with SMTP id b66so26851584qkf.3
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 00:32:41 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id v140si36347836qka.56.2016.01.19.00.32.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Jan 2016 00:32:40 -0800 (PST)
Message-ID: <569DF3D7.3040203@huawei.com>
Date: Tue, 19 Jan 2016 16:29:11 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm/compaction: speed up pageblock_pfn_to_page() when
 zone is contiguous
References: <1450678432-16593-1-git-send-email-iamjoonsoo.kim@lge.com> <1450678432-16593-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1450678432-16593-2-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Aaron Lu <aaron.lu@intel.com>, Mel
 Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 2015/12/21 14:13, Joonsoo Kim wrote:
> There is a performance drop report due to hugepage allocation and in there
> half of cpu time are spent on pageblock_pfn_to_page() in compaction [1].
> In that workload, compaction is triggered to make hugepage but most of
> pageblocks are un-available for compaction due to pageblock type and
> skip bit so compaction usually fails. Most costly operations in this case
> is to find valid pageblock while scanning whole zone range. To check
> if pageblock is valid to compact, valid pfn within pageblock is required
> and we can obtain it by calling pageblock_pfn_to_page(). This function
> checks whether pageblock is in a single zone and return valid pfn
> if possible. Problem is that we need to check it every time before
> scanning pageblock even if we re-visit it and this turns out to
> be very expensive in this workload.
> 
> Although we have no way to skip this pageblock check in the system
> where hole exists at arbitrary position, we can use cached value for
> zone continuity and just do pfn_to_page() in the system where hole doesn't
> exist. This optimization considerably speeds up in above workload.
> 
> Before vs After
> Max: 1096 MB/s vs 1325 MB/s
> Min: 635 MB/s 1015 MB/s
> Avg: 899 MB/s 1194 MB/s
> 
> Avg is improved by roughly 30% [2].
> 
> [1]: http://www.spinics.net/lists/linux-mm/msg97378.html
> [2]: https://lkml.org/lkml/2015/12/9/23
> 
> v2
> o checking zone continuity after initialization
> o handle memory-hotplug case
> 
> Reported and Tested-by: Aaron Lu <aaron.lu@intel.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  include/linux/gfp.h            |  6 ---
>  include/linux/memory_hotplug.h |  3 ++
>  include/linux/mmzone.h         |  2 +
>  mm/compaction.c                | 43 ---------------------
>  mm/internal.h                  | 12 ++++++
>  mm/memory_hotplug.c            | 10 +++++
>  mm/page_alloc.c                | 85 +++++++++++++++++++++++++++++++++++++++++-
>  7 files changed, 111 insertions(+), 50 deletions(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 91f74e7..6eb3eca 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -515,13 +515,7 @@ void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp);
>  void drain_all_pages(struct zone *zone);
>  void drain_local_pages(struct zone *zone);
>  
> -#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
>  void page_alloc_init_late(void);
> -#else
> -static inline void page_alloc_init_late(void)
> -{
> -}
> -#endif
>  
>  /*
>   * gfp_allowed_mask is set to GFP_BOOT_MASK during early boot to restrict what
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index 2ea574f..18c2676 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -196,6 +196,9 @@ void put_online_mems(void);
>  void mem_hotplug_begin(void);
>  void mem_hotplug_done(void);
>  
> +extern void set_zone_contiguous(struct zone *zone);
> +extern void clear_zone_contiguous(struct zone *zone);
> +
>  #else /* ! CONFIG_MEMORY_HOTPLUG */
>  /*
>   * Stub functions for when hotplug is off
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 68cc063..eb5d88e 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -523,6 +523,8 @@ struct zone {
>  	bool			compact_blockskip_flush;
>  #endif
>  
> +	bool			contiguous;
> +
>  	ZONE_PADDING(_pad3_)
>  	/* Zone statistics */
>  	atomic_long_t		vm_stat[NR_VM_ZONE_STAT_ITEMS];
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 56fa321..9c89d46 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -71,49 +71,6 @@ static inline bool migrate_async_suitable(int migratetype)
>  	return is_migrate_cma(migratetype) || migratetype == MIGRATE_MOVABLE;
>  }
>  
> -/*
> - * Check that the whole (or subset of) a pageblock given by the interval of
> - * [start_pfn, end_pfn) is valid and within the same zone, before scanning it
> - * with the migration of free compaction scanner. The scanners then need to
> - * use only pfn_valid_within() check for arches that allow holes within
> - * pageblocks.
> - *
> - * Return struct page pointer of start_pfn, or NULL if checks were not passed.
> - *
> - * It's possible on some configurations to have a setup like node0 node1 node0
> - * i.e. it's possible that all pages within a zones range of pages do not
> - * belong to a single zone. We assume that a border between node0 and node1
> - * can occur within a single pageblock, but not a node0 node1 node0
> - * interleaving within a single pageblock. It is therefore sufficient to check
> - * the first and last page of a pageblock and avoid checking each individual
> - * page in a pageblock.
> - */
> -static struct page *pageblock_pfn_to_page(unsigned long start_pfn,
> -				unsigned long end_pfn, struct zone *zone)
> -{
> -	struct page *start_page;
> -	struct page *end_page;
> -
> -	/* end_pfn is one past the range we are checking */
> -	end_pfn--;
> -
> -	if (!pfn_valid(start_pfn) || !pfn_valid(end_pfn))
> -		return NULL;
> -
> -	start_page = pfn_to_page(start_pfn);
> -
> -	if (page_zone(start_page) != zone)
> -		return NULL;
> -
> -	end_page = pfn_to_page(end_pfn);
> -
> -	/* This gives a shorter code than deriving page_zone(end_page) */
> -	if (page_zone_id(start_page) != page_zone_id(end_page))
> -		return NULL;
> -
> -	return start_page;
> -}
> -
>  #ifdef CONFIG_COMPACTION
>  
>  /* Do not skip compaction more than 64 times */
> diff --git a/mm/internal.h b/mm/internal.h
> index d01a41c..bc9d337 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -137,6 +137,18 @@ __find_buddy_index(unsigned long page_idx, unsigned int order)
>  	return page_idx ^ (1 << order);
>  }
>  
> +extern struct page *__pageblock_pfn_to_page(unsigned long start_pfn,
> +				unsigned long end_pfn, struct zone *zone);
> +
> +static inline struct page *pageblock_pfn_to_page(unsigned long start_pfn,
> +				unsigned long end_pfn, struct zone *zone)
> +{
> +	if (zone->contiguous)
> +		return pfn_to_page(start_pfn);
> +
> +	return __pageblock_pfn_to_page(start_pfn, end_pfn, zone);
> +}
> +
>  extern int __isolate_free_page(struct page *page, unsigned int order);
>  extern void __free_pages_bootmem(struct page *page, unsigned long pfn,
>  					unsigned int order);
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index d8016a2..f7b6e6b 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -505,6 +505,9 @@ int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
>  	unsigned long i;
>  	int err = 0;
>  	int start_sec, end_sec;
> +
> +	clear_zone_contiguous(zone);
> +
>  	/* during initialize mem_map, align hot-added range to section */
>  	start_sec = pfn_to_section_nr(phys_start_pfn);
>  	end_sec = pfn_to_section_nr(phys_start_pfn + nr_pages - 1);
> @@ -523,6 +526,8 @@ int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
>  	}
>  	vmemmap_populate_print_last();
>  
> +	set_zone_contiguous(zone);
> +
>  	return err;
>  }
>  EXPORT_SYMBOL_GPL(__add_pages);
> @@ -770,6 +775,8 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
>  	resource_size_t start, size;
>  	int ret = 0;
>  
> +	clear_zone_contiguous(zone);
> +
>  	/*
>  	 * We can only remove entire sections
>  	 */
> @@ -796,6 +803,9 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
>  		if (ret)
>  			break;
>  	}
> +
> +	set_zone_contiguous(zone);
> +
>  	return ret;
>  }
>  EXPORT_SYMBOL_GPL(__remove_pages);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index bac8842..4f5ad2b 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1271,9 +1271,13 @@ free_range:
>  	pgdat_init_report_one_done();
>  	return 0;
>  }
> +#endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
>  
>  void __init page_alloc_init_late(void)
>  {
> +	struct zone *zone;
> +
> +#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
>  	int nid;
>  
>  	/* There will be num_node_state(N_MEMORY) threads */
> @@ -1287,8 +1291,87 @@ void __init page_alloc_init_late(void)
>  
>  	/* Reinit limits that are based on free pages after the kernel is up */
>  	files_maxfiles_init();
> +#endif
> +
> +	for_each_populated_zone(zone)
> +		set_zone_contiguous(zone);
> +}
> +
> +/*
> + * Check that the whole (or subset of) a pageblock given by the interval of
> + * [start_pfn, end_pfn) is valid and within the same zone, before scanning it
> + * with the migration of free compaction scanner. The scanners then need to
> + * use only pfn_valid_within() check for arches that allow holes within
> + * pageblocks.
> + *
> + * Return struct page pointer of start_pfn, or NULL if checks were not passed.
> + *
> + * It's possible on some configurations to have a setup like node0 node1 node0
> + * i.e. it's possible that all pages within a zones range of pages do not
> + * belong to a single zone. We assume that a border between node0 and node1
> + * can occur within a single pageblock, but not a node0 node1 node0
> + * interleaving within a single pageblock. It is therefore sufficient to check
> + * the first and last page of a pageblock and avoid checking each individual
> + * page in a pageblock.
> + */
> +struct page *__pageblock_pfn_to_page(unsigned long start_pfn,
> +				unsigned long end_pfn, struct zone *zone)
> +{
> +	struct page *start_page;
> +	struct page *end_page;
> +
> +	/* end_pfn is one past the range we are checking */
> +	end_pfn--;
> +
> +	if (!pfn_valid(start_pfn) || !pfn_valid(end_pfn))
> +		return NULL;
> +
> +	start_page = pfn_to_page(start_pfn);
> +
> +	if (page_zone(start_page) != zone)
> +		return NULL;
> +
> +	end_page = pfn_to_page(end_pfn);
> +
> +	/* This gives a shorter code than deriving page_zone(end_page) */
> +	if (page_zone_id(start_page) != page_zone_id(end_page))
> +		return NULL;
> +
> +	return start_page;
> +}
> +
> +void set_zone_contiguous(struct zone *zone)
> +{
> +	unsigned long block_start_pfn = zone->zone_start_pfn;
> +	unsigned long block_end_pfn;
> +	unsigned long pfn;
> +
> +	block_end_pfn = ALIGN(block_start_pfn + 1, pageblock_nr_pages);
> +	for (; block_start_pfn < zone_end_pfn(zone);
> +		block_start_pfn = block_end_pfn,
> +		block_end_pfn += pageblock_nr_pages) {
> +
> +		block_end_pfn = min(block_end_pfn, zone_end_pfn(zone));
> +
> +		if (!__pageblock_pfn_to_page(block_start_pfn,
> +					block_end_pfn, zone))
> +			return;
> +
> +		/* Check validity of pfn within pageblock */
> +		for (pfn = block_start_pfn; pfn < block_end_pfn; pfn++) {
> +			if (!pfn_valid_within(pfn))
> +				return;
> +		}
> +	}
> +
> +	/* We confirm that there is no hole */
> +	zone->contiguous = true;
> +}
pfn_valid_within just to check whether the page frame have a valid
section. buf if this section have a hole, it will not work.

Thanks
zhongjiang


> +void clear_zone_contiguous(struct zone *zone)
> +{
> +	zone->contiguous = false;
>  }
> -#endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
>  
>  #ifdef CONFIG_CMA
>  /* Free whole pageblock and set its migration type to MIGRATE_CMA. */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
