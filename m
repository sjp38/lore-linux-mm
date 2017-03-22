Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0E4026B0353
	for <linux-mm@kvack.org>; Wed, 22 Mar 2017 08:58:19 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id d188so59028867vka.2
        for <linux-mm@kvack.org>; Wed, 22 Mar 2017 05:58:19 -0700 (PDT)
Received: from mail-vk0-x22a.google.com (mail-vk0-x22a.google.com. [2607:f8b0:400c:c05::22a])
        by mx.google.com with ESMTPS id y45si446691uag.232.2017.03.22.05.58.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Mar 2017 05:58:18 -0700 (PDT)
Received: by mail-vk0-x22a.google.com with SMTP id r69so13680266vke.2
        for <linux-mm@kvack.org>; Wed, 22 Mar 2017 05:58:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAK8P3a2eJHjG6qwJZH8M2iziFtjhiWsHU45fjuXtoNBGwSdgjQ@mail.gmail.com>
References: <20170322122449.54505-1-dvyukov@google.com> <CAK8P3a2eJHjG6qwJZH8M2iziFtjhiWsHU45fjuXtoNBGwSdgjQ@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 22 Mar 2017 13:57:56 +0100
Message-ID: <CACT4Y+YHYBq-0QchHaKomgVfRy-eAn3YVp5rnED3JySzRRJ+AQ@mail.gmail.com>
Subject: Re: [PATCH] x86: s/READ_ONCE_NOCHECK/READ_ONCE/ in arch_atomic_read()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Mark Rutland <mark.rutland@arm.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, Linux-MM <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>

On Wed, Mar 22, 2017 at 1:51 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Wed, Mar 22, 2017 at 1:24 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
>> Two problems was reported with READ_ONCE_NOCHECK in arch_atomic_read:
>> 1. Andrey Ryabinin reported significant binary size increase
>> (+400K of text). READ_ONCE_NOCHECK is intentionally compiled to
>> non-inlined function call, and I counted 640 copies of it in my vmlinux.
>> 2. Arnd Bergmann reported a new splat of too large frame sizes.
>>
>> A single inlined KASAN check is very cheap, a non-inlined function
>> call with KASAN/KCOV instrumentation can easily be more expensive.
>>
>> Switch to READ_ONCE() in arch_atomic_read().
>>
>> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
>> Reported-by: Arnd Bergmann <arnd@arndb.de>
>> Reported-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
>> Cc: Mark Rutland <mark.rutland@arm.com>
>> Cc: Peter Zijlstra <peterz@infradead.org>
>> Cc: Will Deacon <will.deacon@arm.com>
>> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: linux-mm@kvack.org
>> Cc: x86@kernel.org
>> Cc: linux-kernel@vger.kernel.org
>> Cc: kasan-dev@googlegroups.com
>> ---
>>  arch/x86/include/asm/atomic.h | 15 ++++++---------
>>  1 file changed, 6 insertions(+), 9 deletions(-)
>>
>> diff --git a/arch/x86/include/asm/atomic.h b/arch/x86/include/asm/atomic.h
>> index 0cde164f058a..46e53bbf7ce3 100644
>> --- a/arch/x86/include/asm/atomic.h
>> +++ b/arch/x86/include/asm/atomic.h
>> @@ -24,10 +24,13 @@
>>  static __always_inline int arch_atomic_read(const atomic_t *v)
>>  {
>>         /*
>> -        * We use READ_ONCE_NOCHECK() because atomic_read() contains KASAN
>> -        * instrumentation. Double instrumentation is unnecessary.
>> +        * Note: READ_ONCE() here leads to double instrumentation as
>> +        * both READ_ONCE() and atomic_read() contain instrumentation.
>> +        * This is deliberate choice. READ_ONCE_NOCHECK() is compiled to a
>> +        * non-inlined function call that considerably increases binary size
>> +        * and stack usage under KASAN.
>>          */
>> -       return READ_ONCE_NOCHECK((v)->counter);
>> +       return READ_ONCE((v)->counter);
>>  }
>
> The change looks good, but the same one is needed in atomic64.h

Right. Mailed v2.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
