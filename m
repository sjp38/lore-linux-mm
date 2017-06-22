Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B2E746B0279
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 13:22:40 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z45so6354459wrb.13
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 10:22:40 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id q129si1827897wmb.13.2017.06.22.10.22.39
        for <linux-mm@kvack.org>;
        Thu, 22 Jun 2017 10:22:39 -0700 (PDT)
Date: Thu, 22 Jun 2017 19:22:20 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v3 05/11] x86/mm: Track the TLB's tlb_gen and update the
 flushing algorithm
Message-ID: <20170622172220.wf3egiwx2kqbxbi2@pd.tnic>
References: <cover.1498022414.git.luto@kernel.org>
 <91f24a6145b2077f992902891f8fa59abe5c8696.1498022414.git.luto@kernel.org>
 <20170621184424.eixb2jdyy66xq4hg@pd.tnic>
 <CALCETrWEGrVJj3Jcc3U38CYh01GKgGpLqW=eN_-7nMo4t=V5Mg@mail.gmail.com>
 <20170622072449.4rc4bnvucn7usuak@pd.tnic>
 <CALCETrVdT449KiEJ7wo8g9B6NyTSQhuXpYL76b=ToJhKwKyVXg@mail.gmail.com>
 <20170622145914.tzqdulshlssiywj4@pd.tnic>
 <CALCETrUPqG-YcneqSqUYzWTJbm2Ae0Nj3K0MuS0cKYeD0yWhuw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CALCETrUPqG-YcneqSqUYzWTJbm2Ae0Nj3K0MuS0cKYeD0yWhuw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Thu, Jun 22, 2017 at 08:55:36AM -0700, Andy Lutomirski wrote:
> > Ah, simple: we control the flushing with info.new_tlb_gen and
> > mm->context.tlb_gen. I.e., this check:
> >
> >
> >         if (f->end != TLB_FLUSH_ALL &&
> >             f->new_tlb_gen == local_tlb_gen + 1 &&
> >             f->new_tlb_gen == mm_tlb_gen) {
> >
> > why can't we write:
> >
> >         if (f->end != TLB_FLUSH_ALL &&
> >             mm_tlb_gen == local_tlb_gen + 1)
> >
> > ?
> 
> Ah, I thought you were asking about why I needed mm_tlb_gen ==
> local_tlb_gen + 1.  This is just an optimization, or at least I hope
> it is.  The idea is that, if we know that another flush is coming, it
> seems likely that it would be faster to do a full flush and increase
> local_tlb_gen all the way to mm_tlb_gen rather than doing a partial
> flush, increasing local_tlb_gen to something less than mm_tlb_gen, and
> needing to flush again very soon.

Thus the f->new_tlb_gen check whether it is local_tlb_gen + 1.

Btw, do you see how confusing this check is: you have new_tlb_gen from
a variable passed from the function call IPI, local_tlb_gen which is
the CPU's own and then there's also mm_tlb_gen which we've written into
new_tlb_gen from:

	info.new_tlb_gen = bump_mm_tlb_gen(mm);

which incremented mm_tlb_gen too.

> Hmm.  I'd be nervous that there are more subtle races if we do this.
> For example, suppose that a partial flush increments tlb_gen from 1 to
> 2 and a full flush increments tlb_gen from 2 to 3.  Meanwhile, the CPU
> is busy switching back and forth between mms, so the partial flush
> sees the cpu set in mm_cpumask but the full flush doesn't see the cpu
> set in mm_cpumask.

Lemme see if I understand this correctly: you mean, the full flush will
exit early due to the

	if (!cpumask_test_cpu(smp_processor_id(), mm_cpumask(loaded_mm))) {

test?

> The flush IPI hits after a switch_mm_irqs_off() call notices the
> change from 1 to 2. switch_mm_irqs_off() will do a full flush and
> increment the local tlb_gen to 2, and the IPI handler for the partial
> flush will see local_tlb_gen == mm_tlb_gen - 1 (because local_tlb_gen
> == 2 and mm_tlb_gen == 3) and do a partial flush.

Why, the 2->3 flush has f->end == TLB_FLUSH_ALL.

That's why you have this thing in addition to the tlb_gen.

What we end up doing in this case, is promote the partial flush to a
full one and thus have a partial and a full flush which are close by
converted to two full flushes.

> The problem here is that it's not obvious to me that this actually
> ends up flushing everything that's needed. Maybe all the memory
> ordering gets this right, but I can imagine scenarios in which
> switch_mm_irqs_off() does its flush early enough that the TLB picks up
> an entry that was supposed to get zapped by the full flush.

See above.

And I don't think that having two full flushes back-to-back is going to
cost a lot as the second one won't flush a whole lot.

> IOW it *might* be valid, but I think it would need very careful review
> and documentation.

Always.

Btw, I get the sense this TLB flush avoiding scheme becomes pretty
complex for diminishing reasons.

  [ Or maybe I'm not seeing them - I'm always open to corrections. ]

Especially if intermediary levels from the pagetable walker are cached
and reestablishing the TLB entries seldom means a full walk.

You should do a full fledged benchmark to see whether this whole
complexity is even worth it, methinks.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
