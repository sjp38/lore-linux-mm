Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id A235B6B0292
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 13:47:53 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id a199so12863160oib.2
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 10:47:53 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w68si755644otb.124.2017.06.22.10.47.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 10:47:52 -0700 (PDT)
Received: from mail-ua0-f175.google.com (mail-ua0-f175.google.com [209.85.217.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9BC9722B68
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 17:47:51 +0000 (UTC)
Received: by mail-ua0-f175.google.com with SMTP id z22so23134562uah.1
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 10:47:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170622145013.n3slk7ip6wpany5d@pd.tnic>
References: <cover.1498022414.git.luto@kernel.org> <70f3a61658aa7c1c89f4db6a4f81d8df9e396ade.1498022414.git.luto@kernel.org>
 <20170622145013.n3slk7ip6wpany5d@pd.tnic>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 22 Jun 2017 10:47:29 -0700
Message-ID: <CALCETrUA-+9ORRXFrYdyEg5ZQOEbDFrwq4uuRWDb89V49QRBWw@mail.gmail.com>
Subject: Re: [PATCH v3 06/11] x86/mm: Rework lazy TLB mode and TLB freshness tracking
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Banman <abanman@sgi.com>, Mike Travis <travis@sgi.com>, Dimitri Sivanich <sivanich@sgi.com>, Juergen Gross <jgross@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

On Thu, Jun 22, 2017 at 7:50 AM, Borislav Petkov <bp@alien8.de> wrote:
> On Tue, Jun 20, 2017 at 10:22:12PM -0700, Andy Lutomirski wrote:
>> Rewrite it entirely.  When we enter lazy mode, we simply remove the
>> cpu from mm_cpumask.  This means that we need a way to figure out
>
> s/cpu/CPU/

Done.

>
>> whether we've missed a flush when we switch back out of lazy mode.
>> I use the tlb_gen machinery to track whether a context is up to
>> date.
>>
>> Note to reviewers: this patch, my itself, looks a bit odd.  I'm
>> using an array of length 1 containing (ctx_id, tlb_gen) rather than
>> just storing tlb_gen, and making it at array isn't necessary yet.
>> I'm doing this because the next few patches add PCID support, and,
>> with PCID, we need ctx_id, and the array will end up with a length
>> greater than 1.  Making it an array now means that there will be
>> less churn and therefore less stress on your eyeballs.
>>
>> NB: This is dubious but, AFAICT, still correct on Xen and UV.
>> xen_exit_mmap() uses mm_cpumask() for nefarious purposes and this
>> patch changes the way that mm_cpumask() works.  This should be okay,
>> since Xen *also* iterates all online CPUs to find all the CPUs it
>> needs to twiddle.
>
> This whole text should be under the "---" line below if we don't want it
> in the commit message.

I figured that some future reader of this patch might actually want to
see this text, though.

>
>>
>> The UV tlbflush code is rather dated and should be changed.

And I'd definitely like the UV maintainers to notice this part, now or
in the future :)  I don't want to personally touch the UV code with a
ten-foot pole, but it really should be updated by someone who has a
chance of getting it right and being able to test it.

>> +
>> +     if (cpumask_test_cpu(cpu, mm_cpumask(mm)))
>> +             cpumask_clear_cpu(cpu, mm_cpumask(mm));
>
> It seems we haz a helper for that: cpumask_test_and_clear_cpu() which
> does BTR straightaway.

Yeah, but I'm doing this for performance.  I think that all the
various one-line helpers do a LOCKed op right away, and I think it's
faster to see if we can avoid the LOCKed op by trying an ordinary read
first.  OTOH, maybe this is misguided -- if the cacheline lives
somewhere else and we do end up needing to update it, we'll end up
first sharing it and then making it exclusive, which increases the
amount of cache coherency traffic, so maybe I'm optimizing for the
wrong thing.  What do you think?

>> -     if (this_cpu_read(cpu_tlbstate.state) == TLBSTATE_OK)
>> -             BUG();
>> +     /* Warn if we're not lazy. */
>> +     WARN_ON(cpumask_test_cpu(smp_processor_id(), mm_cpumask(loaded_mm)));
>
> We don't BUG() anymore?

We could.  But, when the whole patch series is applied, the only
caller left is a somewhat dubious Xen optimization, and if we blindly
continue executing, I think the worst that happens is that we OOPS
later or that we get segfaults when we shouldn't get segfaults.

>
>>
>>       switch_mm(NULL, &init_mm, NULL);
>>  }
>> @@ -67,133 +67,118 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
>>  {
>>       unsigned cpu = smp_processor_id();
>>       struct mm_struct *real_prev = this_cpu_read(cpu_tlbstate.loaded_mm);
>> +     u64 next_tlb_gen;
>
> Please sort function local variables declaration in a reverse christmas
> tree order:
>
>         <type> longest_variable_name;
>         <type> shorter_var_name;
>         <type> even_shorter;
>         <type> i;
>
>>
>>       /*
>> -      * NB: The scheduler will call us with prev == next when
>> -      * switching from lazy TLB mode to normal mode if active_mm
>> -      * isn't changing.  When this happens, there is no guarantee
>> -      * that CR3 (and hence cpu_tlbstate.loaded_mm) matches next.
>> +      * NB: The scheduler will call us with prev == next when switching
>> +      * from lazy TLB mode to normal mode if active_mm isn't changing.
>> +      * When this happens, we don't assume that CR3 (and hence
>> +      * cpu_tlbstate.loaded_mm) matches next.
>>        *
>>        * NB: leave_mm() calls us with prev == NULL and tsk == NULL.
>>        */
>>
>> -     this_cpu_write(cpu_tlbstate.state, TLBSTATE_OK);
>> +     /* We don't want flush_tlb_func_* to run concurrently with us. */
>> +     if (IS_ENABLED(CONFIG_PROVE_LOCKING))
>> +             WARN_ON_ONCE(!irqs_disabled());
>> +
>> +     VM_BUG_ON(read_cr3_pa() != __pa(real_prev->pgd));
>
> Why do we need that check? Can that ever happen?

It did in one particular buggy incarnation.  It would also trigger if,
say, suspend/resume corrupts CR3.  Admittedly this is unlikely, but
I'd rather catch it.  Once PCID is on, corruption seems a bit less
farfetched -- this assertion will catch anyone who accidentally does
write_cr3(read_cr3_pa()).

>
>>       if (real_prev == next) {
>> -             /*
>> -              * There's nothing to do: we always keep the per-mm control
>> -              * regs in sync with cpu_tlbstate.loaded_mm.  Just
>> -              * sanity-check mm_cpumask.
>> -              */
>> -             if (WARN_ON_ONCE(!cpumask_test_cpu(cpu, mm_cpumask(next))))
>> -                     cpumask_set_cpu(cpu, mm_cpumask(next));
>> -             return;
>> -     }
>> +             if (cpumask_test_cpu(cpu, mm_cpumask(next))) {
>> +                     /*
>> +                      * There's nothing to do: we weren't lazy, and we
>> +                      * aren't changing our mm.  We don't need to flush
>> +                      * anything, nor do we need to update CR3, CR4, or
>> +                      * LDTR.
>> +                      */
>
> Nice comment.
>
>> +                     return;
>> +             }
>> +
>> +             /* Resume remote flushes and then read tlb_gen. */
>> +             cpumask_set_cpu(cpu, mm_cpumask(next));
>> +             next_tlb_gen = atomic64_read(&next->context.tlb_gen);
>> +
>> +             VM_BUG_ON(this_cpu_read(cpu_tlbstate.ctxs[0].ctx_id) !=
>> +                       next->context.ctx_id);
>
> I guess this check should be right under the if (real_prev == next), right?

Moved.

>
>> +
>> +             if (this_cpu_read(cpu_tlbstate.ctxs[0].tlb_gen) <
>> +                 next_tlb_gen) {
>
> Yeah, let it stick out - that trailing '<' doesn't make it any nicer.
>
>> +                     /*
>> +                      * Ideally, we'd have a flush_tlb() variant that
>> +                      * takes the known CR3 value as input.  This would
>> +                      * be faster on Xen PV and on hypothetical CPUs
>> +                      * on which INVPCID is fast.
>> +                      */
>> +                     this_cpu_write(cpu_tlbstate.ctxs[0].tlb_gen,
>> +                                    next_tlb_gen);
>> +                     write_cr3(__pa(next->pgd));
>
> <---- newline here.
>
>> +                     /*
>> +                      * This gets called via leave_mm() in the idle path
>> +                      * where RCU functions differently.  Tracing normally
>> +                      * uses RCU, so we have to call the tracepoint
>> +                      * specially here.
>> +                      */
>> +                     trace_tlb_flush_rcuidle(TLB_FLUSH_ON_TASK_SWITCH,
>> +                                             TLB_FLUSH_ALL);
>> +             }
>>
>> -     if (IS_ENABLED(CONFIG_VMAP_STACK)) {
>>               /*
>> -              * If our current stack is in vmalloc space and isn't
>> -              * mapped in the new pgd, we'll double-fault.  Forcibly
>> -              * map it.
>> +              * We just exited lazy mode, which means that CR4 and/or LDTR
>> +              * may be stale.  (Changes to the required CR4 and LDTR states
>> +              * are not reflected in tlb_gen.)
>
> We need that comment because... ? I mean, we do update CR4/LDTR at the
> end of the function.

I'm trying to explain to the potentially confused reader why we fall
through and update CR4 and LDTR even if we decided not to update the
TLB.

>
>>                */
>> -             unsigned int stack_pgd_index = pgd_index(current_stack_pointer());
>> +     } else {
>> +             if (IS_ENABLED(CONFIG_VMAP_STACK)) {
>> +                     /*
>> +                      * If our current stack is in vmalloc space and isn't
>> +                      * mapped in the new pgd, we'll double-fault.  Forcibly
>> +                      * map it.
>> +                      */
>> +                     unsigned int stack_pgd_index =
>
> Shorten that var name and make it fit into 80ish cols so that the
> linebreak is gone.

Done.

>
>> +                             pgd_index(current_stack_pointer());
>> +
>> +                     pgd_t *pgd = next->pgd + stack_pgd_index;
>> +
>> +                     if (unlikely(pgd_none(*pgd)))
>> +                             set_pgd(pgd, init_mm.pgd[stack_pgd_index]);
>> +             }
>>
>> -             pgd_t *pgd = next->pgd + stack_pgd_index;
>> +             /* Stop remote flushes for the previous mm */
>> +             if (cpumask_test_cpu(cpu, mm_cpumask(real_prev)))
>> +                     cpumask_clear_cpu(cpu, mm_cpumask(real_prev));
>
> cpumask_test_and_clear_cpu()

Same as before.  I can change this, but it'll have different
performance characteristics.  This one here will optimize the case
where we go lazy and then switch away.

>
>>
>> -             if (unlikely(pgd_none(*pgd)))
>> -                     set_pgd(pgd, init_mm.pgd[stack_pgd_index]);
>> -     }
>> +             WARN_ON_ONCE(cpumask_test_cpu(cpu, mm_cpumask(next)));
>
> We warn if the next task is not lazy because...?

The next task had better not be in mm_cpumask(), but I agree that this
is minor.  I'll change it to VM_WARN_ON_ONCE.

>
>> -     this_cpu_write(cpu_tlbstate.loaded_mm, next);
>> -     this_cpu_write(cpu_tlbstate.ctxs[0].ctx_id, next->context.ctx_id);
>> -     this_cpu_write(cpu_tlbstate.ctxs[0].tlb_gen,
>> -                    atomic64_read(&next->context.tlb_gen));
>> +             /*
>> +              * Start remote flushes and then read tlb_gen.
>> +              */
>> +             cpumask_set_cpu(cpu, mm_cpumask(next));
>> +             next_tlb_gen = atomic64_read(&next->context.tlb_gen);
>>
>> -     WARN_ON_ONCE(cpumask_test_cpu(cpu, mm_cpumask(next)));
>> -     cpumask_set_cpu(cpu, mm_cpumask(next));
>> +             VM_BUG_ON(this_cpu_read(cpu_tlbstate.ctxs[0].ctx_id) ==
>> +                       next->context.ctx_id);
>
> Also put it as the first statement after the else { ?

Done.

>
>> -     /*
>> -      * Re-load page tables.
>> -      *
>> -      * This logic has an ordering constraint:
>> -      *
>> -      *  CPU 0: Write to a PTE for 'next'
>> -      *  CPU 0: load bit 1 in mm_cpumask.  if nonzero, send IPI.
>> -      *  CPU 1: set bit 1 in next's mm_cpumask
>> -      *  CPU 1: load from the PTE that CPU 0 writes (implicit)
>> -      *
>> -      * We need to prevent an outcome in which CPU 1 observes
>> -      * the new PTE value and CPU 0 observes bit 1 clear in
>> -      * mm_cpumask.  (If that occurs, then the IPI will never
>> -      * be sent, and CPU 0's TLB will contain a stale entry.)
>> -      *
>> -      * The bad outcome can occur if either CPU's load is
>> -      * reordered before that CPU's store, so both CPUs must
>> -      * execute full barriers to prevent this from happening.
>> -      *
>> -      * Thus, switch_mm needs a full barrier between the
>> -      * store to mm_cpumask and any operation that could load
>> -      * from next->pgd.  TLB fills are special and can happen
>> -      * due to instruction fetches or for no reason at all,
>> -      * and neither LOCK nor MFENCE orders them.
>> -      * Fortunately, load_cr3() is serializing and gives the
>> -      * ordering guarantee we need.
>> -      */
>> -     load_cr3(next->pgd);
>> -
>> -     /*
>> -      * This gets called via leave_mm() in the idle path where RCU
>> -      * functions differently.  Tracing normally uses RCU, so we have to
>> -      * call the tracepoint specially here.
>> -      */
>> -     trace_tlb_flush_rcuidle(TLB_FLUSH_ON_TASK_SWITCH, TLB_FLUSH_ALL);
>> +             this_cpu_write(cpu_tlbstate.ctxs[0].ctx_id,
>> +                            next->context.ctx_id);
>> +             this_cpu_write(cpu_tlbstate.ctxs[0].tlb_gen,
>> +                            next_tlb_gen);
>
> Yeah, just let all those three stick out.
>
> Also, no:
>
>                 if (this_cpu_read(cpu_tlbstate.ctxs[0].tlb_gen) <
>                     next_tlb_gen) {
>
> check?

What would the check do?  Without PCID, we don't have a choice as to
whether we flush.

>
>> +             this_cpu_write(cpu_tlbstate.loaded_mm, next);
>> +             write_cr3(__pa(next->pgd));
>>
>> -     /* Stop flush ipis for the previous mm */
>> -     WARN_ON_ONCE(!cpumask_test_cpu(cpu, mm_cpumask(real_prev)) &&
>> -                  real_prev != &init_mm);
>> -     cpumask_clear_cpu(cpu, mm_cpumask(real_prev));
>> +             /*
>> +              * This gets called via leave_mm() in the idle path where RCU
>> +              * functions differently.  Tracing normally uses RCU, so we
>> +              * have to call the tracepoint specially here.
>> +              */
>> +             trace_tlb_flush_rcuidle(TLB_FLUSH_ON_TASK_SWITCH,
>> +                                     TLB_FLUSH_ALL);
>> +     }
>
> That's repeated as in the if-branch above. Move it out I guess.

I would have, but it changes later in the series and this reduces churn.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
