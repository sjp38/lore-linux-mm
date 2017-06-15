Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 110066B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 23:45:58 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id y77so4249139ioe.15
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 20:45:58 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id s103si2061023ioi.238.2017.06.14.20.45.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Jun 2017 20:45:56 -0700 (PDT)
Message-ID: <59420204.905@huawei.com>
Date: Thu, 15 Jun 2017 11:41:56 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [HMM 07/15] mm/ZONE_DEVICE: new type of ZONE_DEVICE for unaddressable
 memory v3
References: <20170524172024.30810-1-jglisse@redhat.com> <20170524172024.30810-8-jglisse@redhat.com>
In-Reply-To: <20170524172024.30810-8-jglisse@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, "Kirill A .
 Shutemov" <kirill.shutemov@linux.intel.com>, John Hubbard <jhubbard@nvidia.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On 2017/5/25 1:20, JA(C)rA'me Glisse wrote:
> HMM (heterogeneous memory management) need struct page to support migration
> from system main memory to device memory.  Reasons for HMM and migration to
> device memory is explained with HMM core patch.
>
> This patch deals with device memory that is un-addressable memory (ie CPU
> can not access it). Hence we do not want those struct page to be manage
> like regular memory. That is why we extend ZONE_DEVICE to support different
> types of memory.
>
> A persistent memory type is define for existing user of ZONE_DEVICE and a
> new device un-addressable type is added for the un-addressable memory type.
> There is a clear separation between what is expected from each memory type
> and existing user of ZONE_DEVICE are un-affected by new requirement and new
> use of the un-addressable type. All specific code path are protect with
> test against the memory type.
>
> Because memory is un-addressable we use a new special swap type for when
> a page is migrated to device memory (this reduces the number of maximum
> swap file).
>
> The main two additions beside memory type to ZONE_DEVICE is two callbacks.
> First one, page_free() is call whenever page refcount reach 1 (which means
> the page is free as ZONE_DEVICE page never reach a refcount of 0). This
> allow device driver to manage its memory and associated struct page.
>
> The second callback page_fault() happens when there is a CPU access to
> an address that is back by a device page (which are un-addressable by the
> CPU). This callback is responsible to migrate the page back to system
> main memory. Device driver can not block migration back to system memory,
> HMM make sure that such page can not be pin into device memory.
>
> If device is in some error condition and can not migrate memory back then
> a CPU page fault to device memory should end with SIGBUS.
>
> Changed since v2:
>   - s/DEVICE_UNADDRESSABLE/DEVICE_PRIVATE
> Changed since v1:
>   - rename to device private memory (from device unaddressable)
>
> Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
> Acked-by: Dan Williams <dan.j.williams@intel.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> ---
>  fs/proc/task_mmu.c       |  7 +++++
>  include/linux/ioport.h   |  1 +
>  include/linux/memremap.h | 72 ++++++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/mm.h       | 12 ++++++++
>  include/linux/swap.h     | 24 ++++++++++++++--
>  include/linux/swapops.h  | 68 +++++++++++++++++++++++++++++++++++++++++++++
>  kernel/memremap.c        | 34 +++++++++++++++++++++++
>  mm/Kconfig               | 13 +++++++++
>  mm/memory.c              | 61 ++++++++++++++++++++++++++++++++++++++++
>  mm/memory_hotplug.c      | 10 +++++--
>  mm/mprotect.c            | 14 ++++++++++
>  11 files changed, 311 insertions(+), 5 deletions(-)
>
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index f0c8b33..90b2fa4 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -542,6 +542,8 @@ static void smaps_pte_entry(pte_t *pte, unsigned long addr,
>  			}
>  		} else if (is_migration_entry(swpent))
>  			page = migration_entry_to_page(swpent);
> +		else if (is_device_private_entry(swpent))
> +			page = device_private_entry_to_page(swpent);
>  	} else if (unlikely(IS_ENABLED(CONFIG_SHMEM) && mss->check_shmem_swap
>  							&& pte_none(*pte))) {
>  		page = find_get_entry(vma->vm_file->f_mapping,
> @@ -704,6 +706,8 @@ static int smaps_hugetlb_range(pte_t *pte, unsigned long hmask,
>  
>  		if (is_migration_entry(swpent))
>  			page = migration_entry_to_page(swpent);
> +		else if (is_device_private_entry(swpent))
> +			page = device_private_entry_to_page(swpent);
>  	}
>  	if (page) {
>  		int mapcount = page_mapcount(page);
> @@ -1196,6 +1200,9 @@ static pagemap_entry_t pte_to_pagemap_entry(struct pagemapread *pm,
>  		flags |= PM_SWAP;
>  		if (is_migration_entry(entry))
>  			page = migration_entry_to_page(entry);
> +
> +		if (is_device_private_entry(entry))
> +			page = device_private_entry_to_page(entry);
>  	}
>  
>  	if (page && !PageAnon(page))
> diff --git a/include/linux/ioport.h b/include/linux/ioport.h
> index 6230064..3a4f691 100644
> --- a/include/linux/ioport.h
> +++ b/include/linux/ioport.h
> @@ -130,6 +130,7 @@ enum {
>  	IORES_DESC_ACPI_NV_STORAGE		= 3,
>  	IORES_DESC_PERSISTENT_MEMORY		= 4,
>  	IORES_DESC_PERSISTENT_MEMORY_LEGACY	= 5,
> +	IORES_DESC_DEVICE_PRIVATE_MEMORY	= 6,
>  };
>  
>  /* helpers to define resources */
> diff --git a/include/linux/memremap.h b/include/linux/memremap.h
> index 9341619..0fcf840 100644
> --- a/include/linux/memremap.h
> +++ b/include/linux/memremap.h
> @@ -4,6 +4,8 @@
>  #include <linux/ioport.h>
>  #include <linux/percpu-refcount.h>
>  
> +#include <asm/pgtable.h>
> +
>  struct resource;
>  struct device;
>  
> @@ -35,18 +37,88 @@ static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
>  }
>  #endif
>  
> +/*
> + * Specialize ZONE_DEVICE memory into multiple types each having differents
> + * usage.
> + *
> + * MEMORY_DEVICE_PUBLIC:
> + * Persistent device memory (pmem): struct page might be allocated in different
> + * memory and architecture might want to perform special actions. It is similar
> + * to regular memory, in that the CPU can access it transparently. However,
> + * it is likely to have different bandwidth and latency than regular memory.
> + * See Documentation/nvdimm/nvdimm.txt for more information.
> + *
> + * MEMORY_DEVICE_PRIVATE:
> + * Device memory that is not directly addressable by the CPU: CPU can neither
> + * read nor write _UNADDRESSABLE memory. In this case, we do still have struct
> + * pages backing the device memory. Doing so simplifies the implementation, but
> + * it is important to remember that there are certain points at which the struct
> + * page must be treated as an opaque object, rather than a "normal" struct page.
> + * A more complete discussion of unaddressable memory may be found in
> + * include/linux/hmm.h and Documentation/vm/hmm.txt.
> + */
> +enum memory_type {
> +	MEMORY_DEVICE_PUBLIC = 0,
> +	MEMORY_DEVICE_PRIVATE,
> +};
> +
> +/*
> + * For MEMORY_DEVICE_PRIVATE we use ZONE_DEVICE and extend it with two
> + * callbacks:
> + *   page_fault()
> + *   page_free()
> + *
> + * Additional notes about MEMORY_DEVICE_PRIVATE may be found in
> + * include/linux/hmm.h and Documentation/vm/hmm.txt. There is also a brief
> + * explanation in include/linux/memory_hotplug.h.
> + *
> + * The page_fault() callback must migrate page back, from device memory to
> + * system memory, so that the CPU can access it. This might fail for various
> + * reasons (device issues,  device have been unplugged, ...). When such error
> + * conditions happen, the page_fault() callback must return VM_FAULT_SIGBUS and
> + * set the CPU page table entry to "poisoned".
> + *
> + * Note that because memory cgroup charges are transferred to the device memory,
> + * this should never fail due to memory restrictions. However, allocation
> + * of a regular system page might still fail because we are out of memory. If
> + * that happens, the page_fault() callback must return VM_FAULT_OOM.
> + *
> + * The page_fault() callback can also try to migrate back multiple pages in one
> + * chunk, as an optimization. It must, however, prioritize the faulting address
> + * over all the others.
> + *
> + *
> + * The page_free() callback is called once the page refcount reaches 1
> + * (ZONE_DEVICE pages never reach 0 refcount unless there is a refcount bug.
> + * This allows the device driver to implement its own memory management.)
> + */
> +typedef int (*dev_page_fault_t)(struct vm_area_struct *vma,
> +				unsigned long addr,
> +				struct page *page,
> +				unsigned int flags,
> +				pmd_t *pmdp);
> +typedef void (*dev_page_free_t)(struct page *page, void *data);
> +
>  /**
>   * struct dev_pagemap - metadata for ZONE_DEVICE mappings
> + * @page_fault: callback when CPU fault on an unaddressable device page
> + * @page_free: free page callback when page refcount reaches 1
>   * @altmap: pre-allocated/reserved memory for vmemmap allocations
>   * @res: physical address range covered by @ref
>   * @ref: reference count that pins the devm_memremap_pages() mapping
>   * @dev: host device of the mapping for debug
> + * @data: private data pointer for page_free()
> + * @type: memory type: see MEMORY_* in memory_hotplug.h
>   */
>  struct dev_pagemap {
> +	dev_page_fault_t page_fault;
> +	dev_page_free_t page_free;
>  	struct vmem_altmap *altmap;
>  	const struct resource *res;
>  	struct percpu_ref *ref;
>  	struct device *dev;
> +	void *data;
> +	enum memory_type type;
>  };
>  
>  #ifdef CONFIG_ZONE_DEVICE
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 7cb17c6..a825dab 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -788,11 +788,23 @@ static inline bool is_zone_device_page(const struct page *page)
>  {
>  	return page_zonenum(page) == ZONE_DEVICE;
>  }
> +
> +static inline bool is_device_private_page(const struct page *page)
> +{
> +	/* See MEMORY_DEVICE_PRIVATE in include/linux/memory_hotplug.h */
> +	return ((page_zonenum(page) == ZONE_DEVICE) &&
> +		(page->pgmap->type == MEMORY_DEVICE_PRIVATE));
> +}
>  #else
>  static inline bool is_zone_device_page(const struct page *page)
>  {
>  	return false;
>  }
> +
> +static inline bool is_device_private_page(const struct page *page)
> +{
> +	return false;
> +}
>  #endif
>  
>  static inline void get_page(struct page *page)
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 5ab1c98..ab6c20b 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -51,6 +51,23 @@ static inline int current_is_kswapd(void)
>   */
>  
>  /*
> + * Unaddressable device memory support. See include/linux/hmm.h and
> + * Documentation/vm/hmm.txt. Short description is we need struct pages for
> + * device memory that is unaddressable (inaccessible) by CPU, so that we can
> + * migrate part of a process memory to device memory.
> + *
> + * When a page is migrated from CPU to device, we set the CPU page table entry
> + * to a special SWP_DEVICE_* entry.
> + */
> +#ifdef CONFIG_DEVICE_PRIVATE
> +#define SWP_DEVICE_NUM 2
> +#define SWP_DEVICE_WRITE (MAX_SWAPFILES+SWP_HWPOISON_NUM+SWP_MIGRATION_NUM)
> +#define SWP_DEVICE_READ (MAX_SWAPFILES+SWP_HWPOISON_NUM+SWP_MIGRATION_NUM+1)
> +#else
> +#define SWP_DEVICE_NUM 0
> +#endif
> +
> +/*
>   * NUMA node memory migration support
>   */
>  #ifdef CONFIG_MIGRATION
> @@ -72,7 +89,8 @@ static inline int current_is_kswapd(void)
>  #endif
>  
>  #define MAX_SWAPFILES \
> -	((1 << MAX_SWAPFILES_SHIFT) - SWP_MIGRATION_NUM - SWP_HWPOISON_NUM)
> +	((1 << MAX_SWAPFILES_SHIFT) - SWP_DEVICE_NUM - \
> +	SWP_MIGRATION_NUM - SWP_HWPOISON_NUM)
>  
>  /*
>   * Magic header for a swap area. The first part of the union is
> @@ -432,8 +450,8 @@ static inline void show_swap_cache_info(void)
>  {
>  }
>  
> -#define free_swap_and_cache(swp)	is_migration_entry(swp)
> -#define swapcache_prepare(swp)		is_migration_entry(swp)
> +#define free_swap_and_cache(e) (is_migration_entry(e) || is_device_private_entry(e))
> +#define swapcache_prepare(e) (is_migration_entry(e) || is_device_private_entry(e))
>  
>  static inline int add_swap_count_continuation(swp_entry_t swp, gfp_t gfp_mask)
>  {
> diff --git a/include/linux/swapops.h b/include/linux/swapops.h
> index 5c3a5f3..361090c 100644
> --- a/include/linux/swapops.h
> +++ b/include/linux/swapops.h
> @@ -100,6 +100,74 @@ static inline void *swp_to_radix_entry(swp_entry_t entry)
>  	return (void *)(value | RADIX_TREE_EXCEPTIONAL_ENTRY);
>  }
>  
> +#if IS_ENABLED(CONFIG_DEVICE_PRIVATE)
> +static inline swp_entry_t make_device_private_entry(struct page *page, bool write)
> +{
> +	return swp_entry(write ? SWP_DEVICE_WRITE : SWP_DEVICE_READ,
> +			 page_to_pfn(page));
> +}
> +
> +static inline bool is_device_private_entry(swp_entry_t entry)
> +{
> +	int type = swp_type(entry);
> +	return type == SWP_DEVICE_READ || type == SWP_DEVICE_WRITE;
> +}
> +
> +static inline void make_device_private_entry_read(swp_entry_t *entry)
> +{
> +	*entry = swp_entry(SWP_DEVICE_READ, swp_offset(*entry));
> +}
> +
> +static inline bool is_write_device_private_entry(swp_entry_t entry)
> +{
> +	return unlikely(swp_type(entry) == SWP_DEVICE_WRITE);
> +}
> +
> +static inline struct page *device_private_entry_to_page(swp_entry_t entry)
> +{
> +	return pfn_to_page(swp_offset(entry));
> +}
> +
> +int device_private_entry_fault(struct vm_area_struct *vma,
> +		       unsigned long addr,
> +		       swp_entry_t entry,
> +		       unsigned int flags,
> +		       pmd_t *pmdp);
> +#else /* CONFIG_DEVICE_PRIVATE */
> +static inline swp_entry_t make_device_private_entry(struct page *page, bool write)
> +{
> +	return swp_entry(0, 0);
> +}
> +
> +static inline void make_device_private_entry_read(swp_entry_t *entry)
> +{
> +}
> +
> +static inline bool is_device_private_entry(swp_entry_t entry)
> +{
> +	return false;
> +}
> +
> +static inline bool is_write_device_private_entry(swp_entry_t entry)
> +{
> +	return false;
> +}
> +
> +static inline struct page *device_private_entry_to_page(swp_entry_t entry)
> +{
> +	return NULL;
> +}
> +
> +static inline int device_private_entry_fault(struct vm_area_struct *vma,
> +				     unsigned long addr,
> +				     swp_entry_t entry,
> +				     unsigned int flags,
> +				     pmd_t *pmdp)
> +{
> +	return VM_FAULT_SIGBUS;
> +}
> +#endif /* CONFIG_DEVICE_PRIVATE */
> +
>  #ifdef CONFIG_MIGRATION
>  static inline swp_entry_t make_migration_entry(struct page *page, int write)
>  {
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index 124bed7..cd596d4 100644
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
> @@ -182,6 +184,34 @@ struct page_map {
>  	struct vmem_altmap altmap;
>  };
>  
> +#if IS_ENABLED(CONFIG_DEVICE_PRIVATE)
> +int device_private_entry_fault(struct vm_area_struct *vma,
> +		       unsigned long addr,
> +		       swp_entry_t entry,
> +		       unsigned int flags,
> +		       pmd_t *pmdp)
> +{
> +	struct page *page = device_private_entry_to_page(entry);
> +
> +	/*
> +	 * The page_fault() callback must migrate page back to system memory
> +	 * so that CPU can access it. This might fail for various reasons
> +	 * (device issue, device was unsafely unplugged, ...). When such
> +	 * error conditions happen, the callback must return VM_FAULT_SIGBUS.
> +	 *
> +	 * Note that because memory cgroup charges are accounted to the device
> +	 * memory, this should never fail because of memory restrictions (but
> +	 * allocation of regular system page might still fail because we are
> +	 * out of memory).
> +	 *
> +	 * There is a more in-depth description of what that callback can and
> +	 * cannot do, in include/linux/memremap.h
> +	 */
> +	return page->pgmap->page_fault(vma, addr, page, flags, pmdp);
> +}
> +EXPORT_SYMBOL(device_private_entry_fault);
> +#endif /* CONFIG_DEVICE_PRIVATE */
> +
>  static void pgmap_radix_release(struct resource *res)
>  {
>  	resource_size_t key, align_start, align_size, align_end;
> @@ -321,6 +351,10 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
>  	}
>  	pgmap->ref = ref;
>  	pgmap->res = &page_map->res;
> +	pgmap->type = MEMORY_DEVICE_PUBLIC;
> +	pgmap->page_fault = NULL;
> +	pgmap->page_free = NULL;
> +	pgmap->data = NULL;
>  
>  	mutex_lock(&pgmap_lock);
>  	error = 0;
> diff --git a/mm/Kconfig b/mm/Kconfig
> index d744cff..f5357ff 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -736,6 +736,19 @@ config ZONE_DEVICE
>  
>  	  If FS_DAX is enabled, then say Y.
>  
> +config DEVICE_PRIVATE
> +	bool "Unaddressable device memory (GPU memory, ...)"
> +	depends on X86_64
> +	depends on ZONE_DEVICE
> +	depends on MEMORY_HOTPLUG
> +	depends on MEMORY_HOTREMOVE
> +	depends on SPARSEMEM_VMEMMAP
> +
 maybe just depends on ARCH_HAS_HMM is enough.
> +	help
> +	  Allows creation of struct pages to represent unaddressable device
> +	  memory; i.e., memory that is only accessible from the device (or
> +	  group of devices).
> +
>  config FRAME_VECTOR
>  	bool
>  
> diff --git a/mm/memory.c b/mm/memory.c
> index d320b4e..eba61dd 100644
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
> @@ -927,6 +928,35 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>  					pte = pte_swp_mksoft_dirty(pte);
>  				set_pte_at(src_mm, addr, src_pte, pte);
>  			}
> +		} else if (is_device_private_entry(entry)) {
> +			page = device_private_entry_to_page(entry);
> +
> +			/*
> +			 * Update rss count even for unaddressable pages, as
> +			 * they should treated just like normal pages in this
> +			 * respect.
> +			 *
> +			 * We will likely want to have some new rss counters
> +			 * for unaddressable pages, at some point. But for now
> +			 * keep things as they are.
> +			 */
> +			get_page(page);
> +			rss[mm_counter(page)]++;
> +			page_dup_rmap(page, false);
> +
> +			/*
> +			 * We do not preserve soft-dirty information, because so
> +			 * far, checkpoint/restore is the only feature that
> +			 * requires that. And checkpoint/restore does not work
> +			 * when a device driver is involved (you cannot easily
> +			 * save and restore device driver state).
> +			 */
> +			if (is_write_device_private_entry(entry) &&
> +			    is_cow_mapping(vm_flags)) {
> +				make_device_private_entry_read(&entry);
> +				pte = swp_entry_to_pte(entry);
> +				set_pte_at(src_mm, addr, src_pte, pte);
> +			}
>  		}
>  		goto out_set_pte;
>  	}
> @@ -1243,6 +1273,29 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
>  			}
>  			continue;
>  		}
> +
> +		entry = pte_to_swp_entry(ptent);
> +		if (non_swap_entry(entry) && is_device_private_entry(entry)) {
> +			struct page *page = device_private_entry_to_page(entry);
> +
> +			if (unlikely(details && details->check_mapping)) {
> +				/*
> +				 * unmap_shared_mapping_pages() wants to
> +				 * invalidate cache without truncating:
> +				 * unmap shared but keep private pages.
> +				 */
> +				if (details->check_mapping !=
> +				    page_rmapping(page))
> +					continue;
> +			}
> +
> +			pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
> +			rss[mm_counter(page)]--;
> +			page_remove_rmap(page, false);
> +			put_page(page);
> +			continue;
> +		}
> +
>  		/* If details->check_mapping, we leave swap entries. */
>  		if (unlikely(details))
>  			continue;
> @@ -2690,6 +2743,14 @@ int do_swap_page(struct vm_fault *vmf)
>  		if (is_migration_entry(entry)) {
>  			migration_entry_wait(vma->vm_mm, vmf->pmd,
>  					     vmf->address);
> +		} else if (is_device_private_entry(entry)) {
> +			/*
> +			 * For un-addressable device memory we call the pgmap
> +			 * fault handler callback. The callback must migrate
> +			 * the page back to some CPU accessible page.
> +			 */
> +			ret = device_private_entry_fault(vma, vmf->address, entry,
> +						 vmf->flags, vmf->pmd);
>  		} else if (is_hwpoison_entry(entry)) {
>  			ret = VM_FAULT_HWPOISON;
>  		} else {
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 599c675..0a9f690 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -156,7 +156,7 @@ void mem_hotplug_done(void)
>  /* add this memory to iomem resource */
>  static struct resource *register_memory_resource(u64 start, u64 size)
>  {
> -	struct resource *res;
> +	struct resource *res, *conflict;
>  	res = kzalloc(sizeof(struct resource), GFP_KERNEL);
>  	if (!res)
>  		return ERR_PTR(-ENOMEM);
> @@ -165,7 +165,13 @@ static struct resource *register_memory_resource(u64 start, u64 size)
>  	res->start = start;
>  	res->end = start + size - 1;
>  	res->flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
> -	if (request_resource(&iomem_resource, res) < 0) {
> +	conflict =  request_resource_conflict(&iomem_resource, res);
> +	if (conflict) {
> +		if (conflict->desc == IORES_DESC_DEVICE_PRIVATE_MEMORY) {
> +			pr_debug("Device unaddressable memory block "
> +				 "memory hotplug at %#010llx !\n",
> +				 (unsigned long long)start);
> +		}
>  		pr_debug("System RAM resource %pR cannot be added\n", res);
>  		kfree(res);
>  		return ERR_PTR(-EEXIST);
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index 1a8c9ca..868d0ed 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -124,6 +124,20 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>  
>  				pages++;
>  			}
> +
> +			if (is_write_device_private_entry(entry)) {
> +				pte_t newpte;
> +
> +				/*
> +				 * We do not preserve soft-dirtiness. See
> +				 * copy_one_pte() for explanation.
> +				 */
> +				make_device_private_entry_read(&entry);
> +				newpte = swp_entry_to_pte(entry);
> +				set_pte_at(mm, addr, pte, newpte);
> +
> +				pages++;
> +			}
>  		}
>  	} while (pte++, addr += PAGE_SIZE, addr != end);
>  	arch_leave_lazy_mmu_mode();


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
