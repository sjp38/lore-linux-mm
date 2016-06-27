Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7C9D96B0253
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 04:24:11 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id a66so66068623wme.1
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 01:24:11 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id tj15si24911482wjb.119.2016.06.27.01.24.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Jun 2016 01:24:09 -0700 (PDT)
Subject: Re: [PATCH v3 3/6] mm/cma: populate ZONE_CMA
References: <1464243748-16367-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1464243748-16367-4-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <1919a85d-6e1e-374f-b8c3-1236c36b0393@suse.cz>
Date: Mon, 27 Jun 2016 10:24:05 +0200
MIME-Version: 1.0
In-Reply-To: <1464243748-16367-4-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Rui Teng <rui.teng@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 05/26/2016 08:22 AM, js1304@gmail.com wrote:
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

I realize I differ here from much more experienced mm guys, and will 
probably deservingly regret it later on, but I think that the ZONE_CMA 
approach could work indeed better than current MIGRATE_CMA pageblocks.

My main worry is (naturally :) the effect on compaction overhead, due to 
potentially sparsely populated zones with holes that have to be scanned 
over - either ZONE_CMA itself, or the zones where pages were stolen from.

> ---
>  include/linux/memory_hotplug.h |  3 ---
>  mm/cma.c                       | 41 +++++++++++++++++++++++++++++++++++++++++
>  mm/internal.h                  |  3 +++
>  mm/page_alloc.c                | 26 ++++++++++++++++++++++++--
>  4 files changed, 68 insertions(+), 5 deletions(-)
>
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index a864d79..6fde69b 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -198,9 +198,6 @@ void put_online_mems(void);
>  void mem_hotplug_begin(void);
>  void mem_hotplug_done(void);
>
> -extern void set_zone_contiguous(struct zone *zone);
> -extern void clear_zone_contiguous(struct zone *zone);
> -
>  #else /* ! CONFIG_MEMORY_HOTPLUG */
>  /*
>   * Stub functions for when hotplug is off
> diff --git a/mm/cma.c b/mm/cma.c
> index ea506eb..8684f50 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -38,6 +38,7 @@
>  #include <trace/events/cma.h>
>
>  #include "cma.h"
> +#include "internal.h"
>
>  struct cma cma_areas[MAX_CMA_AREAS];
>  unsigned cma_area_count;
> @@ -145,6 +146,11 @@ err:
>  static int __init cma_init_reserved_areas(void)
>  {
>  	int i;
> +	struct zone *zone;
> +	unsigned long start_pfn = UINT_MAX, end_pfn = 0;
> +
> +	if (!cma_area_count)
> +		return 0;
>
>  	for (i = 0; i < cma_area_count; i++) {
>  		int ret = cma_activate_area(&cma_areas[i]);
> @@ -153,6 +159,41 @@ static int __init cma_init_reserved_areas(void)
>  			return ret;
>  	}
>
> +	for (i = 0; i < cma_area_count; i++) {
> +		if (start_pfn > cma_areas[i].base_pfn)
> +			start_pfn = cma_areas[i].base_pfn;
> +		if (end_pfn < cma_areas[i].base_pfn + cma_areas[i].count)
> +			end_pfn = cma_areas[i].base_pfn + cma_areas[i].count;
> +	}
> +
> +	for_each_populated_zone(zone) {
> +		if (!is_zone_cma(zone))
> +			continue;
> +
> +		/* ZONE_CMA doesn't need to exceed CMA region */
> +		zone->zone_start_pfn = max(zone->zone_start_pfn, start_pfn);
> +		zone->spanned_pages = min(zone_end_pfn(zone), end_pfn) -
> +					zone->zone_start_pfn;

So what's the typical spanned vs present pages here? Should there 
perhaps be some pr_warns about large holes?

> +	}
> +
> +	/*
> +	 * Reserved pages for ZONE_CMA are now activated and this would change
> +	 * ZONE_CMA's managed page counter and other zone's present counter.
> +	 * We need to re-calculate various zone information that depends on
> +	 * this initialization.
> +	 */
> +	build_all_zonelists(NULL, NULL);
> +	for_each_populated_zone(zone) {
> +		zone_pcp_update(zone);
> +		set_zone_contiguous(zone);
> +	}
> +
> +	/*
> +	 * We need to re-init per zone wmark by calling
> +	 * init_per_zone_wmark_min() but doesn't call here because it is
> +	 * registered on module_init and it will be called later than us.
> +	 */
> +
>  	return 0;
>  }
>  core_initcall(cma_init_reserved_areas);
> diff --git a/mm/internal.h b/mm/internal.h
> index b6ead95..4c37234 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -155,6 +155,9 @@ extern void __free_pages_bootmem(struct page *page, unsigned long pfn,
>  extern void prep_compound_page(struct page *page, unsigned int order);
>  extern int user_min_free_kbytes;
>
> +extern void set_zone_contiguous(struct zone *zone);
> +extern void clear_zone_contiguous(struct zone *zone);
> +
>  #if defined CONFIG_COMPACTION || defined CONFIG_CMA
>
>  /*
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 0197d5d..796b271 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1572,16 +1572,38 @@ void __init page_alloc_init_late(void)
>  }
>
>  #ifdef CONFIG_CMA
> +static void __init adjust_present_page_count(struct page *page, long count)
> +{
> +	struct zone *zone = page_zone(page);
> +
> +	/* We don't need to hold a lock since it is boot-up process */
> +	zone->present_pages += count;
> +}
> +
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

Ideally, zone's start_pfn and spanned_pages should be also adjusted if 
we stole from the beginning/end (which I suppose should be quite common?).

BTW, shouldn't it be possible with ZONE_CMA to drop the requirement in 
cma_activate_area() that all pages come (originally) from the same zone, 
after your series?

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
>
>  	set_pageblock_migratetype(page, MIGRATE_CMA);
>
> @@ -7545,7 +7567,7 @@ void free_contig_range(unsigned long pfn, unsigned nr_pages)
>  }
>  #endif
>
> -#ifdef CONFIG_MEMORY_HOTPLUG
> +#if defined CONFIG_MEMORY_HOTPLUG || defined CONFIG_CMA
>  /*
>   * The zone indicated has a new number of managed_pages; batch sizes and percpu
>   * page high values need to be recalulated.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
