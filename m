Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7C7186B0276
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 09:44:19 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id t17-v6so918427edr.21
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 06:44:19 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p41-v6si1131725edc.24.2018.07.19.06.44.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 06:44:18 -0700 (PDT)
Date: Thu, 19 Jul 2018 15:44:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 3/5] mm/page_alloc: Optimize free_area_init_core
Message-ID: <20180719134417.GC7193@dhcp22.suse.cz>
References: <20180719132740.32743-1-osalvador@techadventures.net>
 <20180719132740.32743-4-osalvador@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180719132740.32743-4-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: akpm@linux-foundation.org, pasha.tatashin@oracle.com, vbabka@suse.cz, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

On Thu 19-07-18 15:27:38, osalvador@techadventures.net wrote:
> From: Oscar Salvador <osalvador@suse.de>
> 
> In free_area_init_core we calculate the amount of managed pages
> we are left with, by substracting the memmap pages and the pages
> reserved for dma.
> With the values left, we also account the total of kernel pages and
> the total of pages.
> 
> Since memmap pages are calculated from zone->spanned_pages,
> let us only do these calculcations whenever zone->spanned_pages is greather
> than 0.

But why do we care? How do we test this? In other words, why is this
worth merging?

> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> ---
>  mm/page_alloc.c | 73 ++++++++++++++++++++++++++++++---------------------------
>  1 file changed, 38 insertions(+), 35 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 10b754fba5fa..f7a6f4e13f41 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6237,6 +6237,40 @@ static void pgdat_init_kcompactd(struct pglist_data *pgdat)
>  static void pgdat_init_kcompactd(struct pglist_data *pgdat) {}
>  #endif
>  
> +static unsigned long calc_remaining_pages(enum zone_type type, unsigned long freesize,
> +								unsigned long size)
> +{
> +	unsigned long memmap_pages = calc_memmap_size(size, freesize);
> +
> +	if(!is_highmem_idx(type)) {
> +		if (freesize >= memmap_pages) {
> +			freesize -= memmap_pages;
> +			if (memmap_pages)
> +				printk(KERN_DEBUG
> +					"  %s zone: %lu pages used for memmap\n",
> +					zone_names[type], memmap_pages);
> +		} else
> +			pr_warn("  %s zone: %lu pages exceeds freesize %lu\n",
> +				zone_names[type], memmap_pages, freesize);
> +	}
> +
> +	/* Account for reserved pages */
> +	if (type == 0 && freesize > dma_reserve) {
> +		freesize -= dma_reserve;
> +		printk(KERN_DEBUG "  %s zone: %lu pages reserved\n",
> +		zone_names[0], dma_reserve);
> +	}
> +
> +	if (!is_highmem_idx(type))
> +		nr_kernel_pages += freesize;
> +	/* Charge for highmem memmap if there are enough kernel pages */
> +	else if (nr_kernel_pages > memmap_pages * 2)
> +		nr_kernel_pages -= memmap_pages;
> +	nr_all_pages += freesize;
> +
> +	return freesize;
> +}
> +
>  /*
>   * Set up the zone data structures:
>   *   - mark all pages reserved
> @@ -6267,43 +6301,12 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
>  
>  	for (j = 0; j < MAX_NR_ZONES; j++) {
>  		struct zone *zone = pgdat->node_zones + j;
> -		unsigned long size, freesize, memmap_pages;
> +		unsigned long size = zone->spanned_pages;
> +		unsigned long freesize = zone->present_pages;
>  		unsigned long zone_start_pfn = zone->zone_start_pfn;
>  
> -		size = zone->spanned_pages;
> -		freesize = zone->present_pages;
> -
> -		/*
> -		 * Adjust freesize so that it accounts for how much memory
> -		 * is used by this zone for memmap. This affects the watermark
> -		 * and per-cpu initialisations
> -		 */
> -		memmap_pages = calc_memmap_size(size, freesize);
> -		if (!is_highmem_idx(j)) {
> -			if (freesize >= memmap_pages) {
> -				freesize -= memmap_pages;
> -				if (memmap_pages)
> -					printk(KERN_DEBUG
> -					       "  %s zone: %lu pages used for memmap\n",
> -					       zone_names[j], memmap_pages);
> -			} else
> -				pr_warn("  %s zone: %lu pages exceeds freesize %lu\n",
> -					zone_names[j], memmap_pages, freesize);
> -		}
> -
> -		/* Account for reserved pages */
> -		if (j == 0 && freesize > dma_reserve) {
> -			freesize -= dma_reserve;
> -			printk(KERN_DEBUG "  %s zone: %lu pages reserved\n",
> -					zone_names[0], dma_reserve);
> -		}
> -
> -		if (!is_highmem_idx(j))
> -			nr_kernel_pages += freesize;
> -		/* Charge for highmem memmap if there are enough kernel pages */
> -		else if (nr_kernel_pages > memmap_pages * 2)
> -			nr_kernel_pages -= memmap_pages;
> -		nr_all_pages += freesize;
> +		if (size)
> +			freesize = calc_remaining_pages(j, freesize, size);
>  
>  		/*
>  		 * Set an approximate value for lowmem here, it will be adjusted
> -- 
> 2.13.6
> 

-- 
Michal Hocko
SUSE Labs
