Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id BDB0B6B0279
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 10:50:34 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id x23so5219233wrb.6
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 07:50:34 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id y6si1616130wrd.379.2017.06.22.07.50.33
        for <linux-mm@kvack.org>;
        Thu, 22 Jun 2017 07:50:33 -0700 (PDT)
Date: Thu, 22 Jun 2017 16:50:13 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v3 06/11] x86/mm: Rework lazy TLB mode and TLB freshness
 tracking
Message-ID: <20170622145013.n3slk7ip6wpany5d@pd.tnic>
References: <cover.1498022414.git.luto@kernel.org>
 <70f3a61658aa7c1c89f4db6a4f81d8df9e396ade.1498022414.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <70f3a61658aa7c1c89f4db6a4f81d8df9e396ade.1498022414.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Banman <abanman@sgi.com>, Mike Travis <travis@sgi.com>, Dimitri Sivanich <sivanich@sgi.com>, Juergen Gross <jgross@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

On Tue, Jun 20, 2017 at 10:22:12PM -0700, Andy Lutomirski wrote:
> x86's lazy TLB mode used to be fairly weak -- it would switch to
> init_mm the first time it tried to flush a lazy TLB.  This meant an
> unnecessary CR3 write and, if the flush was remote, an unnecessary
> IPI.
> 
> Rewrite it entirely.  When we enter lazy mode, we simply remove the
> cpu from mm_cpumask.  This means that we need a way to figure out

s/cpu/CPU/

> whether we've missed a flush when we switch back out of lazy mode.
> I use the tlb_gen machinery to track whether a context is up to
> date.
> 
> Note to reviewers: this patch, my itself, looks a bit odd.  I'm
> using an array of length 1 containing (ctx_id, tlb_gen) rather than
> just storing tlb_gen, and making it at array isn't necessary yet.
> I'm doing this because the next few patches add PCID support, and,
> with PCID, we need ctx_id, and the array will end up with a length
> greater than 1.  Making it an array now means that there will be
> less churn and therefore less stress on your eyeballs.
> 
> NB: This is dubious but, AFAICT, still correct on Xen and UV.
> xen_exit_mmap() uses mm_cpumask() for nefarious purposes and this
> patch changes the way that mm_cpumask() works.  This should be okay,
> since Xen *also* iterates all online CPUs to find all the CPUs it
> needs to twiddle.

This whole text should be under the "---" line below if we don't want it
in the commit message.

> 
> The UV tlbflush code is rather dated and should be changed.
> 
> Cc: Andrew Banman <abanman@sgi.com>
> Cc: Mike Travis <travis@sgi.com>
> Cc: Dimitri Sivanich <sivanich@sgi.com>
> Cc: Juergen Gross <jgross@suse.com>
> Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> Signed-off-by: Andy Lutomirski <luto@kernel.org>
> ---
>  arch/x86/include/asm/mmu_context.h |   6 +-
>  arch/x86/include/asm/tlbflush.h    |   4 -
>  arch/x86/mm/init.c                 |   1 -
>  arch/x86/mm/tlb.c                  | 227 +++++++++++++++++++------------------
>  arch/x86/xen/mmu_pv.c              |   3 +-
>  5 files changed, 119 insertions(+), 122 deletions(-)
> 
> diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
> index e5295d485899..69a4f1ee86ac 100644
> --- a/arch/x86/include/asm/mmu_context.h
> +++ b/arch/x86/include/asm/mmu_context.h
> @@ -125,8 +125,10 @@ static inline void switch_ldt(struct mm_struct *prev, struct mm_struct *next)
>  
>  static inline void enter_lazy_tlb(struct mm_struct *mm, struct task_struct *tsk)
>  {
> -	if (this_cpu_read(cpu_tlbstate.state) == TLBSTATE_OK)
> -		this_cpu_write(cpu_tlbstate.state, TLBSTATE_LAZY);
> +	int cpu = smp_processor_id();
> +
> +	if (cpumask_test_cpu(cpu, mm_cpumask(mm)))
> +		cpumask_clear_cpu(cpu, mm_cpumask(mm));

It seems we haz a helper for that: cpumask_test_and_clear_cpu() which
does BTR straightaway.

>  extern atomic64_t last_mm_ctx_id;
> diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
> index 4f6c30d6ec39..87b13e51e867 100644
> --- a/arch/x86/include/asm/tlbflush.h
> +++ b/arch/x86/include/asm/tlbflush.h
> @@ -95,7 +95,6 @@ struct tlb_state {
>  	 * mode even if we've already switched back to swapper_pg_dir.
>  	 */
>  	struct mm_struct *loaded_mm;
> -	int state;
>  
>  	/*
>  	 * Access to this CR4 shadow and to H/W CR4 is protected by
> @@ -310,9 +309,6 @@ static inline void flush_tlb_page(struct vm_area_struct *vma, unsigned long a)
>  void native_flush_tlb_others(const struct cpumask *cpumask,
>  			     const struct flush_tlb_info *info);
>  
> -#define TLBSTATE_OK	1
> -#define TLBSTATE_LAZY	2
> -
>  static inline void arch_tlbbatch_add_mm(struct arch_tlbflush_unmap_batch *batch,
>  					struct mm_struct *mm)
>  {
> diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
> index 88ee942cb47d..7d6fa4676af9 100644
> --- a/arch/x86/mm/init.c
> +++ b/arch/x86/mm/init.c
> @@ -812,7 +812,6 @@ void __init zone_sizes_init(void)
>  
>  DEFINE_PER_CPU_SHARED_ALIGNED(struct tlb_state, cpu_tlbstate) = {
>  	.loaded_mm = &init_mm,
> -	.state = 0,
>  	.cr4 = ~0UL,	/* fail hard if we screw up cr4 shadow initialization */
>  };
>  EXPORT_SYMBOL_GPL(cpu_tlbstate);
> diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
> index 9f5ef7a5e74a..fea2b07ac7d8 100644
> --- a/arch/x86/mm/tlb.c
> +++ b/arch/x86/mm/tlb.c
> @@ -45,8 +45,8 @@ void leave_mm(int cpu)
>  	if (loaded_mm == &init_mm)
>  		return;
>  
> -	if (this_cpu_read(cpu_tlbstate.state) == TLBSTATE_OK)
> -		BUG();
> +	/* Warn if we're not lazy. */
> +	WARN_ON(cpumask_test_cpu(smp_processor_id(), mm_cpumask(loaded_mm)));

We don't BUG() anymore?

>  
>  	switch_mm(NULL, &init_mm, NULL);
>  }
> @@ -67,133 +67,118 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
>  {
>  	unsigned cpu = smp_processor_id();
>  	struct mm_struct *real_prev = this_cpu_read(cpu_tlbstate.loaded_mm);
> +	u64 next_tlb_gen;

Please sort function local variables declaration in a reverse christmas
tree order:

	<type> longest_variable_name;
	<type> shorter_var_name;
	<type> even_shorter;
	<type> i;

>  
>  	/*
> -	 * NB: The scheduler will call us with prev == next when
> -	 * switching from lazy TLB mode to normal mode if active_mm
> -	 * isn't changing.  When this happens, there is no guarantee
> -	 * that CR3 (and hence cpu_tlbstate.loaded_mm) matches next.
> +	 * NB: The scheduler will call us with prev == next when switching
> +	 * from lazy TLB mode to normal mode if active_mm isn't changing.
> +	 * When this happens, we don't assume that CR3 (and hence
> +	 * cpu_tlbstate.loaded_mm) matches next.
>  	 *
>  	 * NB: leave_mm() calls us with prev == NULL and tsk == NULL.
>  	 */
>  
> -	this_cpu_write(cpu_tlbstate.state, TLBSTATE_OK);
> +	/* We don't want flush_tlb_func_* to run concurrently with us. */
> +	if (IS_ENABLED(CONFIG_PROVE_LOCKING))
> +		WARN_ON_ONCE(!irqs_disabled());
> +
> +	VM_BUG_ON(read_cr3_pa() != __pa(real_prev->pgd));

Why do we need that check? Can that ever happen?

>  	if (real_prev == next) {
> -		/*
> -		 * There's nothing to do: we always keep the per-mm control
> -		 * regs in sync with cpu_tlbstate.loaded_mm.  Just
> -		 * sanity-check mm_cpumask.
> -		 */
> -		if (WARN_ON_ONCE(!cpumask_test_cpu(cpu, mm_cpumask(next))))
> -			cpumask_set_cpu(cpu, mm_cpumask(next));
> -		return;
> -	}
> +		if (cpumask_test_cpu(cpu, mm_cpumask(next))) {
> +			/*
> +			 * There's nothing to do: we weren't lazy, and we
> +			 * aren't changing our mm.  We don't need to flush
> +			 * anything, nor do we need to update CR3, CR4, or
> +			 * LDTR.
> +			 */

Nice comment.

> +			return;
> +		}
> +
> +		/* Resume remote flushes and then read tlb_gen. */
> +		cpumask_set_cpu(cpu, mm_cpumask(next));
> +		next_tlb_gen = atomic64_read(&next->context.tlb_gen);
> +
> +		VM_BUG_ON(this_cpu_read(cpu_tlbstate.ctxs[0].ctx_id) !=
> +			  next->context.ctx_id);

I guess this check should be right under the if (real_prev == next), right?

> +
> +		if (this_cpu_read(cpu_tlbstate.ctxs[0].tlb_gen) <
> +		    next_tlb_gen) {

Yeah, let it stick out - that trailing '<' doesn't make it any nicer.

> +			/*
> +			 * Ideally, we'd have a flush_tlb() variant that
> +			 * takes the known CR3 value as input.  This would
> +			 * be faster on Xen PV and on hypothetical CPUs
> +			 * on which INVPCID is fast.
> +			 */
> +			this_cpu_write(cpu_tlbstate.ctxs[0].tlb_gen,
> +				       next_tlb_gen);
> +			write_cr3(__pa(next->pgd));

<---- newline here.

> +			/*
> +			 * This gets called via leave_mm() in the idle path
> +			 * where RCU functions differently.  Tracing normally
> +			 * uses RCU, so we have to call the tracepoint
> +			 * specially here.
> +			 */
> +			trace_tlb_flush_rcuidle(TLB_FLUSH_ON_TASK_SWITCH,
> +						TLB_FLUSH_ALL);
> +		}
>  
> -	if (IS_ENABLED(CONFIG_VMAP_STACK)) {
>  		/*
> -		 * If our current stack is in vmalloc space and isn't
> -		 * mapped in the new pgd, we'll double-fault.  Forcibly
> -		 * map it.
> +		 * We just exited lazy mode, which means that CR4 and/or LDTR
> +		 * may be stale.  (Changes to the required CR4 and LDTR states
> +		 * are not reflected in tlb_gen.)

We need that comment because... ? I mean, we do update CR4/LDTR at the
end of the function.

>  		 */
> -		unsigned int stack_pgd_index = pgd_index(current_stack_pointer());
> +	} else {
> +		if (IS_ENABLED(CONFIG_VMAP_STACK)) {
> +			/*
> +			 * If our current stack is in vmalloc space and isn't
> +			 * mapped in the new pgd, we'll double-fault.  Forcibly
> +			 * map it.
> +			 */
> +			unsigned int stack_pgd_index =

Shorten that var name and make it fit into 80ish cols so that the
linebreak is gone.

> +				pgd_index(current_stack_pointer());
> +
> +			pgd_t *pgd = next->pgd + stack_pgd_index;
> +
> +			if (unlikely(pgd_none(*pgd)))
> +				set_pgd(pgd, init_mm.pgd[stack_pgd_index]);
> +		}
>  
> -		pgd_t *pgd = next->pgd + stack_pgd_index;
> +		/* Stop remote flushes for the previous mm */
> +		if (cpumask_test_cpu(cpu, mm_cpumask(real_prev)))
> +			cpumask_clear_cpu(cpu, mm_cpumask(real_prev));

cpumask_test_and_clear_cpu()

>  
> -		if (unlikely(pgd_none(*pgd)))
> -			set_pgd(pgd, init_mm.pgd[stack_pgd_index]);
> -	}
> +		WARN_ON_ONCE(cpumask_test_cpu(cpu, mm_cpumask(next)));

We warn if the next task is not lazy because...?

> -	this_cpu_write(cpu_tlbstate.loaded_mm, next);
> -	this_cpu_write(cpu_tlbstate.ctxs[0].ctx_id, next->context.ctx_id);
> -	this_cpu_write(cpu_tlbstate.ctxs[0].tlb_gen,
> -		       atomic64_read(&next->context.tlb_gen));
> +		/*
> +		 * Start remote flushes and then read tlb_gen.
> +		 */
> +		cpumask_set_cpu(cpu, mm_cpumask(next));
> +		next_tlb_gen = atomic64_read(&next->context.tlb_gen);
>  
> -	WARN_ON_ONCE(cpumask_test_cpu(cpu, mm_cpumask(next)));
> -	cpumask_set_cpu(cpu, mm_cpumask(next));
> +		VM_BUG_ON(this_cpu_read(cpu_tlbstate.ctxs[0].ctx_id) ==
> +			  next->context.ctx_id);

Also put it as the first statement after the else { ?

> -	/*
> -	 * Re-load page tables.
> -	 *
> -	 * This logic has an ordering constraint:
> -	 *
> -	 *  CPU 0: Write to a PTE for 'next'
> -	 *  CPU 0: load bit 1 in mm_cpumask.  if nonzero, send IPI.
> -	 *  CPU 1: set bit 1 in next's mm_cpumask
> -	 *  CPU 1: load from the PTE that CPU 0 writes (implicit)
> -	 *
> -	 * We need to prevent an outcome in which CPU 1 observes
> -	 * the new PTE value and CPU 0 observes bit 1 clear in
> -	 * mm_cpumask.  (If that occurs, then the IPI will never
> -	 * be sent, and CPU 0's TLB will contain a stale entry.)
> -	 *
> -	 * The bad outcome can occur if either CPU's load is
> -	 * reordered before that CPU's store, so both CPUs must
> -	 * execute full barriers to prevent this from happening.
> -	 *
> -	 * Thus, switch_mm needs a full barrier between the
> -	 * store to mm_cpumask and any operation that could load
> -	 * from next->pgd.  TLB fills are special and can happen
> -	 * due to instruction fetches or for no reason at all,
> -	 * and neither LOCK nor MFENCE orders them.
> -	 * Fortunately, load_cr3() is serializing and gives the
> -	 * ordering guarantee we need.
> -	 */
> -	load_cr3(next->pgd);
> -
> -	/*
> -	 * This gets called via leave_mm() in the idle path where RCU
> -	 * functions differently.  Tracing normally uses RCU, so we have to
> -	 * call the tracepoint specially here.
> -	 */
> -	trace_tlb_flush_rcuidle(TLB_FLUSH_ON_TASK_SWITCH, TLB_FLUSH_ALL);
> +		this_cpu_write(cpu_tlbstate.ctxs[0].ctx_id,
> +			       next->context.ctx_id);
> +		this_cpu_write(cpu_tlbstate.ctxs[0].tlb_gen,
> +			       next_tlb_gen);

Yeah, just let all those three stick out.

Also, no:

                if (this_cpu_read(cpu_tlbstate.ctxs[0].tlb_gen) <
                    next_tlb_gen) {

check?

> +		this_cpu_write(cpu_tlbstate.loaded_mm, next);
> +		write_cr3(__pa(next->pgd));
>  
> -	/* Stop flush ipis for the previous mm */
> -	WARN_ON_ONCE(!cpumask_test_cpu(cpu, mm_cpumask(real_prev)) &&
> -		     real_prev != &init_mm);
> -	cpumask_clear_cpu(cpu, mm_cpumask(real_prev));
> +		/*
> +		 * This gets called via leave_mm() in the idle path where RCU
> +		 * functions differently.  Tracing normally uses RCU, so we
> +		 * have to call the tracepoint specially here.
> +		 */
> +		trace_tlb_flush_rcuidle(TLB_FLUSH_ON_TASK_SWITCH,
> +					TLB_FLUSH_ALL);
> +	}

That's repeated as in the if-branch above. Move it out I guess.

>  
> -	/* Load per-mm CR4 and LDTR state */
>  	load_mm_cr4(next);
>  	switch_ldt(real_prev, next);
>  }
-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
