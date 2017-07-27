Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3AF336B025F
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 08:54:54 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p43so30663062wrb.6
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 05:54:54 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d196si1638989wme.2.2017.07.27.05.54.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Jul 2017 05:54:52 -0700 (PDT)
Date: Thu, 27 Jul 2017 14:54:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/3] powerpc/mm: update pmdp_invalidate to return old
 pmd value
Message-ID: <20170727125449.GB27766@dhcp22.suse.cz>
References: <20170727083756.32217-1-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170727083756.32217-1-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, "Kirill A . Shutemov" <kirill@shutemov.name>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

EMISSING_CHANGELOG

besides that no user actually uses the return value. Please fold this
into the patch which uses the new functionality.

On Thu 27-07-17 14:07:54, Aneesh Kumar K.V wrote:
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  arch/powerpc/include/asm/book3s/64/pgtable.h | 4 ++--
>  arch/powerpc/mm/pgtable-book3s64.c           | 9 ++++++---
>  2 files changed, 8 insertions(+), 5 deletions(-)
> 
> diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
> index 41d484ac0822..ece6912fae8e 100644
> --- a/arch/powerpc/include/asm/book3s/64/pgtable.h
> +++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
> @@ -1119,8 +1119,8 @@ static inline pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm,
>  }
>  
>  #define __HAVE_ARCH_PMDP_INVALIDATE
> -extern void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
> -			    pmd_t *pmdp);
> +extern pmd_t pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
> +			     pmd_t *pmdp);
>  
>  #define __HAVE_ARCH_PMDP_HUGE_SPLIT_PREPARE
>  static inline void pmdp_huge_split_prepare(struct vm_area_struct *vma,
> diff --git a/arch/powerpc/mm/pgtable-book3s64.c b/arch/powerpc/mm/pgtable-book3s64.c
> index 3b65917785a5..0bb7f824ecdd 100644
> --- a/arch/powerpc/mm/pgtable-book3s64.c
> +++ b/arch/powerpc/mm/pgtable-book3s64.c
> @@ -90,16 +90,19 @@ void serialize_against_pte_lookup(struct mm_struct *mm)
>   * We use this to invalidate a pmdp entry before switching from a
>   * hugepte to regular pmd entry.
>   */
> -void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
> -		     pmd_t *pmdp)
> +pmd_t pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
> +		      pmd_t *pmdp)
>  {
> -	pmd_hugepage_update(vma->vm_mm, address, pmdp, _PAGE_PRESENT, 0);
> +	unsigned long old_pmd;
> +
> +	old_pmd = pmd_hugepage_update(vma->vm_mm, address, pmdp, _PAGE_PRESENT, 0);
>  	flush_pmd_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
>  	/*
>  	 * This ensures that generic code that rely on IRQ disabling
>  	 * to prevent a parallel THP split work as expected.
>  	 */
>  	serialize_against_pte_lookup(vma->vm_mm);
> +	return __pmd(old_pmd);
>  }
>  
>  static pmd_t pmd_set_protbits(pmd_t pmd, pgprot_t pgprot)
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
