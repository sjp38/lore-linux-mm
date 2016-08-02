Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 67EF56B0253
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 20:50:18 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id u142so333809743oia.2
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 17:50:18 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 185si265071ioo.21.2016.08.01.17.50.16
        for <linux-mm@kvack.org>;
        Mon, 01 Aug 2016 17:50:17 -0700 (PDT)
Date: Tue, 2 Aug 2016 09:55:15 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm/slab: Improve performance of gathering slabinfo stats
Message-ID: <20160802005514.GA14725@js1304-P5Q-DELUXE>
References: <1470096548-15095-1-git-send-email-aruna.ramakrishna@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1470096548-15095-1-git-send-email-aruna.ramakrishna@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aruna Ramakrishna <aruna.ramakrishna@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

Hello, Aruna.

On Mon, Aug 01, 2016 at 05:09:08PM -0700, Aruna Ramakrishna wrote:
> On large systems, when some slab caches grow to millions of objects (and
> many gigabytes), running 'cat /proc/slabinfo' can take up to 1-2 seconds.
> During this time, interrupts are disabled while walking the slab lists
> (slabs_full, slabs_partial, and slabs_free) for each node, and this
> sometimes causes timeouts in other drivers (for instance, Infiniband).

Okay.

> 
> This patch optimizes 'cat /proc/slabinfo' by maintaining slab counters to
> keep track of number of slabs per node, per cache. These counters are
> updated as slabs are created and destroyed. This avoids having to scan the

Your patch updates these counters not only when a slabs are created and
destroyed but also when object is allocated/freed from the slab. This
would hurt runtime performance.

> slab lists for gathering slabinfo stats, resulting in a dramatic
> performance improvement. We tested this after growing the dentry cache to
> 70GB, and the performance improved from 2s to 2ms.

Nice improvement. I can think of an altenative.

I guess that improvement of your change comes from skipping to iterate
n->slabs_full list. We can achieve it just with introducing only num_slabs.
num_slabs can be updated when a slabs are created and destroyed.

We can calculate num_slabs_full by following equation.

num_slabs_full = num_slabs - num_slabs_partial - num_slabs_free

Calculating both num_slabs_partial and num_slabs_free by iterating
n->slabs_XXX list would not take too much time.

How about this solution?

Thanks.

> 
> Signed-off-by: Aruna Ramakrishna <aruna.ramakrishna@oracle.com>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
> Note: this has been tested only on x86_64.
> 
>  mm/slab.c | 81 ++++++++++++++++++++++++++++++++++++++++++++++++---------------
>  mm/slab.h |  5 ++++
>  2 files changed, 67 insertions(+), 19 deletions(-)
> 
> diff --git a/mm/slab.c b/mm/slab.c
> index 09771ed..c205cd8 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -233,6 +233,11 @@ static void kmem_cache_node_init(struct kmem_cache_node *parent)
>  	spin_lock_init(&parent->list_lock);
>  	parent->free_objects = 0;
>  	parent->free_touched = 0;
> +	parent->num_slabs_partial = 0;
> +	parent->num_slabs_full = 0;
> +	parent->num_slabs_free = 0;
> +	parent->cache_grown = 0;
> +	parent->using_free_slab = 0;
>  }
>  
>  #define MAKE_LIST(cachep, listp, slab, nodeid)				\
> @@ -2331,6 +2336,7 @@ static int drain_freelist(struct kmem_cache *cache,
>  		 * to the cache.
>  		 */
>  		n->free_objects -= cache->num;
> +		n->num_slabs_free--;
>  		spin_unlock_irq(&n->list_lock);
>  		slab_destroy(cache, page);
>  		nr_freed++;
> @@ -2731,6 +2737,14 @@ static struct page *cache_grow_begin(struct kmem_cache *cachep,
>  	kasan_poison_slab(page);
>  	cache_init_objs(cachep, page);
>  
> +	spin_lock(&n->list_lock);
> +	/*
> +	 * Track the cache growth until the slabs lists and counters
> +	 * are adjusted.
> +	 */
> +	n->cache_grown++;
> +	spin_unlock(&n->list_lock);
> +
>  	if (gfpflags_allow_blocking(local_flags))
>  		local_irq_disable();
>  
> @@ -2758,12 +2772,14 @@ static void cache_grow_end(struct kmem_cache *cachep, struct page *page)
>  	n = get_node(cachep, page_to_nid(page));
>  
>  	spin_lock(&n->list_lock);
> -	if (!page->active)
> +	if (!page->active) {
>  		list_add_tail(&page->lru, &(n->slabs_free));
> -	else
> +		n->num_slabs_free++;
> +	} else
>  		fixup_slab_list(cachep, n, page, &list);
>  	STATS_INC_GROWN(cachep);
>  	n->free_objects += cachep->num - page->active;
> +	n->cache_grown--;
>  	spin_unlock(&n->list_lock);
>  
>  	fixup_objfreelist_debug(cachep, &list);
> @@ -2867,8 +2883,26 @@ static inline void fixup_slab_list(struct kmem_cache *cachep,
>  {
>  	/* move slabp to correct slabp list: */
>  	list_del(&page->lru);
> +	/*
> +	 * If the cache was not grown, then this slabp was deleted from a
> +	 * slabs_partial or a slabs_free list, and we decrement the counter
> +	 * for the appropriate list here. The flag using_free_slab is set
> +	 * whenever a slab from the slabs_free list is used for allocation.
> +	 * If set, we know that a slab was deleted from slabs_free and will be
> +	 * moved to slabs_partial (or slabs_full) later below. Otherwise,
> +	 * it was deleted from slabs_partial.
> +	 * If the cache was grown, slabp points to a new slab not present in
> +	 * any list - so we do not decrement any counters.
> +	 */
> +	if (!n->cache_grown) {
> +		if (n->using_free_slab)
> +			n->num_slabs_free--;
> +		else
> +			n->num_slabs_partial--;
> +	}
>  	if (page->active == cachep->num) {
>  		list_add(&page->lru, &n->slabs_full);
> +		n->num_slabs_full++;
>  		if (OBJFREELIST_SLAB(cachep)) {
>  #if DEBUG
>  			/* Poisoning will be done without holding the lock */
> @@ -2881,8 +2915,10 @@ static inline void fixup_slab_list(struct kmem_cache *cachep,
>  #endif
>  			page->freelist = NULL;
>  		}
> -	} else
> +	} else {
>  		list_add(&page->lru, &n->slabs_partial);
> +		n->num_slabs_partial++;
> +	}
>  }
>  
>  /* Try to find non-pfmemalloc slab if needed */
> @@ -2912,8 +2948,10 @@ static noinline struct page *get_valid_first_slab(struct kmem_cache_node *n,
>  		list_add_tail(&page->lru, &n->slabs_partial);
>  
>  	list_for_each_entry(page, &n->slabs_partial, lru) {
> -		if (!PageSlabPfmemalloc(page))
> +		if (!PageSlabPfmemalloc(page)) {
> +			n->using_free_slab = 0;
>  			return page;
> +		}
>  	}
>  
>  	list_for_each_entry(page, &n->slabs_free, lru) {
> @@ -2934,6 +2972,8 @@ static struct page *get_first_slab(struct kmem_cache_node *n, bool pfmemalloc)
>  		n->free_touched = 1;
>  		page = list_first_entry_or_null(&n->slabs_free,
>  				struct page, lru);
> +		if (page)
> +			n->using_free_slab = 1;
>  	}
>  
>  	if (sk_memalloc_socks())
> @@ -3431,20 +3471,27 @@ static void free_block(struct kmem_cache *cachep, void **objpp,
>  		objp = objpp[i];
>  
>  		page = virt_to_head_page(objp);
> +		if (page->active == cachep->num)
> +			n->num_slabs_full--;
> +		else
> +			n->num_slabs_partial--;
> +
>  		list_del(&page->lru);
>  		check_spinlock_acquired_node(cachep, node);
>  		slab_put_obj(cachep, page, objp);
>  		STATS_DEC_ACTIVE(cachep);
>  
>  		/* fixup slab chains */
> -		if (page->active == 0)
> +		if (page->active == 0) {
>  			list_add(&page->lru, &n->slabs_free);
> -		else {
> +			n->num_slabs_free++;
> +		} else {
>  			/* Unconditionally move a slab to the end of the
>  			 * partial list on free - maximum time for the
>  			 * other objects to be freed, too.
>  			 */
>  			list_add_tail(&page->lru, &n->slabs_partial);
> +			n->num_slabs_partial++;
>  		}
>  	}
>  
> @@ -3453,6 +3500,7 @@ static void free_block(struct kmem_cache *cachep, void **objpp,
>  
>  		page = list_last_entry(&n->slabs_free, struct page, lru);
>  		list_move(&page->lru, list);
> +		n->num_slabs_free--;
>  	}
>  }
>  
> @@ -4121,24 +4169,20 @@ void get_slabinfo(struct kmem_cache *cachep, struct slabinfo *sinfo)
>  		check_irq_on();
>  		spin_lock_irq(&n->list_lock);
>  
> -		list_for_each_entry(page, &n->slabs_full, lru) {
> -			if (page->active != cachep->num && !error)
> -				error = "slabs_full accounting error";
> -			active_objs += cachep->num;
> -			active_slabs++;
> -		}
> +		active_slabs += n->num_slabs_partial +
> +				n->num_slabs_full;
> +		num_slabs += n->num_slabs_free +
> +				n->num_slabs_partial +
> +				n->num_slabs_full;
> +
> +		active_objs += (n->num_slabs_full * cachep->num);
> +
>  		list_for_each_entry(page, &n->slabs_partial, lru) {
>  			if (page->active == cachep->num && !error)
>  				error = "slabs_partial accounting error";
>  			if (!page->active && !error)
>  				error = "slabs_partial accounting error";
>  			active_objs += page->active;
> -			active_slabs++;
> -		}
> -		list_for_each_entry(page, &n->slabs_free, lru) {
> -			if (page->active && !error)
> -				error = "slabs_free accounting error";
> -			num_slabs++;
>  		}
>  		free_objects += n->free_objects;
>  		if (n->shared)
> @@ -4146,7 +4190,6 @@ void get_slabinfo(struct kmem_cache *cachep, struct slabinfo *sinfo)
>  
>  		spin_unlock_irq(&n->list_lock);
>  	}
> -	num_slabs += active_slabs;
>  	num_objs = num_slabs * cachep->num;
>  	if (num_objs - active_objs != free_objects && !error)
>  		error = "free_objects accounting error";
> diff --git a/mm/slab.h b/mm/slab.h
> index 9653f2e..c0e8084 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -432,12 +432,17 @@ struct kmem_cache_node {
>  	struct list_head slabs_partial;	/* partial list first, better asm code */
>  	struct list_head slabs_full;
>  	struct list_head slabs_free;
> +	unsigned long num_slabs_partial;
> +	unsigned long num_slabs_full;
> +	unsigned long num_slabs_free;
>  	unsigned long free_objects;
>  	unsigned int free_limit;
>  	unsigned int colour_next;	/* Per-node cache coloring */
>  	struct array_cache *shared;	/* shared per node */
>  	struct alien_cache **alien;	/* on other nodes */
>  	unsigned long next_reap;	/* updated without locking */
> +	int cache_grown;
> +	bool using_free_slab;
>  	int free_touched;		/* updated without locking */
>  #endif
>  
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
