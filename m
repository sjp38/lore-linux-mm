Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A61A96B002D
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 08:38:15 -0400 (EDT)
Date: Tue, 18 Oct 2011 14:38:09 +0200
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/9] mm: alloc_contig_range() added
Message-ID: <20111018123809.GC6660@csn.ul.ie>
References: <1317909290-29832-1-git-send-email-m.szyprowski@samsung.com>
 <1317909290-29832-4-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1317909290-29832-4-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>

On Thu, Oct 06, 2011 at 03:54:43PM +0200, Marek Szyprowski wrote:
> From: Michal Nazarewicz <m.nazarewicz@samsung.com>
> 
> This commit adds the alloc_contig_range() function which tries
> to allocate given range of pages.  It tries to migrate all
> already allocated pages that fall in the range thus freeing them.
> Once all pages in the range are freed they are removed from the
> buddy system thus allocated for the caller to use.
> 
> Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> [m.szyprowski: renamed some variables for easier code reading]
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> CC: Michal Nazarewicz <mina86@mina86.com>
> Acked-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  include/linux/page-isolation.h |    2 +
>  mm/page_alloc.c                |  148 ++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 150 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
> index b9fc428..774ecec 100644
> --- a/include/linux/page-isolation.h
> +++ b/include/linux/page-isolation.h
> @@ -36,6 +36,8 @@ extern void unset_migratetype_isolate(struct page *page);
>  /* The below functions must be run on a range from a single zone. */
>  extern unsigned long alloc_contig_freed_pages(unsigned long start,
>  					      unsigned long end, gfp_t flag);
> +extern int alloc_contig_range(unsigned long start, unsigned long end,
> +			      gfp_t flags);
>  extern void free_contig_pages(unsigned long pfn, unsigned nr_pages);
>  
>  /*
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index fbfb920..8010854 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5773,6 +5773,154 @@ void free_contig_pages(unsigned long pfn, unsigned nr_pages)
>  	}
>  }
>  
> +static unsigned long pfn_to_maxpage(unsigned long pfn)
> +{
> +	return pfn & ~(MAX_ORDER_NR_PAGES - 1);
> +}
> +

pfn_to_maxpage is a very confusing name here. It would be preferable to
create a MAX_ORDER_MASK that you apply directly.

Maybe something like SECTION_ALIGN_UP and SECTION_ALIGN_DOWN.

> +static unsigned long pfn_to_maxpage_up(unsigned long pfn)
> +{
> +	return ALIGN(pfn, MAX_ORDER_NR_PAGES);
> +}
> +
> +#define MIGRATION_RETRY	5
> +static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
> +{
> +	int migration_failed = 0, ret;
> +	unsigned long pfn = start;
> +
> +	/*
> +	 * Some code "borrowed" from KAMEZAWA Hiroyuki's
> +	 * __alloc_contig_pages().
> +	 */
> +

There is no need to put a comment like this here. Credit him in the
changelog.

> +	/* drop all pages in pagevec and pcp list */
> +	lru_add_drain_all();
> +	drain_all_pages();
> +

Very similar to migrate_prep(). drain_all_pages should not be required
at this point.

> +	for (;;) {
> +		pfn = scan_lru_pages(pfn, end);

scan_lru_pages() is inefficient, this is going to be costly.

> +		if (!pfn || pfn >= end)
> +			break;
> +
> +		ret = do_migrate_range(pfn, end);
> +		if (!ret) {
> +			migration_failed = 0;
> +		} else if (ret != -EBUSY
> +			|| ++migration_failed >= MIGRATION_RETRY) {
> +			return ret;
> +		} else {
> +			/* There are unstable pages.on pagevec. */
> +			lru_add_drain_all();
> +			/*
> +			 * there may be pages on pcplist before
> +			 * we mark the range as ISOLATED.
> +			 */
> +			drain_all_pages();
> +		}
> +		cond_resched();
> +	}
> +
> +	if (!migration_failed) {
> +		/* drop all pages in pagevec and pcp list */
> +		lru_add_drain_all();
> +		drain_all_pages();
> +	}
> +
> +	/* Make sure all pages are isolated */
> +	if (WARN_ON(test_pages_isolated(start, end)))
> +		return -EBUSY;
> +

In some respects, this is very similar to mm/compaction#compact_zone().
They could have shared significant code if you reworked compact_zone
to work on ranges of memory and express compact_zone to operate on
zone->zone_start_pfn zone->zone_start_pfn+zone->spanned_pages . The
compaction code is 

> +	return 0;
> +}
> +
> +/**
> + * alloc_contig_range() -- tries to allocate given range of pages
> + * @start:	start PFN to allocate
> + * @end:	one-past-the-last PFN to allocate
> + * @flags:	flags passed to alloc_contig_freed_pages().
> + *
> + * The PFN range does not have to be pageblock or MAX_ORDER_NR_PAGES
> + * aligned, hovewer it's callers responsibility to guarantee that we
> + * are the only thread that changes migrate type of pageblocks the
> + * pages fall in.
> + *
> + * Returns zero on success or negative error code.  On success all
> + * pages which PFN is in (start, end) are allocated for the caller and
> + * need to be freed with free_contig_pages().
> + */
> +int alloc_contig_range(unsigned long start, unsigned long end,
> +		       gfp_t flags)
> +{
> +	unsigned long outer_start, outer_end;
> +	int ret;
> +
> +	/*
> +	 * What we do here is we mark all pageblocks in range as
> +	 * MIGRATE_ISOLATE.  Because of the way page allocator work, we
> +	 * align the range to MAX_ORDER pages so that page allocator
> +	 * won't try to merge buddies from different pageblocks and
> +	 * change MIGRATE_ISOLATE to some other migration type.
> +	 *

This part is new. compaction does not need to do this nor does it need
to. I can see though why it would be important for CMA though and
calling start_isolate_page_range() is reasonable.

There are alignment problems because it'll be on a pageblock boundary
but that is not a significant problem.

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
> +	ret = start_isolate_page_range(pfn_to_maxpage(start),
> +				       pfn_to_maxpage_up(end));
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
> +	ret = 0;
> +	while (!PageBuddy(pfn_to_page(start & (~0UL << ret))))
> +		if (WARN_ON(++ret >= MAX_ORDER))
> +			return -EINVAL;
> +
> +	outer_start = start & (~0UL << ret);
> +	outer_end   = alloc_contig_freed_pages(outer_start, end, flags);
> +
> +	/* Free head and tail (if any) */
> +	if (start != outer_start)
> +		free_contig_pages(outer_start, start - outer_start);
> +	if (end != outer_end)
> +		free_contig_pages(end, outer_end - end);
> +
> +	ret = 0;
> +done:
> +	undo_isolate_page_range(pfn_to_maxpage(start), pfn_to_maxpage_up(end));
> +	return ret;
> +}
> +
>  #ifdef CONFIG_MEMORY_HOTREMOVE
>  /*
>   * All pages in the range must be isolated before calling this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
