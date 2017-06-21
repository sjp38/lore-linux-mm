Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E57ED6B02B4
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 14:44:42 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id s74so166293333pfe.10
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 11:44:42 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id h71si2059086wmi.1.2017.06.21.11.44.41
        for <linux-mm@kvack.org>;
        Wed, 21 Jun 2017 11:44:41 -0700 (PDT)
Date: Wed, 21 Jun 2017 20:44:24 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v3 05/11] x86/mm: Track the TLB's tlb_gen and update the
 flushing algorithm
Message-ID: <20170621184424.eixb2jdyy66xq4hg@pd.tnic>
References: <cover.1498022414.git.luto@kernel.org>
 <91f24a6145b2077f992902891f8fa59abe5c8696.1498022414.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <91f24a6145b2077f992902891f8fa59abe5c8696.1498022414.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, Jun 20, 2017 at 10:22:11PM -0700, Andy Lutomirski wrote:
> There are two kernel features that would benefit from tracking
> how up-to-date each CPU's TLB is in the case where IPIs aren't keeping
> it up to date in real time:
> 
>  - Lazy mm switching currently works by switching to init_mm when
>    it would otherwise flush.  This is wasteful: there isn't fundamentally
>    any need to update CR3 at all when going lazy or when returning from
>    lazy mode, nor is there any need to receive flush IPIs at all.  Instead,
>    we should just stop trying to keep the TLB coherent when we go lazy and,
>    when unlazying, check whether we missed any flushes.
> 
>  - PCID will let us keep recent user contexts alive in the TLB.  If we
>    start doing this, we need a way to decide whether those contexts are
>    up to date.
> 
> On some paravirt systems, remote TLBs can be flushed without IPIs.
> This won't update the target CPUs' tlb_gens, which may cause
> unnecessary local flushes later on.  We can address this if it becomes
> a problem by carefully updating the target CPU's tlb_gen directly.
> 
> By itself, this patch is a very minor optimization that avoids
> unnecessary flushes when multiple TLB flushes targetting the same CPU
> race.
> 
> Signed-off-by: Andy Lutomirski <luto@kernel.org>
> ---
>  arch/x86/include/asm/tlbflush.h | 37 +++++++++++++++++++
>  arch/x86/mm/tlb.c               | 79 +++++++++++++++++++++++++++++++++++++----
>  2 files changed, 109 insertions(+), 7 deletions(-)

...

> diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
> index 6d9d37323a43..9f5ef7a5e74a 100644
> --- a/arch/x86/mm/tlb.c
> +++ b/arch/x86/mm/tlb.c
> @@ -105,6 +105,9 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
>  	}
>  
>  	this_cpu_write(cpu_tlbstate.loaded_mm, next);
> +	this_cpu_write(cpu_tlbstate.ctxs[0].ctx_id, next->context.ctx_id);
> +	this_cpu_write(cpu_tlbstate.ctxs[0].tlb_gen,
> +		       atomic64_read(&next->context.tlb_gen));

Just let it stick out:

	this_cpu_write(cpu_tlbstate.ctxs[0].ctx_id,  next->context.ctx_id);
	this_cpu_write(cpu_tlbstate.ctxs[0].tlb_gen, atomic64_read(&next->context.tlb_gen));

Should be a bit better readable this way.

>  
>  	WARN_ON_ONCE(cpumask_test_cpu(cpu, mm_cpumask(next)));
>  	cpumask_set_cpu(cpu, mm_cpumask(next));
> @@ -194,20 +197,73 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
>  static void flush_tlb_func_common(const struct flush_tlb_info *f,
>  				  bool local, enum tlb_flush_reason reason)
>  {
> +	struct mm_struct *loaded_mm = this_cpu_read(cpu_tlbstate.loaded_mm);
> +
> +	/*
> +	 * Our memory ordering requirement is that any TLB fills that
> +	 * happen after we flush the TLB are ordered after we read
> +	 * active_mm's tlb_gen.  We don't need any explicit barrier
> +	 * because all x86 flush operations are serializing and the
> +	 * atomic64_read operation won't be reordered by the compiler.
> +	 */
> +	u64 mm_tlb_gen = atomic64_read(&loaded_mm->context.tlb_gen);
> +	u64 local_tlb_gen = this_cpu_read(cpu_tlbstate.ctxs[0].tlb_gen);
> +
>  	/* This code cannot presently handle being reentered. */
>  	VM_WARN_ON(!irqs_disabled());
>  
> +	VM_WARN_ON(this_cpu_read(cpu_tlbstate.ctxs[0].ctx_id) !=
> +		   loaded_mm->context.ctx_id);
> +
>  	if (this_cpu_read(cpu_tlbstate.state) != TLBSTATE_OK) {
> +		/*
> +		 * leave_mm() is adequate to handle any type of flush, and
> +		 * we would prefer not to receive further IPIs.
> +		 */
>  		leave_mm(smp_processor_id());
>  		return;
>  	}
>  
> -	if (f->end == TLB_FLUSH_ALL) {
> -		local_flush_tlb();
> -		if (local)
> -			count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
> -		trace_tlb_flush(reason, TLB_FLUSH_ALL);
> -	} else {
> +	if (local_tlb_gen == mm_tlb_gen) {

	if (unlikely(... 

maybe?

Sounds to me like the concurrent flushes case would be the
uncommon one...

> +		/*
> +		 * There's nothing to do: we're already up to date.  This can
> +		 * happen if two concurrent flushes happen -- the first IPI to
> +		 * be handled can catch us all the way up, leaving no work for
> +		 * the second IPI to be handled.
> +		 */
> +		return;
> +	}


> +
> +	WARN_ON_ONCE(local_tlb_gen > mm_tlb_gen);
> +	WARN_ON_ONCE(f->new_tlb_gen > mm_tlb_gen);
> +
> +	/*
> +	 * If we get to this point, we know that our TLB is out of date.
> +	 * This does not strictly imply that we need to flush (it's
> +	 * possible that f->new_tlb_gen <= local_tlb_gen), but we're
> +	 * going to need to flush in the very near future, so we might
> +	 * as well get it over with.
> +	 *
> +	 * The only question is whether to do a full or partial flush.
> +	 *
> +	 * A partial TLB flush is safe and worthwhile if two conditions are
> +	 * met:
> +	 *
> +	 * 1. We wouldn't be skipping a tlb_gen.  If the requester bumped
> +	 *    the mm's tlb_gen from p to p+1, a partial flush is only correct
> +	 *    if we would be bumping the local CPU's tlb_gen from p to p+1 as
> +	 *    well.
> +	 *
> +	 * 2. If there are no more flushes on their way.  Partial TLB
> +	 *    flushes are not all that much cheaper than full TLB
> +	 *    flushes, so it seems unlikely that it would be a
> +	 *    performance win to do a partial flush if that won't bring
> +	 *    our TLB fully up to date.
> +	 */
> +	if (f->end != TLB_FLUSH_ALL &&
> +	    f->new_tlb_gen == local_tlb_gen + 1 &&
> +	    f->new_tlb_gen == mm_tlb_gen) {

I'm certainly still missing something here:

We have f->new_tlb_gen and mm_tlb_gen to control the flushing, i.e., we
do once

	bump_mm_tlb_gen(mm);

and once

	info.new_tlb_gen = bump_mm_tlb_gen(mm);

and in both cases, the bumping is done on mm->context.tlb_gen.

So why isn't that enough to do the flushing and we have to consult
info.new_tlb_gen too?

> +		/* Partial flush */
>  		unsigned long addr;
>  		unsigned long nr_pages = (f->end - f->start) >> PAGE_SHIFT;

<---- newline here.

>  		addr = f->start;
> @@ -218,7 +274,16 @@ static void flush_tlb_func_common(const struct flush_tlb_info *f,
>  		if (local)
>  			count_vm_tlb_events(NR_TLB_LOCAL_FLUSH_ONE, nr_pages);
>  		trace_tlb_flush(reason, nr_pages);
> +	} else {
> +		/* Full flush. */
> +		local_flush_tlb();
> +		if (local)
> +			count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
> +		trace_tlb_flush(reason, TLB_FLUSH_ALL);
>  	}
> +
> +	/* Both paths above update our state to mm_tlb_gen. */
> +	this_cpu_write(cpu_tlbstate.ctxs[0].tlb_gen, mm_tlb_gen);
>  }
>  
>  static void flush_tlb_func_local(void *info, enum tlb_flush_reason reason)

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
