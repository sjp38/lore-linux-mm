Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 993F9C48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 21:13:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32397204EC
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 21:13:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32397204EC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 64B6F6B0003; Wed, 26 Jun 2019 17:13:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5FC588E0003; Wed, 26 Jun 2019 17:13:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 49C798E0002; Wed, 26 Jun 2019 17:13:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0A3246B0003
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 17:13:04 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x9so27351pfm.16
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 14:13:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=dL1/qkbjKH8CRWu4aDHRvHV1PO4Y5tae8UI8blXubio=;
        b=PFcCS6gdFTaWyg9cB+TnrZKtvszk/xF+Ml1rM94dhghcUz2wHQRh96qAias6kdoO93
         0f+ibXSqy4KwzqsLrHT0jHNYZ2oj3LWklzPrFpggQ4A6yqkYfCNPMRqkPS3hwmwmshyR
         8YBh7yrbksAcNizgPcGwjkm/U3vwqVlz1RK7ZrMWY+J5PRe097OLkXEAFI+wXtLKpZq7
         e6pB7JgXntInGjQ4nZKN+Um0ZnNGF/UhPNF5xo+BqMhvm7wUMa34Nuju1OUABhNfdXIy
         oIaEKCYENwbOGRnPdCJpIuOgp3/AsWyV0TIYWBAHpn5nHWwR2DNgJ2ndwMBxVZMSmtwN
         0JRQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVDPFsUHkhJNRwxAl/tnkgt86ux5+Fr7+JsOLb6VMuJzqFA2dsg
	kbJnWlwBVaaiCZfXT6iijfCsUsj/YOxg/A+tvIJATl7Eguz+TVuv08fBS9K6fYifkIa6gIoffh3
	OE+DH2+/FwqdnD1N/RchFv/V+iYZM9ZZm2gnU0oleetTP99V56XcS344wJW3EQp97yw==
X-Received: by 2002:a17:902:b608:: with SMTP id b8mr147922pls.303.1561583583536;
        Wed, 26 Jun 2019 14:13:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx7rfFp9/4ORap/+BwKBz4eLUhNxZJYVksRZuAx/DQ7AAHz4NCVNevWajI/T09w+rQAcAUl
X-Received: by 2002:a17:902:b608:: with SMTP id b8mr147807pls.303.1561583582409;
        Wed, 26 Jun 2019 14:13:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561583582; cv=none;
        d=google.com; s=arc-20160816;
        b=YR31Lun/+7tKflmhpAZrEACqS0QTQaeUI4DV9EaFBZQiQEsq5C0qQ87ohcf5bGR1uY
         +60eQd5Gx3bxAxC1VNYFUAAMpE4QE37/8wPReOlLUwbCvnSYCsCRNZCx/L6Q2haYrThL
         8B94sPg5BpCsfnO33GRxB99O0G6Yn2t1n5IbEhlWseb4kYFSuvcLvmgh/5E1hylbX1Fi
         mELydo3avCzrX+VEpAxLZ74kETYwqFruCc2MdGlWBLxsC5Yon8JkV/Pq7khBy5eGwVb/
         V0MnaJeEJkGr4gBPYu52P06zz2eqrLWYJYthgIoO+JfjDwzcRrT9da0nEwrXTlRQmYNR
         S14A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=dL1/qkbjKH8CRWu4aDHRvHV1PO4Y5tae8UI8blXubio=;
        b=HmKo6Jtt7Bwc5YA+gXO3tpKj6G6dM/rF90GA0axxC/6lhVNSlp2AXhZwILXTUzc21k
         cggPda8G8AnyHLHVOP6PtGl6f5BKDcQlroPo76RQGvWelPb/irIrceQf9g65/LNRqva0
         QwDvXXTuHBsQ5rgr4Vc02vvme4ESqtH++5FOpCee2BY8ZdmtNZr0YdkF0gucZsRP77FA
         G866WAd9+7NUnjyI2D05OKnS51biOtD+mmmV/L36PcrCQemRrDerA5VM3hKmI9jOf9c/
         +u/qErI5r0DP653PXY2YX7aEBoQxJ1xI+G+N7Aqd9J9E88EWJkQKFp8SHrvWE8NiZvYe
         jKAw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id q3si107803pgp.497.2019.06.26.14.13.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 14:13:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Jun 2019 14:13:01 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,421,1557212400"; 
   d="scan'208";a="172874357"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga002.jf.intel.com with ESMTP; 26 Jun 2019 14:13:01 -0700
Date: Wed, 26 Jun 2019 14:13:00 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	linux-nvdimm@lists.01.org, linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, nouveau@lists.freedesktop.org
Subject: Re: [PATCH 14/25] memremap: replace the altmap_valid field with a
 PGMAP_ALTMAP_VALID flag
Message-ID: <20190626211300.GF4605@iweiny-DESK2.sc.intel.com>
References: <20190626122724.13313-1-hch@lst.de>
 <20190626122724.13313-15-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190626122724.13313-15-hch@lst.de>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 26, 2019 at 02:27:13PM +0200, Christoph Hellwig wrote:
> Add a flags field to struct dev_pagemap to replace the altmap_valid
> boolean to be a little more extensible.  Also add a pgmap_altmap() helper
> to find the optional altmap and clean up the code using the altmap using
> it.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

> ---
>  arch/powerpc/mm/mem.c     | 10 +---------
>  arch/x86/mm/init_64.c     |  8 ++------
>  drivers/nvdimm/pfn_devs.c |  3 +--
>  drivers/nvdimm/pmem.c     |  1 -
>  include/linux/memremap.h  | 12 +++++++++++-
>  kernel/memremap.c         | 26 ++++++++++----------------
>  mm/hmm.c                  |  1 -
>  mm/memory_hotplug.c       |  6 ++----
>  mm/page_alloc.c           |  5 ++---
>  9 files changed, 29 insertions(+), 43 deletions(-)
> 
> diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
> index cba29131bccc..f774d80df025 100644
> --- a/arch/powerpc/mm/mem.c
> +++ b/arch/powerpc/mm/mem.c
> @@ -131,17 +131,9 @@ void __ref arch_remove_memory(int nid, u64 start, u64 size,
>  {
>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
> -	struct page *page;
> +	struct page *page = pfn_to_page(start_pfn) + vmem_altmap_offset(altmap);
>  	int ret;
>  
> -	/*
> -	 * If we have an altmap then we need to skip over any reserved PFNs
> -	 * when querying the zone.
> -	 */
> -	page = pfn_to_page(start_pfn);
> -	if (altmap)
> -		page += vmem_altmap_offset(altmap);
> -
>  	__remove_pages(page_zone(page), start_pfn, nr_pages, altmap);
>  
>  	/* Remove htab bolted mappings for this section of memory */
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index 693aaf28d5fe..3139e992ef9d 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -1211,13 +1211,9 @@ void __ref arch_remove_memory(int nid, u64 start, u64 size,
>  {
>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
> -	struct page *page = pfn_to_page(start_pfn);
> -	struct zone *zone;
> +	struct page *page = pfn_to_page(start_pfn) + vmem_altmap_offset(altmap);
> +	struct zone *zone = page_zone(page);
>  
> -	/* With altmap the first mapped page is offset from @start */
> -	if (altmap)
> -		page += vmem_altmap_offset(altmap);
> -	zone = page_zone(page);
>  	__remove_pages(zone, start_pfn, nr_pages, altmap);
>  	kernel_physical_mapping_remove(start, start + size);
>  }
> diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
> index 0f81fc56bbfd..55fb6b7433ed 100644
> --- a/drivers/nvdimm/pfn_devs.c
> +++ b/drivers/nvdimm/pfn_devs.c
> @@ -622,7 +622,6 @@ static int __nvdimm_setup_pfn(struct nd_pfn *nd_pfn, struct dev_pagemap *pgmap)
>  		if (offset < reserve)
>  			return -EINVAL;
>  		nd_pfn->npfns = le64_to_cpu(pfn_sb->npfns);
> -		pgmap->altmap_valid = false;
>  	} else if (nd_pfn->mode == PFN_MODE_PMEM) {
>  		nd_pfn->npfns = PFN_SECTION_ALIGN_UP((resource_size(res)
>  					- offset) / PAGE_SIZE);
> @@ -634,7 +633,7 @@ static int __nvdimm_setup_pfn(struct nd_pfn *nd_pfn, struct dev_pagemap *pgmap)
>  		memcpy(altmap, &__altmap, sizeof(*altmap));
>  		altmap->free = PHYS_PFN(offset - reserve);
>  		altmap->alloc = 0;
> -		pgmap->altmap_valid = true;
> +		pgmap->flags |= PGMAP_ALTMAP_VALID;
>  	} else
>  		return -ENXIO;
>  
> diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
> index 093408ce40ad..e7d8cc9f41e8 100644
> --- a/drivers/nvdimm/pmem.c
> +++ b/drivers/nvdimm/pmem.c
> @@ -412,7 +412,6 @@ static int pmem_attach_disk(struct device *dev,
>  		bb_res.start += pmem->data_offset;
>  	} else if (pmem_should_map_pages(dev)) {
>  		memcpy(&pmem->pgmap.res, &nsio->res, sizeof(pmem->pgmap.res));
> -		pmem->pgmap.altmap_valid = false;
>  		pmem->pgmap.type = MEMORY_DEVICE_FS_DAX;
>  		pmem->pgmap.ops = &fsdax_pagemap_ops;
>  		addr = devm_memremap_pages(dev, &pmem->pgmap);
> diff --git a/include/linux/memremap.h b/include/linux/memremap.h
> index 336eca601dad..e25685b878e9 100644
> --- a/include/linux/memremap.h
> +++ b/include/linux/memremap.h
> @@ -88,6 +88,8 @@ struct dev_pagemap_ops {
>  	vm_fault_t (*migrate_to_ram)(struct vm_fault *vmf);
>  };
>  
> +#define PGMAP_ALTMAP_VALID	(1 << 0)
> +
>  /**
>   * struct dev_pagemap - metadata for ZONE_DEVICE mappings
>   * @altmap: pre-allocated/reserved memory for vmemmap allocations
> @@ -96,19 +98,27 @@ struct dev_pagemap_ops {
>   * @dev: host device of the mapping for debug
>   * @data: private data pointer for page_free()
>   * @type: memory type: see MEMORY_* in memory_hotplug.h
> + * @flags: PGMAP_* flags to specify defailed behavior
>   * @ops: method table
>   */
>  struct dev_pagemap {
>  	struct vmem_altmap altmap;
> -	bool altmap_valid;
>  	struct resource res;
>  	struct percpu_ref *ref;
>  	struct device *dev;
>  	enum memory_type type;
> +	unsigned int flags;
>  	u64 pci_p2pdma_bus_offset;
>  	const struct dev_pagemap_ops *ops;
>  };
>  
> +static inline struct vmem_altmap *pgmap_altmap(struct dev_pagemap *pgmap)
> +{
> +	if (pgmap->flags & PGMAP_ALTMAP_VALID)
> +		return &pgmap->altmap;
> +	return NULL;
> +}
> +
>  #ifdef CONFIG_ZONE_DEVICE
>  void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap);
>  void devm_memunmap_pages(struct device *dev, struct dev_pagemap *pgmap);
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index 6c3dbb692037..eee490e7d7e1 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -54,14 +54,8 @@ static void pgmap_array_delete(struct resource *res)
>  
>  static unsigned long pfn_first(struct dev_pagemap *pgmap)
>  {
> -	const struct resource *res = &pgmap->res;
> -	struct vmem_altmap *altmap = &pgmap->altmap;
> -	unsigned long pfn;
> -
> -	pfn = res->start >> PAGE_SHIFT;
> -	if (pgmap->altmap_valid)
> -		pfn += vmem_altmap_offset(altmap);
> -	return pfn;
> +	return (pgmap->res.start >> PAGE_SHIFT) +
> +		vmem_altmap_offset(pgmap_altmap(pgmap));
>  }
>  
>  static unsigned long pfn_end(struct dev_pagemap *pgmap)
> @@ -109,7 +103,7 @@ static void devm_memremap_pages_release(void *data)
>  				align_size >> PAGE_SHIFT, NULL);
>  	} else {
>  		arch_remove_memory(nid, align_start, align_size,
> -				pgmap->altmap_valid ? &pgmap->altmap : NULL);
> +				pgmap_altmap(pgmap));
>  		kasan_remove_zero_shadow(__va(align_start), align_size);
>  	}
>  	mem_hotplug_done();
> @@ -129,8 +123,8 @@ static void devm_memremap_pages_release(void *data)
>   * 1/ At a minimum the res, ref and type and ops members of @pgmap must be
>   *    initialized by the caller before passing it to this function
>   *
> - * 2/ The altmap field may optionally be initialized, in which case altmap_valid
> - *    must be set to true
> + * 2/ The altmap field may optionally be initialized, in which case
> + *    PGMAP_ALTMAP_VALID must be set in pgmap->flags.
>   *
>   * 3/ pgmap->ref must be 'live' on entry and will be killed and reaped
>   *    at devm_memremap_pages_release() time, or if this routine fails.
> @@ -142,15 +136,13 @@ static void devm_memremap_pages_release(void *data)
>  void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
>  {
>  	resource_size_t align_start, align_size, align_end;
> -	struct vmem_altmap *altmap = pgmap->altmap_valid ?
> -			&pgmap->altmap : NULL;
>  	struct resource *res = &pgmap->res;
>  	struct dev_pagemap *conflict_pgmap;
>  	struct mhp_restrictions restrictions = {
>  		/*
>  		 * We do not want any optional features only our own memmap
>  		*/
> -		.altmap = altmap,
> +		.altmap = pgmap_altmap(pgmap),
>  	};
>  	pgprot_t pgprot = PAGE_KERNEL;
>  	int error, nid, is_ram;
> @@ -274,7 +266,7 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
>  
>  		zone = &NODE_DATA(nid)->node_zones[ZONE_DEVICE];
>  		move_pfn_range_to_zone(zone, align_start >> PAGE_SHIFT,
> -				align_size >> PAGE_SHIFT, altmap);
> +				align_size >> PAGE_SHIFT, pgmap_altmap(pgmap));
>  	}
>  
>  	mem_hotplug_done();
> @@ -319,7 +311,9 @@ EXPORT_SYMBOL_GPL(devm_memunmap_pages);
>  unsigned long vmem_altmap_offset(struct vmem_altmap *altmap)
>  {
>  	/* number of pfns from base where pfn_to_page() is valid */
> -	return altmap->reserve + altmap->free;
> +	if (altmap)
> +		return altmap->reserve + altmap->free;
> +	return 0;
>  }
>  
>  void vmem_altmap_free(struct vmem_altmap *altmap, unsigned long nr_pfns)
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 36e25cdbdac1..e4470462298f 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -1442,7 +1442,6 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
>  	devmem->pagemap.type = MEMORY_DEVICE_PRIVATE;
>  	devmem->pagemap.res = *devmem->resource;
>  	devmem->pagemap.ops = &hmm_pagemap_ops;
> -	devmem->pagemap.altmap_valid = false;
>  	devmem->pagemap.ref = &devmem->ref;
>  
>  	result = devm_memremap_pages(devmem->device, &devmem->pagemap);
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index e096c987d261..6166ba5a15f3 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -557,10 +557,8 @@ void __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
>  	int sections_to_remove;
>  
>  	/* In the ZONE_DEVICE case device driver owns the memory region */
> -	if (is_dev_zone(zone)) {
> -		if (altmap)
> -			map_offset = vmem_altmap_offset(altmap);
> -	}
> +	if (is_dev_zone(zone))
> +		map_offset = vmem_altmap_offset(altmap);
>  
>  	clear_zone_contiguous(zone);
>  
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d66bc8abe0af..17a39d40a556 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5853,6 +5853,7 @@ void __ref memmap_init_zone_device(struct zone *zone,
>  {
>  	unsigned long pfn, end_pfn = start_pfn + size;
>  	struct pglist_data *pgdat = zone->zone_pgdat;
> +	struct vmem_altmap *altmap = pgmap_altmap(pgmap);
>  	unsigned long zone_idx = zone_idx(zone);
>  	unsigned long start = jiffies;
>  	int nid = pgdat->node_id;
> @@ -5865,9 +5866,7 @@ void __ref memmap_init_zone_device(struct zone *zone,
>  	 * of the pages reserved for the memmap, so we can just jump to
>  	 * the end of that region and start processing the device pages.
>  	 */
> -	if (pgmap->altmap_valid) {
> -		struct vmem_altmap *altmap = &pgmap->altmap;
> -
> +	if (altmap) {
>  		start_pfn = altmap->base_pfn + vmem_altmap_offset(altmap);
>  		size = end_pfn - start_pfn;
>  	}
> -- 
> 2.20.1
> 
> _______________________________________________
> Linux-nvdimm mailing list
> Linux-nvdimm@lists.01.org
> https://lists.01.org/mailman/listinfo/linux-nvdimm

