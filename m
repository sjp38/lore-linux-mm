Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A22076B0263
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 05:20:22 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l138so36747929wmg.3
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 02:20:22 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k78si31963416wmi.122.2016.09.21.02.20.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Sep 2016 02:20:21 -0700 (PDT)
Subject: Re: [PATCH v5 3/6] mm/cma: populate ZONE_CMA
References: <1472447255-10584-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1472447255-10584-4-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d53d9318-1644-4750-6756-ccfb7325cdaa@suse.cz>
Date: Wed, 21 Sep 2016 11:20:11 +0200
MIME-Version: 1.0
In-Reply-To: <1472447255-10584-4-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 08/29/2016 07:07 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> Until now, reserved pages for CMA are managed in the ordinary zones
> where page's pfn are belong to. This approach has numorous problems
> and fixing them isn't easy. (It is mentioned on previous patch.)
> To fix this situation, ZONE_CMA is introduced in previous patch, but,
> not yet populated. This patch implement population of ZONE_CMA
> by stealing reserved pages from the ordinary zones.
>
> Unlike previous implementation that kernel allocation request with
> __GFP_MOVABLE could be serviced from CMA region, allocation request only
> with GFP_HIGHUSER_MOVABLE can be serviced from CMA region in the new
> approach. This is an inevitable design decision to use the zone
> implementation because ZONE_CMA could contain highmem. Due to this
> decision, ZONE_CMA will work like as ZONE_HIGHMEM or ZONE_MOVABLE.
>
> I don't think it would be a problem because most of file cache pages
> and anonymous pages are requested with GFP_HIGHUSER_MOVABLE. It could
> be proved by the fact that there are many systems with ZONE_HIGHMEM and
> they work fine. Notable disadvantage is that we cannot use these pages
> for blockdev file cache page, because it usually has __GFP_MOVABLE but
> not __GFP_HIGHMEM and __GFP_USER. But, in this case, there is pros and
> cons. In my experience, blockdev file cache pages are one of the top
> reason that causes cma_alloc() to fail temporarily. So, we can get more
> guarantee of cma_alloc() success by discarding that case.
>
> Implementation itself is very easy to understand. Steal when cma area is
> initialized and recalculate various per zone stat/threshold.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

...

> @@ -145,6 +145,28 @@ err:
>  static int __init cma_init_reserved_areas(void)
>  {
>  	int i;
> +	struct zone *zone;
> +	unsigned long start_pfn = UINT_MAX, end_pfn = 0;
> +
> +	if (!cma_area_count)
> +		return 0;
> +
> +	for (i = 0; i < cma_area_count; i++) {
> +		if (start_pfn > cma_areas[i].base_pfn)
> +			start_pfn = cma_areas[i].base_pfn;
> +		if (end_pfn < cma_areas[i].base_pfn + cma_areas[i].count)
> +			end_pfn = cma_areas[i].base_pfn + cma_areas[i].count;
> +	}
> +
> +	for_each_zone(zone) {
> +		if (!is_zone_cma(zone))
> +			continue;
> +
> +		/* ZONE_CMA doesn't need to exceed CMA region */
> +		zone->zone_start_pfn = max(zone->zone_start_pfn, start_pfn);
> +		zone->spanned_pages = min(zone_end_pfn(zone), end_pfn) -
> +					zone->zone_start_pfn;
> +	}

Hmm, so what happens on a system with multiple nodes? Each will have its 
own ZONE_CMA, and all will have the same start pfn and spanned pages?

>  /* Free whole pageblock and set its migration type to MIGRATE_CMA. */
>  void __init init_cma_reserved_pageblock(struct page *page)
>  {
>  	unsigned i = pageblock_nr_pages;
> +	unsigned long pfn = page_to_pfn(page);
>  	struct page *p = page;
> +	int nid = page_to_nid(page);
> +
> +	/*
> +	 * ZONE_CMA will steal present pages from other zones by changing
> +	 * page links so page_zone() is changed. Before that,
> +	 * we need to adjust previous zone's page count first.
> +	 */
> +	adjust_present_page_count(page, -pageblock_nr_pages);
>
>  	do {
>  		__ClearPageReserved(p);
>  		set_page_count(p, 0);
> -	} while (++p, --i);
> +
> +		/* Steal pages from other zones */
> +		set_page_links(p, ZONE_CMA, nid, pfn);
> +	} while (++p, ++pfn, --i);
> +
> +	adjust_present_page_count(page, pageblock_nr_pages);

This seems to assign pages to ZONE_CMA on the proper node, which is 
good. But then ZONE_CMA on multiple nodes will have unnecessary holes in 
the spanned pages, as each will contain only a subset.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
