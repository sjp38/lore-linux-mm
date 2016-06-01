Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 07BA36B0005
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 12:21:35 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id i127so48598212ita.2
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 09:21:35 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0092.outbound.protection.outlook.com. [104.47.1.92])
        by mx.google.com with ESMTPS id g58si3223400ote.168.2016.06.01.09.21.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 01 Jun 2016 09:21:34 -0700 (PDT)
Subject: Re: [PATCH] mm: kasan: don't touch metadata in
 kasan_[un]poison_element()
References: <1464785606-20349-1-git-send-email-glider@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <574F0BB6.1040400@virtuozzo.com>
Date: Wed, 1 Jun 2016 19:22:14 +0300
MIME-Version: 1.0
In-Reply-To: <1464785606-20349-1-git-send-email-glider@google.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>, adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, rostedt@goodmis.org, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com, kuthonuzo.luruo@hpe.com
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 06/01/2016 03:53 PM, Alexander Potapenko wrote:
> To avoid draining the mempools, KASAN shouldn't put the mempool elements
> into the quarantine upon mempool_free().

Correct, but unfortunately this patch doesn't fix that.

> It shouldn't store
> allocation/deallocation stacks upon mempool_alloc()/mempool_free() either.

Why not?

> Therefore make kasan_[un]poison_element() just change the shadow memory,
> not the metadata.
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>
> Reported-by: Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>
> ---

[...]

> +void kasan_slab_alloc(struct kmem_cache *cache, void *object,
> +			bool just_unpoison, gfp_t flags)
>  {
> -	kasan_kmalloc(cache, object, cache->object_size, flags);
> +	if (just_unpoison)

This set to 'false' in all call sites.

> +		kasan_unpoison_shadow(object, cache->object_size);
> +	else
> +		kasan_kmalloc(cache, object, cache->object_size, flags);
>  }
>  
>  void kasan_poison_slab_free(struct kmem_cache *cache, void *object)
> @@ -611,6 +615,31 @@ void kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags)
>  		KASAN_PAGE_REDZONE);
>  }
>  
> +void kasan_unpoison_kmalloc(const void *object, size_t size, gfp_t flags)
> +{
> +	struct page *page;
> +	unsigned long redzone_start;
> +	unsigned long redzone_end;
> +
> +	if (unlikely(object == ZERO_SIZE_PTR) || (object == NULL))
> +		return;
> +
> +	page = virt_to_head_page(object);
> +	redzone_start = round_up((unsigned long)(object + size),
> +				KASAN_SHADOW_SCALE_SIZE);
> +
> +	if (unlikely(!PageSlab(page)))
> +		redzone_end = (unsigned long)object +
> +			(PAGE_SIZE << compound_order(page));
> +	else
> +		redzone_end = round_up(
> +			(unsigned long)object + page->slab_cache->object_size,
> +			KASAN_SHADOW_SCALE_SIZE);
> +	kasan_unpoison_shadow(object, size);
> +	kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_start,
> +		KASAN_KMALLOC_REDZONE);
> +}
> +
>  void kasan_krealloc(const void *object, size_t size, gfp_t flags)
>  {
>  	struct page *page;
> @@ -636,7 +665,20 @@ void kasan_kfree(void *ptr)
>  		kasan_poison_shadow(ptr, PAGE_SIZE << compound_order(page),
>  				KASAN_FREE_PAGE);
>  	else
> -		kasan_slab_free(page->slab_cache, ptr);
> +		kasan_poison_slab_free(page->slab_cache, ptr);
> +}
> +
> +void kasan_poison_kfree(void *ptr)

Unused

> +{
> +	struct page *page;
> +
> +	page = virt_to_head_page(ptr);
> +
> +	if (unlikely(!PageSlab(page)))
> +		kasan_poison_shadow(ptr, PAGE_SIZE << compound_order(page),
> +				KASAN_FREE_PAGE);
> +	else
> +		kasan_poison_slab_free(page->slab_cache, ptr);
>  }
>  
>  void kasan_kfree_large(const void *ptr)
> diff --git a/mm/mempool.c b/mm/mempool.c
> index 9e075f8..bcd48c6 100644
> --- a/mm/mempool.c
> +++ b/mm/mempool.c
> @@ -115,9 +115,10 @@ static void kasan_poison_element(mempool_t *pool, void *element)
>  static void kasan_unpoison_element(mempool_t *pool, void *element, gfp_t flags)
>  {
>  	if (pool->alloc == mempool_alloc_slab)
> -		kasan_slab_alloc(pool->pool_data, element, flags);
> +		kasan_slab_alloc(pool->pool_data, element,
> +				/*just_unpoison*/ false, flags);
>  	if (pool->alloc == mempool_kmalloc)
> -		kasan_krealloc(element, (size_t)pool->pool_data, flags);
> +		kasan_unpoison_kmalloc(element, (size_t)pool->pool_data, flags);

I think, that the current code here is fine.
We only need to fix kasan_poison_element() which calls kasan_kfree() that puts objects into quarantine.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
