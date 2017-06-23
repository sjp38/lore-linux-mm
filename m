Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id AE8296B0292
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 11:47:03 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id 6so27590321oik.11
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 08:47:03 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h46si1914876otd.38.2017.06.23.08.47.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jun 2017 08:47:02 -0700 (PDT)
Received: from mail-vk0-f48.google.com (mail-vk0-f48.google.com [209.85.213.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id CB72322B5F
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 15:47:01 +0000 (UTC)
Received: by mail-vk0-f48.google.com with SMTP id 191so15595606vko.2
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 08:47:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170623084219.k4lrorgtlshej7ri@pd.tnic>
References: <cover.1498022414.git.luto@kernel.org> <91f24a6145b2077f992902891f8fa59abe5c8696.1498022414.git.luto@kernel.org>
 <20170621184424.eixb2jdyy66xq4hg@pd.tnic> <CALCETrWEGrVJj3Jcc3U38CYh01GKgGpLqW=eN_-7nMo4t=V5Mg@mail.gmail.com>
 <20170622072449.4rc4bnvucn7usuak@pd.tnic> <CALCETrVdT449KiEJ7wo8g9B6NyTSQhuXpYL76b=ToJhKwKyVXg@mail.gmail.com>
 <20170622145914.tzqdulshlssiywj4@pd.tnic> <CALCETrUPqG-YcneqSqUYzWTJbm2Ae0Nj3K0MuS0cKYeD0yWhuw@mail.gmail.com>
 <20170622172220.wf3egiwx2kqbxbi2@pd.tnic> <CALCETrUbiXK8gjS=U2j4jW8YgPv4j+wgwsa4nJLnO+902fXfKQ@mail.gmail.com>
 <20170623084219.k4lrorgtlshej7ri@pd.tnic>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 23 Jun 2017 08:46:40 -0700
Message-ID: <CALCETrX+B1Xa=0ZjYUNi+aApKPQerVqOt42bgGeNadaZc-c3hw@mail.gmail.com>
Subject: Re: [PATCH v3 05/11] x86/mm: Track the TLB's tlb_gen and update the
 flushing algorithm
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Fri, Jun 23, 2017 at 1:42 AM, Borislav Petkov <bp@alien8.de> wrote:
> On Thu, Jun 22, 2017 at 11:08:38AM -0700, Andy Lutomirski wrote:
>> Yes, I agree it's confusing.  There really are three numbers.  Those
>> numbers are: the latest generation, the generation that this CPU has
>> caught up to, and the generation that the requester of the flush we're
>> currently handling has asked us to catch up to.  I don't see a way to
>> reduce the complexity.
>
> Yeah, can you pls put that clarification what what is, over it. It
> explains it nicely what the check is supposed to do.

Done.  I've tried to improve a bunch of the comments in this function.

>
>> >> The flush IPI hits after a switch_mm_irqs_off() call notices the
>> >> change from 1 to 2. switch_mm_irqs_off() will do a full flush and
>> >> increment the local tlb_gen to 2, and the IPI handler for the partial
>> >> flush will see local_tlb_gen == mm_tlb_gen - 1 (because local_tlb_gen
>> >> == 2 and mm_tlb_gen == 3) and do a partial flush.
>> >
>> > Why, the 2->3 flush has f->end == TLB_FLUSH_ALL.
>> >
>> > That's why you have this thing in addition to the tlb_gen.
>>
>> Yes.  The idea is that we only do remote partial flushes when it's
>> 100% obvious that it's safe.
>
> So why wouldn't my simplified suggestion work then?
>
>         if (f->end != TLB_FLUSH_ALL &&
>              mm_tlb_gen == local_tlb_gen + 1)
>
> 1->2 is a partial flush - gets promoted to a full one
> 2->3 is a full flush - it will get executed as one due to the f->end setting to
> TLB_FLUSH_ALL.

This could still fail in some cases, I think.  Suppose 1->2 is a
partial flush and 2->3 is a full flush.  We could have this order of
events:

 - CPU 1: Partial flush.  Increase context.tlb_gen to 2 and send IPI.
 - CPU 0: switch_mm(), observe mm_tlb_gen == 2, set local_tlb_gen to 2.
 - CPU 2: Full flush.  Increase context.tlb_gen to 3 and send IPI.
 - CPU 0: Receive partial flush IPI.  mm_tlb_gen == 2 and
local_tlb_gen == 3.  Do __flush_tlb_single() and set local_tlb_gen to
3.

Our invariant is now broken: CPU 0's percpu tlb_gen is now ahead of
its actual TLB state.

 - CPU 0: Receive full flush IPI and skip the flush.  Oops.

I think my condition makes it clear that the invariants we need hold
no matter it.

>
>> It could be converted to two full flushes or to just one, I think,
>> depending on what order everything happens in.
>
> Right. One flush at the right time would be optimal.
>
>> But this approach of using three separate tlb_gen values seems to
>> cover all the bases, and I don't think it's *that* bad.
>
> Sure.
>
> As I said in IRC, let's document that complexity then so that when we
> stumble over it in the future, we at least know why it was done this
> way.

I've given it a try.  Hopefully v4 is more clear.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
