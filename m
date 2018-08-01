Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 428B96B0007
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 07:47:31 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id g15-v6so562595edm.11
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 04:47:31 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s21-v6si5403368eda.324.2018.08.01.04.47.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Aug 2018 04:47:29 -0700 (PDT)
Date: Wed, 1 Aug 2018 13:47:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v5 4/4] mm/page_alloc: Introduce
 free_area_init_core_hotplug
Message-ID: <20180801114726.GL16767@dhcp22.suse.cz>
References: <20180730101757.28058-1-osalvador@techadventures.net>
 <20180730101757.28058-5-osalvador@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180730101757.28058-5-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: akpm@linux-foundation.org, vbabka@suse.cz, pasha.tatashin@oracle.com, mgorman@techsingularity.net, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dan.j.williams@intel.com, david@redhat.com, Oscar Salvador <osalvador@suse.de>

On Mon 30-07-18 12:17:57, osalvador@techadventures.net wrote:
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
> 2) Account # nr_all_pages and # nr_kernel_pages. These values are used later on
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
> This patch does two things:
> 
> First, moves the node/zone initializtion to their own function, so it allows us
> to create a small version of free_area_init_core, where we only perform:
> 
> 1) Initialization of pgdat internals, such as spinlock, waitqueues and more
> 4) Initialization of some fields of the zone structure data
> 
> These two functions are: pgdat_init_internals() and zone_init_internals().
> 
> The second thing this patch does, is to introduce free_area_init_core_hotplug(),
> the memhotplug version of free_area_init_core():
> 
> Currently, we call free_area_init_node() from the memhotplug path.
> In there, we set some pgdat's fields, and call calculate_node_totalpages().
> calculate_node_totalpages() calculates the # of pages the node has.
> 
> Since the node is either new, or we are re-using it, the zones belonging to
> this node should not have any pages, so there is no point to calculate this now.
> 
> Actually, we re-set these values to 0 later on with the calls to:
> 
> reset_node_managed_pages()
> reset_node_present_pages()
> 
> The # of pages per node and the # of pages per zone will be calculated when
> onlining the pages:
> 
> online_pages()->move_pfn_range()->move_pfn_range_to_zone()->resize_zone_range()
> online_pages()->move_pfn_range()->move_pfn_range_to_zone()->resize_pgdat_range()
> 
> Also, since free_area_init_core/free_area_init_node will now only get called during early init, let us replace
> __paginginit with __init, so their code gets freed up.

The split up makes sense to me. Sections attributes can be handled on
top. Btw. free_area_init_core_hotplug declaration could have gone into
include/linux/memory_hotplug.h to save the ifdef

> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/mm.h  |  6 ++++-
>  mm/memory_hotplug.c | 16 ++++--------
>  mm/page_alloc.c     | 71 +++++++++++++++++++++++++++++++++++++----------------
>  3 files changed, 60 insertions(+), 33 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 6954ad183159..af3222785347 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1998,10 +1998,14 @@ static inline spinlock_t *pud_lock(struct mm_struct *mm, pud_t *pud)
>  
>  extern void __init pagecache_init(void);
>  extern void free_area_init(unsigned long * zones_size);
> -extern void free_area_init_node(int nid, unsigned long * zones_size,
> +extern void __init free_area_init_node(int nid, unsigned long * zones_size,
>  		unsigned long zone_start_pfn, unsigned long *zholes_size);
>  extern void free_initmem(void);
>  
> +#ifdef CONFIG_MEMORY_HOTPLUG
> +extern void __ref free_area_init_core_hotplug(int nid);
> +#endif
> +
>  /*
>   * Free reserved pages within range [PAGE_ALIGN(start), end & PAGE_MASK)
>   * into the buddy system. The freed pages will be poisoned with pattern
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 4eb6e824a80c..9eea6e809a4e 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -982,8 +982,6 @@ static void reset_node_present_pages(pg_data_t *pgdat)
>  static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
>  {
>  	struct pglist_data *pgdat;
> -	unsigned long zones_size[MAX_NR_ZONES] = {0};
> -	unsigned long zholes_size[MAX_NR_ZONES] = {0};
>  	unsigned long start_pfn = PFN_DOWN(start);
>  
>  	pgdat = NODE_DATA(nid);
> @@ -1006,8 +1004,11 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
>  
>  	/* we can use NODE_DATA(nid) from here */
>  
> +	pgdat->node_id = nid;
> +	pgdat->node_start_pfn = start_pfn;
> +
>  	/* init node's zones as empty zones, we don't have any present pages.*/
> -	free_area_init_node(nid, zones_size, start_pfn, zholes_size);
> +	free_area_init_core_hotplug(nid);
>  	pgdat->per_cpu_nodestats = alloc_percpu(struct per_cpu_nodestat);
>  
>  	/*
> @@ -1017,18 +1018,11 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
>  	build_all_zonelists(pgdat);
>  
>  	/*
> -	 * zone->managed_pages is set to an approximate value in
> -	 * free_area_init_core(), which will cause
> -	 * /sys/device/system/node/nodeX/meminfo has wrong data.
> -	 * So reset it to 0 before any memory is onlined.
> -	 */
> -	reset_node_managed_pages(pgdat);
> -
> -	/*
>  	 * When memory is hot-added, all the memory is in offline state. So
>  	 * clear all zones' present_pages because they will be updated in
>  	 * online_pages() and offline_pages().
>  	 */
> +	reset_node_managed_pages(pgdat);
>  	reset_node_present_pages(pgdat);
>  
>  	return pgdat;
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 4e84a17a5030..b2ccade42020 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6237,21 +6237,9 @@ static void pgdat_init_kcompactd(struct pglist_data *pgdat)
>  static void pgdat_init_kcompactd(struct pglist_data *pgdat) {}
>  #endif
>  
> -/*
> - * Set up the zone data structures:
> - *   - mark all pages reserved
> - *   - mark all memory queues empty
> - *   - clear the memory bitmaps
> - *
> - * NOTE: pgdat should get zeroed by caller.
> - */
> -static void __paginginit free_area_init_core(struct pglist_data *pgdat)
> +static void __paginginit pgdat_init_internals(struct pglist_data *pgdat)
>  {
> -	enum zone_type j;
> -	int nid = pgdat->node_id;
> -
>  	pgdat_resize_init(pgdat);
> -
>  	pgdat_init_numabalancing(pgdat);
>  	pgdat_init_split_queue(pgdat);
>  	pgdat_init_kcompactd(pgdat);
> @@ -6262,7 +6250,54 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
>  	pgdat_page_ext_init(pgdat);
>  	spin_lock_init(&pgdat->lru_lock);
>  	lruvec_init(node_lruvec(pgdat));
> +}
> +
> +static void __paginginit zone_init_internals(struct zone *zone, enum zone_type idx, int nid,
> +							unsigned long remaining_pages)
> +{
> +	zone->managed_pages = remaining_pages;
> +	zone_set_nid(zone, nid);
> +	zone->name = zone_names[idx];
> +	zone->zone_pgdat = NODE_DATA(nid);
> +	spin_lock_init(&zone->lock);
> +	zone_seqlock_init(zone);
> +	zone_pcp_init(zone);
> +}
> +
> +/*
> + * Set up the zone data structures
> + * - init pgdat internals
> + * - init all zones belonging to this node
> + *
> + * NOTE: this function is only called during memory hotplug
> + */
> +#ifdef CONFIG_MEMORY_HOTPLUG
> +void __ref free_area_init_core_hotplug(int nid)
> +{
> +	enum zone_type z;
> +	pg_data_t *pgdat = NODE_DATA(nid);
> +
> +	pgdat_init_internals(pgdat);
> +	for (z = 0; z < MAX_NR_ZONES; z++)
> +		zone_init_internals(&pgdat->node_zones[z], z, nid, 0);
> +}
> +#endif
> +
> +/*
> + * Set up the zone data structures:
> + *   - mark all pages reserved
> + *   - mark all memory queues empty
> + *   - clear the memory bitmaps
> + *
> + * NOTE: pgdat should get zeroed by caller.
> + * NOTE: this function is only called during early init.
> + */
> +static void __init free_area_init_core(struct pglist_data *pgdat)
> +{
> +	enum zone_type j;
> +	int nid = pgdat->node_id;
>  
> +	pgdat_init_internals(pgdat);
>  	pgdat->per_cpu_nodestats = &boot_nodestats;
>  
>  	for (j = 0; j < MAX_NR_ZONES; j++) {
> @@ -6310,13 +6345,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
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
> @@ -6391,7 +6420,7 @@ static inline void pgdat_set_deferred_range(pg_data_t *pgdat)
>  static inline void pgdat_set_deferred_range(pg_data_t *pgdat) {}
>  #endif
>  
> -void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
> +void __init free_area_init_node(int nid, unsigned long *zones_size,
>  		unsigned long node_start_pfn, unsigned long *zholes_size)
>  {
>  	pg_data_t *pgdat = NODE_DATA(nid);
> -- 
> 2.13.6
> 

-- 
Michal Hocko
SUSE Labs
