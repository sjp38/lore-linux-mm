Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id B52C86B007E
	for <linux-mm@kvack.org>; Thu, 26 May 2016 21:47:20 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id c127so226476237ywb.1
        for <linux-mm@kvack.org>; Thu, 26 May 2016 18:47:20 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id k64si15412532qhc.118.2016.05.26.18.47.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 May 2016 18:47:18 -0700 (PDT)
Subject: Re: [PATCH v3 5/6] mm/cma: remove MIGRATE_CMA
References: <1464243748-16367-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1464243748-16367-6-git-send-email-iamjoonsoo.kim@lge.com>
From: Chen Feng <puck.chen@hisilicon.com>
Message-ID: <5747A600.3050800@hisilicon.com>
Date: Fri, 27 May 2016 09:42:24 +0800
MIME-Version: 1.0
In-Reply-To: <1464243748-16367-6-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh
 Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Rui Teng <rui.teng@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, qijiwen@hisilicon.com, Zhuangluan Su <suzhuangluan@hisilicon.com>, Dan Zhao <dan.zhao@hisilicon.com>

Hi Joonsoo,

On 2016/5/26 14:22, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Now, all reserved pages for CMA region are belong to the ZONE_CMA
> and there is no other type of pages. Therefore, we don't need to
> use MIGRATE_CMA to distinguish and handle differently for CMA pages
> and ordinary pages. Remove MIGRATE_CMA.
> 
> Unfortunately, this patch make free CMA counter incorrect because
> we count it when pages are on the MIGRATE_CMA. It will be fixed
> by next patch. I can squash next patch here but it makes changes
> complicated and hard to review so I separate that.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  include/linux/gfp.h    |  3 +-
>  include/linux/mmzone.h | 22 -------------
>  include/linux/vmstat.h |  8 -----
>  mm/cma.c               |  2 +-
>  mm/compaction.c        | 10 ++----
>  mm/hugetlb.c           |  2 +-
>  mm/page_alloc.c        | 87 +++++++++++++-------------------------------------
>  mm/page_isolation.c    |  5 ++-
>  mm/vmstat.c            |  5 +--
>  9 files changed, 31 insertions(+), 113 deletions(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 4d6c008..1a3b869 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -559,8 +559,7 @@ static inline bool pm_suspended_storage(void)
>  
>  #if (defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || defined(CONFIG_CMA)
>  /* The below functions must be run on a range from a single zone. */
> -extern int alloc_contig_range(unsigned long start, unsigned long end,
> -			      unsigned migratetype);
> +extern int alloc_contig_range(unsigned long start, unsigned long end);
>  extern void free_contig_range(unsigned long pfn, unsigned nr_pages);
>  #endif
>  
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 54c92a6..236d0bd 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -41,22 +41,6 @@ enum {
>  	MIGRATE_RECLAIMABLE,
>  	MIGRATE_PCPTYPES,	/* the number of types on the pcp lists */
>  	MIGRATE_HIGHATOMIC = MIGRATE_PCPTYPES,
> -#ifdef CONFIG_CMA
> -	/*
> -	 * MIGRATE_CMA migration type is designed to mimic the way
> -	 * ZONE_MOVABLE works.  Only movable pages can be allocated
> -	 * from MIGRATE_CMA pageblocks and page allocator never
> -	 * implicitly change migration type of MIGRATE_CMA pageblock.
> -	 *
> -	 * The way to use it is to change migratetype of a range of
> -	 * pageblocks to MIGRATE_CMA which can be done by
> -	 * __free_pageblock_cma() function.  What is important though
> -	 * is that a range of pageblocks must be aligned to
> -	 * MAX_ORDER_NR_PAGES should biggest page be bigger then
> -	 * a single pageblock.
> -	 */
> -	MIGRATE_CMA,
> -#endif
>  #ifdef CONFIG_MEMORY_ISOLATION
>  	MIGRATE_ISOLATE,	/* can't allocate from here */
>  #endif
> @@ -66,12 +50,6 @@ enum {
>  /* In mm/page_alloc.c; keep in sync also with show_migration_types() there */
>  extern char * const migratetype_names[MIGRATE_TYPES];
>  
> -#ifdef CONFIG_CMA
> -#  define is_migrate_cma(migratetype) unlikely((migratetype) == MIGRATE_CMA)
> -#else
> -#  define is_migrate_cma(migratetype) false
> -#endif
> -
>  #define for_each_migratetype_order(order, type) \
>  	for (order = 0; order < MAX_ORDER; order++) \
>  		for (type = 0; type < MIGRATE_TYPES; type++)
> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> index 0aa613d..e0eb3e5 100644
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -264,14 +264,6 @@ static inline void drain_zonestat(struct zone *zone,
>  			struct per_cpu_pageset *pset) { }
>  #endif		/* CONFIG_SMP */
>  
> -static inline void __mod_zone_freepage_state(struct zone *zone, int nr_pages,
> -					     int migratetype)
> -{
> -	__mod_zone_page_state(zone, NR_FREE_PAGES, nr_pages);
> -	if (is_migrate_cma(migratetype))
> -		__mod_zone_page_state(zone, NR_FREE_CMA_PAGES, nr_pages);
> -}
> -
>  extern const char * const vmstat_text[];
>  
>  #endif /* _LINUX_VMSTAT_H */
> diff --git a/mm/cma.c b/mm/cma.c
> index 8684f50..bd436e4 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -444,7 +444,7 @@ struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align)
>  
>  		pfn = cma->base_pfn + (bitmap_no << cma->order_per_bit);
>  		mutex_lock(&cma_mutex);
> -		ret = alloc_contig_range(pfn, pfn + count, MIGRATE_CMA);
> +		ret = alloc_contig_range(pfn, pfn + count);
>  		mutex_unlock(&cma_mutex);
>  		if (ret == 0) {
>  			page = pfn_to_page(pfn);
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 1427366..acb1d1a 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -76,7 +76,7 @@ static void map_pages(struct list_head *list)
>  
>  static inline bool migrate_async_suitable(int migratetype)
>  {
> -	return is_migrate_cma(migratetype) || migratetype == MIGRATE_MOVABLE;
> +	return migratetype == MIGRATE_MOVABLE;
>  }
>  
>  #ifdef CONFIG_COMPACTION
> @@ -953,7 +953,7 @@ static bool suitable_migration_target(struct page *page)
>  			return false;
>  	}
>  
> -	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
> +	/* If the block is MIGRATE_MOVABLE, allow migration */
>  	if (migrate_async_suitable(get_pageblock_migratetype(page)))
>  		return true;
>  
> @@ -1277,12 +1277,6 @@ static enum compact_result __compact_finished(struct zone *zone, struct compact_
>  		if (!list_empty(&area->free_list[migratetype]))
>  			return COMPACT_PARTIAL;
>  
> -#ifdef CONFIG_CMA
> -		/* MIGRATE_MOVABLE can fallback on MIGRATE_CMA */
> -		if (migratetype == MIGRATE_MOVABLE &&
> -			!list_empty(&area->free_list[MIGRATE_CMA]))
> -			return COMPACT_PARTIAL;
> -#endif
>  		/*
>  		 * Job done if allocation would steal freepages from
>  		 * other migratetype buddy lists.
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index d26162e..a081f15 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1029,7 +1029,7 @@ static int __alloc_gigantic_page(unsigned long start_pfn,
>  				unsigned long nr_pages)
>  {
>  	unsigned long end_pfn = start_pfn + nr_pages;
> -	return alloc_contig_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
> +	return alloc_contig_range(start_pfn, end_pfn);
>  }
>  
>  static bool pfn_range_valid_gigantic(struct zone *z,
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index bab3698..e1c17d15 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -124,8 +124,8 @@ gfp_t gfp_allowed_mask __read_mostly = GFP_BOOT_MASK;
>   * put on a pcplist. Used to avoid the pageblock migratetype lookup when
>   * freeing from pcplists in most cases, at the cost of possibly becoming stale.
>   * Also the migratetype set in the page does not necessarily match the pcplist
> - * index, e.g. page might have MIGRATE_CMA set but be on a pcplist with any
> - * other index - this ensures that it will be put on the correct CMA freelist.
> + * index, e.g. page might have MIGRATE_MOVABLE set but be on a pcplist with any
> + * other index - this ensures that it will be put on the correct freelist.
>   */
>  static inline int get_pcppage_migratetype(struct page *page)
>  {
> @@ -234,9 +234,6 @@ char * const migratetype_names[MIGRATE_TYPES] = {
>  	"Movable",
>  	"Reclaimable",
>  	"HighAtomic",
> -#ifdef CONFIG_CMA
> -	"CMA",
> -#endif
>  #ifdef CONFIG_MEMORY_ISOLATION
>  	"Isolate",
>  #endif
> @@ -670,7 +667,7 @@ static inline void set_page_guard(struct zone *zone, struct page *page,
>  	INIT_LIST_HEAD(&page->lru);
>  	set_page_private(page, order);
>  	/* Guard pages are not available for any usage */
> -	__mod_zone_freepage_state(zone, -(1 << order), migratetype);
> +	__mod_zone_page_state(zone, NR_FREE_PAGES, -(1 << order));
>  }
>  
>  static inline void clear_page_guard(struct zone *zone, struct page *page,
> @@ -689,7 +686,7 @@ static inline void clear_page_guard(struct zone *zone, struct page *page,
>  
>  	set_page_private(page, 0);
>  	if (!is_migrate_isolate(migratetype))
> -		__mod_zone_freepage_state(zone, (1 << order), migratetype);
> +		__mod_zone_page_state(zone, NR_FREE_PAGES, (1 << order));
>  }
>  #else
>  struct page_ext_operations debug_guardpage_ops = { NULL, };
> @@ -800,7 +797,7 @@ static inline void __free_one_page(struct page *page,
>  
>  	VM_BUG_ON(migratetype == -1);
>  	if (likely(!is_migrate_isolate(migratetype)))
> -		__mod_zone_freepage_state(zone, 1 << order, migratetype);
> +		__mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
>  
>  	page_idx = pfn & ((1 << MAX_ORDER) - 1);
>  
> @@ -1580,7 +1577,7 @@ static void __init adjust_present_page_count(struct page *page, long count)
>  	zone->present_pages += count;
>  }
>  
> -/* Free whole pageblock and set its migration type to MIGRATE_CMA. */
> +/* Free whole pageblock and set its migration type to MIGRATE_MOVABLE. */
>  void __init init_cma_reserved_pageblock(struct page *page)
>  {
>  	unsigned i = pageblock_nr_pages;
> @@ -1605,7 +1602,7 @@ void __init init_cma_reserved_pageblock(struct page *page)
>  
>  	adjust_present_page_count(page, pageblock_nr_pages);
>  
> -	set_pageblock_migratetype(page, MIGRATE_CMA);
> +	set_pageblock_migratetype(page, MIGRATE_MOVABLE);

I have a question here, if the ZONE_CMA pages are all movable.

Then the unmovable alloc will also use CMA memory. Is this right?

How can the cma memory be migrate?

>  
>  	if (pageblock_order >= MAX_ORDER) {
>  		i = pageblock_nr_pages;
> @@ -1830,25 +1827,11 @@ static int fallbacks[MIGRATE_TYPES][4] = {
>  	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE,   MIGRATE_TYPES },
>  	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE,   MIGRATE_TYPES },
>  	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_TYPES },
> -#ifdef CONFIG_CMA
> -	[MIGRATE_CMA]         = { MIGRATE_TYPES }, /* Never used */
> -#endif
>  #ifdef CONFIG_MEMORY_ISOLATION
>  	[MIGRATE_ISOLATE]     = { MIGRATE_TYPES }, /* Never used */
>  #endif
>  };
>  
> -#ifdef CONFIG_CMA
> -static struct page *__rmqueue_cma_fallback(struct zone *zone,
> -					unsigned int order)
> -{
> -	return __rmqueue_smallest(zone, order, MIGRATE_CMA);
> -}
> -#else
> -static inline struct page *__rmqueue_cma_fallback(struct zone *zone,
> -					unsigned int order) { return NULL; }
> -#endif
> -
>  /*
>   * Move the free pages in a range to the free lists of the requested type.
>   * Note that start_page and end_pages are not aligned on a pageblock
> @@ -2053,7 +2036,7 @@ static void reserve_highatomic_pageblock(struct page *page, struct zone *zone,
>  	/* Yoink! */
>  	mt = get_pageblock_migratetype(page);
>  	if (mt != MIGRATE_HIGHATOMIC &&
> -			!is_migrate_isolate(mt) && !is_migrate_cma(mt)) {
> +			!is_migrate_isolate(mt)) {
>  		zone->nr_reserved_highatomic += pageblock_nr_pages;
>  		set_pageblock_migratetype(page, MIGRATE_HIGHATOMIC);
>  		move_freepages_block(zone, page, MIGRATE_HIGHATOMIC);
> @@ -2156,9 +2139,7 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
>  		/*
>  		 * The pcppage_migratetype may differ from pageblock's
>  		 * migratetype depending on the decisions in
> -		 * find_suitable_fallback(). This is OK as long as it does not
> -		 * differ for MIGRATE_CMA pageblocks. Those can be used as
> -		 * fallback only via special __rmqueue_cma_fallback() function
> +		 * find_suitable_fallback(). This is OK.
>  		 */
>  		set_pcppage_migratetype(page, start_migratetype);
>  
> @@ -2181,13 +2162,8 @@ static struct page *__rmqueue(struct zone *zone, unsigned int order,
>  	struct page *page;
>  
>  	page = __rmqueue_smallest(zone, order, migratetype);
> -	if (unlikely(!page)) {
> -		if (migratetype == MIGRATE_MOVABLE)
> -			page = __rmqueue_cma_fallback(zone, order);
> -
> -		if (!page)
> -			page = __rmqueue_fallback(zone, order, migratetype);
> -	}
> +	if (unlikely(!page))
> +		page = __rmqueue_fallback(zone, order, migratetype);
>  
>  	trace_mm_page_alloc_zone_locked(page, order, migratetype);
>  	return page;
> @@ -2227,9 +2203,6 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
>  		else
>  			list_add_tail(&page->lru, list);
>  		list = &page->lru;
> -		if (is_migrate_cma(get_pcppage_migratetype(page)))
> -			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
> -					      -(1 << order));
>  	}
>  	__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
>  	spin_unlock(&zone->lock);
> @@ -2527,7 +2500,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
>  		if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
>  			return 0;
>  
> -		__mod_zone_freepage_state(zone, -(1UL << order), mt);
> +		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));
>  	}
>  
>  	/* Remove page from free list */
> @@ -2542,7 +2515,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
>  		struct page *endpage = page + (1 << order) - 1;
>  		for (; page < endpage; page += pageblock_nr_pages) {
>  			int mt = get_pageblock_migratetype(page);
> -			if (!is_migrate_isolate(mt) && !is_migrate_cma(mt))
> +			if (!is_migrate_isolate(mt))
>  				set_pageblock_migratetype(page,
>  							  MIGRATE_MOVABLE);
>  		}
> @@ -2670,8 +2643,7 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
>  		if (!page)
>  			goto failed;
>  		__mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
> -		__mod_zone_freepage_state(zone, -(1 << order),
> -					  get_pcppage_migratetype(page));
> +		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1 << order));
>  	}
>  
>  	if (atomic_long_read(&zone->vm_stat[NR_ALLOC_BATCH]) <= 0 &&
> @@ -2825,11 +2797,6 @@ bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
>  			if (!list_empty(&area->free_list[mt]))
>  				return true;
>  		}
> -
> -#ifdef CONFIG_CMA
> -		if (!list_empty(&area->free_list[MIGRATE_CMA]))
> -			return true;
> -#endif
>  	}
>  	return false;
>  }
> @@ -4320,9 +4287,6 @@ static void show_migration_types(unsigned char type)
>  		[MIGRATE_MOVABLE]	= 'M',
>  		[MIGRATE_RECLAIMABLE]	= 'E',
>  		[MIGRATE_HIGHATOMIC]	= 'H',
> -#ifdef CONFIG_CMA
> -		[MIGRATE_CMA]		= 'C',
> -#endif
>  #ifdef CONFIG_MEMORY_ISOLATION
>  		[MIGRATE_ISOLATE]	= 'I',
>  #endif
> @@ -7244,7 +7208,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>  		return false;
>  
>  	mt = get_pageblock_migratetype(page);
> -	if (mt == MIGRATE_MOVABLE || is_migrate_cma(mt))
> +	if (mt == MIGRATE_MOVABLE)
>  		return false;
>  
>  	pfn = page_to_pfn(page);
> @@ -7392,15 +7356,11 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
>   * alloc_contig_range() -- tries to allocate given range of pages
>   * @start:	start PFN to allocate
>   * @end:	one-past-the-last PFN to allocate
> - * @migratetype:	migratetype of the underlaying pageblocks (either
> - *			#MIGRATE_MOVABLE or #MIGRATE_CMA).  All pageblocks
> - *			in range must have the same migratetype and it must
> - *			be either of the two.
>   *
>   * The PFN range does not have to be pageblock or MAX_ORDER_NR_PAGES
>   * aligned, however it's the caller's responsibility to guarantee that
>   * we are the only thread that changes migrate type of pageblocks the
> - * pages fall in.
> + * pages fall in and it should be MIGRATE_MOVABLE.
>   *
>   * The PFN range must belong to a single zone.
>   *
> @@ -7408,8 +7368,7 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
>   * pages which PFN is in [start, end) are allocated for the caller and
>   * need to be freed with free_contig_range().
>   */
> -int alloc_contig_range(unsigned long start, unsigned long end,
> -		       unsigned migratetype)
> +int alloc_contig_range(unsigned long start, unsigned long end)
>  {
>  	unsigned long outer_start, outer_end;
>  	unsigned int order;
> @@ -7442,14 +7401,14 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>  	 * allocator removing them from the buddy system.  This way
>  	 * page allocator will never consider using them.
>  	 *
> -	 * This lets us mark the pageblocks back as
> -	 * MIGRATE_CMA/MIGRATE_MOVABLE so that free pages in the
> -	 * aligned range but not in the unaligned, original range are
> -	 * put back to page allocator so that buddy can use them.
> +	 * This lets us mark the pageblocks back as MIGRATE_MOVABLE
> +	 * so that free pages in the aligned range but not in the
> +	 * unaligned, original range are put back to page allocator
> +	 * so that buddy can use them.
>  	 */
>  
>  	ret = start_isolate_page_range(pfn_max_align_down(start),
> -				       pfn_max_align_up(end), migratetype,
> +				       pfn_max_align_up(end), MIGRATE_MOVABLE,
>  				       false);
>  	if (ret)
>  		return ret;
> @@ -7528,7 +7487,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>  
>  done:
>  	undo_isolate_page_range(pfn_max_align_down(start),
> -				pfn_max_align_up(end), migratetype);
> +				pfn_max_align_up(end), MIGRATE_MOVABLE);
>  	return ret;
>  }
>  
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index 612122b..5708649 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -61,13 +61,12 @@ static int set_migratetype_isolate(struct page *page,
>  out:
>  	if (!ret) {
>  		unsigned long nr_pages;
> -		int migratetype = get_pageblock_migratetype(page);
>  
>  		set_pageblock_migratetype(page, MIGRATE_ISOLATE);
>  		zone->nr_isolate_pageblock++;
>  		nr_pages = move_freepages_block(zone, page, MIGRATE_ISOLATE);
>  
> -		__mod_zone_freepage_state(zone, -nr_pages, migratetype);
> +		__mod_zone_page_state(zone, NR_FREE_PAGES, -nr_pages);
>  	}
>  
>  	spin_unlock_irqrestore(&zone->lock, flags);
> @@ -122,7 +121,7 @@ static void unset_migratetype_isolate(struct page *page, unsigned migratetype)
>  	 */
>  	if (!isolated_page) {
>  		nr_pages = move_freepages_block(zone, page, migratetype);
> -		__mod_zone_freepage_state(zone, nr_pages, migratetype);
> +		__mod_zone_page_state(zone, NR_FREE_PAGES, nr_pages);
>  	}
>  	set_pageblock_migratetype(page, migratetype);
>  	zone->nr_isolate_pageblock--;
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 48c4942..8d18d1e 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1088,10 +1088,7 @@ static void pagetypeinfo_showmixedcount_print(struct seq_file *m,
>  
>  			page_mt = gfpflags_to_migratetype(page_ext->gfp_mask);
>  			if (pageblock_mt != page_mt) {
> -				if (is_migrate_cma(pageblock_mt))
> -					count[MIGRATE_MOVABLE]++;
> -				else
> -					count[pageblock_mt]++;
> +				count[pageblock_mt]++;
>  
>  				pfn = block_end_pfn;
>  				break;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
