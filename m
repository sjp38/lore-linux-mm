Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id D87A16B0397
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 11:53:06 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id 6so7371345vkn.10
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 08:53:06 -0700 (PDT)
Received: from mail-vk0-x22d.google.com (mail-vk0-x22d.google.com. [2607:f8b0:400c:c05::22d])
        by mx.google.com with ESMTPS id s14si3167767uag.189.2017.03.29.08.53.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Mar 2017 08:53:05 -0700 (PDT)
Received: by mail-vk0-x22d.google.com with SMTP id s68so22832951vke.3
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 08:53:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170329140000.GK23442@leverpostej>
References: <cover.1490717337.git.dvyukov@google.com> <b560d54e8be963f4155036a1f4b94d7f48b20af5.1490717337.git.dvyukov@google.com>
 <20170329140000.GK23442@leverpostej>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 29 Mar 2017 17:52:43 +0200
Message-ID: <CACT4Y+ay7J4kdLG1i2Czop6H3pDKxpcRVxM0xoNiZ2pJ0emHQw@mail.gmail.com>
Subject: Re: [PATCH 7/8] asm-generic: add KASAN instrumentation to atomic operations
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Will Deacon <will.deacon@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Mar 29, 2017 at 4:00 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> On Tue, Mar 28, 2017 at 06:15:44PM +0200, Dmitry Vyukov wrote:
>> KASAN uses compiler instrumentation to intercept all memory accesses.
>> But it does not see memory accesses done in assembly code.
>> One notable user of assembly code is atomic operations. Frequently,
>> for example, an atomic reference decrement is the last access to an
>> object and a good candidate for a racy use-after-free.
>>
>> Add manual KASAN checks to atomic operations.
>>
>> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
>> Cc: Mark Rutland <mark.rutland@arm.com>
>> Cc: Peter Zijlstra <peterz@infradead.org>
>> Cc: Will Deacon <will.deacon@arm.com>,
>> Cc: Andrew Morton <akpm@linux-foundation.org>,
>> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
>> Cc: Ingo Molnar <mingo@redhat.com>,
>> Cc: kasan-dev@googlegroups.com
>> Cc: linux-mm@kvack.org
>> Cc: linux-kernel@vger.kernel.org
>> Cc: x86@kernel.org
>
> FWIW, I think that structuring the file this way will make it easier to
> add the {acquire,release,relaxed} variants (as arm64 will need),
> so this looks good to me.
>
> As a heads-up, I wanted to have a go at that, but I wasn't able to apply
> patch two onwards on v4.11-rc{3,4} or next-20170329. I was not able to
> cleanly revert the instrumentation patches currently in next-20170329,
> since other patches built atop of them.

I based it on git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git
locking/core


> It would be nice to see that sorted out.
>
> Thanks,
> Mark.
>
>> ---
>>  include/asm-generic/atomic-instrumented.h | 76 +++++++++++++++++++++++++++++--
>>  1 file changed, 72 insertions(+), 4 deletions(-)
>>
>> diff --git a/include/asm-generic/atomic-instrumented.h b/include/asm-generic/atomic-instrumented.h
>> index fd483115d4c6..7f8eb761f896 100644
>> --- a/include/asm-generic/atomic-instrumented.h
>> +++ b/include/asm-generic/atomic-instrumented.h
>> @@ -1,44 +1,54 @@
>>  #ifndef _LINUX_ATOMIC_INSTRUMENTED_H
>>  #define _LINUX_ATOMIC_INSTRUMENTED_H
>>
>> +#include <linux/kasan-checks.h>
>> +
>>  static __always_inline int atomic_read(const atomic_t *v)
>>  {
>> +     kasan_check_read(v, sizeof(*v));
>>       return arch_atomic_read(v);
>>  }
>>
>>  static __always_inline long long atomic64_read(const atomic64_t *v)
>>  {
>> +     kasan_check_read(v, sizeof(*v));
>>       return arch_atomic64_read(v);
>>  }
>>
>>  static __always_inline void atomic_set(atomic_t *v, int i)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       arch_atomic_set(v, i);
>>  }
>>
>>  static __always_inline void atomic64_set(atomic64_t *v, long long i)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       arch_atomic64_set(v, i);
>>  }
>>
>>  static __always_inline int atomic_xchg(atomic_t *v, int i)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       return arch_atomic_xchg(v, i);
>>  }
>>
>>  static __always_inline long long atomic64_xchg(atomic64_t *v, long long i)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       return arch_atomic64_xchg(v, i);
>>  }
>>
>>  static __always_inline int atomic_cmpxchg(atomic_t *v, int old, int new)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       return arch_atomic_cmpxchg(v, old, new);
>>  }
>>
>>  static __always_inline long long atomic64_cmpxchg(atomic64_t *v, long long old,
>>                                                 long long new)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       return arch_atomic64_cmpxchg(v, old, new);
>>  }
>>
>> @@ -46,6 +56,8 @@ static __always_inline long long atomic64_cmpxchg(atomic64_t *v, long long old,
>>  #define atomic_try_cmpxchg atomic_try_cmpxchg
>>  static __always_inline bool atomic_try_cmpxchg(atomic_t *v, int *old, int new)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>> +     kasan_check_read(old, sizeof(*old));
>>       return arch_atomic_try_cmpxchg(v, old, new);
>>  }
>>  #endif
>> @@ -55,12 +67,15 @@ static __always_inline bool atomic_try_cmpxchg(atomic_t *v, int *old, int new)
>>  static __always_inline bool atomic64_try_cmpxchg(atomic64_t *v, long long *old,
>>                                                long long new)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>> +     kasan_check_read(old, sizeof(*old));
>>       return arch_atomic64_try_cmpxchg(v, old, new);
>>  }
>>  #endif
>>
>>  static __always_inline int __atomic_add_unless(atomic_t *v, int a, int u)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       return __arch_atomic_add_unless(v, a, u);
>>  }
>>
>> @@ -68,242 +83,295 @@ static __always_inline int __atomic_add_unless(atomic_t *v, int a, int u)
>>  static __always_inline bool atomic64_add_unless(atomic64_t *v, long long a,
>>                                               long long u)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       return arch_atomic64_add_unless(v, a, u);
>>  }
>>
>>  static __always_inline void atomic_inc(atomic_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       arch_atomic_inc(v);
>>  }
>>
>>  static __always_inline void atomic64_inc(atomic64_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       arch_atomic64_inc(v);
>>  }
>>
>>  static __always_inline void atomic_dec(atomic_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       arch_atomic_dec(v);
>>  }
>>
>>  static __always_inline void atomic64_dec(atomic64_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       arch_atomic64_dec(v);
>>  }
>>
>>  static __always_inline void atomic_add(int i, atomic_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       arch_atomic_add(i, v);
>>  }
>>
>>  static __always_inline void atomic64_add(long long i, atomic64_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       arch_atomic64_add(i, v);
>>  }
>>
>>  static __always_inline void atomic_sub(int i, atomic_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       arch_atomic_sub(i, v);
>>  }
>>
>>  static __always_inline void atomic64_sub(long long i, atomic64_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       arch_atomic64_sub(i, v);
>>  }
>>
>>  static __always_inline void atomic_and(int i, atomic_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       arch_atomic_and(i, v);
>>  }
>>
>>  static __always_inline void atomic64_and(long long i, atomic64_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       arch_atomic64_and(i, v);
>>  }
>>
>>  static __always_inline void atomic_or(int i, atomic_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       arch_atomic_or(i, v);
>>  }
>>
>>  static __always_inline void atomic64_or(long long i, atomic64_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       arch_atomic64_or(i, v);
>>  }
>>
>>  static __always_inline void atomic_xor(int i, atomic_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       arch_atomic_xor(i, v);
>>  }
>>
>>  static __always_inline void atomic64_xor(long long i, atomic64_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       arch_atomic64_xor(i, v);
>>  }
>>
>>  static __always_inline int atomic_inc_return(atomic_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       return arch_atomic_inc_return(v);
>>  }
>>
>>  static __always_inline long long atomic64_inc_return(atomic64_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       return arch_atomic64_inc_return(v);
>>  }
>>
>>  static __always_inline int atomic_dec_return(atomic_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       return arch_atomic_dec_return(v);
>>  }
>>
>>  static __always_inline long long atomic64_dec_return(atomic64_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       return arch_atomic64_dec_return(v);
>>  }
>>
>>  static __always_inline long long atomic64_inc_not_zero(atomic64_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       return arch_atomic64_inc_not_zero(v);
>>  }
>>
>>  static __always_inline long long atomic64_dec_if_positive(atomic64_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       return arch_atomic64_dec_if_positive(v);
>>  }
>>
>>  static __always_inline bool atomic_dec_and_test(atomic_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       return arch_atomic_dec_and_test(v);
>>  }
>>
>>  static __always_inline bool atomic64_dec_and_test(atomic64_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       return arch_atomic64_dec_and_test(v);
>>  }
>>
>>  static __always_inline bool atomic_inc_and_test(atomic_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       return arch_atomic_inc_and_test(v);
>>  }
>>
>>  static __always_inline bool atomic64_inc_and_test(atomic64_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       return arch_atomic64_inc_and_test(v);
>>  }
>>
>>  static __always_inline int atomic_add_return(int i, atomic_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       return arch_atomic_add_return(i, v);
>>  }
>>
>>  static __always_inline long long atomic64_add_return(long long i, atomic64_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       return arch_atomic64_add_return(i, v);
>>  }
>>
>>  static __always_inline int atomic_sub_return(int i, atomic_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       return arch_atomic_sub_return(i, v);
>>  }
>>
>>  static __always_inline long long atomic64_sub_return(long long i, atomic64_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       return arch_atomic64_sub_return(i, v);
>>  }
>>
>>  static __always_inline int atomic_fetch_add(int i, atomic_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       return arch_atomic_fetch_add(i, v);
>>  }
>>
>>  static __always_inline long long atomic64_fetch_add(long long i, atomic64_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       return arch_atomic64_fetch_add(i, v);
>>  }
>>
>>  static __always_inline int atomic_fetch_sub(int i, atomic_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       return arch_atomic_fetch_sub(i, v);
>>  }
>>
>>  static __always_inline long long atomic64_fetch_sub(long long i, atomic64_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       return arch_atomic64_fetch_sub(i, v);
>>  }
>>
>>  static __always_inline int atomic_fetch_and(int i, atomic_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       return arch_atomic_fetch_and(i, v);
>>  }
>>
>>  static __always_inline long long atomic64_fetch_and(long long i, atomic64_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       return arch_atomic64_fetch_and(i, v);
>>  }
>>
>>  static __always_inline int atomic_fetch_or(int i, atomic_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       return arch_atomic_fetch_or(i, v);
>>  }
>>
>>  static __always_inline long long atomic64_fetch_or(long long i, atomic64_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       return arch_atomic64_fetch_or(i, v);
>>  }
>>
>>  static __always_inline int atomic_fetch_xor(int i, atomic_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       return arch_atomic_fetch_xor(i, v);
>>  }
>>
>>  static __always_inline long long atomic64_fetch_xor(long long i, atomic64_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       return arch_atomic64_fetch_xor(i, v);
>>  }
>>
>>  static __always_inline bool atomic_sub_and_test(int i, atomic_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       return arch_atomic_sub_and_test(i, v);
>>  }
>>
>>  static __always_inline bool atomic64_sub_and_test(long long i, atomic64_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       return arch_atomic64_sub_and_test(i, v);
>>  }
>>
>>  static __always_inline bool atomic_add_negative(int i, atomic_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       return arch_atomic_add_negative(i, v);
>>  }
>>
>>  static __always_inline bool atomic64_add_negative(long long i, atomic64_t *v)
>>  {
>> +     kasan_check_write(v, sizeof(*v));
>>       return arch_atomic64_add_negative(i, v);
>>  }
>>
>>  #define cmpxchg(ptr, old, new)                               \
>>  ({                                                   \
>> +     __typeof__(ptr) ___ptr = (ptr);                 \
>> +     kasan_check_write(___ptr, sizeof(*___ptr));     \
>>       arch_cmpxchg((ptr), (old), (new));              \
>>  })
>>
>>  #define sync_cmpxchg(ptr, old, new)                  \
>>  ({                                                   \
>> -     arch_sync_cmpxchg((ptr), (old), (new));         \
>> +     __typeof__(ptr) ___ptr = (ptr);                 \
>> +     kasan_check_write(___ptr, sizeof(*___ptr));     \
>> +     arch_sync_cmpxchg(___ptr, (old), (new));        \
>>  })
>>
>>  #define cmpxchg_local(ptr, old, new)                 \
>>  ({                                                   \
>> -     arch_cmpxchg_local((ptr), (old), (new));        \
>> +     __typeof__(ptr) ____ptr = (ptr);                \
>> +     kasan_check_write(____ptr, sizeof(*____ptr));   \
>> +     arch_cmpxchg_local(____ptr, (old), (new));      \
>>  })
>>
>>  #define cmpxchg64(ptr, old, new)                     \
>>  ({                                                   \
>> -     arch_cmpxchg64((ptr), (old), (new));            \
>> +     __typeof__(ptr) ____ptr = (ptr);                \
>> +     kasan_check_write(____ptr, sizeof(*____ptr));   \
>> +     arch_cmpxchg64(____ptr, (old), (new));          \
>>  })
>>
>>  #define cmpxchg64_local(ptr, old, new)                       \
>>  ({                                                   \
>> -     arch_cmpxchg64_local((ptr), (old), (new));      \
>> +     __typeof__(ptr) ____ptr = (ptr);                \
>> +     kasan_check_write(____ptr, sizeof(*____ptr));   \
>> +     arch_cmpxchg64_local(____ptr, (old), (new));    \
>>  })
>>
>>  #define cmpxchg_double(p1, p2, o1, o2, n1, n2)                               \
>> --
>> 2.12.2.564.g063fe858b8-goog
>>
>
> --
> You received this message because you are subscribed to the Google Groups "kasan-dev" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kasan-dev+unsubscribe@googlegroups.com.
> To post to this group, send email to kasan-dev@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/kasan-dev/20170329140000.GK23442%40leverpostej.
> For more options, visit https://groups.google.com/d/optout.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
