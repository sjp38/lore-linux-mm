Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3023D6B0254
	for <linux-mm@kvack.org>; Wed,  2 Sep 2015 05:09:57 -0400 (EDT)
Received: by qkcf65 with SMTP id f65so1620079qkc.3
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 02:09:56 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q29si24821188qkh.99.2015.09.02.02.09.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Sep 2015 02:09:56 -0700 (PDT)
Date: Wed, 2 Sep 2015 11:09:50 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] slub: Avoid irqoff/on in bulk allocation
Message-ID: <20150902110950.4d407c0f@redhat.com>
In-Reply-To: <alpine.DEB.2.11.1508281443290.11894@east.gentwo.org>
References: <alpine.DEB.2.11.1508281443290.11894@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, brouer@redhat.com

On Fri, 28 Aug 2015 14:44:20 -0500 (CDT)
Christoph Lameter <cl@linux.com> wrote:

> Use the new function that can do allocation while
> interrupts are disabled.  Avoids irq on/off sequences.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> Index: linux/mm/slub.c
> ===================================================================
> --- linux.orig/mm/slub.c	2015-08-28 14:34:59.377234626 -0500
> +++ linux/mm/slub.c	2015-08-28 14:34:59.377234626 -0500
> @@ -2823,30 +2823,23 @@ bool kmem_cache_alloc_bulk(struct kmem_c
>  		void *object = c->freelist;
> 
>  		if (unlikely(!object)) {
> -			local_irq_enable();
>  			/*
>  			 * Invoking slow path likely have side-effect
>  			 * of re-populating per CPU c->freelist
>  			 */
> -			p[i] = __slab_alloc(s, flags, NUMA_NO_NODE,
> +			p[i] = ___slab_alloc(s, flags, NUMA_NO_NODE,
>  					    _RET_IP_, c);
> -			if (unlikely(!p[i])) {
> -				__kmem_cache_free_bulk(s, i, p);
> -				return false;
> -			}
> -			local_irq_disable();
> +			if (unlikely(!p[i]))
> +				goto error;
> +
>  			c = this_cpu_ptr(s->cpu_slab);
>  			continue; /* goto for-loop */
>  		}
> 
>  		/* kmem_cache debug support */
>  		s = slab_pre_alloc_hook(s, flags);
> -		if (unlikely(!s)) {
> -			__kmem_cache_free_bulk(s, i, p);
> -			c->tid = next_tid(c->tid);
> -			local_irq_enable();
> -			return false;
> -		}
> +		if (unlikely(!s))
> +			goto error;
> 
>  		c->freelist = get_freepointer(s, object);
>  		p[i] = object;
> @@ -2866,6 +2859,11 @@ bool kmem_cache_alloc_bulk(struct kmem_c
>  	}
> 
>  	return true;
> +
> +error:
> +	__kmem_cache_free_bulk(s, i, p);

Don't we need to update "tid" here, like:

  c->tid = next_tid(c->tid);

Consider a call to the ordinary kmem_cache_alloc/slab_alloc_node was
in-progress, which get PREEMPT'ed just before it's call to
this_cpu_cmpxchg_double().
 Now, this function gets called and we modify c->freelist, but cannot
get all objects and then fail (goto error).  Although we put-back
objects (via __kmem_cache_free_bulk) don't we want to update c->tid
in-order to make sure the call to this_cpu_cmpxchg_double() retry?

> +	local_irq_enable();
> +	return false;
>  }
>  EXPORT_SYMBOL(kmem_cache_alloc_bulk);


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
