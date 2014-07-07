Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 899BE6B0036
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 10:51:06 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id l18so1865189wgh.30
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 07:51:06 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ct8si45815558wjc.142.2014.07.07.07.51.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 07 Jul 2014 07:51:04 -0700 (PDT)
Message-ID: <53BAB3D3.6060603@suse.cz>
Date: Mon, 07 Jul 2014 16:50:59 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 02/10] mm/page_alloc: correct to clear guard attribute
 in DEBUG_PAGEALLOC
References: <1404460675-24456-1-git-send-email-iamjoonsoo.kim@lge.com> <1404460675-24456-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1404460675-24456-3-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/04/2014 09:57 AM, Joonsoo Kim wrote:
> In __free_one_page(), we check the buddy page if it is guard page.
> And, if so, we should clear guard attribute on the buddy page. But,
> currently, we clear original page's order rather than buddy one's.
> This doesn't have any problem, because resetting buddy's order
> is useless

Well it might theoretically confuse someone examining a crash dump, to 
see an unexpected page->private value. So I agree it should be corrected.

> and the original page's order is re-assigned soon.
> But, it is better to correct code.
>
> Additionally, I change (set/clear)_page_guard_flag() to
> (set/clear)_page_guard() and makes these functions do all works
> needed for guard page. This may make code more understandable.
>
> One more thing, I did in this patch, is that fixing freepage accounting.
> If we clear guard page and link it onto isolate buddy list, we should
> not increase freepage count.

OK, since this is under CONFIG_DEBUG_PAGEALLOC, and I don't see other 
solution in this case, I agree.

> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   mm/page_alloc.c |   29 ++++++++++++++++-------------
>   1 file changed, 16 insertions(+), 13 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 0d4cf7a..aeb51d1 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -441,18 +441,28 @@ static int __init debug_guardpage_minorder_setup(char *buf)
>   }
>   __setup("debug_guardpage_minorder=", debug_guardpage_minorder_setup);
>
> -static inline void set_page_guard_flag(struct page *page)
> +static inline void set_page_guard(struct zone *zone, struct page *page,
> +				unsigned int order, int migratetype)
>   {
>   	__set_bit(PAGE_DEBUG_FLAG_GUARD, &page->debug_flags);
> +	set_page_private(page, order);
> +	/* Guard pages are not available for any usage */
> +	__mod_zone_freepage_state(zone, -(1 << order), migratetype);
>   }
>
> -static inline void clear_page_guard_flag(struct page *page)
> +static inline void clear_page_guard(struct zone *zone, struct page *page,
> +				unsigned int order, int migratetype)
>   {
>   	__clear_bit(PAGE_DEBUG_FLAG_GUARD, &page->debug_flags);
> +	set_page_private(page, 0);
> +	if (!is_migrate_isolate(migratetype))
> +		__mod_zone_freepage_state(zone, (1 << order), migratetype);
>   }
>   #else
> -static inline void set_page_guard_flag(struct page *page) { }
> -static inline void clear_page_guard_flag(struct page *page) { }
> +static inline void set_page_guard(struct zone *zone, struct page *page,
> +				unsigned int order, int migratetype) {}
> +static inline void clear_page_guard(struct zone *zone, struct page *page,
> +				unsigned int order, int migratetype) {}
>   #endif
>
>   static inline void set_page_order(struct page *page, unsigned int order)
> @@ -594,10 +604,7 @@ static inline void __free_one_page(struct page *page,
>   		 * merge with it and move up one order.
>   		 */
>   		if (page_is_guard(buddy)) {
> -			clear_page_guard_flag(buddy);
> -			set_page_private(page, 0);
> -			__mod_zone_freepage_state(zone, 1 << order,
> -						  migratetype);
> +			clear_page_guard(zone, buddy, order, migratetype);
>   		} else {
>   			list_del(&buddy->lru);
>   			zone->free_area[order].nr_free--;
> @@ -919,11 +926,7 @@ static inline void expand(struct zone *zone, struct page *page,
>   			 * pages will stay not present in virtual address space
>   			 */
>   			INIT_LIST_HEAD(&page[size].lru);
> -			set_page_guard_flag(&page[size]);
> -			set_page_private(&page[size], high);
> -			/* Guard pages are not available for any usage */
> -			__mod_zone_freepage_state(zone, -(1 << high),
> -						  migratetype);
> +			set_page_guard(zone, &page[size], high, migratetype);
>   			continue;
>   		}
>   #endif
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
