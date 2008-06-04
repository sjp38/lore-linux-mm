Message-ID: <48469C5B.4070307@goop.org>
Date: Wed, 04 Jun 2008 14:44:59 +0100
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] SGI UV: TLB shootdown using broadcast assist unit
References: <E1K3fF0-00056O-HE@eag09.americas.sgi.com>
In-Reply-To: <E1K3fF0-00056O-HE@eag09.americas.sgi.com>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Cliff Wickman <cpw@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Cliff Wickman wrote:
> Signed-off-by: Cliff Wickman <cpw@sgi.com>
> ---
>  arch/x86/kernel/Makefile    |    2 
>  arch/x86/kernel/entry_64.S  |    4 
>  arch/x86/kernel/tlb_64.c    |    5 
>  arch/x86/kernel/tlb_uv.c    |  785 ++++++++++++++++++++++++++++++++++++++++++++
>  include/asm-x86/atomic_64.h |   30 +
>   

The atomic_64.h changes should be a separate patch.

> Index: 080602.ingo/include/asm-x86/atomic_64.h
> ===================================================================
> --- 080602.ingo.orig/include/asm-x86/atomic_64.h
> +++ 080602.ingo/include/asm-x86/atomic_64.h
> @@ -425,6 +425,36 @@ static inline int atomic64_add_unless(at
>  	return c != (u);
>  }
>  
> +/**
> + * atomic_inc_short - increment of a short integer
> + * @v: pointer to type int
> + *
> + * Atomically adds 1 to @v
> + * Returns the new value of @u
> + */
> +static inline short int atomic_inc_short(short int *v)
> +{
> +	asm volatile("movw $1, %%cx; lock; xaddw %%cx, %0\n"
> +		: "+m" (*v) : : "cx");
> +		/* clobbers counter register cx */
> +	return *v;
> +}
>   
Why?  Why not just:

	asm("lock add $1, %0" : "+m" (*v));

Does xaddw buy anything here?

> +
> +/**
> + * atomic_or_long - OR of two long integers
> + * @v1: pointer to type unsigned long
> + * @v2: pointer to type unsigned long
> + *
> + * Atomically ORs @v1 and @v2
> + * Returns the result of the OR
> + */
> +static inline void atomic_or_long(unsigned long *v1, unsigned long v2)
> +{
> +	asm volatile("movq %1, %%rax; lock; orq %%rax, %0\n"
> +		: "+m" (*v1) : "g" (v2): "rax");
> +		/* clobbers accumulator register ax */
>   

How about:

	asm("lock or %1, %0" : "+m" (*v1), "r" (v2));

No need to force %rax, is there?


    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
