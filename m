Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 983C66B0011
	for <linux-mm@kvack.org>; Tue, 31 May 2011 19:23:30 -0400 (EDT)
Message-ID: <4DE576EA.6070906@zytor.com>
Date: Tue, 31 May 2011 16:16:58 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [slubllv5 07/25] x86: Add support for cmpxchg_double
References: <20110516202605.274023469@linux.com>  <20110516202625.197639928@linux.com> <4DDE9670.3060709@zytor.com>  <alpine.DEB.2.00.1105261315350.26578@router.home>  <4DDE9C01.2090104@zytor.com>  <alpine.DEB.2.00.1105261615130.591@router.home> <1306445159.2543.25.camel@edumazet-laptop> <alpine.DEB.2.00.1105311012420.18755@router.home> <4DE50632.90906@zytor.com> <alpine.DEB.2.00.1105311058030.19928@router.home>
In-Reply-To: <alpine.DEB.2.00.1105311058030.19928@router.home>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

On 05/31/2011 09:53 AM, Christoph Lameter wrote:
> Index: linux-2.6/arch/x86/Kconfig.cpu
> ===================================================================
> --- linux-2.6.orig/arch/x86/Kconfig.cpu	2011-05-31 11:28:24.202948792 -0500
> +++ linux-2.6/arch/x86/Kconfig.cpu	2011-05-31 11:29:36.742948327 -0500
> @@ -312,6 +312,16 @@ config X86_CMPXCHG
>  config CMPXCHG_LOCAL
>  	def_bool X86_64 || (X86_32 && !M386)
> 
> +#
> +# CMPXCHG_DOUBLE needs to be set to enable the kernel to use cmpxchg16/8b
> +# for cmpxchg_double if it find processor flags that indicate that the
> +# capabilities are available. CMPXCHG_DOUBLE only compiles in
> +# detection support. It needs to be set if there is a chance that processor
> +# supports these instructions.
> +#
> +config CMPXCHG_DOUBLE
> +	def_bool GENERIC_CPU || X86_GENERIC || !M386
> +
>  config X86_L1_CACHE_SHIFT
>  	int
>  	default "7" if MPENTIUM4 || MPSC

Per previous discussion:

- Drop this Kconfig option (it is irrelevant.)  CONFIG_CMPXCHG_LOCAL is
different: it indicates that CMPXCHG is *guaranteed* to exist.

> +	asm volatile(LOCK_PREFIX_HERE "cmpxchg8b (%%esi); setz %1"\
> +		       : "d="(__dummy), "=a" (__ret) 		\
> +		       : "S" ((ptr)), "a" (__old1), "d"(__old2),	\
> +		         "b" (__new1), "c" (__new2)		\
> +		       : "memory");				\
> +	__ret; })

> +	asm volatile("cmpxchg8b (%%esi); tsetz %1"		\
> +		       : "d="(__dummy), "=a"(__ret)		\
> +		       : "S" ((ptr)), "a" (__old), "d"(__old2),	\
> +		         "b" (__new1), "c" (__new2),		\
> +		       : "memory");				\
> +	__ret; })

d= is broken (won't even compile), and there is a typo in the opcode
(setz, not tsetz).

Use LOCK_PREFIX and +m here too.

	-hpa





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
