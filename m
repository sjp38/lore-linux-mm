Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6A4096B0279
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 22:46:28 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id b6so2158544oia.14
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 19:46:28 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g125si63875oif.72.2017.06.21.19.46.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 19:46:27 -0700 (PDT)
Received: from mail-ua0-f174.google.com (mail-ua0-f174.google.com [209.85.217.174])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C146E22B4B
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 02:46:26 +0000 (UTC)
Received: by mail-ua0-f174.google.com with SMTP id z22so3460112uah.1
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 19:46:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170621184424.eixb2jdyy66xq4hg@pd.tnic>
References: <cover.1498022414.git.luto@kernel.org> <91f24a6145b2077f992902891f8fa59abe5c8696.1498022414.git.luto@kernel.org>
 <20170621184424.eixb2jdyy66xq4hg@pd.tnic>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 21 Jun 2017 19:46:05 -0700
Message-ID: <CALCETrWEGrVJj3Jcc3U38CYh01GKgGpLqW=eN_-7nMo4t=V5Mg@mail.gmail.com>
Subject: Re: [PATCH v3 05/11] x86/mm: Track the TLB's tlb_gen and update the
 flushing algorithm
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Wed, Jun 21, 2017 at 11:44 AM, Borislav Petkov <bp@alien8.de> wrote:
> On Tue, Jun 20, 2017 at 10:22:11PM -0700, Andy Lutomirski wrote:
>> +     this_cpu_write(cpu_tlbstate.ctxs[0].ctx_id, next->context.ctx_id);
>> +     this_cpu_write(cpu_tlbstate.ctxs[0].tlb_gen,
>> +                    atomic64_read(&next->context.tlb_gen));
>
> Just let it stick out:
>
>         this_cpu_write(cpu_tlbstate.ctxs[0].ctx_id,  next->context.ctx_id);
>         this_cpu_write(cpu_tlbstate.ctxs[0].tlb_gen, atomic64_read(&next->context.tlb_gen));
>
> Should be a bit better readable this way.

Done

>> +     if (local_tlb_gen == mm_tlb_gen) {
>
>         if (unlikely(...
>
> maybe?
>
> Sounds to me like the concurrent flushes case would be the
> uncommon one...

Agreed.

>> +
>> +     WARN_ON_ONCE(local_tlb_gen > mm_tlb_gen);
>> +     WARN_ON_ONCE(f->new_tlb_gen > mm_tlb_gen);
>> +
>> +     /*
>> +      * If we get to this point, we know that our TLB is out of date.
>> +      * This does not strictly imply that we need to flush (it's
>> +      * possible that f->new_tlb_gen <= local_tlb_gen), but we're
>> +      * going to need to flush in the very near future, so we might
>> +      * as well get it over with.
>> +      *
>> +      * The only question is whether to do a full or partial flush.
>> +      *
>> +      * A partial TLB flush is safe and worthwhile if two conditions are
>> +      * met:
>> +      *
>> +      * 1. We wouldn't be skipping a tlb_gen.  If the requester bumped
>> +      *    the mm's tlb_gen from p to p+1, a partial flush is only correct
>> +      *    if we would be bumping the local CPU's tlb_gen from p to p+1 as
>> +      *    well.
>> +      *
>> +      * 2. If there are no more flushes on their way.  Partial TLB
>> +      *    flushes are not all that much cheaper than full TLB
>> +      *    flushes, so it seems unlikely that it would be a
>> +      *    performance win to do a partial flush if that won't bring
>> +      *    our TLB fully up to date.
>> +      */
>> +     if (f->end != TLB_FLUSH_ALL &&
>> +         f->new_tlb_gen == local_tlb_gen + 1 &&
>> +         f->new_tlb_gen == mm_tlb_gen) {
>
> I'm certainly still missing something here:
>
> We have f->new_tlb_gen and mm_tlb_gen to control the flushing, i.e., we
> do once
>
>         bump_mm_tlb_gen(mm);
>
> and once
>
>         info.new_tlb_gen = bump_mm_tlb_gen(mm);
>
> and in both cases, the bumping is done on mm->context.tlb_gen.
>
> So why isn't that enough to do the flushing and we have to consult
> info.new_tlb_gen too?

The issue is a possible race.  Suppose we start at tlb_gen == 1 and
then two concurrent flushes happen.  The first flush is a full flush
and sets tlb_gen to 2.  The second is a partial flush and sets tlb_gen
to 3.  If the second flush gets propagated to a given CPU first and it
were to do an actual partial flush (INVLPG) and set the percpu tlb_gen
to 3, then the first flush won't do anything and we'll fail to flush
all the pages we need to flush.

My solution was to say that we're only allowed to do INVLPG if we're
making exactly the same change to the local tlb_gen that the requester
made to context.tlb_gen.

I'll add a comment to this effect.

>
>> +             /* Partial flush */
>>               unsigned long addr;
>>               unsigned long nr_pages = (f->end - f->start) >> PAGE_SHIFT;
>
> <---- newline here.

Yup.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
