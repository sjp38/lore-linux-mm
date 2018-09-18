Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0CAF28E0001
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 16:28:56 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id c14-v6so2319143qtc.7
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 13:28:56 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 86-v6si1174610qks.141.2018.09.18.13.28.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Sep 2018 13:28:54 -0700 (PDT)
Date: Tue, 18 Sep 2018 16:28:50 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH v5 3/7] mm, devm_memremap_pages: Fix shutdown handling
Message-ID: <20180918202850.GC14689@redhat.com>
References: <153680531988.453305.8080706591516037706.stgit@dwillia2-desk3.amr.corp.intel.com>
 <153680533706.453305.3428304103990941022.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <153680533706.453305.3428304103990941022.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, stable@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Logan Gunthorpe <logang@deltatee.com>, alexander.h.duyck@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Sep 12, 2018 at 07:22:17PM -0700, Dan Williams wrote:
> The last step before devm_memremap_pages() returns success is to
> allocate a release action, devm_memremap_pages_release(), to tear the
> entire setup down. However, the result from devm_add_action() is not
> checked.
> 
> Checking the error from devm_add_action() is not enough. The api
> currently relies on the fact that the percpu_ref it is using is killed
> by the time the devm_memremap_pages_release() is run. Rather than
> continue this awkward situation, offload the responsibility of killing
> the percpu_ref to devm_memremap_pages_release() directly. This allows
> devm_memremap_pages() to do the right thing  relative to init failures
> and shutdown.
> 
> Without this change we could fail to register the teardown of
> devm_memremap_pages(). The likelihood of hitting this failure is tiny as
> small memory allocations almost always succeed. However, the impact of
> the failure is large given any future reconfiguration, or
> disable/enable, of an nvdimm namespace will fail forever as subsequent
> calls to devm_memremap_pages() will fail to setup the pgmap_radix since
> there will be stale entries for the physical address range.
> 
> An argument could be made to require that the ->kill() operation be set
> in the @pgmap arg rather than passed in separately. However, it helps
> code readability, tracking the lifetime of a given instance, to be able
> to grep the kill routine directly at the devm_memremap_pages() call
> site.
> 
> Cc: <stable@vger.kernel.org>
> Fixes: e8d513483300 ("memremap: change devm_memremap_pages interface...")
> Cc: Christoph Hellwig <hch@lst.de>

Reviewed-by: Jerome Glisse <jglisse@redhat.com>

> Reported-by: Logan Gunthorpe <logang@deltatee.com>
> Reviewed-by: Logan Gunthorpe <logang@deltatee.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  drivers/dax/pmem.c                |   15 +++------------
>  drivers/nvdimm/pmem.c             |   18 ++++++++----------
>  include/linux/memremap.h          |    7 +++++--
>  kernel/memremap.c                 |   36 +++++++++++++++++++-----------------
>  tools/testing/nvdimm/test/iomap.c |   21 ++++++++++++++++++---
>  5 files changed, 53 insertions(+), 44 deletions(-)
> 
> diff --git a/drivers/dax/pmem.c b/drivers/dax/pmem.c
> index 99e2aace8078..c1e03d769e6d 100644
> --- a/drivers/dax/pmem.c
> +++ b/drivers/dax/pmem.c
> @@ -48,9 +48,8 @@ static void dax_pmem_percpu_exit(void *data)
>  	percpu_ref_exit(ref);
>  }
>  
> -static void dax_pmem_percpu_kill(void *data)
> +static void dax_pmem_percpu_kill(struct percpu_ref *ref)
>  {
> -	struct percpu_ref *ref = data;
>  	struct dax_pmem *dax_pmem = to_dax_pmem(ref);
>  
>  	dev_dbg(dax_pmem->dev, "trace\n");
> @@ -112,17 +111,9 @@ static int dax_pmem_probe(struct device *dev)
>  	}
>  
>  	dax_pmem->pgmap.ref = &dax_pmem->ref;
> -	addr = devm_memremap_pages(dev, &dax_pmem->pgmap);
> -	if (IS_ERR(addr)) {
> -		devm_remove_action(dev, dax_pmem_percpu_exit, &dax_pmem->ref);
> -		percpu_ref_exit(&dax_pmem->ref);
> +	addr = devm_memremap_pages(dev, &dax_pmem->pgmap, dax_pmem_percpu_kill);
> +	if (IS_ERR(addr))
>  		return PTR_ERR(addr);
> -	}
> -
> -	rc = devm_add_action_or_reset(dev, dax_pmem_percpu_kill,
> -							&dax_pmem->ref);
> -	if (rc)
> -		return rc;
>  
>  	/* adjust the dax_region resource to the start of data */
>  	memcpy(&res, &dax_pmem->pgmap.res, sizeof(res));
> diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
> index 6071e2942053..c9cad5ebea5b 100644
> --- a/drivers/nvdimm/pmem.c
> +++ b/drivers/nvdimm/pmem.c
> @@ -309,8 +309,11 @@ static void pmem_release_queue(void *q)
>  	blk_cleanup_queue(q);
>  }
>  
> -static void pmem_freeze_queue(void *q)
> +static void pmem_freeze_queue(struct percpu_ref *ref)
>  {
> +	struct request_queue *q;
> +
> +	q = container_of(ref, typeof(*q), q_usage_counter);
>  	blk_freeze_queue_start(q);
>  }
>  
> @@ -405,7 +408,8 @@ static int pmem_attach_disk(struct device *dev,
>  	if (is_nd_pfn(dev)) {
>  		if (setup_pagemap_fsdax(dev, &pmem->pgmap))
>  			return -ENOMEM;
> -		addr = devm_memremap_pages(dev, &pmem->pgmap);
> +		addr = devm_memremap_pages(dev, &pmem->pgmap,
> +				pmem_freeze_queue);
>  		pfn_sb = nd_pfn->pfn_sb;
>  		pmem->data_offset = le64_to_cpu(pfn_sb->dataoff);
>  		pmem->pfn_pad = resource_size(res) -
> @@ -418,20 +422,14 @@ static int pmem_attach_disk(struct device *dev,
>  		pmem->pgmap.altmap_valid = false;
>  		if (setup_pagemap_fsdax(dev, &pmem->pgmap))
>  			return -ENOMEM;
> -		addr = devm_memremap_pages(dev, &pmem->pgmap);
> +		addr = devm_memremap_pages(dev, &pmem->pgmap,
> +				pmem_freeze_queue);
>  		pmem->pfn_flags |= PFN_MAP;
>  		memcpy(&bb_res, &pmem->pgmap.res, sizeof(bb_res));
>  	} else
>  		addr = devm_memremap(dev, pmem->phys_addr,
>  				pmem->size, ARCH_MEMREMAP_PMEM);
>  
> -	/*
> -	 * At release time the queue must be frozen before
> -	 * devm_memremap_pages is unwound
> -	 */
> -	if (devm_add_action_or_reset(dev, pmem_freeze_queue, q))
> -		return -ENOMEM;
> -
>  	if (IS_ERR(addr))
>  		return PTR_ERR(addr);
>  	pmem->virt_addr = addr;
> diff --git a/include/linux/memremap.h b/include/linux/memremap.h
> index f91f9e763557..71f5e7c7dfb9 100644
> --- a/include/linux/memremap.h
> +++ b/include/linux/memremap.h
> @@ -106,6 +106,7 @@ typedef void (*dev_page_free_t)(struct page *page, void *data);
>   * @altmap: pre-allocated/reserved memory for vmemmap allocations
>   * @res: physical address range covered by @ref
>   * @ref: reference count that pins the devm_memremap_pages() mapping
> + * @kill: callback to transition @ref to the dead state
>   * @dev: host device of the mapping for debug
>   * @data: private data pointer for page_free()
>   * @type: memory type: see MEMORY_* in memory_hotplug.h
> @@ -117,13 +118,15 @@ struct dev_pagemap {
>  	bool altmap_valid;
>  	struct resource res;
>  	struct percpu_ref *ref;
> +	void (*kill)(struct percpu_ref *ref);
>  	struct device *dev;
>  	void *data;
>  	enum memory_type type;
>  };
>  
>  #ifdef CONFIG_ZONE_DEVICE
> -void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap);
> +void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap,
> +		void (*kill)(struct percpu_ref *));
>  struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
>  		struct dev_pagemap *pgmap);
>  
> @@ -131,7 +134,7 @@ unsigned long vmem_altmap_offset(struct vmem_altmap *altmap);
>  void vmem_altmap_free(struct vmem_altmap *altmap, unsigned long nr_pfns);
>  #else
>  static inline void *devm_memremap_pages(struct device *dev,
> -		struct dev_pagemap *pgmap)
> +		struct dev_pagemap *pgmap, void (*kill)(struct percpu_ref *))
>  {
>  	/*
>  	 * Fail attempts to call devm_memremap_pages() without
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index 92e838127767..ab5eb570d28d 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -122,14 +122,10 @@ static void devm_memremap_pages_release(void *data)
>  	resource_size_t align_start, align_size;
>  	unsigned long pfn;
>  
> +	pgmap->kill(pgmap->ref);
>  	for_each_device_pfn(pfn, pgmap)
>  		put_page(pfn_to_page(pfn));
>  
> -	if (percpu_ref_tryget_live(pgmap->ref)) {
> -		dev_WARN(dev, "%s: page mapping is still live!\n", __func__);
> -		percpu_ref_put(pgmap->ref);
> -	}
> -
>  	/* pages are dead and unused, undo the arch mapping */
>  	align_start = res->start & ~(SECTION_SIZE - 1);
>  	align_size = ALIGN(res->start + resource_size(res), SECTION_SIZE)
> @@ -150,7 +146,8 @@ static void devm_memremap_pages_release(void *data)
>  /**
>   * devm_memremap_pages - remap and provide memmap backing for the given resource
>   * @dev: hosting device for @res
> - * @pgmap: pointer to a struct dev_pgmap
> + * @pgmap: pointer to a struct dev_pagemap
> + * @kill: routine to kill @pgmap->ref
>   *
>   * Notes:
>   * 1/ At a minimum the res, ref and type members of @pgmap must be initialized
> @@ -159,17 +156,15 @@ static void devm_memremap_pages_release(void *data)
>   * 2/ The altmap field may optionally be initialized, in which case altmap_valid
>   *    must be set to true
>   *
> - * 3/ pgmap.ref must be 'live' on entry and 'dead' before devm_memunmap_pages()
> - *    time (or devm release event). The expected order of events is that ref has
> - *    been through percpu_ref_kill() before devm_memremap_pages_release(). The
> - *    wait for the completion of all references being dropped and
> - *    percpu_ref_exit() must occur after devm_memremap_pages_release().
> + * 3/ pgmap->ref must be 'live' on entry and will be killed at
> + *    devm_memremap_pages_release() time, or if this routine fails.
>   *
>   * 4/ res is expected to be a host memory range that could feasibly be
>   *    treated as a "System RAM" range, i.e. not a device mmio range, but
>   *    this is not enforced.
>   */
> -void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
> +void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap,
> +		void (*kill)(struct percpu_ref *))
>  {
>  	resource_size_t align_start, align_size, align_end;
>  	struct vmem_altmap *altmap = pgmap->altmap_valid ?
> @@ -180,6 +175,9 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
>  	int error, nid, is_ram;
>  	struct dev_pagemap *conflict_pgmap;
>  
> +	if (!pgmap->ref || !kill)
> +		return ERR_PTR(-EINVAL);
> +
>  	align_start = res->start & ~(SECTION_SIZE - 1);
>  	align_size = ALIGN(res->start + resource_size(res), SECTION_SIZE)
>  		- align_start;
> @@ -205,12 +203,10 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
>  	if (is_ram != REGION_DISJOINT) {
>  		WARN_ONCE(1, "%s attempted on %s region %pr\n", __func__,
>  				is_ram == REGION_MIXED ? "mixed" : "ram", res);
> -		return ERR_PTR(-ENXIO);
> +		error = -ENXIO;
> +		goto err_init;
>  	}
>  
> -	if (!pgmap->ref)
> -		return ERR_PTR(-EINVAL);
> -
>  	pgmap->dev = dev;
>  
>  	mutex_lock(&pgmap_lock);
> @@ -267,7 +263,11 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
>  		percpu_ref_get(pgmap->ref);
>  	}
>  
> -	devm_add_action(dev, devm_memremap_pages_release, pgmap);
> +	pgmap->kill = kill;
> +	error = devm_add_action_or_reset(dev, devm_memremap_pages_release,
> +			pgmap);
> +	if (error)
> +		return ERR_PTR(error);
>  
>  	return __va(res->start);
>  
> @@ -278,6 +278,8 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
>   err_pfn_remap:
>   err_radix:
>  	pgmap_radix_release(res, pgoff);
> + err_init:
> +	kill(pgmap->ref);
>  	return ERR_PTR(error);
>  }
>  EXPORT_SYMBOL_GPL(devm_memremap_pages);
> diff --git a/tools/testing/nvdimm/test/iomap.c b/tools/testing/nvdimm/test/iomap.c
> index ff9d3a5825e1..ad544e6476a9 100644
> --- a/tools/testing/nvdimm/test/iomap.c
> +++ b/tools/testing/nvdimm/test/iomap.c
> @@ -104,14 +104,29 @@ void *__wrap_devm_memremap(struct device *dev, resource_size_t offset,
>  }
>  EXPORT_SYMBOL(__wrap_devm_memremap);
>  
> -void *__wrap_devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
> +static void nfit_test_kill(void *_pgmap)
> +{
> +	struct dev_pagemap *pgmap = _pgmap;
> +
> +	pgmap->kill(pgmap->ref);
> +}
> +
> +void *__wrap_devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap,
> +		void (*kill)(struct percpu_ref *))
>  {
>  	resource_size_t offset = pgmap->res.start;
>  	struct nfit_test_resource *nfit_res = get_nfit_res(offset);
>  
> -	if (nfit_res)
> +	if (nfit_res) {
> +		int rc;
> +
> +		pgmap->kill = kill;
> +		rc = devm_add_action_or_reset(dev, nfit_test_kill, pgmap);
> +		if (rc)
> +			return ERR_PTR(rc);
>  		return nfit_res->buf + offset - nfit_res->res.start;
> -	return devm_memremap_pages(dev, pgmap);
> +	}
> +	return devm_memremap_pages(dev, pgmap, kill);
>  }
>  EXPORT_SYMBOL(__wrap_devm_memremap_pages);
>  
> 
