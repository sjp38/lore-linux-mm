Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id CDCB46B0292
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 01:43:51 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id b130so8014185oii.4
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 22:43:51 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j6si6340683oia.128.2017.07.24.22.43.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 22:43:50 -0700 (PDT)
Received: from mail-ua0-f182.google.com (mail-ua0-f182.google.com [209.85.217.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9BF7822CAA
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 05:43:49 +0000 (UTC)
Received: by mail-ua0-f182.google.com with SMTP id f9so95087300uaf.4
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 22:43:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <231630A0-21DB-4347-B126-F49AFD32B851@gmail.com>
References: <cover.1500957502.git.luto@kernel.org> <695299daa67239284e8db5a60d4d7eb88c914e0a.1500957502.git.luto@kernel.org>
 <231630A0-21DB-4347-B126-F49AFD32B851@gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 24 Jul 2017 22:43:28 -0700
Message-ID: <CALCETrUL_-6S8mkR_mhhpHqev7EBfFnLor3hZ28RiYQRNHC6ig@mail.gmail.com>
Subject: Re: [PATCH v5 2/2] x86/mm: Improve TLB flush documentation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Mon, Jul 24, 2017 at 9:47 PM, Nadav Amit <nadav.amit@gmail.com> wrote:
> Andy Lutomirski <luto@kernel.org> wrote:
>
>> Improve comments as requested by PeterZ and also add some
>> documentation at the top of the file.
>>
>> Signed-off-by: Andy Lutomirski <luto@kernel.org>
>> ---
>> arch/x86/mm/tlb.c | 43 +++++++++++++++++++++++++++++++++----------
>> 1 file changed, 33 insertions(+), 10 deletions(-)
>>
>> diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
>> index ce104b962a17..d4ee781ca656 100644
>> --- a/arch/x86/mm/tlb.c
>> +++ b/arch/x86/mm/tlb.c
>> @@ -15,17 +15,24 @@
>> #include <linux/debugfs.h>
>>
>> /*
>> - *   TLB flushing, formerly SMP-only
>> - *           c/o Linus Torvalds.
>> + * The code in this file handles mm switches and TLB flushes.
>>  *
>> - *   These mean you can really definitely utterly forget about
>> - *   writing to user space from interrupts. (Its not allowed anyway).
>> + * An mm's TLB state is logically represented by a totally ordered sequence
>> + * of TLB flushes.  Each flush increments the mm's tlb_gen.
>>  *
>> - *   Optimizations Manfred Spraul <manfred@colorfullife.com>
>> + * Each CPU that might have an mm in its TLB (and that might ever use
>> + * those TLB entries) will have an entry for it in its cpu_tlbstate.ctxs
>> + * array.  The kernel maintains the following invariant: for each CPU and
>> + * for each mm in its cpu_tlbstate.ctxs array, the CPU has performed all
>> + * flushes in that mms history up to the tlb_gen in cpu_tlbstate.ctxs
>> + * or the CPU has performed an equivalent set of flushes.
>>  *
>> - *   More scalable flush, from Andi Kleen
>> - *
>> - *   Implement flush IPI by CALL_FUNCTION_VECTOR, Alex Shi
>> + * For this purpose, an equivalent set is a set that is at least as strong.
>> + * So, for example, if the flush history is a full flush at time 1,
>> + * a full flush after time 1 is sufficient, but a full flush before time 1
>> + * is not.  Similarly, any number of flushes can be replaced by a single
>> + * full flush so long as that replacement flush is after all the flushes
>> + * that it's replacing.
>>  */
>>
>> atomic64_t last_mm_ctx_id = ATOMIC64_INIT(1);
>> @@ -138,7 +145,16 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
>>                       return;
>>               }
>>
>> -             /* Resume remote flushes and then read tlb_gen. */
>> +             /*
>> +              * Resume remote flushes and then read tlb_gen.  The
>> +              * implied barrier in atomic64_read() synchronizes
>> +              * with inc_mm_tlb_gen() like this:
>
> You mean the implied memory barrier in cpumask_set_cpu(), no?
>


Ugh, yes.  And I misread PeterZ's email and incorrectly removed the
smp_mb__after_atomic().  I'll respin this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
