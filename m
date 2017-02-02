Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 616C56B0253
	for <linux-mm@kvack.org>; Thu,  2 Feb 2017 10:26:59 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id gt1so4976952wjc.0
        for <linux-mm@kvack.org>; Thu, 02 Feb 2017 07:26:59 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k126si2532175wmb.73.2017.02.02.07.26.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Feb 2017 07:26:57 -0800 (PST)
Date: Thu, 2 Feb 2017 16:26:56 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCHv3 03/12] mm: fix handling PTE-mapped THPs in
 page_referenced()
Message-ID: <20170202152655.GB22823@dhcp22.suse.cz>
References: <20170129173858.45174-1-kirill.shutemov@linux.intel.com>
 <20170129173858.45174-4-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170129173858.45174-4-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun 29-01-17 20:38:49, Kirill A. Shutemov wrote:
> For PTE-mapped THP page_check_address_transhuge() is not adequate: it
> cannot find all relevant PTEs, only the first one. It means we can miss
> some references of the page and it can result in suboptimal decisions by
> vmscan.
> 
> Let's switch it to page_vma_mapped_walk().
> 
> I don't think it's subject for stable@: it's not fatal. The only side
> effect is that THP can be swapped out when it shouldn't.

Please be more specific about the situation when this happens and how a
user can recognize this is going on. In other words when should I
consider backporting this series.

Also the interface is quite awkward imho. Why cannot we provide a
callback into page_vma_mapped_walk and call it for each pte/pmd that
matters to the given page? Wouldn't that be much easier than the loop
around page_vma_mapped_walk iterator?

> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  mm/rmap.c | 66 ++++++++++++++++++++++++++++++++-------------------------------
>  1 file changed, 34 insertions(+), 32 deletions(-)
> 
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 91619fd70939..0dff8accd629 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -886,45 +886,48 @@ struct page_referenced_arg {
>  static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
>  			unsigned long address, void *arg)
>  {
> -	struct mm_struct *mm = vma->vm_mm;
>  	struct page_referenced_arg *pra = arg;
> -	pmd_t *pmd;
> -	pte_t *pte;
> -	spinlock_t *ptl;
> +	struct page_vma_mapped_walk pvmw = {
> +		.page = page,
> +		.vma = vma,
> +		.address = address,
> +	};
>  	int referenced = 0;
>  
> -	if (!page_check_address_transhuge(page, mm, address, &pmd, &pte, &ptl))
> -		return SWAP_AGAIN;
> +	while (page_vma_mapped_walk(&pvmw)) {
> +		address = pvmw.address;
>  
> -	if (vma->vm_flags & VM_LOCKED) {
> -		if (pte)
> -			pte_unmap(pte);
> -		spin_unlock(ptl);
> -		pra->vm_flags |= VM_LOCKED;
> -		return SWAP_FAIL; /* To break the loop */
> -	}
> +		if (vma->vm_flags & VM_LOCKED) {
> +			page_vma_mapped_walk_done(&pvmw);
> +			pra->vm_flags |= VM_LOCKED;
> +			return SWAP_FAIL; /* To break the loop */
> +		}
>  
> -	if (pte) {
> -		if (ptep_clear_flush_young_notify(vma, address, pte)) {
> -			/*
> -			 * Don't treat a reference through a sequentially read
> -			 * mapping as such.  If the page has been used in
> -			 * another mapping, we will catch it; if this other
> -			 * mapping is already gone, the unmap path will have
> -			 * set PG_referenced or activated the page.
> -			 */
> -			if (likely(!(vma->vm_flags & VM_SEQ_READ)))
> +		if (pvmw.pte) {
> +			if (ptep_clear_flush_young_notify(vma, address,
> +						pvmw.pte)) {
> +				/*
> +				 * Don't treat a reference through
> +				 * a sequentially read mapping as such.
> +				 * If the page has been used in another mapping,
> +				 * we will catch it; if this other mapping is
> +				 * already gone, the unmap path will have set
> +				 * PG_referenced or activated the page.
> +				 */
> +				if (likely(!(vma->vm_flags & VM_SEQ_READ)))
> +					referenced++;
> +			}
> +		} else if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE)) {
> +			if (pmdp_clear_flush_young_notify(vma, address,
> +						pvmw.pmd))
>  				referenced++;
> +		} else {
> +			/* unexpected pmd-mapped page? */
> +			WARN_ON_ONCE(1);
>  		}
> -		pte_unmap(pte);
> -	} else if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE)) {
> -		if (pmdp_clear_flush_young_notify(vma, address, pmd))
> -			referenced++;
> -	} else {
> -		/* unexpected pmd-mapped page? */
> -		WARN_ON_ONCE(1);
> +
> +		pra->mapcount--;
>  	}
> -	spin_unlock(ptl);
>  
>  	if (referenced)
>  		clear_page_idle(page);
> @@ -936,7 +939,6 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
>  		pra->vm_flags |= vma->vm_flags;
>  	}
>  
> -	pra->mapcount--;
>  	if (!pra->mapcount)
>  		return SWAP_SUCCESS; /* To break the loop */
>  
> -- 
> 2.11.0
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
