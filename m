Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0BDE86B0003
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 10:59:51 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id r2-v6so2519217wrm.15
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 07:59:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a19-v6si2688787edj.406.2018.06.21.07.59.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 21 Jun 2018 07:59:49 -0700 (PDT)
Date: Thu, 21 Jun 2018 16:59:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: mempool: Remove unused argument in
 kasan_unpoison_element() and remove_element()
Message-ID: <20180621145947.GA13063@dhcp22.suse.cz>
References: <20180621070332.16633-1-baijiaju1990@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180621070332.16633-1-baijiaju1990@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia-Ju Bai <baijiaju1990@gmail.com>
Cc: akpm@linux-foundation.org, jthumshirn@suse.de, cl@linux.com, kstewart@linuxfoundation.org, pombredanne@nexb.com, gregkh@linuxfoundation.org, dvyukov@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 21-06-18 15:03:32, Jia-Ju Bai wrote:
> The argument "gfp_t flags" is not used in kasan_unpoison_element() 
> and remove_element(), so remove it.

yeah, seems like left over from 9b75a867cc9d ("mm: mempool: kasan: don't
poot mempool objects in quarantine")
 
> Signed-off-by: Jia-Ju Bai <baijiaju1990@gmail.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/mempool.c | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/mempool.c b/mm/mempool.c
> index 5c9dce34719b..3076ab3f7bc4 100644
> --- a/mm/mempool.c
> +++ b/mm/mempool.c
> @@ -111,7 +111,7 @@ static __always_inline void kasan_poison_element(mempool_t *pool, void *element)
>  		kasan_free_pages(element, (unsigned long)pool->pool_data);
>  }
>  
> -static void kasan_unpoison_element(mempool_t *pool, void *element, gfp_t flags)
> +static void kasan_unpoison_element(mempool_t *pool, void *element)
>  {
>  	if (pool->alloc == mempool_alloc_slab || pool->alloc == mempool_kmalloc)
>  		kasan_unpoison_slab(element);
> @@ -127,12 +127,12 @@ static __always_inline void add_element(mempool_t *pool, void *element)
>  	pool->elements[pool->curr_nr++] = element;
>  }
>  
> -static void *remove_element(mempool_t *pool, gfp_t flags)
> +static void *remove_element(mempool_t *pool)
>  {
>  	void *element = pool->elements[--pool->curr_nr];
>  
>  	BUG_ON(pool->curr_nr < 0);
> -	kasan_unpoison_element(pool, element, flags);
> +	kasan_unpoison_element(pool, element);
>  	check_element(pool, element);
>  	return element;
>  }
> @@ -151,7 +151,7 @@ void mempool_destroy(mempool_t *pool)
>  		return;
>  
>  	while (pool->curr_nr) {
> -		void *element = remove_element(pool, GFP_KERNEL);
> +		void *element = remove_element(pool);
>  		pool->free(element, pool->pool_data);
>  	}
>  	kfree(pool->elements);
> @@ -247,7 +247,7 @@ int mempool_resize(mempool_t *pool, int new_min_nr)
>  	spin_lock_irqsave(&pool->lock, flags);
>  	if (new_min_nr <= pool->min_nr) {
>  		while (new_min_nr < pool->curr_nr) {
> -			element = remove_element(pool, GFP_KERNEL);
> +			element = remove_element(pool);
>  			spin_unlock_irqrestore(&pool->lock, flags);
>  			pool->free(element, pool->pool_data);
>  			spin_lock_irqsave(&pool->lock, flags);
> @@ -333,7 +333,7 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
>  
>  	spin_lock_irqsave(&pool->lock, flags);
>  	if (likely(pool->curr_nr)) {
> -		element = remove_element(pool, gfp_temp);
> +		element = remove_element(pool);
>  		spin_unlock_irqrestore(&pool->lock, flags);
>  		/* paired with rmb in mempool_free(), read comment there */
>  		smp_wmb();
> -- 
> 2.17.0

-- 
Michal Hocko
SUSE Labs
