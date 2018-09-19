Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0D1698E0001
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 22:48:05 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id w126-v6so2823309qka.11
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 19:48:05 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r13-v6si3575438qtm.243.2018.09.18.19.48.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Sep 2018 19:48:04 -0700 (PDT)
Date: Tue, 18 Sep 2018 22:48:02 -0400 (EDT)
From: Pankaj Gupta <pagupta@redhat.com>
Message-ID: <373427884.13987814.1537325282516.JavaMail.zimbra@redhat.com>
In-Reply-To: <044309496afbb4121447dff6a453bd6b96d6068d.1534934405.git.yi.z.zhang@linux.intel.com>
References: <cover.1534934405.git.yi.z.zhang@linux.intel.com> <044309496afbb4121447dff6a453bd6b96d6068d.1534934405.git.yi.z.zhang@linux.intel.com>
Subject: Re: [PATCH V4 3/4] mm: add a function to differentiate the pages is
 from DAX device memory
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yi <yi.z.zhang@linux.intel.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pbonzini@redhat.com, dan j williams <dan.j.williams@intel.com>, dave jiang <dave.jiang@intel.com>, yu c zhang <yu.c.zhang@intel.com>, david@redhat.com, jack@suse.cz, hch@lst.de, linux-mm@kvack.org, rkrcmar@redhat.com, jglisse@redhat.com, yi z zhang <yi.z.zhang@intel.com>


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
> Acked-by: Jan Kara <jack@suse.cz>
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

Reviewed-by: Pankaj Gupta <pagupta@redhat.com>

> 2.7.4
> 
> 
