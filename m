Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 0F0746B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 07:10:47 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id lj1so69180pab.5
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 04:10:47 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id gf8si8461923pbc.230.2014.08.27.04.10.39
        for <linux-mm@kvack.org>;
        Wed, 27 Aug 2014 04:10:40 -0700 (PDT)
Date: Wed, 27 Aug 2014 12:09:48 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATH V2 6/6] arm64: mm: Enable RCU fast_gup
Message-ID: <20140827110947.GI6968@arm.com>
References: <1408635812-31584-1-git-send-email-steve.capper@linaro.org>
 <1408635812-31584-7-git-send-email-steve.capper@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1408635812-31584-7-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Will Deacon <Will.Deacon@arm.com>, "gary.robertson@linaro.org" <gary.robertson@linaro.org>, "christoffer.dall@linaro.org" <christoffer.dall@linaro.org>, "peterz@infradead.org" <peterz@infradead.org>, "anders.roxell@linaro.org" <anders.roxell@linaro.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "dann.frazier@canonical.com" <dann.frazier@canonical.com>, Mark Rutland <Mark.Rutland@arm.com>, "mgorman@suse.de" <mgorman@suse.de>

On Thu, Aug 21, 2014 at 04:43:32PM +0100, Steve Capper wrote:
> --- a/arch/arm64/include/asm/pgtable.h
> +++ b/arch/arm64/include/asm/pgtable.h
> @@ -256,7 +256,13 @@ static inline pmd_t pte_pmd(pte_t pte)
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  #define pmd_trans_huge(pmd)	(pmd_val(pmd) && !(pmd_val(pmd) & PMD_TABLE_BIT))
>  #define pmd_trans_splitting(pmd)	pte_special(pmd_pte(pmd))
> -#endif
> +#ifdef CONFIG_HAVE_RCU_TABLE_FREE
> +#define __HAVE_ARCH_PMDP_SPLITTING_FLUSH
> +struct vm_area_struct;
> +void pmdp_splitting_flush(struct vm_area_struct *vma, unsigned long address,
> +			  pmd_t *pmdp);
> +#endif /* CONFIG_HAVE_RCU_TABLE_FREE */
> +#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>  
>  #define pmd_young(pmd)		pte_young(pmd_pte(pmd))
>  #define pmd_wrprotect(pmd)	pte_pmd(pte_wrprotect(pmd_pte(pmd)))
> @@ -277,6 +283,7 @@ static inline pmd_t pte_pmd(pte_t pte)
>  #define mk_pmd(page,prot)	pfn_pmd(page_to_pfn(page),prot)
>  
>  #define pmd_page(pmd)           pfn_to_page(__phys_to_pfn(pmd_val(pmd) & PHYS_MASK))
> +#define pud_write(pud)		pmd_write(__pmd(pud_val(pud)))
>  #define pud_pfn(pud)		(((pud_val(pud) & PUD_MASK) & PHYS_MASK) >> PAGE_SHIFT)
>  
>  #define set_pmd_at(mm, addr, pmdp, pmd)	set_pte_at(mm, addr, (pte_t *)pmdp, pmd_pte(pmd))
> @@ -376,6 +383,8 @@ static inline pmd_t *pmd_offset(pud_t *pud, unsigned long addr)
>  	return (pmd_t *)pud_page_vaddr(*pud) + pmd_index(addr);
>  }
>  
> +#define pud_page(pud)           pmd_page(__pmd(pud_val(pud)))

I think you could define a pud_pte as you've done for pmd. The
conversion would look slightly cleaner. Otherwise:

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
