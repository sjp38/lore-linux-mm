Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9C3866B0394
	for <linux-mm@kvack.org>; Sun, 19 Mar 2017 16:09:09 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id c5so12918677wmi.0
        for <linux-mm@kvack.org>; Sun, 19 Mar 2017 13:09:09 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id y63si12135249wme.103.2017.03.19.13.09.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 19 Mar 2017 13:09:08 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id A9CFE98D0A
	for <linux-mm@kvack.org>; Sun, 19 Mar 2017 20:09:07 +0000 (UTC)
Date: Sun, 19 Mar 2017 20:09:01 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [HMM 04/16] mm/ZONE_DEVICE/unaddressable: add support for
 un-addressable device memory v3
Message-ID: <20170319200901.GE2774@techsingularity.net>
References: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
 <1489680335-6594-5-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1489680335-6594-5-git-send-email-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: J?r?me Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

Nits mainly

On Thu, Mar 16, 2017 at 12:05:23PM -0400, J?r?me Glisse wrote:
> This add support for un-addressable device memory. Such memory is hotpluged

hotplugged

> only so we can have struct page but we should never map them as such memory
> can not be accessed by CPU. For that reason it uses a special swap entry for
> CPU page table entry.
> 
> This patch implement all the logic from special swap type to handling CPU
> page fault through a callback specified in the ZONE_DEVICE pgmap struct.
> 
> Architecture that wish to support un-addressable device memory should make
> sure to never populate the kernel linar mapping for the physical range.
> 
> This feature potentially breaks memory hotplug unless every driver using it
> magically predicts the future addresses of where memory will be hotplugged.
> 


Note in the changelog that enabling this option reduces the maximum
number of swapfiles that can be activated.

Also, you have to read quite a lot of the patch before you learn that
the struct pages are required for migration. It's be nice to lead with
why struct pages are required for memory that can never be
CPU-accessible.

> <SNIP>
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 45e91dd..ba564bc 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -51,6 +51,17 @@ static inline int current_is_kswapd(void)
>   */
>  
>  /*
> + * Un-addressable device memory support
> + */
> +#ifdef CONFIG_DEVICE_UNADDRESSABLE
> +#define SWP_DEVICE_NUM 2
> +#define SWP_DEVICE_WRITE (MAX_SWAPFILES + SWP_HWPOISON_NUM + SWP_MIGRATION_NUM)
> +#define SWP_DEVICE (MAX_SWAPFILES + SWP_HWPOISON_NUM + SWP_MIGRATION_NUM + 1)
> +#else
> +#define SWP_DEVICE_NUM 0
> +#endif
> +
> +/*
>   * NUMA node memory migration support
>   */
>  #ifdef CONFIG_MIGRATION
> @@ -72,7 +83,8 @@ static inline int current_is_kswapd(void)
>  #endif
>  
>  #define MAX_SWAPFILES \
> -	((1 << MAX_SWAPFILES_SHIFT) - SWP_MIGRATION_NUM - SWP_HWPOISON_NUM)
> +	((1 << MAX_SWAPFILES_SHIFT) - SWP_DEVICE_NUM - \
> +	SWP_MIGRATION_NUM - SWP_HWPOISON_NUM)
>  
>  /*
>   * Magic header for a swap area. The first part of the union is

Max swap count reduced here and it looks fine other than the limitation
should be clear.

> @@ -435,8 +447,8 @@ static inline void show_swap_cache_info(void)
>  {
>  }
>  
> -#define free_swap_and_cache(swp)	is_migration_entry(swp)
> -#define swapcache_prepare(swp)		is_migration_entry(swp)
> +#define free_swap_and_cache(e) (is_migration_entry(e) || is_device_entry(e))
> +#define swapcache_prepare(e) (is_migration_entry(e) || is_device_entry(e))
>  
>  static inline int add_swap_count_continuation(swp_entry_t swp, gfp_t gfp_mask)
>  {
> diff --git a/include/linux/swapops.h b/include/linux/swapops.h
> index 5c3a5f3..0e339f0 100644
> --- a/include/linux/swapops.h
> +++ b/include/linux/swapops.h
> @@ -100,6 +100,73 @@ static inline void *swp_to_radix_entry(swp_entry_t entry)
>  	return (void *)(value | RADIX_TREE_EXCEPTIONAL_ENTRY);
>  }
>  
> +#if IS_ENABLED(CONFIG_DEVICE_UNADDRESSABLE)
> +static inline swp_entry_t make_device_entry(struct page *page, bool write)
> +{
> +	return swp_entry(write?SWP_DEVICE_WRITE:SWP_DEVICE, page_to_pfn(page));
> +}
> +

Minor naming nit. Migration has READ and WRITE migration types but this
has SWP_DEVICE and SWP_DEVICE_WRITE. This was the first time it was
clear there are READ/WRITE types but with different naming.

> +static inline bool is_device_entry(swp_entry_t entry)
> +{
> +	int type = swp_type(entry);
> +	return type == SWP_DEVICE || type == SWP_DEVICE_WRITE;
> +}
> +
> +static inline void make_device_entry_read(swp_entry_t *entry)
> +{
> +	*entry = swp_entry(SWP_DEVICE, swp_offset(*entry));
> +}
> +
> +static inline bool is_write_device_entry(swp_entry_t entry)
> +{
> +	return unlikely(swp_type(entry) == SWP_DEVICE_WRITE);
> +}
> +
> +static inline struct page *device_entry_to_page(swp_entry_t entry)
> +{
> +	return pfn_to_page(swp_offset(entry));
> +}
> +

Otherwise, looks ok and fairly standard.

>  {
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index 19df1f5..d42f039f 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -18,6 +18,8 @@
>  #include <linux/io.h>
>  #include <linux/mm.h>
>  #include <linux/memory_hotplug.h>
> +#include <linux/swap.h>
> +#include <linux/swapops.h>
>  
>  #ifndef ioremap_cache
>  /* temporary while we convert existing ioremap_cache users to memremap */
> @@ -203,6 +205,21 @@ void put_zone_device_page(struct page *page)
>  }
>  EXPORT_SYMBOL(put_zone_device_page);
>  
> +#if IS_ENABLED(CONFIG_DEVICE_UNADDRESSABLE)
> +int device_entry_fault(struct vm_area_struct *vma,
> +		       unsigned long addr,
> +		       swp_entry_t entry,
> +		       unsigned flags,
> +		       pmd_t *pmdp)
> +{
> +	struct page *page = device_entry_to_page(entry);
> +
> +	BUG_ON(!page->pgmap->page_fault);
> +	return page->pgmap->page_fault(vma, addr, page, flags, pmdp);
> +}

The BUG_ON is overkill. It'll trigger a NULL pointer exception
immediately and would likely be a fairly obvious driver bug. 

More importantly, there should be a description of what the
responsibilities of page_fault are. Saying it's a fault helpful when it
could say here (or in the struct description) that the handled is
responsible for migrating the data from device memory to CPU-accessible
memory.

What is expected to happen if migration fails? Think something crazy like
a process that is memcg limited, is mostly anonymous memory and there is
no swap. Is it acceptable for the application to be killed?

> +EXPORT_SYMBOL(device_entry_fault);
> +#endif /* CONFIG_DEVICE_UNADDRESSABLE */
> +
>  static void pgmap_radix_release(struct resource *res)
>  {
>  	resource_size_t key, align_start, align_size, align_end;
> @@ -258,7 +275,7 @@ static void devm_memremap_pages_release(struct device *dev, void *data)
>  
>  	lock_device_hotplug();
>  	mem_hotplug_begin();
> -	arch_remove_memory(align_start, align_size, MEMORY_DEVICE);
> +	arch_remove_memory(align_start, align_size, pgmap->flags);
>  	mem_hotplug_done();
>  	unlock_device_hotplug();
>  
> @@ -338,6 +355,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
>  	pgmap->ref = ref;
>  	pgmap->res = &page_map->res;
>  	pgmap->flags = MEMORY_DEVICE;
> +	pgmap->page_fault = NULL;
>  	pgmap->page_free = NULL;
>  	pgmap->data = NULL;
>  
> @@ -378,7 +396,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
>  
>  	lock_device_hotplug();
>  	mem_hotplug_begin();
> -	error = arch_add_memory(nid, align_start, align_size, MEMORY_DEVICE);
> +	error = arch_add_memory(nid, align_start, align_size, pgmap->flags);
>  	mem_hotplug_done();
>  	unlock_device_hotplug();
>  	if (error)
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 9b8fccb..9502315 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -700,6 +700,18 @@ config ZONE_DEVICE
>  
>  	  If FS_DAX is enabled, then say Y.
>  
> +config DEVICE_UNADDRESSABLE
> +	bool "Un-addressable device memory (GPU memory, ...)"
> +	depends on ZONE_DEVICE
> +
> +	help
> +	  Allow to create struct page for un-addressable device memory
> +	  ie memory that is only accessible by the device (or group of
> +	  devices).
> +
> +	  Having struct page is necessary for process memory migration
> +	  to device memory.
> +
>  config FRAME_VECTOR
>  	bool
>  
> diff --git a/mm/memory.c b/mm/memory.c
> index 235ba51..33aff303 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -49,6 +49,7 @@
>  #include <linux/swap.h>
>  #include <linux/highmem.h>
>  #include <linux/pagemap.h>
> +#include <linux/memremap.h>
>  #include <linux/ksm.h>
>  #include <linux/rmap.h>
>  #include <linux/export.h>
> @@ -927,6 +928,25 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>  					pte = pte_swp_mksoft_dirty(pte);
>  				set_pte_at(src_mm, addr, src_pte, pte);
>  			}
> +		} else if (is_device_entry(entry)) {
> +			page = device_entry_to_page(entry);
> +
> +			/*
> +			 * Update rss count even for un-addressable page as
> +			 * they should be consider just like any other page.
> +			 */
> +			get_page(page);
> +			rss[mm_counter(page)]++;
> +			page_dup_rmap(page, false);
> +
> +			if (is_write_device_entry(entry) &&
> +			    is_cow_mapping(vm_flags)) {
> +				make_device_entry_read(&entry);
> +				pte = swp_entry_to_pte(entry);
> +				if (pte_swp_soft_dirty(*src_pte))
> +					pte = pte_swp_mksoft_dirty(pte);
> +				set_pte_at(src_mm, addr, src_pte, pte);
> +			}
>  		}
>  		goto out_set_pte;
>  	}

I'm curious about the soft dirty page handling part. One of the main
reasons for that is for features like checkpoint/restore but the memory in
question in inaccessible so how can should that be handled?  Superficially,
it looks like soft dirty handling with inaccessible memory is a no-go. I
would think that is even a reasonable restriction but it should be clear.

Presumably if an entry needs COW at some point in the future, it's the
device callback that handles it.

> @@ -3679,6 +3735,7 @@ static int wp_huge_pud(struct vm_fault *vmf, pud_t orig_pud)
>  static int handle_pte_fault(struct vm_fault *vmf)
>  {
>  	pte_t entry;
> +	struct page *page;
>  
>  	if (unlikely(pmd_none(*vmf->pmd))) {
>  		/*
> @@ -3729,9 +3786,16 @@ static int handle_pte_fault(struct vm_fault *vmf)
>  	if (pte_protnone(vmf->orig_pte) && vma_is_accessible(vmf->vma))
>  		return do_numa_page(vmf);
>  
> +	/* Catch mapping of un-addressable memory this should never happen */
> +	entry = vmf->orig_pte;
> +	page = pfn_to_page(pte_pfn(entry));
> +	if (!is_addressable_page(page)) {
> +		print_bad_pte(vmf->vma, vmf->address, entry, page);
> +		return VM_FAULT_SIGBUS;
> +	}
> +

You're adding a new pfn_to_page on every PTE fault and this happens
unconditionally whether DEVICE_INACCESSIBLE is configured or not and it's
for a debugging check. It's also a seriously paranoid check because at
this point the PTE is present so something seriously bad happened in a
fault handler in the past.

Consider removing this entirely or making it a debug-only check. What
happens if such a PTE is accessed anyway and the CPU accesses it?
SIGBUS? If it's harmless (other than an application crash), remove it.
If it's actively dangerous then move this behind a static branch in a
separate patch that is activate iff there is cpu-inaccessible memory in
the system.

>  	vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
>  	spin_lock(vmf->ptl);
> -	entry = vmf->orig_pte;
>  	if (unlikely(!pte_same(*vmf->pte, entry)))
>  		goto unlock;
>  	if (vmf->flags & FAULT_FLAG_WRITE) {
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 46960b3..4dcc003 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -152,7 +152,7 @@ void mem_hotplug_done(void)
>  /* add this memory to iomem resource */
>  static struct resource *register_memory_resource(u64 start, u64 size)
>  {
> -	struct resource *res;
> +	struct resource *res, *conflict;
>  	res = kzalloc(sizeof(struct resource), GFP_KERNEL);
>  	if (!res)
>  		return ERR_PTR(-ENOMEM);
> @@ -161,7 +161,13 @@ static struct resource *register_memory_resource(u64 start, u64 size)
>  	res->start = start;
>  	res->end = start + size - 1;
>  	res->flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
> -	if (request_resource(&iomem_resource, res) < 0) {
> +	conflict =  request_resource_conflict(&iomem_resource, res);
> +	if (conflict) {
> +		if (conflict->desc == IORES_DESC_UNADDRESSABLE_MEMORY) {
> +			pr_debug("Device un-addressable memory block "
> +				 "memory hotplug at %#010llx !\n",
> +				 (unsigned long long)start);
> +		}
>  		pr_debug("System RAM resource %pR cannot be added\n", res);
>  		kfree(res);
>  		return ERR_PTR(-EEXIST);
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index 8edd0d5..50ac297 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -126,6 +126,18 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>  
>  				pages++;
>  			}
> +
> +			if (is_write_device_entry(entry)) {
> +				pte_t newpte;
> +
> +				make_device_entry_read(&entry);
> +				newpte = swp_entry_to_pte(entry);
> +				if (pte_swp_soft_dirty(oldpte))
> +					newpte = pte_swp_mksoft_dirty(newpte);
> +				set_pte_at(mm, addr, pte, newpte);
> +
> +				pages++;
> +			}
>  		}
>  	} while (pte++, addr += PAGE_SIZE, addr != end);
>  	arch_leave_lazy_mmu_mode();

Again, the soft dirty handling puzzles me.

Overall though, other than the pfn_to_page stuck into the page fault
path for a debugging check I don't have major objections.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
