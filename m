Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 729D7680FED
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 19:40:01 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id r103so976362wrb.0
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 16:40:01 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m19si22691048wmb.57.2017.07.05.16.39.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 16:40:00 -0700 (PDT)
Date: Wed, 5 Jul 2017 16:39:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: Add SLUB free list pointer obfuscation
Message-Id: <20170705163957.90c7856f622a63666df4b5a6@linux-foundation.org>
In-Reply-To: <20170623015010.GA137429@beast>
References: <20170623015010.GA137429@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Christoph Lameter <cl@linux.com>, Laura Abbott <labbott@redhat.com>, Daniel Micay <danielmicay@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Josh Triplett <josh@joshtriplett.org>, Andy Lutomirski <luto@kernel.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Tejun Heo <tj@kernel.org>, Daniel Mack <daniel@zonque.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Helge Deller <deller@gmx.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

On Thu, 22 Jun 2017 18:50:10 -0700 Kees Cook <keescook@chromium.org> wrote:

> This SLUB free list pointer obfuscation code is modified from Brad
> Spengler/PaX Team's code in the last public patch of grsecurity/PaX based
> on my understanding of the code. Changes or omissions from the original
> code are mine and don't reflect the original grsecurity/PaX code.
> 
> This adds a per-cache random value to SLUB caches that is XORed with
> their freelist pointers. This adds nearly zero overhead and frustrates the
> very common heap overflow exploitation method of overwriting freelist
> pointers. A recent example of the attack is written up here:
> http://cyseclabs.com/blog/cve-2016-6187-heap-off-by-one-exploit
> 
> This is based on patches by Daniel Micay, and refactored to avoid lots
> of #ifdef code.
> 
> ...
>
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -1900,6 +1900,15 @@ config SLAB_FREELIST_RANDOM
>  	  security feature reduces the predictability of the kernel slab
>  	  allocator against heap overflows.
>  
> +config SLAB_FREELIST_HARDENED
> +	bool "Harden slab freelist metadata"
> +	depends on SLUB
> +	help
> +	  Many kernel heap attacks try to target slab cache metadata and
> +	  other infrastructure. This options makes minor performance
> +	  sacrifies to harden the kernel slab allocator against common
> +	  freelist exploit methods.
> +

Well, it is optable-outable.

>  config SLUB_CPU_PARTIAL
>  	default y
>  	depends on SLUB && SMP
> diff --git a/mm/slub.c b/mm/slub.c
> index 57e5156f02be..590e7830aaed 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -34,6 +34,7 @@
>  #include <linux/stacktrace.h>
>  #include <linux/prefetch.h>
>  #include <linux/memcontrol.h>
> +#include <linux/random.h>
>  
>  #include <trace/events/kmem.h>
>  
> @@ -238,30 +239,50 @@ static inline void stat(const struct kmem_cache *s, enum stat_item si)
>   * 			Core slab cache functions
>   *******************************************************************/
>  
> +#ifdef CONFIG_SLAB_FREELIST_HARDENED
> +# define initialize_random(s)					\
> +		do {						\
> +			s->random = get_random_long();		\
> +		} while (0)
> +# define FREEPTR_VAL(ptr, ptr_addr, s)	\
> +		(void *)((unsigned long)(ptr) ^ s->random ^ (ptr_addr))
> +#else
> +# define initialize_random(s)		do { } while (0)
> +# define FREEPTR_VAL(ptr, addr, s)	((void *)(ptr))
> +#endif
> +#define FREELIST_ENTRY(ptr_addr, s)				\
> +		FREEPTR_VAL(*(unsigned long *)(ptr_addr),	\
> +			    (unsigned long)ptr_addr, s)
> +

That's a bit of an eyesore.  Is there any reason why we cannot
implement all of the above in nice, conventional C functions?

>
> ...
>
> @@ -3536,6 +3557,7 @@ static int kmem_cache_open(struct kmem_cache *s, unsigned long flags)
>  {
>  	s->flags = kmem_cache_flags(s->size, flags, s->name, s->ctor);
>  	s->reserved = 0;
> +	initialize_random(s);
>  
>  	if (need_reserve_slab_rcu && (s->flags & SLAB_TYPESAFE_BY_RCU))
>  		s->reserved = sizeof(struct rcu_head);

We regularly have issues where the random system just isn't ready
(enough) for clients to use it.  Are you sure the above is actually
useful for the boot-time caches?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
