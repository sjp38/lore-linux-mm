Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0BA6D6B000A
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 09:56:02 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id g22so30966678qke.15
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 06:56:02 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m27si7176933qta.366.2018.11.13.06.56.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Nov 2018 06:56:00 -0800 (PST)
Subject: Re: [PATCH v5 2/4] mm: convert zone->managed_pages to atomic variable
References: <1542090790-21750-1-git-send-email-arunks@codeaurora.org>
 <1542090790-21750-3-git-send-email-arunks@codeaurora.org>
From: David Hildenbrand <david@redhat.com>
Message-ID: <2b2b6108-45ce-4fd5-0e87-299211c1fcb4@redhat.com>
Date: Tue, 13 Nov 2018 15:55:56 +0100
MIME-Version: 1.0
In-Reply-To: <1542090790-21750-3-git-send-email-arunks@codeaurora.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun KS <arunks@codeaurora.org>
Cc: keescook@chromium.org, khlebnikov@yandex-team.ru, minchan@kernel.org, getarunks@gmail.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, vatsa@codeaurora.org, willy@infradead.org

On 13.11.18 07:33, Arun KS wrote:
> totalram_pages, zone->managed_pages and totalhigh_pages updates
> are protected by managed_page_count_lock, but readers never care
> about it. Convert these variables to atomic to avoid readers
> potentially seeing a store tear.
> 
> This patch converts zone->managed_pages. Subsequent patches will
> convert totalram_panges, totalhigh_pages and eventually
> managed_page_count_lock will be removed.
> 
> Main motivation was that managed_page_count_lock handling was
> complicating things. It was discussed in length here,
> https://lore.kernel.org/patchwork/patch/995739/#1181785
> So it seemes better to remove the lock and convert variables
> to atomic, with preventing poteintial store-to-read tearing as
> a bonus.
> 
> Suggested-by: Michal Hocko <mhocko@suse.com>
> Suggested-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Arun KS <arunks@codeaurora.org>
> Reviewed-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> ---
> Most of the changes are done by below coccinelle script,
> 
> @@
> struct zone *z;
> expression e1;
> @@
> (
> - z->managed_pages = e1
> + atomic_long_set(&z->managed_pages, e1)
> |
> - e1->managed_pages++
> + atomic_long_inc(&e1->managed_pages)
> |
> - z->managed_pages
> + zone_managed_pages(z)
> )
> 
> @@
> expression e,e1;
> @@
> - e->managed_pages += e1
> + atomic_long_add(e1, &e->managed_pages)
> 
> @@
> expression z;
> @@
> - z.managed_pages
> + zone_managed_pages(&z)
> 
> Then, manually apply following change,
> include/linux/mmzone.h
> 
> - unsigned long managed_pages;
> + atomic_long_t managed_pages;
> 
> +static inline unsigned long zone_managed_pages(struct zone *zone)
> +{
> +       return (unsigned long)atomic_long_read(&zone->managed_pages);
> +}
> 
> ---
> 
>  drivers/gpu/drm/amd/amdkfd/kfd_crat.c |  2 +-
>  include/linux/mmzone.h                |  9 +++++--
>  lib/show_mem.c                        |  2 +-
>  mm/memblock.c                         |  2 +-
>  mm/page_alloc.c                       | 44 +++++++++++++++++------------------
>  mm/vmstat.c                           |  4 ++--
>  6 files changed, 34 insertions(+), 29 deletions(-)
> 
> diff --git a/drivers/gpu/drm/amd/amdkfd/kfd_crat.c b/drivers/gpu/drm/amd/amdkfd/kfd_crat.c
> index 56412b0..c0e55bb 100644
> --- a/drivers/gpu/drm/amd/amdkfd/kfd_crat.c
> +++ b/drivers/gpu/drm/amd/amdkfd/kfd_crat.c
> @@ -848,7 +848,7 @@ static int kfd_fill_mem_info_for_cpu(int numa_node_id, int *avail_size,
>  	 */
>  	pgdat = NODE_DATA(numa_node_id);
>  	for (zone_type = 0; zone_type < MAX_NR_ZONES; zone_type++)
> -		mem_in_bytes += pgdat->node_zones[zone_type].managed_pages;
> +		mem_in_bytes += zone_managed_pages(&pgdat->node_zones[zone_type]);
>  	mem_in_bytes <<= PAGE_SHIFT;
>  
>  	sub_type_hdr->length_low = lower_32_bits(mem_in_bytes);
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 847705a..e73dc31 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -435,7 +435,7 @@ struct zone {
>  	 * adjust_managed_page_count() should be used instead of directly
>  	 * touching zone->managed_pages and totalram_pages.
>  	 */
> -	unsigned long		managed_pages;
> +	atomic_long_t		managed_pages;
>  	unsigned long		spanned_pages;
>  	unsigned long		present_pages;
>  
> @@ -524,6 +524,11 @@ enum pgdat_flags {
>  	PGDAT_RECLAIM_LOCKED,		/* prevents concurrent reclaim */
>  };
>  
> +static inline unsigned long zone_managed_pages(struct zone *zone)
> +{
> +	return (unsigned long)atomic_long_read(&zone->managed_pages);
> +}
> +
>  static inline unsigned long zone_end_pfn(const struct zone *zone)
>  {
>  	return zone->zone_start_pfn + zone->spanned_pages;
> @@ -814,7 +819,7 @@ static inline bool is_dev_zone(const struct zone *zone)
>   */
>  static inline bool managed_zone(struct zone *zone)
>  {
> -	return zone->managed_pages;
> +	return zone_managed_pages(zone);
>  }
>  
>  /* Returns true if a zone has memory */
> diff --git a/lib/show_mem.c b/lib/show_mem.c
> index 0beaa1d..eefe67d 100644
> --- a/lib/show_mem.c
> +++ b/lib/show_mem.c
> @@ -28,7 +28,7 @@ void show_mem(unsigned int filter, nodemask_t *nodemask)
>  				continue;
>  
>  			total += zone->present_pages;
> -			reserved += zone->present_pages - zone->managed_pages;
> +			reserved += zone->present_pages - zone_managed_pages(zone);
>  
>  			if (is_highmem_idx(zoneid))
>  				highmem += zone->present_pages;
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 7df468c..bbd82ab 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1950,7 +1950,7 @@ void reset_node_managed_pages(pg_data_t *pgdat)
>  	struct zone *z;
>  
>  	for (z = pgdat->node_zones; z < pgdat->node_zones + MAX_NR_ZONES; z++)
> -		z->managed_pages = 0;
> +		atomic_long_set(&z->managed_pages, 0);
>  }
>  
>  void __init reset_all_zones_managed_pages(void)
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 173312b..22e6645 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1279,7 +1279,7 @@ static void __init __free_pages_boot_core(struct page *page, unsigned int order)
>  	__ClearPageReserved(p);
>  	set_page_count(p, 0);
>  
> -	page_zone(page)->managed_pages += nr_pages;
> +	atomic_long_add(nr_pages, &page_zone(page)->managed_pages);
>  	set_page_refcounted(page);
>  	__free_pages(page, order);
>  }
> @@ -2258,7 +2258,7 @@ static void reserve_highatomic_pageblock(struct page *page, struct zone *zone,
>  	 * Limit the number reserved to 1 pageblock or roughly 1% of a zone.
>  	 * Check is race-prone but harmless.
>  	 */
> -	max_managed = (zone->managed_pages / 100) + pageblock_nr_pages;
> +	max_managed = (zone_managed_pages(zone) / 100) + pageblock_nr_pages;
>  	if (zone->nr_reserved_highatomic >= max_managed)
>  		return;
>  
> @@ -4662,7 +4662,7 @@ static unsigned long nr_free_zone_pages(int offset)
>  	struct zonelist *zonelist = node_zonelist(numa_node_id(), GFP_KERNEL);
>  
>  	for_each_zone_zonelist(zone, z, zonelist, offset) {
> -		unsigned long size = zone->managed_pages;
> +		unsigned long size = zone_managed_pages(zone);
>  		unsigned long high = high_wmark_pages(zone);
>  		if (size > high)
>  			sum += size - high;
> @@ -4769,7 +4769,7 @@ void si_meminfo_node(struct sysinfo *val, int nid)
>  	pg_data_t *pgdat = NODE_DATA(nid);
>  
>  	for (zone_type = 0; zone_type < MAX_NR_ZONES; zone_type++)
> -		managed_pages += pgdat->node_zones[zone_type].managed_pages;
> +		managed_pages += zone_managed_pages(&pgdat->node_zones[zone_type]);
>  	val->totalram = managed_pages;
>  	val->sharedram = node_page_state(pgdat, NR_SHMEM);
>  	val->freeram = sum_zone_node_page_state(nid, NR_FREE_PAGES);
> @@ -4778,7 +4778,7 @@ void si_meminfo_node(struct sysinfo *val, int nid)
>  		struct zone *zone = &pgdat->node_zones[zone_type];
>  
>  		if (is_highmem(zone)) {
> -			managed_highpages += zone->managed_pages;
> +			managed_highpages += zone_managed_pages(zone);
>  			free_highpages += zone_page_state(zone, NR_FREE_PAGES);
>  		}
>  	}
> @@ -4985,7 +4985,7 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
>  			K(zone_page_state(zone, NR_ZONE_UNEVICTABLE)),
>  			K(zone_page_state(zone, NR_ZONE_WRITE_PENDING)),
>  			K(zone->present_pages),
> -			K(zone->managed_pages),
> +			K(zone_managed_pages(zone)),
>  			K(zone_page_state(zone, NR_MLOCK)),
>  			zone_page_state(zone, NR_KERNEL_STACK_KB),
>  			K(zone_page_state(zone, NR_PAGETABLE)),
> @@ -5645,7 +5645,7 @@ static int zone_batchsize(struct zone *zone)
>  	 * The per-cpu-pages pools are set to around 1000th of the
>  	 * size of the zone.
>  	 */
> -	batch = zone->managed_pages / 1024;
> +	batch = zone_managed_pages(zone) / 1024;
>  	/* But no more than a meg. */
>  	if (batch * PAGE_SIZE > 1024 * 1024)
>  		batch = (1024 * 1024) / PAGE_SIZE;
> @@ -5756,7 +5756,7 @@ static void pageset_set_high_and_batch(struct zone *zone,
>  {
>  	if (percpu_pagelist_fraction)
>  		pageset_set_high(pcp,
> -			(zone->managed_pages /
> +			(zone_managed_pages(zone) /
>  				percpu_pagelist_fraction));
>  	else
>  		pageset_set_batch(pcp, zone_batchsize(zone));
> @@ -6311,7 +6311,7 @@ static void __meminit pgdat_init_internals(struct pglist_data *pgdat)
>  static void __meminit zone_init_internals(struct zone *zone, enum zone_type idx, int nid,
>  							unsigned long remaining_pages)
>  {
> -	zone->managed_pages = remaining_pages;
> +	atomic_long_set(&zone->managed_pages, remaining_pages);
>  	zone_set_nid(zone, nid);
>  	zone->name = zone_names[idx];
>  	zone->zone_pgdat = NODE_DATA(nid);
> @@ -7064,7 +7064,7 @@ static int __init cmdline_parse_movablecore(char *p)
>  void adjust_managed_page_count(struct page *page, long count)
>  {
>  	spin_lock(&managed_page_count_lock);
> -	page_zone(page)->managed_pages += count;
> +	atomic_long_add(count, &page_zone(page)->managed_pages);
>  	totalram_pages += count;
>  #ifdef CONFIG_HIGHMEM
>  	if (PageHighMem(page))
> @@ -7112,7 +7112,7 @@ void free_highmem_page(struct page *page)
>  {
>  	__free_reserved_page(page);
>  	totalram_pages++;
> -	page_zone(page)->managed_pages++;
> +	atomic_long_inc(&page_zone(page)->managed_pages);
>  	totalhigh_pages++;
>  }
>  #endif
> @@ -7245,7 +7245,7 @@ static void calculate_totalreserve_pages(void)
>  		for (i = 0; i < MAX_NR_ZONES; i++) {
>  			struct zone *zone = pgdat->node_zones + i;
>  			long max = 0;
> -			unsigned long managed_pages = zone->managed_pages;
> +			unsigned long managed_pages = zone_managed_pages(zone);
>  
>  			/* Find valid and maximum lowmem_reserve in the zone */
>  			for (j = i; j < MAX_NR_ZONES; j++) {
> @@ -7281,7 +7281,7 @@ static void setup_per_zone_lowmem_reserve(void)
>  	for_each_online_pgdat(pgdat) {
>  		for (j = 0; j < MAX_NR_ZONES; j++) {
>  			struct zone *zone = pgdat->node_zones + j;
> -			unsigned long managed_pages = zone->managed_pages;
> +			unsigned long managed_pages = zone_managed_pages(zone);
>  
>  			zone->lowmem_reserve[j] = 0;
>  
> @@ -7299,7 +7299,7 @@ static void setup_per_zone_lowmem_reserve(void)
>  					lower_zone->lowmem_reserve[j] =
>  						managed_pages / sysctl_lowmem_reserve_ratio[idx];
>  				}
> -				managed_pages += lower_zone->managed_pages;
> +				managed_pages += zone_managed_pages(lower_zone);
>  			}
>  		}
>  	}
> @@ -7318,14 +7318,14 @@ static void __setup_per_zone_wmarks(void)
>  	/* Calculate total number of !ZONE_HIGHMEM pages */
>  	for_each_zone(zone) {
>  		if (!is_highmem(zone))
> -			lowmem_pages += zone->managed_pages;
> +			lowmem_pages += zone_managed_pages(zone);
>  	}
>  
>  	for_each_zone(zone) {
>  		u64 tmp;
>  
>  		spin_lock_irqsave(&zone->lock, flags);
> -		tmp = (u64)pages_min * zone->managed_pages;
> +		tmp = (u64)pages_min * zone_managed_pages(zone);
>  		do_div(tmp, lowmem_pages);
>  		if (is_highmem(zone)) {
>  			/*
> @@ -7339,7 +7339,7 @@ static void __setup_per_zone_wmarks(void)
>  			 */
>  			unsigned long min_pages;
>  
> -			min_pages = zone->managed_pages / 1024;
> +			min_pages = zone_managed_pages(zone) / 1024;
>  			min_pages = clamp(min_pages, SWAP_CLUSTER_MAX, 128UL);
>  			zone->watermark[WMARK_MIN] = min_pages;
>  		} else {
> @@ -7356,7 +7356,7 @@ static void __setup_per_zone_wmarks(void)
>  		 * ensure a minimum size on small systems.
>  		 */
>  		tmp = max_t(u64, tmp >> 2,
> -			    mult_frac(zone->managed_pages,
> +			    mult_frac(zone_managed_pages(zone),
>  				      watermark_scale_factor, 10000));
>  
>  		zone->watermark[WMARK_LOW]  = min_wmark_pages(zone) + tmp;
> @@ -7486,8 +7486,8 @@ static void setup_min_unmapped_ratio(void)
>  		pgdat->min_unmapped_pages = 0;
>  
>  	for_each_zone(zone)
> -		zone->zone_pgdat->min_unmapped_pages += (zone->managed_pages *
> -				sysctl_min_unmapped_ratio) / 100;
> +		zone->zone_pgdat->min_unmapped_pages += (zone_managed_pages(zone) *
> +						         sysctl_min_unmapped_ratio) / 100;
>  }
>  
>  
> @@ -7514,8 +7514,8 @@ static void setup_min_slab_ratio(void)
>  		pgdat->min_slab_pages = 0;
>  
>  	for_each_zone(zone)
> -		zone->zone_pgdat->min_slab_pages += (zone->managed_pages *
> -				sysctl_min_slab_ratio) / 100;
> +		zone->zone_pgdat->min_slab_pages += (zone_managed_pages(zone) *
> +						     sysctl_min_slab_ratio) / 100;
>  }
>  
>  int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *table, int write,
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 6038ce5..9fee037 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -227,7 +227,7 @@ int calculate_normal_threshold(struct zone *zone)
>  	 * 125		1024		10	16-32 GB	9
>  	 */
>  
> -	mem = zone->managed_pages >> (27 - PAGE_SHIFT);
> +	mem = zone_managed_pages(zone) >> (27 - PAGE_SHIFT);
>  
>  	threshold = 2 * fls(num_online_cpus()) * (1 + fls(mem));
>  
> @@ -1569,7 +1569,7 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
>  		   high_wmark_pages(zone),
>  		   zone->spanned_pages,
>  		   zone->present_pages,
> -		   zone->managed_pages);
> +		   zone_managed_pages(zone));
>  
>  	seq_printf(m,
>  		   "\n        protection: (%ld",
> 

Reviewed-by: David Hildenbrand <david@redhat.com>

-- 

Thanks,

David / dhildenb
