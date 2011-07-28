Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 668806B0169
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 06:46:32 -0400 (EDT)
Received: by fxg9 with SMTP id 9so1505233fxg.14
        for <linux-mm@kvack.org>; Thu, 28 Jul 2011 03:46:28 -0700 (PDT)
Date: Thu, 28 Jul 2011 13:46:23 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: possible recursive locking detected cache_alloc_refill() +
 cache_flusharray()
In-Reply-To: <1311176680.29152.20.camel@twins>
Message-ID: <alpine.DEB.2.00.1107281346060.2841@tiger>
References: <20110716211850.GA23917@breakpoint.cc>  <alpine.LFD.2.02.1107172333340.2702@ionos>  <alpine.DEB.2.00.1107201619540.3528@tiger> <1311168638.5345.80.camel@twins>  <alpine.DEB.2.00.1107201642500.4921@tiger> <1311176680.29152.20.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Sebastian Siewior <sebastian@breakpoint.cc>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

On Wed, 20 Jul 2011, Peter Zijlstra wrote:
> We just need to annotate the SLAB_DEBUG_OBJECTS slab with a different
> key. Something like the below, except that doesn't quite cover cpu
> hotplug yet I think.. /me pokes more
>
> Completely untested, hasn't even seen a compiler etc..

Ping? Did someone send me a patch I can apply?

>
> ---
> mm/slab.c |   65 ++++++++++++++++++++++++++++++++++++++++++++----------------
> 1 files changed, 47 insertions(+), 18 deletions(-)
>
> diff --git a/mm/slab.c b/mm/slab.c
> index d96e223..c13f7e9 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -620,6 +620,37 @@ int slab_is_available(void)
> static struct lock_class_key on_slab_l3_key;
> static struct lock_class_key on_slab_alc_key;
>
> +static struct lock_class_key debugobj_l3_key;
> +static struct lock_class_key debugobj_alc_key;
> +
> +static void slab_set_lock_classes(struct kmem_cache *cachep,
> +		struct lock_class_key *l3_key, struct lock_class_key *alc_key)
> +{
> +	struct array_cache **alc;
> +	struct kmem_list3 *l3;
> +	int r;
> +
> +	l3 = cachep->nodelists[q];
> +	if (!l3)
> +		return;
> +
> +	lockdep_set_class(&l3->list_lock, l3_key);
> +	alc = l3->alien;
> +	/*
> +	 * FIXME: This check for BAD_ALIEN_MAGIC
> +	 * should go away when common slab code is taught to
> +	 * work even without alien caches.
> +	 * Currently, non NUMA code returns BAD_ALIEN_MAGIC
> +	 * for alloc_alien_cache,
> +	 */
> +	if (!alc || (unsigned long)alc == BAD_ALIEN_MAGIC)
> +		return;
> +	for_each_node(r) {
> +		if (alc[r])
> +			lockdep_set_class(&alc[r]->lock, alc_key);
> +	}
> +}
> +
> static void init_node_lock_keys(int q)
> {
> 	struct cache_sizes *s = malloc_sizes;
> @@ -628,29 +659,14 @@ static void init_node_lock_keys(int q)
> 		return;
>
> 	for (s = malloc_sizes; s->cs_size != ULONG_MAX; s++) {
> -		struct array_cache **alc;
> 		struct kmem_list3 *l3;
> -		int r;
>
> 		l3 = s->cs_cachep->nodelists[q];
> 		if (!l3 || OFF_SLAB(s->cs_cachep))
> 			continue;
> -		lockdep_set_class(&l3->list_lock, &on_slab_l3_key);
> -		alc = l3->alien;
> -		/*
> -		 * FIXME: This check for BAD_ALIEN_MAGIC
> -		 * should go away when common slab code is taught to
> -		 * work even without alien caches.
> -		 * Currently, non NUMA code returns BAD_ALIEN_MAGIC
> -		 * for alloc_alien_cache,
> -		 */
> -		if (!alc || (unsigned long)alc == BAD_ALIEN_MAGIC)
> -			continue;
> -		for_each_node(r) {
> -			if (alc[r])
> -				lockdep_set_class(&alc[r]->lock,
> -					&on_slab_alc_key);
> -		}
> +
> +		slab_set_lock_classes(s->cs_cachep,
> +				&on_slab_l3_key, &on_slab_alc_key)
> 	}
> }
>
> @@ -2424,6 +2440,19 @@ kmem_cache_create (const char *name, size_t size, size_t align,
> 		goto oops;
> 	}
>
> +	if (flags & SLAB_DEBUG_OBJECTS) {
> +		/*
> +		 * Would deadlock through slab_destroy()->call_rcu()->
> +		 * debug_object_activate()->kmem_cache_alloc().
> +		 */
> +		WARN_ON_ONCE(flags & SLAB_DESTROY_BY_RCU);
> +
> +#ifdef CONFIG_LOCKDEP
> +		slab_set_lock_classes(cachep,
> +				&debugobj_l3_key, &debugobj_alc_key);
> +#endif
> +	}
> +
> 	/* cache setup completed, link it into the list */
> 	list_add(&cachep->next, &cache_chain);
> oops:
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
