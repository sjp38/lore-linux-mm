Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id BC1426B1EC6
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 09:17:17 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id o18-v6so16162905qtm.11
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 06:17:17 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id x46-v6si776933qvf.286.2018.08.21.06.17.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Aug 2018 06:17:14 -0700 (PDT)
Subject: Re: [RFC v2 2/2] mm/memory_hotplug: Shrink spanned pages when
 offlining memory
References: <20180817154127.28602-1-osalvador@techadventures.net>
 <20180817154127.28602-3-osalvador@techadventures.net>
From: David Hildenbrand <david@redhat.com>
Message-ID: <a18525a5-ea5f-5e7a-8765-a6c0e38ddd21@redhat.com>
Date: Tue, 21 Aug 2018 15:17:10 +0200
MIME-Version: 1.0
In-Reply-To: <20180817154127.28602-3-osalvador@techadventures.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>, akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, jglisse@redhat.com, jonathan.cameron@huawei.com, Pavel.Tatashin@microsoft.com, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

> add_device_memory is in charge of

I wouldn't use the terminology of onlining/offlining here. That applies
rather to memory that is exposed to the rest of the system (e.g. buddy
allocator, has underlying memory block devices). I guess it is rather a
pure setup/teardown of that device memory.

> 
> a) calling either arch_add_memory() or add_pages(), depending on whether
>    we want a linear mapping
> b) online the memory sections that correspond to the pfn range
> c) calling move_pfn_range_to_zone() being zone ZONE_DEVICE to
>    expand zone/pgdat spanned pages and initialize its pages
> 
> del_device_memory, on the other hand, is in charge of
> 
> a) offline the memory sections that correspond to the pfn range
> b) calling shrink_pages(), which shrinks node/zone spanned pages.
> c) calling either arch_remove_memory() or __remove_pages(), depending on
>    whether we need to tear down the linear mapping or not
> 
> These two functions are called from:
> 
> add_device_memory:
> 	- devm_memremap_pages()
> 	- hmm_devmem_pages_create()
> 
> del_device_memory:
> 	- devm_memremap_pages_release()
> 	- hmm_devmem_release()
> 
> I think that this will get easier as soon as [1] gets merged.
> 
> Finally, shrink_pages() is moved to offline_pages(), so now,
> all pages/zone handling is being taken care in online/offline_pages stage.
> 
> [1] https://lkml.org/lkml/2018/6/19/110
> 

[...]

> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index f90fa077b0c4..d04338ffabec 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -1152,15 +1152,9 @@ int __ref arch_remove_memory(int nid, u64 start, u64 size, struct vmem_altmap *a
>  {
>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
> -	struct page *page = pfn_to_page(start_pfn);
> -	struct zone *zone;
>  	int ret;
>  
> -	/* With altmap the first mapped page is offset from @start */
> -	if (altmap)
> -		page += vmem_altmap_offset(altmap);
> -	zone = page_zone(page);
> -	ret = __remove_pages(zone, start_pfn, nr_pages, altmap);
> +	ret = __remove_pages(nid, start_pfn, nr_pages, altmap);

These changes certainly look nice.

[...]

> index 7a832b844f24..95df37686196 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -119,6 +119,8 @@ static void devm_memremap_pages_release(void *data)
>  	struct dev_pagemap *pgmap = data;
>  	struct device *dev = pgmap->dev;
>  	struct resource *res = &pgmap->res;
> +	struct vmem_altmap *altmap = pgmap->altmap_valid ?
> +					&pgmap->altmap : NULL;
>  	resource_size_t align_start, align_size;
>  	unsigned long pfn;
>  	int nid;
> @@ -138,8 +140,7 @@ static void devm_memremap_pages_release(void *data)
>  	nid = dev_to_node(dev);
>  
>  	mem_hotplug_begin();

I would really like to see the mem_hotplug_begin/end also getting moved
inside add_device_memory()/del_device_memory(). (just like for
add/remove_memory)

I wonder if kasan_ stuff actually requires this lock, or if it could
also be somehow moved inside add_device_memory/del_device_memory.

> -	arch_remove_memory(nid, align_start, align_size, pgmap->altmap_valid ?
> -			&pgmap->altmap : NULL);
> +	del_device_memory(nid, align_start, align_size, altmap, true);
>  	kasan_remove_zero_shadow(__va(align_start), align_size);
>  	mem_hotplug_done();
>  
> @@ -175,7 +176,7 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
>  {
>  	resource_size_t align_start, align_size, align_end;
>  	struct vmem_altmap *altmap = pgmap->altmap_valid ?
> -			&pgmap->altmap : NULL;
> +					&pgmap->altmap : NULL;
>  	struct resource *res = &pgmap->res;
>  	unsigned long pfn, pgoff, order;
>  	pgprot_t pgprot = PAGE_KERNEL;
> @@ -249,11 +250,8 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
>  		goto err_kasan;
>  	}
>  
> -	error = arch_add_memory(nid, align_start, align_size, altmap, false);
> -	if (!error)
> -		move_pfn_range_to_zone(&NODE_DATA(nid)->node_zones[ZONE_DEVICE],
> -					align_start >> PAGE_SHIFT,
> -					align_size >> PAGE_SHIFT, altmap);
> +	error = add_device_memory(nid, align_start, align_size, altmap, true);
> +
>  	mem_hotplug_done();
>  	if (error)
>  		goto err_add_memory;
> diff --git a/kernel/resource.c b/kernel/resource.c
> index 30e1bc68503b..8e68b5ca67ca 100644
> --- a/kernel/resource.c
> +++ b/kernel/resource.c
> @@ -1262,6 +1262,22 @@ int release_mem_region_adjustable(struct resource *parent,
>  			continue;
>  		}
>  
> +		/*
> +		 * All memory regions added from memory-hotplug path
> +		 * have the flag IORESOURCE_SYSTEM_RAM.
> +		 * IORESOURCE_SYSTEM_RAM = (IORESOURCE_MEM|IORESOURCE_SYSRAM)
> +		 * If the resource does not have this flag, we know that
> +		 * we are dealing with a resource coming from HMM/devm.
> +		 * HMM/devm use another mechanism to add/release a resource.
> +		 * This goes via devm_request_mem_region/devm_release_mem_region.
> +		 * HMM/devm take care to release their resources when they want, so
> +		 * if we are dealing with them, let us just back off nicely
> +		 */

Maybe shorten that a bit

"HMM/devm memory does not have IORESOURCE_SYSTEM_RAM set. They use
 devm_request_mem_region/devm_release_mem_region to add/release a
 resource. Just back off here."

> +		if (!(res->flags & IORESOURCE_SYSRAM)) {
> +			ret = 0;
> +			break;
> +		}
> +
>  		if (!(res->flags & IORESOURCE_MEM))
>  			break;
>  
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 21787e480b4a..23ce7fbdb651 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -996,6 +996,7 @@ static void hmm_devmem_release(struct device *dev, void *data)
>  	struct zone *zone;
>  	struct page *page;
>  	int nid;
> +	bool mapping;
>  
>  	if (percpu_ref_tryget_live(&devmem->ref)) {
>  		dev_WARN(dev, "%s: page mapping is still live!\n", __func__);
> @@ -1012,12 +1013,14 @@ static void hmm_devmem_release(struct device *dev, void *data)
>  
>  	mem_hotplug_begin();
>  	if (resource->desc == IORES_DESC_DEVICE_PRIVATE_MEMORY)
> -		__remove_pages(zone, start_pfn, npages, NULL);
> +		mapping = false;
>  	else
> -		arch_remove_memory(nid, start_pfn << PAGE_SHIFT,
> -				   npages << PAGE_SHIFT, NULL);
> -	mem_hotplug_done();
> +		mapping = true;
>  
> +	del_device_memory(nid, start_pfn << PAGE_SHIFT, npages << PAGE_SHIFT,
> +									NULL,
> +									mapping);
> +	mem_hotplug_done();
>  	hmm_devmem_radix_release(resource);
>  }
>  
> @@ -1027,6 +1030,7 @@ static int hmm_devmem_pages_create(struct hmm_devmem *devmem)
>  	struct device *device = devmem->device;
>  	int ret, nid, is_ram;
>  	unsigned long pfn;
> +	bool mapping;
>  
>  	align_start = devmem->resource->start & ~(PA_SECTION_SIZE - 1);
>  	align_size = ALIGN(devmem->resource->start +
> @@ -1085,7 +1089,6 @@ static int hmm_devmem_pages_create(struct hmm_devmem *devmem)
>  	if (nid < 0)
>  		nid = numa_mem_id();
>  
> -	mem_hotplug_begin();
>  	/*
>  	 * For device private memory we call add_pages() as we only need to
>  	 * allocate and initialize struct page for the device memory. More-
> @@ -1096,21 +1099,18 @@ static int hmm_devmem_pages_create(struct hmm_devmem *devmem)
>  	 * For device public memory, which is accesible by the CPU, we do
>  	 * want the linear mapping and thus use arch_add_memory().
>  	 */
> +	mem_hotplug_begin();
>  	if (devmem->pagemap.type == MEMORY_DEVICE_PUBLIC)
> -		ret = arch_add_memory(nid, align_start, align_size, NULL,
> -				false);
> +		mapping = true;
>  	else
> -		ret = add_pages(nid, align_start >> PAGE_SHIFT,
> -				align_size >> PAGE_SHIFT, NULL, false);
> -	if (ret) {
> -		mem_hotplug_done();
> -		goto error_add_memory;
> -	}
> -	move_pfn_range_to_zone(&NODE_DATA(nid)->node_zones[ZONE_DEVICE],
> -				align_start >> PAGE_SHIFT,
> -				align_size >> PAGE_SHIFT, NULL);
> +		mapping = false;
> +
> +	ret = add_device_memory(nid, align_start, align_size, NULL, mapping);
>  	mem_hotplug_done();
>  
> +	if (ret)
> +		goto error_add_memory;
> +
>  	for (pfn = devmem->pfn_first; pfn < devmem->pfn_last; pfn++) {
>  		struct page *page = pfn_to_page(pfn);
>  
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 9bd629944c91..60b67f09956e 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -320,12 +320,10 @@ static unsigned long find_smallest_section_pfn(int nid, struct zone *zone,
>  				     unsigned long start_pfn,
>  				     unsigned long end_pfn)
>  {
> -	struct mem_section *ms;
> -
>  	for (; start_pfn < end_pfn; start_pfn += PAGES_PER_SECTION) {
> -		ms = __pfn_to_section(start_pfn);
> +		struct mem_section *ms = __pfn_to_section(start_pfn);
>  
> -		if (unlikely(!valid_section(ms)))
> +		if (unlikely(!online_section(ms)))
>  			continue;
>  
>  		if (unlikely(pfn_to_nid(start_pfn) != nid))
> @@ -345,15 +343,14 @@ static unsigned long find_biggest_section_pfn(int nid, struct zone *zone,
>  				    unsigned long start_pfn,
>  				    unsigned long end_pfn)
>  {
> -	struct mem_section *ms;
>  	unsigned long pfn;
>  
>  	/* pfn is the end pfn of a memory section. */
>  	pfn = end_pfn - 1;
>  	for (; pfn >= start_pfn; pfn -= PAGES_PER_SECTION) {
> -		ms = __pfn_to_section(pfn);
> +		struct mem_section *ms = __pfn_to_section(pfn);
>  
> -		if (unlikely(!valid_section(ms)))
> +		if (unlikely(!online_section(ms)))
>  			continue;
>  
>  		if (unlikely(pfn_to_nid(pfn) != nid))
> @@ -415,7 +412,7 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
>  	for (; pfn < zone_end_pfn; pfn += PAGES_PER_SECTION) {
>  		ms = __pfn_to_section(pfn);
>  
> -		if (unlikely(!valid_section(ms)))
> +		if (unlikely(!online_section(ms)))
>  			continue;
>  
>  		if (page_zone(pfn_to_page(pfn)) != zone)
> @@ -502,23 +499,33 @@ static void shrink_pgdat_span(struct pglist_data *pgdat,
>  	pgdat->node_spanned_pages = 0;
>  }
>  
> -static void __remove_zone(struct zone *zone, unsigned long start_pfn)
> +static void shrink_pages(struct zone *zone, unsigned long start_pfn,
> +						unsigned long end_pfn,
> +						unsigned long offlined_pages)
>  {
>  	struct pglist_data *pgdat = zone->zone_pgdat;
>  	int nr_pages = PAGES_PER_SECTION;
>  	unsigned long flags;
> +	unsigned long pfn;
>  
> -	pgdat_resize_lock(zone->zone_pgdat, &flags);
> -	shrink_zone_span(zone, start_pfn, start_pfn + nr_pages);
> -	shrink_pgdat_span(pgdat, start_pfn, start_pfn + nr_pages);
> -	pgdat_resize_unlock(zone->zone_pgdat, &flags);
> +	zone->present_pages -= offlined_pages;
> +
> +	clear_zone_contiguous(zone);
> +	pgdat_resize_lock(pgdat, &flags);
> +
> +	for(pfn = start_pfn; pfn < end_pfn; pfn += nr_pages) {
> +		shrink_zone_span(zone, pfn, pfn + nr_pages);
> +		shrink_pgdat_span(pgdat, pfn, pfn + nr_pages);
> +	}
> +	pgdat->node_present_pages -= offlined_pages;
> +
> +	pgdat_resize_unlock(pgdat, &flags);
> +	set_zone_contiguous(zone);
>  }
>  
> -static int __remove_section(struct zone *zone, struct mem_section *ms,
> +static int __remove_section(int nid, struct mem_section *ms,
>  		unsigned long map_offset, struct vmem_altmap *altmap)
>  {
> -	unsigned long start_pfn;
> -	int scn_nr;
>  	int ret = -EINVAL;
>  
>  	if (!valid_section(ms))
> @@ -528,17 +535,13 @@ static int __remove_section(struct zone *zone, struct mem_section *ms,
>  	if (ret)
>  		return ret;
>  
> -	scn_nr = __section_nr(ms);
> -	start_pfn = section_nr_to_pfn((unsigned long)scn_nr);
> -	__remove_zone(zone, start_pfn);
> -
> -	sparse_remove_one_section(zone, ms, map_offset, altmap);
> +	sparse_remove_one_section(nid, ms, map_offset, altmap);
>  	return 0;
>  }
>  
>  /**
>   * __remove_pages() - remove sections of pages from a zone
> - * @zone: zone from which pages need to be removed
> + * @nid: nid from which pages belong to
>   * @phys_start_pfn: starting pageframe (must be aligned to start of a section)
>   * @nr_pages: number of pages to remove (must be multiple of section size)
>   * @altmap: alternative device page map or %NULL if default memmap is used
> @@ -548,35 +551,27 @@ static int __remove_section(struct zone *zone, struct mem_section *ms,
>   * sure that pages are marked reserved and zones are adjust properly by
>   * calling offline_pages().
>   */
> -int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
> +int __remove_pages(int nid, unsigned long phys_start_pfn,
>  		 unsigned long nr_pages, struct vmem_altmap *altmap)
>  {
>  	unsigned long i;
>  	unsigned long map_offset = 0;
>  	int sections_to_remove, ret = 0;
> +	resource_size_t start, size;
>  
> -	/* In the ZONE_DEVICE case device driver owns the memory region */
> -	if (is_dev_zone(zone)) {
> -		if (altmap)
> -			map_offset = vmem_altmap_offset(altmap);
> -	} else {
> -		resource_size_t start, size;
> -
> -		start = phys_start_pfn << PAGE_SHIFT;
> -		size = nr_pages * PAGE_SIZE;
> +	start = phys_start_pfn << PAGE_SHIFT;
> +	size = nr_pages * PAGE_SIZE;
>  
> -		ret = release_mem_region_adjustable(&iomem_resource, start,
> -					size);
> -		if (ret) {
> -			resource_size_t endres = start + size - 1;
> +	if (altmap)
> +		map_offset = vmem_altmap_offset(altmap);
>  
> -			pr_warn("Unable to release resource <%pa-%pa> (%d)\n",
> -					&start, &endres, ret);
> -		}
> +	ret = release_mem_region_adjustable(&iomem_resource, start, size);
> +	if (ret) {
> +		resource_size_t endres = start + size - 1;
> +		pr_warn("Unable to release resource <%pa-%pa> (%d)\n",
> +						&start, &endres, ret);
>  	}
>  
> -	clear_zone_contiguous(zone);
> -
>  	/*
>  	 * We can only remove entire sections
>  	 */
> @@ -587,15 +582,13 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
>  	for (i = 0; i < sections_to_remove; i++) {
>  		unsigned long pfn = phys_start_pfn + i*PAGES_PER_SECTION;
>  
> -		ret = __remove_section(zone, __pfn_to_section(pfn), map_offset,
> -				altmap);
> +		ret = __remove_section(nid, __pfn_to_section(pfn), map_offset,
> +									altmap);
>  		map_offset = 0;
>  		if (ret)
>  			break;
>  	}
>  
> -	set_zone_contiguous(zone);
> -
>  	return ret;
>  }
>  #endif /* CONFIG_MEMORY_HOTREMOVE */
> @@ -1595,7 +1588,6 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  	unsigned long pfn, nr_pages;
>  	long offlined_pages;
>  	int ret, node;
> -	unsigned long flags;
>  	unsigned long valid_start, valid_end;
>  	struct zone *zone;
>  	struct memory_notify arg;
> @@ -1665,11 +1657,9 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
>  	/* removal success */
>  	adjust_managed_page_count(pfn_to_page(start_pfn), -offlined_pages);
> -	zone->present_pages -= offlined_pages;
>  
> -	pgdat_resize_lock(zone->zone_pgdat, &flags);
> -	zone->zone_pgdat->node_present_pages -= offlined_pages;
> -	pgdat_resize_unlock(zone->zone_pgdat, &flags);
> +	/* Here we will shrink zone/node's spanned/present_pages */
> +	shrink_pages(zone, valid_start, valid_end, offlined_pages);
>  
>  	init_per_zone_wmark_min();
>  
> @@ -1902,4 +1892,57 @@ void __ref remove_memory(int nid, u64 start, u64 size)
>  	mem_hotplug_done();
>  }
>  EXPORT_SYMBOL_GPL(remove_memory);
> +
> +static int __del_device_memory(int nid, unsigned long start, unsigned long size,
> +				struct vmem_altmap *altmap, bool mapping)
> +{
> +	int ret;
> +	unsigned long start_pfn = PHYS_PFN(start);
> +	unsigned long nr_pages = size >> PAGE_SHIFT;
> +	struct zone *zone = &NODE_DATA(nid)->node_zones[ZONE_DEVICE];
> +
> +	offline_mem_sections(start_pfn, start_pfn + nr_pages);
> +	shrink_pages(zone, start_pfn, start_pfn + nr_pages, 0);
> +
> +	if (mapping)
> +		ret = arch_remove_memory(nid, start, size, altmap);
> +	else
> +		ret = __remove_pages(nid, start_pfn, nr_pages, altmap);
> +
> +	return ret;
> +}
> +
> +int del_device_memory(int nid, unsigned long start, unsigned long size,
> +			struct vmem_altmap *altmap, bool mapping)
> +{
> +	return __del_device_memory(nid, start, size, altmap, mapping);
> +}
>  #endif /* CONFIG_MEMORY_HOTREMOVE */
> +
> +static int __add_device_memory(int nid, unsigned long start, unsigned long size,
> +				struct vmem_altmap *altmap, bool mapping)
> +{
> +	int ret;
> +        unsigned long start_pfn = PHYS_PFN(start);
> +        unsigned long nr_pages = size >> PAGE_SHIFT;
> +
> +	if (mapping)
> +		ret = arch_add_memory(nid, start, size, altmap, false);
> +        else
> +		ret = add_pages(nid, start_pfn, nr_pages, altmap, false);
> +
> +	if (!ret) {
> +		struct zone *zone = &NODE_DATA(nid)->node_zones[ZONE_DEVICE];
> +
> +		online_mem_sections(start_pfn, start_pfn + nr_pages);
> +		move_pfn_range_to_zone(zone, start_pfn, nr_pages, altmap);
> +	}
> +
> +	return ret;
> +}
> +
> +int add_device_memory(int nid, unsigned long start, unsigned long size,
> +				struct vmem_altmap *altmap, bool mapping)
> +{
> +	return __add_device_memory(nid, start, size, altmap, mapping);
> +}

Any reason for these indirections?

> diff --git a/mm/sparse.c b/mm/sparse.c
> index 10b07eea9a6e..016020bd20b5 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -766,12 +766,12 @@ static void free_section_usemap(struct page *memmap, unsigned long *usemap,
>  		free_map_bootmem(memmap);
>  }


I guess for readability, this patch could be split up into several
patches. E.g. factoring out of add_device_memory/del_device_memory,
release_mem_region_adjustable change ...

-- 

Thanks,

David / dhildenb
