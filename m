Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id BE4276B0292
	for <linux-mm@kvack.org>; Tue, 18 Jul 2017 13:06:39 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id 191so1832841oii.4
        for <linux-mm@kvack.org>; Tue, 18 Jul 2017 10:06:39 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id k27si2362013oiy.376.2017.07.18.10.06.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jul 2017 10:06:38 -0700 (PDT)
Received: from mail-ua0-f182.google.com (mail-ua0-f182.google.com [209.85.217.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 38BE923693
	for <linux-mm@kvack.org>; Tue, 18 Jul 2017 17:06:37 +0000 (UTC)
Received: by mail-ua0-f182.google.com with SMTP id y47so15958321uag.0
        for <linux-mm@kvack.org>; Tue, 18 Jul 2017 10:06:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170718085341.nlt35dph4oukb4tc@gmail.com>
References: <cover.1498751203.git.luto@kernel.org> <cf600d28712daa8e2222c08a10f6c914edab54f2.1498751203.git.luto@kernel.org>
 <20170705121807.GF4941@worktop> <CALCETrWivSq=qSN6DMBLXVRCo-EBOx_xvnQYXHojYHuG7SaWnQ@mail.gmail.com>
 <20170705170219.ogjnswef3ufgeklz@hirez.programming.kicks-ass.net> <20170718085341.nlt35dph4oukb4tc@gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 18 Jul 2017 10:06:15 -0700
Message-ID: <CALCETrVyY-Bvh8GkwqpC9eL4D0QnkVEjpYmwvPhTJBa9evwqtQ@mail.gmail.com>
Subject: Re: [PATCH v4 10/10] x86/mm: Try to preserve old TLB entries using PCID
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>

On Tue, Jul 18, 2017 at 1:53 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
> * Peter Zijlstra <peterz@infradead.org> wrote:
>
>> On Wed, Jul 05, 2017 at 09:04:39AM -0700, Andy Lutomirski wrote:
>> > On Wed, Jul 5, 2017 at 5:18 AM, Peter Zijlstra <peterz@infradead.org> wrote:
>> > > On Thu, Jun 29, 2017 at 08:53:22AM -0700, Andy Lutomirski wrote:
>> > >> @@ -104,18 +140,20 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
>> > >>
>> > >>               /* Resume remote flushes and then read tlb_gen. */
>> > >>               cpumask_set_cpu(cpu, mm_cpumask(next));
>> > >
>> > > Barriers should have a comment... what is being ordered here against
>> > > what?
>> >
>> > How's this comment?
>> >
>> >         /*
>> >          * Resume remote flushes and then read tlb_gen.  We need to do
>> >          * it in this order: any inc_mm_tlb_gen() caller that writes a
>> >          * larger tlb_gen than we read here must see our cpu set in
>> >          * mm_cpumask() so that it will know to flush us.  The barrier
>> >          * here synchronizes with inc_mm_tlb_gen().
>> >          */
>>
>> Slightly confusing, you mean this, right?
>>
>>
>>       cpumask_set_cpu(cpu, mm_cpumask());                     inc_mm_tlb_gen();
>>
>>       MB                                                      MB
>>
>>       next_tlb_gen = atomic64_read(&next->context.tlb_gen);   flush_tlb_others(mm_cpumask());
>>
>>
>> which seems to make sense.
>
> Btw., I'll wait for a v5 iteration before applying this last patch to tip:x86/mm.

I'll send it shortly.  I think I'll also add a patch to factor out the
flush calls a bit more to prepare for Mel's upcoming fix.

>
> Thanks,
>
>         Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
