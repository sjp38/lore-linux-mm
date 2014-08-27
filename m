Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id 869246B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 09:43:16 -0400 (EDT)
Received: by mail-we0-f172.google.com with SMTP id x48so238084wes.3
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 06:43:14 -0700 (PDT)
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
        by mx.google.com with ESMTPS id bs11si1655409wib.35.2014.08.27.06.43.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 27 Aug 2014 06:43:12 -0700 (PDT)
Received: by mail-wi0-f178.google.com with SMTP id hi2so460253wib.17
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 06:43:12 -0700 (PDT)
Date: Wed, 27 Aug 2014 14:43:09 +0100
From: Steve Capper <steve.capper@linaro.org>
Subject: Re: [PATH V2 6/6] arm64: mm: Enable RCU fast_gup
Message-ID: <20140827134309.GB8814@linaro.org>
References: <1408635812-31584-1-git-send-email-steve.capper@linaro.org>
 <1408635812-31584-7-git-send-email-steve.capper@linaro.org>
 <20140827110947.GI6968@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140827110947.GI6968@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Will Deacon <Will.Deacon@arm.com>, "gary.robertson@linaro.org" <gary.robertson@linaro.org>, "christoffer.dall@linaro.org" <christoffer.dall@linaro.org>, "peterz@infradead.org" <peterz@infradead.org>, "anders.roxell@linaro.org" <anders.roxell@linaro.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "dann.frazier@canonical.com" <dann.frazier@canonical.com>, Mark Rutland <Mark.Rutland@arm.com>, "mgorman@suse.de" <mgorman@suse.de>

On Wed, Aug 27, 2014 at 12:09:48PM +0100, Catalin Marinas wrote:
> On Thu, Aug 21, 2014 at 04:43:32PM +0100, Steve Capper wrote:
> > --- a/arch/arm64/include/asm/pgtable.h
> > +++ b/arch/arm64/include/asm/pgtable.h
> > @@ -256,7 +256,13 @@ static inline pmd_t pte_pmd(pte_t pte)
> >  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
> >  #define pmd_trans_huge(pmd)	(pmd_val(pmd) && !(pmd_val(pmd) & PMD_TABLE_BIT))
> >  #define pmd_trans_splitting(pmd)	pte_special(pmd_pte(pmd))
> > -#endif
> > +#ifdef CONFIG_HAVE_RCU_TABLE_FREE
> > +#define __HAVE_ARCH_PMDP_SPLITTING_FLUSH
> > +struct vm_area_struct;
> > +void pmdp_splitting_flush(struct vm_area_struct *vma, unsigned long address,
> > +			  pmd_t *pmdp);
> > +#endif /* CONFIG_HAVE_RCU_TABLE_FREE */
> > +#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
> >  
> >  #define pmd_young(pmd)		pte_young(pmd_pte(pmd))
> >  #define pmd_wrprotect(pmd)	pte_pmd(pte_wrprotect(pmd_pte(pmd)))
> > @@ -277,6 +283,7 @@ static inline pmd_t pte_pmd(pte_t pte)
> >  #define mk_pmd(page,prot)	pfn_pmd(page_to_pfn(page),prot)
> >  
> >  #define pmd_page(pmd)           pfn_to_page(__phys_to_pfn(pmd_val(pmd) & PHYS_MASK))
> > +#define pud_write(pud)		pmd_write(__pmd(pud_val(pud)))
> >  #define pud_pfn(pud)		(((pud_val(pud) & PUD_MASK) & PHYS_MASK) >> PAGE_SHIFT)
> >  
> >  #define set_pmd_at(mm, addr, pmdp, pmd)	set_pte_at(mm, addr, (pte_t *)pmdp, pmd_pte(pmd))
> > @@ -376,6 +383,8 @@ static inline pmd_t *pmd_offset(pud_t *pud, unsigned long addr)
> >  	return (pmd_t *)pud_page_vaddr(*pud) + pmd_index(addr);
> >  }
> >  
> > +#define pud_page(pud)           pmd_page(__pmd(pud_val(pud)))
> 
> I think you could define a pud_pte as you've done for pmd. The
> conversion would look slightly cleaner. Otherwise:

Thanks Catalin,
I've added pud_pte and pud_pmd helpers and that now looks a lot
clearer.

> 
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>
Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
