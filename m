Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id 68D4282F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 03:39:03 -0500 (EST)
Received: by lbblt2 with SMTP id lt2so11206566lbb.3
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 00:39:02 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id aw10si3546242lbc.112.2015.11.05.00.39.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Nov 2015 00:39:02 -0800 (PST)
Date: Thu, 5 Nov 2015 11:38:43 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] slub: add missing kmem cgroup support to
 kmem_cache_free_bulk
Message-ID: <20151105083842.GA29259@esperanza>
References: <20151029130531.15158.58018.stgit@firesoul>
 <20151105050621.GC20374@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151105050621.GC20374@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>

On Thu, Nov 05, 2015 at 02:06:21PM +0900, Joonsoo Kim wrote:
> On Thu, Oct 29, 2015 at 02:05:31PM +0100, Jesper Dangaard Brouer wrote:
> > Initial implementation missed support for kmem cgroup support
> > in kmem_cache_free_bulk() call, add this.
> > 
> > If CONFIG_MEMCG_KMEM is not enabled, the compiler should
> > be smart enough to not add any asm code.
> > 
> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> > ---
> >  mm/slub.c |    3 +++
> >  1 file changed, 3 insertions(+)
> > 
> > diff --git a/mm/slub.c b/mm/slub.c
> > index 9be12ffae9fc..9875864ad7b8 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -2845,6 +2845,9 @@ static int build_detached_freelist(struct kmem_cache *s, size_t size,
> >  	if (!object)
> >  		return 0;
> >  
> > +	/* Support for kmemcg */
> > +	s = cache_from_obj(s, object);
> > +
> >  	/* Start new detached freelist */
> >  	set_freepointer(s, object, NULL);
> >  	df->page = virt_to_head_page(object);
> 
> Hello,
> 
> It'd better to add this 's = cache_from_obj()' on kmem_cache_free_bulk().
> Not only build_detached_freelist() but also slab_free() need proper
> cache.

Yeah, Joonsoo is right. Besides, there's a bug in kmem_cache_alloc_bulk:

> /* Note that interrupts must be enabled when calling this function. */
> bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
> 			   void **p)
> {
> 	struct kmem_cache_cpu *c;
> 	int i;
> 
> 	/*
> 	 * Drain objects in the per cpu slab, while disabling local
> 	 * IRQs, which protects against PREEMPT and interrupts
> 	 * handlers invoking normal fastpath.
> 	 */
> 	local_irq_disable();
> 	c = this_cpu_ptr(s->cpu_slab);
> 
> 	for (i = 0; i < size; i++) {
> 		void *object = c->freelist;
> 
> 		if (unlikely(!object)) {
> 			/*
> 			 * Invoking slow path likely have side-effect
> 			 * of re-populating per CPU c->freelist
> 			 */
> 			p[i] = ___slab_alloc(s, flags, NUMA_NO_NODE,
> 					    _RET_IP_, c);
> 			if (unlikely(!p[i]))
> 				goto error;
> 
> 			c = this_cpu_ptr(s->cpu_slab);
> 			continue; /* goto for-loop */
> 		}
> 
> 		/* kmem_cache debug support */
> 		s = slab_pre_alloc_hook(s, flags);

slab_pre_alloc_hook expects a global cache and returns per memcg one, so
calling this function from inside a kmemcg will result in hitting the
VM_BUG_ON in __memcg_kmem_get_cache, not saying about mis-accounting of
__slab_alloc.

memcg_kmem_get_cache should be called once, in the very beginning of
kmem_cache_alloc_bulk, and it should be matched by memcg_kmem_put_cache
when we are done.

Thanks,
Vladimir

> 		if (unlikely(!s))
> 			goto error;
> 
> 		c->freelist = get_freepointer(s, object);
> 		p[i] = object;
> 
> 		/* kmem_cache debug support */
> 		slab_post_alloc_hook(s, flags, object);
> 	}
> 	c->tid = next_tid(c->tid);
> 	local_irq_enable();
> 
> 	/* Clear memory outside IRQ disabled fastpath loop */
> 	if (unlikely(flags & __GFP_ZERO)) {
> 		int j;
> 
> 		for (j = 0; j < i; j++)
> 			memset(p[j], 0, s->object_size);
> 	}
> 
> 	return true;
> 
> error:
> 	__kmem_cache_free_bulk(s, i, p);
> 	local_irq_enable();
> 	return false;
> }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
