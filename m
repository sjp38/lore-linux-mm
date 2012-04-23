Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id E6A536B004A
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 10:56:35 -0400 (EDT)
Date: Mon, 23 Apr 2012 15:56:31 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH][RFC] mm: compaction: handle incorrect Unmovable type
 pageblocks
Message-ID: <20120423145631.GD3255@suse.de>
References: <201204231202.55739.b.zolnierkie@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <201204231202.55739.b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>

On Mon, Apr 23, 2012 at 12:02:55PM +0200, Bartlomiej Zolnierkiewicz wrote:
> From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Subject: [PATCH][RFC] mm: compaction: handle incorrect Unmovable type pageblocks
> 
> When Unmovable pages are freed from Unmovable type pageblock
> (and some Movable type pages are left in it) the type of
> the pageblock remains unchanged and therefore the pageblock
> cannot be used as a migration target during compaction.
> 

It does not remain unchanged forever. It can get reset a allocation time
although this depends on detecting that much of the pageblock is free.
This depends on high-order pages being freed which your adverse workload
avoids.

> Fix it by recording Unmovable type pages in a separate bitmap
> (which consumes 128 bytes per 4MiB of memory) and actively
> trying to fix the whole pageblock type during compaction
> (so the previously unsuitable pageblocks can now be used as
> a migration targets).
> 
> [ I also tried using counter for Unmovable pages per pageblock
>   but this approach turned out to be insufficient as we don't
>   always have an information about type of the page that we are
>   freeing. ]
> 

I have not read the patch yet but it seems very heavy-handed to add a
whole new bitmap for this. Based on your estimate it is 1 bit per page in a
pageblock which means that every allocation or free is likely to be updating
this bitmap. On machines with many cores that is potentially a lot of dirty
cache line bouncing and may incur significant overhead.  I'll know for sure
when I see the patch but my initial feeling is that this is a big problem.

> My particular test case (on a ARM EXYNOS4 device with 512 MiB,
> which means 131072 standard 4KiB pages in 'Normal' zone) is to:
> - allocate 120000 pages for kernel's usage
> - free every second page (60000 pages) of memory just allocated
> - allocate and use 60000 pages from user space
> - free remaining 60000 pages of kernel memory
> (now we have fragmented memory occupied mostly by user space pages)
> - try to allocate 100 order-9 (2048 KiB) pages for kernel's usage
> 

Ok, that is indeed an adverse workload that the current system will not
properly deal with. I think you are right to try fixing this but may need
a different approach that takes the cost out of the allocation/free path
and moves it the compaction path.

> The results:
> - with compaction disabled I get 11 successful allocations
> - with compaction enabled - 14 successful allocations
> - with this patch I'm able to get all 100 successful allocations
> 
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> ---
> This patch replaces http://marc.info/?l=linux-mm&m=133364363709346&w=2
> 
>  include/linux/mmzone.h |   10 ++
>  mm/compaction.c        |    3 
>  mm/internal.h          |    1 
>  mm/page_alloc.c        |  128 +++++++++++++++++++++++++++++
>  mm/sparse.c            |  216 +++++++++++++++++++++++++++++++++++++++++++++++--
>  5 files changed, 353 insertions(+), 5 deletions(-)
> 
> Index: b/include/linux/mmzone.h
> ===================================================================
> --- a/include/linux/mmzone.h	2012-04-20 16:35:16.894872193 +0200
> +++ b/include/linux/mmzone.h	2012-04-23 09:55:01.845549009 +0200
> @@ -379,6 +379,10 @@
>  	 * In SPARSEMEM, this map is stored in struct mem_section
>  	 */
>  	unsigned long		*pageblock_flags;
> +
> +#ifdef CONFIG_COMPACTION
> +	unsigned long		*unmovable_map;
> +#endif
>  #endif /* CONFIG_SPARSEMEM */
>  
>  #ifdef CONFIG_COMPACTION
> @@ -1033,6 +1037,12 @@
>  
>  	/* See declaration of similar field in struct zone */
>  	unsigned long *pageblock_flags;
> +
> +#ifdef CONFIG_COMPACTION
> +	unsigned long *unmovable_map;
> +	unsigned long pad0; /* Why this is needed? */
> +#endif
> +

You tell us, you added the padding :)

If I had to guess you are trying to avoid sharing a cache line between
unmovable_map and adjacent fields but I doubt it is necessary.

>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
>  	/*
>  	 * If !SPARSEMEM, pgdat doesn't have page_cgroup pointer. We use
> Index: b/mm/compaction.c
> ===================================================================
> --- a/mm/compaction.c	2012-04-20 16:35:16.910872188 +0200
> +++ b/mm/compaction.c	2012-04-23 09:33:54.525527592 +0200
> @@ -376,6 +376,9 @@
>  	if (migrate_async_suitable(migratetype))
>  		return true;
>  
> +	if (migratetype == MIGRATE_UNMOVABLE && set_unmovable_movable(page))
> +		return true;
> +

Ok, I have a two suggested changes to this

1. compaction currently has sync and async compaction. I suggest you
   make it a three states called async_partial, async_full and sync.
   async_partial would be the current behaviour. async_full and sync
   would both scan within MIGRATE_UNMOVABLE blocks to see if they
   needed to be changed. This will add a new slower path but the
   common path will be as it is today.

2. You maintain a bitmap of unmovable pages. Get rid of it. Instead have
   set_unmovable_movable scan the pageblock and build a free count based
   on finding PageBuddy pages, page_count(page) == 0 or PageLRU pages.
   If all pages within the block are in one of those three sets, call
   set_pageblock_migratetype(MIGRATE_MOVABLE) and call move_freepages_block()
   I also suggest finding a better name than set_unmovable_movable
   although  I do not have a better suggestion myself right now.

>  	/* Otherwise skip the block */
>  	return false;
>  }
> Index: b/mm/internal.h
> ===================================================================
> --- a/mm/internal.h	2012-04-20 16:35:16.898872189 +0200
> +++ b/mm/internal.h	2012-04-20 16:36:45.566872179 +0200
> @@ -95,6 +95,7 @@
>   * in mm/page_alloc.c
>   */
>  extern void __free_pages_bootmem(struct page *page, unsigned int order);
> +extern bool set_unmovable_movable(struct page *page);
>  extern void prep_compound_page(struct page *page, unsigned long order);
>  #ifdef CONFIG_MEMORY_FAILURE
>  extern bool is_free_buddy_page(struct page *page);
> Index: b/mm/page_alloc.c
> ===================================================================
> --- a/mm/page_alloc.c	2012-04-20 16:36:44.054872175 +0200
> +++ b/mm/page_alloc.c	2012-04-23 09:53:27.861547420 +0200
> @@ -257,6 +257,95 @@
>  					PB_migrate, PB_migrate_end);
>  }
>  
> +#ifdef CONFIG_COMPACTION
> +static inline unsigned long *get_unmovable_bitmap(struct zone *zone,
> +						  unsigned long pfn)
> +{
> +#ifdef CONFIG_SPARSEMEM
> +	return __pfn_to_section(pfn)->unmovable_map;
> +#else
> +	return zone->unmovable_map;
> +#endif /* CONFIG_SPARSEMEM */
> +}
> +
> +static inline int pfn_to_idx(struct zone *zone, unsigned long pfn)
> +{
> +#ifdef CONFIG_SPARSEMEM
> +	pfn &= (PAGES_PER_SECTION-1);
> +	return pfn;
> +#else
> +	pfn = pfn - zone->zone_start_pfn;
> +	return pfn;
> +#endif /* CONFIG_SPARSEMEM */
> +}
> +
> +static void set_unmovable_bitmap(struct page *page, int order)
> +{
> +	struct zone *zone;
> +	unsigned long *map;
> +	unsigned long pfn;
> +	int idx, i;
> +
> +	zone = page_zone(page);
> +	pfn = page_to_pfn(page);
> +	map = get_unmovable_bitmap(zone, pfn);
> +	idx = pfn_to_idx(zone, pfn);
> +
> +	for (i = 0; i < (1 << order); i++)
> +		__set_bit(idx + i, map);
> +}
> +
> +static void clear_unmovable_bitmap(struct page *page, int order)
> +{
> +	struct zone *zone;
> +	unsigned long *map;
> +	unsigned long pfn;
> +	int idx, i;
> +
> +	zone = page_zone(page);
> +	pfn = page_to_pfn(page);
> +	map = get_unmovable_bitmap(zone, pfn);
> +	idx = pfn_to_idx(zone, pfn);
> +
> +	for (i = 0; i < (1 << order); i++)
> +		__clear_bit(idx + i, map);
> +
> +}
> +

This stuff is called from page allocator fast paths which means it will
have a system-wide slowdown. This should be avoided.

> +static int move_freepages_block(struct zone *, struct page *, int);
> +
> +bool set_unmovable_movable(struct page *page)
> +{
> +	struct zone *zone;
> +	unsigned long *map;
> +	unsigned long pfn, start_pfn, end_pfn, t = 0;
> +	int idx, i, step = sizeof(unsigned long) * 8;
> +
> +	zone = page_zone(page);
> +	pfn = page_to_pfn(page);
> +	map = get_unmovable_bitmap(zone, pfn);
> +	idx = pfn_to_idx(zone, pfn);
> +
> +	start_pfn = idx & ~(pageblock_nr_pages - 1);
> +	end_pfn = start_pfn + pageblock_nr_pages - 1;
> +
> +	/* check if pageblock is free of unmovable pages */
> +	for (i = start_pfn; i <= end_pfn; i += step)
> +		t |= map[i / step];
> +
> +	if (!t) {
> +		set_pageblock_migratetype(page, MIGRATE_MOVABLE);
> +		move_freepages_block(zone, page, MIGRATE_MOVABLE);
> +		return true;
> +	}
> +
> +	return false;
> +}

And it can be avoided if this thing scans a pageblock looking for PageBuddy,
page_count==0 and PageLRU pages and changing the pageblock if all the
patches are of that type. Compaction may be slower as a result but that's
better than hurting the page allocator fast paths and it will also remove
an awful lot of complexity.

I did not read much of the rest of the patch because large parts of it
deal with this unmovable_bitmap which I do not think is necessary at
this point.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
