Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E878E6B0006
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 05:13:59 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id z20-v6so5163942edq.10
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 02:13:59 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l57-v6si1133660eda.313.2018.08.07.02.13.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 02:13:58 -0700 (PDT)
Date: Tue, 7 Aug 2018 11:13:57 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH V2 3/4] mm: add a function to differentiate the pages is
 from DAX device memory
Message-ID: <20180807091357.zxanrttlp3ml7mq2@quack2.suse.cz>
References: <cover.1531241281.git.yi.z.zhang@linux.intel.com>
 <a0d220839ce0414f13e9394dffcd9abe8689dafe.1531241281.git.yi.z.zhang@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a0d220839ce0414f13e9394dffcd9abe8689dafe.1531241281.git.yi.z.zhang@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yi <yi.z.zhang@linux.intel.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pbonzini@redhat.com, dan.j.williams@intel.com, jack@suse.cz, hch@lst.de, yu.c.zhang@intel.com, linux-mm@kvack.org, rkrcmar@redhat.com, yi.z.zhang@intel.com

On Wed 11-07-18 01:03:51, Zhang Yi wrote:
> DAX driver hotplug the device memory and move it to memory zone, these
> pages will be marked reserved flag, however, some other kernel componet
> will misconceive these pages are reserved mmio (ex: we map these dev_dax
> or fs_dax pages to kvm for DIMM/NVDIMM backend). Together with the type
> MEMORY_DEVICE_FS_DAX, we can use is_dax_page() to differentiate the pages
> is DAX device memory or not.
> 
> Signed-off-by: Zhang Yi <yi.z.zhang@linux.intel.com>
> Signed-off-by: Zhang Yu <yu.c.zhang@linux.intel.com>

The patch looks OK to me but I don't really feel too confident about this
part of the kernel... But feel free to add my:

Acked-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  include/linux/mm.h | 12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 6e19265..9f0f690 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -856,6 +856,13 @@ static inline bool is_device_public_page(const struct page *page)
>  		page->pgmap->type == MEMORY_DEVICE_PUBLIC;
>  }
>  
> +static inline bool is_dax_page(const struct page *page)
> +{
> +	return is_zone_device_page(page) &&
> +		(page->pgmap->type == MEMORY_DEVICE_FS_DAX ||
> +		page->pgmap->type == MEMORY_DEVICE_DEV_DAX);
> +}
> +
>  #else /* CONFIG_DEV_PAGEMAP_OPS */
>  static inline void dev_pagemap_get_ops(void)
>  {
> @@ -879,6 +886,11 @@ static inline bool is_device_public_page(const struct page *page)
>  {
>  	return false;
>  }
> +
> +static inline bool is_dax_page(const struct page *page)
> +{
> +	return false;
> +}
>  #endif /* CONFIG_DEV_PAGEMAP_OPS */
>  
>  static inline void get_page(struct page *page)
> -- 
> 2.7.4
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
