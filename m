Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E3A896B0292
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 08:13:23 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l34so33274883wrc.12
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 05:13:23 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id d9si1705707wrc.290.2017.06.28.05.13.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 28 Jun 2017 05:13:22 -0700 (PDT)
Date: Wed, 28 Jun 2017 14:12:52 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH] locking/atomics: don't alias ____ptr
Message-ID: <20170628121246.qnk2csgzbgpqrmw3@linutronix.de>
References: <cover.1498140838.git.dvyukov@google.com>
 <85d51d3551b676ba1fc40e8fbddd2eadd056d8dd.1498140838.git.dvyukov@google.com>
 <20170628100246.7nsvhblgi3xjbc4m@breakpoint.cc>
 <CACT4Y+Yhy-jucOC37um5xZewEj0sdw8Hjte7oOYxDdxkzOTYoA@mail.gmail.com>
 <1c1cbbfb-8e34-dd33-0e73-bbb2a758e962@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1c1cbbfb-8e34-dd33-0e73-bbb2a758e962@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@kernel.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Mark Rutland <mark.rutland@arm.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, "H. Peter Anvin" <hpa@zytor.com>, kasan-dev <kasan-dev@googlegroups.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>

On 2017-06-28 14:15:18 [+0300], Andrey Ryabinin wrote:
> The main problem here is that arch_cmpxchg64_local() calls cmpxhg_local() instead of using arch_cmpxchg_local().
> 
> So, the patch bellow should fix the problem, also this will fix double instrumentation of cmpcxchg64[_local]().
> But I haven't tested this patch yet.

tested, works. Next step?

> ---
>  arch/x86/include/asm/cmpxchg_64.h | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/x86/include/asm/cmpxchg_64.h b/arch/x86/include/asm/cmpxchg_64.h
> index fafaebacca2d..7046a3cc2493 100644
> --- a/arch/x86/include/asm/cmpxchg_64.h
> +++ b/arch/x86/include/asm/cmpxchg_64.h
> @@ -9,13 +9,13 @@ static inline void set_64bit(volatile u64 *ptr, u64 val)
>  #define arch_cmpxchg64(ptr, o, n)					\
>  ({									\
>  	BUILD_BUG_ON(sizeof(*(ptr)) != 8);				\
> -	cmpxchg((ptr), (o), (n));					\
> +	arch_cmpxchg((ptr), (o), (n));					\
>  })
>  
>  #define arch_cmpxchg64_local(ptr, o, n)					\
>  ({									\
>  	BUILD_BUG_ON(sizeof(*(ptr)) != 8);				\
> -	cmpxchg_local((ptr), (o), (n));					\
> +	arch_cmpxchg_local((ptr), (o), (n));					\
>  })
>  
>  #define system_has_cmpxchg_double() boot_cpu_has(X86_FEATURE_CX16)

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
