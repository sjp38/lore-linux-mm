Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id AD0066B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 16:42:34 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id p63so7099004wmp.1
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 13:42:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pg2si4284052wjb.128.2016.01.26.13.42.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 13:42:33 -0800 (PST)
Subject: Re: [RFC PATCH] mm: support CONFIG_ZONE_DEVICE + CONFIG_ZONE_DMA
References: <20160126000639.358.89668.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56A7E846.30607@suse.cz>
Date: Tue, 26 Jan 2016 22:42:30 +0100
MIME-Version: 1.0
In-Reply-To: <20160126000639.358.89668.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, linux-nvdimm@lists.01.org, Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Jerome Glisse <j.glisse@gmail.com>, Sudip Mukherjee <sudipm.mukherjee@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Laura Abbott <labbott@fedoraproject.org>

On 26.1.2016 1:06, Dan Williams wrote:
> It appears devices requiring ZONE_DMA are still prevalent (see link
> below).  For this reason the proposal to require turning off ZONE_DMA to
> enable ZONE_DEVICE is untenable in the short term.  We want a single
> kernel image to be able to support legacy devices as well as next
> generation persistent memory platforms.
> 
> Towards this end, alias ZONE_DMA and ZONE_DEVICE to work around needing
> to maintain a unique zone number for ZONE_DEVICE.  Record the geometry
> of ZONE_DMA at init (->init_spanned_pages) and use that information in
> is_zone_device_page() to differentiate pages allocated via
> devm_memremap_pages() vs true ZONE_DMA pages.  Otherwise, use the
> simpler definition of is_zone_device_page() when ZONE_DMA is turned off.
> 
> Note that this also teaches the memory hot remove path that the zone may
> not have sections for all pfn spans (->zone_dyn_start_pfn).
> 
> A user visible implication of this change is potentially an unexpectedly
> high "spanned" value in /proc/zoneinfo for the DMA zone.

[+CC Joonsoo, Laura]

Sounds like quite a hack :( Would it be possible to extend the bits encoding
zone? Potentially, ZONE_CMA could be added one day...

> Cc: H. Peter Anvin <hpa@zytor.com>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Jerome Glisse <j.glisse@gmail.com>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Link: https://bugzilla.kernel.org/show_bug.cgi?id=110931
> Fixes: 033fbae988fc ("mm: ZONE_DEVICE for "device memory"")
> Reported-by: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  include/linux/mm.h     |   46 ++++++++++++++++++++++++++++++++--------------
>  include/linux/mmzone.h |   24 ++++++++++++++++++++----
>  mm/Kconfig             |    1 -
>  mm/memory_hotplug.c    |   15 +++++++++++----
>  mm/page_alloc.c        |    9 ++++++---
>  5 files changed, 69 insertions(+), 26 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index f1cd22f2df1a..b4bccd3d3c41 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -664,12 +664,44 @@ static inline enum zone_type page_zonenum(const struct page *page)
>  	return (page->flags >> ZONES_PGSHIFT) & ZONES_MASK;
>  }
>  
> +#ifdef NODE_NOT_IN_PAGE_FLAGS
> +extern int page_to_nid(const struct page *page);
> +#else
> +static inline int page_to_nid(const struct page *page)
> +{
> +	return (page->flags >> NODES_PGSHIFT) & NODES_MASK;
> +}
> +#endif
> +
> +static inline struct zone *page_zone(const struct page *page)
> +{
> +	return &NODE_DATA(page_to_nid(page))->node_zones[page_zonenum(page)];
> +}
> +
>  #ifdef CONFIG_ZONE_DEVICE
>  void get_zone_device_page(struct page *page);
>  void put_zone_device_page(struct page *page);
>  static inline bool is_zone_device_page(const struct page *page)
>  {
> +#ifndef CONFIG_ZONE_DMA
>  	return page_zonenum(page) == ZONE_DEVICE;
> +#else /* ZONE_DEVICE == ZONE_DMA */
> +	struct zone *zone;
> +
> +	if (page_zonenum(page) != ZONE_DEVICE)
> +		return false;
> +
> +	/*
> +	 * If ZONE_DEVICE is aliased with ZONE_DMA we need to check
> +	 * whether this was a dynamically allocated page from
> +	 * devm_memremap_pages() by checking against the size of
> +	 * ZONE_DMA at boot.
> +	 */
> +	zone = page_zone(page);
> +	if (page_to_pfn(page) <= zone_end_pfn_boot(zone))
> +		return false;
> +	return true;
> +#endif
>  }
>  #else
>  static inline void get_zone_device_page(struct page *page)
> @@ -735,15 +767,6 @@ static inline int zone_to_nid(struct zone *zone)
>  #endif
>  }
>  
> -#ifdef NODE_NOT_IN_PAGE_FLAGS
> -extern int page_to_nid(const struct page *page);
> -#else
> -static inline int page_to_nid(const struct page *page)
> -{
> -	return (page->flags >> NODES_PGSHIFT) & NODES_MASK;
> -}
> -#endif
> -
>  #ifdef CONFIG_NUMA_BALANCING
>  static inline int cpu_pid_to_cpupid(int cpu, int pid)
>  {
> @@ -857,11 +880,6 @@ static inline bool cpupid_match_pid(struct task_struct *task, int cpupid)
>  }
>  #endif /* CONFIG_NUMA_BALANCING */
>  
> -static inline struct zone *page_zone(const struct page *page)
> -{
> -	return &NODE_DATA(page_to_nid(page))->node_zones[page_zonenum(page)];
> -}
> -
>  #ifdef SECTION_IN_PAGE_FLAGS
>  static inline void set_page_section(struct page *page, unsigned long section)
>  {
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 33bb1b19273e..a0ef09b7f893 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -288,6 +288,13 @@ enum zone_type {
>  	 */
>  	ZONE_DMA,
>  #endif
> +#ifdef CONFIG_ZONE_DEVICE
> +#ifndef CONFIG_ZONE_DMA
> +	ZONE_DEVICE,
> +#else
> +	ZONE_DEVICE = ZONE_DMA,
> +#endif
> +#endif
>  #ifdef CONFIG_ZONE_DMA32
>  	/*
>  	 * x86_64 needs two ZONE_DMAs because it supports devices that are
> @@ -314,11 +321,7 @@ enum zone_type {
>  	ZONE_HIGHMEM,
>  #endif
>  	ZONE_MOVABLE,
> -#ifdef CONFIG_ZONE_DEVICE
> -	ZONE_DEVICE,
> -#endif
>  	__MAX_NR_ZONES
> -
>  };
>  
>  #ifndef __GENERATING_BOUNDS_H
> @@ -379,12 +382,19 @@ struct zone {
>  
>  	/* zone_start_pfn == zone_start_paddr >> PAGE_SHIFT */
>  	unsigned long		zone_start_pfn;
> +	/* first dynamically added pfn of the zone */
> +	unsigned long		zone_dyn_start_pfn;
>  
>  	/*
>  	 * spanned_pages is the total pages spanned by the zone, including
>  	 * holes, which is calculated as:
>  	 * 	spanned_pages = zone_end_pfn - zone_start_pfn;
>  	 *
> +	 * init_spanned_pages is the boot/init time total pages spanned
> +	 * by the zone for differentiating statically assigned vs
> +	 * dynamically hot added memory to a zone.
> +	 * 	init_spanned_pages = init_zone_end_pfn - zone_start_pfn;
> +	 *
>  	 * present_pages is physical pages existing within the zone, which
>  	 * is calculated as:
>  	 *	present_pages = spanned_pages - absent_pages(pages in holes);
> @@ -423,6 +433,7 @@ struct zone {
>  	 */
>  	unsigned long		managed_pages;
>  	unsigned long		spanned_pages;
> +	unsigned long		init_spanned_pages;
>  	unsigned long		present_pages;
>  
>  	const char		*name;
> @@ -546,6 +557,11 @@ static inline unsigned long zone_end_pfn(const struct zone *zone)
>  	return zone->zone_start_pfn + zone->spanned_pages;
>  }
>  
> +static inline unsigned long zone_end_pfn_boot(const struct zone *zone)
> +{
> +	return zone->zone_start_pfn + zone->init_spanned_pages;
> +}
> +
>  static inline bool zone_spans_pfn(const struct zone *zone, unsigned long pfn)
>  {
>  	return zone->zone_start_pfn <= pfn && pfn < zone_end_pfn(zone);
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 97a4e06b15c0..08a92a9c8fbd 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -652,7 +652,6 @@ config IDLE_PAGE_TRACKING
>  config ZONE_DEVICE
>  	bool "Device memory (pmem, etc...) hotplug support" if EXPERT
>  	default !ZONE_DMA
> -	depends on !ZONE_DMA
>  	depends on MEMORY_HOTPLUG
>  	depends on MEMORY_HOTREMOVE
>  	depends on X86_64 #arch_add_memory() comprehends device memory
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 4af58a3a8ffa..c3f0ff45bd47 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -300,6 +300,8 @@ static void __meminit grow_zone_span(struct zone *zone, unsigned long start_pfn,
>  
>  	zone->spanned_pages = max(old_zone_end_pfn, end_pfn) -
>  				zone->zone_start_pfn;
> +	if (!zone->zone_dyn_start_pfn || start_pfn < zone->zone_dyn_start_pfn)
> +		zone->zone_dyn_start_pfn = start_pfn;
>  
>  	zone_span_writeunlock(zone);
>  }
> @@ -601,8 +603,9 @@ static int find_biggest_section_pfn(int nid, struct zone *zone,
>  static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
>  			     unsigned long end_pfn)
>  {
> -	unsigned long zone_start_pfn = zone->zone_start_pfn;
> +	unsigned long zone_start_pfn = zone->zone_dyn_start_pfn;
>  	unsigned long z = zone_end_pfn(zone); /* zone_end_pfn namespace clash */
> +	bool dyn_zone = zone->zone_start_pfn == zone_start_pfn;
>  	unsigned long zone_end_pfn = z;
>  	unsigned long pfn;
>  	struct mem_section *ms;
> @@ -619,7 +622,9 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
>  		pfn = find_smallest_section_pfn(nid, zone, end_pfn,
>  						zone_end_pfn);
>  		if (pfn) {
> -			zone->zone_start_pfn = pfn;
> +			if (dyn_zone)
> +				zone->zone_start_pfn = pfn;
> +			zone->zone_dyn_start_pfn = pfn;
>  			zone->spanned_pages = zone_end_pfn - pfn;
>  		}
>  	} else if (zone_end_pfn == end_pfn) {
> @@ -661,8 +666,10 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
>  	}
>  
>  	/* The zone has no valid section */
> -	zone->zone_start_pfn = 0;
> -	zone->spanned_pages = 0;
> +	if (dyn_zone)
> +		zone->zone_start_pfn = 0;
> +	zone->zone_dyn_start_pfn = 0;
> +	zone->spanned_pages = zone->init_spanned_pages;
>  	zone_span_writeunlock(zone);
>  }
>  
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 63358d9f9aa9..2d8b1d602ff3 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -209,6 +209,10 @@ EXPORT_SYMBOL(totalram_pages);
>  static char * const zone_names[MAX_NR_ZONES] = {
>  #ifdef CONFIG_ZONE_DMA
>  	 "DMA",
> +#else
> +#ifdef CONFIG_ZONE_DEVICE
> +	 "Device",
> +#endif
>  #endif
>  #ifdef CONFIG_ZONE_DMA32
>  	 "DMA32",
> @@ -218,9 +222,6 @@ static char * const zone_names[MAX_NR_ZONES] = {
>  	 "HighMem",
>  #endif
>  	 "Movable",
> -#ifdef CONFIG_ZONE_DEVICE
> -	 "Device",
> -#endif
>  };
>  
>  compound_page_dtor * const compound_page_dtors[] = {
> @@ -5082,6 +5083,8 @@ static void __meminit calculate_node_totalpages(struct pglist_data *pgdat,
>  						  node_start_pfn, node_end_pfn,
>  						  zholes_size);
>  		zone->spanned_pages = size;
> +		zone->init_spanned_pages = size;
> +		zone->zone_dyn_start_pfn = 0;
>  		zone->present_pages = real_size;
>  
>  		totalpages += size;
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
