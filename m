Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1E7A96B0069
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 08:41:33 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id bk3so38932225wjc.4
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 05:41:33 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hf6si242732wjc.204.2016.12.01.05.41.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Dec 2016 05:41:31 -0800 (PST)
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v4
References: <20161201002440.5231-1-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <8c666476-f8b6-d468-6050-56e3b5ff84cd@suse.cz>
Date: Thu, 1 Dec 2016 14:41:29 +0100
MIME-Version: 1.0
In-Reply-To: <20161201002440.5231-1-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On 12/01/2016 01:24 AM, Mel Gorman wrote:

...

> @@ -1096,28 +1097,29 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>  	if (nr_scanned)
>  		__mod_node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED, -nr_scanned);
>
> -	while (count) {
> +	while (count > 0) {
>  		struct page *page;
>  		struct list_head *list;
> +		unsigned int order;
>
>  		/*
>  		 * Remove pages from lists in a round-robin fashion. A
>  		 * batch_free count is maintained that is incremented when an
> -		 * empty list is encountered.  This is so more pages are freed
> -		 * off fuller lists instead of spinning excessively around empty
> -		 * lists
> +		 * empty list is encountered. This is not exact due to
> +		 * high-order but percision is not required.
>  		 */
>  		do {
>  			batch_free++;
> -			if (++migratetype == MIGRATE_PCPTYPES)
> -				migratetype = 0;
> -			list = &pcp->lists[migratetype];
> +			if (++pindex == NR_PCP_LISTS)
> +				pindex = 0;
> +			list = &pcp->lists[pindex];
>  		} while (list_empty(list));
>
>  		/* This is the only non-empty list. Free them all. */
> -		if (batch_free == MIGRATE_PCPTYPES)
> +		if (batch_free == NR_PCP_LISTS)
>  			batch_free = count;
>
> +		order = pindex_to_order(pindex);
>  		do {
>  			int mt;	/* migratetype of the to-be-freed page */
>
> @@ -1135,11 +1137,14 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>  			if (bulkfree_pcp_prepare(page))
>  				continue;

Hmm I think that if this hits, we don't decrease count/increase nr_freed and 
pcp->count will become wrong. And if we are unlucky/doing full drain, all lists 
will get empty, but as count stays e.g. 1, we loop forever on the outer while()?

BTW, I think there's a similar problem (but not introduced by this patch) in 
rmqueue_bulk() and its

     if (unlikely(check_pcp_refill(page)))
             continue;

This might result in pcp->count being higher than actual pages. That one would 
be introduced by 479f854a207c ("mm, page_alloc: defer debugging checks of pages 
allocated from the PCP").

>
> -			__free_one_page(page, page_to_pfn(page), zone, 0, mt);
> -			trace_mm_page_pcpu_drain(page, 0, mt);
> -		} while (--count && --batch_free && !list_empty(list));
> +			__free_one_page(page, page_to_pfn(page), zone, order, mt);
> +			trace_mm_page_pcpu_drain(page, order, mt);
> +			nr_freed += (1 << order);
> +			count -= (1 << order);
> +		} while (count > 0 && --batch_free && !list_empty(list));
>  	}
>  	spin_unlock(&zone->lock);
> +	pcp->count -= nr_freed;
>  }
>
>  static void free_one_page(struct zone *zone,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
