Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 85FCD6B040E
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 11:17:21 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id o27so121540519otd.15
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 08:17:21 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g10si7368652oth.296.2017.06.21.08.17.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 08:17:20 -0700 (PDT)
Received: from mail-ua0-f179.google.com (mail-ua0-f179.google.com [209.85.217.179])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1CAD02199D
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 15:17:19 +0000 (UTC)
Received: by mail-ua0-f179.google.com with SMTP id j53so101912621uaa.2
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 08:17:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1706211115580.2328@nanos>
References: <cover.1498022414.git.luto@kernel.org> <2b3572123ab0d0fb9a9b82dc0deee8a33eeac51f.1498022414.git.luto@kernel.org>
 <alpine.DEB.2.20.1706211115580.2328@nanos>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 21 Jun 2017 08:16:58 -0700
Message-ID: <CALCETrXmyZ0KwAHbYRwv=hO3nkgctjnb3z5tXvkQKkoABrKgHg@mail.gmail.com>
Subject: Re: [PATCH v3 07/11] x86/mm: Stop calling leave_mm() in idle code
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Wed, Jun 21, 2017 at 2:22 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> On Tue, 20 Jun 2017, Andy Lutomirski wrote:
>> diff --git a/drivers/idle/intel_idle.c b/drivers/idle/intel_idle.c
>> index 216d7ec88c0c..2ae43f59091d 100644
>> --- a/drivers/idle/intel_idle.c
>> +++ b/drivers/idle/intel_idle.c
>> @@ -912,16 +912,15 @@ static __cpuidle int intel_idle(struct cpuidle_device *dev,
>>       struct cpuidle_state *state = &drv->states[index];
>>       unsigned long eax = flg2MWAIT(state->flags);
>>       unsigned int cstate;
>> -     int cpu = smp_processor_id();
>>
>>       cstate = (((eax) >> MWAIT_SUBSTATE_SIZE) & MWAIT_CSTATE_MASK) + 1;
>>
>>       /*
>> -      * leave_mm() to avoid costly and often unnecessary wakeups
>> -      * for flushing the user TLB's associated with the active mm.
>> +      * NB: if CPUIDLE_FLAG_TLB_FLUSHED is set, this idle transition
>> +      * will probably flush the TLB.  It's not guaranteed to flush
>> +      * the TLB, though, so it's not clear that we can do anything
>> +      * useful with this knowledge.
>
> So my understanding here is:
>
>       The C-state transition might flush the TLB, when cstate->flags has
>       CPUIDLE_FLAG_TLB_FLUSHED set. The idle transition already took the
>       CPU out of the set of CPUs which are remotely flushed, so the
>       knowledge about this potential flush is not useful for the kernels
>       view of the TLB state.

Indeed.  I assume the theory behind the old code was that leave_mm()
was expensive and that CPUIDLE_FLAG_TLB_FLUSHED would be a decent
heuristic for when to do it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
