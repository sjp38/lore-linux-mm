Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5D2AB280260
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 03:07:13 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id p66so380212207pga.4
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 00:07:13 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id v28si21503787pgo.267.2016.11.21.00.07.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Nov 2016 00:07:11 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAL84ggA053050
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 03:07:10 -0500
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26uty5n2p5-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 03:07:10 -0500
Received: from localhost
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 21 Nov 2016 18:07:07 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 413513578052
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 19:07:05 +1100 (EST)
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAL874gF21299276
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 19:07:04 +1100
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAL874uX018911
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 19:07:05 +1100
Subject: Re: [HMM v13 02/18] mm/ZONE_DEVICE/unaddressable: add support for
 un-addressable device memory
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-3-git-send-email-jglisse@redhat.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Mon, 21 Nov 2016 13:36:57 +0530
MIME-Version: 1.0
In-Reply-To: <1479493107-982-3-git-send-email-jglisse@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Message-Id: <5832AB21.1010606@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On 11/18/2016 11:48 PM, JA(C)rA'me Glisse wrote:
> This add support for un-addressable device memory. Such memory is hotpluged
> only so we can have struct page but should never be map. This patch add code

struct pages inside the system RAM range unlike the vmem_altmap scheme
where the struct pages can be inside the device memory itself. This
possibility does not arise for un addressable device memory. May be we
will have to block the paths where vmem_altmap is requested along with
un addressable device memory.

> to mm page fault code path to catch any such mapping and SIGBUS on such event.
> 
> Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> ---
>  drivers/dax/pmem.c                |  3 ++-
>  drivers/nvdimm/pmem.c             |  5 +++--
>  include/linux/memremap.h          | 23 ++++++++++++++++++++---
>  kernel/memremap.c                 | 12 +++++++++---
>  mm/memory.c                       |  9 +++++++++
>  tools/testing/nvdimm/test/iomap.c |  2 +-
>  6 files changed, 44 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/dax/pmem.c b/drivers/dax/pmem.c
> index 1f01e98..1b42aef 100644
> --- a/drivers/dax/pmem.c
> +++ b/drivers/dax/pmem.c
> @@ -107,7 +107,8 @@ static int dax_pmem_probe(struct device *dev)
>  	if (rc)
>  		return rc;
>  
> -	addr = devm_memremap_pages(dev, &res, &dax_pmem->ref, altmap);
> +	addr = devm_memremap_pages(dev, &res, &dax_pmem->ref,
> +				   altmap, NULL, MEMORY_DEVICE);
>  	if (IS_ERR(addr))
>  		return PTR_ERR(addr);
>  
> diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
> index 571a6c7..5ffd937 100644
> --- a/drivers/nvdimm/pmem.c
> +++ b/drivers/nvdimm/pmem.c
> @@ -260,7 +260,7 @@ static int pmem_attach_disk(struct device *dev,
>  	pmem->pfn_flags = PFN_DEV;
>  	if (is_nd_pfn(dev)) {
>  		addr = devm_memremap_pages(dev, &pfn_res, &q->q_usage_counter,
> -				altmap);
> +					   altmap, NULL, MEMORY_DEVICE);
>  		pfn_sb = nd_pfn->pfn_sb;
>  		pmem->data_offset = le64_to_cpu(pfn_sb->dataoff);
>  		pmem->pfn_pad = resource_size(res) - resource_size(&pfn_res);
> @@ -269,7 +269,8 @@ static int pmem_attach_disk(struct device *dev,
>  		res->start += pmem->data_offset;
>  	} else if (pmem_should_map_pages(dev)) {
>  		addr = devm_memremap_pages(dev, &nsio->res,
> -				&q->q_usage_counter, NULL);
> +					   &q->q_usage_counter,
> +					   NULL, NULL, MEMORY_DEVICE);
>  		pmem->pfn_flags |= PFN_MAP;
>  	} else
>  		addr = devm_memremap(dev, pmem->phys_addr,
> diff --git a/include/linux/memremap.h b/include/linux/memremap.h
> index 9341619..fe61dca 100644
> --- a/include/linux/memremap.h
> +++ b/include/linux/memremap.h
> @@ -41,22 +41,34 @@ static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
>   * @res: physical address range covered by @ref
>   * @ref: reference count that pins the devm_memremap_pages() mapping
>   * @dev: host device of the mapping for debug
> + * @flags: memory flags (look for MEMORY_FLAGS_NONE in memory_hotplug.h)

^^^^^^^^^^^^^ device memory flags instead ?

>   */
>  struct dev_pagemap {
>  	struct vmem_altmap *altmap;
>  	const struct resource *res;
>  	struct percpu_ref *ref;
>  	struct device *dev;
> +	int flags;
>  };
>  
>  #ifdef CONFIG_ZONE_DEVICE
>  void *devm_memremap_pages(struct device *dev, struct resource *res,
> -		struct percpu_ref *ref, struct vmem_altmap *altmap);
> +			  struct percpu_ref *ref, struct vmem_altmap *altmap,
> +			  struct dev_pagemap **ppgmap, int flags);
>  struct dev_pagemap *find_dev_pagemap(resource_size_t phys);
> +
> +static inline bool is_addressable_page(const struct page *page)
> +{
> +	return ((page_zonenum(page) != ZONE_DEVICE) ||
> +		!(page->pgmap->flags & MEMORY_UNADDRESSABLE));
> +}
>  #else
>  static inline void *devm_memremap_pages(struct device *dev,
> -		struct resource *res, struct percpu_ref *ref,
> -		struct vmem_altmap *altmap)
> +					struct resource *res,
> +					struct percpu_ref *ref,
> +					struct vmem_altmap *altmap,
> +					struct dev_pagemap **ppgmap,
> +					int flags)


As I had mentioned before devm_memremap_pages() should be changed not
to accept a valid altmap along with request for un-addressable memory.

>  {
>  	/*
>  	 * Fail attempts to call devm_memremap_pages() without
> @@ -71,6 +83,11 @@ static inline struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
>  {
>  	return NULL;
>  }
> +
> +static inline bool is_addressable_page(const struct page *page)
> +{
> +	return true;
> +}
>  #endif
>  
>  /**
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index 07665eb..438a73aa2 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -246,7 +246,7 @@ static void devm_memremap_pages_release(struct device *dev, void *data)
>  	/* pages are dead and unused, undo the arch mapping */
>  	align_start = res->start & ~(SECTION_SIZE - 1);
>  	align_size = ALIGN(resource_size(res), SECTION_SIZE);
> -	arch_remove_memory(align_start, align_size, MEMORY_DEVICE);
> +	arch_remove_memory(align_start, align_size, pgmap->flags);
>  	untrack_pfn(NULL, PHYS_PFN(align_start), align_size);
>  	pgmap_radix_release(res);
>  	dev_WARN_ONCE(dev, pgmap->altmap && pgmap->altmap->alloc,
> @@ -270,6 +270,8 @@ struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
>   * @res: "host memory" address range
>   * @ref: a live per-cpu reference count
>   * @altmap: optional descriptor for allocating the memmap from @res
> + * @ppgmap: pointer set to new page dev_pagemap on success
> + * @flags: flag for memory (look for MEMORY_FLAGS_NONE in memory_hotplug.h)
>   *
>   * Notes:
>   * 1/ @ref must be 'live' on entry and 'dead' before devm_memunmap_pages() time
> @@ -280,7 +282,8 @@ struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
>   *    this is not enforced.
>   */
>  void *devm_memremap_pages(struct device *dev, struct resource *res,
> -		struct percpu_ref *ref, struct vmem_altmap *altmap)
> +			  struct percpu_ref *ref, struct vmem_altmap *altmap,
> +			  struct dev_pagemap **ppgmap, int flags)
>  {
>  	resource_size_t key, align_start, align_size, align_end;
>  	pgprot_t pgprot = PAGE_KERNEL;
> @@ -322,6 +325,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
>  	}
>  	pgmap->ref = ref;
>  	pgmap->res = &page_map->res;
> +	pgmap->flags = flags | MEMORY_DEVICE;

So the caller of devm_memremap_pages() should not have give out MEMORY_DEVICE
in the flag it passed on to this function ? Hmm, else we should just check
that the flags contains all appropriate bits before proceeding.

>  
>  	mutex_lock(&pgmap_lock);
>  	error = 0;
> @@ -358,7 +362,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
>  	if (error)
>  		goto err_pfn_remap;
>  
> -	error = arch_add_memory(nid, align_start, align_size, MEMORY_DEVICE);
> +	error = arch_add_memory(nid, align_start, align_size, pgmap->flags);
>  	if (error)
>  		goto err_add_memory;
>  
> @@ -375,6 +379,8 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
>  		page->pgmap = pgmap;
>  	}
>  	devres_add(dev, page_map);
> +	if (ppgmap)
> +		*ppgmap = pgmap;
>  	return __va(res->start);
>  
>   err_add_memory:
> diff --git a/mm/memory.c b/mm/memory.c
> index 840adc6..15f2908 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -45,6 +45,7 @@
>  #include <linux/swap.h>
>  #include <linux/highmem.h>
>  #include <linux/pagemap.h>
> +#include <linux/memremap.h>
>  #include <linux/ksm.h>
>  #include <linux/rmap.h>
>  #include <linux/export.h>
> @@ -3482,6 +3483,7 @@ static inline bool vma_is_accessible(struct vm_area_struct *vma)
>  static int handle_pte_fault(struct fault_env *fe)
>  {
>  	pte_t entry;
> +	struct page *page;
>  
>  	if (unlikely(pmd_none(*fe->pmd))) {
>  		/*
> @@ -3533,6 +3535,13 @@ static int handle_pte_fault(struct fault_env *fe)
>  	if (pte_protnone(entry) && vma_is_accessible(fe->vma))
>  		return do_numa_page(fe, entry);
>  
> +	/* Catch mapping of un-addressable memory this should never happen */
> +	page = pfn_to_page(pte_pfn(entry));
> +	if (!is_addressable_page(page)) {
> +		print_bad_pte(fe->vma, fe->address, entry, page);
> +		return VM_FAULT_SIGBUS;
> +	}

Right, core VM should never put an un-addressable page in the page table.

> +
>  	fe->ptl = pte_lockptr(fe->vma->vm_mm, fe->pmd);
>  	spin_lock(fe->ptl);
>  	if (unlikely(!pte_same(*fe->pte, entry)))
> diff --git a/tools/testing/nvdimm/test/iomap.c b/tools/testing/nvdimm/test/iomap.c
> index c29f8dc..899d6a8 100644
> --- a/tools/testing/nvdimm/test/iomap.c
> +++ b/tools/testing/nvdimm/test/iomap.c
> @@ -108,7 +108,7 @@ void *__wrap_devm_memremap_pages(struct device *dev, struct resource *res,
>  
>  	if (nfit_res)
>  		return nfit_res->buf + offset - nfit_res->res->start;
> -	return devm_memremap_pages(dev, res, ref, altmap);
> +	return devm_memremap_pages(dev, res, ref, altmap, MEMORY_DEVICE);
>  }
>  EXPORT_SYMBOL(__wrap_devm_memremap_pages);
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
