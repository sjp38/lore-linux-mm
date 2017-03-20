Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7B5CC6B0388
	for <linux-mm@kvack.org>; Mon, 20 Mar 2017 12:40:18 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id n11so100679302pfg.7
        for <linux-mm@kvack.org>; Mon, 20 Mar 2017 09:40:18 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0094.outbound.protection.outlook.com. [104.47.0.94])
        by mx.google.com with ESMTPS id m2si18063120pgn.334.2017.03.20.09.40.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 20 Mar 2017 09:40:17 -0700 (PDT)
Subject: Re: [PATCH 2/3] asm-generic, x86: wrap atomic operations
References: <cover.1489519233.git.dvyukov@google.com>
 <6bb1c71b87b300d04977c34f0cd8586363bc6170.1489519233.git.dvyukov@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <4cb2bd62-7345-25ed-2cf4-11e4d2579ca6@virtuozzo.com>
Date: Mon, 20 Mar 2017 19:41:16 +0300
MIME-Version: 1.0
In-Reply-To: <6bb1c71b87b300d04977c34f0cd8586363bc6170.1489519233.git.dvyukov@google.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, mark.rutland@arm.com, peterz@infradead.org, mingo@redhat.com
Cc: will.deacon@arm.com, akpm@linux-foundation.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

On 03/14/2017 10:24 PM, Dmitry Vyukov wrote:

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

This is kinda questionable "optimization". READ_ONCE_NOCHECK() is actually
function call to  __read_once_size_nocheck().
So this _NOCHECK adds some bloat to the kernel.
E.g. on my .config remove of _NOCHECK() saves ~400K of .text:

size vmlinux_read
   text    data     bss     dec     hex filename
40548235        16418838        23289856        80256929        4c89fa1 vmlinux_read
size vmlinux_read_nocheck
   text    data     bss     dec     hex filename
40938418        16451958        23289856        80680232        4cf1528 vmlinux_read_nocheck

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
