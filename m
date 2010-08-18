Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 4EF326B01F1
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 10:54:41 -0400 (EDT)
Date: Wed, 18 Aug 2010 09:54:36 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [S+Q Cleanup 3/6] slub: Remove static kmem_cache_cpu array for
 boot
In-Reply-To: <alpine.DEB.2.00.1008171638160.31928@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1008180953420.4025@router.home>
References: <20100817211118.958108012@linux.com> <20100817211136.091336874@linux.com> <alpine.DEB.2.00.1008171638160.31928@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 17 Aug 2010, David Rientjes wrote:

> On Tue, 17 Aug 2010, Christoph Lameter wrote:
>
> > Index: linux-2.6/mm/slub.c
> > ===================================================================
> > --- linux-2.6.orig/mm/slub.c	2010-08-13 10:32:45.000000000 -0500
> > +++ linux-2.6/mm/slub.c	2010-08-13 10:32:50.000000000 -0500
> > @@ -2062,23 +2062,14 @@ init_kmem_cache_node(struct kmem_cache_n
> >  #endif
> >  }
> >
> > -static DEFINE_PER_CPU(struct kmem_cache_cpu, kmalloc_percpu[KMALLOC_CACHES]);
> > -
> >  static inline int alloc_kmem_cache_cpus(struct kmem_cache *s)
> >  {
> > -	if (s < kmalloc_caches + KMALLOC_CACHES && s >= kmalloc_caches)
> > -		/*
> > -		 * Boot time creation of the kmalloc array. Use static per cpu data
> > -		 * since the per cpu allocator is not available yet.
> > -		 */
> > -		s->cpu_slab = kmalloc_percpu + (s - kmalloc_caches);
> > -	else
> > -		s->cpu_slab =  alloc_percpu(struct kmem_cache_cpu);
> > +	BUILD_BUG_ON(PERCPU_DYNAMIC_EARLY_SIZE <
> > +			SLUB_PAGE_SHIFT * sizeof(struct kmem_cache));
>
> This fails with CONFIG_NODES_SHIFT=10 on x86_64, which means it will fail
> the ia64 defconfig as well.  struct kmem_cache stores nodemask pointers up
> to MAX_NUMNODES, which makes the conditional fail.

Hmmm... Wrong struct name. This needs to be struct kmem_cache_cpu not
struct kmem_cache. struct kmem_cache_cpu is sufficiently small.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
