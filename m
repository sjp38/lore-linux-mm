Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id DA7716B0035
	for <linux-mm@kvack.org>; Tue, 12 Aug 2014 02:38:42 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id y10so12131088pdj.28
        for <linux-mm@kvack.org>; Mon, 11 Aug 2014 23:38:42 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id ul4si15331787pac.14.2014.08.11.23.38.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 11 Aug 2014 23:38:41 -0700 (PDT)
Received: by mail-pa0-f51.google.com with SMTP id ey11so12487589pad.38
        for <linux-mm@kvack.org>; Mon, 11 Aug 2014 23:38:41 -0700 (PDT)
Date: Tue, 12 Aug 2014 06:43:12 +0000
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 5/8] mm/isolation: change pageblock isolation logic to
 fix freepage counting bugs
Message-ID: <20140812064312.GD23418@gmail.com>
References: <1407309517-3270-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1407309517-3270-9-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1407309517-3270-9-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Aug 06, 2014 at 04:18:34PM +0900, Joonsoo Kim wrote:
> Current pageblock isolation logic has a problem that results in incorrect
> freepage counting. move_freepages_block() doesn't return number of
> moved pages so freepage count could be wrong if some pages are freed
> inbetween set_pageblock_migratetype() and move_freepages_block(). Although

It's a problem introduced by your patch pcp_disable/enable which release the
zone->lock so it would be better to mention it because I got confused
the problem was there. :(

In addition, could you include the situation in description?
It seems you are saying some of pages which was freed could be located in
isolated list already so move_freepages_block moves from isolated list to
isolated list so double accounting happens and it's a BUG. Right?

> we fix move_freepages_block() to return number of moved pages, the problem
> wouldn't be fixed completely because buddy allocator doesn't care if merged
> pages are on different buddy list or not. If some page on normal buddy list
> is merged with isolated page and moved to isolate buddy list, freepage
> count should be subtracted, but, it didn't and can't now.
> 
> To fix this case, freed page should not be added to buddy list
> inbetween set_pageblock_migratetype() and move_freepages_block().
> In this patch, I introduce hook, deactivate_isolate_page() on
> free_one_page() for freeing page on isolate pageblock. This page will
> be marked as PageIsolated() and handled specially in pageblock
> isolation logic.
> 
> Overall design of changed pageblock isolation logic is as following.
> 
> 1. ISOLATION
> - check pageblock is suitable for pageblock isolation.
> - change migratetype of pageblock to MIGRATE_ISOLATE.
> - disable pcp list.
> - drain pcp list.
> - pcp couldn't have any freepage at this point.
> - synchronize all cpus to see correct migratetype.
> - freed pages on this pageblock will be handled specially and
> not added to buddy list from here. With this way, there is no
> possibility of merging pages on different buddy list.

Pz, write down hwo to handle it specially. For instance, mark
the page with new flag and keep it without returning to the
buddy list.

> - move freepages on normal buddy list to isolate buddy list.
> There is no page on isolate buddy list so move_freepages_block()
> returns number of moved freepages correctly.
> - enable pcp list.
> 
> 2. TEST-ISOLATION
> - activates freepages marked as PageIsolated() and add to isolate

I was curious what "activate" means and realized with code inspection.
How about using "- Checking PageIsolated flag of the page and finally
move it into buddy list which should be MIGRATE_ISOLATE migratetype.

> buddy list.
> - test if pageblock is properly isolated.
> 
> 3. UNDO-ISOLATION
> - move freepages from isolate buddy list to normal buddy list.
> There is no page on normal buddy list so move_freepages_block()
> return number of moved freepages correctly.
> - change migratetype of pageblock to normal migratetype
> - synchronize all cpus.
> - activate isolated freepages and add to normal buddy list.
> 
> With this patch, most of freepage counting bugs are solved and
> exceptional handling for freepage count is done in pageblock isolation
> logic rather than allocator.
> 
> Remain problem is for page with pageblock_order. Following patch
> will fix it, too.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  include/linux/page-isolation.h |    2 +
>  mm/internal.h                  |    3 ++
>  mm/page_alloc.c                |   28 ++++++-----
>  mm/page_isolation.c            |  107 ++++++++++++++++++++++++++++++++++++----
>  4 files changed, 118 insertions(+), 22 deletions(-)
> 
> diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
> index 3fff8e7..3dd39fe 100644
> --- a/include/linux/page-isolation.h
> +++ b/include/linux/page-isolation.h
> @@ -21,6 +21,8 @@ static inline bool is_migrate_isolate(int migratetype)
>  }
>  #endif
>  
> +void deactivate_isolated_page(struct zone *zone, struct page *page,
> +				unsigned int order);

I don't know what is better name. How about "hijack_isolated_page"?

>  bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>  			 bool skip_hwpoisoned_pages);
>  void set_pageblock_migratetype(struct page *page, int migratetype);
> diff --git a/mm/internal.h b/mm/internal.h
> index 81b8884..c70750a 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -110,6 +110,9 @@ extern pmd_t *mm_find_pmd(struct mm_struct *mm, unsigned long address);
>   */
>  extern void zone_pcp_disable(struct zone *zone);
>  extern void zone_pcp_enable(struct zone *zone);
> +extern void __free_one_page(struct page *page, unsigned long pfn,
> +		struct zone *zone, unsigned int order,
> +		int migratetype);
>  extern void __free_pages_bootmem(struct page *page, unsigned int order);
>  extern void prep_compound_page(struct page *page, unsigned long order);
>  #ifdef CONFIG_MEMORY_FAILURE
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 4517b1d..82da4a8 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -571,7 +571,7 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
>   * -- nyc
>   */
>  
> -static inline void __free_one_page(struct page *page,
> +void __free_one_page(struct page *page,

no inline any more. :(

Personally, it is becoming increasingly clear that it would be better
to add some hooks for isolateed pages to be sure to fix theses problems
without adding more complicated logic.

>  		unsigned long pfn,
>  		struct zone *zone, unsigned int order,
>  		int migratetype)
> @@ -738,14 +738,19 @@ static void free_one_page(struct zone *zone,
>  				int migratetype)
>  {
>  	unsigned long nr_scanned;
> +
> +	if (unlikely(is_migrate_isolate(migratetype))) {
> +		deactivate_isolated_page(zone, page, order);
> +		return;
> +	}
> +
>  	spin_lock(&zone->lock);
>  	nr_scanned = zone_page_state(zone, NR_PAGES_SCANNED);
>  	if (nr_scanned)
>  		__mod_zone_page_state(zone, NR_PAGES_SCANNED, -nr_scanned);
>  
>  	__free_one_page(page, pfn, zone, order, migratetype);
> -	if (unlikely(!is_migrate_isolate(migratetype)))
> -		__mod_zone_freepage_state(zone, 1 << order, migratetype);
> +	__mod_zone_freepage_state(zone, 1 << order, migratetype);
>  	spin_unlock(&zone->lock);
>  }
>  
> @@ -6413,6 +6418,14 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>  	lru_add_drain_all();
>  	drain_all_pages();
>  
> +	/* Make sure the range is really isolated. */
> +	if (test_pages_isolated(start, end, false)) {
> +		pr_warn("alloc_contig_range test_pages_isolated(%lx, %lx) failed\n",
> +		       start, end);
> +		ret = -EBUSY;
> +		goto done;
> +	}
> +

It would be better to mention why you moved the logic in description
and please write down a description on test_pages_isolated.
"It moves captured isolated page in freeing path to buddy"

>  	order = 0;
>  	outer_start = start;
>  	while (!PageBuddy(pfn_to_page(outer_start))) {
> @@ -6423,15 +6436,6 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>  		outer_start &= ~0UL << order;
>  	}
>  
> -	/* Make sure the range is really isolated. */
> -	if (test_pages_isolated(outer_start, end, false)) {
> -		pr_warn("alloc_contig_range test_pages_isolated(%lx, %lx) failed\n",
> -		       outer_start, end);
> -		ret = -EBUSY;
> -		goto done;
> -	}
> -
> -
>  	/* Grab isolated pages from freelists. */
>  	outer_end = isolate_freepages_range(&cc, outer_start, end);
>  	if (!outer_end) {
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index 439158d..898361f 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -9,6 +9,75 @@
>  #include <linux/hugetlb.h>
>  #include "internal.h"
>  
> +#define ISOLATED_PAGE_MAPCOUNT_VALUE (-64)
> +
> +static inline int PageIsolated(struct page *page)
> +{
> +	return atomic_read(&page->_mapcount) == ISOLATED_PAGE_MAPCOUNT_VALUE;
> +}
> +
> +static inline void __SetPageIsolated(struct page *page)
> +{
> +	VM_BUG_ON_PAGE(atomic_read(&page->_mapcount) != -1, page);
> +	atomic_set(&page->_mapcount, ISOLATED_PAGE_MAPCOUNT_VALUE);
> +}
> +
> +static inline void __ClearPageIsolated(struct page *page)
> +{
> +	VM_BUG_ON_PAGE(!PageIsolated(page), page);
> +	atomic_set(&page->_mapcount, -1);
> +}
> +
> +void deactivate_isolated_page(struct zone *zone, struct page *page,
> +				unsigned int order)
> +{
> +	spin_lock(&zone->lock);
> +
> +	set_page_private(page, order);
> +	__SetPageIsolated(page);
> +
> +	spin_unlock(&zone->lock);
> +}
> +
> +static void activate_isolated_pages(struct zone *zone, unsigned long start_pfn,

IMO, activate is not a good name.
How about "drain_hijacked_isolate_pages"?

> +				unsigned long end_pfn, int migratetype)
> +{
> +	unsigned long flags;
> +	struct page *page;
> +	unsigned long pfn = start_pfn;
> +	unsigned int order;
> +	unsigned long nr_pages = 0;
> +
> +	spin_lock_irqsave(&zone->lock, flags);
> +
> +	while (pfn < end_pfn) {
> +		if (!pfn_valid_within(pfn)) {
> +			pfn++;
> +			continue;
> +		}
> +
> +		page = pfn_to_page(pfn);
> +		if (PageBuddy(page)) {
> +			pfn += 1 << page_order(page);
> +		} else if (PageIsolated(page)) {
> +			__ClearPageIsolated(page);
> +			set_freepage_migratetype(page, migratetype);
> +			order = page_order(page);
> +			__free_one_page(page, pfn, zone, order, migratetype);
> +
> +			pfn += 1 << order;
> +			nr_pages += 1 << order;
> +		} else {
> +			pfn++;
> +		}
> +	}
> +
> +	if (!is_migrate_isolate(migratetype))
> +		__mod_zone_freepage_state(zone, nr_pages, migratetype);
> +
> +	spin_unlock_irqrestore(&zone->lock, flags);
> +}
> +
>  int set_migratetype_isolate(struct page *page, bool skip_hwpoisoned_pages)
>  {
>  	struct zone *zone;
> @@ -88,24 +157,26 @@ void unset_migratetype_isolate(struct page *page, unsigned migratetype)
>  {
>  	struct zone *zone;
>  	unsigned long flags, nr_pages;
> +	unsigned long start_pfn, end_pfn;
>  
>  	zone = page_zone(page);
>  	spin_lock_irqsave(&zone->lock, flags);
> -	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
> -		goto out;
> +	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE) {
> +		spin_unlock_irqrestore(&zone->lock, flags);
> +		return;
> +	}
>  
> +	nr_pages = move_freepages_block(zone, page, migratetype);
> +	__mod_zone_freepage_state(zone, nr_pages, migratetype);
>  	set_pageblock_migratetype(page, migratetype);
>  	spin_unlock_irqrestore(&zone->lock, flags);
>  
>  	/* Freed pages will see original migratetype after this point */
>  	kick_all_cpus_sync();
>  
> -	spin_lock_irqsave(&zone->lock, flags);
> -	nr_pages = move_freepages_block(zone, page, migratetype);
> -	__mod_zone_freepage_state(zone, nr_pages, migratetype);
> -
> -out:
> -	spin_unlock_irqrestore(&zone->lock, flags);
> +	start_pfn = page_to_pfn(page) & ~(pageblock_nr_pages - 1);
> +	end_pfn = start_pfn + pageblock_nr_pages;
> +	activate_isolated_pages(zone, start_pfn, end_pfn, migratetype);
>  }
>  
>  static inline struct page *
> @@ -242,6 +313,8 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
>  	struct page *page;
>  	struct zone *zone;
>  	int ret;
> +	int order;
> +	unsigned long outer_start;
>  
>  	/*
>  	 * Note: pageblock_nr_pages != MAX_ORDER. Then, chunks of free pages
> @@ -256,10 +329,24 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
>  	page = __first_valid_page(start_pfn, end_pfn - start_pfn);
>  	if ((pfn < end_pfn) || !page)
>  		return -EBUSY;
> -	/* Check all pages are free or marked as ISOLATED */
> +
>  	zone = page_zone(page);
> +	activate_isolated_pages(zone, start_pfn, end_pfn, MIGRATE_ISOLATE);
> +
> +	/* Check all pages are free or marked as ISOLATED */
>  	spin_lock_irqsave(&zone->lock, flags);
> -	ret = __test_page_isolated_in_pageblock(start_pfn, end_pfn,
> +	order = 0;
> +	outer_start = start_pfn;
> +	while (!PageBuddy(pfn_to_page(outer_start))) {
> +		if (++order >= MAX_ORDER) {
> +			spin_unlock_irqrestore(&zone->lock, flags);
> +			return -EBUSY;
> +		}
> +
> +		outer_start &= ~0UL << order;
> +	}
> +
> +	ret = __test_page_isolated_in_pageblock(outer_start, end_pfn,
>  						skip_hwpoisoned_pages);
>  	spin_unlock_irqrestore(&zone->lock, flags);
>  	return ret ? 0 : -EBUSY;
> -- 
> 1.7.9.5
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
