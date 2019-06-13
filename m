Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3BEDC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 23:42:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 883A121721
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 23:42:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="K8AKe6go"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 883A121721
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06E2D6B000E; Thu, 13 Jun 2019 19:42:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F3A338E0002; Thu, 13 Jun 2019 19:42:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E015A6B026A; Thu, 13 Jun 2019 19:42:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id B78746B000E
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 19:42:10 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id i136so618906ywe.23
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 16:42:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=wLsE+X+8pitibNp+2XhoFt2Wacvnxu1fblPm1H5d/6Q=;
        b=H5Jcz89iQOgIStVYhgzQXegCezCoucHju+YcM1zSWTLKS4BhINIATGR7OvuhZLvoqF
         FXmJMOeknSl4//7NMkQXUu+e4TGiPGMHSoj78caqPvBt6ZlA4hNu0BAZAeCMxzWMVqef
         2DeMPypNCha5V8ROAILMchebCMq+rJ9Qadv9t9NEMFCKx7pt1lu00uMw4puuKrDMwtwv
         iLwE9aALPuqG13GzMjWfofCHlfd7ASY3zu6MOh8qjUeRNn+to+/BdWKowc/1ElJHuXMW
         9+qss05fEsmjM5POjqzeMGUigIXRuwAKt1bTjg6LGn1FJ/A3IZ0f/Lbs4yvDc2Tq1fDp
         uyhQ==
X-Gm-Message-State: APjAAAU1Q7jiE42qWHydQtIK9jvi2JDbCV9RA4Ygka0SCI6ksGxvV47S
	0lpxC51ScVba+Z/MryTpfm7X/xXKf0/n90XoFv/uPo7VCbdj1zomUbPt27W7zyk42NHV7ga2Msw
	0oTSfvyzXUoDUDTl6J0jPrw1+jacSCIZN3nyFaQzGRovqLL/upxjP9hEh6ViGyBUG8A==
X-Received: by 2002:a81:3dc8:: with SMTP id k191mr47832396ywa.383.1560469330436;
        Thu, 13 Jun 2019 16:42:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyN8SL67sIg0TL4hz+anTWrvHAR9gjo7U0aDINYwk8m0rwuLdnq38/c5E4wSNKvswJ32MwN
X-Received: by 2002:a81:3dc8:: with SMTP id k191mr47832370ywa.383.1560469329659;
        Thu, 13 Jun 2019 16:42:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560469329; cv=none;
        d=google.com; s=arc-20160816;
        b=klMTrrb9g+B6JdXmJa/xXcZo1ZpDnocsQP1LwveSR2MDyRGeTTVMiufqjWtPTatenX
         ZZrcDNqD6+55+iEOwbqgdnLovPnuLP8XUpLDPqZ3N5XWT2HOMfwhmne/TW2SfzWxA9Yf
         58fM3xJslfQa5xeTgT11G23pmmlKrpRpMOSzCmqM4xoBwouMzrncXjdUfPhUnFGNwTJg
         GUu1V9h4L1i6bQT9IowH6LJqEz0tFQvWkEtrW2a67h33abXbyrwpI9hy2EtgNxxXmNHa
         vZXmYJgGnT/jmWlNRwNylj/aVapwytB3jFptu2191FBs7BZyZEfWnTKLdNff5/NMUkd3
         oP5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=wLsE+X+8pitibNp+2XhoFt2Wacvnxu1fblPm1H5d/6Q=;
        b=BntUH7R2BwGhrRLRHKnBRSL2WkMdkdK1m9RnbyfBCoI9ZlRnKPx4rqaqQtf3VvaDmT
         gPwBsLSFeIECcJ0fEpz2mV75tKdZPR65+LP9NZcPuJwX1eOgGXCVXWORMBjaGgXKc0Bp
         K2dlQvrKDApbZ/wkA5J4dIngG/ONxNSD8nVz03IpKM07QAbju4ucgCL9aAjv5Mfyj0nk
         y/aOvHY1CceD3olaFImwYL0CNIbHrCrfl+GW1IsahKbWTT/rrQ92BwT8IrUuPKZBY1/A
         p32j/9xPqXIFZMDGQF7tJ/K4GbHnYxXEgu/4/D503AHa6z9DOgy7usqyJ3C+ewNU26Gn
         HDHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=K8AKe6go;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id f184si461419ywa.396.2019.06.13.16.42.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 16:42:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=K8AKe6go;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d02df510000>; Thu, 13 Jun 2019 16:42:09 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 13 Jun 2019 16:42:08 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 13 Jun 2019 16:42:08 -0700
Received: from rcampbell-dev.nvidia.com (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 13 Jun
 2019 23:42:07 +0000
Subject: Re: [PATCH 10/22] memremap: add a migrate callback to struct
 dev_pagemap_ops
To: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Jason Gunthorpe
	<jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>
CC: <linux-mm@kvack.org>, <nouveau@lists.freedesktop.org>,
	<dri-devel@lists.freedesktop.org>, <linux-nvdimm@lists.01.org>,
	<linux-pci@vger.kernel.org>, <linux-kernel@vger.kernel.org>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-11-hch@lst.de>
From: Ralph Campbell <rcampbell@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <d6916d71-c17e-74df-58f2-c28ff8044b96@nvidia.com>
Date: Thu, 13 Jun 2019 16:42:07 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190613094326.24093-11-hch@lst.de>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL106.nvidia.com (172.18.146.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1560469329; bh=wLsE+X+8pitibNp+2XhoFt2Wacvnxu1fblPm1H5d/6Q=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=K8AKe6gofAssIF+PWoIuTwl4fCkUwuiOvHNEsvPI3F+q8VQ4+xJWpP84RWIp2f3Mv
	 vM/f8XrfvgL48kTe0DZDz8uLahwVWJVbReUsFLpkhihuCalW2d/Eak3R/rD5QepCm4
	 eAT3qIqhtKZ2iV0oC5E3+YcnsBUSSuqGl8OksAsK+CDDOD/NG+NwGm+eY+JOt6cn/K
	 1DJbYLIbG5TYSbhI0/IpkyhPXQDxOnDF3mu4S/a9zHc+FirnrIJnjHhjESGPnAKzt5
	 I3iL8In6P9r99xdo7wZmjVCtpSHnz1ZXoerU/wDDEdlFepU5Wsr2g9IVOwPBRrjw/t
	 DyeF5Z2L4YXLg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 6/13/19 2:43 AM, Christoph Hellwig wrote:
> This replaces the hacky ->fault callback, which is currently directly
> called from common code through a hmm specific data structure as an
> exercise in layering violations.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>   include/linux/hmm.h      |  6 ------
>   include/linux/memremap.h |  6 ++++++
>   include/linux/swapops.h  | 15 ---------------
>   kernel/memremap.c        | 31 -------------------------------
>   mm/hmm.c                 | 13 +++++--------
>   mm/memory.c              |  9 ++-------
>   6 files changed, 13 insertions(+), 67 deletions(-)
> 
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 5761a39221a6..3c9a59dbfdb8 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -658,11 +658,6 @@ struct hmm_devmem_ops {
>    * chunk, as an optimization. It must, however, prioritize the faulting address
>    * over all the others.
>    */
> -typedef vm_fault_t (*dev_page_fault_t)(struct vm_area_struct *vma,
> -				unsigned long addr,
> -				const struct page *page,
> -				unsigned int flags,
> -				pmd_t *pmdp);
>   
>   struct hmm_devmem {
>   	struct completion		completion;
> @@ -673,7 +668,6 @@ struct hmm_devmem {
>   	struct dev_pagemap		pagemap;
>   	const struct hmm_devmem_ops	*ops;
>   	struct percpu_ref		ref;
> -	dev_page_fault_t		page_fault;
>   };
>   
>   /*
> diff --git a/include/linux/memremap.h b/include/linux/memremap.h
> index 96a3a6d564ad..03a4099be701 100644
> --- a/include/linux/memremap.h
> +++ b/include/linux/memremap.h
> @@ -75,6 +75,12 @@ struct dev_pagemap_ops {
>   	 * Transition the percpu_ref in struct dev_pagemap to the dead state.
>   	 */
>   	void (*kill)(struct dev_pagemap *pgmap);
> +
> +	/*
> +	 * Used for private (un-addressable) device memory only.  Must migrate
> +	 * the page back to a CPU accessible page.
> +	 */
> +	vm_fault_t (*migrate)(struct vm_fault *vmf);
>   };
>   
>   /**
> diff --git a/include/linux/swapops.h b/include/linux/swapops.h
> index 4d961668e5fc..15bdb6fe71e5 100644
> --- a/include/linux/swapops.h
> +++ b/include/linux/swapops.h
> @@ -129,12 +129,6 @@ static inline struct page *device_private_entry_to_page(swp_entry_t entry)
>   {
>   	return pfn_to_page(swp_offset(entry));
>   }
> -
> -vm_fault_t device_private_entry_fault(struct vm_area_struct *vma,
> -		       unsigned long addr,
> -		       swp_entry_t entry,
> -		       unsigned int flags,
> -		       pmd_t *pmdp);
>   #else /* CONFIG_DEVICE_PRIVATE */
>   static inline swp_entry_t make_device_private_entry(struct page *page, bool write)
>   {
> @@ -164,15 +158,6 @@ static inline struct page *device_private_entry_to_page(swp_entry_t entry)
>   {
>   	return NULL;
>   }
> -
> -static inline vm_fault_t device_private_entry_fault(struct vm_area_struct *vma,
> -				     unsigned long addr,
> -				     swp_entry_t entry,
> -				     unsigned int flags,
> -				     pmd_t *pmdp)
> -{
> -	return VM_FAULT_SIGBUS;
> -}
>   #endif /* CONFIG_DEVICE_PRIVATE */
>   
>   #ifdef CONFIG_MIGRATION
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index 6a3183cac764..7167e717647d 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -11,7 +11,6 @@
>   #include <linux/types.h>
>   #include <linux/wait_bit.h>
>   #include <linux/xarray.h>
> -#include <linux/hmm.h>
>   
>   static DEFINE_XARRAY(pgmap_array);
>   #define SECTION_MASK ~((1UL << PA_SECTION_SHIFT) - 1)
> @@ -48,36 +47,6 @@ static inline int dev_pagemap_enable(struct device *dev)
>   }
>   #endif /* CONFIG_DEV_PAGEMAP_OPS */
>   
> -#if IS_ENABLED(CONFIG_DEVICE_PRIVATE)
> -vm_fault_t device_private_entry_fault(struct vm_area_struct *vma,
> -		       unsigned long addr,
> -		       swp_entry_t entry,
> -		       unsigned int flags,
> -		       pmd_t *pmdp)
> -{
> -	struct page *page = device_private_entry_to_page(entry);
> -	struct hmm_devmem *devmem;
> -
> -	devmem = container_of(page->pgmap, typeof(*devmem), pagemap);
> -
> -	/*
> -	 * The page_fault() callback must migrate page back to system memory
> -	 * so that CPU can access it. This might fail for various reasons
> -	 * (device issue, device was unsafely unplugged, ...). When such
> -	 * error conditions happen, the callback must return VM_FAULT_SIGBUS.
> -	 *
> -	 * Note that because memory cgroup charges are accounted to the device
> -	 * memory, this should never fail because of memory restrictions (but
> -	 * allocation of regular system page might still fail because we are
> -	 * out of memory).
> -	 *
> -	 * There is a more in-depth description of what that callback can and
> -	 * cannot do, in include/linux/memremap.h
> -	 */
> -	return devmem->page_fault(vma, addr, page, flags, pmdp);
> -}
> -#endif /* CONFIG_DEVICE_PRIVATE */
> -
>   static void pgmap_array_delete(struct resource *res)
>   {
>   	xa_store_range(&pgmap_array, PHYS_PFN(res->start), PHYS_PFN(res->end),
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 6dc769feb2e1..aab799677c7d 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -1330,15 +1330,12 @@ static void hmm_devmem_ref_kill(struct dev_pagemap *pgmap)
>   	percpu_ref_kill(pgmap->ref);
>   }
>   
> -static vm_fault_t hmm_devmem_fault(struct vm_area_struct *vma,
> -			    unsigned long addr,
> -			    const struct page *page,
> -			    unsigned int flags,
> -			    pmd_t *pmdp)
> +static vm_fault_t hmm_devmem_migrate(struct vm_fault *vmf)
>   {
> -	struct hmm_devmem *devmem = page->pgmap->data;
> +	struct hmm_devmem *devmem = vmf->page->pgmap->data;
>   
> -	return devmem->ops->fault(devmem, vma, addr, page, flags, pmdp);
> +	return devmem->ops->fault(devmem, vmf->vma, vmf->address, vmf->page,
> +			vmf->flags, vmf->pmd);
>   }
>   
>   static void hmm_devmem_free(struct page *page, void *data)
> @@ -1351,6 +1348,7 @@ static void hmm_devmem_free(struct page *page, void *data)
>   static const struct dev_pagemap_ops hmm_pagemap_ops = {
>   	.page_free		= hmm_devmem_free,
>   	.kill			= hmm_devmem_ref_kill,
> +	.migrate		= hmm_devmem_migrate,
>   };
>   
>   /*
> @@ -1405,7 +1403,6 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
>   	devmem->pfn_first = devmem->resource->start >> PAGE_SHIFT;
>   	devmem->pfn_last = devmem->pfn_first +
>   			   (resource_size(devmem->resource) >> PAGE_SHIFT);
> -	devmem->page_fault = hmm_devmem_fault;
>   
>   	devmem->pagemap.type = MEMORY_DEVICE_PRIVATE;
>   	devmem->pagemap.res = *devmem->resource;
> diff --git a/mm/memory.c b/mm/memory.c
> index ddf20bd0c317..cbf3cb598436 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2782,13 +2782,8 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
>   			migration_entry_wait(vma->vm_mm, vmf->pmd,
>   					     vmf->address);
>   		} else if (is_device_private_entry(entry)) {
> -			/*
> -			 * For un-addressable device memory we call the pgmap
> -			 * fault handler callback. The callback must migrate
> -			 * the page back to some CPU accessible page.
> -			 */
> -			ret = device_private_entry_fault(vma, vmf->address, entry,
> -						 vmf->flags, vmf->pmd);
> +			vmf->page = device_private_entry_to_page(entry);
> +			ret = page->pgmap->ops->migrate(vmf);

This needs to either initialize "page" or be changed to "vmf->page".
Otherwise, it is a NULL pointer dereference.

>   		} else if (is_hwpoison_entry(entry)) {
>   			ret = VM_FAULT_HWPOISON;
>   		} else {
> 

You can add:
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

