Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6B0A36B025F
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 14:03:19 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id x189so126693555pgb.11
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 11:03:19 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c63si2398932pfe.580.2017.08.17.11.03.17
        for <linux-mm@kvack.org>;
        Thu, 17 Aug 2017 11:03:17 -0700 (PDT)
Date: Thu, 17 Aug 2017 19:03:11 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v6 4/9] arm64: hugetlb: Add break-before-make logic for
 contiguous entries
Message-ID: <20170817180311.uwrz64g3bkwfdkrn@armageddon.cambridge.arm.com>
References: <20170810170906.30772-1-punit.agrawal@arm.com>
 <20170810170906.30772-5-punit.agrawal@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170810170906.30772-5-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Punit Agrawal <punit.agrawal@arm.com>
Cc: will.deacon@arm.com, mark.rutland@arm.com, linux-mm@kvack.org, David Woods <dwoods@mellanox.com>, linux-arm-kernel@lists.infradead.org, Steve Capper <steve.capper@arm.com>

On Thu, Aug 10, 2017 at 06:09:01PM +0100, Punit Agrawal wrote:
> --- a/arch/arm64/mm/hugetlbpage.c
> +++ b/arch/arm64/mm/hugetlbpage.c
> @@ -68,6 +68,62 @@ static int find_num_contig(struct mm_struct *mm, unsigned long addr,
>  	return CONT_PTES;
>  }
>  
> +/*
> + * Changing some bits of contiguous entries requires us to follow a
> + * Break-Before-Make approach, breaking the whole contiguous set
> + * before we can change any entries. See ARM DDI 0487A.k_iss10775,
> + * "Misprogramming of the Contiguous bit", page D4-1762.
> + *
> + * This helper performs the break step.
> + */
> +static pte_t get_clear_flush(struct mm_struct *mm,
> +			     unsigned long addr,
> +			     pte_t *ptep,
> +			     unsigned long pgsize,
> +			     unsigned long ncontig)
> +{
> +	unsigned long i, saddr = addr;
> +	struct vm_area_struct vma = { .vm_mm = mm };
> +	pte_t orig_pte = huge_ptep_get(ptep);
> +
> +	/*
> +	 * If we already have a faulting entry then we don't need
> +	 * to break before make (there won't be a tlb entry cached).
> +	 */
> +	if (!pte_present(orig_pte))
> +		return orig_pte;

I first thought we could relax this check to pte_valid() as we don't
care about the PROT_NONE case for hardware page table updates. However,
I realised that we call this where we expect the pte to be entirely
cleared but we simply skip it if !present (e.g. swap entry). Is this
correct?

> +
> +	for (i = 0; i < ncontig; i++, addr += pgsize, ptep++) {
> +		pte_t pte = ptep_get_and_clear(mm, addr, ptep);
> +
> +		/*
> +		 * If HW_AFDBM is enabled, then the HW could turn on
> +		 * the dirty bit for any page in the set, so check
> +		 * them all.  All hugetlb entries are already young.
> +		 */
> +		if (IS_ENABLED(CONFIG_ARM64_HW_AFDBM) && pte_dirty(pte))
> +			orig_pte = pte_mkdirty(orig_pte);
> +	}
> +
> +	flush_tlb_range(&vma, saddr, addr);
> +	return orig_pte;
> +}

It would be better if you do something like

	bool valid = pte_valid(org_pte);
	...
	if (valid)
		flush_tlb_range(...);

> +
> +static void clear_flush(struct mm_struct *mm,
> +			     unsigned long addr,
> +			     pte_t *ptep,
> +			     unsigned long pgsize,
> +			     unsigned long ncontig)
> +{
> +	unsigned long i, saddr = addr;
> +	struct vm_area_struct vma = { .vm_mm = mm };
> +
> +	for (i = 0; i < ncontig; i++, addr += pgsize, ptep++)
> +		pte_clear(mm, addr, ptep);
> +
> +	flush_tlb_range(&vma, saddr, addr);
> +}
> +
>  void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
>  			    pte_t *ptep, pte_t pte)
>  {
> @@ -93,6 +149,8 @@ void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
>  	dpfn = pgsize >> PAGE_SHIFT;
>  	hugeprot = pte_pgprot(pte);
>  
> +	clear_flush(mm, addr, ptep, pgsize, ncontig);
> +
>  	for (i = 0; i < ncontig; i++, ptep++, addr += pgsize, pfn += dpfn) {
>  		pr_debug("%s: set pte %p to 0x%llx\n", __func__, ptep,
>  			 pte_val(pfn_pte(pfn, hugeprot)));
> @@ -194,7 +252,7 @@ pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
>  pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
>  			      unsigned long addr, pte_t *ptep)
>  {
> -	int ncontig, i;
> +	int ncontig;
>  	size_t pgsize;
>  	pte_t orig_pte = huge_ptep_get(ptep);
>  
> @@ -202,17 +260,8 @@ pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
>  		return ptep_get_and_clear(mm, addr, ptep);
>  
>  	ncontig = find_num_contig(mm, addr, ptep, &pgsize);
> -	for (i = 0; i < ncontig; i++, addr += pgsize, ptep++) {
> -		/*
> -		 * If HW_AFDBM is enabled, then the HW could
> -		 * turn on the dirty bit for any of the page
> -		 * in the set, so check them all.
> -		 */
> -		if (pte_dirty(ptep_get_and_clear(mm, addr, ptep)))
> -			orig_pte = pte_mkdirty(orig_pte);
> -	}
>  
> -	return orig_pte;
> +	return get_clear_flush(mm, addr, ptep, pgsize, ncontig);
>  }

E.g. here you don't always clear the pte if a swap entry.

>  
>  int huge_ptep_set_access_flags(struct vm_area_struct *vma,
> @@ -222,6 +271,7 @@ int huge_ptep_set_access_flags(struct vm_area_struct *vma,
>  	int ncontig, i, changed = 0;
>  	size_t pgsize = 0;
>  	unsigned long pfn = pte_pfn(pte), dpfn;
> +	pte_t orig_pte;
>  	pgprot_t hugeprot;
>  
>  	if (!pte_cont(pte))
> @@ -229,12 +279,18 @@ int huge_ptep_set_access_flags(struct vm_area_struct *vma,
>  
>  	ncontig = find_num_contig(vma->vm_mm, addr, ptep, &pgsize);
>  	dpfn = pgsize >> PAGE_SHIFT;
> -	hugeprot = pte_pgprot(pte);
>  
> -	for (i = 0; i < ncontig; i++, ptep++, addr += pgsize, pfn += dpfn) {
> -		changed |= ptep_set_access_flags(vma, addr, ptep,
> -				pfn_pte(pfn, hugeprot), dirty);
> -	}
> +	orig_pte = get_clear_flush(vma->vm_mm, addr, ptep, pgsize, ncontig);
> +	if (!pte_same(orig_pte, pte))
> +		changed = 1;
> +
> +	/* Make sure we don't lose the dirty state */
> +	if (pte_dirty(orig_pte))
> +		pte = pte_mkdirty(pte);
> +
> +	hugeprot = pte_pgprot(pte);
> +	for (i = 0; i < ncontig; i++, ptep++, addr += pgsize, pfn += dpfn)
> +		set_pte_at(vma->vm_mm, addr, ptep, pfn_pte(pfn, hugeprot));
>  
>  	return changed;
>  }
> @@ -244,6 +300,9 @@ void huge_ptep_set_wrprotect(struct mm_struct *mm,
>  {
>  	int ncontig, i;
>  	size_t pgsize;
> +	pte_t pte = pte_wrprotect(huge_ptep_get(ptep)), orig_pte;

I'm not particularly fond of too many function calls in the variable
initialisation part. I would rather keep pte_wrprotect further down
where you also make it "dirty".

> +	unsigned long pfn = pte_pfn(pte), dpfn;
> +	pgprot_t hugeprot;
>  
>  	if (!pte_cont(*ptep)) {
>  		ptep_set_wrprotect(mm, addr, ptep);
> @@ -251,14 +310,21 @@ void huge_ptep_set_wrprotect(struct mm_struct *mm,
>  	}
>  
>  	ncontig = find_num_contig(mm, addr, ptep, &pgsize);
> -	for (i = 0; i < ncontig; i++, ptep++, addr += pgsize)
> -		ptep_set_wrprotect(mm, addr, ptep);
> +	dpfn = pgsize >> PAGE_SHIFT;
> +
> +	orig_pte = get_clear_flush(mm, addr, ptep, pgsize, ncontig);

Can you not use just set pte here instead of deriving it from *ptep
early on?

	pte = get_clear_flush(mm, addr, ptep, pgsize, ncontig);
	pte = pte_wrprotect(pte);

> +	if (pte_dirty(orig_pte))
> +		pte = pte_mkdirty(pte);
> +
> +	hugeprot = pte_pgprot(pte);
> +	for (i = 0; i < ncontig; i++, ptep++, addr += pgsize, pfn += dpfn)
> +		set_pte_at(mm, addr, ptep, pfn_pte(pfn, hugeprot));
>  }

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
