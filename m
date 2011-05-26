Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 45EE96B0011
	for <linux-mm@kvack.org>; Thu, 26 May 2011 17:26:06 -0400 (EDT)
Received: by wwi36 with SMTP id 36so1041098wwi.26
        for <linux-mm@kvack.org>; Thu, 26 May 2011 14:26:03 -0700 (PDT)
Subject: Re: [slubllv5 07/25] x86: Add support for cmpxchg_double
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <alpine.DEB.2.00.1105261615130.591@router.home>
References: <20110516202605.274023469@linux.com>
	 <20110516202625.197639928@linux.com> <4DDE9670.3060709@zytor.com>
	 <alpine.DEB.2.00.1105261315350.26578@router.home>
	 <4DDE9C01.2090104@zytor.com>
	 <alpine.DEB.2.00.1105261615130.591@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 26 May 2011 23:25:59 +0200
Message-ID: <1306445159.2543.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

Le jeudi 26 mai 2011 A  16:16 -0500, Christoph Lameter a A(C)crit :
> Here is a new patch that may address the concerns. The list of cpus that
> support CMPXCHG_DOUBLE is not complete.Could someone help me complete it?
> 
> 
> 
> Subject: x86: Add support for cmpxchg_double
> 
> A simple implementation that only supports the word size and does not
> have a fallback mode (would require a spinlock).
> 
> And 32 and 64 bit support for cmpxchg_double. cmpxchg double uses
> the cmpxchg8b or cmpxchg16b instruction on x86 processors to compare
> and swap 2 machine words. This allows lockless algorithms to move more
> context information through critical sections.
> 
> Set a flag CONFIG_CMPXCHG_DOUBLE to signal the support of that feature
> during kernel builds.
> 
> Cc: tj@kernel.org
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> ---
>  arch/x86/Kconfig.cpu              |   10 +++++++
>  arch/x86/include/asm/cmpxchg_32.h |   48 ++++++++++++++++++++++++++++++++++++++
>  arch/x86/include/asm/cmpxchg_64.h |   45 +++++++++++++++++++++++++++++++++++
>  arch/x86/include/asm/cpufeature.h |    1
>  4 files changed, 104 insertions(+)
> 
> Index: linux-2.6/arch/x86/include/asm/cmpxchg_64.h
> ===================================================================
> --- linux-2.6.orig/arch/x86/include/asm/cmpxchg_64.h	2011-05-26 16:03:33.595608967 -0500
> +++ linux-2.6/arch/x86/include/asm/cmpxchg_64.h	2011-05-26 16:06:25.815607865 -0500
> @@ -151,4 +151,49 @@ extern void __cmpxchg_wrong_size(void);
>  	cmpxchg_local((ptr), (o), (n));					\
>  })
> 
> +#define cmpxchg16b(ptr, o1, o2, n1, n2)				\
> +({								\
> +	char __ret;						\
> +	__typeof__(o2) __junk;					\
> +	__typeof__(*(ptr)) __old1 = (o1);			\
> +	__typeof__(o2) __old2 = (o2);				\
> +	__typeof__(*(ptr)) __new1 = (n1);			\
> +	__typeof__(o2) __new2 = (n2);				\
> +	asm volatile(LOCK_PREFIX_HERE "lock; cmpxchg16b (%%rsi);setz %1" \

If there is no emulation, why do you force rsi here ?

It could be something else, like "=m" (*ptr) ?

(same remark for other functions)


> +		       : "=d"(__junk), "=a"(__ret)		\
> +		       : "S"(ptr), "b"(__new1),	"c"(__new2),	\
> +		         "a"(__old1), "d"(__old2));		\
> +	__ret; })
> +
> +


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
