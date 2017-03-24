Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8570C6B0333
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 02:52:08 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id d66so5497834wmi.2
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 23:52:08 -0700 (PDT)
Received: from mail-wr0-x244.google.com (mail-wr0-x244.google.com. [2a00:1450:400c:c0c::244])
        by mx.google.com with ESMTPS id 59si1778412wre.100.2017.03.23.23.52.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Mar 2017 23:52:07 -0700 (PDT)
Received: by mail-wr0-x244.google.com with SMTP id u108so686968wrb.2
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 23:52:06 -0700 (PDT)
Date: Fri, 24 Mar 2017 07:52:03 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 2/3] asm-generic, x86: wrap atomic operations
Message-ID: <20170324065203.GA5229@gmail.com>
References: <cover.1489519233.git.dvyukov@google.com>
 <6bb1c71b87b300d04977c34f0cd8586363bc6170.1489519233.git.dvyukov@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6bb1c71b87b300d04977c34f0cd8586363bc6170.1489519233.git.dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: mark.rutland@arm.com, peterz@infradead.org, aryabinin@virtuozzo.com, mingo@redhat.com, will.deacon@arm.com, akpm@linux-foundation.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>


* Dmitry Vyukov <dvyukov@google.com> wrote:

> KASAN uses compiler instrumentation to intercept all memory accesses.
> But it does not see memory accesses done in assembly code.
> One notable user of assembly code is atomic operations. Frequently,
> for example, an atomic reference decrement is the last access to an
> object and a good candidate for a racy use-after-free.
> 
> Atomic operations are defined in arch files, but KASAN instrumentation
> is required for several archs that support KASAN. Later we will need
> similar hooks for KMSAN (uninit use detector) and KTSAN (data race
> detector).
> 
> This change introduces wrappers around atomic operations that can be
> used to add KASAN/KMSAN/KTSAN instrumentation across several archs.
> This patch uses the wrappers only for x86 arch. Arm64 will be switched
> later.
> 
> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Will Deacon <will.deacon@arm.com>,
> Cc: Andrew Morton <akpm@linux-foundation.org>,
> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
> Cc: Ingo Molnar <mingo@redhat.com>,
> Cc: kasan-dev@googlegroups.com
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> Cc: x86@kernel.org
> ---
>  arch/x86/include/asm/atomic.h             | 100 +++++++-------
>  arch/x86/include/asm/atomic64_32.h        |  86 ++++++------
>  arch/x86/include/asm/atomic64_64.h        |  90 ++++++-------
>  arch/x86/include/asm/cmpxchg.h            |  12 +-
>  arch/x86/include/asm/cmpxchg_32.h         |   8 +-
>  arch/x86/include/asm/cmpxchg_64.h         |   4 +-
>  include/asm-generic/atomic-instrumented.h | 210 ++++++++++++++++++++++++++++++
>  7 files changed, 367 insertions(+), 143 deletions(-)

Ugh, that's disgusting really...

> 
> diff --git a/arch/x86/include/asm/atomic.h b/arch/x86/include/asm/atomic.h
> index 14635c5ea025..95dd167eb3af 100644
> --- a/arch/x86/include/asm/atomic.h
> +++ b/arch/x86/include/asm/atomic.h
> @@ -16,36 +16,46 @@
>  #define ATOMIC_INIT(i)	{ (i) }
>  
>  /**
> - * atomic_read - read atomic variable
> + * arch_atomic_read - read atomic variable
>   * @v: pointer of type atomic_t
>   *
>   * Atomically reads the value of @v.
>   */
> -static __always_inline int atomic_read(const atomic_t *v)
> +static __always_inline int arch_atomic_read(const atomic_t *v)
>  {
> -	return READ_ONCE((v)->counter);
> +	/*
> +	 * We use READ_ONCE_NOCHECK() because atomic_read() contains KASAN
> +	 * instrumentation. Double instrumentation is unnecessary.
> +	 */
> +	return READ_ONCE_NOCHECK((v)->counter);
>  }

Firstly, the patch is way too large, please split off new the documentation parts 
of the patch to reduce the size and to make it easier to read!

Secondly, the next patch should do the rename to arch_atomic_*() pattern - and 
nothing else:

>  
>  /**
> - * atomic_set - set atomic variable
> + * arch_atomic_set - set atomic variable
>   * @v: pointer of type atomic_t
>   * @i: required value
>   *
>   * Atomically sets the value of @v to @i.
>   */
> -static __always_inline void atomic_set(atomic_t *v, int i)
> +static __always_inline void arch_atomic_set(atomic_t *v, int i)


Third, the prototype CPP complications:

> +#define __INSTR_VOID1(op, sz)						\
> +static __always_inline void atomic##sz##_##op(atomic##sz##_t *v)	\
> +{									\
> +	arch_atomic##sz##_##op(v);					\
> +}
> +
> +#define INSTR_VOID1(op)	\
> +__INSTR_VOID1(op,);	\
> +__INSTR_VOID1(op, 64)
> +
> +INSTR_VOID1(inc);
> +INSTR_VOID1(dec);
> +
> +#undef __INSTR_VOID1
> +#undef INSTR_VOID1
> +
> +#define __INSTR_VOID2(op, sz, type)					\
> +static __always_inline void atomic##sz##_##op(type i, atomic##sz##_t *v)\
> +{									\
> +	arch_atomic##sz##_##op(i, v);					\
> +}
> +
> +#define INSTR_VOID2(op)		\
> +__INSTR_VOID2(op, , int);	\
> +__INSTR_VOID2(op, 64, long long)
> +
> +INSTR_VOID2(add);
> +INSTR_VOID2(sub);
> +INSTR_VOID2(and);
> +INSTR_VOID2(or);
> +INSTR_VOID2(xor);
> +
> +#undef __INSTR_VOID2
> +#undef INSTR_VOID2
> +
> +#define __INSTR_RET1(op, sz, type, rtype)				\
> +static __always_inline rtype atomic##sz##_##op(atomic##sz##_t *v)	\
> +{									\
> +	return arch_atomic##sz##_##op(v);				\
> +}
> +
> +#define INSTR_RET1(op)		\
> +__INSTR_RET1(op, , int, int);	\
> +__INSTR_RET1(op, 64, long long, long long)
> +
> +INSTR_RET1(inc_return);
> +INSTR_RET1(dec_return);
> +__INSTR_RET1(inc_not_zero, 64, long long, long long);
> +__INSTR_RET1(dec_if_positive, 64, long long, long long);
> +
> +#define INSTR_RET_BOOL1(op)	\
> +__INSTR_RET1(op, , int, bool);	\
> +__INSTR_RET1(op, 64, long long, bool)
> +
> +INSTR_RET_BOOL1(dec_and_test);
> +INSTR_RET_BOOL1(inc_and_test);
> +
> +#undef __INSTR_RET1
> +#undef INSTR_RET1
> +#undef INSTR_RET_BOOL1
> +
> +#define __INSTR_RET2(op, sz, type, rtype)				\
> +static __always_inline rtype atomic##sz##_##op(type i, atomic##sz##_t *v) \
> +{									\
> +	return arch_atomic##sz##_##op(i, v);				\
> +}
> +
> +#define INSTR_RET2(op)		\
> +__INSTR_RET2(op, , int, int);	\
> +__INSTR_RET2(op, 64, long long, long long)
> +
> +INSTR_RET2(add_return);
> +INSTR_RET2(sub_return);
> +INSTR_RET2(fetch_add);
> +INSTR_RET2(fetch_sub);
> +INSTR_RET2(fetch_and);
> +INSTR_RET2(fetch_or);
> +INSTR_RET2(fetch_xor);
> +
> +#define INSTR_RET_BOOL2(op)		\
> +__INSTR_RET2(op, , int, bool);		\
> +__INSTR_RET2(op, 64, long long, bool)
> +
> +INSTR_RET_BOOL2(sub_and_test);
> +INSTR_RET_BOOL2(add_negative);
> +
> +#undef __INSTR_RET2
> +#undef INSTR_RET2
> +#undef INSTR_RET_BOOL2

Are just utterly disgusting that turn perfectly readable code into an unreadable, 
unmaintainable mess.

You need to find some better, cleaner solution please, or convince me that no such 
solution is possible. NAK for the time being.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
