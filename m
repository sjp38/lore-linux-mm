Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 3359E6B004D
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 07:11:10 -0500 (EST)
Date: Mon, 30 Jan 2012 12:11:05 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 06/15] mm: page_alloc: introduce alloc_contig_range()
Message-ID: <20120130121105.GJ25268@csn.ul.ie>
References: <1327568457-27734-1-git-send-email-m.szyprowski@samsung.com>
 <1327568457-27734-7-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1327568457-27734-7-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>

On Thu, Jan 26, 2012 at 10:00:48AM +0100, Marek Szyprowski wrote:
> From: Michal Nazarewicz <mina86@mina86.com>
> 
> This commit adds the alloc_contig_range() function which tries
> to allocate given range of pages.  It tries to migrate all
> already allocated pages that fall in the range thus freeing them.
> Once all pages in the range are freed they are removed from the
> buddy system thus allocated for the caller to use.
> 
> Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> ---
>  include/linux/page-isolation.h |    7 ++
>  mm/page_alloc.c                |  183 ++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 190 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
> index 8c02c2b..430cf61 100644
> --- a/include/linux/page-isolation.h
> +++ b/include/linux/page-isolation.h
> @@ -39,5 +39,12 @@ extern void update_pcp_isolate_block(unsigned long pfn);
>  extern int set_migratetype_isolate(struct page *page);
>  extern void unset_migratetype_isolate(struct page *page);
>  
> +#ifdef CONFIG_CMA
> +
> +/* The below functions must be run on a range from a single zone. */
> +extern int alloc_contig_range(unsigned long start, unsigned long end);
> +extern void free_contig_range(unsigned long pfn, unsigned nr_pages);
> +
> +#endif
>  

Did you really mean page-isolation.h? I would have thought gfp.h
would be a more suitable fit.

>  #endif
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 70709e7..b4f50532 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -57,6 +57,7 @@
>  #include <linux/ftrace_event.h>
>  #include <linux/memcontrol.h>
>  #include <linux/prefetch.h>
> +#include <linux/migrate.h>
>  #include <linux/page-debug-flags.h>
>  
>  #include <asm/tlbflush.h>
> @@ -5488,6 +5489,188 @@ out:
>  	spin_unlock_irqrestore(&zone->lock, flags);
>  }
>  
> +#ifdef CONFIG_CMA
> +
> +static unsigned long pfn_align_to_maxpage_down(unsigned long pfn)
> +{
> +	return pfn & ~(MAX_ORDER_NR_PAGES - 1);
> +}
> +
> +static unsigned long pfn_align_to_maxpage_up(unsigned long pfn)
> +{
> +	return ALIGN(pfn, MAX_ORDER_NR_PAGES);
> +}
> +
> +static struct page *
> +__alloc_contig_migrate_alloc(struct page *page, unsigned long private,
> +			     int **resultp)
> +{
> +	return alloc_page(GFP_HIGHUSER_MOVABLE);
> +}
> +
> +/* [start, end) must belong to a single zone. */
> +static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
> +{
> +	/* This function is based on compact_zone() from compaction.c. */
> +
> +	unsigned long pfn = start;
> +	unsigned int tries = 0;
> +	int ret = 0;
> +
> +	struct compact_control cc = {
> +		.nr_migratepages = 0,
> +		.order = -1,
> +		.zone = page_zone(pfn_to_page(start)),
> +		.sync = true,
> +	};
> +	INIT_LIST_HEAD(&cc.migratepages);
> +
> +	migrate_prep_local();
> +
> +	while (pfn < end || !list_empty(&cc.migratepages)) {
> +		if (fatal_signal_pending(current)) {
> +			ret = -EINTR;
> +			break;
> +		}
> +
> +		if (list_empty(&cc.migratepages)) {
> +			cc.nr_migratepages = 0;
> +			pfn = isolate_migratepages_range(cc.zone, &cc,
> +							 pfn, end);
> +			if (!pfn) {
> +				ret = -EINTR;
> +				break;
> +			}
> +			tries = 0;
> +		} else if (++tries == 5) {
> +			ret = ret < 0 ? ret : -EBUSY;
> +			break;
> +		}
> +
> +		ret = migrate_pages(&cc.migratepages,
> +				    __alloc_contig_migrate_alloc,
> +				    0, false, true);
> +	}
> +
> +	putback_lru_pages(&cc.migratepages);
> +	return ret;
> +}
> +
> +/**
> + * alloc_contig_range() -- tries to allocate given range of pages
> + * @start:	start PFN to allocate
> + * @end:	one-past-the-last PFN to allocate
> + *
> + * The PFN range does not have to be pageblock or MAX_ORDER_NR_PAGES
> + * aligned, however it's the caller's responsibility to guarantee that
> + * we are the only thread that changes migrate type of pageblocks the
> + * pages fall in.
> + *
> + * The PFN range must belong to a single zone.
> + *
> + * Returns zero on success or negative error code.  On success all
> + * pages which PFN is in [start, end) are allocated for the caller and
> + * need to be freed with free_contig_range().
> + */
> +int alloc_contig_range(unsigned long start, unsigned long end)
> +{
> +	unsigned long outer_start, outer_end;
> +	int ret = 0, order;
> +
> +	/*
> +	 * What we do here is we mark all pageblocks in range as
> +	 * MIGRATE_ISOLATE.  Because of the way page allocator work, we
> +	 * align the range to MAX_ORDER pages so that page allocator
> +	 * won't try to merge buddies from different pageblocks and
> +	 * change MIGRATE_ISOLATE to some other migration type.
> +	 *
> +	 * Once the pageblocks are marked as MIGRATE_ISOLATE, we
> +	 * migrate the pages from an unaligned range (ie. pages that
> +	 * we are interested in).  This will put all the pages in
> +	 * range back to page allocator as MIGRATE_ISOLATE.
> +	 *
> +	 * When this is done, we take the pages in range from page
> +	 * allocator removing them from the buddy system.  This way
> +	 * page allocator will never consider using them.
> +	 *
> +	 * This lets us mark the pageblocks back as
> +	 * MIGRATE_CMA/MIGRATE_MOVABLE so that free pages in the
> +	 * MAX_ORDER aligned range but not in the unaligned, original
> +	 * range are put back to page allocator so that buddy can use
> +	 * them.
> +	 */
> +
> +	ret = start_isolate_page_range(pfn_align_to_maxpage_down(start),
> +				       pfn_align_to_maxpage_up(end));
> +	if (ret)
> +		goto done;
> +
> +	ret = __alloc_contig_migrate_range(start, end);
> +	if (ret)
> +		goto done;
> +
> +	/*
> +	 * Pages from [start, end) are within a MAX_ORDER_NR_PAGES
> +	 * aligned blocks that are marked as MIGRATE_ISOLATE.  What's
> +	 * more, all pages in [start, end) are free in page allocator.
> +	 * What we are going to do is to allocate all pages from
> +	 * [start, end) (that is remove them from page allocater).
> +	 *
> +	 * The only problem is that pages at the beginning and at the
> +	 * end of interesting range may be not aligned with pages that
> +	 * page allocator holds, ie. they can be part of higher order
> +	 * pages.  Because of this, we reserve the bigger range and
> +	 * once this is done free the pages we are not interested in.
> +	 */
> +
> +	lru_add_drain_all();
> +	drain_all_pages();
> +

You unconditionally drain all pages here. It's up to you whether to
keep that or try reduce IPIs by only sending one if a page with count
0 is found in the range. I think it is something that could be followed
up on later and is not necessary for initial merging and wider testing.

> +	order = 0;
> +	outer_start = start;
> +	while (!PageBuddy(pfn_to_page(outer_start))) {
> +		if (WARN_ON(++order >= MAX_ORDER)) {
> +			ret = -EINVAL;
> +			goto done;
> +		}
> +		outer_start &= ~0UL << order;
> +	}
> +

Just a small note here - you are checking PageBuddy without zone->lock .
As you have isolated the range, you have a reasonable expectation that
this is safe but if you spin another version of the patch it might
justify a small comment.

> +	/* Make sure the range is really isolated. */
> +	if (test_pages_isolated(outer_start, end)) {
> +		pr_warn("__alloc_contig_migrate_range: test_pages_isolated(%lx, %lx) failed\n",
> +		       outer_start, end);
> +		ret = -EBUSY;
> +		goto done;
> +	}
> +
> +	outer_end = isolate_freepages_range(outer_start, end);
> +	if (!outer_end) {
> +		ret = -EBUSY;
> +		goto done;
> +	}
> +
> +	/* Free head and tail (if any) */
> +	if (start != outer_start)
> +		free_contig_range(outer_start, start - outer_start);
> +	if (end != outer_end)
> +		free_contig_range(end, outer_end - end);
> +
> +done:
> +	undo_isolate_page_range(pfn_align_to_maxpage_down(start),
> +				pfn_align_to_maxpage_up(end));
> +	return ret;
> +}
> +
> +void free_contig_range(unsigned long pfn, unsigned nr_pages)
> +{
> +	for (; nr_pages--; ++pfn)
> +		__free_page(pfn_to_page(pfn));
> +}
> +
> +#endif
> +
> +

Bit of whitespace damage there.

I confess that I did not read this one quite as carefully because I
think I looked a previous version that looked ok at the time. As it
affects CMA and only CMA I also expect others will be spending a lot
of effort and testing on this. Nothing obvious or horrible jumped out
at me other than the page_isolation.h thing and that could be argued
either way so;

Acked-by: Mel Gorman <mel@csn.ul.ie>

>  /*
>  #ifdef CONFIG_MEMORY_HOTREMOVE
>  /*
>   * All pages in the range must be isolated before calling this.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
