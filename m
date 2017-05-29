Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3FCA46B0292
	for <linux-mm@kvack.org>; Mon, 29 May 2017 07:03:54 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id g12so17754793uab.10
        for <linux-mm@kvack.org>; Mon, 29 May 2017 04:03:54 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x63sor1291056vkx.16.2017.05.29.04.03.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 May 2017 04:03:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170529104916.GB12975@osiris>
References: <cover.1495825151.git.dvyukov@google.com> <3758f3da9de01b1a082c4e1f44ba3b48f7a840ea.1495825151.git.dvyukov@google.com>
 <20170529104916.GB12975@osiris>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 29 May 2017 13:03:32 +0200
Message-ID: <CACT4Y+aptgVy4Co0WcsZ9sbDpKSJAM58oFOwBRQK99arMf5a+w@mail.gmail.com>
Subject: Re: [PATCH v2 2/7] x86: use long long for 64-bit atomic ops
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Matthew Wilcox <willy@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, May 29, 2017 at 12:49 PM, Heiko Carstens
<heiko.carstens@de.ibm.com> wrote:
> On Fri, May 26, 2017 at 09:09:04PM +0200, Dmitry Vyukov wrote:
>> Some 64-bit atomic operations use 'long long' as operand/return type
>> (e.g. asm-generic/atomic64.h, arch/x86/include/asm/atomic64_32.h);
>> while others use 'long' (e.g. arch/x86/include/asm/atomic64_64.h).
>> This makes it impossible to write portable code.
>> For example, there is no format specifier that prints result of
>> atomic64_read() without warnings. atomic64_try_cmpxchg() is almost
>> impossible to use in portable fashion because it requires either
>> 'long *' or 'long long *' as argument depending on arch.
>>
>> Switch arch/x86/include/asm/atomic64_64.h to 'long long'.
>>
>> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
>>
>> ---
>> Changes since v1:
>>  - reverted stray s/long/long long/ replace in comment
>>  - added arch/s390 changes to fix build errors/warnings
>
> If you change s390 code, please add the relevant mailing list and/or
> maintainers please.
>
>> diff --git a/arch/s390/include/asm/atomic_ops.h b/arch/s390/include/asm/atomic_ops.h
>> index ac9e2b939d04..055a9083e52d 100644
>> --- a/arch/s390/include/asm/atomic_ops.h
>> +++ b/arch/s390/include/asm/atomic_ops.h
>> @@ -31,10 +31,10 @@ __ATOMIC_OPS(__atomic_and, int, "lan")
>>  __ATOMIC_OPS(__atomic_or,  int, "lao")
>>  __ATOMIC_OPS(__atomic_xor, int, "lax")
>>
>> -__ATOMIC_OPS(__atomic64_add, long, "laag")
>> -__ATOMIC_OPS(__atomic64_and, long, "lang")
>> -__ATOMIC_OPS(__atomic64_or,  long, "laog")
>> -__ATOMIC_OPS(__atomic64_xor, long, "laxg")
>> +__ATOMIC_OPS(__atomic64_add, long long, "laag")
>> +__ATOMIC_OPS(__atomic64_and, long long, "lang")
>> +__ATOMIC_OPS(__atomic64_or,  long long, "laog")
>> +__ATOMIC_OPS(__atomic64_xor, long long, "laxg")
>>
>>  #undef __ATOMIC_OPS
>>  #undef __ATOMIC_OP
>> @@ -46,7 +46,7 @@ static inline void __atomic_add_const(int val, int *ptr)
>>               : [ptr] "+Q" (*ptr) : [val] "i" (val) : "cc");
>>  }
>>
>> -static inline void __atomic64_add_const(long val, long *ptr)
>> +static inline void __atomic64_add_const(long val, long long *ptr)
>
> If you change this then val should be long long (or s64) too.
>
>> -static inline long op_name(long val, long *ptr)                              \
>> +static inline long op_name(long val, long long *ptr)                 \
>>  {                                                                    \
>>       long old, new;                                                  \
>
> Same here. You only changed the type of *ptr, but left the rest
> alone. Everything should have the same type.

I will try to follow hpa's suggestion in the next version of the
patch. If it work out, I will not need to touch s390 code.

Still thanks for the review.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
