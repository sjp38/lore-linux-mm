Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id F2F156B01F7
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 09:47:09 -0400 (EDT)
Date: Thu, 15 Apr 2010 14:46:48 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/4] mm: introduce free_pages_bulk
Message-ID: <20100415134648.GF10966@csn.ul.ie>
References: <20100415085420.GT2493@dastard> <20100415185310.D1A1.A69D9226@jp.fujitsu.com> <20100415192412.D1AA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100415192412.D1AA.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 15, 2010 at 07:24:53PM +0900, KOSAKI Motohiro wrote:
> Now, vmscan is using __pagevec_free() for batch freeing. but
> pagevec consume slightly lots stack (sizeof(long)*8), and x86_64
> stack is very strictly limited.
> 
> Then, now we are planning to use page->lru list instead pagevec
> for reducing stack. and introduce new helper function.
> 
> This is similar to __pagevec_free(), but receive list instead
> pagevec. and this don't use pcp cache. it is good characteristics
> for vmscan.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  include/linux/gfp.h |    1 +
>  mm/page_alloc.c     |   44 ++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 45 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 4c6d413..dbcac56 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -332,6 +332,7 @@ extern void free_hot_cold_page(struct page *page, int cold);
>  #define __free_page(page) __free_pages((page), 0)
>  #define free_page(addr) free_pages((addr),0)
>  
> +void free_pages_bulk(struct zone *zone, struct list_head *list);
>  void page_alloc_init(void);
>  void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp);
>  void drain_all_pages(void);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ba9aea7..1f68832 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2049,6 +2049,50 @@ void free_pages(unsigned long addr, unsigned int order)
>  
>  EXPORT_SYMBOL(free_pages);
>  
> +/*
> + * Frees a number of pages from the list
> + * Assumes all pages on list are in same zone and order==0.
> + *
> + * This is similar to __pagevec_free(), but receive list instead pagevec.
> + * and this don't use pcp cache. it is good characteristics for vmscan.
> + */
> +void free_pages_bulk(struct zone *zone, struct list_head *list)
> +{
> +	unsigned long flags;
> +	struct page *page;
> +	struct page *page2;
> +	int nr_pages = 0;
> +
> +	list_for_each_entry_safe(page, page2, list, lru) {
> +		int wasMlocked = __TestClearPageMlocked(page);
> +
> +		if (free_pages_prepare(page, 0)) {
> +			/* Make orphan the corrupted page. */
> +			list_del(&page->lru);
> +			continue;
> +		}
> +		if (unlikely(wasMlocked)) {
> +			local_irq_save(flags);
> +			free_page_mlock(page);
> +			local_irq_restore(flags);
> +		}

You could clear this under the zone->lock below before calling
__free_one_page. It'd avoid a large number of IRQ enables and disables which
are a problem on some CPUs (P4 and Itanium both blow in this regard according
to PeterZ).

> +		nr_pages++;
> +	}
> +
> +	spin_lock_irqsave(&zone->lock, flags);
> +	__count_vm_events(PGFREE, nr_pages);
> +	zone->all_unreclaimable = 0;
> +	zone->pages_scanned = 0;
> +	__mod_zone_page_state(zone, NR_FREE_PAGES, nr_pages);
> +
> +	list_for_each_entry_safe(page, page2, list, lru) {
> +		/* have to delete it as __free_one_page list manipulates */
> +		list_del(&page->lru);
> +		__free_one_page(page, zone, 0, page_private(page));
> +	}

This has the effect of bypassing the per-cpu lists as well as making the
zone lock hotter. The cache hotness of the data within the page is
probably not a factor but the cache hotness of the stuct page is.

The zone lock getting hotter is a greater problem. Large amounts of page
reclaim or dumping of page cache will now contend on the zone lock where
as previously it would have dumped into the per-cpu lists (potentially
but not necessarily avoiding the zone lock).

While there might be a stack saving in the next patch, there would appear
to be definite performance implications in taking this patch.

Functionally, I see no problem but I'd put this sort of patch on the
very long finger until the performance aspects of it could be examined.

> +	spin_unlock_irqrestore(&zone->lock, flags);
> +}
> +
>  /**
>   * alloc_pages_exact - allocate an exact number physically-contiguous pages.
>   * @size: the number of bytes to allocate
> -- 
> 1.6.5.2
> 
> 
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
