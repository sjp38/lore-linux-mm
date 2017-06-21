Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5E23A6B0408
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 11:11:41 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id o27so121449853otd.15
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 08:11:41 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id n4si890231oia.45.2017.06.21.08.11.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 08:11:38 -0700 (PDT)
Received: from mail-ua0-f182.google.com (mail-ua0-f182.google.com [209.85.217.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2F28E214F0
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 15:11:37 +0000 (UTC)
Received: by mail-ua0-f182.google.com with SMTP id g40so115361621uaa.3
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 08:11:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1706211007080.2328@nanos>
References: <cover.1498022414.git.luto@kernel.org> <91f24a6145b2077f992902891f8fa59abe5c8696.1498022414.git.luto@kernel.org>
 <alpine.DEB.2.20.1706211007080.2328@nanos>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 21 Jun 2017 08:11:15 -0700
Message-ID: <CALCETrX9z1pM0cqSFrt7rozENy4pbFz2gvorYtBa212KsVw5Mg@mail.gmail.com>
Subject: Re: [PATCH v3 05/11] x86/mm: Track the TLB's tlb_gen and update the
 flushing algorithm
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Wed, Jun 21, 2017 at 1:32 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> On Tue, 20 Jun 2017, Andy Lutomirski wrote:
>>  struct flush_tlb_info {
>> +     /*
>> +      * We support several kinds of flushes.
>> +      *
>> +      * - Fully flush a single mm.  flush_mm will be set, flush_end will be
>
> flush_mm is the *mm member in the struct, right? You might rename that as a
> preparatory step so comments and implementation match.

The comment is outdated.  Fixed now.

>
>> +      *   TLB_FLUSH_ALL, and new_tlb_gen will be the tlb_gen to which the
>> +      *   IPI sender is trying to catch us up.
>> +      *
>> +      * - Partially flush a single mm.  flush_mm will be set, flush_start
>> +      *   and flush_end will indicate the range, and new_tlb_gen will be
>> +      *   set such that the changes between generation new_tlb_gen-1 and
>> +      *   new_tlb_gen are entirely contained in the indicated range.
>> +      *
>> +      * - Fully flush all mms whose tlb_gens have been updated.  flush_mm
>> +      *   will be NULL, flush_end will be TLB_FLUSH_ALL, and new_tlb_gen
>> +      *   will be zero.
>> +      */
>>       struct mm_struct *mm;
>>       unsigned long start;
>>       unsigned long end;
>> +     u64 new_tlb_gen;
>
> Nit. While at it could you please make that struct tabular aligned as we
> usually do in x86?

Sure.

>
>>  static void flush_tlb_func_common(const struct flush_tlb_info *f,
>>                                 bool local, enum tlb_flush_reason reason)
>>  {
>> +     struct mm_struct *loaded_mm = this_cpu_read(cpu_tlbstate.loaded_mm);
>> +
>> +     /*
>> +      * Our memory ordering requirement is that any TLB fills that
>> +      * happen after we flush the TLB are ordered after we read
>> +      * active_mm's tlb_gen.  We don't need any explicit barrier
>> +      * because all x86 flush operations are serializing and the
>> +      * atomic64_read operation won't be reordered by the compiler.
>> +      */
>
> Can you please move the comment above the loaded_mm assignment?

I'll move it above the function entirely.  It's more of a general
comment about how the function works than any particular part of the
function.

>
>> +     u64 mm_tlb_gen = atomic64_read(&loaded_mm->context.tlb_gen);
>> +     u64 local_tlb_gen = this_cpu_read(cpu_tlbstate.ctxs[0].tlb_gen);
>> +
>>       /* This code cannot presently handle being reentered. */
>>       VM_WARN_ON(!irqs_disabled());
>>
>> +     VM_WARN_ON(this_cpu_read(cpu_tlbstate.ctxs[0].ctx_id) !=
>> +                loaded_mm->context.ctx_id);
>> +
>>       if (this_cpu_read(cpu_tlbstate.state) != TLBSTATE_OK) {
>> +             /*
>> +              * leave_mm() is adequate to handle any type of flush, and
>> +              * we would prefer not to receive further IPIs.
>
> While I know what you mean, it might be useful to have a more elaborate
> explanation why this prevents new IPIs.

Added, although it just gets deleted again later in the series.

>
>> +              */
>>               leave_mm(smp_processor_id());
>>               return;
>>       }
>>
>> -     if (f->end == TLB_FLUSH_ALL) {
>> -             local_flush_tlb();
>> -             if (local)
>> -                     count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
>> -             trace_tlb_flush(reason, TLB_FLUSH_ALL);
>> -     } else {
>> +     if (local_tlb_gen == mm_tlb_gen) {
>> +             /*
>> +              * There's nothing to do: we're already up to date.  This can
>> +              * happen if two concurrent flushes happen -- the first IPI to
>> +              * be handled can catch us all the way up, leaving no work for
>> +              * the second IPI to be handled.
>
> That not restricted to IPIs, right? A local flush / IPI combo can do that
> as well.

Indeed.  Comment fixed.

>
> Other than those nits;
>
> Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
