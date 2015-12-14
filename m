Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id D94CE6B0256
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 10:20:06 -0500 (EST)
Received: by qkht125 with SMTP id t125so138869617qkh.3
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 07:20:06 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y206si6225420qka.77.2015.12.14.07.20.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 07:20:03 -0800 (PST)
Date: Mon, 14 Dec 2015 16:19:58 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH V2 8/9] slab: implement bulk free in SLAB allocator
Message-ID: <20151214161958.1a8edf79@redhat.com>
In-Reply-To: <alpine.DEB.2.20.1512090945570.30894@east.gentwo.org>
References: <20151208161751.21945.53936.stgit@firesoul>
	<20151208161903.21945.33876.stgit@firesoul>
	<alpine.DEB.2.20.1512090945570.30894@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov@virtuozzo.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, brouer@redhat.com


On Wed, 9 Dec 2015 10:06:39 -0600 (CST) Christoph Lameter <cl@linux.com> wrote:

> From: Christoph Lameter <cl@linux.com>
> Subject: slab bulk api: Remove the kmem_cache parameter from kmem_cache_bulk_free()
> 
> It is desirable and necessary to free objects from different kmem_caches.
> It is required in order to support memcg object freeing across different5
> cgroups.
> 
> So drop the pointless parameter and allow freeing of arbitrary lists
> of slab allocated objects.
> 
> This patch also does the proper compound page handling so that
> arbitrary objects allocated via kmalloc() can be handled by
> kmem_cache_bulk_free().
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

I've modified this patch, to instead introduce a kfree_bulk() and keep
the old behavior of kmem_cache_free_bulk().  This allow us to easier
compare the two impl. approaches.

[...]
> Index: linux/mm/slub.c
> ===================================================================
> --- linux.orig/mm/slub.c
> +++ linux/mm/slub.c
> @@ -2887,23 +2887,30 @@ static int build_detached_freelist(struc
> 
> 
>  /* Note that interrupts must be enabled when calling this function. */
> -void kmem_cache_free_bulk(struct kmem_cache *orig_s, size_t size, void **p) 
> +void kmem_cache_free_bulk(size_t size, void **p)

Renamed to kfree_bulk(size_t size, void **p)

>  {
>  	if (WARN_ON(!size))
>  		return;
> 
>  	do {
>  		struct detached_freelist df;
> -		struct kmem_cache *s;
> +		struct page *page;
> 
> -		/* Support for memcg */
> -		s = cache_from_obj(orig_s, p[size - 1]);
> +		page = virt_to_head_page(p[size - 1]);
> 
> -		size = build_detached_freelist(s, size, p, &df);
> +		if (unlikely(!PageSlab(page))) {
> +			BUG_ON(!PageCompound(page));
> +			kfree_hook(p[size - 1]);
> +			__free_kmem_pages(page, compound_order(page));
> +			p[--size] = NULL;
> +			continue;
> +		}
> +
> +		size = build_detached_freelist(page->slab_cache, size, p, &df);
> 		if (unlikely(!df.page))
>  			continue;
> 
> -		slab_free(s, df.page, df.freelist, df.tail, df.cnt, _RET_IP_);
> +		slab_free(page->slab_cache, df.page, df.freelist,
> + 			df.tail, df.cnt, _RET_IP_);
> 	} while (likely(size));
>  }
>  EXPORT_SYMBOL(kmem_cache_free_bulk);

This specific implementation was too slow, mostly because we call
virt_to_head_page() both in this function and inside build_detached_freelist().

After integrating this directly into build_detached_freelist() I'm
getting more comparative results.

Results with disabled CONFIG_MEMCG_KMEM, and SLUB (and slab_nomerge for
more accurate results between runs):

 bulk- fallback          - kmem_cache_free_bulk - kfree_bulk
 1 - 58 cycles 14.735 ns -  55 cycles 13.880 ns -  59 cycles 14.843 ns
 2 - 53 cycles 13.298 ns -  32 cycles  8.037 ns -  34 cycles 8.592 ns
 3 - 51 cycles 12.837 ns -  25 cycles  6.442 ns -  27 cycles 6.794 ns
 4 - 50 cycles 12.514 ns -  23 cycles  5.952 ns -  23 cycles 5.958 ns
 8 - 48 cycles 12.097 ns -  20 cycles  5.160 ns -  22 cycles 5.505 ns
 16 - 47 cycles 11.888 ns -  19 cycles 4.900 ns -  19 cycles 4.969 ns
 30 - 47 cycles 11.793 ns -  18 cycles 4.688 ns -  18 cycles 4.682 ns
 32 - 47 cycles 11.926 ns -  18 cycles 4.674 ns -  18 cycles 4.702 ns
 34 - 95 cycles 23.823 ns -  24 cycles 6.068 ns -  24 cycles 6.058 ns
 48 - 81 cycles 20.258 ns -  21 cycles 5.360 ns -  21 cycles 5.338 ns
 64 - 73 cycles 18.414 ns -  20 cycles 5.160 ns -  20 cycles 5.140 ns
 128 - 90 cycles 22.563 ns -  27 cycles 6.765 ns -  27 cycles 6.801 ns
 158 - 99 cycles 24.831 ns -  30 cycles 7.625 ns -  30 cycles 7.720 ns
 250 - 104 cycles 26.173 ns -  37 cycles 9.271 ns -  37 cycles 9.371 ns

As can been seen the old kmem_cache_free_bulk() is faster than the new
kfree_bulk() (which omits the kmem_cache pointer and need to derive it
from the page->slab_cache). The base (bulk=1) extra cost is 4 cycles,
which then gets amortized as build_detached_freelist() combines objects
belonging to same page.

This is likely because the compiler, with disabled CONFIG_MEMCG_KMEM=n,
can optimize and avoid doing the lookup of the kmem_cache structure.

I'll start doing testing with CONFIG_MEMCG_KMEM enabled...

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
