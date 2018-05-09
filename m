Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 38F846B04E1
	for <linux-mm@kvack.org>; Wed,  9 May 2018 06:46:38 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id e74so4293049wmg.5
        for <linux-mm@kvack.org>; Wed, 09 May 2018 03:46:38 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x4-v6si618421edq.436.2018.05.09.03.46.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 09 May 2018 03:46:37 -0700 (PDT)
Date: Wed, 9 May 2018 12:46:35 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v9 5/9] mm: fix __gup_device_huge vs unmap
Message-ID: <20180509104635.57upe2fri7abqu7p@quack2.suse.cz>
References: <152461278149.17530.2867511144531572045.stgit@dwillia2-desk3.amr.corp.intel.com>
 <152461280975.17530.2817946409563456285.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152461280975.17530.2817946409563456285.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, stable@vger.kernel.org, Jan Kara <jack@suse.cz>, david@fromorbit.com, hch@lst.de, linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org

On Tue 24-04-18 16:33:29, Dan Williams wrote:
> get_user_pages_fast() for device pages is missing the typical validation
> that all page references have been taken while the mapping was valid.
> Without this validation truncate operations can not reliably coordinate
> against new page reference events like O_DIRECT.
> 
> Cc: <stable@vger.kernel.org>
> Fixes: 3565fce3a659 ("mm, x86: get_user_pages() for dax mappings")
> Reported-by: Jan Kara <jack@suse.cz>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

The patch looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza


> ---
>  mm/gup.c |   36 ++++++++++++++++++++++++++----------
>  1 file changed, 26 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index 76af4cfeaf68..84dd2063ca3d 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -1456,32 +1456,48 @@ static int __gup_device_huge(unsigned long pfn, unsigned long addr,
>  	return 1;
>  }
>  
> -static int __gup_device_huge_pmd(pmd_t pmd, unsigned long addr,
> +static int __gup_device_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
>  		unsigned long end, struct page **pages, int *nr)
>  {
>  	unsigned long fault_pfn;
> +	int nr_start = *nr;
> +
> +	fault_pfn = pmd_pfn(orig) + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
> +	if (!__gup_device_huge(fault_pfn, addr, end, pages, nr))
> +		return 0;
>  
> -	fault_pfn = pmd_pfn(pmd) + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
> -	return __gup_device_huge(fault_pfn, addr, end, pages, nr);
> +	if (unlikely(pmd_val(orig) != pmd_val(*pmdp))) {
> +		undo_dev_pagemap(nr, nr_start, pages);
> +		return 0;
> +	}
> +	return 1;
>  }
>  
> -static int __gup_device_huge_pud(pud_t pud, unsigned long addr,
> +static int __gup_device_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
>  		unsigned long end, struct page **pages, int *nr)
>  {
>  	unsigned long fault_pfn;
> +	int nr_start = *nr;
> +
> +	fault_pfn = pud_pfn(orig) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
> +	if (!__gup_device_huge(fault_pfn, addr, end, pages, nr))
> +		return 0;
>  
> -	fault_pfn = pud_pfn(pud) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
> -	return __gup_device_huge(fault_pfn, addr, end, pages, nr);
> +	if (unlikely(pud_val(orig) != pud_val(*pudp))) {
> +		undo_dev_pagemap(nr, nr_start, pages);
> +		return 0;
> +	}
> +	return 1;
>  }
>  #else
> -static int __gup_device_huge_pmd(pmd_t pmd, unsigned long addr,
> +static int __gup_device_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
>  		unsigned long end, struct page **pages, int *nr)
>  {
>  	BUILD_BUG();
>  	return 0;
>  }
>  
> -static int __gup_device_huge_pud(pud_t pud, unsigned long addr,
> +static int __gup_device_huge_pud(pud_t pud, pud_t *pudp, unsigned long addr,
>  		unsigned long end, struct page **pages, int *nr)
>  {
>  	BUILD_BUG();
> @@ -1499,7 +1515,7 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
>  		return 0;
>  
>  	if (pmd_devmap(orig))
> -		return __gup_device_huge_pmd(orig, addr, end, pages, nr);
> +		return __gup_device_huge_pmd(orig, pmdp, addr, end, pages, nr);
>  
>  	refs = 0;
>  	page = pmd_page(orig) + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
> @@ -1537,7 +1553,7 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
>  		return 0;
>  
>  	if (pud_devmap(orig))
> -		return __gup_device_huge_pud(orig, addr, end, pages, nr);
> +		return __gup_device_huge_pud(orig, pudp, addr, end, pages, nr);
>  
>  	refs = 0;
>  	page = pud_page(orig) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
