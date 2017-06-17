Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 82FDF6B0350
	for <linux-mm@kvack.org>; Sat, 17 Jun 2017 05:16:55 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id 93so43827781oto.10
        for <linux-mm@kvack.org>; Sat, 17 Jun 2017 02:16:55 -0700 (PDT)
Received: from mail-ot0-x233.google.com (mail-ot0-x233.google.com. [2607:f8b0:4003:c0f::233])
        by mx.google.com with ESMTPS id n96si1785220otn.130.2017.06.17.02.16.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Jun 2017 02:16:54 -0700 (PDT)
Received: by mail-ot0-x233.google.com with SMTP id u13so29333347otd.2
        for <linux-mm@kvack.org>; Sat, 17 Jun 2017 02:16:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <7c4a35fe-67eb-6520-b036-bfa2b4267276@virtuozzo.com>
References: <cover.1496743523.git.dvyukov@google.com> <ca52d3d26fcc5d5d8af430bc269610d3aa7df252.1496743523.git.dvyukov@google.com>
 <7c4a35fe-67eb-6520-b036-bfa2b4267276@virtuozzo.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sat, 17 Jun 2017 11:16:33 +0200
Message-ID: <CACT4Y+aQqwa1bb0Z2OJ3JLE6V6+6cAaoEiGDZdFBa23RkS6q+g@mail.gmail.com>
Subject: Re: [PATCH v3 4/7] x86: switch atomic.h to use atomic-instrumented.h
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>

On Fri, Jun 16, 2017 at 5:54 PM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
> On 06/06/2017 01:11 PM, Dmitry Vyukov wrote:
>> Add arch_ prefix to all atomic operations and include
>> <asm-generic/atomic-instrumented.h>. This will allow
>> to add KASAN instrumentation to all atomic ops.
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
>>
>> ---
>
>
>
>
>> -static __always_inline void atomic_set(atomic_t *v, int i)
>> +static __always_inline void arch_atomic_set(atomic_t *v, int i)
>>  {
>> +     /*
>> +      * We could use WRITE_ONCE_NOCHECK() if it exists, similar to
>> +      * READ_ONCE_NOCHECK() in arch_atomic_read(). But there is no such
>> +      * thing at the moment, and introducing it for this case does not
>> +      * worth it.
>> +      */
>
>
> I'd rather remove this comment. I woudn't say that WRITE_ONCE() here looks confusing
> and needs comment. Also there is no READ_ONCE_NOCHECK() in arch_atomic_read() anymore.

Done.
It also should have gone to the patch that adds comments.


> Otherwise,
>         Reviewed-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
>
>>       WRITE_ONCE(v->counter, i);
>>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
