Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id E8F846B0031
	for <linux-mm@kvack.org>; Fri,  4 Apr 2014 18:03:48 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id uo5so4012413pbc.24
        for <linux-mm@kvack.org>; Fri, 04 Apr 2014 15:03:48 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id a8si5097524pbs.242.2014.04.04.15.03.47
        for <linux-mm@kvack.org>;
        Fri, 04 Apr 2014 15:03:47 -0700 (PDT)
Date: Fri, 4 Apr 2014 15:03:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/hugetlb.c: add NULL check of return value of
 huge_pte_offset
Message-Id: <20140404150345.92400430db3111fe21df7c7f@linux-foundation.org>
In-Reply-To: <533efd68.435fe00a.6936.ffffa5e7SMTPIN_ADDED_BROKEN@mx.google.com>
References: <533efd68.435fe00a.6936.ffffa5e7SMTPIN_ADDED_BROKEN@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-kernel@vger.kernel.org, mgorman@suse.de, andi@firstfloor.org, sasha.levin@oracle.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, linux-mm@kvack.org

On Fri, 04 Apr 2014 14:43:33 -0400 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> huge_pte_offset() could return NULL, so we need NULL check to avoid
> potential NULL pointer dereferences.
> 
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2662,7 +2662,8 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
>  				BUG_ON(huge_pte_none(pte));
>  				spin_lock(ptl);
>  				ptep = huge_pte_offset(mm, address & huge_page_mask(h));
> -				if (likely(pte_same(huge_ptep_get(ptep), pte)))
> +				if (likely(ptep &&
> +					   pte_same(huge_ptep_get(ptep), pte)))
>  					goto retry_avoidcopy;
>  				/*
>  				 * race occurs while re-acquiring page table
> @@ -2706,7 +2707,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
>  	 */
>  	spin_lock(ptl);
>  	ptep = huge_pte_offset(mm, address & huge_page_mask(h));
> -	if (likely(pte_same(huge_ptep_get(ptep), pte))) {
> +	if (likely(ptep && pte_same(huge_ptep_get(ptep), pte))) {
>  		ClearPagePrivate(new_page);
>  
>  		/* Break COW */

Has anyone been hitting oopses here or was this from code inspection?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
