Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4EBE96B025E
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 05:23:30 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id r126so25190892wmr.2
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 02:23:30 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 196si17737545wmg.65.2017.01.24.02.23.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Jan 2017 02:23:29 -0800 (PST)
Subject: Re: [PATCH 1/4] mm, page_alloc: Split buffered_rmqueue
References: <20170123153906.3122-1-mgorman@techsingularity.net>
 <20170123153906.3122-2-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <8808c88d-3404-a3b5-b395-06936bbaa2ed@suse.cz>
Date: Tue, 24 Jan 2017 11:23:26 +0100
MIME-Version: 1.0
In-Reply-To: <20170123153906.3122-2-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jesper Dangaard Brouer <brouer@redhat.com>

On 01/23/2017 04:39 PM, Mel Gorman wrote:
> buffered_rmqueue removes a page from a given zone and uses the per-cpu
> list for order-0. This is fine but a hypothetical caller that wanted
> multiple order-0 pages has to disable/reenable interrupts multiple
> times. This patch structures buffere_rmqueue such that it's relatively
> easy to build a bulk order-0 page allocator. There is no functional
> change.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

But I think you need a fix on top

[...]

> -struct page *buffered_rmqueue(struct zone *preferred_zone,
> +struct page *rmqueue(struct zone *preferred_zone,
>  			struct zone *zone, unsigned int order,
>  			gfp_t gfp_flags, unsigned int alloc_flags,
>  			int migratetype)
>  {
>  	unsigned long flags;
>  	struct page *page;
> -	bool cold = ((gfp_flags & __GFP_COLD) != 0);
>  
>  	if (likely(order == 0)) {
> -		struct per_cpu_pages *pcp;
> -		struct list_head *list;
> -
> -		local_irq_save(flags);
> -		do {
> -			pcp = &this_cpu_ptr(zone->pageset)->pcp;
> -			list = &pcp->lists[migratetype];
> -			if (list_empty(list)) {
> -				pcp->count += rmqueue_bulk(zone, 0,
> -						pcp->batch, list,
> -						migratetype, cold);
> -				if (unlikely(list_empty(list)))
> -					goto failed;
> -			}
> -
> -			if (cold)
> -				page = list_last_entry(list, struct page, lru);
> -			else
> -				page = list_first_entry(list, struct page, lru);
> -
> -			list_del(&page->lru);
> -			pcp->count--;
> +		page = rmqueue_pcplist(preferred_zone, zone, order,
> +				gfp_flags, migratetype);
> +		goto out;

page might be NULL here...

> +	}
>  
> -		} while (check_new_pcp(page));
> -	} else {
> -		/*
> -		 * We most definitely don't want callers attempting to
> -		 * allocate greater than order-1 page units with __GFP_NOFAIL.
> -		 */
> -		WARN_ON_ONCE((gfp_flags & __GFP_NOFAIL) && (order > 1));
> -		spin_lock_irqsave(&zone->lock, flags);
> +	/*
> +	 * We most definitely don't want callers attempting to
> +	 * allocate greater than order-1 page units with __GFP_NOFAIL.
> +	 */
> +	WARN_ON_ONCE((gfp_flags & __GFP_NOFAIL) && (order > 1));
> +	spin_lock_irqsave(&zone->lock, flags);
>  
> -		do {
> -			page = NULL;
> -			if (alloc_flags & ALLOC_HARDER) {
> -				page = __rmqueue_smallest(zone, order, MIGRATE_HIGHATOMIC);
> -				if (page)
> -					trace_mm_page_alloc_zone_locked(page, order, migratetype);
> -			}
> -			if (!page)
> -				page = __rmqueue(zone, order, migratetype);
> -		} while (page && check_new_pages(page, order));
> -		spin_unlock(&zone->lock);
> +	do {
> +		page = NULL;
> +		if (alloc_flags & ALLOC_HARDER) {
> +			page = __rmqueue_smallest(zone, order, MIGRATE_HIGHATOMIC);
> +			if (page)
> +				trace_mm_page_alloc_zone_locked(page, order, migratetype);
> +		}
>  		if (!page)
> -			goto failed;
> -		__mod_zone_freepage_state(zone, -(1 << order),
> -					  get_pcppage_migratetype(page));
> -	}
> +			page = __rmqueue(zone, order, migratetype);
> +	} while (page && check_new_pages(page, order));
> +	spin_unlock(&zone->lock);
> +	if (!page)
> +		goto failed;
> +	__mod_zone_freepage_state(zone, -(1 << order),
> +				  get_pcppage_migratetype(page));
>  
>  	__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);
>  	zone_statistics(preferred_zone, zone);
>  	local_irq_restore(flags);
>  
> +out:
>  	VM_BUG_ON_PAGE(bad_range(zone, page), page);

... and then this explodes?
I guess the easiest fix is change the condition to
"page && bad_range(...)"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
