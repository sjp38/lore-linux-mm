Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1BB3D6B03AA
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 06:55:02 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c75so99824218pfk.3
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 03:55:02 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 1si7757959pgt.572.2017.06.19.03.55.00
        for <linux-mm@kvack.org>;
        Mon, 19 Jun 2017 03:55:01 -0700 (PDT)
Date: Mon, 19 Jun 2017 11:54:11 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH v4 7/7] asm-generic, x86: add comments for atomic
 instrumentation
Message-ID: <20170619105410.GG10246@leverpostej>
References: <cover.1497690003.git.dvyukov@google.com>
 <fa8b171bcbddc84d7ec69fe26cd272841c0171b9.1497690003.git.dvyukov@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fa8b171bcbddc84d7ec69fe26cd272841c0171b9.1497690003.git.dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: peterz@infradead.org, mingo@redhat.com, will.deacon@arm.com, hpa@zytor.com, aryabinin@virtuozzo.com, kasan-dev@googlegroups.com, x86@kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Sat, Jun 17, 2017 at 11:15:33AM +0200, Dmitry Vyukov wrote:
> The comments are factored out from the code changes to make them
> easier to read. Add them separately to explain some non-obvious
> aspects.
> 
> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: kasan-dev@googlegroups.com
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> Cc: x86@kernel.org
> 

The comments look sane to me.

When arm64 support comes round, it would be nice to instrument
cmpxchg_double(), since I think we're not affected by the compiler
issue. We can solve that as and when.

FWIW:

Acked-by: Mark Rutland <mark.rutland@arm.com>

Mark.

> ---
> 
> Changes since v3:
>  - rephrase comment in arch_atomic_read()
> ---
>  arch/x86/include/asm/atomic.h             |  4 ++++
>  include/asm-generic/atomic-instrumented.h | 30 ++++++++++++++++++++++++++++++
>  2 files changed, 34 insertions(+)
> 
> diff --git a/arch/x86/include/asm/atomic.h b/arch/x86/include/asm/atomic.h
> index 304f4f676cce..219c49b4d3aa 100644
> --- a/arch/x86/include/asm/atomic.h
> +++ b/arch/x86/include/asm/atomic.h
> @@ -23,6 +23,10 @@
>   */
>  static __always_inline int arch_atomic_read(const atomic_t *v)
>  {
> +	/*
> +	 * Note for KASAN: we deliberately don't use READ_ONCE_NOCHECK() here,
> +	 * it's non-inlined function that increases binary size and stack usage.
> +	 */
>  	return READ_ONCE((v)->counter);
>  }
>  
> diff --git a/include/asm-generic/atomic-instrumented.h b/include/asm-generic/atomic-instrumented.h
> index a0f5b7525bb2..5771439e7a31 100644
> --- a/include/asm-generic/atomic-instrumented.h
> +++ b/include/asm-generic/atomic-instrumented.h
> @@ -1,3 +1,15 @@
> +/*
> + * This file provides wrappers with KASAN instrumentation for atomic operations.
> + * To use this functionality an arch's atomic.h file needs to define all
> + * atomic operations with arch_ prefix (e.g. arch_atomic_read()) and include
> + * this file at the end. This file provides atomic_read() that forwards to
> + * arch_atomic_read() for actual atomic operation.
> + * Note: if an arch atomic operation is implemented by means of other atomic
> + * operations (e.g. atomic_read()/atomic_cmpxchg() loop), then it needs to use
> + * arch_ variants (i.e. arch_atomic_read()/arch_atomic_cmpxchg()) to avoid
> + * double instrumentation.
> + */
> +
>  #ifndef _LINUX_ATOMIC_INSTRUMENTED_H
>  #define _LINUX_ATOMIC_INSTRUMENTED_H
>  
> @@ -336,6 +348,15 @@ static __always_inline bool atomic64_add_negative(s64 i, atomic64_t *v)
>  	return arch_atomic64_add_negative(i, v);
>  }
>  
> +/*
> + * In the following macros we need to be careful to not clash with arch_ macros.
> + * arch_xchg() can be defined as an extended statement expression as well,
> + * if we define a __ptr variable, and arch_xchg() also defines __ptr variable,
> + * and we pass __ptr as an argument to arch_xchg(), it will use own __ptr
> + * instead of ours. This leads to unpleasant crashes. To avoid the problem
> + * the following macros declare variables with lots of underscores.
> + */
> +
>  #define cmpxchg(ptr, old, new)				\
>  ({							\
>  	__typeof__(ptr) ___ptr = (ptr);			\
> @@ -371,6 +392,15 @@ static __always_inline bool atomic64_add_negative(s64 i, atomic64_t *v)
>  	arch_cmpxchg64_local(____ptr, (old), (new));	\
>  })
>  
> +/*
> + * Originally we had the following code here:
> + *     __typeof__(p1) ____p1 = (p1);
> + *     kasan_check_write(____p1, 2 * sizeof(*____p1));
> + *     arch_cmpxchg_double(____p1, (p2), (o1), (o2), (n1), (n2));
> + * But it leads to compilation failures (see gcc issue 72873).
> + * So for now it's left non-instrumented.
> + * There are few callers of cmpxchg_double(), so it's not critical.
> + */
>  #define cmpxchg_double(p1, p2, o1, o2, n1, n2)				\
>  ({									\
>  	arch_cmpxchg_double((p1), (p2), (o1), (o2), (n1), (n2));	\
> -- 
> 2.13.1.518.g3df882009-goog
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
