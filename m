Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 580B66B0343
	for <linux-mm@kvack.org>; Wed, 22 Mar 2017 08:51:56 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id l49so200724208otc.5
        for <linux-mm@kvack.org>; Wed, 22 Mar 2017 05:51:56 -0700 (PDT)
Received: from mail-ot0-x243.google.com (mail-ot0-x243.google.com. [2607:f8b0:4003:c0f::243])
        by mx.google.com with ESMTPS id h65si642968oia.230.2017.03.22.05.51.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Mar 2017 05:51:55 -0700 (PDT)
Received: by mail-ot0-x243.google.com with SMTP id i50so16005029otd.0
        for <linux-mm@kvack.org>; Wed, 22 Mar 2017 05:51:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170322122449.54505-1-dvyukov@google.com>
References: <20170322122449.54505-1-dvyukov@google.com>
From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 22 Mar 2017 13:51:54 +0100
Message-ID: <CAK8P3a2eJHjG6qwJZH8M2iziFtjhiWsHU45fjuXtoNBGwSdgjQ@mail.gmail.com>
Subject: Re: [PATCH] x86: s/READ_ONCE_NOCHECK/READ_ONCE/ in arch_atomic_read()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Mark Rutland <mark.rutland@arm.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, Linux-MM <linux-mm@kvack.org>, x86@kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>

On Wed, Mar 22, 2017 at 1:24 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> Two problems was reported with READ_ONCE_NOCHECK in arch_atomic_read:
> 1. Andrey Ryabinin reported significant binary size increase
> (+400K of text). READ_ONCE_NOCHECK is intentionally compiled to
> non-inlined function call, and I counted 640 copies of it in my vmlinux.
> 2. Arnd Bergmann reported a new splat of too large frame sizes.
>
> A single inlined KASAN check is very cheap, a non-inlined function
> call with KASAN/KCOV instrumentation can easily be more expensive.
>
> Switch to READ_ONCE() in arch_atomic_read().
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
> ---
>  arch/x86/include/asm/atomic.h | 15 ++++++---------
>  1 file changed, 6 insertions(+), 9 deletions(-)
>
> diff --git a/arch/x86/include/asm/atomic.h b/arch/x86/include/asm/atomic.h
> index 0cde164f058a..46e53bbf7ce3 100644
> --- a/arch/x86/include/asm/atomic.h
> +++ b/arch/x86/include/asm/atomic.h
> @@ -24,10 +24,13 @@
>  static __always_inline int arch_atomic_read(const atomic_t *v)
>  {
>         /*
> -        * We use READ_ONCE_NOCHECK() because atomic_read() contains KASAN
> -        * instrumentation. Double instrumentation is unnecessary.
> +        * Note: READ_ONCE() here leads to double instrumentation as
> +        * both READ_ONCE() and atomic_read() contain instrumentation.
> +        * This is deliberate choice. READ_ONCE_NOCHECK() is compiled to a
> +        * non-inlined function call that considerably increases binary size
> +        * and stack usage under KASAN.
>          */
> -       return READ_ONCE_NOCHECK((v)->counter);
> +       return READ_ONCE((v)->counter);
>  }

The change looks good, but the same one is needed in atomic64.h

     Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
