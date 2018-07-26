Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 85F286B0006
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 04:12:05 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d18-v6so501132edp.0
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 01:12:05 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r6-v6si829775edh.327.2018.07.26.01.12.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 01:12:04 -0700 (PDT)
Date: Thu, 26 Jul 2018 10:12:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 4/5] mm/page_alloc: Move initialization of node and
 zones to an own function
Message-ID: <20180726081200.GY28386@dhcp22.suse.cz>
References: <20180725220144.11531-1-osalvador@techadventures.net>
 <20180725220144.11531-5-osalvador@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180725220144.11531-5-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: akpm@linux-foundation.org, vbabka@suse.cz, pasha.tatashin@oracle.com, mgorman@techsingularity.net, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dan.j.williams@intel.com, Oscar Salvador <osalvador@suse.de>

On Thu 26-07-18 00:01:43, osalvador@techadventures.net wrote:
> From: Oscar Salvador <osalvador@suse.de>
> 
> Currently, whenever a new node is created/re-used from the memhotplug path,
> we call free_area_init_node()->free_area_init_core().
> But there is some code that we do not really need to run when we are coming
> from such path.
> 
> free_area_init_core() performs the following actions:
> 
> 1) Initializes pgdat internals, such as spinlock, waitqueues and more.
> 2) Account # nr_all_pages and nr_kernel_pages. These values are used later on
>    when creating hash tables.
> 3) Account number of managed_pages per zone, substracting dma_reserved and memmap pages.
> 4) Initializes some fields of the zone structure data
> 5) Calls init_currently_empty_zone to initialize all the freelists
> 6) Calls memmap_init to initialize all pages belonging to certain zone
> 
> When called from memhotplug path, free_area_init_core() only performs actions #1 and #4.
> 
> Action #2 is pointless as the zones do not have any pages since either the node was freed,
> or we are re-using it, eitherway all zones belonging to this node should have 0 pages.
> For the same reason, action #3 results always in manages_pages being 0.
> 
> Action #5 and #6 are performed later on when onlining the pages:
>  online_pages()->move_pfn_range_to_zone()->init_currently_empty_zone()
>  online_pages()->move_pfn_range_to_zone()->memmap_init_zone()
> 
> This patch moves the node/zone initializtion to their own function, so it allows us
> to create a small version of free_area_init_core(next patch), where we only perform:
> 
> 1) Initialization of pgdat internals, such as spinlock, waitqueues and more
> 4) Initialization of some fields of the zone structure data
> 
> This patch only introduces these two functions.

OK, this looks definitely better. I will have to check that all the
required state is initialized properly. Considering the above
explanation I would simply fold the follow up patch into this one. It is
not so large it would get hard to review and you would make it clear why
the work is done.

> +/*
> + * Set up the zone data structures:
> + *   - mark all pages reserved
> + *   - mark all memory queues empty
> + *   - clear the memory bitmaps
> + *
> + * NOTE: pgdat should get zeroed by caller.
> + * NOTE: this function is only called during early init.
> + */
> +static void __paginginit free_area_init_core(struct pglist_data *pgdat)

now that this function is called only from the early init code we can
make it s@__paginginit@__init@ AFAICS.

> +{
> +	enum zone_type j;
> +	int nid = pgdat->node_id;
>  
> +	pgdat_init_internals(pgdat);
>  	pgdat->per_cpu_nodestats = &boot_nodestats;
>  
>  	for (j = 0; j < MAX_NR_ZONES; j++) {
> @@ -6310,13 +6326,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
>  		 * when the bootmem allocator frees pages into the buddy system.
>  		 * And all highmem pages will be managed by the buddy system.
>  		 */
> -		zone->managed_pages = freesize;
> -		zone_set_nid(zone, nid);
> -		zone->name = zone_names[j];
> -		zone->zone_pgdat = pgdat;
> -		spin_lock_init(&zone->lock);
> -		zone_seqlock_init(zone);
> -		zone_pcp_init(zone);
> +		zone_init_internals(zone, j, nid, freesize);
>  
>  		if (!size)
>  			continue;
> -- 
> 2.13.6
> 

-- 
Michal Hocko
SUSE Labs
