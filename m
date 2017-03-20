Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 09BB16B0388
	for <linux-mm@kvack.org>; Mon, 20 Mar 2017 13:17:37 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c23so268692810pfj.0
        for <linux-mm@kvack.org>; Mon, 20 Mar 2017 10:17:37 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k6si18224745pla.215.2017.03.20.10.17.35
        for <linux-mm@kvack.org>;
        Mon, 20 Mar 2017 10:17:36 -0700 (PDT)
Date: Mon, 20 Mar 2017 17:17:18 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH 2/3] asm-generic, x86: wrap atomic operations
Message-ID: <20170320171718.GL31213@leverpostej>
References: <cover.1489519233.git.dvyukov@google.com>
 <6bb1c71b87b300d04977c34f0cd8586363bc6170.1489519233.git.dvyukov@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6bb1c71b87b300d04977c34f0cd8586363bc6170.1489519233.git.dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: peterz@infradead.org, aryabinin@virtuozzo.com, mingo@redhat.com, will.deacon@arm.com, akpm@linux-foundation.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

Hi,

On Tue, Mar 14, 2017 at 08:24:13PM +0100, Dmitry Vyukov wrote:
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

Just to check, we do this to avoid duplicate reports, right?

If so, double instrumentation isn't solely "unnecessary"; it has a
functional difference, and we should explicitly describe that in the
comment.

... or are duplicate reports supressed somehow?

[...]

> +static __always_inline void arch_atomic_set(atomic_t *v, int i)
>  {
> +	/*
> +	 * We could use WRITE_ONCE_NOCHECK() if it exists, similar to
> +	 * READ_ONCE_NOCHECK() in arch_atomic_read(). But there is no such
> +	 * thing at the moment, and introducing it for this case does not
> +	 * worth it.
> +	 */
>  	WRITE_ONCE(v->counter, i);
>  }

If we are trying to avoid duplicate reports, we should do the same here.

[...]

> +static __always_inline short int atomic_inc_short(short int *v)
> +{
> +	return arch_atomic_inc_short(v);
> +}

This is x86-specific, and AFAICT, not used anywhere.

Given that it is arch-specific, I don't think it should be instrumented
here. If it isn't used, we could get rid of it entirely...

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
