Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 82A896B00AA
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 07:52:51 -0400 (EDT)
Received: by pxi12 with SMTP id 12so1845218pxi.22
        for <linux-mm@kvack.org>; Fri, 28 Aug 2009 04:52:57 -0700 (PDT)
Date: Fri, 28 Aug 2009 20:52:41 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 1/2] page-allocator: Split per-cpu list into
 one-list-per-migrate-type
Message-Id: <20090828205241.fc8dfa51.minchan.kim@barrios-desktop>
In-Reply-To: <1251449067-3109-2-git-send-email-mel@csn.ul.ie>
References: <1251449067-3109-1-git-send-email-mel@csn.ul.ie>
	<1251449067-3109-2-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi, Mel. 

On Fri, 28 Aug 2009 09:44:26 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> Currently the per-cpu page allocator searches the PCP list for pages of the
> correct migrate-type to reduce the possibility of pages being inappropriate
> placed from a fragmentation perspective. This search is potentially expensive
> in a fast-path and undesirable. Splitting the per-cpu list into multiple
> lists increases the size of a per-cpu structure and this was potentially
> a major problem at the time the search was introduced. These problem has
> been mitigated as now only the necessary number of structures is allocated
> for the running system.
> 
> This patch replaces a list search in the per-cpu allocator with one list per
> migrate type. The potential snag with this approach is when bulk freeing
> pages. We round-robin free pages based on migrate type which has little
> bearing on the cache hotness of the page and potentially checks empty lists
> repeatedly in the event the majority of PCP pages are of one type.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Acked-by: Nick Piggin <npiggin@suse.de>
> ---
>  include/linux/mmzone.h |    5 ++-
>  mm/page_alloc.c        |  106 ++++++++++++++++++++++++++---------------------
>  2 files changed, 63 insertions(+), 48 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 008cdcd..045348f 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -38,6 +38,7 @@
>  #define MIGRATE_UNMOVABLE     0
>  #define MIGRATE_RECLAIMABLE   1
>  #define MIGRATE_MOVABLE       2
> +#define MIGRATE_PCPTYPES      3 /* the number of types on the pcp lists */
>  #define MIGRATE_RESERVE       3
>  #define MIGRATE_ISOLATE       4 /* can't allocate from here */
>  #define MIGRATE_TYPES         5
> @@ -169,7 +170,9 @@ struct per_cpu_pages {
>  	int count;		/* number of pages in the list */
>  	int high;		/* high watermark, emptying needed */
>  	int batch;		/* chunk size for buddy add/remove */
> -	struct list_head list;	/* the list of pages */
> +
> +	/* Lists of pages, one per migrate type stored on the pcp-lists */
> +	struct list_head lists[MIGRATE_PCPTYPES];
>  };
>  
>  struct per_cpu_pageset {
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ac3afe1..65eedb5 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -522,7 +522,7 @@ static inline int free_pages_check(struct page *page)
>  }
>  
>  /*
> - * Frees a list of pages. 
> + * Frees a number of pages from the PCP lists
>   * Assumes all pages on list are in same zone, and of same order.
>   * count is the number of pages to free.
>   *
> @@ -532,23 +532,36 @@ static inline int free_pages_check(struct page *page)
>   * And clear the zone's pages_scanned counter, to hold off the "all pages are
>   * pinned" detection logic.
>   */
> -static void free_pages_bulk(struct zone *zone, int count,
> -					struct list_head *list, int order)
> +static void free_pcppages_bulk(struct zone *zone, int count,
> +					struct per_cpu_pages *pcp)
>  {
> +	int migratetype = 0;
> +

How about caching the last sucess migratetype
with 'per_cpu_pages->last_alloc_type'?
I think it could prevent a litte spinning empty list.

>  	spin_lock(&zone->lock);
>  	zone_clear_flag(zone, ZONE_ALL_UNRECLAIMABLE);
>  	zone->pages_scanned = 0;
>  
> -	__mod_zone_page_state(zone, NR_FREE_PAGES, count << order);
> +	__mod_zone_page_state(zone, NR_FREE_PAGES, count);
>  	while (count--) {
>  		struct page *page;
> +		struct list_head *list;
> +
> +		/*
> +		 * Remove pages from lists in a round-robin fashion. This spinning
> +		 * around potentially empty lists is bloody awful, alternatives that
> +		 * don't suck are welcome
> +		 */
> +		do {
> +			if (++migratetype == MIGRATE_PCPTYPES)
> +				migratetype = 0;
> +			list = &pcp->lists[migratetype];
> +		} while (list_empty(list));
>  
> -		VM_BUG_ON(list_empty(list));
>  		page = list_entry(list->prev, struct page, lru);
>  		/* have to delete it as __free_one_page list manipulates */
>  		list_del(&page->lru);
> -		trace_mm_page_pcpu_drain(page, order, page_private(page));
> -		__free_one_page(page, zone, order, page_private(page));
> +		trace_mm_page_pcpu_drain(page, 0, migratetype);
> +		__free_one_page(page, zone, 0, migratetype);
>  	}
>  	spin_unlock(&zone->lock);
>  }



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
