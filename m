Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 5A90C82F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 11:03:48 -0500 (EST)
Received: by lbbes7 with SMTP id es7so38682561lbb.2
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 08:03:47 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id oq4si4766782lbb.14.2015.11.05.08.03.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Nov 2015 08:03:46 -0800 (PST)
Date: Thu, 5 Nov 2015 19:03:24 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 4/4] mm: prepare page_referenced() and page_idle to new
 THP refcounting
Message-ID: <20151105160324.GF29259@esperanza>
References: <1446564375-72143-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1446564375-72143-5-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1446564375-72143-5-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Sasha Levin <sasha.levin@oracle.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Nov 03, 2015 at 05:26:15PM +0200, Kirill A. Shutemov wrote:
...
> @@ -812,60 +812,104 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
>  	spinlock_t *ptl;
>  	int referenced = 0;
>  	struct page_referenced_arg *pra = arg;
> +	pgd_t *pgd;
> +	pud_t *pud;
> +	pmd_t *pmd;
> +	pte_t *pte;
>  
> -	if (unlikely(PageTransHuge(page))) {
> -		pmd_t *pmd;
> -
> -		/*
> -		 * rmap might return false positives; we must filter
> -		 * these out using page_check_address_pmd().
> -		 */
> -		pmd = page_check_address_pmd(page, mm, address, &ptl);
> -		if (!pmd)
> +	if (unlikely(PageHuge(page))) {
> +		/* when pud is not present, pte will be NULL */
> +		pte = huge_pte_offset(mm, address);
> +		if (!pte)
>  			return SWAP_AGAIN;
>  
> -		if (vma->vm_flags & VM_LOCKED) {
> +		ptl = huge_pte_lockptr(page_hstate(page), mm, pte);
> +		goto check_pte;
> +	}
> +
> +	pgd = pgd_offset(mm, address);
> +	if (!pgd_present(*pgd))
> +		return SWAP_AGAIN;
> +	pud = pud_offset(pgd, address);
> +	if (!pud_present(*pud))
> +		return SWAP_AGAIN;
> +	pmd = pmd_offset(pud, address);
> +
> +	if (pmd_trans_huge(*pmd)) {
> +		int ret = SWAP_AGAIN;
> +
> +		ptl = pmd_lock(mm, pmd);
> +		if (!pmd_present(*pmd))
> +			goto unlock_pmd;
> +		if (unlikely(!pmd_trans_huge(*pmd))) {
>  			spin_unlock(ptl);
> +			goto map_pte;
> +		}
> +
> +		if (pmd_page(*pmd) != page)
> +			goto unlock_pmd;
> +
> +		if (vma->vm_flags & VM_LOCKED) {
>  			pra->vm_flags |= VM_LOCKED;
> -			return SWAP_FAIL; /* To break the loop */
> +			ret = SWAP_FAIL; /* To break the loop */
> +			goto unlock_pmd;
>  		}
>  
>  		if (pmdp_clear_flush_young_notify(vma, address, pmd))
>  			referenced++;
> -
>  		spin_unlock(ptl);
> +		goto found;
> +unlock_pmd:
> +		spin_unlock(ptl);
> +		return ret;
>  	} else {
> -		pte_t *pte;
> -
> -		/*
> -		 * rmap might return false positives; we must filter
> -		 * these out using page_check_address().
> -		 */
> -		pte = page_check_address(page, mm, address, &ptl, 0);
> -		if (!pte)
> +		pmd_t pmde = *pmd;
> +		barrier();

This is supposed to be

		pmd_t pmde = READ_ONCE(*pmd);

Right?

I don't understand why we need a barrier here. Why can't we just do

	} else if (!pmd_present(*pmd))
		reutnr SWAP_AGAIN;

?

Thanks,
Vladimir

> +		if (!pmd_present(pmde) || pmd_trans_huge(pmde))
>  			return SWAP_AGAIN;
> +	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
