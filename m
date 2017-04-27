Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id AD46E6B03A8
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 04:33:21 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b20so808256wma.11
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 01:33:21 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id l187si8959289wmf.64.2017.04.27.01.33.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 01:33:20 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id z129so2951041wmb.1
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 01:33:19 -0700 (PDT)
Date: Thu, 27 Apr 2017 11:33:17 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm, zone_device: replace {get, put}_zone_device_page()
 with a single reference
Message-ID: <20170427083317.vzfiw7up63draslc@node.shutemov.name>
References: <20170423233125.nehmgtzldgi25niy@node.shutemov.name>
 <149325431313.40660.7404075559824162131.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <149325431313.40660.7404075559824162131.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Ingo Molnar <mingo@redhat.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, linux-kernel@vger.kernel.org, Kirill Shutemov <kirill.shutemov@linux.intel.com>

On Wed, Apr 26, 2017 at 05:55:31PM -0700, Dan Williams wrote:
> Kirill points out that the calls to {get,put}_dev_pagemap() can be
> removed from the mm fast path if we take a single get_dev_pagemap()
> reference to signify that the page is alive and use the final put of the
> page to drop that reference.
> 
> This does require some care to make sure that any waits for the
> percpu_ref to drop to zero occur *after* devm_memremap_page_release(),
> since it now maintains its own elevated reference.
> 
> Cc Ingo Molnar <mingo@redhat.com>
> Cc: Jerome Glisse <jglisse@redhat.com>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Suggested-by: Kirill Shutemov <kirill.shutemov@linux.intel.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
> 
> This patch might fix the regression that we found with the conversion to
> generic get_user_pages_fast() in the x86/mm branch pending for 4.12
> (commit 2947ba054a4d "x86/mm/gup: Switch GUP to the generic
> get_user_page_fast() implementation"). I'll test tomorrow, but in case
> someone can give it a try before I wake up, here's an early version.

+ Ingo.

This works for me with and without GUP revert.

Tested-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

>  drivers/dax/pmem.c    |    2 +-
>  drivers/nvdimm/pmem.c |   13 +++++++++++--

There's a trivial conflict in drivers/nvdimm/pmem.c when applied to
tip/master.

>  include/linux/mm.h    |   14 --------------
>  kernel/memremap.c     |   22 +++++++++-------------
>  mm/swap.c             |   10 ++++++++++
>  5 files changed, 31 insertions(+), 30 deletions(-)
> 
> diff --git a/drivers/dax/pmem.c b/drivers/dax/pmem.c
> index d4ca19bd74eb..9f2a0b4fd801 100644
> --- a/drivers/dax/pmem.c
> +++ b/drivers/dax/pmem.c
> @@ -43,6 +43,7 @@ static void dax_pmem_percpu_exit(void *data)
>  	struct dax_pmem *dax_pmem = to_dax_pmem(ref);
>  
>  	dev_dbg(dax_pmem->dev, "%s\n", __func__);
> +	wait_for_completion(&dax_pmem->cmp);
>  	percpu_ref_exit(ref);
>  }
>  
> @@ -53,7 +54,6 @@ static void dax_pmem_percpu_kill(void *data)
>  
>  	dev_dbg(dax_pmem->dev, "%s\n", __func__);
>  	percpu_ref_kill(ref);
> -	wait_for_completion(&dax_pmem->cmp);
>  }
>  
>  static int dax_pmem_probe(struct device *dev)
> diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
> index 3b3dab73d741..6be0c1253fcd 100644
> --- a/drivers/nvdimm/pmem.c
> +++ b/drivers/nvdimm/pmem.c
> @@ -25,6 +25,7 @@
>  #include <linux/badblocks.h>
>  #include <linux/memremap.h>
>  #include <linux/vmalloc.h>
> +#include <linux/blk-mq.h>
>  #include <linux/pfn_t.h>
>  #include <linux/slab.h>
>  #include <linux/pmem.h>
> @@ -243,6 +244,11 @@ static void pmem_release_queue(void *q)
>  	blk_cleanup_queue(q);
>  }
>  
> +static void pmem_freeze_queue(void *q)
> +{
> +	blk_mq_freeze_queue_start(q);
> +}
> +
>  static void pmem_release_disk(void *__pmem)
>  {
>  	struct pmem_device *pmem = __pmem;
> @@ -301,6 +307,9 @@ static int pmem_attach_disk(struct device *dev,
>  	if (!q)
>  		return -ENOMEM;
>  
> +	if (devm_add_action_or_reset(dev, pmem_release_queue, q))
> +		return -ENOMEM;
> +
>  	pmem->pfn_flags = PFN_DEV;
>  	if (is_nd_pfn(dev)) {
>  		addr = devm_memremap_pages(dev, &pfn_res, &q->q_usage_counter,
> @@ -320,10 +329,10 @@ static int pmem_attach_disk(struct device *dev,
>  				pmem->size, ARCH_MEMREMAP_PMEM);
>  
>  	/*
> -	 * At release time the queue must be dead before
> +	 * At release time the queue must be frozen before
>  	 * devm_memremap_pages is unwound
>  	 */
> -	if (devm_add_action_or_reset(dev, pmem_release_queue, q))
> +	if (devm_add_action_or_reset(dev, pmem_freeze_queue, q))
>  		return -ENOMEM;
>  
>  	if (IS_ERR(addr))
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 00a8fa7e366a..ce17b35257ac 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -758,19 +758,11 @@ static inline enum zone_type page_zonenum(const struct page *page)
>  }
>  
>  #ifdef CONFIG_ZONE_DEVICE
> -void get_zone_device_page(struct page *page);
> -void put_zone_device_page(struct page *page);
>  static inline bool is_zone_device_page(const struct page *page)
>  {
>  	return page_zonenum(page) == ZONE_DEVICE;
>  }
>  #else
> -static inline void get_zone_device_page(struct page *page)
> -{
> -}
> -static inline void put_zone_device_page(struct page *page)
> -{
> -}
>  static inline bool is_zone_device_page(const struct page *page)
>  {
>  	return false;
> @@ -786,9 +778,6 @@ static inline void get_page(struct page *page)
>  	 */
>  	VM_BUG_ON_PAGE(page_ref_count(page) <= 0, page);
>  	page_ref_inc(page);
> -
> -	if (unlikely(is_zone_device_page(page)))
> -		get_zone_device_page(page);
>  }
>  
>  static inline void put_page(struct page *page)
> @@ -797,9 +786,6 @@ static inline void put_page(struct page *page)
>  
>  	if (put_page_testzero(page))
>  		__put_page(page);
> -
> -	if (unlikely(is_zone_device_page(page)))
> -		put_zone_device_page(page);
>  }
>  
>  #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index 07e85e5229da..5316efdde083 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -182,18 +182,6 @@ struct page_map {
>  	struct vmem_altmap altmap;
>  };
>  
> -void get_zone_device_page(struct page *page)
> -{
> -	percpu_ref_get(page->pgmap->ref);
> -}
> -EXPORT_SYMBOL(get_zone_device_page);
> -
> -void put_zone_device_page(struct page *page)
> -{
> -	put_dev_pagemap(page->pgmap);
> -}
> -EXPORT_SYMBOL(put_zone_device_page);
> -
>  static void pgmap_radix_release(struct resource *res)
>  {
>  	resource_size_t key, align_start, align_size, align_end;
> @@ -237,6 +225,10 @@ static void devm_memremap_pages_release(struct device *dev, void *data)
>  	struct resource *res = &page_map->res;
>  	resource_size_t align_start, align_size;
>  	struct dev_pagemap *pgmap = &page_map->pgmap;
> +	unsigned long pfn;
> +
> +	for_each_device_pfn(pfn, page_map)
> +		put_page(pfn_to_page(pfn));
>  
>  	if (percpu_ref_tryget_live(pgmap->ref)) {
>  		dev_WARN(dev, "%s: page mapping is still live!\n", __func__);
> @@ -277,7 +269,10 @@ struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
>   *
>   * Notes:
>   * 1/ @ref must be 'live' on entry and 'dead' before devm_memunmap_pages() time
> - *    (or devm release event).
> + *    (or devm release event). The expected order of events is that @ref has
> + *    been through percpu_ref_kill() before devm_memremap_pages_release(). The
> + *    wait for the completion of kill and percpu_ref_exit() must occur after
> + *    devm_memremap_pages_release().
>   *
>   * 2/ @res is expected to be a host memory range that could feasibly be
>   *    treated as a "System RAM" range, i.e. not a device mmio range, but
> @@ -379,6 +374,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
>  		 */
>  		list_del(&page->lru);
>  		page->pgmap = pgmap;
> +		percpu_ref_get(ref);
>  	}
>  	devres_add(dev, page_map);
>  	return __va(res->start);
> diff --git a/mm/swap.c b/mm/swap.c
> index 5dabf444d724..01267dda6668 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -97,6 +97,16 @@ static void __put_compound_page(struct page *page)
>  
>  void __put_page(struct page *page)
>  {
> +	if (is_zone_device_page(page)) {
> +		put_dev_pagemap(page->pgmap);
> +
> +		/*
> +		 * The page belong to device, do not return it to
> +		 * page allocator.
> +		 */
> +		return;
> +	}
> +
>  	if (unlikely(PageCompound(page)))
>  		__put_compound_page(page);
>  	else
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
