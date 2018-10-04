Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4B6D46B000D
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 05:52:16 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id g131-v6so7688405qke.17
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 02:52:16 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p15-v6si833670qkg.232.2018.10.04.02.52.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 02:52:15 -0700 (PDT)
Subject: Re: [RFC PATCH v3 1/5] mm/memory_hotplug: Add nid parameter to
 arch_remove_memory
References: <20181002150029.23461-1-osalvador@techadventures.net>
 <20181002150029.23461-2-osalvador@techadventures.net>
From: David Hildenbrand <david@redhat.com>
Message-ID: <df5ebe1d-2fd9-3015-321a-378bb160c4f0@redhat.com>
Date: Thu, 4 Oct 2018 11:52:09 +0200
MIME-Version: 1.0
In-Reply-To: <20181002150029.23461-2-osalvador@techadventures.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>, linux-mm@kvack.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, yasu.isimatu@gmail.com, rppt@linux.vnet.ibm.com, malat@debian.org, linux-kernel@vger.kernel.org, pavel.tatashin@microsoft.com, jglisse@redhat.com, Jonathan.Cameron@huawei.com, rafael@kernel.org, dave.jiang@intel.com, Oscar Salvador <osalvador@suse.de>

On 02/10/2018 17:00, Oscar Salvador wrote:
> From: Oscar Salvador <osalvador@suse.de>
> 
> This patch is only a preparation for the following-up patches.
> The idea of passing the nid is that will allow us to get rid
> of the zone parameter in the patches that follow
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> ---
>  arch/ia64/mm/init.c            | 2 +-
>  arch/powerpc/mm/mem.c          | 2 +-
>  arch/s390/mm/init.c            | 2 +-
>  arch/sh/mm/init.c              | 2 +-
>  arch/x86/mm/init_32.c          | 2 +-
>  arch/x86/mm/init_64.c          | 2 +-
>  include/linux/memory_hotplug.h | 2 +-
>  kernel/memremap.c              | 4 +++-
>  mm/memory_hotplug.c            | 2 +-
>  9 files changed, 11 insertions(+), 9 deletions(-)
> 
> diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
> index d5e12ff1d73c..904fe55e10fc 100644
> --- a/arch/ia64/mm/init.c
> +++ b/arch/ia64/mm/init.c
> @@ -661,7 +661,7 @@ int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
>  }
>  
>  #ifdef CONFIG_MEMORY_HOTREMOVE
> -int arch_remove_memory(u64 start, u64 size, struct vmem_altmap *altmap)
> +int arch_remove_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap)
>  {
>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
> diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
> index 578cbb262c01..445fce705f91 100644
> --- a/arch/powerpc/mm/mem.c
> +++ b/arch/powerpc/mm/mem.c
> @@ -138,7 +138,7 @@ int __meminit arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *
>  }
>  
>  #ifdef CONFIG_MEMORY_HOTREMOVE
> -int __meminit arch_remove_memory(u64 start, u64 size, struct vmem_altmap *altmap)
> +int __meminit arch_remove_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap)
>  {
>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
> diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
> index e472cd763eb3..f705da1a085f 100644
> --- a/arch/s390/mm/init.c
> +++ b/arch/s390/mm/init.c
> @@ -239,7 +239,7 @@ int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
>  }
>  
>  #ifdef CONFIG_MEMORY_HOTREMOVE
> -int arch_remove_memory(u64 start, u64 size, struct vmem_altmap *altmap)
> +int arch_remove_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap)
>  {
>  	/*
>  	 * There is no hardware or firmware interface which could trigger a
> diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
> index c8c13c777162..a8e5c0e00fca 100644
> --- a/arch/sh/mm/init.c
> +++ b/arch/sh/mm/init.c
> @@ -443,7 +443,7 @@ EXPORT_SYMBOL_GPL(memory_add_physaddr_to_nid);
>  #endif
>  
>  #ifdef CONFIG_MEMORY_HOTREMOVE
> -int arch_remove_memory(u64 start, u64 size, struct vmem_altmap *altmap)
> +int arch_remove_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap)
>  {
>  	unsigned long start_pfn = PFN_DOWN(start);
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
> diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
> index f2837e4c40b3..b2a698d87a0e 100644
> --- a/arch/x86/mm/init_32.c
> +++ b/arch/x86/mm/init_32.c
> @@ -860,7 +860,7 @@ int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
>  }
>  
>  #ifdef CONFIG_MEMORY_HOTREMOVE
> -int arch_remove_memory(u64 start, u64 size, struct vmem_altmap *altmap)
> +int arch_remove_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap)
>  {
>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index 5fab264948c2..c754d9543ae1 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -1147,7 +1147,7 @@ kernel_physical_mapping_remove(unsigned long start, unsigned long end)
>  	remove_pagetable(start, end, true, NULL);
>  }
>  
> -int __ref arch_remove_memory(u64 start, u64 size, struct vmem_altmap *altmap)
> +int __ref arch_remove_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap)
>  {
>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index ffd9cd10fcf3..f9fc35819e65 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -107,7 +107,7 @@ static inline bool movable_node_is_enabled(void)
>  }
>  
>  #ifdef CONFIG_MEMORY_HOTREMOVE
> -extern int arch_remove_memory(u64 start, u64 size,
> +extern int arch_remove_memory(int nid, u64 start, u64 size,
>  		struct vmem_altmap *altmap);
>  extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
>  	unsigned long nr_pages, struct vmem_altmap *altmap);
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index e3036433ce4e..fe54bba2d7e2 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -121,6 +121,7 @@ static void devm_memremap_pages_release(void *data)
>  	struct resource *res = &pgmap->res;
>  	resource_size_t align_start, align_size;
>  	unsigned long pfn;
> +	int nid;
>  
>  	pgmap->kill(pgmap->ref);
>  	for_each_device_pfn(pfn, pgmap)
> @@ -130,6 +131,7 @@ static void devm_memremap_pages_release(void *data)
>  	align_start = res->start & ~(SECTION_SIZE - 1);
>  	align_size = ALIGN(res->start + resource_size(res), SECTION_SIZE)
>  		- align_start;
> +	nid = dev_to_node(dev);
>  
>  	mem_hotplug_begin();
>  	if (pgmap->type == MEMORY_DEVICE_PRIVATE) {
> @@ -137,7 +139,7 @@ static void devm_memremap_pages_release(void *data)
>  		__remove_pages(page_zone(pfn_to_page(pfn)), pfn,
>  				align_size >> PAGE_SHIFT, NULL);
>  	} else {
> -		arch_remove_memory(align_start, align_size,
> +		arch_remove_memory(nid, align_start, align_size,
>  				pgmap->altmap_valid ? &pgmap->altmap : NULL);
>  		kasan_remove_zero_shadow(__va(align_start), align_size);
>  	}
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index d4c7e42e46f3..11b7dcf83323 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1890,7 +1890,7 @@ void __ref __remove_memory(int nid, u64 start, u64 size)
>  	memblock_free(start, size);
>  	memblock_remove(start, size);
>  
> -	arch_remove_memory(start, size, NULL);
> +	arch_remove_memory(nid, start, size, NULL);
>  
>  	try_offline_node(nid);
>  
> 

Reviewed-by: David Hildenbrand <david@redhat.com>

-- 

Thanks,

David / dhildenb
