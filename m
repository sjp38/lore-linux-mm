Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 726CB6B026E
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 09:36:50 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y17-v6so1930582eds.22
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 06:36:50 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w44-v6si2710127edb.165.2018.07.18.06.36.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 06:36:48 -0700 (PDT)
Date: Wed, 18 Jul 2018 15:36:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/3] mm/page_alloc: Refactor free_area_init_core
Message-ID: <20180718133647.GD7193@dhcp22.suse.cz>
References: <20180718124722.9872-1-osalvador@techadventures.net>
 <20180718124722.9872-3-osalvador@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180718124722.9872-3-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: akpm@linux-foundation.org, pasha.tatashin@oracle.com, vbabka@suse.cz, iamjoonsoo.kim@lge.com, aaron.lu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

On Wed 18-07-18 14:47:21, osalvador@techadventures.net wrote:
> From: Oscar Salvador <osalvador@suse.de>
> 
> When free_area_init_core gets called from the memhotplug code,
> we only need to perform some of the operations in
> there.

Which ones? Or other way around. Which we do not want to do and why?

> Since memhotplug code is the only place where free_area_init_core
> gets called while node being still offline, we can better separate
> the context from where it is called.

I really do not like this if node is offline than only perform half of
the function. This will generate more mess in the future. Why don't you
simply. If we can split out this code into logical units then let's do
that but no, please do not make random ifs for hotplug code paths.
Sooner or later somebody will simply don't know what is needed and what
is not.

> This patch re-structures the code for that purpose.
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> ---
>  mm/page_alloc.c | 94 +++++++++++++++++++++++++++++++--------------------------
>  1 file changed, 52 insertions(+), 42 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 8a73305f7c55..d652a3ad720c 100644
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
> @@ -6249,6 +6283,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
>  {
>  	enum zone_type j;
>  	int nid = pgdat->node_id;
> +	bool no_hotplug_context;
>  
>  	pgdat_resize_init(pgdat);
>  
> @@ -6265,45 +6300,18 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
>  
>  	pgdat->per_cpu_nodestats = &boot_nodestats;
>  
> +	/* Memhotplug is the only place where free_area_init_node gets called
> +	 * with the node being still offline.
> +	 */
> +	no_hotplug_context = node_online(nid);
> +
>  	for (j = 0; j < MAX_NR_ZONES; j++) {
>  		struct zone *zone = pgdat->node_zones + j;
> -		unsigned long size, freesize, memmap_pages;
> -		unsigned long zone_start_pfn = zone->zone_start_pfn;
> +		unsigned long size = zone->spanned_pages;
> +		unsigned long freesize = zone->present_pages;
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
> +		if (no_hotplug_context)
> +			freesize = calc_remaining_pages(j, freesize, size);
>  
>  		/*
>  		 * Set an approximate value for lowmem here, it will be adjusted
> @@ -6311,6 +6319,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
>  		 * And all highmem pages will be managed by the buddy system.
>  		 */
>  		zone->managed_pages = freesize;
> +
>  #ifdef CONFIG_NUMA
>  		zone->node = nid;
>  #endif
> @@ -6320,13 +6329,14 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
>  		zone_seqlock_init(zone);
>  		zone_pcp_init(zone);
>  
> -		if (!size)
> -			continue;
> +		if (size && no_hotplug_context) {
> +			unsigned long zone_start_pfn = zone->zone_start_pfn;
>  
> -		set_pageblock_order();
> -		setup_usemap(pgdat, zone, zone_start_pfn, size);
> -		init_currently_empty_zone(zone, zone_start_pfn, size);
> -		memmap_init(size, nid, j, zone_start_pfn);
> +			set_pageblock_order();
> +			setup_usemap(pgdat, zone, zone_start_pfn, size);
> +			init_currently_empty_zone(zone, zone_start_pfn, size);
> +			memmap_init(size, nid, j, zone_start_pfn);
> +		}
>  	}
>  }
>  
> -- 
> 2.13.6
> 

-- 
Michal Hocko
SUSE Labs
