Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 76AA76B004D
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 07:43:40 -0400 (EDT)
Date: Tue, 18 Aug 2009 13:43:35 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 1/3] page-allocator: Split per-cpu list into one-list-per-migrate-type
Message-ID: <20090818114335.GO9962@wotan.suse.de>
References: <1250594162-17322-1-git-send-email-mel@csn.ul.ie> <1250594162-17322-2-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1250594162-17322-2-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 18, 2009 at 12:16:00PM +0100, Mel Gorman wrote:
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

Seems OK I guess. Trading off icache and branches for dcache and
algorithmic gains. Too bad everything is always a tradeoff ;)

But no I think this is a good idea.

> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  include/linux/mmzone.h |    5 ++-
>  mm/page_alloc.c        |  106 ++++++++++++++++++++++++++---------------------
>  2 files changed, 63 insertions(+), 48 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 9c50309..6e0b624 100644
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
> index 0e5baa9..a06ddf0 100644
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
> @@ -974,7 +987,7 @@ void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp)
>  		to_drain = pcp->batch;
>  	else
>  		to_drain = pcp->count;
> -	free_pages_bulk(zone, to_drain, &pcp->list, 0);
> +	free_pcppages_bulk(zone, to_drain, pcp);
>  	pcp->count -= to_drain;
>  	local_irq_restore(flags);
>  }
> @@ -1000,7 +1013,7 @@ static void drain_pages(unsigned int cpu)
>  
>  		pcp = &pset->pcp;
>  		local_irq_save(flags);
> -		free_pages_bulk(zone, pcp->count, &pcp->list, 0);
> +		free_pcppages_bulk(zone, pcp->count, pcp);
>  		pcp->count = 0;
>  		local_irq_restore(flags);
>  	}
> @@ -1066,6 +1079,7 @@ static void free_hot_cold_page(struct page *page, int cold)
>  	struct zone *zone = page_zone(page);
>  	struct per_cpu_pages *pcp;
>  	unsigned long flags;
> +	int migratetype;
>  	int wasMlocked = __TestClearPageMlocked(page);
>  
>  	kmemcheck_free_shadow(page, 0);
> @@ -1083,21 +1097,39 @@ static void free_hot_cold_page(struct page *page, int cold)
>  	kernel_map_pages(page, 1, 0);
>  
>  	pcp = &zone_pcp(zone, get_cpu())->pcp;
> -	set_page_private(page, get_pageblock_migratetype(page));
> +	migratetype = get_pageblock_migratetype(page);
> +	set_page_private(page, migratetype);
>  	local_irq_save(flags);
>  	if (unlikely(wasMlocked))
>  		free_page_mlock(page);
>  	__count_vm_event(PGFREE);
>  
> +	/*
> +	 * We only track unreclaimable, reclaimable and movable on pcp lists.
> +	 * Free ISOLATE pages back to the allocator because they are being
> +	 * offlined but treat RESERVE as movable pages so we can get those
> +	 * areas back if necessary. Otherwise, we may have to free
> +	 * excessively into the page allocator
> +	 */
> +	if (migratetype >= MIGRATE_PCPTYPES) {
> +		if (unlikely(migratetype == MIGRATE_ISOLATE)) {
> +			free_one_page(zone, page, 0, migratetype);
> +			goto out;
> +		}
> +		migratetype = MIGRATE_MOVABLE;
> +	}
> +
>  	if (cold)
> -		list_add_tail(&page->lru, &pcp->list);
> +		list_add_tail(&page->lru, &pcp->lists[migratetype]);
>  	else
> -		list_add(&page->lru, &pcp->list);
> +		list_add(&page->lru, &pcp->lists[migratetype]);
>  	pcp->count++;
>  	if (pcp->count >= pcp->high) {
> -		free_pages_bulk(zone, pcp->batch, &pcp->list, 0);
> +		free_pcppages_bulk(zone, pcp->batch, pcp);
>  		pcp->count -= pcp->batch;
>  	}
> +
> +out:
>  	local_irq_restore(flags);
>  	put_cpu();
>  }
> @@ -1155,46 +1187,24 @@ again:
>  	cpu  = get_cpu();
>  	if (likely(order == 0)) {
>  		struct per_cpu_pages *pcp;
> +		struct list_head *list;
>  
>  		pcp = &zone_pcp(zone, cpu)->pcp;
> +		list = &pcp->lists[migratetype];
>  		local_irq_save(flags);
> -		if (!pcp->count) {
> -			pcp->count = rmqueue_bulk(zone, 0,
> -					pcp->batch, &pcp->list,
> -					migratetype, cold);
> -			if (unlikely(!pcp->count))
> -				goto failed;
> -		}
> -
> -		/* Find a page of the appropriate migrate type */
> -		if (cold) {
> -			list_for_each_entry_reverse(page, &pcp->list, lru)
> -				if (page_private(page) == migratetype)
> -					break;
> -		} else {
> -			list_for_each_entry(page, &pcp->list, lru)
> -				if (page_private(page) == migratetype)
> -					break;
> -		}
> -
> -		/* Allocate more to the pcp list if necessary */
> -		if (unlikely(&page->lru == &pcp->list)) {
> -			int get_one_page = 0;
> -
> +		if (list_empty(list)) {
>  			pcp->count += rmqueue_bulk(zone, 0,
> -					pcp->batch, &pcp->list,
> +					pcp->batch, list,
>  					migratetype, cold);
> -			list_for_each_entry(page, &pcp->list, lru) {
> -				if (get_pageblock_migratetype(page) !=
> -					    MIGRATE_ISOLATE) {
> -					get_one_page = 1;
> -					break;
> -				}
> -			}
> -			if (!get_one_page)
> +			if (unlikely(list_empty(list)))
>  				goto failed;
>  		}
>  
> +		if (cold)
> +			page = list_entry(list->prev, struct page, lru);
> +		else
> +			page = list_entry(list->next, struct page, lru);
> +
>  		list_del(&page->lru);
>  		pcp->count--;
>  	} else {
> @@ -3033,6 +3043,7 @@ static int zone_batchsize(struct zone *zone)
>  static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch)
>  {
>  	struct per_cpu_pages *pcp;
> +	int migratetype;
>  
>  	memset(p, 0, sizeof(*p));
>  
> @@ -3040,7 +3051,8 @@ static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch)
>  	pcp->count = 0;
>  	pcp->high = 6 * batch;
>  	pcp->batch = max(1UL, 1 * batch);
> -	INIT_LIST_HEAD(&pcp->list);
> +	for (migratetype = 0; migratetype < MIGRATE_PCPTYPES; migratetype++)
> +		INIT_LIST_HEAD(&pcp->lists[migratetype]);
>  }
>  
>  /*
> @@ -3232,7 +3244,7 @@ static int __zone_pcp_update(void *data)
>  		pcp = &pset->pcp;
>  
>  		local_irq_save(flags);
> -		free_pages_bulk(zone, pcp->count, &pcp->list, 0);
> +		free_pcppages_bulk(zone, pcp->count, pcp);
>  		setup_pageset(pset, batch);
>  		local_irq_restore(flags);
>  	}
> -- 
> 1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
