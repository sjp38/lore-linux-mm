Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 664076B0035
	for <linux-mm@kvack.org>; Wed,  6 Aug 2014 21:48:16 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id z10so4290367pdj.30
        for <linux-mm@kvack.org>; Wed, 06 Aug 2014 18:48:16 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id bl11si1096005pdb.374.2014.08.06.18.48.13
        for <linux-mm@kvack.org>;
        Wed, 06 Aug 2014 18:48:15 -0700 (PDT)
Message-ID: <53E2DA85.8020601@cn.fujitsu.com>
Date: Thu, 7 Aug 2014 09:46:45 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/8] mm/page_alloc: correct to clear guard attribute
 in DEBUG_PAGEALLOC
References: <1407309517-3270-1-git-send-email-iamjoonsoo.kim@lge.com> <1407309517-3270-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1407309517-3270-2-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/06/2014 03:18 PM, Joonsoo Kim wrote:
> In __free_one_page(), we check the buddy page if it is guard page.
> And, if so, we should clear guard attribute on the buddy page. But,
> currently, we clear original page's order rather than buddy one's.
> This doesn't have any problem, because resetting buddy's order
> is useless and the original page's order is re-assigned soon.
> But, it is better to correct code.
> 
> Additionally, I change (set/clear)_page_guard_flag() to
> (set/clear)_page_guard() and makes these functions do all works
> needed for guard page. This may make code more understandable.
> 
> One more thing, I did in this patch, is that fixing freepage accounting.
> If we clear guard page and link it onto isolate buddy list, we should
> not increase freepage count.
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

> ---
>  mm/page_alloc.c |   29 ++++++++++++++++-------------
>  1 file changed, 16 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index b99643d4..e6fee4b 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -441,18 +441,28 @@ static int __init debug_guardpage_minorder_setup(char *buf)
>  }
>  __setup("debug_guardpage_minorder=", debug_guardpage_minorder_setup);
>  
> -static inline void set_page_guard_flag(struct page *page)
> +static inline void set_page_guard(struct zone *zone, struct page *page,
> +				unsigned int order, int migratetype)
>  {
>  	__set_bit(PAGE_DEBUG_FLAG_GUARD, &page->debug_flags);
> +	set_page_private(page, order);
> +	/* Guard pages are not available for any usage */
> +	__mod_zone_freepage_state(zone, -(1 << order), migratetype);
>  }
>  
> -static inline void clear_page_guard_flag(struct page *page)
> +static inline void clear_page_guard(struct zone *zone, struct page *page,
> +				unsigned int order, int migratetype)
>  {
>  	__clear_bit(PAGE_DEBUG_FLAG_GUARD, &page->debug_flags);
> +	set_page_private(page, 0);
> +	if (!is_migrate_isolate(migratetype))
> +		__mod_zone_freepage_state(zone, (1 << order), migratetype);
>  }
>  #else
> -static inline void set_page_guard_flag(struct page *page) { }
> -static inline void clear_page_guard_flag(struct page *page) { }
> +static inline void set_page_guard(struct zone *zone, struct page *page,
> +				unsigned int order, int migratetype) {}
> +static inline void clear_page_guard(struct zone *zone, struct page *page,
> +				unsigned int order, int migratetype) {}
>  #endif
>  
>  static inline void set_page_order(struct page *page, unsigned int order)
> @@ -594,10 +604,7 @@ static inline void __free_one_page(struct page *page,
>  		 * merge with it and move up one order.
>  		 */
>  		if (page_is_guard(buddy)) {
> -			clear_page_guard_flag(buddy);
> -			set_page_private(page, 0);
> -			__mod_zone_freepage_state(zone, 1 << order,
> -						  migratetype);
> +			clear_page_guard(zone, buddy, order, migratetype);
>  		} else {
>  			list_del(&buddy->lru);
>  			zone->free_area[order].nr_free--;
> @@ -876,11 +883,7 @@ static inline void expand(struct zone *zone, struct page *page,
>  			 * pages will stay not present in virtual address space
>  			 */
>  			INIT_LIST_HEAD(&page[size].lru);
> -			set_page_guard_flag(&page[size]);
> -			set_page_private(&page[size], high);
> -			/* Guard pages are not available for any usage */
> -			__mod_zone_freepage_state(zone, -(1 << high),
> -						  migratetype);
> +			set_page_guard(zone, &page[size], high, migratetype);
>  			continue;
>  		}
>  #endif
> 


-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
