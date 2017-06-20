Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1383E6B0279
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 14:05:24 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id l87so39630742qki.7
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 11:05:24 -0700 (PDT)
Received: from mail-qt0-f173.google.com (mail-qt0-f173.google.com. [209.85.216.173])
        by mx.google.com with ESMTPS id k44si12853764qtf.298.2017.06.20.11.05.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 11:05:22 -0700 (PDT)
Received: by mail-qt0-f173.google.com with SMTP id u12so139793223qth.0
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 11:05:22 -0700 (PDT)
Subject: Re: [PATCH] mm: Add SLUB free list pointer obfuscation
References: <20170620030112.GA140256@beast>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <505961f9-b266-191a-f4b7-931410a55149@redhat.com>
Date: Tue, 20 Jun 2017 11:05:17 -0700
MIME-Version: 1.0
In-Reply-To: <20170620030112.GA140256@beast>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Christoph Lameter <cl@linux.com>
Cc: Daniel Micay <danielmicay@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andy Lutomirski <luto@kernel.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Tejun Heo <tj@kernel.org>, Daniel Mack <daniel@zonque.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Helge Deller <deller@gmx.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On 06/19/2017 08:01 PM, Kees Cook wrote:
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
> Suggested-by: Daniel Micay <danielmicay@gmail.com>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
>  include/linux/slub_def.h |  4 ++++
>  init/Kconfig             | 10 ++++++++++
>  mm/slub.c                | 32 +++++++++++++++++++++++++++-----
>  3 files changed, 41 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
> index 07ef550c6627..0258d6d74e9c 100644
> --- a/include/linux/slub_def.h
> +++ b/include/linux/slub_def.h
> @@ -93,6 +93,10 @@ struct kmem_cache {
>  #endif
>  #endif
>  
> +#ifdef CONFIG_SLAB_HARDENED
> +	unsigned long random;
> +#endif
> +
>  #ifdef CONFIG_NUMA
>  	/*
>  	 * Defragmentation by allocating from a remote node.
> diff --git a/init/Kconfig b/init/Kconfig
> index 1d3475fc9496..eb91082546bf 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -1900,6 +1900,16 @@ config SLAB_FREELIST_RANDOM
>  	  security feature reduces the predictability of the kernel slab
>  	  allocator against heap overflows.
>  
> +config SLAB_HARDENED
> +	bool "Harden slab cache infrastructure"
> +	default y
> +	depends on SLAB_FREELIST_RANDOM && SLUB> +	help
> +	  Many kernel heap attacks try to target slab cache metadata and
> +	  other infrastructure. This options makes minor performance
> +	  sacrifies to harden the kernel slab allocator against common
> +	  exploit methods.
> +

Going to bikeshed on SLAB_HARDENED unless this is intended to be used for
more things. Perhaps SLAB_FREELIST_HARDENED?

What's the reason for the dependency on SLAB_FREELIST_RANDOM?

>  config SLUB_CPU_PARTIAL
>  	default y
>  	depends on SLUB && SMP
> diff --git a/mm/slub.c b/mm/slub.c
> index 57e5156f02be..ffede2e0c5c1 100644
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
> +#ifdef CONFIG_SLAB_HARDENED
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
>  static inline void *get_freepointer(struct kmem_cache *s, void *object)
>  {
> -	return *(void **)(object + s->offset);
> +	return FREELIST_ENTRY(object + s->offset, s);
>  }
>  
>  static void prefetch_freepointer(const struct kmem_cache *s, void *object)
>  {
> -	prefetch(object + s->offset);
> +	if (object)
> +		prefetch(FREELIST_ENTRY(object + s->offset, s));
>  }
>  
>  static inline void *get_freepointer_safe(struct kmem_cache *s, void *object)
>  {
> +	unsigned long freepointer_addr;
>  	void *p;
>  
>  	if (!debug_pagealloc_enabled())
>  		return get_freepointer(s, object);
>  
> -	probe_kernel_read(&p, (void **)(object + s->offset), sizeof(p));
> -	return p;
> +	freepointer_addr = (unsigned long)object + s->offset;
> +	probe_kernel_read(&p, (void **)freepointer_addr, sizeof(p));
> +	return FREEPTR_VAL(p, freepointer_addr, s);
>  }
>  
>  static inline void set_freepointer(struct kmem_cache *s, void *object, void *fp)
>  {
> -	*(void **)(object + s->offset) = fp;
> +	unsigned long freeptr_addr = (unsigned long)object + s->offset;
> +
> +	*(void **)freeptr_addr = FREEPTR_VAL(fp, freeptr_addr, s);
>  }
>  
>  /* Loop over all objects in a slab */
> @@ -3536,6 +3557,7 @@ static int kmem_cache_open(struct kmem_cache *s, unsigned long flags)
>  {
>  	s->flags = kmem_cache_flags(s->size, flags, s->name, s->ctor);
>  	s->reserved = 0;
> +	initialize_random(s);
>  
>  	if (need_reserve_slab_rcu && (s->flags & SLAB_TYPESAFE_BY_RCU))
>  		s->reserved = sizeof(struct rcu_head);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
