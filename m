Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 572DF6B0258
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 05:16:44 -0500 (EST)
Received: by qgcc31 with SMTP id c31so83713007qgc.3
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 02:16:44 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u102si11399043qge.90.2015.12.04.02.16.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Dec 2015 02:16:43 -0800 (PST)
Date: Fri, 4 Dec 2015 11:16:38 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 1/2] slab: implement bulk alloc in SLAB allocator
Message-ID: <20151204111638.2c581a9d@redhat.com>
In-Reply-To: <20151203155637.3589.62609.stgit@firesoul>
References: <20151203155600.3589.86568.stgit@firesoul>
	<20151203155637.3589.62609.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Christoph Lameter <cl@linux.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, brouer@redhat.com


On Thu, 03 Dec 2015 16:57:31 +0100 Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> diff --git a/mm/slab.c b/mm/slab.c
> index 4765c97ce690..3354489547ec 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -3420,9 +3420,59 @@ void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
>  EXPORT_SYMBOL(kmem_cache_free_bulk);
>  
>  int kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
> -								void **p)
> +			  void **p)
>  {
> -	return __kmem_cache_alloc_bulk(s, flags, size, p);
> +	size_t i;
> +
> +	flags &= gfp_allowed_mask;
> +	lockdep_trace_alloc(flags);
> +
> +	if (slab_should_failslab(s, flags))
> +		return 0;
> +
> +	s = memcg_kmem_get_cache(s, flags);
> +
> +	cache_alloc_debugcheck_before(s, flags);
> +
> +	local_irq_disable();
> +	for (i = 0; i < size; i++) {
> +		void *objp = __do_cache_alloc(s, flags);
> +
> +		// this call could be done outside IRQ disabled section
> +		objp = cache_alloc_debugcheck_after(s, flags, objp, _RET_IP_);

Profiling with SLAB mem debugging on (CONFIG_DEBUG_SLAB=y), this call
cache_alloc_debugcheck_after() is the most expensive call, well
actually the underlying check_poison_obj() call.

Thus, it might be a good idea to, place it outside the IRQ disabled section?
It might make the code look a little strange, but I can try and we can
see how ugly that makes the code look (and the compiler still have to
be able to remove the code in-case no debugging enabled).

> +
> +		if (unlikely(!objp))
> +			goto error;
> +
> +		prefetchw(objp);
> +		p[i] = objp;
> +	}
> +	local_irq_enable();
> +
> +	/* Kmemleak and kmemcheck outside IRQ disabled section */
> +	for (i = 0; i < size; i++) {
> +		void *x = p[i];
> +
> +		kmemleak_alloc_recursive(x, s->object_size, 1, s->flags, flags);
> +		kmemcheck_slab_alloc(s, flags, x, s->object_size);
> +	}
> +
> +	/* Clear memory outside IRQ disabled section */
> +	if (unlikely(flags & __GFP_ZERO))
> +		for (i = 0; i < size; i++)
> +			memset(p[i], 0, s->object_size);
[...]

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
