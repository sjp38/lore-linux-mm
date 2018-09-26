Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 19CE28E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 08:54:13 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id p23-v6so31672599otl.23
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 05:54:13 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 19-v6si2065137oij.45.2018.09.26.05.54.12
        for <linux-mm@kvack.org>;
        Wed, 26 Sep 2018 05:54:12 -0700 (PDT)
Date: Wed, 26 Sep 2018 13:54:06 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 08/18] arm/tlb: Convert to generic mmu_gather
Message-ID: <20180926125405.GH2979@brain-police>
References: <20180926113623.863696043@infradead.org>
 <20180926114800.927066872@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180926114800.927066872@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com, riel@surriel.com

On Wed, Sep 26, 2018 at 01:36:31PM +0200, Peter Zijlstra wrote:
> Generic mmu_gather provides everything that ARM needs:
> 
>  - range tracking
>  - RCU table free
>  - VM_EXEC tracking
>  - VIPT cache flushing
> 
> The one notable curiosity is the 'funny' range tracking for classical
> ARM in __pte_free_tlb().
> 
> Cc: Nick Piggin <npiggin@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Russell King <linux@armlinux.org.uk>
> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> ---
>  arch/arm/include/asm/tlb.h |  255 ++-------------------------------------------
>  1 file changed, 14 insertions(+), 241 deletions(-)

[...]

>  static inline void
> -tlb_remove_pmd_tlb_entry(struct mmu_gather *tlb, pmd_t *pmdp, unsigned long addr)
> +__pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmdp, unsigned long addr)
>  {
> -	tlb_add_flush(tlb, addr);
> -}
> -
> -#define pte_free_tlb(tlb, ptep, addr)	__pte_free_tlb(tlb, ptep, addr)
> -#define pmd_free_tlb(tlb, pmdp, addr)	__pmd_free_tlb(tlb, pmdp, addr)
> -#define pud_free_tlb(tlb, pudp, addr)	pud_free((tlb)->mm, pudp)
> -
> -#define tlb_migrate_finish(mm)		do { } while (0)
> -
> -static inline void tlb_change_page_size(struct mmu_gather *tlb,
> -						     unsigned int page_size)
> -{
> -}
> -
> -static inline void tlb_flush_remove_tables(struct mm_struct *mm)
> -{
> -}
> +#ifdef CONFIG_ARM_LPAE
> +	struct page *page = virt_to_page(pmdp);
>  
> -static inline void tlb_flush_remove_tables_local(void *arg)
> -{
> +	pgtable_pmd_page_dtor(page);

The dtor() is a NOP for Arm, so I don't think you need too call it (and we
never call the ctor() afaict). I wonder if should be caring about this on
arm64...

Other than that:

Acked-by: Will Deacon <will.deacon@arm.com>

Will
