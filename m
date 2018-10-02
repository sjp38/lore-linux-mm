Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id E2DD46B0003
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 07:26:27 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id c4-v6so1564791plz.20
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 04:26:27 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id u1-v6si15909308plb.291.2018.10.02.04.26.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 04:26:26 -0700 (PDT)
Date: Tue, 2 Oct 2018 14:26:23 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv3 6/6] mm/gup: Cache dev_pagemap while pinning pages
Message-ID: <20181002112623.zlxtcclhtslfx3pa@black.fi.intel.com>
References: <20180921223956.3485-1-keith.busch@intel.com>
 <20180921223956.3485-7-keith.busch@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180921223956.3485-7-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Fri, Sep 21, 2018 at 10:39:56PM +0000, Keith Busch wrote:
> Pinning pages from ZONE_DEVICE memory needs to check the backing device's
> live-ness, which is tracked in the device's dev_pagemap metadata. This
> metadata is stored in a radix tree and looking it up adds measurable
> software overhead.
> 
> This patch avoids repeating this relatively costly operation when
> dev_pagemap is used by caching the last dev_pagemap when getting user
> pages. The gup_benchmark reports this reduces the time to get user pages
> to as low as 1/3 of the previous time.
> 
> The cached value is combined with other output parameters into a context
> struct to keep the parameters fewer.
> 
> Cc: Kirill Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Signed-off-by: Keith Busch <keith.busch@intel.com>
> ---

....

> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index a61ebe8ad4ca..79c80496dd50 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2534,15 +2534,28 @@ static inline vm_fault_t vmf_error(int err)
>  	return VM_FAULT_SIGBUS;
>  }
>  
> +struct follow_page_context {
> +	struct dev_pagemap *pgmap;
> +	unsigned int page_mask;
> +};
> +
>  struct page *follow_page_mask(struct vm_area_struct *vma,
>  			      unsigned long address, unsigned int foll_flags,
> -			      unsigned int *page_mask);
> +			      struct follow_page_context *ctx);
>  
>  static inline struct page *follow_page(struct vm_area_struct *vma,
>  		unsigned long address, unsigned int foll_flags)
>  {
> -	unsigned int unused_page_mask;
> -	return follow_page_mask(vma, address, foll_flags, &unused_page_mask);
> +	struct page *page;
> +	struct follow_page_context ctx = {
> +		.pgmap = NULL,
> +		.page_mask = 0,
> +	};
> +
> +	page = follow_page_mask(vma, address, foll_flags, &ctx);
> +	if (ctx.pgmap)
> +		put_dev_pagemap(ctx.pgmap);
> +	return page;
>  }

Do we still want to keep the function as inline? I don't think so.
Let's move it into mm/gup.c and make struct follow_page_context private to
the file.

>  
>  #define FOLL_WRITE	0x01	/* check pte is writable */
> diff --git a/mm/gup.c b/mm/gup.c
> index 1abc8b4afff6..124e7293e381 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -71,10 +71,10 @@ static inline bool can_follow_write_pte(pte_t pte, unsigned int flags)
>  }
>  
>  static struct page *follow_page_pte(struct vm_area_struct *vma,
> -		unsigned long address, pmd_t *pmd, unsigned int flags)
> +		unsigned long address, pmd_t *pmd, unsigned int flags,
> +		struct dev_pagemap **pgmap)
>  {
>  	struct mm_struct *mm = vma->vm_mm;
> -	struct dev_pagemap *pgmap = NULL;
>  	struct page *page;
>  	spinlock_t *ptl;
>  	pte_t *ptep, pte;
> @@ -116,8 +116,8 @@ static struct page *follow_page_pte(struct vm_area_struct *vma,
>  		 * Only return device mapping pages in the FOLL_GET case since
>  		 * they are only valid while holding the pgmap reference.
>  		 */
> -		pgmap = get_dev_pagemap(pte_pfn(pte), NULL);
> -		if (pgmap)
> +		*pgmap = get_dev_pagemap(pte_pfn(pte), *pgmap);
> +		if (*pgmap)
>  			page = pte_page(pte);
>  		else
>  			goto no_page;

Hm. Shouldn't get_dev_pagemap() call be under if (!*pgmap)?

... ah, never mind. I've got confused by get_dev_pagemap() interface.

>  static bool vma_permits_fault(struct vm_area_struct *vma,
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 533f9b00147d..9839bf91b057 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -851,13 +851,23 @@ static void touch_pmd(struct vm_area_struct *vma, unsigned long addr,
>  		update_mmu_cache_pmd(vma, addr, pmd);
>  }
>  
> +static struct page *pagemap_page(unsigned long pfn, struct dev_pagemap **pgmap)

The function name doesn't reflect the fact that it takes pin on the page.
Maybe pagemap_get_page()?

> +{
> +	struct page *page;
> +
> +	*pgmap = get_dev_pagemap(pfn, *pgmap);
> +	if (!*pgmap)
> +		return ERR_PTR(-EFAULT);
> +	page = pfn_to_page(pfn);
> +	get_page(page);
> +	return page;
> +}
> +

-- 
 Kirill A. Shutemov
