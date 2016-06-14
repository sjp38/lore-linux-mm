Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 95CFD6B007E
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 14:10:07 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id k184so726588wme.3
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 11:10:07 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id w186si5489013wma.55.2016.06.14.11.10.05
        for <linux-mm@kvack.org>;
        Tue, 14 Jun 2016 11:10:06 -0700 (PDT)
Date: Tue, 14 Jun 2016 20:10:02 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v2] Linux VM workaround for Knights Landing A/D leak
Message-ID: <20160614181002.GA30049@pd.tnic>
References: <7FB15233-B347-4A87-9506-A9E10D331292@gmail.com>
 <1465923672-14232-1-git-send-email-lukasz.anaczkowski@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1465923672-14232-1-git-send-email-lukasz.anaczkowski@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lukasz Anaczkowski <lukasz.anaczkowski@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, dave.hansen@linux.intel.com, ak@linux.intel.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, akpm@linux-foundation.org, hpa@zytor.com, harish.srinivasappa@intel.com, lukasz.odzioba@intel.com, grzegorz.andrejczuk@intel.com, lukasz.daniluk@intel.com

On Tue, Jun 14, 2016 at 07:01:12PM +0200, Lukasz Anaczkowski wrote:
> From: Andi Kleen <ak@linux.intel.com>
> 
> Knights Landing has a issue that a thread setting A or D bits
> may not do so atomically against checking the present bit.
> A thread which is going to page fault may still set those
> bits, even though the present bit was already atomically cleared.
> 
> This implies that when the kernel clears present atomically,
> some time later the supposed to be zero entry could be corrupted
> with stray A or D bits.
> 
> Since the PTE could be already used for storing a swap index,
> or a NUMA migration index, this cannot be tolerated. Most
> of the time the kernel detects the problem, but in some
> rare cases it may not.
> 
> This patch enforces that the page unmap path in vmscan/direct reclaim
> always flushes other CPUs after clearing each page, and also
> clears the PTE again after the flush.
> 
> For reclaim this brings the performance back to before Mel's
> flushing changes, but for unmap it disables batching.
> 
> This makes sure any leaked A/D bits are immediately cleared before the entry
> is used for something else.
> 
> Any parallel faults that check for entry is zero may loop,
> but they should eventually recover after the entry is written.
> 
> Also other users may spin in the page table lock until we
> "fixed" the PTE. This is ensured by always taking the page table lock
> even for the swap cache case. Previously this was only done
> on architectures with non atomic PTE accesses (such as 32bit PTE),
> but now it is also done when this bug workaround is active.
> 
> I audited apply_pte_range and other users of arch_enter_lazy...
> and they seem to all not clear the present bit.
> 
> Right now the extra flush is done in the low level
> architecture code, while the higher level code still
> does batched TLB flush. This means there is always one extra
> unnecessary TLB flush now. As a followon optimization
> this could be avoided by telling the callers that
> the flush already happenend.
> 
> v2 (Lukasz Anaczkowski):
>     () added call to smp_mb__after_atomic() to synchornize with
>        switch_mm, based on Nadav's comment
>     () fixed compilation breakage
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> Signed-off-by: Lukasz Anaczkowski <lukasz.anaczkowski@intel.com>
> ---
>  arch/x86/include/asm/cpufeatures.h |  1 +
>  arch/x86/include/asm/hugetlb.h     |  9 ++++++++-
>  arch/x86/include/asm/pgtable.h     |  5 +++++
>  arch/x86/include/asm/pgtable_64.h  |  6 ++++++
>  arch/x86/kernel/cpu/intel.c        | 10 ++++++++++
>  arch/x86/mm/tlb.c                  | 22 ++++++++++++++++++++++
>  include/linux/mm.h                 |  4 ++++
>  mm/memory.c                        |  3 ++-
>  8 files changed, 58 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/x86/include/asm/cpufeatures.h b/arch/x86/include/asm/cpufeatures.h
> index 4a41348..2c48011 100644
> --- a/arch/x86/include/asm/cpufeatures.h
> +++ b/arch/x86/include/asm/cpufeatures.h
> @@ -303,6 +303,7 @@
>  #define X86_BUG_SYSRET_SS_ATTRS	X86_BUG(8) /* SYSRET doesn't fix up SS attrs */
>  #define X86_BUG_NULL_SEG	X86_BUG(9) /* Nulling a selector preserves the base */
>  #define X86_BUG_SWAPGS_FENCE	X86_BUG(10) /* SWAPGS without input dep on GS */
> +#define X86_BUG_PTE_LEAK        X86_BUG(11) /* PTE may leak A/D bits after clear */
>  
>  
>  #ifdef CONFIG_X86_32
> diff --git a/arch/x86/include/asm/hugetlb.h b/arch/x86/include/asm/hugetlb.h
> index 3a10616..58e1ca9 100644
> --- a/arch/x86/include/asm/hugetlb.h
> +++ b/arch/x86/include/asm/hugetlb.h
> @@ -41,10 +41,17 @@ static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
>  	set_pte_at(mm, addr, ptep, pte);
>  }
>  
> +extern void fix_pte_leak(struct mm_struct *mm, unsigned long addr,
> +			 pte_t *ptep);
> +
>  static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
>  					    unsigned long addr, pte_t *ptep)
>  {
> -	return ptep_get_and_clear(mm, addr, ptep);
> +	pte_t pte = ptep_get_and_clear(mm, addr, ptep);
> +
> +	if (boot_cpu_has_bug(X86_BUG_PTE_LEAK))

static_cpu_has_bug()

> +		fix_pte_leak(mm, addr, ptep);
> +	return pte;
>  }
>  
>  static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
> diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
> index 1a27396..9769355 100644
> --- a/arch/x86/include/asm/pgtable.h
> +++ b/arch/x86/include/asm/pgtable.h
> @@ -794,11 +794,16 @@ extern int ptep_test_and_clear_young(struct vm_area_struct *vma,
>  extern int ptep_clear_flush_young(struct vm_area_struct *vma,
>  				  unsigned long address, pte_t *ptep);
>  
> +extern void fix_pte_leak(struct mm_struct *mm, unsigned long addr,
> +			 pte_t *ptep);
> +
>  #define __HAVE_ARCH_PTEP_GET_AND_CLEAR
>  static inline pte_t ptep_get_and_clear(struct mm_struct *mm, unsigned long addr,
>  				       pte_t *ptep)
>  {
>  	pte_t pte = native_ptep_get_and_clear(ptep);
> +	if (boot_cpu_has_bug(X86_BUG_PTE_LEAK))

static_cpu_has_bug()

> +		fix_pte_leak(mm, addr, ptep);
>  	pte_update(mm, addr, ptep);
>  	return pte;
>  }
> diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
> index 2ee7811..6fa4079 100644
> --- a/arch/x86/include/asm/pgtable_64.h
> +++ b/arch/x86/include/asm/pgtable_64.h
> @@ -178,6 +178,12 @@ extern void cleanup_highmap(void);
>  extern void init_extra_mapping_uc(unsigned long phys, unsigned long size);
>  extern void init_extra_mapping_wb(unsigned long phys, unsigned long size);
>  
> +#define ARCH_HAS_NEEDS_SWAP_PTL 1
> +static inline bool arch_needs_swap_ptl(void)
> +{
> +       return boot_cpu_has_bug(X86_BUG_PTE_LEAK);

static_cpu_has_bug()

> +}
> +
>  #endif /* !__ASSEMBLY__ */
>  
>  #endif /* _ASM_X86_PGTABLE_64_H */
> diff --git a/arch/x86/kernel/cpu/intel.c b/arch/x86/kernel/cpu/intel.c
> index 6e2ffbe..f499513 100644
> --- a/arch/x86/kernel/cpu/intel.c
> +++ b/arch/x86/kernel/cpu/intel.c
> @@ -181,6 +181,16 @@ static void early_init_intel(struct cpuinfo_x86 *c)
>  		}
>  	}
>  
> +	if (c->x86_model == 87) {

That should be INTEL_FAM6_XEON_PHI_KNL, AFAICT.

> +		static bool printed;
> +
> +		if (!printed) {
> +			pr_info("Enabling PTE leaking workaround\n");
> +			printed = true;
> +		}

pr_info_once

> +		set_cpu_bug(c, X86_BUG_PTE_LEAK);
> +	}
> +
>  	/*
>  	 * Intel Quark Core DevMan_001.pdf section 6.4.11
>  	 * "The operating system also is required to invalidate (i.e., flush)
-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
