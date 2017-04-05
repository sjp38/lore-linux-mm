Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0551E6B03A2
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 04:14:06 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id w11so596803wrc.2
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 01:14:05 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k73si14402212wrc.281.2017.04.05.01.14.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 05 Apr 2017 01:14:04 -0700 (PDT)
Date: Wed, 5 Apr 2017 10:14:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1 1/6] mm: get rid of zone_is_initialized
Message-ID: <20170405081400.GE6035@dhcp22.suse.cz>
References: <20170330115454.32154-1-mhocko@kernel.org>
 <20170330115454.32154-2-mhocko@kernel.org>
 <20170331073954.GF27098@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170331073954.GF27098@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Fri 31-03-17 09:39:54, Michal Hocko wrote:
> Fixed screw ups during the initial patch split up as per Hillf
> ---
> From 8be6c5e47de66210e47710c80e72e8abd899017b Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Wed, 29 Mar 2017 15:11:30 +0200
> Subject: [PATCH] mm: get rid of zone_is_initialized
> 
> There shouldn't be any reason to add initialized when we can tell the
> same thing from checking whether there are any pages spanned to the
> zone. Remove zone_is_initialized() and replace it by zone_is_empty
> which can be used for the same set of tests.
> 
> This shouldn't have any visible effect

I've decided to drop this patch. My main motivation was to simplify
the hotplug workflow/ The situation is more hairy than I expected,
though. On one hand all zones should be initialized early during the
hotplug in add_memory_resource but direct users of arch_add_memory will
need this to be called I suspect. Let's just keep the current status quo
and clean up it later. It is not really needed for this series.

> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/mmzone.h | 7 -------
>  mm/memory_hotplug.c    | 6 +++---
>  mm/page_alloc.c        | 3 +--
>  3 files changed, 4 insertions(+), 12 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 618499159a7c..3bac3ed71c7a 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -442,8 +442,6 @@ struct zone {
>  	seqlock_t		span_seqlock;
>  #endif
>  
> -	int initialized;
> -
>  	/* Write-intensive fields used from the page allocator */
>  	ZONE_PADDING(_pad1_)
>  
> @@ -520,11 +518,6 @@ static inline bool zone_spans_pfn(const struct zone *zone, unsigned long pfn)
>  	return zone->zone_start_pfn <= pfn && pfn < zone_end_pfn(zone);
>  }
>  
> -static inline bool zone_is_initialized(struct zone *zone)
> -{
> -	return zone->initialized;
> -}
> -
>  static inline bool zone_is_empty(struct zone *zone)
>  {
>  	return zone->spanned_pages == 0;
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 6fb6bd2df787..699f5a2a8efd 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -348,7 +348,7 @@ static void fix_zone_id(struct zone *zone, unsigned long start_pfn,
>  static int __ref ensure_zone_is_initialized(struct zone *zone,
>  			unsigned long start_pfn, unsigned long num_pages)
>  {
> -	if (!zone_is_initialized(zone))
> +	if (zone_is_empty(zone))
>  		return init_currently_empty_zone(zone, start_pfn, num_pages);
>  
>  	return 0;
> @@ -1051,7 +1051,7 @@ bool zone_can_shift(unsigned long pfn, unsigned long nr_pages,
>  
>  		/* no zones in use between current zone and target */
>  		for (i = idx + 1; i < target; i++)
> -			if (zone_is_initialized(zone - idx + i))
> +			if (!zone_is_empty(zone - idx + i))
>  				return false;
>  	}
>  
> @@ -1062,7 +1062,7 @@ bool zone_can_shift(unsigned long pfn, unsigned long nr_pages,
>  
>  		/* no zones in use between current zone and target */
>  		for (i = target + 1; i < idx; i++)
> -			if (zone_is_initialized(zone - idx + i))
> +			if (!zone_is_empty(zone - idx + i))
>  				return false;
>  	}
>  
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 5ee8a26fa383..756353d1e293 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -795,7 +795,7 @@ static inline void __free_one_page(struct page *page,
>  
>  	max_order = min_t(unsigned int, MAX_ORDER, pageblock_order + 1);
>  
> -	VM_BUG_ON(!zone_is_initialized(zone));
> +	VM_BUG_ON(zone_is_empty(zone));
>  	VM_BUG_ON_PAGE(page->flags & PAGE_FLAGS_CHECK_AT_PREP, page);
>  
>  	VM_BUG_ON(migratetype == -1);
> @@ -5535,7 +5535,6 @@ int __meminit init_currently_empty_zone(struct zone *zone,
>  			zone_start_pfn, (zone_start_pfn + size));
>  
>  	zone_init_free_lists(zone);
> -	zone->initialized = 1;
>  
>  	return 0;
>  }
> -- 
> 2.11.0
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
