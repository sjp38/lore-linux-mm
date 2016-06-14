Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id DD1996B0253
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 13:19:59 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id he1so123559858pac.0
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 10:19:59 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id sq4si25190803pab.243.2016.06.14.10.19.58
        for <linux-mm@kvack.org>;
        Tue, 14 Jun 2016 10:19:59 -0700 (PDT)
Subject: Re: [PATCH] Linux VM workaround for Knights Landing A/D leak
References: <1465919919-2093-1-git-send-email-lukasz.anaczkowski@intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <57603CBE.7090702@linux.intel.com>
Date: Tue, 14 Jun 2016 10:19:58 -0700
MIME-Version: 1.0
In-Reply-To: <1465919919-2093-1-git-send-email-lukasz.anaczkowski@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lukasz Anaczkowski <lukasz.anaczkowski@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, ak@linux.intel.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, akpm@linux-foundation.org, hpa@zytor.com
Cc: harish.srinivasappa@intel.com, lukasz.odzioba@intel.com

...
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
> +		fix_pte_leak(mm, addr, ptep);
>  	pte_update(mm, addr, ptep);
>  	return pte;
>  }

Doesn't hugetlb.h somehow #include pgtable.h?  So why double-define
fix_pte_leak()?

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
> +}
> +
>  #endif /* !__ASSEMBLY__ */

I think we need a comment on this sucker.  I'm not sure we should lean
solely on the commit message to record why we need this until the end of
time.

Or, refer over to fix_pte_leak() for a full description of what is going on.

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
> +		static bool printed;
> +
> +		if (!printed) {
> +			pr_info("Enabling PTE leaking workaround\n");
> +			printed = true;
> +		}
> +		set_cpu_bug(c, X86_BUG_PTE_LEAK);
> +	}

Please use the macros in here for the model id:

> http://git.kernel.org/cgit/linux/kernel/git/tip/tip.git/tree/arch/x86/include/asm/intel-family.h

We also probably want to prefix the pr_info() with something like
"x86/intel:".

> +/*
> + * Workaround for KNL issue:

Please be specific about what this "KNL issue" *is*.  Refer to the
public documentation of the erratum, please.

> + * A thread that is going to page fault due to P=0, may still
> + * non atomically set A or D bits, which could corrupt swap entries.
> + * Always flush the other CPUs and clear the PTE again to avoid
> + * this leakage. We are excluded using the pagetable lock.
> + */
> +
> +void fix_pte_leak(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
> +{
> +	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids) {
> +		trace_tlb_flush(TLB_LOCAL_SHOOTDOWN, TLB_FLUSH_ALL);
> +		flush_tlb_others(mm_cpumask(mm), mm, addr,
> +				 addr + PAGE_SIZE);
> +		mb();
> +		set_pte(ptep, __pte(0));
> +	}
> +}

I think the comment here is a bit sparse.  Can we add some more details,
like:

	Entering here, the current CPU just cleared the PTE.  But,
	another thread may have raced and set the A or D bits, or be
	_about_ to set the bits.  Shooting their TLB entry down will
	ensure they see the cleared PTE and will not set A or D.

and by the set_pte():

	Clear the PTE one more time, in case the other thread set A/D
	before we sent the TLB flush.

>  #endif /* CONFIG_SMP */
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 5df5feb..5c80fe09 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2404,6 +2404,10 @@ static inline bool debug_guardpage_enabled(void) { return false; }
>  static inline bool page_is_guard(struct page *page) { return false; }
>  #endif /* CONFIG_DEBUG_PAGEALLOC */
>  
> +#ifndef ARCH_HAS_NEEDS_SWAP_PTL
> +static inline bool arch_needs_swap_ptl(void) { return false; }
> +#endif
> +
>  #if MAX_NUMNODES > 1
>  void __init setup_nr_node_ids(void);
>  #else
> diff --git a/mm/memory.c b/mm/memory.c
> index 15322b7..0d6ef39 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1960,7 +1960,8 @@ static inline int pte_unmap_same(struct mm_struct *mm, pmd_t *pmd,
>  {
>  	int same = 1;
>  #if defined(CONFIG_SMP) || defined(CONFIG_PREEMPT)
> -	if (sizeof(pte_t) > sizeof(unsigned long)) {
> +	if (arch_needs_swap_ptl() ||
> +	    sizeof(pte_t) > sizeof(unsigned long)) {
>  		spinlock_t *ptl = pte_lockptr(mm, pmd);
>  		spin_lock(ptl);
>  		same = pte_same(*page_table, orig_pte);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
