Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 996318D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 09:44:54 -0400 (EDT)
Date: Mon, 28 Mar 2011 08:44:48 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: Disable the lockless allocator
In-Reply-To: <20110328063656.GA29462@elte.hu>
Message-ID: <alpine.DEB.2.00.1103280844320.7590@router.home>
References: <1301161507.2979.105.camel@edumazet-laptop> <alpine.DEB.2.00.1103261406420.24195@router.home> <alpine.DEB.2.00.1103261428200.25375@router.home> <alpine.DEB.2.00.1103261440160.25375@router.home> <AANLkTinTzKQkRcE2JvP_BpR0YMj82gppAmNo7RqgftCG@mail.gmail.com>
 <alpine.DEB.2.00.1103262028170.1004@router.home> <alpine.DEB.2.00.1103262054410.1373@router.home> <4D9026C8.6060905@cs.helsinki.fi> <20110328061929.GA24328@elte.hu> <AANLkTinpCa6GBjP3+fdantvOdbktqW8m_D0fGkAnCXYk@mail.gmail.com>
 <20110328063656.GA29462@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Pekka Enberg <penberg@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Linus Torvalds <torvalds@linux-foundation.org>, Eric Dumazet <eric.dumazet@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 28 Mar 2011, Ingo Molnar wrote:

> I think we might still be missing the hunk below - or is it now not needed
> anymore?

Its not needed anymore.

>
> Thanks,
>
> 	Ingo
>
> -------------->
> >From 53c0eceb7bf64f2a89c59ae4f14a676fa4128462 Mon Sep 17 00:00:00 2001
> From: Christoph Lameter <cl@linux.com>
> Date: Sat, 26 Mar 2011 14:49:56 -0500
> Subject: [PATCH] per_cpu: Fix cmpxchg_double() for !SMP
>
> cmpxchg_double() should only be provided for SMP. In the UP case
> the GS register is not defined and the function will fail.
>
> Signed-off-by: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: torvalds@linux-foundation.org
> Cc: tj@kernel.org
> Cc: npiggin@kernel.dk
> Cc: rientjes@google.com
> Cc: linux-mm@kvack.org
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> LKML-Reference: <alpine.DEB.2.00.1103261440160.25375@router.home>
> Signed-off-by: Ingo Molnar <mingo@elte.hu>
> ---
>  arch/x86/include/asm/percpu.h |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
>
> diff --git a/arch/x86/include/asm/percpu.h b/arch/x86/include/asm/percpu.h
> index a09e1f0..52330a4 100644
> --- a/arch/x86/include/asm/percpu.h
> +++ b/arch/x86/include/asm/percpu.h
> @@ -507,6 +507,7 @@ do {									\
>   * it in software.  The address used in the cmpxchg16 instruction must be
>   * aligned to a 16 byte boundary.
>   */
> +#ifdef CONFIG_SMP
>  #define percpu_cmpxchg16b_double(pcp1, o1, o2, n1, n2)			\
>  ({									\
>  	char __ret;							\
> @@ -529,6 +530,7 @@ do {									\
>  #define irqsafe_cpu_cmpxchg_double_8(pcp1, pcp2, o1, o2, n1, n2)	percpu_cmpxchg16b_double(pcp1, o1, o2, n1, n2)
>
>  #endif
> +#endif
>
>  /* This is not atomic against other CPUs -- CPU preemption needs to be off */
>  #define x86_test_and_clear_bit_percpu(bit, var)				\
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
