Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 426A46B0003
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 05:11:24 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d5-v6so5166066edq.3
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 02:11:24 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w43-v6si1167506edc.207.2018.08.07.02.11.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 02:11:22 -0700 (PDT)
Date: Tue, 7 Aug 2018 11:11:20 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH V2 2/4] mm: introduce memory type MEMORY_DEVICE_DEV_DAX
Message-ID: <20180807091120.ybne44o2fy2mxcch@quack2.suse.cz>
References: <cover.1531241281.git.yi.z.zhang@linux.intel.com>
 <7e20d862f96662e1a7736dbb747a71949933dcd4.1531241281.git.yi.z.zhang@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7e20d862f96662e1a7736dbb747a71949933dcd4.1531241281.git.yi.z.zhang@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yi <yi.z.zhang@linux.intel.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pbonzini@redhat.com, dan.j.williams@intel.com, jack@suse.cz, hch@lst.de, yu.c.zhang@intel.com, linux-mm@kvack.org, rkrcmar@redhat.com, yi.z.zhang@intel.com

On Wed 11-07-18 01:01:59, Zhang Yi wrote:
> Currently, NVDIMM pages will be marked 'PageReserved'. However, unlike
> other reserved PFNs, pages on NVDIMM shall still behave like normal ones
> in many cases, i.e. when used as backend memory of KVM guest. This patch
> introduces a new memory type, MEMORY_DEVICE_DEV_DAX. And set this flag
> while dax driver hotplug the device memory.
> 
> Signed-off-by: Zhang Yi <yi.z.zhang@linux.intel.com>
> Signed-off-by: Zhang Yu <yu.c.zhang@linux.intel.com>
> ---
>  drivers/dax/pmem.c       | 1 +
>  include/linux/memremap.h | 9 +++++++++
>  2 files changed, 10 insertions(+)
> 
> diff --git a/drivers/dax/pmem.c b/drivers/dax/pmem.c
> index fd49b24..fb3f363 100644
> --- a/drivers/dax/pmem.c
> +++ b/drivers/dax/pmem.c
> @@ -111,6 +111,7 @@ static int dax_pmem_probe(struct device *dev)
>  		return rc;
>  
>  	dax_pmem->pgmap.ref = &dax_pmem->ref;
> +	dax_pmem->pgmap.type = MEMORY_DEVICE_DEV_DAX;
>  	addr = devm_memremap_pages(dev, &dax_pmem->pgmap);
>  	if (IS_ERR(addr))
>  		return PTR_ERR(addr);
> diff --git a/include/linux/memremap.h b/include/linux/memremap.h
> index 5ebfff6..a36bce8 100644
> --- a/include/linux/memremap.h
> +++ b/include/linux/memremap.h
> @@ -53,11 +53,20 @@ struct vmem_altmap {
>   * wakeup event whenever a page is unpinned and becomes idle. This
>   * wakeup is used to coordinate physical address space management (ex:
>   * fs truncate/hole punch) vs pinned pages (ex: device dma).
> + *
> + * MEMORY_DEVICE_DEV_DAX:
> + * DAX driver hotplug the device memory and move it to memory zone, these
> + * pages will be marked reserved flag. However, some other kernel componet
> + * will misconceive these pages are reserved mmio (ex: we map these dev_dax
> + * or fs_dax pages to kvm for DIMM/NVDIMM backend). Together with the type
> + * MEMORY_DEVICE_FS_DAX, we can differentiate the pages on NVDIMM with the
> + * normal reserved pages.

So I believe the description should be in terms of what kind of memory is
the MEMORY_DEVICE_DEV_DAX type, not how users use this type. See comments
for other memory types...

								Honza

>   */
>  enum memory_type {
>  	MEMORY_DEVICE_PRIVATE = 1,
>  	MEMORY_DEVICE_PUBLIC,
>  	MEMORY_DEVICE_FS_DAX,
> +	MEMORY_DEVICE_DEV_DAX,
>  };
>  
>  /*
> -- 
> 2.7.4
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
