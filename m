Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 872536B006E
	for <linux-mm@kvack.org>; Fri, 15 May 2015 07:05:31 -0400 (EDT)
Received: by wizk4 with SMTP id k4so282051497wiz.1
        for <linux-mm@kvack.org>; Fri, 15 May 2015 04:05:31 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cy1si2716840wib.89.2015.05.15.04.05.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 15 May 2015 04:05:30 -0700 (PDT)
Message-ID: <5555D2F7.5070301@suse.cz>
Date: Fri, 15 May 2015 13:05:27 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCHv5 05/28] mm: adjust FOLL_SPLIT for new refcounting
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com> <1429823043-157133-6-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1429823043-157133-6-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> We need to prepare kernel to allow transhuge pages to be mapped with
> ptes too. We need to handle FOLL_SPLIT in follow_page_pte().
>
> Also we use split_huge_page() directly instead of split_huge_page_pmd().
> split_huge_page_pmd() will gone.

You still call split_huge_page_pmd() for the is_huge_zero_page(page) 
case. Also, of the code around split_huge_page() you basically took from 
split_huge_page_pmd() and open-coded into follow_page_mask(), you didn't 
include the mmu notifier calls. Why are they needed in 
split_huge_page_pmd() but not here?

>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>
> ---
>   mm/gup.c | 67 +++++++++++++++++++++++++++++++++++++++++++++++-----------------
>   1 file changed, 49 insertions(+), 18 deletions(-)
>
> diff --git a/mm/gup.c b/mm/gup.c
> index 203781fa96a5..ebdb39b3e820 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -79,6 +79,19 @@ retry:
>   		page = pte_page(pte);
>   	}
>
> +	if (flags & FOLL_SPLIT && PageTransCompound(page)) {
> +		int ret;
> +		get_page(page);
> +		pte_unmap_unlock(ptep, ptl);
> +		lock_page(page);
> +		ret = split_huge_page(page);
> +		unlock_page(page);
> +		put_page(page);
> +		if (ret)
> +			return ERR_PTR(ret);
> +		goto retry;
> +	}
> +
>   	if (flags & FOLL_GET)
>   		get_page_foll(page);
>   	if (flags & FOLL_TOUCH) {
> @@ -186,27 +199,45 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
>   	}
>   	if ((flags & FOLL_NUMA) && pmd_protnone(*pmd))
>   		return no_page_table(vma, flags);
> -	if (pmd_trans_huge(*pmd)) {
> -		if (flags & FOLL_SPLIT) {
> +	if (likely(!pmd_trans_huge(*pmd)))
> +		return follow_page_pte(vma, address, pmd, flags);
> +
> +	ptl = pmd_lock(mm, pmd);
> +	if (unlikely(!pmd_trans_huge(*pmd))) {
> +		spin_unlock(ptl);
> +		return follow_page_pte(vma, address, pmd, flags);
> +	}
> +
> +	if (unlikely(pmd_trans_splitting(*pmd))) {
> +		spin_unlock(ptl);
> +		wait_split_huge_page(vma->anon_vma, pmd);
> +		return follow_page_pte(vma, address, pmd, flags);
> +	}
> +
> +	if (flags & FOLL_SPLIT) {
> +		int ret;
> +		page = pmd_page(*pmd);
> +		if (is_huge_zero_page(page)) {
> +			spin_unlock(ptl);
> +			ret = 0;
>   			split_huge_page_pmd(vma, address, pmd);
> -			return follow_page_pte(vma, address, pmd, flags);
> -		}
> -		ptl = pmd_lock(mm, pmd);
> -		if (likely(pmd_trans_huge(*pmd))) {
> -			if (unlikely(pmd_trans_splitting(*pmd))) {
> -				spin_unlock(ptl);
> -				wait_split_huge_page(vma->anon_vma, pmd);
> -			} else {
> -				page = follow_trans_huge_pmd(vma, address,
> -							     pmd, flags);
> -				spin_unlock(ptl);
> -				*page_mask = HPAGE_PMD_NR - 1;
> -				return page;
> -			}
> -		} else
> +		} else {
> +			get_page(page);
>   			spin_unlock(ptl);
> +			lock_page(page);
> +			ret = split_huge_page(page);
> +			unlock_page(page);
> +			put_page(page);
> +		}
> +
> +		return ret ? ERR_PTR(ret) :
> +			follow_page_pte(vma, address, pmd, flags);
>   	}
> -	return follow_page_pte(vma, address, pmd, flags);
> +
> +	page = follow_trans_huge_pmd(vma, address, pmd, flags);
> +	spin_unlock(ptl);
> +	*page_mask = HPAGE_PMD_NR - 1;
> +	return page;
>   }
>
>   static int get_gate_page(struct mm_struct *mm, unsigned long address,
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
