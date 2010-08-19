Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 276126B02C0
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 14:57:10 -0400 (EDT)
Date: Thu, 19 Aug 2010 13:57:16 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [S+Q Cleanup2 4/6] slub: Dynamically size kmalloc cache
 allocations
In-Reply-To: <alpine.DEB.2.00.1008181350340.28077@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1008191345570.1839@router.home>
References: <20100818162539.281413425@linux.com> <20100818162638.201568486@linux.com> <alpine.DEB.2.00.1008181350340.28077@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 18 Aug 2010, David Rientjes wrote:

> > Index: linux-2.6/mm/slub.c
> > ===================================================================
> > --- linux-2.6.orig/mm/slub.c	2010-08-17 12:30:11.000000000 -0500
> > +++ linux-2.6/mm/slub.c	2010-08-17 14:46:09.000000000 -0500
> > @@ -178,7 +178,7 @@ static struct notifier_block slab_notifi
> >
> >  static enum {
> >  	DOWN,		/* No slab functionality available */
> > -	PARTIAL,	/* kmem_cache_open() works but kmalloc does not */
> > +	PARTIAL,	/* Kmem_cache_node works */
>
> This isn't going to be needed anymore, even with the rest of your SLUB+Q
> patches, so it should probably be removed unless you can think of a future
> use.

Its needed for early_kmem_cache_alloc_node() on NUMA. It only runs on
DOWN. The PARTIAL state is required to enable allocation from
the kmem_cache_node cache.

> > -static void create_kmalloc_cache(struct kmem_cache *s,
> > +static void __init create_kmalloc_cache(struct kmem_cache **sp,
> >  		const char *name, int size, unsigned int flags)
> >  {
> > +	struct kmem_cache *s;
> > +
> > +	s = kmem_cache_alloc(kmem_cache, GFP_NOWAIT);
>
> Needs BUG_ON(!s)?

It will segfault even without that.

> > @@ -2552,6 +2562,8 @@ static void create_kmalloc_cache(struct
> >  								flags, NULL))
> >  		goto panic;
> >
> > +	*sp = s;
>
> Is there an advantage to doing this and not simply having the function
> return s (or NULL, on error) back to kmem_cache_init()?

Cannot think of any advantage.

> > +static void __init kmem_cache_bootstrap_fixup(struct kmem_cache *s)
> > +{
> > +	int node;
> > +
> > +	list_add(&s->list, &slab_caches);
> > +	sysfs_slab_add(s);
>
> We'll need some error handling here to at least emit a warning message
> that we're missing caches in sysfs.


What caches are missing? We should drop the sysfs_slab_add() I guess.
Useless here since it wont do anything.

>
> > +	s->refcount = -1;
> > +
> > +	for_each_node(node) {
>
> Only needs to iterate over N_NORMAL_MEMORY.
>
> > +		struct kmem_cache_node *n = get_node(s, node);
> > +		struct page *p;
> > +

True. Changed.

> > +		if (n) {
> > +			list_for_each_entry(p, &n->partial, lru)
> > +				p->slab = s;
> > +
> > +#ifdef CONFIG_SLAB_DEBUG
> > +			list_for_each_entry(p, &n->full, lru)
> > +				p->slab = s;
> > +#endif
> > +		}
> > +	}
> > +}
> > +
> >  void __init kmem_cache_init(void)
> >  {
> >  	int i;
> >  	int caches = 0;
> > +	struct kmem_cache *temp_kmem_cache;
> > +	int order;
> >
> >  #ifdef CONFIG_NUMA
> > +	struct kmem_cache *temp_kmem_cache_node;
> > +	unsigned long kmalloc_size;
> > +
> > +	kmem_size = offsetof(struct kmem_cache, node) +
> > +				nr_node_ids * sizeof(struct kmem_cache_node *);
> > +
> > +	/* Allocate two kmem_caches from the page allocator */
> > +	kmalloc_size = ALIGN(kmem_size, cache_line_size());
> > +	order = get_order(2 * kmalloc_size);
> > +	kmem_cache = (void *)__get_free_pages(GFP_NOWAIT, order);
> > +
> >  	/*
> >  	 * Must first have the slab cache available for the allocations of the
> >  	 * struct kmem_cache_node's. There is special bootstrap code in
> >  	 * kmem_cache_open for slab_state == DOWN.
> >  	 */
> > -	create_kmalloc_cache(&kmalloc_caches[0], "kmem_cache_node",
> > -		sizeof(struct kmem_cache_node), 0);
> > -	kmalloc_caches[0].refcount = -1;
> > -	caches++;
> > +	kmem_cache_node = (void *)kmem_cache + kmalloc_size;
> > +
> > +	kmem_cache_open(kmem_cache_node, "kmem_cache_node",
> > +		sizeof(struct kmem_cache_node),
> > +		0, SLAB_HWCACHE_ALIGN | SLAB_PANIC, NULL);
> >
> >  	hotplug_memory_notifier(slab_memory_callback, SLAB_CALLBACK_PRI);
> > +#else
> > +	/* Allocate a single kmem_cache from the page allocator */
> > +	kmem_size = sizeof(struct kmem_cache);
> > +	order = get_order(kmem_size);
>
> Should this be cacheline aligned?

Not in the SMP case. __get_free_pages() gives us a page that is cacheline
aligned.

> > +	temp_kmem_cache = kmem_cache;
> > +	kmem_cache_open(kmem_cache, "kmem_cache", kmem_size,
> > +		0, SLAB_HWCACHE_ALIGN | SLAB_PANIC, NULL);
> > +	kmem_cache = kmem_cache_alloc(kmem_cache, GFP_NOWAIT);
>
> BUG_ON(!kmem_cache);

It will segfault in the following memcpy.

> > +	memcpy(kmem_cache, temp_kmem_cache, kmem_size);
>
> kmem_cache_bootstrap_fixup(kmem_cache) should be here and not later,
> right?

We are still using the original temp_kmem_cache to allocate
kmem_cache_node. We need to wait until that is complete before doing the
fixup.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
