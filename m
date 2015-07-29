Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5CA1C6B0254
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 08:25:18 -0400 (EDT)
Received: by wicgb10 with SMTP id gb10so198138084wic.1
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 05:25:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o3si26750628wic.109.2015.07.29.05.25.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Jul 2015 05:25:16 -0700 (PDT)
Subject: Re: [PATCH 10/10] mm, page_alloc: Only enforce watermarks for order-0
 allocations
References: <1437379219-9160-1-git-send-email-mgorman@suse.com>
 <1437379219-9160-11-git-send-email-mgorman@suse.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55B8C629.80303@suse.cz>
Date: Wed, 29 Jul 2015 14:25:13 +0200
MIME-Version: 1.0
In-Reply-To: <1437379219-9160-11-git-send-email-mgorman@suse.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.com>, Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Pintu Kumar <pintu.k@samsung.com>, Xishi Qiu <qiuxishi@huawei.com>, Gioh Kim <gioh.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

On 07/20/2015 10:00 AM, Mel Gorman wrote:

[...]

>  static bool __zone_watermark_ok(struct zone *z, unsigned int order,
>  			unsigned long mark, int classzone_idx, int alloc_flags,
> @@ -2259,7 +2261,7 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
>  {
>  	long min = mark;
>  	int o;
> -	long free_cma = 0;
> +	const bool atomic = (alloc_flags & ALLOC_HARDER);
>  
>  	/* free_pages may go negative - that's OK */
>  	free_pages -= (1 << order) - 1;
> @@ -2271,7 +2273,7 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
>  	 * If the caller is not atomic then discount the reserves. This will
>  	 * over-estimate how the atomic reserve but it avoids a search
>  	 */
> -	if (likely(!(alloc_flags & ALLOC_HARDER)))
> +	if (likely(!atomic))
>  		free_pages -= z->nr_reserved_highatomic;
>  	else
>  		min -= min / 4;
> @@ -2279,22 +2281,30 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
>  #ifdef CONFIG_CMA
>  	/* If allocation can't use CMA areas don't use free CMA pages */
>  	if (!(alloc_flags & ALLOC_CMA))
> -		free_cma = zone_page_state(z, NR_FREE_CMA_PAGES);
> +		free_pages -= zone_page_state(z, NR_FREE_CMA_PAGES);
>  #endif
>  
> -	if (free_pages - free_cma <= min + z->lowmem_reserve[classzone_idx])
> +	if (free_pages <= min + z->lowmem_reserve[classzone_idx])
>  		return false;
> -	for (o = 0; o < order; o++) {
> -		/* At the next order, this order's pages become unavailable */
> -		free_pages -= z->free_area[o].nr_free << o;
>  
> -		/* Require fewer higher order pages to be free */
> -		min >>= 1;
> +	/* order-0 watermarks are ok */
> +	if (!order)
> +		return true;
> +
> +	/* Check at least one high-order page is free */
> +	for (o = order; o < MAX_ORDER; o++) {
> +		struct free_area *area = &z->free_area[o];
> +		int mt;
> +
> +		if (atomic && area->nr_free)
> +			return true;

This may be a false positive due to MIGRATE_CMA or MIGRATE_ISOLATE pages being
the only free ones. But maybe it doesn't matter that much?

>  
> -		if (free_pages <= min)
> -			return false;
> +		for (mt = 0; mt < MIGRATE_PCPTYPES; mt++) {
> +			if (!list_empty(&area->free_list[mt]))
> +				return true;
> +		}

This may be a false negative for ALLOC_CMA allocations, if the only free pages
are of MIGRATE_CMA. Arguably that's the worse case than a false positive?

>  	}
> -	return true;
> +	return false;
>  }
>  
>  bool zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
