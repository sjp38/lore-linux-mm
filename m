Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id B8E3B6B025D
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 18:46:59 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id wq6so13156938pac.1
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 15:46:59 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 62si3486pfp.195.2015.12.15.15.46.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Dec 2015 15:46:59 -0800 (PST)
Date: Tue, 15 Dec 2015 15:46:58 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [-mm PATCH v2 21/25] mm, dax, pmem: introduce
 {get|put}_dev_pagemap() for dax-gup
Message-Id: <20151215154658.993c1b63977332027792aed7@linux-foundation.org>
In-Reply-To: <20151210023905.30368.32787.stgit@dwillia2-desk3.jf.intel.com>
References: <20151210023708.30368.92962.stgit@dwillia2-desk3.jf.intel.com>
	<20151210023905.30368.32787.stgit@dwillia2-desk3.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Hansen <dave@sr71.net>, linux-nvdimm@ml01.01.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Logan Gunthorpe <logang@deltatee.com>

On Wed, 09 Dec 2015 18:39:06 -0800 Dan Williams <dan.j.williams@intel.com> wrote:

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
> Cc: Dave Hansen <dave@sr71.net>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Matthew Wilcox <willy@linux.intel.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Tested-by: Logan Gunthorpe <logang@deltatee.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  drivers/nvdimm/pmem.c    |    6 +++--
>  include/linux/mm.h       |   49 +++++++++++++++++++++++++++++++++++++++++--
>  include/linux/mm_types.h |    5 ++++
>  kernel/memremap.c        |   53 +++++++++++++++++++++++++++++++++++++++++++---
>  4 files changed, 105 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
> index 9060a64628ae..11e483a3fbc9 100644
> --- a/drivers/nvdimm/pmem.c
> +++ b/drivers/nvdimm/pmem.c
> @@ -149,7 +149,7 @@ static struct pmem_device *pmem_alloc(struct device *dev,
>  	pmem->pfn_flags = PFN_DEV;
>  	if (pmem_should_map_pages(dev)) {
>  		pmem->virt_addr = (void __pmem *) devm_memremap_pages(dev, res,
> -				NULL);
> +				&q->q_usage_counter, NULL);
>  		pmem->pfn_flags |= PFN_MAP;
>  	} else
>  		pmem->virt_addr = (void __pmem *) devm_memremap(dev,
> @@ -323,6 +323,7 @@ static int nvdimm_namespace_attach_pfn(struct nd_namespace_common *ndns)
>  	struct vmem_altmap *altmap;
>  	struct nd_pfn_sb *pfn_sb;
>  	struct pmem_device *pmem;
> +	struct request_queue *q;
>  	phys_addr_t offset;
>  	int rc;
>  	struct vmem_altmap __altmap = {
> @@ -374,9 +375,10 @@ static int nvdimm_namespace_attach_pfn(struct nd_namespace_common *ndns)
>  
>  	/* establish pfn range for lookup, and switch to direct map */
>  	pmem = dev_get_drvdata(dev);
> +	q = pmem->pmem_queue;
>  	devm_memunmap(dev, (void __force *) pmem->virt_addr);
>  	pmem->virt_addr = (void __pmem *) devm_memremap_pages(dev, &nsio->res,
> -			altmap);
> +			&q->q_usage_counter, altmap);
>  	pmem->pfn_flags |= PFN_MAP;
>  	if (IS_ERR(pmem->virt_addr)) {
>  		rc = PTR_ERR(pmem->virt_addr);
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index e8130b798da8..c74e7eca24c0 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -15,12 +15,14 @@
>  #include <linux/debug_locks.h>
>  #include <linux/mm_types.h>
>  #include <linux/range.h>
> +#include <linux/percpu-refcount.h>
>  #include <linux/pfn.h>
>  #include <linux/bit_spinlock.h>
>  #include <linux/shrinker.h>
>  #include <linux/resource.h>
>  #include <linux/page_ext.h>
>  #include <linux/err.h>
> +#include <linux/ioport.h>

Oh geeze, poor old mm.h.

>
> ...
>
> @@ -785,6 +791,45 @@ static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
>  }
>  #endif
>  
> +/**
> + * get_dev_pagemap() - take a new live reference on the dev_pagemap for @pfn
> + * @pfn: page frame number to lookup page_map
> + * @pgmap: optional known pgmap that already has a reference
> + *
> + * @pgmap allows the overhead of a lookup to be bypassed when @pfn lands in the
> + * same mapping.
> + */
> +static inline struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
> +		struct dev_pagemap *pgmap)
> +{
> +	const struct resource *res = pgmap ? pgmap->res : NULL;
> +	resource_size_t phys = __pfn_to_phys(pfn);
> +
> +	/*
> +	 * In the cached case we're already holding a live reference so
> +	 * we can simply do a blind increment
> +	 */
> +	if (res && phys >= res->start && phys <= res->end) {
> +		percpu_ref_get(pgmap->ref);
> +		return pgmap;
> +	}
> +
> +	/* fall back to slow path lookup */
> +	rcu_read_lock();
> +	pgmap = find_dev_pagemap(phys);
> +	if (pgmap && !percpu_ref_tryget_live(pgmap->ref))
> +		pgmap = NULL;
> +	rcu_read_unlock();
> +
> +	return pgmap;
> +}

Big.  Does it need to be inlined?

> +static inline void put_dev_pagemap(struct dev_pagemap *pgmap)
> +{
> +	if (pgmap)
> +		percpu_ref_put(pgmap->ref);
> +}
> +
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
