Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id E3FFD6B0038
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 20:21:24 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so2216878pac.2
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 17:21:24 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id za1si6313007pbb.154.2015.06.08.17.21.22
        for <linux-mm@kvack.org>;
        Mon, 08 Jun 2015 17:21:23 -0700 (PDT)
Date: Tue, 9 Jun 2015 09:22:59 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: Corruption with MMOTS
 slub-bulk-allocation-from-per-cpu-partial-pages.patch
Message-ID: <20150609002258.GA9687@js1304-P5Q-DELUXE>
References: <20150608121639.3d9ce2aa@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150608121639.3d9ce2aa@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>

On Mon, Jun 08, 2015 at 12:16:39PM +0200, Jesper Dangaard Brouer wrote:
> 
> It seems the patch from (inserted below):
>  http://ozlabs.org/~akpm/mmots/broken-out/slub-bulk-allocation-from-per-cpu-partial-pages.patch
> 
> Is not protecting access to c->partial "enough" (section is under
> local_irq_disable/enable).  When exercising bulk API I can make it
> crash/corrupt memory when compiled with CONFIG_SLUB_CPU_PARTIAL=y
> 
> First I suspected:
>  object = get_freelist(s, c->page); 
> But the problem goes way with CONFIG_SLUB_CPU_PARTIAL=n
> 
> 
> From: Christoph Lameter <cl@linux.com>
> Subject: slub: bulk allocation from per cpu partial pages
> 
> Cover all of the per cpu objects available.
> 
> Expand the bulk allocation support to drain the per cpu partial pages
> while interrupts are off.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> Cc: Jesper Dangaard Brouer <brouer@redhat.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/slub.c |   36 +++++++++++++++++++++++++++++++++---
>  1 file changed, 33 insertions(+), 3 deletions(-)
> 
> diff -puN mm/slub.c~slub-bulk-allocation-from-per-cpu-partial-pages mm/slub.c
> --- a/mm/slub.c~slub-bulk-allocation-from-per-cpu-partial-pages
> +++ a/mm/slub.c
> @@ -2769,15 +2769,45 @@ bool kmem_cache_alloc_bulk(struct kmem_c
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

Hello,

get_freepointer() should be called before zeroing object.
It may help your problem.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
