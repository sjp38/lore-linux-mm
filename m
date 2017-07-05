Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1068C6B03A7
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 12:10:24 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id 6so36534098oik.11
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 09:10:24 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j28si12963608oiy.154.2017.07.05.09.10.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 09:10:23 -0700 (PDT)
Received: from mail-vk0-f47.google.com (mail-vk0-f47.google.com [209.85.213.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7C5AB22C7D
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 16:10:22 +0000 (UTC)
Received: by mail-vk0-f47.google.com with SMTP id y70so127235448vky.3
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 09:10:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170705122506.GG4941@worktop>
References: <cover.1498751203.git.luto@kernel.org> <cf600d28712daa8e2222c08a10f6c914edab54f2.1498751203.git.luto@kernel.org>
 <20170705122506.GG4941@worktop>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 5 Jul 2017 09:10:00 -0700
Message-ID: <CALCETrXYQHQm2qQ_4dLx8K2rFfapFUb-eqFdG8bk2377eFnNGg@mail.gmail.com>
Subject: Re: [PATCH v4 10/10] x86/mm: Try to preserve old TLB entries using PCID
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>

On Wed, Jul 5, 2017 at 5:25 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Thu, Jun 29, 2017 at 08:53:22AM -0700, Andy Lutomirski wrote:
>> +static void choose_new_asid(struct mm_struct *next, u64 next_tlb_gen,
>> +                         u16 *new_asid, bool *need_flush)
>> +{
>> +     u16 asid;
>> +
>> +     if (!static_cpu_has(X86_FEATURE_PCID)) {
>> +             *new_asid = 0;
>> +             *need_flush = true;
>> +             return;
>> +     }
>> +
>> +     for (asid = 0; asid < TLB_NR_DYN_ASIDS; asid++) {
>> +             if (this_cpu_read(cpu_tlbstate.ctxs[asid].ctx_id) !=
>> +                 next->context.ctx_id)
>> +                     continue;
>> +
>> +             *new_asid = asid;
>> +             *need_flush = (this_cpu_read(cpu_tlbstate.ctxs[asid].tlb_gen) <
>> +                            next_tlb_gen);
>> +             return;
>> +     }
>> +
>> +     /*
>> +      * We don't currently own an ASID slot on this CPU.
>> +      * Allocate a slot.
>> +      */
>> +     *new_asid = this_cpu_add_return(cpu_tlbstate.next_asid, 1) - 1;
>
> So this basically RR the ASID slots. Have you tried slightly more
> complex replacement policies like CLOCK ?

No, mainly because I'm lazy and because CLOCK requires scavenging a
bit.  (Which we can certainly do, but it will further complicate the
code.)  It could be worth playing with better replacement algorithms
as a followup, though.

I've also considered a slight elaboration of RR in which we make sure
not to reuse the most recent ASID slot, which would guarantee that, if
we switch from task A to B and back to A, we don't flush on the way
back to A.  (Currently, if B is not in the cache, there's a 1/6 chance
we'll flush on the way back.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
