Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6A8346B04B7
	for <linux-mm@kvack.org>; Sun, 20 Nov 2016 20:03:50 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id q10so365149990pgq.7
        for <linux-mm@kvack.org>; Sun, 20 Nov 2016 17:03:50 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id o1si6309185pgc.285.2016.11.20.17.03.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Nov 2016 17:03:49 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id x23so26841305pgx.3
        for <linux-mm@kvack.org>; Sun, 20 Nov 2016 17:03:48 -0800 (PST)
Subject: Re: [HMM v13 01/18] mm/memory/hotplug: convert device parameter bool
 to set of flags
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-2-git-send-email-jglisse@redhat.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <e4157b8e-ef9b-0539-bb2b-649152fbc7f2@gmail.com>
Date: Mon, 21 Nov 2016 11:44:36 +1100
MIME-Version: 1.0
In-Reply-To: <1479493107-982-2-git-send-email-jglisse@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Russell King <linux@armlinux.org.uk>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Chris Metcalf <cmetcalf@mellanox.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>



On 19/11/16 05:18, JA(C)rA'me Glisse wrote:
> Only usefull for arch where we support ZONE_DEVICE and where we want to
> also support un-addressable device memory. We need struct page for such
> un-addressable memory. But we should avoid populating the kernel linear
> mapping for the physical address range because there is no real memory
> or anything behind those physical address.
> 
> Hence we need more flags than just knowing if it is device memory or not.
> 


Isn't it better to add a wrapper to arch_add/remove_memory and do those
checks inside and then call arch_add/remove_memory to reduce the churn.
If you need selectively enable MEMORY_UNADDRESSABLE that can be done with
_ARCH_HAS_FEATURE

> Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
> Cc: Russell King <linux@armlinux.org.uk>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
> Cc: Rich Felker <dalias@libc.org>
> Cc: Chris Metcalf <cmetcalf@mellanox.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> ---
>  arch/ia64/mm/init.c            | 19 ++++++++++++++++---
>  arch/powerpc/mm/mem.c          | 18 +++++++++++++++---
>  arch/s390/mm/init.c            | 10 ++++++++--
>  arch/sh/mm/init.c              | 18 +++++++++++++++---
>  arch/tile/mm/init.c            | 10 ++++++++--
>  arch/x86/mm/init_32.c          | 19 ++++++++++++++++---
>  arch/x86/mm/init_64.c          | 19 ++++++++++++++++---
>  include/linux/memory_hotplug.h | 17 +++++++++++++++--
>  kernel/memremap.c              |  4 ++--
>  mm/memory_hotplug.c            |  4 ++--
>  10 files changed, 113 insertions(+), 25 deletions(-)
> 
> diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
> index 1841ef6..95a2fa5 100644
> --- a/arch/ia64/mm/init.c
> +++ b/arch/ia64/mm/init.c
> @@ -645,7 +645,7 @@ mem_init (void)
>  }
>  
>  #ifdef CONFIG_MEMORY_HOTPLUG
> -int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
> +int arch_add_memory(int nid, u64 start, u64 size, int flags)
>  {
>  	pg_data_t *pgdat;
>  	struct zone *zone;
> @@ -653,10 +653,17 @@ int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
>  	int ret;
>  
> +	/* Need to add support for device and unaddressable memory if needed */
> +	if (flags & MEMORY_UNADDRESSABLE) {
> +		BUG();
> +		return -EINVAL;
> +	}
> +
>  	pgdat = NODE_DATA(nid);
>  
>  	zone = pgdat->node_zones +
> -		zone_for_memory(nid, start, size, ZONE_NORMAL, for_device);
> +		zone_for_memory(nid, start, size, ZONE_NORMAL,
> +				flags & MEMORY_DEVICE);
>  	ret = __add_pages(nid, zone, start_pfn, nr_pages);
>  
>  	if (ret)
> @@ -667,13 +674,19 @@ int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
>  }
>  
>  #ifdef CONFIG_MEMORY_HOTREMOVE
> -int arch_remove_memory(u64 start, u64 size)
> +int arch_remove_memory(u64 start, u64 size, int flags)
>  {
>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
>  	struct zone *zone;
>  	int ret;
>  
> +	/* Need to add support for device and unaddressable memory if needed */
> +	if (flags & MEMORY_UNADDRESSABLE) {
> +		BUG();
> +		return -EINVAL;
> +	}
> +
>  	zone = page_zone(pfn_to_page(start_pfn));
>  	ret = __remove_pages(zone, start_pfn, nr_pages);
>  	if (ret)
> diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
> index 5f84433..e3c0532 100644
> --- a/arch/powerpc/mm/mem.c
> +++ b/arch/powerpc/mm/mem.c
> @@ -126,7 +126,7 @@ int __weak remove_section_mapping(unsigned long start, unsigned long end)
>  	return -ENODEV;
>  }
>  
> -int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
> +int arch_add_memory(int nid, u64 start, u64 size, int flags)
>  {
>  	struct pglist_data *pgdata;
>  	struct zone *zone;
> @@ -134,6 +134,12 @@ int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
>  	int rc;
>  
> +	/* Need to add support for device and unaddressable memory if needed */
> +	if (flags & MEMORY_UNADDRESSABLE) {
> +		BUG();
> +		return -EINVAL;
> +	}
> +
>  	pgdata = NODE_DATA(nid);
>  
>  	start = (unsigned long)__va(start);
> @@ -147,18 +153,24 @@ int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
>  
>  	/* this should work for most non-highmem platforms */
>  	zone = pgdata->node_zones +
> -		zone_for_memory(nid, start, size, 0, for_device);
> +		zone_for_memory(nid, start, size, 0, flags & MEMORY_DEVICE);
>  
>  	return __add_pages(nid, zone, start_pfn, nr_pages);
>  }
>  
>  #ifdef CONFIG_MEMORY_HOTREMOVE
> -int arch_remove_memory(u64 start, u64 size)
> +int arch_remove_memory(u64 start, u64 size, int flags)
>  {
>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
>  	struct zone *zone;
>  	int ret;
> +	
> +	/* Need to add support for device and unaddressable memory if needed */
> +	if (flags & MEMORY_UNADDRESSABLE) {
> +		BUG();
> +		return -EINVAL;
> +	}
>  
>  	zone = page_zone(pfn_to_page(start_pfn));
>  	ret = __remove_pages(zone, start_pfn, nr_pages);
> diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
> index f56a39b..4147b87 100644
> --- a/arch/s390/mm/init.c
> +++ b/arch/s390/mm/init.c
> @@ -149,7 +149,7 @@ void __init free_initrd_mem(unsigned long start, unsigned long end)
>  #endif
>  
>  #ifdef CONFIG_MEMORY_HOTPLUG
> -int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
> +int arch_add_memory(int nid, u64 start, u64 size, int flags)
>  {
>  	unsigned long normal_end_pfn = PFN_DOWN(memblock_end_of_DRAM());
>  	unsigned long dma_end_pfn = PFN_DOWN(MAX_DMA_ADDRESS);
> @@ -158,6 +158,12 @@ int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
>  	unsigned long nr_pages;
>  	int rc, zone_enum;
>  
> +	/* Need to add support for device and unaddressable memory if needed */
> +	if (flags & MEMORY_UNADDRESSABLE) {
> +		BUG();
> +		return -EINVAL;
> +	}
> +
>  	rc = vmem_add_mapping(start, size);
>  	if (rc)
>  		return rc;
> @@ -197,7 +203,7 @@ unsigned long memory_block_size_bytes(void)
>  }
>  
>  #ifdef CONFIG_MEMORY_HOTREMOVE
> -int arch_remove_memory(u64 start, u64 size)
> +int arch_remove_memory(u64 start, u64 size, int flags)
>  {
>  	/*
>  	 * There is no hardware or firmware interface which could trigger a
> diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
> index 7549186..f72a402 100644
> --- a/arch/sh/mm/init.c
> +++ b/arch/sh/mm/init.c
> @@ -485,19 +485,25 @@ void free_initrd_mem(unsigned long start, unsigned long end)
>  #endif
>  
>  #ifdef CONFIG_MEMORY_HOTPLUG
> -int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
> +int arch_add_memory(int nid, u64 start, u64 size, int flags)
>  {
>  	pg_data_t *pgdat;
>  	unsigned long start_pfn = PFN_DOWN(start);
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
>  	int ret;
>  
> +	/* Need to add support for device and unaddressable memory if needed */
> +	if (flags & MEMORY_UNADDRESSABLE) {
> +		BUG();
> +		return -EINVAL;
> +	}
> +
>  	pgdat = NODE_DATA(nid);
>  
>  	/* We only have ZONE_NORMAL, so this is easy.. */
>  	ret = __add_pages(nid, pgdat->node_zones +
>  			zone_for_memory(nid, start, size, ZONE_NORMAL,
> -			for_device),
> +					flags & MEMORY_DEVICE),
>  			start_pfn, nr_pages);
>  	if (unlikely(ret))
>  		printk("%s: Failed, __add_pages() == %d\n", __func__, ret);
> @@ -516,13 +522,19 @@ EXPORT_SYMBOL_GPL(memory_add_physaddr_to_nid);
>  #endif
>  
>  #ifdef CONFIG_MEMORY_HOTREMOVE
> -int arch_remove_memory(u64 start, u64 size)
> +int arch_remove_memory(u64 start, u64 size, int flags)
>  {
>  	unsigned long start_pfn = PFN_DOWN(start);
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
>  	struct zone *zone;
>  	int ret;
>  
> +	/* Need to add support for device and unaddressable memory if needed */
> +	if (flags & MEMORY_UNADDRESSABLE) {
> +		BUG();
> +		return -EINVAL;
> +	}
> +
>  	zone = page_zone(pfn_to_page(start_pfn));
>  	ret = __remove_pages(zone, start_pfn, nr_pages);
>  	if (unlikely(ret))
> diff --git a/arch/tile/mm/init.c b/arch/tile/mm/init.c
> index adce254..5fd972c 100644
> --- a/arch/tile/mm/init.c
> +++ b/arch/tile/mm/init.c
> @@ -863,13 +863,19 @@ void __init mem_init(void)
>   * memory to the highmem for now.
>   */
>  #ifndef CONFIG_NEED_MULTIPLE_NODES
> -int arch_add_memory(u64 start, u64 size, bool for_device)
> +int arch_add_memory(u64 start, u64 size, int flags)
>  {
>  	struct pglist_data *pgdata = &contig_page_data;
>  	struct zone *zone = pgdata->node_zones + MAX_NR_ZONES-1;
>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
>  
> +	/* Need to add support for device and unaddressable memory if needed */
> +	if (flags & MEMORY_UNADDRESSABLE) {
> +		BUG();
> +		return -EINVAL;
> +	}
> +
>  	return __add_pages(zone, start_pfn, nr_pages);
>  }
>  
> @@ -879,7 +885,7 @@ int remove_memory(u64 start, u64 size)
>  }
>  
>  #ifdef CONFIG_MEMORY_HOTREMOVE
> -int arch_remove_memory(u64 start, u64 size)
> +int arch_remove_memory(u64 start, u64 size, int flags)
>  {
>  	/* TODO */
>  	return -EBUSY;
> diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
> index cf80590..16a9095 100644
> --- a/arch/x86/mm/init_32.c
> +++ b/arch/x86/mm/init_32.c
> @@ -816,24 +816,37 @@ void __init mem_init(void)
>  }
>  
>  #ifdef CONFIG_MEMORY_HOTPLUG
> -int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
> +int arch_add_memory(int nid, u64 start, u64 size, int flags)
>  {
>  	struct pglist_data *pgdata = NODE_DATA(nid);
>  	struct zone *zone = pgdata->node_zones +
> -		zone_for_memory(nid, start, size, ZONE_HIGHMEM, for_device);
> +		zone_for_memory(nid, start, size, ZONE_HIGHMEM,
> +				flags & MEMORY_DEVICE);
>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
>  
> +	/* Need to add support for device and unaddressable memory if needed */
> +	if (flags & MEMORY_UNADDRESSABLE) {
> +		BUG();
> +		return -EINVAL;
> +	}
> +
>  	return __add_pages(nid, zone, start_pfn, nr_pages);
>  }
>  
>  #ifdef CONFIG_MEMORY_HOTREMOVE
> -int arch_remove_memory(u64 start, u64 size)
> +int arch_remove_memory(u64 start, u64 size, int flags)
>  {
>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
>  	struct zone *zone;
>  
> +	/* Need to add support for device and unaddressable memory if needed */
> +	if (flags & MEMORY_UNADDRESSABLE) {
> +		BUG();
> +		return -EINVAL;
> +	}
> +
>  	zone = page_zone(pfn_to_page(start_pfn));
>  	return __remove_pages(zone, start_pfn, nr_pages);
>  }
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index 14b9dd7..8c4abb0 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -651,15 +651,22 @@ static void  update_end_of_memory_vars(u64 start, u64 size)
>   * Memory is added always to NORMAL zone. This means you will never get
>   * additional DMA/DMA32 memory.
>   */
> -int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
> +int arch_add_memory(int nid, u64 start, u64 size, int flags)
>  {
>  	struct pglist_data *pgdat = NODE_DATA(nid);
>  	struct zone *zone = pgdat->node_zones +
> -		zone_for_memory(nid, start, size, ZONE_NORMAL, for_device);
> +		zone_for_memory(nid, start, size, ZONE_NORMAL,
> +				flags & MEMORY_DEVICE);
>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
>  	int ret;
>  
> +	/* Need to add support for device and unaddressable memory if needed */
> +	if (flags & MEMORY_UNADDRESSABLE) {
> +		BUG();
> +		return -EINVAL;
> +	}
> +
>  	init_memory_mapping(start, start + size);
>  
>  	ret = __add_pages(nid, zone, start_pfn, nr_pages);
> @@ -956,7 +963,7 @@ kernel_physical_mapping_remove(unsigned long start, unsigned long end)
>  	remove_pagetable(start, end, true);
>  }
>  
> -int __ref arch_remove_memory(u64 start, u64 size)
> +int __ref arch_remove_memory(u64 start, u64 size, int flags)
>  {
>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
> @@ -965,6 +972,12 @@ int __ref arch_remove_memory(u64 start, u64 size)
>  	struct zone *zone;
>  	int ret;
>  
> +	/* Need to add support for device and unaddressable memory if needed */
> +	if (flags & MEMORY_UNADDRESSABLE) {
> +		BUG();
> +		return -EINVAL;
> +	}
> +
>  	/* With altmap the first mapped page is offset from @start */
>  	altmap = to_vmem_altmap((unsigned long) page);
>  	if (altmap)
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index 01033fa..ba9b12e 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -103,7 +103,7 @@ extern bool memhp_auto_online;
>  
>  #ifdef CONFIG_MEMORY_HOTREMOVE
>  extern bool is_pageblock_removable_nolock(struct page *page);
> -extern int arch_remove_memory(u64 start, u64 size);
> +extern int arch_remove_memory(u64 start, u64 size, int flags);
>  extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
>  	unsigned long nr_pages);
>  #endif /* CONFIG_MEMORY_HOTREMOVE */
> @@ -275,7 +275,20 @@ extern int add_memory(int nid, u64 start, u64 size);
>  extern int add_memory_resource(int nid, struct resource *resource, bool online);
>  extern int zone_for_memory(int nid, u64 start, u64 size, int zone_default,
>  		bool for_device);
> -extern int arch_add_memory(int nid, u64 start, u64 size, bool for_device);
> +
> +/*
> + * For device memory we want more informations than just knowing it is device
				     information
> + * memory. We want to know if we can migrate it (ie it is not storage memory
> + * use by DAX). Is it addressable by the CPU ? Some device memory like GPU
> + * memory can not be access by CPU but we still want struct page so that we
			accessed
> + * can use it like regular memory.

Can you please add some details on why -- migration needs them for example?

> + */
> +#define MEMORY_FLAGS_NONE 0
> +#define MEMORY_DEVICE (1 << 0)
> +#define MEMORY_MOVABLE (1 << 1)
> +#define MEMORY_UNADDRESSABLE (1 << 2)
> +
> +extern int arch_add_memory(int nid, u64 start, u64 size, int flags);
>  extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
>  extern bool is_memblock_offlined(struct memory_block *mem);
>  extern void remove_memory(int nid, u64 start, u64 size);
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index b501e39..07665eb 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -246,7 +246,7 @@ static void devm_memremap_pages_release(struct device *dev, void *data)
>  	/* pages are dead and unused, undo the arch mapping */
>  	align_start = res->start & ~(SECTION_SIZE - 1);
>  	align_size = ALIGN(resource_size(res), SECTION_SIZE);
> -	arch_remove_memory(align_start, align_size);
> +	arch_remove_memory(align_start, align_size, MEMORY_DEVICE);
>  	untrack_pfn(NULL, PHYS_PFN(align_start), align_size);
>  	pgmap_radix_release(res);
>  	dev_WARN_ONCE(dev, pgmap->altmap && pgmap->altmap->alloc,
> @@ -358,7 +358,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
>  	if (error)
>  		goto err_pfn_remap;
>  
> -	error = arch_add_memory(nid, align_start, align_size, true);
> +	error = arch_add_memory(nid, align_start, align_size, MEMORY_DEVICE);
>  	if (error)
>  		goto err_add_memory;
>  
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 9629273..b2942d7 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1386,7 +1386,7 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
>  	}
>  
>  	/* call arch's memory hotadd */
> -	ret = arch_add_memory(nid, start, size, false);
> +	ret = arch_add_memory(nid, start, size, MEMORY_FLAGS_NONE);
>  
>  	if (ret < 0)
>  		goto error;
> @@ -2205,7 +2205,7 @@ void __ref remove_memory(int nid, u64 start, u64 size)
>  	memblock_free(start, size);
>  	memblock_remove(start, size);
>  
> -	arch_remove_memory(start, size);
> +	arch_remove_memory(start, size, MEMORY_FLAGS_NONE);
>  
>  	try_offline_node(nid);
>  
> 

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
