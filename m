Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 996F66B025F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 13:19:24 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id o82so9240733pfj.11
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 10:19:24 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id n2si4946705pfj.485.2017.08.07.10.19.22
        for <linux-mm@kvack.org>;
        Mon, 07 Aug 2017 10:19:23 -0700 (PDT)
Date: Mon, 7 Aug 2017 18:19:17 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v5 4/9] arm64: hugetlb: Add break-before-make logic for
 contiguous entries
Message-ID: <20170807171916.vdplrndrdyeontho@armageddon.cambridge.arm.com>
References: <20170802094904.27749-1-punit.agrawal@arm.com>
 <20170802094904.27749-5-punit.agrawal@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170802094904.27749-5-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Punit Agrawal <punit.agrawal@arm.com>
Cc: will.deacon@arm.com, mark.rutland@arm.com, David Woods <dwoods@mellanox.com>, Steve Capper <steve.capper@arm.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org

On Wed, Aug 02, 2017 at 10:48:59AM +0100, Punit Agrawal wrote:
> diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
> index 08deed7c71f0..f2c976464f39 100644
> --- a/arch/arm64/mm/hugetlbpage.c
> +++ b/arch/arm64/mm/hugetlbpage.c
> @@ -68,6 +68,47 @@ static int find_num_contig(struct mm_struct *mm, unsigned long addr,
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
> +
>  void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
>  			    pte_t *ptep, pte_t pte)
>  {
> @@ -93,6 +134,8 @@ void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
>  	dpfn = pgsize >> PAGE_SHIFT;
>  	hugeprot = pte_pgprot(pte);
>  
> +	get_clear_flush(mm, addr, ptep, pgsize, ncontig);
> +
>  	for (i = 0; i < ncontig; i++, ptep++, addr += pgsize, pfn += dpfn) {
>  		pr_debug("%s: set pte %p to 0x%llx\n", __func__, ptep,
>  			 pte_val(pfn_pte(pfn, hugeprot)));

Is there any risk of the huge pte being accessed (from user space on
another CPU) in the short break-before-make window? Not that we can do
much about it but just checking.

BTW, it seems a bit overkill to use ptep_get_and_clear() (via
get_clear_flush) when we just want to zero the entries. Probably not
much overhead though.

> @@ -222,6 +256,7 @@ int huge_ptep_set_access_flags(struct vm_area_struct *vma,
>  	int ncontig, i, changed = 0;
>  	size_t pgsize = 0;
>  	unsigned long pfn = pte_pfn(pte), dpfn;
> +	pte_t orig_pte;
>  	pgprot_t hugeprot;
>  
>  	if (!pte_cont(pte))
> @@ -231,10 +266,12 @@ int huge_ptep_set_access_flags(struct vm_area_struct *vma,
>  	dpfn = pgsize >> PAGE_SHIFT;
>  	hugeprot = pte_pgprot(pte);
>  
> -	for (i = 0; i < ncontig; i++, ptep++, addr += pgsize, pfn += dpfn) {
> -		changed |= ptep_set_access_flags(vma, addr, ptep,
> -				pfn_pte(pfn, hugeprot), dirty);
> -	}
> +	orig_pte = get_clear_flush(vma->vm_mm, addr, ptep, pgsize, ncontig);
> +	if (!pte_same(orig_pte, pte))
> +		changed = 1;
> +
> +	for (i = 0; i < ncontig; i++, ptep++, addr += pgsize, pfn += dpfn)
> +		set_pte_at(vma->vm_mm, addr, ptep, pfn_pte(pfn, hugeprot));
>  
>  	return changed;
>  }

If hugeprot isn't dirty but orig_pte became dirty, it looks like we just
drop such information from the new pte.

Same comment here about the window. huge_ptep_set_access_flags() is
called on a present (huge) pte and we briefly make it invalid. Can the
mm subsystem cope with a fault on another CPU here? Same for the
huge_ptep_set_wrprotect() below.

> @@ -244,6 +281,9 @@ void huge_ptep_set_wrprotect(struct mm_struct *mm,
>  {
>  	int ncontig, i;
>  	size_t pgsize;
> +	pte_t pte = pte_wrprotect(huge_ptep_get(ptep)), orig_pte;
> +	unsigned long pfn = pte_pfn(pte), dpfn;
> +	pgprot_t hugeprot;
>  
>  	if (!pte_cont(*ptep)) {
>  		ptep_set_wrprotect(mm, addr, ptep);
> @@ -251,8 +291,15 @@ void huge_ptep_set_wrprotect(struct mm_struct *mm,
>  	}
>  
>  	ncontig = find_num_contig(mm, addr, ptep, &pgsize);
> -	for (i = 0; i < ncontig; i++, ptep++, addr += pgsize)
> -		ptep_set_wrprotect(mm, addr, ptep);
> +	dpfn = pgsize >> PAGE_SHIFT;
> +
> +	orig_pte = get_clear_flush(mm, addr, ptep, pgsize, ncontig);
> +	if (pte_dirty(orig_pte))
> +		pte = pte_mkdirty(pte);
> +
> +	hugeprot = pte_pgprot(pte);
> +	for (i = 0; i < ncontig; i++, ptep++, addr += pgsize, pfn += dpfn)
> +		set_pte_at(mm, addr, ptep, pfn_pte(pfn, hugeprot));
>  }
>  
>  void huge_ptep_clear_flush(struct vm_area_struct *vma,

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
