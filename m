Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5C2D28E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 08:53:42 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id l191-v6so633359oig.23
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 05:53:42 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k13-v6si2338834otj.329.2018.09.26.05.53.41
        for <linux-mm@kvack.org>;
        Wed, 26 Sep 2018 05:53:41 -0700 (PDT)
Date: Wed, 26 Sep 2018 13:53:35 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 05/18] asm-generic/tlb: Provide generic tlb_flush
Message-ID: <20180926125335.GG2979@brain-police>
References: <20180926113623.863696043@infradead.org>
 <20180926114800.770817616@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180926114800.770817616@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com, riel@surriel.com

On Wed, Sep 26, 2018 at 01:36:28PM +0200, Peter Zijlstra wrote:
> Provide a generic tlb_flush() implementation that relies on
> flush_tlb_range(). This is a little awkward because flush_tlb_range()
> assumes a VMA for range invalidation, but we no longer have one.
> 
> Audit of all flush_tlb_range() implementations shows only vma->vm_mm
> and vma->vm_flags are used, and of the latter only VM_EXEC (I-TLB
> invalidates) and VM_HUGETLB (large TLB invalidate) are used.
> 
> Therefore, track VM_EXEC and VM_HUGETLB in two more bits, and create a
> 'fake' VMA.
> 
> This allows architectures that have a reasonably efficient
> flush_tlb_range() to not require any additional effort.
> 
> Cc: Nick Piggin <npiggin@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> ---
>  arch/arm64/include/asm/tlb.h   |    1 
>  arch/powerpc/include/asm/tlb.h |    1 
>  arch/riscv/include/asm/tlb.h   |    1 
>  arch/x86/include/asm/tlb.h     |    1 
>  include/asm-generic/tlb.h      |   80 +++++++++++++++++++++++++++++++++++------
>  5 files changed, 74 insertions(+), 10 deletions(-)
> 
> --- a/arch/arm64/include/asm/tlb.h
> +++ b/arch/arm64/include/asm/tlb.h
> @@ -27,6 +27,7 @@ static inline void __tlb_remove_table(vo
>  	free_page_and_swap_cache((struct page *)_table);
>  }
>  
> +#define tlb_flush tlb_flush
>  static void tlb_flush(struct mmu_gather *tlb);
>  
>  #include <asm-generic/tlb.h>
> --- a/arch/powerpc/include/asm/tlb.h
> +++ b/arch/powerpc/include/asm/tlb.h
> @@ -28,6 +28,7 @@
>  #define tlb_end_vma(tlb, vma)	do { } while (0)
>  #define __tlb_remove_tlb_entry	__tlb_remove_tlb_entry
>  
> +#define tlb_flush tlb_flush
>  extern void tlb_flush(struct mmu_gather *tlb);
>  
>  /* Get the generic bits... */
> --- a/arch/riscv/include/asm/tlb.h
> +++ b/arch/riscv/include/asm/tlb.h
> @@ -18,6 +18,7 @@ struct mmu_gather;
>  
>  static void tlb_flush(struct mmu_gather *tlb);
>  
> +#define tlb_flush tlb_flush
>  #include <asm-generic/tlb.h>
>  
>  static inline void tlb_flush(struct mmu_gather *tlb)
> --- a/arch/x86/include/asm/tlb.h
> +++ b/arch/x86/include/asm/tlb.h
> @@ -6,6 +6,7 @@
>  #define tlb_end_vma(tlb, vma) do { } while (0)
>  #define __tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
>  
> +#define tlb_flush tlb_flush
>  static inline void tlb_flush(struct mmu_gather *tlb);
>  
>  #include <asm-generic/tlb.h>
> --- a/include/asm-generic/tlb.h
> +++ b/include/asm-generic/tlb.h
> @@ -241,6 +241,12 @@ struct mmu_gather {
>  	unsigned int		cleared_puds : 1;
>  	unsigned int		cleared_p4ds : 1;
>  
> +	/*
> +	 * tracks VM_EXEC | VM_HUGETLB in tlb_start_vma
> +	 */
> +	unsigned int		vma_exec : 1;
> +	unsigned int		vma_huge : 1;
> +
>  	unsigned int		batch_count;
>  
>  	struct mmu_gather_batch *active;
> @@ -282,7 +288,35 @@ static inline void __tlb_reset_range(str
>  	tlb->cleared_pmds = 0;
>  	tlb->cleared_puds = 0;
>  	tlb->cleared_p4ds = 0;
> +	/*
> +	 * Do not reset mmu_gather::vma_* fields here, we do not
> +	 * call into tlb_start_vma() again to set them if there is an
> +	 * intermediate flush.
> +	 */
> +}
> +
> +#ifndef tlb_flush
> +
> +#if defined(tlb_start_vma) || defined(tlb_end_vma)
> +#error Default tlb_flush() relies on default tlb_start_vma() and tlb_end_vma()
> +#endif
> +
> +#define tlb_flush tlb_flush

Do we need this #define?

> @@ -353,19 +387,45 @@ static inline unsigned long tlb_get_unma
>   * the vmas are adjusted to only cover the region to be torn down.
>   */
>  #ifndef tlb_start_vma
> -#define tlb_start_vma(tlb, vma)						\
> -do {									\
> -	if (!tlb->fullmm)						\
> -		flush_cache_range(vma, vma->vm_start, vma->vm_end);	\
> -} while (0)
> +#define tlb_start_vma tlb_start_vma

Or this one?

> +static inline void tlb_start_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
> +{
> +	if (tlb->fullmm)
> +		return;
> +
> +	/*
> +	 * flush_tlb_range() implementations that look at VM_HUGETLB (tile,
> +	 * mips-4k) flush only large pages.
> +	 *
> +	 * flush_tlb_range() implementations that flush I-TLB also flush D-TLB
> +	 * (tile, xtensa, arm), so it's ok to just add VM_EXEC to an existing
> +	 * range.
> +	 *
> +	 * We rely on tlb_end_vma() to issue a flush, such that when we reset
> +	 * these values the batch is empty.
> +	 */
> +	tlb->vma_huge = !!(vma->vm_flags & VM_HUGETLB);
> +	tlb->vma_exec = !!(vma->vm_flags & VM_EXEC);

Hmm, does this result in code generation for archs that don't care about the
vm_flags?

> +	flush_cache_range(vma, vma->vm_start, vma->vm_end);
> +}
>  #endif
>  
>  #ifndef tlb_end_vma
> -#define tlb_end_vma(tlb, vma)						\
> -do {									\
> -	if (!tlb->fullmm)						\
> -		tlb_flush_mmu_tlbonly(tlb);				\
> -} while (0)
> +#define tlb_end_vma tlb_end_vma

Another #define we can drop?

Will
