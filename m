Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 25C7F6B0266
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 04:56:08 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id b55-v6so24024880qtb.5
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 01:56:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j4-v6si1209401qtb.398.2018.10.16.01.56.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Oct 2018 01:56:07 -0700 (PDT)
Subject: Re: [PATCH 2/5] mm/memory_hotplug: Create add/del_device_memory
 functions
References: <20181015153034.32203-1-osalvador@techadventures.net>
 <20181015153034.32203-3-osalvador@techadventures.net>
From: David Hildenbrand <david@redhat.com>
Message-ID: <d0a12eb5-3824-8d25-75f8-3e62f1e81994@redhat.com>
Date: Tue, 16 Oct 2018 10:55:56 +0200
MIME-Version: 1.0
In-Reply-To: <20181015153034.32203-3-osalvador@techadventures.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>, akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, yasu.isimatu@gmail.com, rppt@linux.vnet.ibm.com, malat@debian.org, linux-kernel@vger.kernel.org, pavel.tatashin@microsoft.com, jglisse@redhat.com, Jonathan.Cameron@huawei.com, rafael@kernel.org, dave.jiang@intel.com, linux-mm@kvack.org, alexander.h.duyck@linux.intel.com, Oscar Salvador <osalvador@suse.de>


> index 42d79bcc8aab..d3e52ae71bd9 100644
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
> @@ -1010,12 +1011,15 @@ static void hmm_devmem_release(struct device *dev, void *data)
>  	zone = page_zone(page);
>  	nid = zone->zone_pgdat->node_id;
>  
> -	mem_hotplug_begin();
>  	if (resource->desc == IORES_DESC_DEVICE_PRIVATE_MEMORY)
> -		__remove_pages(zone, start_pfn, npages, NULL);
> +		mapping = false;
>  	else
> -		arch_remove_memory(nid, start_pfn << PAGE_SHIFT,
> -				   npages << PAGE_SHIFT, NULL);
> +		mapping = true;
> +
> +	mem_hotplug_begin();
> +	del_device_memory(nid, start_pfn << PAGE_SHIFT, npages << PAGE_SHIFT,
> +								NULL,
> +								mapping);
>  	mem_hotplug_done();
>  
>  	hmm_devmem_radix_release(resource);
> @@ -1026,6 +1030,7 @@ static int hmm_devmem_pages_create(struct hmm_devmem *devmem)
>  	resource_size_t key, align_start, align_size, align_end;
>  	struct device *device = devmem->device;
>  	int ret, nid, is_ram;
> +	bool mapping;
>  
>  	align_start = devmem->resource->start & ~(PA_SECTION_SIZE - 1);
>  	align_size = ALIGN(devmem->resource->start +
> @@ -1084,7 +1089,6 @@ static int hmm_devmem_pages_create(struct hmm_devmem *devmem)
>  	if (nid < 0)
>  		nid = numa_mem_id();
>  
> -	mem_hotplug_begin();
>  	/*
>  	 * For device private memory we call add_pages() as we only need to
>  	 * allocate and initialize struct page for the device memory. More-
> @@ -1096,20 +1100,17 @@ static int hmm_devmem_pages_create(struct hmm_devmem *devmem)
>  	 * want the linear mapping and thus use arch_add_memory().
>  	 */

Some parts of this comment should be moved into add_device_memory now.
(e.g. we call add_pages() ...)

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
> +	mem_hotplug_begin();
> +	ret = add_device_memory(nid, align_start, align_size, NULL, mapping);
>  	mem_hotplug_done();
>  
> +	if (ret)
> +		goto error_add_memory;
> +
>  	/*
>  	 * Initialization of the pages has been deferred until now in order
>  	 * to allow us to do the work while not holding the hotplug lock.
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 33d448314b3f..5874aceb81ac 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1889,4 +1889,45 @@ void remove_memory(int nid, u64 start, u64 size)
>  	unlock_device_hotplug();
>  }
>  EXPORT_SYMBOL_GPL(remove_memory);
> +
> +#ifdef CONFIG_ZONE_DEVICE
> +int del_device_memory(int nid, unsigned long start, unsigned long size,
> +				struct vmem_altmap *altmap, bool mapping)
> +{
> +	int ret;

nit: personally I prefer short parameters last in the list.

> +	unsigned long start_pfn = PHYS_PFN(start);
> +	unsigned long nr_pages = size >> PAGE_SHIFT;
> +	struct zone *zone = page_zone(pfn_to_page(pfn));
> +
> +	if (mapping)
> +		ret = arch_remove_memory(nid, start, size, altmap);
> +	else
> +		ret = __remove_pages(zone, start_pfn, nr_pages, altmap);
> +
> +	return ret;
> +}
> +#endif
>  #endif /* CONFIG_MEMORY_HOTREMOVE */
> +
> +#ifdef CONFIG_ZONE_DEVICE
> +int add_device_memory(int nid, unsigned long start, unsigned long size,
> +				struct vmem_altmap *altmap, bool mapping)
> +{
> +	int ret;

dito

> +	unsigned long start_pfn = PHYS_PFN(start);
> +	unsigned long nr_pages = size >> PAGE_SHIFT;
> +
> +	if (mapping)
> +		ret = arch_add_memory(nid, start, size, altmap, false);
> +	else
> +		ret = add_pages(nid, start_pfn, nr_pages, altmap, false);
> +
> +	if (!ret) {
> +		struct zone *zone = &NODE_DATA(nid)->node_zones[ZONE_DEVICE];
> +
> +		move_pfn_range_to_zone(zone, start_pfn, nr_pages, altmap);
> +	}
> +
> +	return ret;
> +}
> +#endif
> 

Can you document for both functions that they should be called with the
memory hotplug lock in write?

Apart from that looks good to me.

-- 

Thanks,

David / dhildenb
