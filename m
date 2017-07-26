Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 960A16B0387
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 09:52:29 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id g131so2819525oic.10
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 06:52:29 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id m124si4645184oia.8.2017.07.26.06.52.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 06:52:28 -0700 (PDT)
Received: from mail-vk0-f52.google.com (mail-vk0-f52.google.com [209.85.213.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 076A722CB7
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 13:52:28 +0000 (UTC)
Received: by mail-vk0-f52.google.com with SMTP id r199so9808190vke.4
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 06:52:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170725144412.iaxl4um6c42ydtbw@hirez.programming.kicks-ass.net>
References: <b994bd38fd8dbed15e3bf8a0a23dde207b2297c0.1500991817.git.luto@kernel.org>
 <20170725144412.iaxl4um6c42ydtbw@hirez.programming.kicks-ass.net>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 26 Jul 2017 06:52:06 -0700
Message-ID: <CALCETrXHXvyKTp4uAJuW_gtBndTq=GOMyeTi0jsWZmiJYULHtg@mail.gmail.com>
Subject: Re: [PATCH v6] x86/mm: Improve TLB flush documentation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>

On Tue, Jul 25, 2017 at 7:44 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Tue, Jul 25, 2017 at 07:10:44AM -0700, Andy Lutomirski wrote:
>> Improve comments as requested by PeterZ and also add some
>> documentation at the top of the file.
>>
>> This adds and removes some smp_mb__after_atomic() calls to make the
>> code correct even in the absence of x86's extra-strong atomics.
>
> The main point being that this better documents on which specific
> ordering we rely.

Indeed.

>>               /*
>> +              * Start remote flushes and then read tlb_gen.  As
>> +              * above, the barrier synchronizes with
>> +              * inc_mm_tlb_gen() like this:
>> +              *
>> +              * switch_mm_irqs_off():        flush request:
>> +              *  cpumask_set_cpu(...);        inc_mm_tlb_gen();
>> +              *  MB                           MB
>> +              *  atomic64_read(.tlb_gen);     flush_tlb_others(mm_cpumask());
>>                */
>>               cpumask_set_cpu(cpu, mm_cpumask(next));
>> +             smp_mb__after_atomic();
>>               next_tlb_gen = atomic64_read(&next->context.tlb_gen);
>>
>>               choose_new_asid(next, next_tlb_gen, &new_asid, &need_flush);
>
> Arguably one could make a helper function of those few lines, not sure
> it makes sense, but this duplication seems wasteful.
>
> So we either see the increment or the CPU set, but can not have neither.
>
> Should not arch_tlbbatch_add_mm() also have this same comment? It too
> seems to increment and then read the mask.

Hmm.  There's already this comment in inc_mm_tlb_gen():

        /*
         * Bump the generation count.  This also serves as a full barrier
         * that synchronizes with switch_mm(): callers are required to order
         * their read of mm_cpumask after their writes to the paging
         * structures.
         */

is that not adequate?

FWIW, I have followup patches in the works to further de-deduplicate a
bunch of this code.  I wanted to get the main bits all landed first,
though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
