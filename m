Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 489166B0035
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 06:53:23 -0400 (EDT)
Received: by mail-wg0-f46.google.com with SMTP id b13so7285832wgh.5
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 03:53:22 -0700 (PDT)
Received: from mail-we0-x22f.google.com (mail-we0-x22f.google.com [2a00:1450:400c:c03::22f])
        by mx.google.com with ESMTPS id ha2si9407087wib.6.2014.04.01.03.53.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 01 Apr 2014 03:53:21 -0700 (PDT)
Received: by mail-we0-f175.google.com with SMTP id q58so5948085wes.6
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 03:53:21 -0700 (PDT)
Date: Tue, 1 Apr 2014 12:53:18 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] x86,mm: delay TLB flush after clearing accessed bit
Message-ID: <20140401105318.GA2823@gmail.com>
References: <20140331113442.0d628362@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140331113442.0d628362@annuminas.surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, shli@kernel.org, akpm@linux-foundation.org, hughd@google.com, mgorman@suse.de, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>


The speedup looks good to me!

I have one major concern (see the last item), plus a few minor nits:

* Rik van Riel <riel@redhat.com> wrote:

> Doing an immediate TLB flush after clearing the accesed bit

s/accesed/accessed

> in page tables results in a lot of extra TLB flushes when there
> is memory pressure. This used to not be a problem, when swap
> was done to spinning disks, but with SSDs it is starting to
> become an issue.

s/This used to not be a problem/This did not use to be a problem

> However, clearing the accessed bit does not lead to any
> consistency issues, there is no reason to flush the TLB
> immediately. The TLB flush can be deferred until some
> later point in time.
> 
> The lazy TLB flush code already has a data structure that
> is used at context switch time to determine whether or not
> the TLB needs to be flushed. The accessed bit clearing code
> can piggyback on top of that same data structure, allowing
> the context switch code to check whether a TLB flush needs
> to be forced when switching between the same mm, without
> incurring an additional cache miss.
> 
> In Shaohua's multi-threaded test with a lot of swap to several
> PCIe SSDs, this patch results in about 20-30% swapout speedup,
> increasing swapout speed from 1.5GB/s to 1.85GB/s.
> 
> Tested-by: Shaohua Li <shli@kernel.org>
> Signed-off-by: Rik van Riel <riel@redhat.com>
> ---
>  arch/x86/include/asm/mmu_context.h |  5 ++++-
>  arch/x86/include/asm/tlbflush.h    | 12 ++++++++++++
>  arch/x86/mm/pgtable.c              |  9 ++++++---
>  3 files changed, 22 insertions(+), 4 deletions(-)
> 
> diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
> index be12c53..665d98b 100644
> --- a/arch/x86/include/asm/mmu_context.h
> +++ b/arch/x86/include/asm/mmu_context.h
> @@ -39,6 +39,7 @@ static inline void switch_mm(struct mm_struct *prev, struct mm_struct *next,
>  #ifdef CONFIG_SMP
>  		this_cpu_write(cpu_tlbstate.state, TLBSTATE_OK);
>  		this_cpu_write(cpu_tlbstate.active_mm, next);
> +		this_cpu_write(cpu_tlbstate.force_flush, false);
>  #endif
>  		cpumask_set_cpu(cpu, mm_cpumask(next));
>  
> @@ -57,7 +58,8 @@ static inline void switch_mm(struct mm_struct *prev, struct mm_struct *next,
>  		this_cpu_write(cpu_tlbstate.state, TLBSTATE_OK);
>  		BUG_ON(this_cpu_read(cpu_tlbstate.active_mm) != next);
>  
> -		if (!cpumask_test_cpu(cpu, mm_cpumask(next))) {
> +		if (!cpumask_test_cpu(cpu, mm_cpumask(next)) ||
> +				this_cpu_read(cpu_tlbstate.force_flush)) {

Should this be unlikely() perhaps?

>  			/*
>  			 * On established mms, the mm_cpumask is only changed
>  			 * from irq context, from ptep_clear_flush() while in
> @@ -70,6 +72,7 @@ static inline void switch_mm(struct mm_struct *prev, struct mm_struct *next,
>  			 * tlb flush IPI delivery. We must reload CR3
>  			 * to make sure to use no freed page tables.
>  			 */
> +			this_cpu_write(cpu_tlbstate.force_flush, false);
>  			load_cr3(next->pgd);
>  			load_LDT_nolock(&next->context);
>  		}
> diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
> index 04905bf..f2cda2c 100644
> --- a/arch/x86/include/asm/tlbflush.h
> +++ b/arch/x86/include/asm/tlbflush.h
> @@ -151,6 +151,10 @@ static inline void reset_lazy_tlbstate(void)
>  {
>  }
>  
> +static inline void tlb_set_force_flush(int cpu)
> +{
> +}
> +
>  static inline void flush_tlb_kernel_range(unsigned long start,
>  					  unsigned long end)
>  {
> @@ -187,6 +191,7 @@ void native_flush_tlb_others(const struct cpumask *cpumask,
>  struct tlb_state {
>  	struct mm_struct *active_mm;
>  	int state;
> +	bool force_flush;
>  };
>  DECLARE_PER_CPU_SHARED_ALIGNED(struct tlb_state, cpu_tlbstate);
>  
> @@ -196,6 +201,13 @@ static inline void reset_lazy_tlbstate(void)
>  	this_cpu_write(cpu_tlbstate.active_mm, &init_mm);
>  }
>  
> +static inline void tlb_set_force_flush(int cpu)
> +{
> +	struct tlb_state *percputlb= &per_cpu(cpu_tlbstate, cpu);

s/b= /b = /

> +	if (percputlb->force_flush == false)
> +		percputlb->force_flush = true;
> +}
> +
>  #endif	/* SMP */
>  
>  #ifndef CONFIG_PARAVIRT
> diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
> index c96314a..dcd26e9 100644
> --- a/arch/x86/mm/pgtable.c
> +++ b/arch/x86/mm/pgtable.c
> @@ -4,6 +4,7 @@
>  #include <asm/pgtable.h>
>  #include <asm/tlb.h>
>  #include <asm/fixmap.h>
> +#include <asm/tlbflush.h>
>  
>  #define PGALLOC_GFP GFP_KERNEL | __GFP_NOTRACK | __GFP_REPEAT | __GFP_ZERO
>  
> @@ -399,11 +400,13 @@ int pmdp_test_and_clear_young(struct vm_area_struct *vma,
>  int ptep_clear_flush_young(struct vm_area_struct *vma,
>  			   unsigned long address, pte_t *ptep)
>  {
> -	int young;
> +	int young, cpu;
>  
>  	young = ptep_test_and_clear_young(vma, address, ptep);
> -	if (young)
> -		flush_tlb_page(vma, address);
> +	if (young) {
> +		for_each_cpu(cpu, vma->vm_mm->cpu_vm_mask_var)
> +			tlb_set_force_flush(cpu);

Hm, just to play the devil's advocate - what happens when we have a va 
that is used on a few dozen, a few hundred or a few thousand CPUs? 
Will the savings be dwarved by the O(nr_cpus_used) loop overhead?

Especially as this is touching cachelines on other CPUs and likely 
creating the worst kind of cachemisses. That can really kill 
performance.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
