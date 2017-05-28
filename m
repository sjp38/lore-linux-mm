Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id BB39B6B0279
	for <linux-mm@kvack.org>; Sun, 28 May 2017 05:44:25 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id q23so18008931pgn.14
        for <linux-mm@kvack.org>; Sun, 28 May 2017 02:44:25 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [65.50.211.136])
        by mx.google.com with ESMTPS id a76si6886689pfc.145.2017.05.28.02.44.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 May 2017 02:44:24 -0700 (PDT)
Date: Sun, 28 May 2017 02:34:58 -0700
In-Reply-To: <CACT4Y+a0=FicpyHHyvnZg+EO0MOJsokwANYVKPKSkuyWC=g6Lg@mail.gmail.com>
References: <cover.1495825151.git.dvyukov@google.com> <3758f3da9de01b1a082c4e1f44ba3b48f7a840ea.1495825151.git.dvyukov@google.com> <683DBA00-B29A-4A05-A8DD-23E7C936C38E@zytor.com> <CACT4Y+a0=FicpyHHyvnZg+EO0MOJsokwANYVKPKSkuyWC=g6Lg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH v2 2/7] x86: use long long for 64-bit atomic ops
From: hpa@zytor.com
Message-ID: <CA6F3776-CE7E-4271-8138-387A472C3197@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Matthew Wilcox <willy@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On May 28, 2017 2:29:32 AM PDT, Dmitry Vyukov <dvyukov@google=2Ecom> wrote:
>On Sun, May 28, 2017 at 1:02 AM,  <hpa@zytor=2Ecom> wrote:
>> On May 26, 2017 12:09:04 PM PDT, Dmitry Vyukov <dvyukov@google=2Ecom>
>wrote:
>>>Some 64-bit atomic operations use 'long long' as operand/return type
>>>(e=2Eg=2E asm-generic/atomic64=2Eh, arch/x86/include/asm/atomic64_32=2E=
h);
>>>while others use 'long' (e=2Eg=2E arch/x86/include/asm/atomic64_64=2Eh)=
=2E
>>>This makes it impossible to write portable code=2E
>>>For example, there is no format specifier that prints result of
>>>atomic64_read() without warnings=2E atomic64_try_cmpxchg() is almost
>>>impossible to use in portable fashion because it requires either
>>>'long *' or 'long long *' as argument depending on arch=2E
>>>
>>>Switch arch/x86/include/asm/atomic64_64=2Eh to 'long long'=2E
>>>
>>>Signed-off-by: Dmitry Vyukov <dvyukov@google=2Ecom>
>>>Cc: Mark Rutland <mark=2Erutland@arm=2Ecom>
>>>Cc: Peter Zijlstra <peterz@infradead=2Eorg>
>>>Cc: Will Deacon <will=2Edeacon@arm=2Ecom>
>>>Cc: Andrew Morton <akpm@linux-foundation=2Eorg>
>>>Cc: Andrey Ryabinin <aryabinin@virtuozzo=2Ecom>
>>>Cc: Ingo Molnar <mingo@redhat=2Ecom>
>>>Cc: kasan-dev@googlegroups=2Ecom
>>>Cc: linux-mm@kvack=2Eorg
>>>Cc: linux-kernel@vger=2Ekernel=2Eorg
>>>Cc: x86@kernel=2Eorg
>>>
>>>---
>>>Changes since v1:
>>> - reverted stray s/long/long long/ replace in comment
>>> - added arch/s390 changes to fix build errors/warnings
>>>---
>>> arch/s390/include/asm/atomic_ops=2Eh | 14 +++++-----
>>> arch/s390/include/asm/bitops=2Eh     | 12 ++++-----
>>>arch/x86/include/asm/atomic64_64=2Eh | 52
>>>+++++++++++++++++++-------------------
>>> include/linux/types=2Eh              |  2 +-
>>> 4 files changed, 40 insertions(+), 40 deletions(-)
>>>
>>>diff --git a/arch/s390/include/asm/atomic_ops=2Eh
>>>b/arch/s390/include/asm/atomic_ops=2Eh
>>>index ac9e2b939d04=2E=2E055a9083e52d 100644
>>>--- a/arch/s390/include/asm/atomic_ops=2Eh
>>>+++ b/arch/s390/include/asm/atomic_ops=2Eh
>>>@@ -31,10 +31,10 @@ __ATOMIC_OPS(__atomic_and, int, "lan")
>>> __ATOMIC_OPS(__atomic_or,  int, "lao")
>>> __ATOMIC_OPS(__atomic_xor, int, "lax")
>>>
>>>-__ATOMIC_OPS(__atomic64_add, long, "laag")
>>>-__ATOMIC_OPS(__atomic64_and, long, "lang")
>>>-__ATOMIC_OPS(__atomic64_or,  long, "laog")
>>>-__ATOMIC_OPS(__atomic64_xor, long, "laxg")
>>>+__ATOMIC_OPS(__atomic64_add, long long, "laag")
>>>+__ATOMIC_OPS(__atomic64_and, long long, "lang")
>>>+__ATOMIC_OPS(__atomic64_or,  long long, "laog")
>>>+__ATOMIC_OPS(__atomic64_xor, long long, "laxg")
>>>
>>> #undef __ATOMIC_OPS
>>> #undef __ATOMIC_OP
>>>@@ -46,7 +46,7 @@ static inline void __atomic_add_const(int val, int
>>>*ptr)
>>>               : [ptr] "+Q" (*ptr) : [val] "i" (val) : "cc");
>>> }
>>>
>>>-static inline void __atomic64_add_const(long val, long *ptr)
>>>+static inline void __atomic64_add_const(long val, long long *ptr)
>>> {
>>>       asm volatile(
>>>               "       agsi    %[ptr],%[val]\n"
>>>@@ -82,7 +82,7 @@ __ATOMIC_OPS(__atomic_xor, "xr")
>>> #undef __ATOMIC_OPS
>>>
>>> #define __ATOMIC64_OP(op_name, op_string)                          =20
> \
>>>-static inline long op_name(long val, long *ptr)                    =20
>         \
>>>+static inline long op_name(long val, long long *ptr)               =20
> \
>>> {                                                                  =20
> \
>>>       long old, new;                                               =20
> \
>>>                                                                    =20
> \
>>>@@ -118,7 +118,7 @@ static inline int __atomic_cmpxchg(int *ptr, int
>>>old, int new)
>>>       return old;
>>> }
>>>
>>>-static inline long __atomic64_cmpxchg(long *ptr, long old, long new)
>>>+static inline long __atomic64_cmpxchg(long long *ptr, long old, long
>>>new)
>>> {
>>>       asm volatile(
>>>               "       csg     %[old],%[new],%[ptr]"
>>>diff --git a/arch/s390/include/asm/bitops=2Eh
>>>b/arch/s390/include/asm/bitops=2Eh
>>>index d92047da5ccb=2E=2E8912f52bca5d 100644
>>>--- a/arch/s390/include/asm/bitops=2Eh
>>>+++ b/arch/s390/include/asm/bitops=2Eh
>>>@@ -80,7 +80,7 @@ static inline void set_bit(unsigned long nr,
>volatile
>>>unsigned long *ptr)
>>>       }
>>> #endif
>>>       mask =3D 1UL << (nr & (BITS_PER_LONG - 1));
>>>-      __atomic64_or(mask, addr);
>>>+      __atomic64_or(mask, (long long *)addr);
>>> }
>>>
>>>static inline void clear_bit(unsigned long nr, volatile unsigned long
>>>*ptr)
>>>@@ -101,7 +101,7 @@ static inline void clear_bit(unsigned long nr,
>>>volatile unsigned long *ptr)
>>>       }
>>> #endif
>>>       mask =3D ~(1UL << (nr & (BITS_PER_LONG - 1)));
>>>-      __atomic64_and(mask, addr);
>>>+      __atomic64_and(mask, (long long *)addr);
>>> }
>>>
>>>static inline void change_bit(unsigned long nr, volatile unsigned
>long
>>>*ptr)
>>>@@ -122,7 +122,7 @@ static inline void change_bit(unsigned long nr,
>>>volatile unsigned long *ptr)
>>>       }
>>> #endif
>>>       mask =3D 1UL << (nr & (BITS_PER_LONG - 1));
>>>-      __atomic64_xor(mask, addr);
>>>+      __atomic64_xor(mask, (long long *)addr);
>>> }
>>>
>>> static inline int
>>>@@ -132,7 +132,7 @@ test_and_set_bit(unsigned long nr, volatile
>>>unsigned long *ptr)
>>>       unsigned long old, mask;
>>>
>>>       mask =3D 1UL << (nr & (BITS_PER_LONG - 1));
>>>-      old =3D __atomic64_or_barrier(mask, addr);
>>>+      old =3D __atomic64_or_barrier(mask, (long long *)addr);
>>>       return (old & mask) !=3D 0;
>>> }
>>>
>>>@@ -143,7 +143,7 @@ test_and_clear_bit(unsigned long nr, volatile
>>>unsigned long *ptr)
>>>       unsigned long old, mask;
>>>
>>>       mask =3D ~(1UL << (nr & (BITS_PER_LONG - 1)));
>>>-      old =3D __atomic64_and_barrier(mask, addr);
>>>+      old =3D __atomic64_and_barrier(mask, (long long *)addr);
>>>       return (old & ~mask) !=3D 0;
>>> }
>>>
>>>@@ -154,7 +154,7 @@ test_and_change_bit(unsigned long nr, volatile
>>>unsigned long *ptr)
>>>       unsigned long old, mask;
>>>
>>>       mask =3D 1UL << (nr & (BITS_PER_LONG - 1));
>>>-      old =3D __atomic64_xor_barrier(mask, addr);
>>>+      old =3D __atomic64_xor_barrier(mask, (long long *)addr);
>>>       return (old & mask) !=3D 0;
>>> }
>>>
>>>diff --git a/arch/x86/include/asm/atomic64_64=2Eh
>>>b/arch/x86/include/asm/atomic64_64=2Eh
>>>index 8db8879a6d8c=2E=2E8555cd19a916 100644
>>>--- a/arch/x86/include/asm/atomic64_64=2Eh
>>>+++ b/arch/x86/include/asm/atomic64_64=2Eh
>>>@@ -16,7 +16,7 @@
>>>  * Atomically reads the value of @v=2E
>>>  * Doesn't imply a read memory barrier=2E
>>>  */
>>>-static inline long atomic64_read(const atomic64_t *v)
>>>+static inline long long atomic64_read(const atomic64_t *v)
>>> {
>>>       return READ_ONCE((v)->counter);
>>> }
>>>@@ -28,7 +28,7 @@ static inline long atomic64_read(const atomic64_t
>*v)
>>>  *
>>>  * Atomically sets the value of @v to @i=2E
>>>  */
>>>-static inline void atomic64_set(atomic64_t *v, long i)
>>>+static inline void atomic64_set(atomic64_t *v, long long i)
>>> {
>>>       WRITE_ONCE(v->counter, i);
>>> }
>>>@@ -40,7 +40,7 @@ static inline void atomic64_set(atomic64_t *v, long
>>>i)
>>>  *
>>>  * Atomically adds @i to @v=2E
>>>  */
>>>-static __always_inline void atomic64_add(long i, atomic64_t *v)
>>>+static __always_inline void atomic64_add(long long i, atomic64_t *v)
>>> {
>>>       asm volatile(LOCK_PREFIX "addq %1,%0"
>>>                    : "=3Dm" (v->counter)
>>>@@ -54,7 +54,7 @@ static __always_inline void atomic64_add(long i,
>>>atomic64_t *v)
>>>  *
>>>  * Atomically subtracts @i from @v=2E
>>>  */
>>>-static inline void atomic64_sub(long i, atomic64_t *v)
>>>+static inline void atomic64_sub(long long i, atomic64_t *v)
>>> {
>>>       asm volatile(LOCK_PREFIX "subq %1,%0"
>>>                    : "=3Dm" (v->counter)
>>>@@ -70,7 +70,7 @@ static inline void atomic64_sub(long i, atomic64_t
>>>*v)
>>>  * true if the result is zero, or false for all
>>>  * other cases=2E
>>>  */
>>>-static inline bool atomic64_sub_and_test(long i, atomic64_t *v)
>>>+static inline bool atomic64_sub_and_test(long long i, atomic64_t *v)
>>> {
>>>       GEN_BINARY_RMWcc(LOCK_PREFIX "subq", v->counter, "er", i,
>"%0", e);
>>> }
>>>@@ -136,7 +136,7 @@ static inline bool
>atomic64_inc_and_test(atomic64_t
>>>*v)
>>>  * if the result is negative, or false when
>>>  * result is greater than or equal to zero=2E
>>>  */
>>>-static inline bool atomic64_add_negative(long i, atomic64_t *v)
>>>+static inline bool atomic64_add_negative(long long i, atomic64_t *v)
>>> {
>>>       GEN_BINARY_RMWcc(LOCK_PREFIX "addq", v->counter, "er", i,
>"%0", s);
>>> }
>>>@@ -148,22 +148,22 @@ static inline bool atomic64_add_negative(long
>i,
>>>atomic64_t *v)
>>>  *
>>>  * Atomically adds @i to @v and returns @i + @v
>>>  */
>>>-static __always_inline long atomic64_add_return(long i, atomic64_t
>*v)
>>>+static __always_inline long long atomic64_add_return(long long i,
>>>atomic64_t *v)
>>> {
>>>       return i + xadd(&v->counter, i);
>>> }
>>>
>>>-static inline long atomic64_sub_return(long i, atomic64_t *v)
>>>+static inline long long atomic64_sub_return(long long i, atomic64_t
>>>*v)
>>> {
>>>       return atomic64_add_return(-i, v);
>>> }
>>>
>>>-static inline long atomic64_fetch_add(long i, atomic64_t *v)
>>>+static inline long long atomic64_fetch_add(long long i, atomic64_t
>*v)
>>> {
>>>       return xadd(&v->counter, i);
>>> }
>>>
>>>-static inline long atomic64_fetch_sub(long i, atomic64_t *v)
>>>+static inline long long atomic64_fetch_sub(long long i, atomic64_t
>*v)
>>> {
>>>       return xadd(&v->counter, -i);
>>> }
>>>@@ -171,18 +171,18 @@ static inline long atomic64_fetch_sub(long i,
>>>atomic64_t *v)
>>> #define atomic64_inc_return(v)  (atomic64_add_return(1, (v)))
>>> #define atomic64_dec_return(v)  (atomic64_sub_return(1, (v)))
>>>
>>>-static inline long atomic64_cmpxchg(atomic64_t *v, long old, long
>new)
>>>+static inline long long atomic64_cmpxchg(atomic64_t *v, long long
>old,
>>>long long new)
>>> {
>>>       return cmpxchg(&v->counter, old, new);
>>> }
>>>
>>> #define atomic64_try_cmpxchg atomic64_try_cmpxchg
>>>-static __always_inline bool atomic64_try_cmpxchg(atomic64_t *v, long
>>>*old, long new)
>>>+static __always_inline bool atomic64_try_cmpxchg(atomic64_t *v, long
>>>long *old, long long new)
>>> {
>>>       return try_cmpxchg(&v->counter, old, new);
>>> }
>>>
>>>-static inline long atomic64_xchg(atomic64_t *v, long new)
>>>+static inline long long atomic64_xchg(atomic64_t *v, long long new)
>>> {
>>>       return xchg(&v->counter, new);
>>> }
>>>@@ -196,9 +196,9 @@ static inline long atomic64_xchg(atomic64_t *v,
>>>long new)
>>>  * Atomically adds @a to @v, so long as it was not @u=2E
>>>  * Returns the old value of @v=2E
>>>  */
>>>-static inline bool atomic64_add_unless(atomic64_t *v, long a, long
>u)
>>>+static inline bool atomic64_add_unless(atomic64_t *v, long long a,
>>>long long u)
>>> {
>>>-      long c =3D atomic64_read(v);
>>>+      long long c =3D atomic64_read(v);
>>>       do {
>>>               if (unlikely(c =3D=3D u))
>>>                       return false;
>>>@@ -215,9 +215,9 @@ static inline bool atomic64_add_unless(atomic64_t
>>>*v, long a, long u)
>>>  * The function returns the old value of *v minus 1, even if
>>>  * the atomic variable, v, was not decremented=2E
>>>  */
>>>-static inline long atomic64_dec_if_positive(atomic64_t *v)
>>>+static inline long long atomic64_dec_if_positive(atomic64_t *v)
>>> {
>>>-      long dec, c =3D atomic64_read(v);
>>>+      long long dec, c =3D atomic64_read(v);
>>>       do {
>>>               dec =3D c - 1;
>>>               if (unlikely(dec < 0))
>>>@@ -226,7 +226,7 @@ static inline long
>>>atomic64_dec_if_positive(atomic64_t *v)
>>>       return dec;
>>> }
>>>
>>>-static inline void atomic64_and(long i, atomic64_t *v)
>>>+static inline void atomic64_and(long long i, atomic64_t *v)
>>> {
>>>       asm volatile(LOCK_PREFIX "andq %1,%0"
>>>                       : "+m" (v->counter)
>>>@@ -234,16 +234,16 @@ static inline void atomic64_and(long i,
>>>atomic64_t *v)
>>>                       : "memory");
>>> }
>>>
>>>-static inline long atomic64_fetch_and(long i, atomic64_t *v)
>>>+static inline long long atomic64_fetch_and(long long i, atomic64_t
>*v)
>>> {
>>>-      long val =3D atomic64_read(v);
>>>+      long long val =3D atomic64_read(v);
>>>
>>>       do {
>>>       } while (!atomic64_try_cmpxchg(v, &val, val & i));
>>>       return val;
>>> }
>>>
>>>-static inline void atomic64_or(long i, atomic64_t *v)
>>>+static inline void atomic64_or(long long i, atomic64_t *v)
>>> {
>>>       asm volatile(LOCK_PREFIX "orq %1,%0"
>>>                       : "+m" (v->counter)
>>>@@ -251,16 +251,16 @@ static inline void atomic64_or(long i,
>atomic64_t
>>>*v)
>>>                       : "memory");
>>> }
>>>
>>>-static inline long atomic64_fetch_or(long i, atomic64_t *v)
>>>+static inline long long atomic64_fetch_or(long long i, atomic64_t
>*v)
>>> {
>>>-      long val =3D atomic64_read(v);
>>>+      long long val =3D atomic64_read(v);
>>>
>>>       do {
>>>       } while (!atomic64_try_cmpxchg(v, &val, val | i));
>>>       return val;
>>> }
>>>
>>>-static inline void atomic64_xor(long i, atomic64_t *v)
>>>+static inline void atomic64_xor(long long i, atomic64_t *v)
>>> {
>>>       asm volatile(LOCK_PREFIX "xorq %1,%0"
>>>                       : "+m" (v->counter)
>>>@@ -268,9 +268,9 @@ static inline void atomic64_xor(long i,
>atomic64_t
>>>*v)
>>>                       : "memory");
>>> }
>>>
>>>-static inline long atomic64_fetch_xor(long i, atomic64_t *v)
>>>+static inline long long atomic64_fetch_xor(long long i, atomic64_t
>*v)
>>> {
>>>-      long val =3D atomic64_read(v);
>>>+      long long val =3D atomic64_read(v);
>>>
>>>       do {
>>>       } while (!atomic64_try_cmpxchg(v, &val, val ^ i));
>>>diff --git a/include/linux/types=2Eh b/include/linux/types=2Eh
>>>index 1e7bd24848fc=2E=2E569fc6db1bd5 100644
>>>--- a/include/linux/types=2Eh
>>>+++ b/include/linux/types=2Eh
>>>@@ -177,7 +177,7 @@ typedef struct {
>>>
>>> #ifdef CONFIG_64BIT
>>> typedef struct {
>>>-      long counter;
>>>+      long long counter;
>>> } atomic64_t;
>>> #endif
>>>
>>
>> NAK - this is what u64/s64 is for=2E
>
>
>Hi,
>
>Patch 3 adds atomic-instrumented=2Eh which now contains:
>
>+static __always_inline long long atomic64_read(const atomic64_t *v)
>+{
>+       return arch_atomic64_read(v);
>+}
>
>without this patch that will become
>
>+static __always_inline s64 atomic64_read(const atomic64_t *v)
>
>Right?

Yes=2E
--=20
Sent from my Android device with K-9 Mail=2E Please excuse my brevity=2E

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
