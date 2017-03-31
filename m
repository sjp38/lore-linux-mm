Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 485616B0397
	for <linux-mm@kvack.org>; Fri, 31 Mar 2017 05:52:35 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id m1so74189890pgd.13
        for <linux-mm@kvack.org>; Fri, 31 Mar 2017 02:52:35 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f26si4709214pgn.194.2017.03.31.02.52.34
        for <linux-mm@kvack.org>;
        Fri, 31 Mar 2017 02:52:34 -0700 (PDT)
Date: Fri, 31 Mar 2017 10:52:06 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH 2/4] arm64: hugetlbpages: Correctly handle swap entries
 in huge_pte_offset()
Message-ID: <20170331095155.GA31398@leverpostej>
References: <20170330163849.18402-1-punit.agrawal@arm.com>
 <20170330163849.18402-3-punit.agrawal@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170330163849.18402-3-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Punit Agrawal <punit.agrawal@arm.com>
Cc: catalin.marinas@arm.com, will.deacon@arm.com, akpm@linux-foundation.org, David Woods <dwoods@mellanox.com>, tbaicar@codeaurora.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, kirill.shutemov@linux.intel.com, mike.kravetz@oracle.com

Hi Punit,

On Thu, Mar 30, 2017 at 05:38:47PM +0100, Punit Agrawal wrote:
> huge_pte_offset() does not correctly handle poisoned or migration page
> table entries. 

What exactly does it do wrong?

Judging by the patch, we return NULL in some cases we shouldn't, right?

What can result from this? e.g. can we see data corruption?

> Not knowing the size of the hugepage entry being
> requested only compounded the problem.
> 
> The recently added hstate parameter can be used to determine the size of
> hugepage being accessed. Use the size to find the correct page table
> entry to return when coming across a swap page table entry.
> 
> Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
> Cc: David Woods <dwoods@mellanox.com>

Given this is a fix for a bug, it sounds like it should have a fixes
tag, or a Cc stable...

Thanks,
Mark.

> ---
>  arch/arm64/mm/hugetlbpage.c | 31 ++++++++++++++++---------------
>  1 file changed, 16 insertions(+), 15 deletions(-)
> 
> diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
> index 9ca742c4c1ab..44014403081f 100644
> --- a/arch/arm64/mm/hugetlbpage.c
> +++ b/arch/arm64/mm/hugetlbpage.c
> @@ -192,38 +192,39 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
>  pte_t *huge_pte_offset(struct mm_struct *mm,
>  		       unsigned long addr, struct hstate *h)
>  {
> +	unsigned long sz = huge_page_size(h);
>  	pgd_t *pgd;
>  	pud_t *pud;
> -	pmd_t *pmd = NULL;
> -	pte_t *pte = NULL;
> +	pmd_t *pmd;
> +	pte_t *pte;
>  
>  	pgd = pgd_offset(mm, addr);
>  	pr_debug("%s: addr:0x%lx pgd:%p\n", __func__, addr, pgd);
>  	if (!pgd_present(*pgd))
>  		return NULL;
> +
>  	pud = pud_offset(pgd, addr);
> -	if (!pud_present(*pud))
> +	if (pud_none(*pud) && sz != PUD_SIZE)
>  		return NULL;
> -
> -	if (pud_huge(*pud))
> +	else if (!pud_table(*pud))
>  		return (pte_t *)pud;
> +
> +	if (sz == CONT_PMD_SIZE)
> +		addr &= CONT_PMD_MASK;
> +
>  	pmd = pmd_offset(pud, addr);
> -	if (!pmd_present(*pmd))
> +	if (pmd_none(*pmd) &&
> +	    !(sz == PMD_SIZE || sz == CONT_PMD_SIZE))
>  		return NULL;
> -
> -	if (pte_cont(pmd_pte(*pmd))) {
> -		pmd = pmd_offset(
> -			pud, (addr & CONT_PMD_MASK));
> -		return (pte_t *)pmd;
> -	}
> -	if (pmd_huge(*pmd))
> +	else if (!pmd_table(*pmd))
>  		return (pte_t *)pmd;
> -	pte = pte_offset_kernel(pmd, addr);
> -	if (pte_present(*pte) && pte_cont(*pte)) {
> +
> +	if (sz == CONT_PTE_SIZE) {
>  		pte = pte_offset_kernel(
>  			pmd, (addr & CONT_PTE_MASK));
>  		return pte;
>  	}
> +
>  	return NULL;
>  }
>  
> -- 
> 2.11.0
> 
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
