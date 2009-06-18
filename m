Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 61CD26B004D
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 22:58:34 -0400 (EDT)
Message-ID: <4A39ADBF.1000505@kernel.org>
Date: Thu, 18 Jun 2009 12:00:15 +0900
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [this_cpu_xx V2 10/19] this_cpu: X86 optimized this_cpu operations
References: <20090617203337.399182817@gentwo.org> <20090617203444.731295080@gentwo.org>
In-Reply-To: <20090617203444.731295080@gentwo.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: cl@linux-foundation.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

cl@linux-foundation.org wrote:
> Basically the existing percpu ops can be used. However, we do not pass a
> reference to a percpu variable in. Instead an address of a percpu variable
> is provided.
> 
> Both preempt, the non preempt and the irqsafe operations generate the same code.
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

I'm a bit confused why this patch is in the middle of patches which
convert macro users?  Wouldn't it be better to put this one right
after the patch which introduces this_cpu_*()?

> ---
>  arch/x86/include/asm/percpu.h |   22 ++++++++++++++++++++++
>  1 file changed, 22 insertions(+)
> 
> Index: linux-2.6/arch/x86/include/asm/percpu.h
> ===================================================================
> --- linux-2.6.orig/arch/x86/include/asm/percpu.h	2009-06-04 13:38:01.000000000 -0500
> +++ linux-2.6/arch/x86/include/asm/percpu.h	2009-06-04 14:21:22.000000000 -0500
> @@ -140,6 +140,28 @@ do {							\
>  #define percpu_or(var, val)	percpu_to_op("or", per_cpu__##var, val)
>  #define percpu_xor(var, val)	percpu_to_op("xor", per_cpu__##var, val)
>  
> +#define __this_cpu_read(pcp)		percpu_from_op("mov", pcp)
                                                             ^^^^
					              missing parentheses
and maybe adding () around val is a good idea too?

Also, I'm not quite sure these macros would operate on the correct
address.  Checking... yeap, the following function,

 DEFINE_PER_CPU(int, my_pcpu_cnt);
 void my_func(void)
 {
	 int *ptr = &per_cpu__my_pcpu_cnt;

	 *(int *)this_cpu_ptr(ptr) = 0;
	 this_cpu_add(ptr, 1);
	 percpu_add(my_pcpu_cnt, 1);
 }

ends up being assembled into the following.

 mov    $0xdd48,%rax		# save offset of my_pcpu_cnt
 mov    %rax,-0x10(%rbp)		# into local var ptr
 mov    %gs:0xb800,%rdx		# fetch this_cpu_off
 movl   $0x0,(%rax,%rdx,1)	# 0 -> *(this_cpu_off + my_pcpu_cnt)
 addq   $0x1,%gs:-0x10(%rbp)	# add 1 to %gs:ptr !!!
 addl   $0x1,%gs:0xdd48		# add 1 to %gs:my_pcpu_cnt

So, this_cpu_add(ptr, 1) ends up accessing the wrong address.  Also,
please note the use of 'addq' instead of 'addl' as the pointer
variable is being modified.

> +#define __this_cpu_write(pcp, val)	percpu_to_op("mov", (pcp), val)
> +#define __this_cpu_add(pcp, val)	percpu_to_op("add", (pcp), val)
> +#define __this_cpu_sub(pcp, val)	percpu_to_op("sub", (pcp), val)
> +#define __this_cpu_and(pcp, val)	percpu_to_op("and", (pcp), val)
> +#define __this_cpu_or(pcp, val)		percpu_to_op("or", (pcp), val)
> +#define __this_cpu_xor(pcp, val)	percpu_to_op("xor", (pcp), val)
> +
> +#define this_cpu_read(pcp)		percpu_from_op("mov", (pcp))
> +#define this_cpu_write(pcp, val)	percpu_to_op("mov", (pcp), val)
> +#define this_cpu_add(pcp, val)		percpu_to_op("add", (pcp), val)
> +#define this_cpu_sub(pcp, val)		percpu_to_op("sub", (pcp), val)
> +#define this_cpu_and(pcp, val)		percpu_to_op("and", (pcp), val)
> +#define this_cpu_or(pcp, val)		percpu_to_op("or", (pcp), val)
> +#define this_cpu_xor(pcp, val)		percpu_to_op("xor", (pcp), val)
>
> +#define irqsafe_cpu_add(pcp, val)	percpu_to_op("add", (pcp), val)
> +#define irqsafe_cpu_sub(pcp, val)	percpu_to_op("sub", (pcp), val)
> +#define irqsafe_cpu_and(pcp, val)	percpu_to_op("and", (pcp), val)
> +#define irqsafe_cpu_or(pcp, val)	percpu_to_op("or", (pcp), val)
> +#define irqsafe_cpu_xor(pcp, val)	percpu_to_op("xor", (pcp), val)

Wouldn't it be clearer / easier to define preempt and irqsafe versions
as aliases of __ prefixed ones?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
