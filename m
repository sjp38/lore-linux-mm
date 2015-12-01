Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id 82AF06B0256
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 20:20:34 -0500 (EST)
Received: by obdgf3 with SMTP id gf3so144500483obd.3
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 17:20:34 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id bp4si2452750obb.28.2015.11.30.17.20.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Nov 2015 17:20:33 -0800 (PST)
Subject: Re: [PATCH v1] mm: hugetlb: call huge_pte_alloc() only if ptep is
 null
References: <1448524936-10501-1-git-send-email-n-horiguchi@ah.jp.nec.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <565CF5D6.1030602@oracle.com>
Date: Mon, 30 Nov 2015 17:20:22 -0800
MIME-Version: 1.0
In-Reply-To: <1448524936-10501-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On 11/26/2015 12:02 AM, Naoya Horiguchi wrote:
> Currently at the beginning of hugetlb_fault(), we call huge_pte_offset()
> and check whether the obtained *ptep is a migration/hwpoison entry or not.
> And if not, then we get to call huge_pte_alloc(). This is racy because the
> *ptep could turn into migration/hwpoison entry after the huge_pte_offset()
> check. This race results in BUG_ON in huge_pte_alloc().

I assume the BUG_ON you hit in huge_pte_alloc is:

	BUG_ON(pte && !pte_none(*pte) && !pte_huge(*pte));

Correct?

This means either:
1) The pte was present when entering hugetlb_fault() and not marked
   for migration or hwpoisoned.
2) The pte was added to the page table after the call to huge_pte_offset()
   and before the call to huge_pte_alloc().

Your patch will take care of case # 1.  I am not sure case # 2 is possible,
but your patch would not address this situation.

-- 
Mike Kravetz

> 
> We don't have to call huge_pte_alloc() when the huge_pte_offset() returns
> non-NULL, so let's fix this bug with moving the code into else block.
> 
> Note that the *ptep could turn into a migration/hwpoison entry after
> this block, but that's not a problem because we have another !pte_present
> check later (we never go into hugetlb_no_page() in that case.)
> 
> Fixes: 290408d4a250 ("hugetlb: hugepage migration core")
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: <stable@vger.kernel.org> [2.6.36+]
> ---
>  mm/hugetlb.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git next-20151123/mm/hugetlb.c next-20151123_patched/mm/hugetlb.c
> index 1101ccd..6ad5e91 100644
> --- next-20151123/mm/hugetlb.c
> +++ next-20151123_patched/mm/hugetlb.c
> @@ -3696,12 +3696,12 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  		} else if (unlikely(is_hugetlb_entry_hwpoisoned(entry)))
>  			return VM_FAULT_HWPOISON_LARGE |
>  				VM_FAULT_SET_HINDEX(hstate_index(h));
> +	} else {
> +		ptep = huge_pte_alloc(mm, address, huge_page_size(h));
> +		if (!ptep)
> +			return VM_FAULT_OOM;
>  	}
>  
> -	ptep = huge_pte_alloc(mm, address, huge_page_size(h));
> -	if (!ptep)
> -		return VM_FAULT_OOM;
> -
>  	mapping = vma->vm_file->f_mapping;
>  	idx = vma_hugecache_offset(h, vma, address);
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
