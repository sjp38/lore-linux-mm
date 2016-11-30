Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 95DAA6B0038
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 08:05:54 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id g23so50800482wme.4
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 05:05:54 -0800 (PST)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id f9si63796871wjw.135.2016.11.30.05.05.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 05:05:52 -0800 (PST)
Received: by mail-wm0-f66.google.com with SMTP id m203so29328242wma.3
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 05:05:52 -0800 (PST)
Date: Wed, 30 Nov 2016 14:05:50 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v3
Message-ID: <20161130130549.GE18432@dhcp22.suse.cz>
References: <20161127131954.10026-1-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161127131954.10026-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Sun 27-11-16 13:19:54, Mel Gorman wrote:
[...]
> @@ -2588,18 +2594,22 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
>  	struct page *page;
>  	bool cold = ((gfp_flags & __GFP_COLD) != 0);
>  
> -	if (likely(order == 0)) {
> +	if (likely(order <= PAGE_ALLOC_COSTLY_ORDER)) {
>  		struct per_cpu_pages *pcp;
>  		struct list_head *list;
>  
>  		local_irq_save(flags);
>  		do {
> +			unsigned int pindex;
> +
> +			pindex = order_to_pindex(migratetype, order);
>  			pcp = &this_cpu_ptr(zone->pageset)->pcp;
> -			list = &pcp->lists[migratetype];
> +			list = &pcp->lists[pindex];
>  			if (list_empty(list)) {
> -				pcp->count += rmqueue_bulk(zone, 0,
> +				int nr_pages = rmqueue_bulk(zone, order,
>  						pcp->batch, list,
>  						migratetype, cold);
> +				pcp->count += (nr_pages << order);
>  				if (unlikely(list_empty(list)))
>  					goto failed;

just a nit, we can reorder the check and the count update because nobody
could have stolen pages allocated by rmqueue_bulk. I would also consider
nr_pages a bit misleading because we get a number or allocated elements.
Nothing to lose sleep over...

>  			}

But...  Unless I am missing something this effectively means that we do
not exercise high order atomic reserves. Shouldn't we fallback to
the locked __rmqueue_smallest(zone, order, MIGRATE_HIGHATOMIC) for
order > 0 && ALLOC_HARDER ? Or is this just hidden in some other code
path which I am not seeing?

Other than that the patch looks reasonable to me. Keeping some portion
of !costly pages on pcp lists sounds useful from the fragmentation
point of view as well AFAICS because it would be normally dissolved for
order-0 requests while we push on the reclaim more right now.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
