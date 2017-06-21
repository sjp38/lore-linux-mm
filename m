Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5FD636B03D3
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 06:33:40 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id l34so29200204wrc.12
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 03:33:40 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id m25si1041706wrm.92.2017.06.21.03.33.38
        for <linux-mm@kvack.org>;
        Wed, 21 Jun 2017 03:33:38 -0700 (PDT)
Date: Wed, 21 Jun 2017 12:33:22 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v3 04/11] x86/mm: Give each mm TLB flush generation a
 unique ID
Message-ID: <20170621103322.pwi6koe7jee7hd63@pd.tnic>
References: <cover.1498022414.git.luto@kernel.org>
 <e2903f555bd23f8cf62f34b91895c42f7d4e40e3.1498022414.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <e2903f555bd23f8cf62f34b91895c42f7d4e40e3.1498022414.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, Jun 20, 2017 at 10:22:10PM -0700, Andy Lutomirski wrote:
> - * The x86 doesn't have a mmu context, but
> - * we put the segment information here.
> + * x86 has arch-specific MMU state beyond what lives in mm_struct.
>   */
>  typedef struct {
> +	/*
> +	 * ctx_id uniquely identifies this mm_struct.  A ctx_id will never
> +	 * be reused, and zero is not a valid ctx_id.
> +	 */
> +	u64 ctx_id;
> +
> +	/*
> +	 * Any code that needs to do any sort of TLB flushing for this
> +	 * mm will first make its changes to the page tables, then
> +	 * increment tlb_gen, then flush.  This lets the low-level
> +	 * flushing code keep track of what needs flushing.
> +	 *
> +	 * This is not used on Xen PV.
> +	 */
> +	atomic64_t tlb_gen;
> +
>  #ifdef CONFIG_MODIFY_LDT_SYSCALL
>  	struct ldt_struct *ldt;
>  #endif
> @@ -37,6 +53,11 @@ typedef struct {
>  #endif
>  } mm_context_t;
>  
> +#define INIT_MM_CONTEXT(mm)						\
> +	.context = {							\
> +		.ctx_id = 1,						\

So ctx_id of 0 is invalid?

Let's state that explicitly. We could even use it to sanity-check mms or
whatever.

> +	}
> +
>  void leave_mm(int cpu);
>  
>  #endif /* _ASM_X86_MMU_H */
> diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
> index ecfcb6643c9b..e5295d485899 100644
> --- a/arch/x86/include/asm/mmu_context.h
> +++ b/arch/x86/include/asm/mmu_context.h
> @@ -129,9 +129,14 @@ static inline void enter_lazy_tlb(struct mm_struct *mm, struct task_struct *tsk)
>  		this_cpu_write(cpu_tlbstate.state, TLBSTATE_LAZY);
>  }
>  
> +extern atomic64_t last_mm_ctx_id;

I think we prefer externs/variable defines at the beginning of the file,
not intermixed with functions.

> +
>  static inline int init_new_context(struct task_struct *tsk,
>  				   struct mm_struct *mm)
>  {
> +	mm->context.ctx_id = atomic64_inc_return(&last_mm_ctx_id);
> +	atomic64_set(&mm->context.tlb_gen, 0);
> +
>  	#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
>  	if (cpu_feature_enabled(X86_FEATURE_OSPKE)) {
>  		/* pkey 0 is the default and always allocated */
> diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
> index 50ea3482e1d1..1eb946c0507e 100644
> --- a/arch/x86/include/asm/tlbflush.h
> +++ b/arch/x86/include/asm/tlbflush.h
> @@ -57,6 +57,23 @@ static inline void invpcid_flush_all_nonglobals(void)
>  	__invpcid(0, 0, INVPCID_TYPE_ALL_NON_GLOBAL);
>  }
>  
> +static inline u64 bump_mm_tlb_gen(struct mm_struct *mm)

inc_mm_tlb_gen() I guess. git grep says like "inc" more :-)

> +{
> +	u64 new_tlb_gen;
> +
> +	/*
> +	 * Bump the generation count.  This also serves as a full barrier
> +	 * that synchronizes with switch_mm: callers are required to order

Please end function names with parentheses.

> +	 * their read of mm_cpumask after their writes to the paging
> +	 * structures.
> +	 */
> +	smp_mb__before_atomic();
> +	new_tlb_gen = atomic64_inc_return(&mm->context.tlb_gen);
> +	smp_mb__after_atomic();
> +
> +	return new_tlb_gen;
> +}
> +
>  #ifdef CONFIG_PARAVIRT
>  #include <asm/paravirt.h>
>  #else

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
