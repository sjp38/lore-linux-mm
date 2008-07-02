Date: Wed, 02 Jul 2008 21:01:59 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] capture pages freed during direct reclaim for allocation by the reclaimer
In-Reply-To: <1214935122-20828-5-git-send-email-apw@shadowen.org>
References: <1214935122-20828-1-git-send-email-apw@shadowen.org> <1214935122-20828-5-git-send-email-apw@shadowen.org>
Message-Id: <20080702182909.D163.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Hi Andy,

I feel this is interesting patch.

but I'm worry about it become increase OOM occur.
What do you think?

and, Why don't you make patch against -mm tree?


> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d73e1e1..1ac703d 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -410,6 +410,51 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
>   * -- wli
>   */
>  
> +static inline void __capture_one_page(struct list_head *capture_list,
> +		struct page *page, struct zone *zone, unsigned int order)
> +{
> +	unsigned long page_idx;
> +	unsigned long order_size = 1UL << order;
> +
> +	if (unlikely(PageCompound(page)))
> +		destroy_compound_page(page, order);
> +
> +	page_idx = page_to_pfn(page) & ((1 << MAX_ORDER) - 1);
> +
> +	VM_BUG_ON(page_idx & (order_size - 1));
> +	VM_BUG_ON(bad_range(zone, page));
> +
> +	while (order < MAX_ORDER-1) {
> +		unsigned long combined_idx;
> +		struct page *buddy;
> +
> +		buddy = __page_find_buddy(page, page_idx, order);
> +		if (!page_is_buddy(page, buddy, order))
> +			break;
> +
> +		/* Our buddy is free, merge with it and move up one order. */
> +		list_del(&buddy->lru);
> +		if (PageBuddyCapture(buddy)) {
> +			buddy->buddy_free = 0;
> +			__ClearPageBuddyCapture(buddy);
> +		} else {
> +			zone->free_area[order].nr_free--;
> +			__mod_zone_page_state(zone,
> +					NR_FREE_PAGES, -(1UL << order));
> +		}
> +		rmv_page_order(buddy);
> +		combined_idx = __find_combined_index(page_idx, order);
> +		page = page + (combined_idx - page_idx);
> +		page_idx = combined_idx;
> +		order++;
> +	}
> +	set_page_order(page, order);
> +	__SetPageBuddyCapture(page);
> +	page->buddy_free = capture_list;
> +
> +	list_add(&page->lru, capture_list);
> +}

if we already have enough size page, 
shoudn't we release page to buddy list?

otherwise, increase oom risk.
or, Am I misunderstanding?


>  static inline void __free_one_page(struct page *page,
>  		struct zone *zone, unsigned int order)
>  {
> @@ -433,6 +478,12 @@ static inline void __free_one_page(struct page *page,
>  		buddy = __page_find_buddy(page, page_idx, order);
>  		if (!page_is_buddy(page, buddy, order))
>  			break;
> +		if (PageBuddyCapture(buddy)) {
> +			__mod_zone_page_state(zone,
> +					NR_FREE_PAGES, -(1UL << order));
> +			return __capture_one_page(buddy->buddy_free,
> +							page, zone, order);
> +		}

shouldn't you make captured page's zonestat?
otherwise, administrator can't trouble shooting.


>  	/* Can pages be swapped as part of reclaim? */
> @@ -78,6 +80,12 @@ struct scan_control {
>  			unsigned long *scanned, int order, int mode,
>  			struct zone *z, struct mem_cgroup *mem_cont,
>  			int active);
> +
> +	/* Captured page. */
> +	struct page **capture;
> +	
> +	/* Nodemask for acceptable allocations. */
> +	nodemask_t *nodemask;
>  };

please more long comment.
anybody think about scan_control is reclaim purpose structure.
So, probably they think "Why is this member needed?".




> @@ -1314,8 +1360,14 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  	unsigned long lru_pages = 0;
>  	struct zoneref *z;
>  	struct zone *zone;
> +	struct zone *preferred_zone;
>  	enum zone_type high_zoneidx = gfp_zone(sc->gfp_mask);
>  
> +	/* This should never fail as we should be scanning a real zonelist. */
> +	(void)first_zones_zonelist(zonelist, high_zoneidx, sc->nodemask,
> +							&preferred_zone);

nit.
(void) is unnecessary.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
