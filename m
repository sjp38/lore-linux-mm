Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5BCED6B0253
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 12:49:17 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id g13so38100131ioj.3
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 09:49:17 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0128.outbound.protection.outlook.com. [157.55.234.128])
        by mx.google.com with ESMTPS id t205si3844953oig.234.2016.06.15.09.49.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 15 Jun 2016 09:49:16 -0700 (PDT)
Subject: Re: [PATCH v3] mm, kasan: switch SLUB to stackdepot, enable memory
 quarantine for SLUB
References: <1466004364-57279-1-git-send-email-glider@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <5761873A.2020104@virtuozzo.com>
Date: Wed, 15 Jun 2016 19:50:02 +0300
MIME-Version: 1.0
In-Reply-To: <1466004364-57279-1-git-send-email-glider@google.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>, adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, rostedt@goodmis.org, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com, kuthonuzo.luruo@hpe.com
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 06/15/2016 06:26 PM, Alexander Potapenko wrote:
> For KASAN builds:
>  - switch SLUB allocator to using stackdepot instead of storing the
>    allocation/deallocation stacks in the objects;
>  - define SLAB_RED_ZONE, SLAB_POISON, SLAB_STORE_USER to zero,
>    effectively disabling these debug features, as they're redundant in
>    the presence of KASAN;

So, why we forbid these? If user wants to set these, why not? If you don't want it, just don't turn them on, that's it.

And sometimes POISON/REDZONE might be actually useful. KASAN doesn't catch everything,
e.g. corruption may happen in assembly code, or DMA by  some device.


>  - change the freelist hook so that parts of the freelist can be put into
>    the quarantine.
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>
> ---

...

> diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
> index fb87923..8c75953 100644
> --- a/mm/kasan/kasan.h
> +++ b/mm/kasan/kasan.h
> @@ -110,7 +110,7 @@ static inline bool kasan_report_enabled(void)
>  void kasan_report(unsigned long addr, size_t size,
>  		bool is_write, unsigned long ip);
>  
> -#ifdef CONFIG_SLAB
> +#if defined(CONFIG_SLAB) || defined(CONFIG_SLUB)
>  void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cache);
>  void quarantine_reduce(void);
>  void quarantine_remove_cache(struct kmem_cache *cache);
> diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
> index 4973505..89259c2 100644
> --- a/mm/kasan/quarantine.c
> +++ b/mm/kasan/quarantine.c
> @@ -149,7 +149,12 @@ static void qlink_free(struct qlist_node *qlink, struct kmem_cache *cache)
>  
>  	local_irq_save(flags);
>  	alloc_info->state = KASAN_STATE_FREE;
> +#ifdef CONFIG_SLAB
>  	___cache_free(cache, object, _THIS_IP_);
> +#elif defined(CONFIG_SLUB)
> +	do_slab_free(cache, virt_to_head_page(object), object, NULL, 1,
> +		_RET_IP_);
> +#endif

Please, add some simple wrapper instead of this.

>  	local_irq_restore(flags);
>  }
>  


...

> diff --git a/mm/slub.c b/mm/slub.c
> index 825ff45..f023dd4 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -191,7 +191,11 @@ static inline bool kmem_cache_has_cpu_partial(struct kmem_cache *s)
>  #define MAX_OBJS_PER_PAGE	32767 /* since page.objects is u15 */
>  
>  /* Internal SLUB flags */
> +#ifndef CONFIG_KASAN
>  #define __OBJECT_POISON		0x80000000UL /* Poison object */
> +#else
> +#define __OBJECT_POISON		0x00000000UL /* Disable object poisoning */
> +#endif
>  #define __CMPXCHG_DOUBLE	0x40000000UL /* Use cmpxchg_double */
>  
>  #ifdef CONFIG_SMP
> @@ -454,10 +458,8 @@ static inline void *restore_red_left(struct kmem_cache *s, void *p)
>   */
>  #if defined(CONFIG_SLUB_DEBUG_ON)
>  static int slub_debug = DEBUG_DEFAULT_FLAGS;
> -#elif defined(CONFIG_KASAN)
> -static int slub_debug = SLAB_STORE_USER;
>  #else
> -static int slub_debug;
> +static int slub_debug = SLAB_STORE_USER;

Huh! So now it is on!? By default, and for everyone!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
