Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id 2C2D36B006E
	for <linux-mm@kvack.org>; Thu, 16 Apr 2015 08:06:45 -0400 (EDT)
Received: by qcrf4 with SMTP id f4so4651003qcr.0
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 05:06:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s70si8025399qge.37.2015.04.16.05.06.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Apr 2015 05:06:43 -0700 (PDT)
Date: Thu, 16 Apr 2015 14:06:38 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: slub: bulk allocation from per cpu partial pages
Message-ID: <20150416140638.684838a2@redhat.com>
In-Reply-To: <alpine.DEB.2.11.1504091215330.18198@gentwo.org>
References: <alpine.DEB.2.11.1504081311070.20469@gentwo.org>
	<20150408155304.4480f11f16b60f09879c350d@linux-foundation.org>
	<alpine.DEB.2.11.1504090859560.19278@gentwo.org>
	<alpine.DEB.2.11.1504091215330.18198@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, brouer@redhat.com

On Thu, 9 Apr 2015 12:16:23 -0500 (CDT)
Christoph Lameter <cl@linux.com> wrote:

> Next step: cover all of the per cpu objects available.
> 
> 
> Expand the bulk allocation support to drain the per cpu partial
> pages while interrupts are off.

Started my micro benchmarking.

On CPU E5-2630 @ 2.30GHz, the cost of kmem_cache_alloc +
kmem_cache_free, is a tight loop (most optimal fast-path), cost 22ns.
With elem size 256 bytes, where slab chooses to make 32 obj-per-slab.

With this patch, testing different bulk sizes, the cost of alloc+free
per element is improved for small sizes of bulk (which I guess this the
is expected outcome).

Have something to compare against, I also ran the bulk sizes through
the fallback versions __kmem_cache_alloc_bulk() and
__kmem_cache_free_bulk(), e.g. the none optimized versions.

 size    --  optimized -- fallback
 bulk  8 --  15ns      --  22ns
 bulk 16 --  15ns      --  22ns
 bulk 30 --  44ns      --  48ns
 bulk 32 --  47ns      --  50ns
 bulk 64 --  52ns      --  54ns

For smaller bulk sizes 8 and 16, this is actually a significant
improvement, especially considering the free side is not optimized.

Thus, the 7ns improvement must come from the alloc side only.


> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> Index: linux/mm/slub.c
> ===================================================================
> --- linux.orig/mm/slub.c
> +++ linux/mm/slub.c
> @@ -2771,15 +2771,45 @@ bool kmem_cache_alloc_bulk(struct kmem_c
>  		while (size) {
>  			void *object = c->freelist;
> 
> -			if (!object)
> -				break;
> +			if (unlikely(!object)) {
> +				/*
> +				 * Check if there remotely freed objects
> +				 * availalbe in the page.
> +				 */
> +				object = get_freelist(s, c->page);
> +
> +				if (!object) {
> +					/*
> +					 * All objects in use lets check if
> +					 * we have other per cpu partial
> +					 * pages that have available
> +					 * objects.
> +					 */
> +					c->page = c->partial;
> +					if (!c->page) {
> +						/* No per cpu objects left */
> +						c->freelist = NULL;
> +						break;
> +					}
> +
> +					/* Next per cpu partial page */
> +					c->partial = c->page->next;
> +					c->freelist = get_freelist(s,
> +							c->page);
> +					continue;
> +				}
> +
> +			}
> +
> 
> -			c->freelist = get_freepointer(s, object);
>  			*p++ = object;
>  			size--;
> 
>  			if (unlikely(flags & __GFP_ZERO))
>  				memset(object, 0, s->object_size);
> +
> +			c->freelist = get_freepointer(s, object);
> +
>  		}
>  		c->tid = next_tid(c->tid);
> 



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
