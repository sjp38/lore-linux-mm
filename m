Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f47.google.com (mail-lf0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 8220A82FD8
	for <linux-mm@kvack.org>; Sun, 27 Dec 2015 03:46:57 -0500 (EST)
Received: by mail-lf0-f47.google.com with SMTP id p203so188418933lfa.0
        for <linux-mm@kvack.org>; Sun, 27 Dec 2015 00:46:57 -0800 (PST)
Received: from mail-lb0-x233.google.com (mail-lb0-x233.google.com. [2a00:1450:4010:c04::233])
        by mx.google.com with ESMTPS id k64si11023657lfg.244.2015.12.27.00.46.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Dec 2015 00:46:56 -0800 (PST)
Received: by mail-lb0-x233.google.com with SMTP id sv6so74022553lbb.0
        for <linux-mm@kvack.org>; Sun, 27 Dec 2015 00:46:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151221054521.34542.62283.stgit@dwillia2-desk3.jf.intel.com>
References: <20151221054406.34542.64393.stgit@dwillia2-desk3.jf.intel.com>
	<20151221054521.34542.62283.stgit@dwillia2-desk3.jf.intel.com>
Date: Sun, 27 Dec 2015 16:46:55 +0800
Message-ID: <CAA_GA1cYJhpqJkceYzJBpUj9Uvr68zGZzmphopu+7U+dEqCN3w@mail.gmail.com>
Subject: Re: [-mm PATCH v4 14/18] mm, dax, pmem: introduce {get|put}_dev_pagemap()
 for dax-gup
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@sr71.net>, linux-nvdimm@lists.01.org, Linux-MM <linux-mm@kvack.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Logan Gunthorpe <logang@deltatee.com>

On Mon, Dec 21, 2015 at 1:45 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> get_dev_page() enables paths like get_user_pages() to pin a dynamically
> mapped pfn-range (devm_memremap_pages()) while the resulting struct page
> objects are in use.  Unlike get_page() it may fail if the device is, or
> is in the process of being, disabled.  While the initial lookup of the
> range may be an expensive list walk, the result is cached to speed up
> subsequent lookups which are likely to be in the same mapped range.
>
> devm_memremap_pages() now requires a reference counter to be specified
> at init time.  For pmem this means moving request_queue allocation into
> pmem_alloc() so the existing queue usage counter can track "device
> pages".
>
> ZONE_DEVICE pages always have an elevated count and will never be on an
> lru reclaim list.  That space in 'struct page' can be redirected for
> other uses, but for safety introduce a poison value that will always
> trip __list_add() to assert.  This allows half of the struct list_head
> storage to be reclaimed with some assurance to back up the assumption
> that the page count never goes to zero and a list_add() is never
> attempted.
>
> Cc: Dave Hansen <dave@sr71.net>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Matthew Wilcox <willy@linux.intel.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Tested-by: Logan Gunthorpe <logang@deltatee.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  drivers/nvdimm/pmem.c    |    6 +++--
>  include/linux/list.h     |   12 ++++++++++
>  include/linux/memremap.h |   49 +++++++++++++++++++++++++++++++++++++++++--
>  include/linux/mm_types.h |    5 ++++
>  kernel/memremap.c        |   53 +++++++++++++++++++++++++++++++++++++++++++---
>  lib/list_debug.c         |    9 ++++++++
>  6 files changed, 126 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
> index 2c6096ab2ce6..37ebf42c0415 100644
> --- a/drivers/nvdimm/pmem.c
> +++ b/drivers/nvdimm/pmem.c
> @@ -150,7 +150,7 @@ static struct pmem_device *pmem_alloc(struct device *dev,
>         pmem->pfn_flags = PFN_DEV;
>         if (pmem_should_map_pages(dev)) {
>                 pmem->virt_addr = (void __pmem *) devm_memremap_pages(dev, res,
> -                               NULL);
> +                               &q->q_usage_counter, NULL);
>                 pmem->pfn_flags |= PFN_MAP;
>         } else
>                 pmem->virt_addr = (void __pmem *) devm_memremap(dev,
> @@ -324,6 +324,7 @@ static int nvdimm_namespace_attach_pfn(struct nd_namespace_common *ndns)
>         struct vmem_altmap *altmap;
>         struct nd_pfn_sb *pfn_sb;
>         struct pmem_device *pmem;
> +       struct request_queue *q;
>         phys_addr_t offset;
>         int rc;
>         struct vmem_altmap __altmap = {
> @@ -375,9 +376,10 @@ static int nvdimm_namespace_attach_pfn(struct nd_namespace_common *ndns)
>
>         /* establish pfn range for lookup, and switch to direct map */
>         pmem = dev_get_drvdata(dev);
> +       q = pmem->pmem_queue;
>         devm_memunmap(dev, (void __force *) pmem->virt_addr);
>         pmem->virt_addr = (void __pmem *) devm_memremap_pages(dev, &nsio->res,
> -                       altmap);
> +                       &q->q_usage_counter, altmap);
>         pmem->pfn_flags |= PFN_MAP;
>         if (IS_ERR(pmem->virt_addr)) {
>                 rc = PTR_ERR(pmem->virt_addr);
> diff --git a/include/linux/list.h b/include/linux/list.h
> index 993395a2e55c..d870ba3315f8 100644
> --- a/include/linux/list.h
> +++ b/include/linux/list.h
> @@ -113,6 +113,18 @@ extern void __list_del_entry(struct list_head *entry);
>  extern void list_del(struct list_head *entry);
>  #endif
>
> +#ifdef CONFIG_DEBUG_LIST
> +/*
> + * See devm_memremap_pages() which wants DEBUG_LIST=y to assert if one
> + * of the pages it allocates is ever passed to list_add()
> + */
> +extern void list_force_poison(struct list_head *entry);
> +#else
> +static inline void list_force_poison(struct list_head *entry)
> +{
> +}
> +#endif
> +
>  /**
>   * list_replace - replace old entry by new one
>   * @old : the element to be replaced
> diff --git a/include/linux/memremap.h b/include/linux/memremap.h
> index aa3e82a80d7b..bcaa634139a9 100644
> --- a/include/linux/memremap.h
> +++ b/include/linux/memremap.h
> @@ -1,6 +1,8 @@
>  #ifndef _LINUX_MEMREMAP_H_
>  #define _LINUX_MEMREMAP_H_
>  #include <linux/mm.h>
> +#include <linux/ioport.h>
> +#include <linux/percpu-refcount.h>
>
>  struct resource;
>  struct device;
> @@ -36,21 +38,25 @@ static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
>  /**
>   * struct dev_pagemap - metadata for ZONE_DEVICE mappings
>   * @altmap: pre-allocated/reserved memory for vmemmap allocations
> + * @res: physical address range covered by @ref
> + * @ref: reference count that pins the devm_memremap_pages() mapping
>   * @dev: host device of the mapping for debug
>   */
>  struct dev_pagemap {
>         struct vmem_altmap *altmap;
>         const struct resource *res;
> +       struct percpu_ref *ref;
>         struct device *dev;
>  };
>
>  #ifdef CONFIG_ZONE_DEVICE
>  void *devm_memremap_pages(struct device *dev, struct resource *res,
> -               struct vmem_altmap *altmap);
> +               struct percpu_ref *ref, struct vmem_altmap *altmap);
>  struct dev_pagemap *find_dev_pagemap(resource_size_t phys);
>  #else
>  static inline void *devm_memremap_pages(struct device *dev,
> -               struct resource *res, struct vmem_altmap *altmap)
> +               struct resource *res, struct percpu_ref *ref,
> +               struct vmem_altmap *altmap)
>  {
>         /*
>          * Fail attempts to call devm_memremap_pages() without
> @@ -66,4 +72,43 @@ static inline struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
>         return NULL;
>  }
>  #endif
> +
> +/**
> + * get_dev_pagemap() - take a new live reference on the dev_pagemap for @pfn
> + * @pfn: page frame number to lookup page_map
> + * @pgmap: optional known pgmap that already has a reference
> + *
> + * @pgmap allows the overhead of a lookup to be bypassed when @pfn lands in the
> + * same mapping.
> + */
> +static inline struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
> +               struct dev_pagemap *pgmap)
> +{
> +       const struct resource *res = pgmap ? pgmap->res : NULL;
> +       resource_size_t phys = PFN_PHYS(pfn);
> +
> +       /*
> +        * In the cached case we're already holding a live reference so
> +        * we can simply do a blind increment
> +        */
> +       if (res && phys >= res->start && phys <= res->end) {
> +               percpu_ref_get(pgmap->ref);
> +               return pgmap;
> +       }
> +
> +       /* fall back to slow path lookup */
> +       rcu_read_lock();
> +       pgmap = find_dev_pagemap(phys);

Is it possible just use pfn_to_page() and then return page->pgmap?
Then we can get rid of the pgmap_radix tree totally.

Regards,
Bob

> +       if (pgmap && !percpu_ref_tryget_live(pgmap->ref))
> +               pgmap = NULL;
> +       rcu_read_unlock();
> +
> +       return pgmap;
> +}
> +
> +static inline void put_dev_pagemap(struct dev_pagemap *pgmap)
> +{
> +       if (pgmap)
> +               percpu_ref_put(pgmap->ref);
> +}
>  #endif /* _LINUX_MEMREMAP_H_ */
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 22beb225e88f..c67ea476991e 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -116,6 +116,11 @@ struct page {
>                                          * Can be used as a generic list
>                                          * by the page owner.
>                                          */
> +               struct dev_pagemap *pgmap; /* ZONE_DEVICE pages are never on an
> +                                           * lru or handled by a slab
> +                                           * allocator, this points to the
> +                                           * hosting device page map.
> +                                           */
>                 struct {                /* slub per cpu partial pages */
>                         struct page *next;      /* Next partial slab */
>  #ifdef CONFIG_64BIT

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
