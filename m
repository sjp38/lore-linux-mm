Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 534176B0007
	for <linux-mm@kvack.org>; Thu,  9 Aug 2018 05:23:30 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id u68-v6so5155138qku.5
        for <linux-mm@kvack.org>; Thu, 09 Aug 2018 02:23:30 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r2-v6si2876544qkd.14.2018.08.09.02.23.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Aug 2018 02:23:29 -0700 (PDT)
Date: Thu, 9 Aug 2018 05:23:28 -0400 (EDT)
From: Pankaj Gupta <pagupta@redhat.com>
Message-ID: <872818364.892078.1533806608252.JavaMail.zimbra@redhat.com>
In-Reply-To: <2b7856596e519130946c834d5d61b00b7f592770.1533811181.git.yi.z.zhang@linux.intel.com>
References: <cover.1533811181.git.yi.z.zhang@linux.intel.com> <2b7856596e519130946c834d5d61b00b7f592770.1533811181.git.yi.z.zhang@linux.intel.com>
Subject: Re: [PATCH V3 3/4] mm: add a function to differentiate the pages is
 from DAX device memory
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yi <yi.z.zhang@linux.intel.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pbonzini@redhat.com, dan j williams <dan.j.williams@intel.com>, jack@suse.cz, hch@lst.de, yu c zhang <yu.c.zhang@intel.com>, linux-mm@kvack.org, rkrcmar@redhat.com, yi z zhang <yi.z.zhang@intel.com>


> 
> DAX driver hotplug the device memory and move it to memory zone, these
> pages will be marked reserved flag, however, some other kernel componet
> will misconceive these pages are reserved mmio (ex: we map these dev_dax
> or fs_dax pages to kvm for DIMM/NVDIMM backend). Together with the type
> MEMORY_DEVICE_FS_DAX, we can use is_dax_page() to differentiate the pages
> is DAX device memory or not.
> 
> Signed-off-by: Zhang Yi <yi.z.zhang@linux.intel.com>
> Signed-off-by: Zhang Yu <yu.c.zhang@linux.intel.com>
> ---
>  include/linux/mm.h | 12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 68a5121..de5cbc3 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -889,6 +889,13 @@ static inline bool is_device_public_page(const struct
> page *page)
>  		page->pgmap->type == MEMORY_DEVICE_PUBLIC;
>  }
>  
> +static inline bool is_dax_page(const struct page *page)
> +{
> +	return is_zone_device_page(page) &&
> +		(page->pgmap->type == MEMORY_DEVICE_FS_DAX ||
> +		page->pgmap->type == MEMORY_DEVICE_DEV_DAX);
> +}

I think question from Dan for KVM VM with 'MEMORY_DEVICE_PUBLIC' still holds?
I am also interested to know if there is any use-case.

Thanks,
Pankaj

> +
>  #else /* CONFIG_DEV_PAGEMAP_OPS */
>  static inline void dev_pagemap_get_ops(void)
>  {
> @@ -912,6 +919,11 @@ static inline bool is_device_public_page(const struct
> page *page)
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
> 
