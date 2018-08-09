Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 773756B0007
	for <linux-mm@kvack.org>; Thu,  9 Aug 2018 04:59:42 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c2-v6so1866676edi.20
        for <linux-mm@kvack.org>; Thu, 09 Aug 2018 01:59:42 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e46-v6si618745edd.173.2018.08.09.01.59.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Aug 2018 01:59:41 -0700 (PDT)
Date: Thu, 9 Aug 2018 10:59:40 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH V3 2/4] mm: introduce memory type MEMORY_DEVICE_DEV_DAX
Message-ID: <20180809085940.GC5069@quack2.suse.cz>
References: <cover.1533811181.git.yi.z.zhang@linux.intel.com>
 <01aaca83694c3b0093fcb2f48af1dff0b147a4b2.1533811181.git.yi.z.zhang@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01aaca83694c3b0093fcb2f48af1dff0b147a4b2.1533811181.git.yi.z.zhang@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yi <yi.z.zhang@linux.intel.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pbonzini@redhat.com, dan.j.williams@intel.com, jack@suse.cz, hch@lst.de, yu.c.zhang@intel.com, linux-mm@kvack.org, rkrcmar@redhat.com, yi.z.zhang@intel.com

On Thu 09-08-18 18:53:08, Zhang Yi wrote:
> Currently, NVDIMM pages will be marked 'PageReserved'. However, unlike
> other reserved PFNs, pages on NVDIMM shall still behave like normal ones
> in many cases, i.e. when used as backend memory of KVM guest. This patch
> introduces a new memory type, MEMORY_DEVICE_DEV_DAX. And set this flag
> while dax driver hotplug the device memory.
> 
> Signed-off-by: Zhang Yi <yi.z.zhang@linux.intel.com>
> Signed-off-by: Zhang Yu <yu.c.zhang@linux.intel.com>

Looks good to me now. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  drivers/dax/pmem.c       | 1 +
>  include/linux/memremap.h | 8 ++++++++
>  2 files changed, 9 insertions(+)
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
> index f91f9e7..cd07ca8 100644
> --- a/include/linux/memremap.h
> +++ b/include/linux/memremap.h
> @@ -53,11 +53,19 @@ struct vmem_altmap {
>   * wakeup event whenever a page is unpinned and becomes idle. This
>   * wakeup is used to coordinate physical address space management (ex:
>   * fs truncate/hole punch) vs pinned pages (ex: device dma).
> + *
> + * MEMORY_DEVICE_DEV_DAX:
> + * Device memory that support raw access to persistent memory. Without need
> + * of an intervening filesystem, it could be directed mapped via an mmap
> + * capable character device. Together with the type MEMORY_DEVICE_FS_DAX,
> + * we could distinguish the persistent memory pages from normal ZONE_DEVICE
> + * pages.
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
