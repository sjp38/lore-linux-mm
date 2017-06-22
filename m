Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id BEDA66B0279
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 11:55:59 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id a199so11302528oib.2
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 08:55:59 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id v28si644073otf.368.2017.06.22.08.55.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 08:55:58 -0700 (PDT)
Received: from mail-vk0-f52.google.com (mail-vk0-f52.google.com [209.85.213.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id ACCF722B68
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 15:55:57 +0000 (UTC)
Received: by mail-vk0-f52.google.com with SMTP id y70so1354955vky.3
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 08:55:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170622145914.tzqdulshlssiywj4@pd.tnic>
References: <cover.1498022414.git.luto@kernel.org> <91f24a6145b2077f992902891f8fa59abe5c8696.1498022414.git.luto@kernel.org>
 <20170621184424.eixb2jdyy66xq4hg@pd.tnic> <CALCETrWEGrVJj3Jcc3U38CYh01GKgGpLqW=eN_-7nMo4t=V5Mg@mail.gmail.com>
 <20170622072449.4rc4bnvucn7usuak@pd.tnic> <CALCETrVdT449KiEJ7wo8g9B6NyTSQhuXpYL76b=ToJhKwKyVXg@mail.gmail.com>
 <20170622145914.tzqdulshlssiywj4@pd.tnic>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 22 Jun 2017 08:55:36 -0700
Message-ID: <CALCETrUPqG-YcneqSqUYzWTJbm2Ae0Nj3K0MuS0cKYeD0yWhuw@mail.gmail.com>
Subject: Re: [PATCH v3 05/11] x86/mm: Track the TLB's tlb_gen and update the
 flushing algorithm
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Thu, Jun 22, 2017 at 7:59 AM, Borislav Petkov <bp@alien8.de> wrote:
> On Thu, Jun 22, 2017 at 07:48:21AM -0700, Andy Lutomirski wrote:
>> On Thu, Jun 22, 2017 at 12:24 AM, Borislav Petkov <bp@alien8.de> wrote:
>> > On Wed, Jun 21, 2017 at 07:46:05PM -0700, Andy Lutomirski wrote:
>> >> > I'm certainly still missing something here:
>> >> >
>> >> > We have f->new_tlb_gen and mm_tlb_gen to control the flushing, i.e., we
>> >> > do once
>> >> >
>> >> >         bump_mm_tlb_gen(mm);
>> >> >
>> >> > and once
>> >> >
>> >> >         info.new_tlb_gen = bump_mm_tlb_gen(mm);
>> >> >
>> >> > and in both cases, the bumping is done on mm->context.tlb_gen.
>> >> >
>> >> > So why isn't that enough to do the flushing and we have to consult
>> >> > info.new_tlb_gen too?
>> >>
>> >> The issue is a possible race.  Suppose we start at tlb_gen == 1 and
>> >> then two concurrent flushes happen.  The first flush is a full flush
>> >> and sets tlb_gen to 2.  The second is a partial flush and sets tlb_gen
>> >> to 3.  If the second flush gets propagated to a given CPU first and it
>> >
>> > Maybe I'm still missing something, which is likely...
>> >
>> > but if the second flush gets propagated to the CPU first, the CPU will
>> > have local tlb_gen 1 and thus enforce a full flush anyway because we
>> > will go 1 -> 3 on that particular CPU. Or?
>> >
>>
>> Yes, exactly.  Which means I'm probably just misunderstanding your
>> original question.  Can you re-ask it?
>
> Ah, simple: we control the flushing with info.new_tlb_gen and
> mm->context.tlb_gen. I.e., this check:
>
>
>         if (f->end != TLB_FLUSH_ALL &&
>             f->new_tlb_gen == local_tlb_gen + 1 &&
>             f->new_tlb_gen == mm_tlb_gen) {
>
> why can't we write:
>
>         if (f->end != TLB_FLUSH_ALL &&
>             mm_tlb_gen == local_tlb_gen + 1)
>
> ?

Ah, I thought you were asking about why I needed mm_tlb_gen ==
local_tlb_gen + 1.  This is just an optimization, or at least I hope
it is.  The idea is that, if we know that another flush is coming, it
seems likely that it would be faster to do a full flush and increase
local_tlb_gen all the way to mm_tlb_gen rather than doing a partial
flush, increasing local_tlb_gen to something less than mm_tlb_gen, and
needing to flush again very soon.

>
> If mm_tlb_gen is + 2, then we'll do a full flush, if it is + 1, then
> partial.
>
> If the second flush, as you say is a partial one and still gets
> propagated first, the check will force a full flush anyway.
>
> When the first flush propagates after the second, we'll ignore it
> because local_tlb_gen has advanced adready due to the second flush.
>
> As a matter of fact, we could simplify the logic: if local_tlb_gen is
> only mm_tlb_gen - 1, then do the requested flush type.

Hmm.  I'd be nervous that there are more subtle races if we do this.
For example, suppose that a partial flush increments tlb_gen from 1 to
2 and a full flush increments tlb_gen from 2 to 3.  Meanwhile, the CPU
is busy switching back and forth between mms, so the partial flush
sees the cpu set in mm_cpumask but the full flush doesn't see the cpu
set in mm_cpumask.  The flush IPI hits after a switch_mm_irqs_off()
call notices the change from 1 to 2.  switch_mm_irqs_off() will do a
full flush and increment the local tlb_gen to 2, and the IPI handler
for the partial flush will see local_tlb_gen == mm_tlb_gen - 1
(because local_tlb_gen == 2 and mm_tlb_gen == 3) and do a partial
flush.  The problem here is that it's not obvious to me that this
actually ends up flushing everything that's needed.  Maybe all the
memory ordering gets this right, but I can imagine scenarios in which
switch_mm_irqs_off() does its flush early enough that the TLB picks up
an entry that was supposed to get zapped by the full flush.

IOW it *might* be valid, but I think it would need very careful review
and documentation.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
