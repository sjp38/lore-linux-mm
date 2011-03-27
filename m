Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B24E38D003B
	for <linux-mm@kvack.org>; Sun, 27 Mar 2011 03:52:37 -0400 (EDT)
Received: by wwi18 with SMTP id 18so822981wwi.2
        for <linux-mm@kvack.org>; Sun, 27 Mar 2011 00:52:33 -0700 (PDT)
Subject: Re: [PATCH] slub: Disable the lockless allocator
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <alpine.DEB.2.00.1103262054410.1373@router.home>
References: <alpine.DEB.2.00.1103221635400.4521@tiger>
	 <20110324142146.GA11682@elte.hu>
	 <alpine.DEB.2.00.1103240940570.32226@router.home>
	 <AANLkTikb8rtSX5hQG6MQF4quymFUuh5Tw97TcpB0YfwS@mail.gmail.com>
	 <20110324172653.GA28507@elte.hu> <20110324185258.GA28370@elte.hu>
	 <alpine.LFD.2.00.1103242005530.31464@localhost6.localdomain6>
	 <20110324192247.GA5477@elte.hu>
	 <AANLkTinBwM9egao496WnaNLAPUxhMyJmkusmxt+ARtnV@mail.gmail.com>
	 <20110326112725.GA28612@elte.hu> <20110326114736.GA8251@elte.hu>
	 <1301161507.2979.105.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1103261406420.24195@router.home>
	 <alpine.DEB.2.00.1103261428200.25375@router.home>
	 <alpine.DEB.2.00.1103261440160.25375@router.home>
	 <AANLkTinTzKQkRcE2JvP_BpR0YMj82gppAmNo7RqgftCG@mail.gmail.com>
	 <alpine.DEB.2.00.1103262028170.1004@router.home>
	 <alpine.DEB.2.00.1103262054410.1373@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 27 Mar 2011 09:52:27 +0200
Message-ID: <1301212347.32248.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Le samedi 26 mars 2011 A  20:57 -0500, Christoph Lameter a A(C)crit :
> But then the same fix must also be used in the asm code or the fallback
> (turns out that the fallback is always used in kmem_cache_init since
> the instruction patching comes later).
> 
> Patch boots fine both in UP and SMP mode
> 
> 
> 
> 
> Subject: percpu: Omit segment prefix in the UP case for cmpxchg_double
> 
> Omit the segment prefix in the UP case. GS is not used then
> and we will generate segfaults if cmpxchg16b is used otherwise.
> 
> Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
>  arch/x86/include/asm/percpu.h |   10 ++++++----
>  1 files changed, 6 insertions(+), 4 deletions(-)
> 
> Index: linux-2.6/arch/x86/include/asm/percpu.h
> ===================================================================
> --- linux-2.6.orig/arch/x86/include/asm/percpu.h	2011-03-26 20:43:03.994089001 -0500
> +++ linux-2.6/arch/x86/include/asm/percpu.h	2011-03-26 20:43:22.414089004 -0500
> @@ -45,7 +45,7 @@
>  #include <linux/stringify.h>
> 
>  #ifdef CONFIG_SMP
> -#define __percpu_arg(x)		"%%"__stringify(__percpu_seg)":%P" #x
> +#define __percpu_prefix		"%%"__stringify(__percpu_seg)":"
>  #define __my_cpu_offset		percpu_read(this_cpu_off)
> 
>  /*
> @@ -62,9 +62,11 @@
>  	(typeof(*(ptr)) __kernel __force *)tcp_ptr__;	\
>  })
>  #else
> -#define __percpu_arg(x)		"%P" #x
> +#define __percpu_prefix		""
>  #endif
> 
> +#define __percpu_arg(x)		__percpu_prefix "%P" #x
> +
>  /*
>   * Initialized pointers to per-cpu variables needed for the boot
>   * processor need to use these macros to get the proper address
> @@ -516,11 +518,11 @@
>  	typeof(o2) __n2 = n2;						\
>  	typeof(o2) __dummy;						\
>  	alternative_io("call this_cpu_cmpxchg16b_emu\n\t" P6_NOP4,	\

I guess you should make P6_NOP4 be P6_NOP3 in !SMP builds.

> -		       "cmpxchg16b %%gs:(%%rsi)\n\tsetz %0\n\t",	\
> +		       "cmpxchg16b " __percpu_prefix "(%%rsi)\n\tsetz %0\n\t",	\
>  		       X86_FEATURE_CX16,				\
>  		       ASM_OUTPUT2("=a"(__ret), "=d"(__dummy)),		\
>  		       "S" (&pcp1), "b"(__n1), "c"(__n2),		\
> -		       "a"(__o1), "d"(__o2));				\
> +		       "a"(__o1), "d"(__o2) : "memory");		\
>  	__ret;								\
>  })
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
