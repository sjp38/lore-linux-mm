Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 89B9E6B0035
	for <linux-mm@kvack.org>; Mon, 11 Aug 2014 21:40:53 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id y10so11797436pdj.0
        for <linux-mm@kvack.org>; Mon, 11 Aug 2014 18:40:53 -0700 (PDT)
Received: from mail-pd0-x22b.google.com (mail-pd0-x22b.google.com [2607:f8b0:400e:c02::22b])
        by mx.google.com with ESMTPS id n2si11223062pdm.111.2014.08.11.18.40.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 11 Aug 2014 18:40:52 -0700 (PDT)
Received: by mail-pd0-f171.google.com with SMTP id z10so11703888pdj.16
        for <linux-mm@kvack.org>; Mon, 11 Aug 2014 18:40:52 -0700 (PDT)
Date: Tue, 12 Aug 2014 01:45:23 +0000
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 2/8] mm/page_alloc: correct to clear guard attribute
 in DEBUG_PAGEALLOC
Message-ID: <20140812014523.GB23418@gmail.com>
References: <1407309517-3270-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1407309517-3270-5-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1407309517-3270-5-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Aug 06, 2014 at 04:18:30PM +0900, Joonsoo Kim wrote:
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

You are saying just "shouldn't do that" but don't say "why" and "result"
I know the reason but as you know, I'm one of the person who is rather
familiar with this part but I guess others should spend some time to get.
Kind detail description is never to look down on person. :)

> 

Nice catch, Joonsoo! But what make me worry is is this patch makes 3 thing
all at once.

1. fix - no candidate for stable
2. clean up
3. fix - candidate for stable.

Could you separate 3 and (1,2) in next spin?


> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  mm/page_alloc.c |   29 ++++++++++++++++-------------
>  1 file changed, 16 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 44672dc..3e1e344 100644
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
> -- 
> 1.7.9.5
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
