Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28EEEC48BD9
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 19:04:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1D9C216C8
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 19:04:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1D9C216C8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 685286B0005; Wed, 26 Jun 2019 15:04:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 635DA8E0003; Wed, 26 Jun 2019 15:04:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 524B78E0002; Wed, 26 Jun 2019 15:04:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1BE336B0005
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 15:04:50 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id u10so1936499plq.21
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 12:04:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=aqyxWDV4z/NfBALkGLkFQjG9dLo/Lmc07LaPnhV+YTw=;
        b=BXTnK9C5itnQle55x/2iW6H2BnVIHjByXAzG1KzIY1QCMC4AcTkauIkxjCv8falzcB
         JntwBcoyyeRZMLpK7sWI65eINmR9GAzbGudOZmPTJsWA7YxTWzPd0TfjkhtZ/sYznQPS
         gyYXfwlksQpALp21XAti1K0ezjznKnvTMp3yFjjxBU+J33Gp1pCZRKNVw2IsGlCR1o+a
         68u7ikS+1oFWl+euadf3MTiPexabB5B0j9UmyBbucPhb3+xGwIWUevbB30P9qE+nB5kf
         /B6UJcMhvXyIY9gwo2/HHW18Xd8NAdg4R8BTVUctrF5+EF0gjX0zmS+oGJntw4YUBlBi
         xpag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVG5FPE+G3px8XVRA04+EY2fDtlIjxFIUE3FCxF6z4dqLRPiNbe
	GkLq1P5/fZFJO7rYjBxdUc4oRW0C4OMKF0EUeu4eRdqOLSwJT84bPofZzm0iVy0PxHe12rmnO0c
	FOj81tjau8+WblvgSoNb+ZdUqkFqVz3r6LR4vId+xRrGascwqXbdTDK+DNPewrKe47w==
X-Received: by 2002:a17:90a:4803:: with SMTP id a3mr794221pjh.58.1561575888753;
        Wed, 26 Jun 2019 12:04:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxauf8OJKvgTA0hiHmwPRiXpO+1m/Wg4cFPQ3LYpq7134Vy6WYAW9wLFELp6MGMgQCEXY5p
X-Received: by 2002:a17:90a:4803:: with SMTP id a3mr794135pjh.58.1561575887754;
        Wed, 26 Jun 2019 12:04:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561575887; cv=none;
        d=google.com; s=arc-20160816;
        b=QjS4k2IKAs83gjAVQ34TabdqVHbrOEAKRw23NAvbIwYdfLxN8SAQvQm9R2p3EJza0A
         yHHk3K+5HXAFMIvqYbzsBYVgG3YnWqhhY30Ei6FOkFYjOWVrJAwyDMiaAuL+NaSdb4xr
         3xSMQUZ6ZkQn7wLJOYcHEn0Cj3yMKupkzwG1uXa5/Qg/16xYtoh3uEu+Z0z8tlSrO3Rl
         2c96jFYy/zr1oQeWHnIzrgbwye3IUI0QHm9Tb073AuPv9b2uzSiX8+dunigwMxOnihPW
         Fhjyt5SiuT+lA+qYe/JdNnQVC2zFvKTQzQgg90eabkWy0T11wkp9nFEtUUPRM3fLWkSI
         DtPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=aqyxWDV4z/NfBALkGLkFQjG9dLo/Lmc07LaPnhV+YTw=;
        b=Nfj6veybpuzyV8HRn19OynSp5TbeIhMATVYlqHLQn4X0a4RlEGvO5ElZf8ovonY8uE
         4df/M5DciVjnhCDFXmG/qUdqu6F9zVLip5pK6YtaH5/GI6sI75JO2Fwvc0O6Xn0/Op2a
         hjk+v0l9Ln7iqXHoU9y51bzk8W1JlFgJv6VRyiZFGjNonmrp7x3UwrOEtoqo9VHLUnVq
         WdpRSL8wPBRnFPCYqyrTt3bCzShXH3CQhl9sI3Kk2od1o27tu/rzFo/UjLRerOp0fk9X
         RX2NS6DYsbN7s6ixZEEvh289rMDw2W8g1k4a0MJdX4Jiz+4PewfR9VgZDNqrE0AzhnW0
         AkLA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id bg10si2245465plb.160.2019.06.26.12.04.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 12:04:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Jun 2019 12:04:47 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,420,1557212400"; 
   d="scan'208";a="245528232"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga001.jf.intel.com with ESMTP; 26 Jun 2019 12:04:44 -0700
Date: Wed, 26 Jun 2019 12:04:46 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	linux-nvdimm@lists.01.org, linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, nouveau@lists.freedesktop.org
Subject: Re: [PATCH 11/25] memremap: lift the devmap_enable manipulation into
 devm_memremap_pages
Message-ID: <20190626190445.GE4605@iweiny-DESK2.sc.intel.com>
References: <20190626122724.13313-1-hch@lst.de>
 <20190626122724.13313-12-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190626122724.13313-12-hch@lst.de>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 26, 2019 at 02:27:10PM +0200, Christoph Hellwig wrote:
> Just check if there is a ->page_free operation set and take care of the
> static key enable, as well as the put using device managed resources.
> Also check that a ->page_free is provided for the pgmaps types that
> require it, and check for a valid type as well while we are at it.
> 
> Note that this also fixes the fact that hmm never called
> dev_pagemap_put_ops and thus would leave the slow path enabled forever,
> even after a device driver unload or disable.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  drivers/nvdimm/pmem.c | 23 +++--------------
>  include/linux/mm.h    | 10 --------
>  kernel/memremap.c     | 59 +++++++++++++++++++++++++++----------------
>  mm/hmm.c              |  2 --
>  4 files changed, 41 insertions(+), 53 deletions(-)
> 
> diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
> index 9dac48359353..48767171a4df 100644
> --- a/drivers/nvdimm/pmem.c
> +++ b/drivers/nvdimm/pmem.c
> @@ -334,11 +334,6 @@ static void pmem_release_disk(void *__pmem)
>  	put_disk(pmem->disk);
>  }
>  
> -static void pmem_release_pgmap_ops(void *__pgmap)
> -{
> -	dev_pagemap_put_ops();
> -}
> -
>  static void pmem_pagemap_page_free(struct page *page, void *data)
>  {
>  	wake_up_var(&page->_refcount);
> @@ -350,16 +345,6 @@ static const struct dev_pagemap_ops fsdax_pagemap_ops = {
>  	.cleanup		= pmem_pagemap_cleanup,
>  };
>  
> -static int setup_pagemap_fsdax(struct device *dev, struct dev_pagemap *pgmap)
> -{
> -	dev_pagemap_get_ops();
> -	if (devm_add_action_or_reset(dev, pmem_release_pgmap_ops, pgmap))
> -		return -ENOMEM;
> -	pgmap->type = MEMORY_DEVICE_FS_DAX;
> -	pgmap->ops = &fsdax_pagemap_ops;
> -	return 0;
> -}
> -
>  static int pmem_attach_disk(struct device *dev,
>  		struct nd_namespace_common *ndns)
>  {
> @@ -415,8 +400,8 @@ static int pmem_attach_disk(struct device *dev,
>  	pmem->pfn_flags = PFN_DEV;
>  	pmem->pgmap.ref = &q->q_usage_counter;
>  	if (is_nd_pfn(dev)) {
> -		if (setup_pagemap_fsdax(dev, &pmem->pgmap))
> -			return -ENOMEM;
> +		pmem->pgmap.type = MEMORY_DEVICE_FS_DAX;
> +		pmem->pgmap.ops = &fsdax_pagemap_ops;
>  		addr = devm_memremap_pages(dev, &pmem->pgmap);
>  		pfn_sb = nd_pfn->pfn_sb;
>  		pmem->data_offset = le64_to_cpu(pfn_sb->dataoff);
> @@ -428,8 +413,8 @@ static int pmem_attach_disk(struct device *dev,
>  	} else if (pmem_should_map_pages(dev)) {
>  		memcpy(&pmem->pgmap.res, &nsio->res, sizeof(pmem->pgmap.res));
>  		pmem->pgmap.altmap_valid = false;
> -		if (setup_pagemap_fsdax(dev, &pmem->pgmap))
> -			return -ENOMEM;
> +		pmem->pgmap.type = MEMORY_DEVICE_FS_DAX;
> +		pmem->pgmap.ops = &fsdax_pagemap_ops;
>  		addr = devm_memremap_pages(dev, &pmem->pgmap);
>  		pmem->pfn_flags |= PFN_MAP;
>  		memcpy(&bb_res, &pmem->pgmap.res, sizeof(bb_res));
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 6e4b9be08b13..aa3970291cdf 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -932,8 +932,6 @@ static inline bool is_zone_device_page(const struct page *page)
>  #endif
>  
>  #ifdef CONFIG_DEV_PAGEMAP_OPS
> -void dev_pagemap_get_ops(void);
> -void dev_pagemap_put_ops(void);
>  void __put_devmap_managed_page(struct page *page);
>  DECLARE_STATIC_KEY_FALSE(devmap_managed_key);
>  static inline bool put_devmap_managed_page(struct page *page)
> @@ -973,14 +971,6 @@ static inline bool is_pci_p2pdma_page(const struct page *page)
>  #endif /* CONFIG_PCI_P2PDMA */
>  
>  #else /* CONFIG_DEV_PAGEMAP_OPS */
> -static inline void dev_pagemap_get_ops(void)
> -{
> -}
> -
> -static inline void dev_pagemap_put_ops(void)
> -{
> -}
> -
>  static inline bool put_devmap_managed_page(struct page *page)
>  {
>  	return false;
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index 00c1ceb60c19..3219a4c91d07 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -17,6 +17,35 @@ static DEFINE_XARRAY(pgmap_array);
>  #define SECTION_MASK ~((1UL << PA_SECTION_SHIFT) - 1)
>  #define SECTION_SIZE (1UL << PA_SECTION_SHIFT)
>  
> +#ifdef CONFIG_DEV_PAGEMAP_OPS
> +DEFINE_STATIC_KEY_FALSE(devmap_managed_key);
> +EXPORT_SYMBOL(devmap_managed_key);
> +static atomic_t devmap_managed_enable;
> +
> +static void devmap_managed_enable_put(void *data)
> +{
> +	if (atomic_dec_and_test(&devmap_managed_enable))
> +		static_branch_disable(&devmap_managed_key);
> +}
> +
> +static int devmap_managed_enable_get(struct device *dev, struct dev_pagemap *pgmap)
> +{
> +	if (!pgmap->ops->page_free) {

NIT: later on you add the check for pgmap->ops...  it should probably be here.

But not sure that bisection will be an issue here.

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

> +		WARN(1, "Missing page_free method\n");
> +		return -EINVAL;
> +	}
> +
> +	if (atomic_inc_return(&devmap_managed_enable) == 1)
> +		static_branch_enable(&devmap_managed_key);
> +	return devm_add_action_or_reset(dev, devmap_managed_enable_put, NULL);
> +}
> +#else
> +static int devmap_managed_enable_get(struct device *dev, struct dev_pagemap *pgmap)
> +{
> +	return -EINVAL;
> +}
> +#endif /* CONFIG_DEV_PAGEMAP_OPS */
> +
>  #if IS_ENABLED(CONFIG_DEVICE_PRIVATE)
>  vm_fault_t device_private_entry_fault(struct vm_area_struct *vma,
>  		       unsigned long addr,
> @@ -156,6 +185,7 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
>  	};
>  	pgprot_t pgprot = PAGE_KERNEL;
>  	int error, nid, is_ram;
> +	bool need_devmap_managed = true;
>  
>  	switch (pgmap->type) {
>  	case MEMORY_DEVICE_PRIVATE:
> @@ -173,6 +203,7 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
>  		break;
>  	case MEMORY_DEVICE_DEVDAX:
>  	case MEMORY_DEVICE_PCI_P2PDMA:
> +		need_devmap_managed = false;
>  		break;
>  	default:
>  		WARN(1, "Invalid pgmap type %d\n", pgmap->type);
> @@ -185,6 +216,12 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
>  		return ERR_PTR(-EINVAL);
>  	}
>  
> +	if (need_devmap_managed) {
> +		error = devmap_managed_enable_get(dev, pgmap);
> +		if (error)
> +			return ERR_PTR(error);
> +	}
> +
>  	align_start = res->start & ~(SECTION_SIZE - 1);
>  	align_size = ALIGN(res->start + resource_size(res), SECTION_SIZE)
>  		- align_start;
> @@ -351,28 +388,6 @@ struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
>  EXPORT_SYMBOL_GPL(get_dev_pagemap);
>  
>  #ifdef CONFIG_DEV_PAGEMAP_OPS
> -DEFINE_STATIC_KEY_FALSE(devmap_managed_key);
> -EXPORT_SYMBOL(devmap_managed_key);
> -static atomic_t devmap_enable;
> -
> -/*
> - * Toggle the static key for ->page_free() callbacks when dev_pagemap
> - * pages go idle.
> - */
> -void dev_pagemap_get_ops(void)
> -{
> -	if (atomic_inc_return(&devmap_enable) == 1)
> -		static_branch_enable(&devmap_managed_key);
> -}
> -EXPORT_SYMBOL_GPL(dev_pagemap_get_ops);
> -
> -void dev_pagemap_put_ops(void)
> -{
> -	if (atomic_dec_and_test(&devmap_enable))
> -		static_branch_disable(&devmap_managed_key);
> -}
> -EXPORT_SYMBOL_GPL(dev_pagemap_put_ops);
> -
>  void __put_devmap_managed_page(struct page *page)
>  {
>  	int count = page_ref_dec_return(page);
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 987793fba923..5b0bd5f6a74f 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -1415,8 +1415,6 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
>  	void *result;
>  	int ret;
>  
> -	dev_pagemap_get_ops();
> -
>  	devmem = devm_kzalloc(device, sizeof(*devmem), GFP_KERNEL);
>  	if (!devmem)
>  		return ERR_PTR(-ENOMEM);
> -- 
> 2.20.1
> 
> _______________________________________________
> Linux-nvdimm mailing list
> Linux-nvdimm@lists.01.org
> https://lists.01.org/mailman/listinfo/linux-nvdimm

