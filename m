Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6C7DF6B0292
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 03:49:47 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k9so3951901wre.11
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 00:49:47 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 73si1134035wmw.171.2017.08.30.00.49.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 Aug 2017 00:49:45 -0700 (PDT)
Date: Wed, 30 Aug 2017 09:49:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm/hugetlb.c: make huge_pte_offset() consistent and
 document behaviour
Message-ID: <20170830074943.f4jm42l2fdaordn2@dhcp22.suse.cz>
References: <20170725154114.24131-2-punit.agrawal@arm.com>
 <20170818145415.7588-1-punit.agrawal@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170818145415.7588-1-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Punit Agrawal <punit.agrawal@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@arm.com>, Will Deacon <will.deacon@arm.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Mike Kravetz <mike.kravetz@oracle.com>

On Fri 18-08-17 15:54:15, Punit Agrawal wrote:
> When walking the page tables to resolve an address that points to
> !p*d_present() entry, huge_pte_offset() returns inconsistent values
> depending on the level of page table (PUD or PMD).
> 
> It returns NULL in the case of a PUD entry while in the case of a PMD
> entry, it returns a pointer to the page table entry.
> 
> A similar inconsitency exists when handling swap entries - returns NULL
> for a PUD entry while a pointer to the pte_t is retured for the PMD entry.
> 
> Update huge_pte_offset() to make the behaviour consistent - return a
> pointer to the pte_t for hugepage or swap entries. Only return NULL in
> instances where we have a p*d_none() entry and the size parameter
> doesn't match the hugepage size at this level of the page table.
> 
> Document the behaviour to clarify the expected behaviour of this function.
> This is to set clear semantics for architecture specific implementations
> of huge_pte_offset().
> 
> Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Steve Capper <steve.capper@arm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>

I always thought that the weird semantic is a result of the hugetlb pte
sharing. But now that I dug into history it has been added by
02b0ccef903e ("[PATCH] hugetlb: check p?d_present in huge_pte_offset()")
for a completely different reason. I suspec the weird semantic just
wasn't noticed back then.

Anyway, I didn't find any problem with the patch
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
> 
> Hi Andrew,
> 
> >From discussions on the arm64 implementation of huge_pte_offset()[0]
> we realised that there is benefit from returning a pte_t* in the case
> of p*d_none().
> 
> The fault handling code in hugetlb_fault() can handle p*d_none()
> entries and saves an extra round trip to huge_pte_alloc(). Other
> callers of huge_pte_offset() should be ok as well.
> 
> Apologies for sending a late update but I thought if we are defining
> the semantics, it's worth getting them right.
> 
> Could you please pick this version please?
> 
> Thanks,
> Punit
> 
> [0] http://www.spinics.net/lists/linux-mm/msg133699.html
> 
> v2: 
> 
>  mm/hugetlb.c | 24 +++++++++++++++++++++---
>  1 file changed, 21 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 31e207cb399b..1d54a131bdd5 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -4600,6 +4600,15 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
>  	return pte;
>  }
>  
> +/*
> + * huge_pte_offset() - Walk the page table to resolve the hugepage
> + * entry at address @addr
> + *
> + * Return: Pointer to page table or swap entry (PUD or PMD) for
> + * address @addr, or NULL if a p*d_none() entry is encountered and the
> + * size @sz doesn't match the hugepage size at this level of the page
> + * table.
> + */
>  pte_t *huge_pte_offset(struct mm_struct *mm,
>  		       unsigned long addr, unsigned long sz)
>  {
> @@ -4614,13 +4623,22 @@ pte_t *huge_pte_offset(struct mm_struct *mm,
>  	p4d = p4d_offset(pgd, addr);
>  	if (!p4d_present(*p4d))
>  		return NULL;
> +
>  	pud = pud_offset(p4d, addr);
> -	if (!pud_present(*pud))
> +	if (sz != PUD_SIZE && pud_none(*pud))
>  		return NULL;
> -	if (pud_huge(*pud))
> +	/* hugepage or swap? */
> +	if (pud_huge(*pud) || !pud_present(*pud))
>  		return (pte_t *)pud;
> +
>  	pmd = pmd_offset(pud, addr);
> -	return (pte_t *) pmd;
> +	if (sz != PMD_SIZE && pmd_none(*pmd))
> +		return NULL;
> +	/* hugepage or swap? */
> +	if (pmd_huge(*pmd) || !pmd_present(*pmd))
> +		return (pte_t *)pmd;
> +
> +	return NULL;
>  }
>  
>  #endif /* CONFIG_ARCH_WANT_GENERAL_HUGETLB */
> -- 
> 2.13.2
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
