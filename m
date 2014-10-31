Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id 20A01280037
	for <linux-mm@kvack.org>; Fri, 31 Oct 2014 10:39:19 -0400 (EDT)
Received: by mail-la0-f44.google.com with SMTP id gf13so6364909lab.17
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 07:39:19 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id xv1si16944748lbb.119.2014.10.31.07.39.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 31 Oct 2014 07:39:18 -0700 (PDT)
Message-ID: <54539F11.7080501@suse.cz>
Date: Fri, 31 Oct 2014 15:39:13 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v5 4/4] mm/page_alloc: restrict max order of merging on
 isolated pageblock
References: <1414740330-4086-1-git-send-email-iamjoonsoo.kim@lge.com> <1414740330-4086-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1414740330-4086-5-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On 10/31/2014 08:25 AM, Joonsoo Kim wrote:
> @@ -571,6 +548,7 @@ static inline void __free_one_page(struct page *page,
>   	unsigned long combined_idx;
>   	unsigned long uninitialized_var(buddy_idx);
>   	struct page *buddy;
> +	int max_order = MAX_ORDER;
>
>   	VM_BUG_ON(!zone_is_initialized(zone));
>
> @@ -579,15 +557,23 @@ static inline void __free_one_page(struct page *page,
>   			return;
>
>   	VM_BUG_ON(migratetype == -1);
> -	if (!is_migrate_isolate(migratetype))
> +	if (is_migrate_isolate(migratetype)) {
> +		/*
> +		 * We restrict max order of merging to prevent merge
> +		 * between freepages on isolate pageblock and normal
> +		 * pageblock. Without this, pageblock isolation
> +		 * could cause incorrect freepage accounting.
> +		 */
> +		max_order = min(MAX_ORDER, pageblock_order + 1);
> +	} else
>   		__mod_zone_freepage_state(zone, 1 << order, migratetype);

Please add { } to the else branch, this looks ugly :)

> -	page_idx = pfn & ((1 << MAX_ORDER) - 1);
> +	page_idx = pfn & ((1 << max_order) - 1);
>
>   	VM_BUG_ON_PAGE(page_idx & ((1 << order) - 1), page);
>   	VM_BUG_ON_PAGE(bad_range(zone, page), page);
>
> -	while (order < MAX_ORDER-1) {
> +	while (order < max_order - 1) {
>   		buddy_idx = __find_buddy_index(page_idx, order);
>   		buddy = page + (buddy_idx - page_idx);
>   		if (!page_is_buddy(page, buddy, order))
> @@ -1590,7 +1576,7 @@ void split_page(struct page *page, unsigned int order)
>   }
>   EXPORT_SYMBOL_GPL(split_page);
>
> -static int __isolate_free_page(struct page *page, unsigned int order)
> +int __isolate_free_page(struct page *page, unsigned int order)
>   {
>   	unsigned long watermark;
>   	struct zone *zone;
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index 1fa4a4d..df61c93 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -76,17 +76,48 @@ void unset_migratetype_isolate(struct page *page, unsigned migratetype)
>   {
>   	struct zone *zone;
>   	unsigned long flags, nr_pages;
> +	struct page *isolated_page = NULL;
> +	unsigned int order;
> +	unsigned long page_idx, buddy_idx;
> +	struct page *buddy;
> +	int mt;
>
>   	zone = page_zone(page);
>   	spin_lock_irqsave(&zone->lock, flags);
>   	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
>   		goto out;
> +
> +	/*
> +	 * Because freepage with more than pageblock_order on isolated
> +	 * pageblock is restricted to merge due to freepage counting problem,
> +	 * it is possible that there is free buddy page.
> +	 * move_freepages_block() doesn't care of merge so we need other
> +	 * approach in order to merge them. Isolation and free will make
> +	 * these pages to be merged.
> +	 */
> +	if (PageBuddy(page)) {
> +		order = page_order(page);
> +		if (order >= pageblock_order) {
> +			page_idx = page_to_pfn(page) & ((1 << MAX_ORDER) - 1);
> +			buddy_idx = __find_buddy_index(page_idx, order);
> +			buddy = page + (buddy_idx - page_idx);
> +			mt = get_pageblock_migratetype(buddy);
> +
> +			if (!is_migrate_isolate(mt)) {

You could use is_migrate_isolate_page(buddy) and save a variable.

> +				__isolate_free_page(page, order);
> +				set_page_refcounted(page);
> +				isolated_page = page;
> +			}
> +		}
> +	}
>   	nr_pages = move_freepages_block(zone, page, migratetype);

- this is a costly no-op when the whole pageblock is an isolated page, 
right?

>   	__mod_zone_freepage_state(zone, nr_pages, migratetype);

- with isolated_page set, this means you increase freepage_state here, 
and then the second time in __free_pages() below? __isolate_free_page() 
won't decrease it as the pageblock is still MIGRATE_ISOLATE, so the net 
result is overcounting?

>   	set_pageblock_migratetype(page, migratetype);
>   	zone->nr_isolate_pageblock--;
>   out:
>   	spin_unlock_irqrestore(&zone->lock, flags);
> +	if (isolated_page)
> +		__free_pages(isolated_page, order);
>   }
>
>   static inline struct page *
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
