Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 66AEC6B0032
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 13:04:20 -0400 (EDT)
Received: by pabqy3 with SMTP id qy3so69010216pab.3
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 10:04:20 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id bo11si18768037pdb.19.2015.06.15.10.04.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 10:04:19 -0700 (PDT)
Received: by padev16 with SMTP id ev16so69310154pad.0
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 10:04:19 -0700 (PDT)
Message-ID: <557F0591.5080704@gmail.com>
Date: Mon, 15 Jun 2015 10:04:17 -0700
From: Alexander Duyck <alexander.duyck@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 7/7] slub: initial bulk free implementation
References: <20150615155053.18824.617.stgit@devil> <20150615155256.18824.42651.stgit@devil>
In-Reply-To: <20150615155256.18824.42651.stgit@devil>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: netdev@vger.kernel.org

On 06/15/2015 08:52 AM, Jesper Dangaard Brouer wrote:
> This implements SLUB specific kmem_cache_free_bulk().  SLUB allocator
> now both have bulk alloc and free implemented.
>
> Play nice and reenable local IRQs while calling slowpath.
>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---
>   mm/slub.c |   32 +++++++++++++++++++++++++++++++-
>   1 file changed, 31 insertions(+), 1 deletion(-)
>
> diff --git a/mm/slub.c b/mm/slub.c
> index 98d0e6f73ec1..cc4f870677bb 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2752,7 +2752,37 @@ EXPORT_SYMBOL(kmem_cache_free);
>   
>   void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
>   {
> -	__kmem_cache_free_bulk(s, size, p);
> +	struct kmem_cache_cpu *c;
> +	struct page *page;
> +	int i;
> +
> +	local_irq_disable();
> +	c = this_cpu_ptr(s->cpu_slab);
> +
> +	for (i = 0; i < size; i++) {
> +		void *object = p[i];
> +
> +		if (unlikely(!object))
> +			continue; // HOW ABOUT BUG_ON()???
> +
> +		page = virt_to_head_page(object);
> +		BUG_ON(s != page->slab_cache); /* Check if valid slab page */
> +
> +		if (c->page == page) {
> +			/* Fastpath: local CPU free */
> +			set_freepointer(s, object, c->freelist);
> +			c->freelist = object;
> +		} else {
> +			c->tid = next_tid(c->tid);
> +			local_irq_enable();
> +			/* Slowpath: overhead locked cmpxchg_double_slab */
> +			__slab_free(s, page, object, _RET_IP_);
> +			local_irq_disable();
> +			c = this_cpu_ptr(s->cpu_slab);
> +		}
> +	}
> +	c->tid = next_tid(c->tid);
> +	local_irq_enable();
>   }
>   EXPORT_SYMBOL(kmem_cache_free_bulk);

So if the idea is to batch the freeing maybe you should look at doing 
the freeing in two passes.  The first would be to free all those buffers 
that share their page with the percpu slab.  Then you could just free 
everything else in the second pass after you have re-enabled IRQs.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
