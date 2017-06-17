Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id BF35A6B0338
	for <linux-mm@kvack.org>; Sat, 17 Jun 2017 05:21:50 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id j65so37758794oib.1
        for <linux-mm@kvack.org>; Sat, 17 Jun 2017 02:21:50 -0700 (PDT)
Received: from mail-ot0-x229.google.com (mail-ot0-x229.google.com. [2607:f8b0:4003:c0f::229])
        by mx.google.com with ESMTPS id b141si394867oih.278.2017.06.17.02.21.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Jun 2017 02:21:50 -0700 (PDT)
Received: by mail-ot0-x229.google.com with SMTP id y47so21391718oty.0
        for <linux-mm@kvack.org>; Sat, 17 Jun 2017 02:21:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <96e64715-20b7-0aba-6bf8-ede926c804fb@virtuozzo.com>
References: <cover.1496743523.git.dvyukov@google.com> <658c169bdc4d486b19d161579168a425b064b6f5.1496743523.git.dvyukov@google.com>
 <96e64715-20b7-0aba-6bf8-ede926c804fb@virtuozzo.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sat, 17 Jun 2017 11:21:29 +0200
Message-ID: <CACT4Y+YMUghcyjweQPtG9m4W=AJ=raSAz=7MqeFYc2Jok-uYfQ@mail.gmail.com>
Subject: Re: [PATCH v3 7/7] asm-generic, x86: add comments for atomic instrumentation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>

On Fri, Jun 16, 2017 at 6:29 PM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
> On 06/06/2017 01:11 PM, Dmitry Vyukov wrote:
>> The comments are factored out from the code changes to make them
>> easier to read. Add them separately to explain some non-obvious
>> aspects.
>>
>> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
>> Cc: Mark Rutland <mark.rutland@arm.com>
>> Cc: Peter Zijlstra <peterz@infradead.org>
>> Cc: Will Deacon <will.deacon@arm.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
>> Cc: Ingo Molnar <mingo@redhat.com>
>> Cc: kasan-dev@googlegroups.com
>> Cc: linux-mm@kvack.org
>> Cc: linux-kernel@vger.kernel.org
>> Cc: x86@kernel.org
>> ---
>>  arch/x86/include/asm/atomic.h             |  7 +++++++
>>  include/asm-generic/atomic-instrumented.h | 30 ++++++++++++++++++++++++++++++
>>  2 files changed, 37 insertions(+)
>>
>> diff --git a/arch/x86/include/asm/atomic.h b/arch/x86/include/asm/atomic.h
>> index b7900346c77e..8a9e65e585db 100644
>> --- a/arch/x86/include/asm/atomic.h
>> +++ b/arch/x86/include/asm/atomic.h
>> @@ -23,6 +23,13 @@
>>   */
>>  static __always_inline int arch_atomic_read(const atomic_t *v)
>>  {
>> +     /*
>> +      * Note: READ_ONCE() here leads to double instrumentation as
>> +      * both READ_ONCE() and atomic_read() contain instrumentation.
>> +      * This is a deliberate choice. READ_ONCE_NOCHECK() is compiled to a
>> +      * non-inlined function call that considerably increases binary size
>> +      * and stack usage under KASAN.
>> +      */
>
>
> Not sure that this worth commenting. Whoever is looking into arch_atomic_read() internals
> probably don't even think about KASAN instrumentation, so I'd remove this comment.


My concern is that if somebody does think about KASAN, he/she will
conclude that it should be READ_ONCE_NOCHECK(). And that's what I did
initially, until you pointed the negative effects. I don't like
pointless comments that repeat code too, but this one explains
something that basically cannot be inferred from source code.

I've made it clear that it's for KASAN and also significantly shorten
it so that it does not obscure code too much. Now it is:

/*
 * Note for KASAN: we deliberately don't use READ_ONCE_NOCHECK() here,
 * it's non-inlined function that increases binary size and stack usage.
 */

Does it look better to you?

I've mailed v4 with the 2 fixed.

Thanks for review!


>>       return READ_ONCE((v)->counter);
>>  }
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
