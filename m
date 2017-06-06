Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 78CCD6B0338
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 06:12:53 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id 23so44097528uaj.5
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 03:12:53 -0700 (PDT)
Received: from mail-ua0-x229.google.com (mail-ua0-x229.google.com. [2607:f8b0:400c:c08::229])
        by mx.google.com with ESMTPS id m15si18408535vkf.120.2017.06.06.03.12.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jun 2017 03:12:52 -0700 (PDT)
Received: by mail-ua0-x229.google.com with SMTP id q15so6736664uaa.2
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 03:12:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+bJFLZ65Ms9cFOQtZz2wg4dmnB39jB6OqT2a3rALskzoA@mail.gmail.com>
References: <cover.1495825151.git.dvyukov@google.com> <3758f3da9de01b1a082c4e1f44ba3b48f7a840ea.1495825151.git.dvyukov@google.com>
 <683DBA00-B29A-4A05-A8DD-23E7C936C38E@zytor.com> <CACT4Y+a0=FicpyHHyvnZg+EO0MOJsokwANYVKPKSkuyWC=g6Lg@mail.gmail.com>
 <CA6F3776-CE7E-4271-8138-387A472C3197@zytor.com> <CACT4Y+bJFLZ65Ms9cFOQtZz2wg4dmnB39jB6OqT2a3rALskzoA@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 6 Jun 2017 12:12:31 +0200
Message-ID: <CACT4Y+bbZ0-MDXRTPjRBHFVDNV3A3_2PxC9FaT+jO+vsoqGvzQ@mail.gmail.com>
Subject: Re: [PATCH v2 2/7] x86: use long long for 64-bit atomic ops
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Matthew Wilcox <willy@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, May 29, 2017 at 4:44 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Sun, May 28, 2017 at 11:34 AM,  <hpa@zytor.com> wrote:
>> On May 28, 2017 2:29:32 AM PDT, Dmitry Vyukov <dvyukov@google.com> wrote:
>>>On Sun, May 28, 2017 at 1:02 AM,  <hpa@zytor.com> wrote:
>>>> On May 26, 2017 12:09:04 PM PDT, Dmitry Vyukov <dvyukov@google.com>
>>>wrote:
>>>>>Some 64-bit atomic operations use 'long long' as operand/return type
>>>>>(e.g. asm-generic/atomic64.h, arch/x86/include/asm/atomic64_32.h);
>>>>>while others use 'long' (e.g. arch/x86/include/asm/atomic64_64.h).
>>>>>This makes it impossible to write portable code.
>>>>>For example, there is no format specifier that prints result of
>>>>>atomic64_read() without warnings. atomic64_try_cmpxchg() is almost
>>>>>impossible to use in portable fashion because it requires either
>>>>>'long *' or 'long long *' as argument depending on arch.
>>>>>
>>>>>Switch arch/x86/include/asm/atomic64_64.h to 'long long'.
>>>>>
>>>>>Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
>>>>>Cc: Mark Rutland <mark.rutland@arm.com>
>>>>>Cc: Peter Zijlstra <peterz@infradead.org>
>>>>>Cc: Will Deacon <will.deacon@arm.com>
>>>>>Cc: Andrew Morton <akpm@linux-foundation.org>
>>>>>Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
>>>>>Cc: Ingo Molnar <mingo@redhat.com>
>>>>>Cc: kasan-dev@googlegroups.com
>>>>>Cc: linux-mm@kvack.org
>>>>>Cc: linux-kernel@vger.kernel.org
>>>>>Cc: x86@kernel.org
>>>>>
>>>>>---
>>>>>Changes since v1:
>>>>> - reverted stray s/long/long long/ replace in comment
>>>>> - added arch/s390 changes to fix build errors/warnings
>>>>>---
>
> [snip]
>
>>>> NAK - this is what u64/s64 is for.

Mailed v3 with all requested changes.


>>>Hi,
>>>
>>>Patch 3 adds atomic-instrumented.h which now contains:
>>>
>>>+static __always_inline long long atomic64_read(const atomic64_t *v)
>>>+{
>>>+       return arch_atomic64_read(v);
>>>+}
>>>
>>>without this patch that will become
>>>
>>>+static __always_inline s64 atomic64_read(const atomic64_t *v)
>>>
>>>Right?
>>
>> Yes.
>
>
> I see that s64 is not the same as long on x86_64 (long long vs long),
> so it's still not possible to e.g. portably print a result of
> atomic_read(). But it's a separate issue that we don't need to solve
> now.
>
> Also all wrappers like:
>
> void atomic64_set(atomic64_t *v, s64 i)
> {
>     arch_atomic64_set(v, i);
> }
>
> lead to type conversions, but at least my compiler does not bark on it.
>
> The only remaining problem is with atomic64_try_cmpxchg, which is
> simply not possible to use now (not possible to declare the *old
> type).
> I will need something along the following lines to fix it (then
> callers can use s64* for old).
> Sounds good?
>
>
> --- a/arch/x86/include/asm/atomic64_64.h
> +++ b/arch/x86/include/asm/atomic64_64.h
> @@ -177,7 +177,7 @@ static inline long
> arch_atomic64_cmpxchg(atomic64_t *v, long old, long new)
>  }
>
>  #define arch_atomic64_try_cmpxchg arch_atomic64_try_cmpxchg
> -static __always_inline bool arch_atomic64_try_cmpxchg(atomic64_t *v,
> long *old, long new)
> +static __always_inline bool arch_atomic64_try_cmpxchg(atomic64_t *v,
> s64 *old, long new)
>  {
>         return try_cmpxchg(&v->counter, old, new);
>  }
> @@ -198,7 +198,7 @@ static inline long arch_atomic64_xchg(atomic64_t
> *v, long new)
>   */
>  static inline bool arch_atomic64_add_unless(atomic64_t *v, long a, long u)
>  {
> -       long c = arch_atomic64_read(v);
> +       s64 c = arch_atomic64_read(v);
>         do {
>                 if (unlikely(c == u))
>                         return false;
> @@ -217,7 +217,7 @@ static inline bool
> arch_atomic64_add_unless(atomic64_t *v, long a, long u)
>   */
>  static inline long arch_atomic64_dec_if_positive(atomic64_t *v)
>  {
> -       long dec, c = arch_atomic64_read(v);
> +       s64 dec, c = arch_atomic64_read(v);
>         do {
>                 dec = c - 1;
>                 if (unlikely(dec < 0))
> @@ -236,7 +236,7 @@ static inline void arch_atomic64_and(long i, atomic64_t *v)
>
>  static inline long arch_atomic64_fetch_and(long i, atomic64_t *v)
>  {
> -       long val = arch_atomic64_read(v);
> +       s64 val = arch_atomic64_read(v);
>
>         do {
>         } while (!arch_atomic64_try_cmpxchg(v, &val, val & i));
> @@ -253,7 +253,7 @@ static inline void arch_atomic64_or(long i, atomic64_t *v)
>
>  static inline long arch_atomic64_fetch_or(long i, atomic64_t *v)
>  {
> -       long val = arch_atomic64_read(v);
> +       s64 val = arch_atomic64_read(v);
>
>         do {
>         } while (!arch_atomic64_try_cmpxchg(v, &val, val | i));
> @@ -270,7 +270,7 @@ static inline void arch_atomic64_xor(long i, atomic64_t *v)
>
>  static inline long arch_atomic64_fetch_xor(long i, atomic64_t *v)
>  {
> -       long val = arch_atomic64_read(v);
> +       s64 val = arch_atomic64_read(v);
>
>         do {
>         } while (!arch_atomic64_try_cmpxchg(v, &val, val ^ i));
> diff --git a/arch/x86/include/asm/cmpxchg.h b/arch/x86/include/asm/cmpxchg.h
> index e8cf95908fe5..9e2faa85eb02 100644
> --- a/arch/x86/include/asm/cmpxchg.h
> +++ b/arch/x86/include/asm/cmpxchg.h
> @@ -157,7 +157,7 @@ extern void __add_wrong_size(void)
>  #define __raw_try_cmpxchg(_ptr, _pold, _new, size, lock)               \
>  ({                                                                     \
>         bool success;                                                   \
> -       __typeof__(_ptr) _old = (_pold);                                \
> +       __typeof__(_ptr) _old = (__typeof__(_ptr))(_pold);              \
>         __typeof__(*(_ptr)) __old = *_old;                              \
>         __typeof__(*(_ptr)) __new = (_new);                             \
>         switch (size) {                                                 \

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
