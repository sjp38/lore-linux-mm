Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6005C6B025F
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 08:56:51 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z48so33194512wrc.4
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 05:56:51 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v185si10835536wmb.36.2017.07.27.05.56.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Jul 2017 05:56:50 -0700 (PDT)
Date: Thu, 27 Jul 2017 14:56:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/3] powerpc/mm: Implement pmdp_establish for ppc64
Message-ID: <20170727125644.GC27766@dhcp22.suse.cz>
References: <20170727083756.32217-1-aneesh.kumar@linux.vnet.ibm.com>
 <20170727083756.32217-2-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170727083756.32217-2-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, "Kirill A . Shutemov" <kirill@shutemov.name>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Thu 27-07-17 14:07:55, Aneesh Kumar K.V wrote:
> We can now use this to set pmd page table entries to absolute values. THP
> need to ensure that we always update pmd PTE entries such that we never mark
> the pmd none. pmdp_establish helps in implementing that.
> 
> This doesn't flush the tlb. Based on the old_pmd value returned caller can
> decide to call flush_pmd_tlb_range()

_Why_ do we need this. It doesn't really help that the newly added
function is not used so we could check that...

> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  arch/powerpc/include/asm/book3s/64/radix.h |  9 ++++++---
>  arch/powerpc/mm/pgtable-book3s64.c         | 10 ++++++++++
>  2 files changed, 16 insertions(+), 3 deletions(-)
> 
> diff --git a/arch/powerpc/include/asm/book3s/64/radix.h b/arch/powerpc/include/asm/book3s/64/radix.h
> index cd481ab601b6..558fea3b2d22 100644
> --- a/arch/powerpc/include/asm/book3s/64/radix.h
> +++ b/arch/powerpc/include/asm/book3s/64/radix.h
> @@ -131,7 +131,8 @@ static inline unsigned long __radix_pte_update(pte_t *ptep, unsigned long clr,
>  	do {
>  		pte = READ_ONCE(*ptep);
>  		old_pte = pte_val(pte);
> -		new_pte = (old_pte | set) & ~clr;
> +		new_pte = old_pte & ~clr;
> +		new_pte |= set;
>  
>  	} while (!pte_xchg(ptep, __pte(old_pte), __pte(new_pte)));
>  
> @@ -153,9 +154,11 @@ static inline unsigned long radix__pte_update(struct mm_struct *mm,
>  
>  		old_pte = __radix_pte_update(ptep, ~0ul, 0);
>  		/*
> -		 * new value of pte
> +		 * new value of pte. We clear all the bits in clr mask
> +		 * first and set the bits in set mask.
>  		 */
> -		new_pte = (old_pte | set) & ~clr;
> +		new_pte = old_pte & ~clr;
> +		new_pte |= set;
>  		radix__flush_tlb_pte_p9_dd1(old_pte, mm, addr);
>  		if (new_pte)
>  			__radix_pte_update(ptep, 0, new_pte);
> diff --git a/arch/powerpc/mm/pgtable-book3s64.c b/arch/powerpc/mm/pgtable-book3s64.c
> index 0bb7f824ecdd..7100b0150a2a 100644
> --- a/arch/powerpc/mm/pgtable-book3s64.c
> +++ b/arch/powerpc/mm/pgtable-book3s64.c
> @@ -45,6 +45,16 @@ int pmdp_set_access_flags(struct vm_area_struct *vma, unsigned long address,
>  	return changed;
>  }
>  
> +pmd_t pmdp_establish(struct vm_area_struct *vma, unsigned long addr,
> +		     pmd_t *pmdp, pmd_t entry)
> +{
> +	long pmdval;
> +
> +	pmdval = pmd_hugepage_update(vma->vm_mm, addr, pmdp, ~0UL, pmd_val(entry));
> +	return __pmd(pmdval);
> +}
> +
> +
>  int pmdp_test_and_clear_young(struct vm_area_struct *vma,
>  			      unsigned long address, pmd_t *pmdp)
>  {
> -- 
> 2.13.3
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
