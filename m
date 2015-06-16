Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id ADC096B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 03:25:59 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so8298597pdb.1
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 00:25:59 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id ed4si170646pbd.248.2015.06.16.00.25.57
        for <linux-mm@kvack.org>;
        Tue, 16 Jun 2015 00:25:58 -0700 (PDT)
Date: Tue, 16 Jun 2015 16:28:06 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 7/7] slub: initial bulk free implementation
Message-ID: <20150616072806.GC13125@js1304-P5Q-DELUXE>
References: <20150615155053.18824.617.stgit@devil>
 <20150615155256.18824.42651.stgit@devil>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150615155256.18824.42651.stgit@devil>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>

On Mon, Jun 15, 2015 at 05:52:56PM +0200, Jesper Dangaard Brouer wrote:
> This implements SLUB specific kmem_cache_free_bulk().  SLUB allocator
> now both have bulk alloc and free implemented.
> 
> Play nice and reenable local IRQs while calling slowpath.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---
>  mm/slub.c |   32 +++++++++++++++++++++++++++++++-
>  1 file changed, 31 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index 98d0e6f73ec1..cc4f870677bb 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2752,7 +2752,37 @@ EXPORT_SYMBOL(kmem_cache_free);
>  
>  void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
>  {
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

SLUB free path doesn't need to irq management in many cases although
it uses cmpxchg_doule_slab. Is this really better than just calling
__kmem_cache_free_bulk()?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
