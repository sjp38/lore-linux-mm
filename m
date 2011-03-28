Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A84028D003B
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 02:12:28 -0400 (EDT)
Message-ID: <4D9026C8.6060905@cs.helsinki.fi>
Date: Mon, 28 Mar 2011 09:12:24 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH] slub: Disable the lockless allocator
References: <alpine.DEB.2.00.1103221635400.4521@tiger> <20110324142146.GA11682@elte.hu> <alpine.DEB.2.00.1103240940570.32226@router.home> <AANLkTikb8rtSX5hQG6MQF4quymFUuh5Tw97TcpB0YfwS@mail.gmail.com> <20110324172653.GA28507@elte.hu> <20110324185258.GA28370@elte.hu> <alpine.LFD.2.00.1103242005530.31464@localhost6.localdomain6> <20110324192247.GA5477@elte.hu> <AANLkTinBwM9egao496WnaNLAPUxhMyJmkusmxt+ARtnV@mail.gmail.com> <20110326112725.GA28612@elte.hu> <20110326114736.GA8251@elte.hu> <1301161507.2979.105.camel@edumazet-laptop> <alpine.DEB.2.00.1103261406420.24195@router.home> <alpine.DEB.2.00.1103261428200.25375@router.home> <alpine.DEB.2.00.1103261440160.25375@router.home> <AANLkTinTzKQkRcE2JvP_BpR0YMj82gppAmNo7RqgftCG@mail.gmail.com> <alpine.DEB.2.00.1103262028170.1004@router.home> <alpine.DEB.2.00.1103262054410.1373@router.home>
In-Reply-To: <alpine.DEB.2.00.1103262054410.1373@router.home>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Eric Dumazet <eric.dumazet@gmail.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.orgtj@kernel.org

On 3/27/11 4:57 AM, Christoph Lameter wrote:
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
> Signed-off-by: Linus Torvalds<torvalds@linux-foundation.org>
> Signed-off-by: Christoph Lameter<cl@linux.com>
>
>   arch/x86/include/asm/percpu.h |   10 ++++++----
>   1 files changed, 6 insertions(+), 4 deletions(-)
>
> Index: linux-2.6/arch/x86/include/asm/percpu.h
> ===================================================================
> --- linux-2.6.orig/arch/x86/include/asm/percpu.h	2011-03-26 20:43:03.994089001 -0500
> +++ linux-2.6/arch/x86/include/asm/percpu.h	2011-03-26 20:43:22.414089004 -0500
> @@ -45,7 +45,7 @@
>   #include<linux/stringify.h>
>
>   #ifdef CONFIG_SMP
> -#define __percpu_arg(x)		"%%"__stringify(__percpu_seg)":%P" #x
> +#define __percpu_prefix		"%%"__stringify(__percpu_seg)":"
>   #define __my_cpu_offset		percpu_read(this_cpu_off)
>
>   /*
> @@ -62,9 +62,11 @@
>   	(typeof(*(ptr)) __kernel __force *)tcp_ptr__;	\
>   })
>   #else
> -#define __percpu_arg(x)		"%P" #x
> +#define __percpu_prefix		""
>   #endif
>
> +#define __percpu_arg(x)		__percpu_prefix "%P" #x
> +
>   /*
>    * Initialized pointers to per-cpu variables needed for the boot
>    * processor need to use these macros to get the proper address
> @@ -516,11 +518,11 @@
>   	typeof(o2) __n2 = n2;						\
>   	typeof(o2) __dummy;						\
>   	alternative_io("call this_cpu_cmpxchg16b_emu\n\t" P6_NOP4,	\
> -		       "cmpxchg16b %%gs:(%%rsi)\n\tsetz %0\n\t",	\
> +		       "cmpxchg16b " __percpu_prefix "(%%rsi)\n\tsetz %0\n\t",	\
>   		       X86_FEATURE_CX16,				\
>   		       ASM_OUTPUT2("=a"(__ret), "=d"(__dummy)),		\
>   		       "S" (&pcp1), "b"(__n1), "c"(__n2),		\
> -		       "a"(__o1), "d"(__o2));				\
> +		       "a"(__o1), "d"(__o2) : "memory");		\
>   	__ret;								\
>   })
>
> Index: linux-2.6/arch/x86/lib/cmpxchg16b_emu.S
> ===================================================================
> --- linux-2.6.orig/arch/x86/lib/cmpxchg16b_emu.S	2011-03-26 20:43:57.384089004 -0500
> +++ linux-2.6/arch/x86/lib/cmpxchg16b_emu.S	2011-03-26 20:48:42.684088999 -0500
> @@ -10,6 +10,12 @@
>   #include<asm/frame.h>
>   #include<asm/dwarf2.h>
>
> +#ifdef CONFIG_SMP
> +#define SEG_PREFIX %gs:
> +#else
> +#define SEG_PREFIX
> +#endif
> +
>   .text
>
>   /*
> @@ -37,13 +43,13 @@
>   	pushf
>   	cli
>
> -	cmpq %gs:(%rsi), %rax
> +	cmpq SEG_PREFIX(%rsi), %rax
>   	jne not_same
> -	cmpq %gs:8(%rsi), %rdx
> +	cmpq SEG_PREFIX 8(%rsi), %rdx
>   	jne not_same
>
> -	movq %rbx, %gs:(%rsi)
> -	movq %rcx, %gs:8(%rsi)
> +	movq %rbx, SEG_PREFIX(%rsi)
> +	movq %rcx, SEG_PREFIX 8(%rsi)
>
>   	popf
>   	mov $1, %al

Tejun, does this look good to you as well? I think it should go through 
the percpu tree. It's needed to fix a boot crash with lockless SLUB 
fastpaths enabled.

                 Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
