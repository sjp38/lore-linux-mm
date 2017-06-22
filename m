Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8BEC86B02F4
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 14:09:01 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id f20so15561569otd.9
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 11:09:01 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g9si771536otb.321.2017.06.22.11.09.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 11:09:00 -0700 (PDT)
Received: from mail-ua0-f174.google.com (mail-ua0-f174.google.com [209.85.217.174])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 92EAB22B69
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 18:08:59 +0000 (UTC)
Received: by mail-ua0-f174.google.com with SMTP id g40so23407657uaa.3
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 11:08:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170622172220.wf3egiwx2kqbxbi2@pd.tnic>
References: <cover.1498022414.git.luto@kernel.org> <91f24a6145b2077f992902891f8fa59abe5c8696.1498022414.git.luto@kernel.org>
 <20170621184424.eixb2jdyy66xq4hg@pd.tnic> <CALCETrWEGrVJj3Jcc3U38CYh01GKgGpLqW=eN_-7nMo4t=V5Mg@mail.gmail.com>
 <20170622072449.4rc4bnvucn7usuak@pd.tnic> <CALCETrVdT449KiEJ7wo8g9B6NyTSQhuXpYL76b=ToJhKwKyVXg@mail.gmail.com>
 <20170622145914.tzqdulshlssiywj4@pd.tnic> <CALCETrUPqG-YcneqSqUYzWTJbm2Ae0Nj3K0MuS0cKYeD0yWhuw@mail.gmail.com>
 <20170622172220.wf3egiwx2kqbxbi2@pd.tnic>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 22 Jun 2017 11:08:38 -0700
Message-ID: <CALCETrUbiXK8gjS=U2j4jW8YgPv4j+wgwsa4nJLnO+902fXfKQ@mail.gmail.com>
Subject: Re: [PATCH v3 05/11] x86/mm: Track the TLB's tlb_gen and update the
 flushing algorithm
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Thu, Jun 22, 2017 at 10:22 AM, Borislav Petkov <bp@alien8.de> wrote:
> On Thu, Jun 22, 2017 at 08:55:36AM -0700, Andy Lutomirski wrote:
>> > Ah, simple: we control the flushing with info.new_tlb_gen and
>> > mm->context.tlb_gen. I.e., this check:
>> >
>> >
>> >         if (f->end != TLB_FLUSH_ALL &&
>> >             f->new_tlb_gen == local_tlb_gen + 1 &&
>> >             f->new_tlb_gen == mm_tlb_gen) {
>> >
>> > why can't we write:
>> >
>> >         if (f->end != TLB_FLUSH_ALL &&
>> >             mm_tlb_gen == local_tlb_gen + 1)
>> >
>> > ?
>>
>> Ah, I thought you were asking about why I needed mm_tlb_gen ==
>> local_tlb_gen + 1.  This is just an optimization, or at least I hope
>> it is.  The idea is that, if we know that another flush is coming, it
>> seems likely that it would be faster to do a full flush and increase
>> local_tlb_gen all the way to mm_tlb_gen rather than doing a partial
>> flush, increasing local_tlb_gen to something less than mm_tlb_gen, and
>> needing to flush again very soon.
>
> Thus the f->new_tlb_gen check whether it is local_tlb_gen + 1.
>
> Btw, do you see how confusing this check is: you have new_tlb_gen from
> a variable passed from the function call IPI, local_tlb_gen which is
> the CPU's own and then there's also mm_tlb_gen which we've written into
> new_tlb_gen from:
>
>         info.new_tlb_gen = bump_mm_tlb_gen(mm);
>
> which incremented mm_tlb_gen too.

Yes, I agree it's confusing.  There really are three numbers.  Those
numbers are: the latest generation, the generation that this CPU has
caught up to, and the generation that the requester of the flush we're
currently handling has asked us to catch up to.  I don't see a way to
reduce the complexity.

>
>> Hmm.  I'd be nervous that there are more subtle races if we do this.
>> For example, suppose that a partial flush increments tlb_gen from 1 to
>> 2 and a full flush increments tlb_gen from 2 to 3.  Meanwhile, the CPU
>> is busy switching back and forth between mms, so the partial flush
>> sees the cpu set in mm_cpumask but the full flush doesn't see the cpu
>> set in mm_cpumask.
>
> Lemme see if I understand this correctly: you mean, the full flush will
> exit early due to the
>
>         if (!cpumask_test_cpu(smp_processor_id(), mm_cpumask(loaded_mm))) {
>
> test?

Yes, or at least that's what I'm imagining.

>
>> The flush IPI hits after a switch_mm_irqs_off() call notices the
>> change from 1 to 2. switch_mm_irqs_off() will do a full flush and
>> increment the local tlb_gen to 2, and the IPI handler for the partial
>> flush will see local_tlb_gen == mm_tlb_gen - 1 (because local_tlb_gen
>> == 2 and mm_tlb_gen == 3) and do a partial flush.
>
> Why, the 2->3 flush has f->end == TLB_FLUSH_ALL.
>
> That's why you have this thing in addition to the tlb_gen.

Yes.  The idea is that we only do remote partial flushes when it's
100% obvious that it's safe.

>
> What we end up doing in this case, is promote the partial flush to a
> full one and thus have a partial and a full flush which are close by
> converted to two full flushes.

It could be converted to two full flushes or to just one, I think,
depending on what order everything happens in.

>
>> The problem here is that it's not obvious to me that this actually
>> ends up flushing everything that's needed. Maybe all the memory
>> ordering gets this right, but I can imagine scenarios in which
>> switch_mm_irqs_off() does its flush early enough that the TLB picks up
>> an entry that was supposed to get zapped by the full flush.
>
> See above.
>
> And I don't think that having two full flushes back-to-back is going to
> cost a lot as the second one won't flush a whole lot.

>From limited benchmarking on new Intel chips, a full flush is very
expensive no matter what.  I think this is silly because I suspect
that the PCID circuitry could internally simulate a full flush at very
little cost, but it seems that it doesn't.  I haven't tried to
benchmark INVLPG.

>
>> IOW it *might* be valid, but I think it would need very careful review
>> and documentation.
>
> Always.
>
> Btw, I get the sense this TLB flush avoiding scheme becomes pretty
> complex for diminishing reasons.
>
>   [ Or maybe I'm not seeing them - I'm always open to corrections. ]
>
> Especially if intermediary levels from the pagetable walker are cached
> and reestablishing the TLB entries seldom means a full walk.
>
> You should do a full fledged benchmark to see whether this whole
> complexity is even worth it, methinks.

I agree that, by itself, this patch is waaaaaay too complex to be
justifiable.  The thing is that, after quite a few false starts, I
couldn't find a clean way to get PCID and improved laziness without
this thing as a prerequisite.  Both of those features depend on having
a heuristic for when a flush can be avoided, and that heuristic must
*never* say that a flush can be skipped when it can't be skipped.
This patch gives a way to do that.

I tried a few other approaches:

 - Keeping a cpumask of which CPUs are up to date.  Someone at Intel
tried this once and I inherited that code, but I scrapped it all after
it had both performance and correctness issues.  I tried the approach
again from scratch and paulmck poked all kinds of holes in it.

 - Using a lock to make sure that only one flush can be in progress on
a given mm at a given time.  The performance is just fine -- flushes
can't usefully happen in parallel anyway.  The problem is that the
batched unmap code in the core mm (which is apparently a huge win on
some workloads) can introduce arbitrarily long delays between
initiating a flush and actually requesting that the IPIs be sent.  I
could have worked around this with fancy data structures, but getting
them right so they wouldn't deadlock if called during reclaim and
preventing lock ordering issues would have been really nasty.

 - Poking remote cpus' data structures even when they're lazy.  This
wouldn't scale on systems with many cpus, since a given mm can easily
be lazy on every single other cpu all at once.

 - Ditching remote partial flushes entirely.  But those were recently
re-optimized by some Intel folks (Dave and others, IIRC) and came with
nice benchmarks showing that they were useful on some workloads.
(munmapping a small range, presumably.)

But this approach of using three separate tlb_gen values seems to
cover all the bases, and I don't think it's *that* bad.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
