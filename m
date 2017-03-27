Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id DB6DE6B0333
	for <linux-mm@kvack.org>; Mon, 27 Mar 2017 02:25:58 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id i18so10083888wrb.21
        for <linux-mm@kvack.org>; Sun, 26 Mar 2017 23:25:58 -0700 (PDT)
Received: from mail-wr0-x241.google.com (mail-wr0-x241.google.com. [2a00:1450:400c:c0c::241])
        by mx.google.com with ESMTPS id b74si12965250wmi.80.2017.03.26.23.25.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Mar 2017 23:25:57 -0700 (PDT)
Received: by mail-wr0-x241.google.com with SMTP id 20so9829828wrx.0
        for <linux-mm@kvack.org>; Sun, 26 Mar 2017 23:25:57 -0700 (PDT)
Date: Mon, 27 Mar 2017 08:25:54 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v2] x86: s/READ_ONCE_NOCHECK/READ_ONCE/ in
 arch_atomic[64]_read()
Message-ID: <20170327062554.GA10918@gmail.com>
References: <20170322125740.85337-1-dvyukov@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170322125740.85337-1-dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: akpm@linux-foundation.org, arnd@arndb.de, aryabinin@virtuozzo.com, Mark Rutland <mark.rutland@arm.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com


* Dmitry Vyukov <dvyukov@google.com> wrote:

> Two problems was reported with READ_ONCE_NOCHECK in arch_atomic_read:
> 1. Andrey Ryabinin reported significant binary size increase
> (+400K of text). READ_ONCE_NOCHECK is intentionally compiled to
> non-inlined function call, and I counted 640 copies of it in my vmlinux.
> 2. Arnd Bergmann reported a new splat of too large frame sizes.
> 
> A single inlined KASAN check is very cheap, a non-inlined function
> call with KASAN/KCOV instrumentation can easily be more expensive.
> 
> Switch to READ_ONCE() in arch_atomic[64]_read().
> 
> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
> Reported-by: Arnd Bergmann <arnd@arndb.de>
> Reported-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: linux-mm@kvack.org
> Cc: x86@kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: kasan-dev@googlegroups.com
> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
> 
> ---
> 
> Changes since v1:
>  - also change arch_atomic64_read()
> ---
>  arch/x86/include/asm/atomic.h      | 15 ++++++---------
>  arch/x86/include/asm/atomic64_64.h |  2 +-
>  2 files changed, 7 insertions(+), 10 deletions(-)
> 
> diff --git a/arch/x86/include/asm/atomic.h b/arch/x86/include/asm/atomic.h
> index 0cde164f058a..46e53bbf7ce3 100644
> --- a/arch/x86/include/asm/atomic.h
> +++ b/arch/x86/include/asm/atomic.h
> @@ -24,10 +24,13 @@
>  static __always_inline int arch_atomic_read(const atomic_t *v)
>  {
>  	/*
> -	 * We use READ_ONCE_NOCHECK() because atomic_read() contains KASAN
> -	 * instrumentation. Double instrumentation is unnecessary.
> +	 * Note: READ_ONCE() here leads to double instrumentation as
> +	 * both READ_ONCE() and atomic_read() contain instrumentation.
> +	 * This is deliberate choice. READ_ONCE_NOCHECK() is compiled to a
> +	 * non-inlined function call that considerably increases binary size
> +	 * and stack usage under KASAN.

s/this is deliberate choice
 /this is a deliberate choice

Also, the patch does not apply to the latest locking tree cleanly, due to 
interacting changes.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
