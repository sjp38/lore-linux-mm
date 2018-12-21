Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 88B748E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 20:45:35 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id q33so3940121qte.23
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 17:45:35 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j62si225356qkj.139.2018.12.20.17.45.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Dec 2018 17:45:34 -0800 (PST)
Date: Thu, 20 Dec 2018 20:45:30 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH] mm/hmm: Fix memremap.h, move dev_page_fault_t callback
 to hmm
Message-ID: <20181221014530.GA6425@redhat.com>
References: <154534090899.3120190.6652620807617715272.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <154534090899.3120190.6652620807617715272.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 20, 2018 at 01:24:13PM -0800, Dan Williams wrote:
> The kbuild robot reported the following on a development branch that
> used memremap.h in a new path:
> 
>    In file included from arch/m68k/include/asm/pgtable_mm.h:148:0,
>                      from arch/m68k/include/asm/pgtable.h:5,
>                      from include/linux/memremap.h:7,
>                      from drivers//dax/bus.c:3:
>     arch/m68k/include/asm/motorola_pgtable.h: In function 'pgd_offset':
>  >> arch/m68k/include/asm/motorola_pgtable.h:199:11: error: dereferencing pointer to incomplete type 'const struct mm_struct'
>       return mm->pgd + pgd_index(address);
>                ^~
> 
> The ->page_fault() callback is specific to HMM. Move it to 'struct
> hmm_devmem' where the unusual asm/pgtable.h dependency can be contained
> in include/linux/hmm.h.  Longer term refactoring this dependency out of
> HMM is recommended, but in the meantime memremap.h remains generic.
> 
> Fixes: 5042db43cc26 "mm/ZONE_DEVICE: new type of ZONE_DEVICE memory..."

Reviewed-by: "J�r�me Glisse" <jglisse@redhat.com>


> Cc: Logan Gunthorpe <logang@deltatee.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
> Hi Andrew, a fairly straightfoward fix, hopefully J�r�me has time to ack
> it before the holidays.
> 
> It has been exposed to 0day for a few hours with no reported compile
> breakage.
> 
>  include/linux/hmm.h      |   24 ++++++++++++++++++++++++
>  include/linux/memremap.h |   32 --------------------------------
>  kernel/memremap.c        |    6 +++++-
>  mm/hmm.c                 |    4 ++--
>  4 files changed, 31 insertions(+), 35 deletions(-)
> 
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index ed89fbc525d2..66f9ebbb1df3 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -69,6 +69,7 @@
>  #define LINUX_HMM_H
>  
>  #include <linux/kconfig.h>
> +#include <asm/pgtable.h>
>  
>  #if IS_ENABLED(CONFIG_HMM)
>  
> @@ -486,6 +487,7 @@ struct hmm_devmem_ops {
>   * @device: device to bind resource to
>   * @ops: memory operations callback
>   * @ref: per CPU refcount
> + * @page_fault: callback when CPU fault on an unaddressable device page
>   *
>   * This an helper structure for device drivers that do not wish to implement
>   * the gory details related to hotplugging new memoy and allocating struct
> @@ -493,7 +495,28 @@ struct hmm_devmem_ops {
>   *
>   * Device drivers can directly use ZONE_DEVICE memory on their own if they
>   * wish to do so.
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
>   */
> +typedef int (*dev_page_fault_t)(struct vm_area_struct *vma,
> +				unsigned long addr,
> +				const struct page *page,
> +				unsigned int flags,
> +				pmd_t *pmdp);
> +
>  struct hmm_devmem {
>  	struct completion		completion;
>  	unsigned long			pfn_first;
> @@ -503,6 +526,7 @@ struct hmm_devmem {
>  	struct dev_pagemap		pagemap;
>  	const struct hmm_devmem_ops	*ops;
>  	struct percpu_ref		ref;
> +	dev_page_fault_t		page_fault;
>  };
>  
>  /*
> diff --git a/include/linux/memremap.h b/include/linux/memremap.h
> index 55db66b3716f..f0628660d541 100644
> --- a/include/linux/memremap.h
> +++ b/include/linux/memremap.h
> @@ -4,8 +4,6 @@
>  #include <linux/ioport.h>
>  #include <linux/percpu-refcount.h>
>  
> -#include <asm/pgtable.h>
> -
>  struct resource;
>  struct device;
>  
> @@ -66,47 +64,18 @@ enum memory_type {
>  };
>  
>  /*
> - * For MEMORY_DEVICE_PRIVATE we use ZONE_DEVICE and extend it with two
> - * callbacks:
> - *   page_fault()
> - *   page_free()
> - *
>   * Additional notes about MEMORY_DEVICE_PRIVATE may be found in
>   * include/linux/hmm.h and Documentation/vm/hmm.rst. There is also a brief
>   * explanation in include/linux/memory_hotplug.h.
>   *
> - * The page_fault() callback must migrate page back, from device memory to
> - * system memory, so that the CPU can access it. This might fail for various
> - * reasons (device issues,  device have been unplugged, ...). When such error
> - * conditions happen, the page_fault() callback must return VM_FAULT_SIGBUS and
> - * set the CPU page table entry to "poisoned".
> - *
> - * Note that because memory cgroup charges are transferred to the device memory,
> - * this should never fail due to memory restrictions. However, allocation
> - * of a regular system page might still fail because we are out of memory. If
> - * that happens, the page_fault() callback must return VM_FAULT_OOM.
> - *
> - * The page_fault() callback can also try to migrate back multiple pages in one
> - * chunk, as an optimization. It must, however, prioritize the faulting address
> - * over all the others.
> - *
> - *
>   * The page_free() callback is called once the page refcount reaches 1
>   * (ZONE_DEVICE pages never reach 0 refcount unless there is a refcount bug.
>   * This allows the device driver to implement its own memory management.)
> - *
> - * For MEMORY_DEVICE_PUBLIC only the page_free() callback matter.
>   */
> -typedef int (*dev_page_fault_t)(struct vm_area_struct *vma,
> -				unsigned long addr,
> -				const struct page *page,
> -				unsigned int flags,
> -				pmd_t *pmdp);
>  typedef void (*dev_page_free_t)(struct page *page, void *data);
>  
>  /**
>   * struct dev_pagemap - metadata for ZONE_DEVICE mappings
> - * @page_fault: callback when CPU fault on an unaddressable device page
>   * @page_free: free page callback when page refcount reaches 1
>   * @altmap: pre-allocated/reserved memory for vmemmap allocations
>   * @res: physical address range covered by @ref
> @@ -117,7 +86,6 @@ typedef void (*dev_page_free_t)(struct page *page, void *data);
>   * @type: memory type: see MEMORY_* in memory_hotplug.h
>   */
>  struct dev_pagemap {
> -	dev_page_fault_t page_fault;
>  	dev_page_free_t page_free;
>  	struct vmem_altmap altmap;
>  	bool altmap_valid;
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index 66cbf334203b..f458b44303c9 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -11,6 +11,7 @@
>  #include <linux/types.h>
>  #include <linux/wait_bit.h>
>  #include <linux/xarray.h>
> +#include <linux/hmm.h>
>  
>  static DEFINE_XARRAY(pgmap_array);
>  #define SECTION_MASK ~((1UL << PA_SECTION_SHIFT) - 1)
> @@ -24,6 +25,9 @@ vm_fault_t device_private_entry_fault(struct vm_area_struct *vma,
>  		       pmd_t *pmdp)
>  {
>  	struct page *page = device_private_entry_to_page(entry);
> +	struct hmm_devmem *devmem;
> +
> +	devmem = container_of(page->pgmap, typeof(*devmem), pagemap);
>  
>  	/*
>  	 * The page_fault() callback must migrate page back to system memory
> @@ -39,7 +43,7 @@ vm_fault_t device_private_entry_fault(struct vm_area_struct *vma,
>  	 * There is a more in-depth description of what that callback can and
>  	 * cannot do, in include/linux/memremap.h
>  	 */
> -	return page->pgmap->page_fault(vma, addr, page, flags, pmdp);
> +	return devmem->page_fault(vma, addr, page, flags, pmdp);
>  }
>  EXPORT_SYMBOL(device_private_entry_fault);
>  #endif /* CONFIG_DEVICE_PRIVATE */
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 789587731217..a04e4b810610 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -1087,10 +1087,10 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
>  	devmem->pfn_first = devmem->resource->start >> PAGE_SHIFT;
>  	devmem->pfn_last = devmem->pfn_first +
>  			   (resource_size(devmem->resource) >> PAGE_SHIFT);
> +	devmem->page_fault = hmm_devmem_fault;
>  
>  	devmem->pagemap.type = MEMORY_DEVICE_PRIVATE;
>  	devmem->pagemap.res = *devmem->resource;
> -	devmem->pagemap.page_fault = hmm_devmem_fault;
>  	devmem->pagemap.page_free = hmm_devmem_free;
>  	devmem->pagemap.altmap_valid = false;
>  	devmem->pagemap.ref = &devmem->ref;
> @@ -1141,10 +1141,10 @@ struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
>  	devmem->pfn_first = devmem->resource->start >> PAGE_SHIFT;
>  	devmem->pfn_last = devmem->pfn_first +
>  			   (resource_size(devmem->resource) >> PAGE_SHIFT);
> +	devmem->page_fault = hmm_devmem_fault;
>  
>  	devmem->pagemap.type = MEMORY_DEVICE_PUBLIC;
>  	devmem->pagemap.res = *devmem->resource;
> -	devmem->pagemap.page_fault = hmm_devmem_fault;
>  	devmem->pagemap.page_free = hmm_devmem_free;
>  	devmem->pagemap.altmap_valid = false;
>  	devmem->pagemap.ref = &devmem->ref;
> 
