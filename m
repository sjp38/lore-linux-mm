Date: Mon, 21 May 2007 15:10:39 +0100
Subject: Re: [patch 02/10] SLUB: slab defragmentation and kmem_cache_vacate
Message-ID: <20070521141039.GA18474@skynet.ie>
References: <20070518181040.465335396@sgi.com> <20070518181119.062736299@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20070518181119.062736299@sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On (18/05/07 11:10), clameter@sgi.com didst pronounce:
> Slab defragmentation occurs when the slabs are shrunk (after inode, dentry
> shrinkers have been run from the reclaim code) or when a manual shrinking
> is requested via slabinfo. During the shrink operation SLUB will generate a
> list of partially populated slabs sorted by the number of objects in use.
> 
> We extract pages off that list that are only filled less than a quarter and
> attempt to motivate the users of those slabs to either remove the objects
> or move the objects.
> 

I know I brought up this "less than a quarter" thing before and I
haven't thought of a better alternative. However, it occurs to be that
shrink_slab() is called when there is awareness of a reclaim priority.
It may be worth passing that down so that the fraction of candidates
pages is calculated based on priority.

That said..... where is kmem_cache_shrink() ever called? The freeing of
slab pages seems to be indirect these days. Way back,
kmem_cache_shrink() used to be called directly but I'm not sure where it
happens now.

> Targeted reclaim allows to target a single slab for reclaim. This is done by
> calling
> 
> kmem_cache_vacate(page);
> 
> It will return 1 on success, 0 if the operation failed.
> 
> 
> In order for a slabcache to support defragmentation a couple of functions
> must be defined via kmem_cache_ops. These are
> 
> void *get(struct kmem_cache *s, int nr, void **objects)
> 
> 	Must obtain a reference to the listed objects. SLUB guarantees that
> 	the objects are still allocated. However, other threads may be blocked
> 	in slab_free attempting to free objects in the slab. These may succeed
> 	as soon as get() returns to the slab allocator. The function must
> 	be able to detect the situation and void the attempts to handle such
> 	objects (by for example voiding the corresponding entry in the objects
> 	array).
> 
> 	No slab operations may be performed in get_reference(). Interrupts
> 	are disabled. What can be done is very limited. The slab lock
> 	for the page with the object is taken. Any attempt to perform a slab
> 	operation may lead to a deadlock.
> 
> 	get() returns a private pointer that is passed to kick. Should we
> 	be unable to obtain all references then that pointer may indicate
> 	to the kick() function that it should not attempt any object removal
> 	or move but simply remove the reference counts.
> 

Much clearer than before.

> void kick(struct kmem_cache *, int nr, void **objects, void *get_result)
> 
> 	After SLUB has established references to the objects in a
> 	slab it will drop all locks and then use kick() to move objects out
> 	of the slab. The existence of the object is guaranteed by virtue of
> 	the earlier obtained references via get(). The callback may perform
> 	any slab operation since no locks are held at the time of call.
> 
> 	The callback should remove the object from the slab in some way. This
> 	may be accomplished by reclaiming the object and then running
> 	kmem_cache_free() or reallocating it and then running
> 	kmem_cache_free(). Reallocation is advantageous because the partial
> 	slabs were just sorted to have the partial slabs with the most objects
> 	first. Allocation is likely to result in filling up a slab so that
> 	it can be removed from the partial list.
> 
> 	Kick() does not return a result. SLUB will check the number of
> 	remaining objects in the slab. If all objects were removed then
> 	we know that the operation was successful.
> 

Again, much clearer.

> If a kmem_cache_vacate on a page fails then the slab has usually a pretty
> low usage ratio. Go through the slab and resequence the freelist so that
> object addresses increase as we allocate objects. This will trigger the
> cacheline prefetcher when we start allocating from the slab again and
> thereby increase allocations speed.
> 

Nice idea.

> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> ---
>  include/linux/slab.h |   31 +++++
>  mm/slab.c            |    9 +
>  mm/slob.c            |    9 +
>  mm/slub.c            |  264 +++++++++++++++++++++++++++++++++++++++++++++++++--
>  4 files changed, 303 insertions(+), 10 deletions(-)
> 
> Index: slub/include/linux/slab.h
> ===================================================================
> --- slub.orig/include/linux/slab.h	2007-05-18 00:13:39.000000000 -0700
> +++ slub/include/linux/slab.h	2007-05-18 00:13:40.000000000 -0700
> @@ -39,6 +39,36 @@ void __init kmem_cache_init(void);
>  int slab_is_available(void);
>  
>  struct kmem_cache_ops {
> +	/*
> +	 * Called with slab lock held and interrupts disabled.
> +	 * No slab operation may be performed.
> +	 *
> +	 * Parameters passed are the number of objects to process
> +	 * and a an array of pointers to objects for which we
> +	 * need references.
> +	 *

s/a an/an/

> +	 * Returns a pointer that is passed to the kick function.
> +	 * If all objects cannot be moved then the pointer may
> +	 * indicate that this wont work and then kick can simply
> +	 * remove the references that were already obtained.
> +	 *
> +	 * The array passed to get() is also passed to kick(). The
> +	 * function may remove objects by setting array elements to NULL.
> +	 */
> +	void *(*get)(struct kmem_cache *, int nr, void **);
> +
> +	/*
> +	 * Called with no locks held and interrupts enabled.
> +	 * Any operation may be performed in kick().
> +	 *
> +	 * Parameters passed are the number of objects in the array,
> +	 * the array of pointers to the objects and the pointer
> +	 * returned by get().
> +	 *
> +	 * Success is checked by examining the number of remaining
> +	 * objects in the slab.
> +	 */
> +	void (*kick)(struct kmem_cache *, int nr, void **, void *private);
>  };
>  
>  struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
> @@ -53,6 +83,7 @@ void kmem_cache_free(struct kmem_cache *
>  unsigned int kmem_cache_size(struct kmem_cache *);
>  const char *kmem_cache_name(struct kmem_cache *);
>  int kmem_ptr_validate(struct kmem_cache *cachep, const void *ptr);
> +int kmem_cache_vacate(struct page *);
>  
>  /*
>   * Please use this macro to create slab caches. Simply specify the
> Index: slub/mm/slub.c
> ===================================================================
> --- slub.orig/mm/slub.c	2007-05-18 00:13:39.000000000 -0700
> +++ slub/mm/slub.c	2007-05-18 09:55:47.000000000 -0700
> @@ -1043,12 +1043,11 @@ static struct page *new_slab(struct kmem
>  	n = get_node(s, page_to_nid(page));
>  	if (n)
>  		atomic_long_inc(&n->nr_slabs);
> +
> +	page->inuse = 0;
> +	page->lockless_freelist = NULL;
>  	page->offset = s->offset / sizeof(void *);
>  	page->slab = s;
> -	page->flags |= 1 << PG_slab;
> -	if (s->flags & (SLAB_DEBUG_FREE | SLAB_RED_ZONE | SLAB_POISON |
> -			SLAB_STORE_USER | SLAB_TRACE))
> -		SetSlabDebug(page);
>  
>  	start = page_address(page);
>  	end = start + s->objects * s->size;
> @@ -1066,11 +1065,20 @@ static struct page *new_slab(struct kmem
>  	set_freepointer(s, last, NULL);
>  
>  	page->freelist = start;
> -	page->lockless_freelist = NULL;
> -	page->inuse = 0;
> -out:
> -	if (flags & __GFP_WAIT)
> -		local_irq_disable();
> +
> +	/*
> +	 * page->inuse must be 0 when PageSlab(page) becomes
> +	 * true so that defrag knows that this slab is not in use.
> +	 */
> +	smp_wmb();
> +	__SetPageSlab(page);
> +	if (s->flags & (SLAB_DEBUG_FREE | SLAB_RED_ZONE | SLAB_POISON |
> +			SLAB_STORE_USER | SLAB_TRACE))
> +		SetSlabDebug(page);
> +
> + out:
> + 	if (flags & __GFP_WAIT)
> + 		local_irq_disable();
>  	return page;
>  }
>  
> @@ -2323,6 +2331,191 @@ void kfree(const void *x)
>  EXPORT_SYMBOL(kfree);
>  
>  /*
> + * Order the freelist so that addresses increase as object are allocated.
> + * This is useful to trigger the cpu cacheline prefetching logic.
> + */

makes sense. However, it occurs to me that maybe this should be a
separate patch so it can be measured to be sure. It makes sense though.

> +void resequence_freelist(struct kmem_cache *s, struct page *page)
> +{
> +	void *p;
> +	void *last;
> +	void *addr = page_address(page);
> +	DECLARE_BITMAP(map, s->objects);
> +
> +	bitmap_zero(map, s->objects);
> +
> +	/* Figure out which objects are on the freelist */
> +	for_each_free_object(p, s, page->freelist)
> +		set_bit(slab_index(p, s, addr), map);
> +
> +	last = NULL;
> +	for_each_object(p, s, addr)
> +		if (test_bit(slab_index(p, s, addr), map)) {
> +			if (last)
> +				set_freepointer(s, last, p);
> +			else
> +				page->freelist = p;
> +			last = p;
> +		}
> +
> +	if (last)
> +		set_freepointer(s, last, NULL);
> +	else
> +		page->freelist = NULL;
> +}
> +
> +/*
> + * Vacate all objects in the given slab.
> + *
> + * Slab must be locked and frozen. Interrupts are disabled (flags must
> + * be passed).
> + *

It may not hurt to have a VM_BUG_ON() if interrupts are still enabled when
this is called

> + * Will drop and regain and drop the slab lock. At the end the slab will
> + * either be freed or returned to the partial lists.
> + *
> + * Returns the number of remaining objects
> + */
> +static int __kmem_cache_vacate(struct kmem_cache *s,
> +		struct page *page, unsigned long flags, void **vector)
> +{
> +	void *p;
> +	void *addr = page_address(page);
> +	DECLARE_BITMAP(map, s->objects);
> +	int leftover;
> +	int objects;
> +	void *private;
> +
> +	if (!page->inuse)
> +		goto out;
> +
> +	/* Determine used objects */
> +	bitmap_fill(map, s->objects);
> +	for_each_free_object(p, s, page->freelist)
> +		__clear_bit(slab_index(p, s, addr), map);
> +
> +	objects = 0;
> +	memset(vector, 0, s->objects * sizeof(void **));
> +	for_each_object(p, s, addr) {
> +		if (test_bit(slab_index(p, s, addr), map))
> +			vector[objects++] = p;
> +	}
> +
> +	private = s->ops->get(s, objects, vector);
> +
> +	/*
> +	 * Got references. Now we can drop the slab lock. The slab
> +	 * is frozen so it cannot vanish from under us nor will
> +	 * allocations be performed on the slab. However, unlocking the
> +	 * slab will allow concurrent slab_frees to proceed.
> +	 */
> +	slab_unlock(page);
> +	local_irq_restore(flags);

I recognise that you want to restore interrupts as early as possible but
it should be noted somewhere that kmem_cache_vacate() disables
interrupts and __kmem_cache_vacate() enabled them again. I had to go
searching to see where interrupts are enabled again.

Maybe even a slab_lock_irq() and slab_unlock_irq() would clarify things
a little.

> +
> +	/*
> +	 * Perform the KICK callbacks to remove the objects.
> +	 */
> +	s->ops->kick(s, objects, vector, private);
> +
> +	local_irq_save(flags);
> +	slab_lock(page);
> +out:
> +	/*
> +	 * Check the result and unfreeze the slab
> +	 */
> +	leftover = page->inuse;
> +	if (leftover > 0)
> +		/*
> +		 * Cannot free. Lets at least optimize the freelist. We have
> +		 * likely touched all the cachelines with the free pointers
> +		 * already so it is cheap to do here.
> +		 */
> +		resequence_freelist(s, page);
> +	unfreeze_slab(s, page);
> +	local_irq_restore(flags);
> +	return leftover;
> +}
> +
> +/*
> + * Get a page off a list and freeze it. Must be holding slab lock.
> + */
> +static void freeze_from_list(struct kmem_cache *s, struct page *page)
> +{
> +	if (page->inuse < s->objects)
> +		remove_partial(s, page);
> +	else if (s->flags & SLAB_STORE_USER)
> +		remove_full(s, page);
> +	SetSlabFrozen(page);
> +}
> +
> +/*
> + * Attempt to free objects in a page. Return 1 if succesful.
> + */
> +int kmem_cache_vacate(struct page *page)
> +{
> +	unsigned long flags;
> +	struct kmem_cache *s;
> +	int vacated = 0;
> +	void **vector = NULL;
> +
> +	/*
> +	 * Get a reference to the page. Return if its freed or being freed.
> +	 * This is necessary to make sure that the page does not vanish
> +	 * from under us before we are able to check the result.
> +	 */
> +	if (!get_page_unless_zero(page))
> +		return 0;
> +
> +	if (!PageSlab(page))
> +		goto out;
> +
> +	s = page->slab;
> +	if (!s)
> +		goto out;
> +
> +	vector = kmalloc(s->objects * sizeof(void *), GFP_KERNEL);
> +	if (!vector)
> +		return 0;

Is it worth logging this event, returning -ENOMEM or something so that
callers are aware of why kmem_cache_vacate() failed in this instance?

Also.. we have called get_page_unless_zero() but if we are out of memory
here, where have we called put_page()? Maybe we should be "goto out"
here with a

if (vector)
	kfree(vector);

> +
> +	local_irq_save(flags);
> +	/*
> +	 * The implicit memory barrier in slab_lock guarantees that page->inuse
> +	 * is loaded after PageSlab(page) has been established to be true. This is
> +	 * only revelant for a  newly created slab.
> +	 */
> +	slab_lock(page);
> +
> +	/*
> +	 * We may now have locked a page that may be in various stages of
> +	 * being freed. If the PageSlab bit is off then we have already
> +	 * reached the page allocator. If page->inuse is zero then we are
> +	 * in SLUB but freeing or allocating the page.
> +	 * page->inuse is never modified without the slab lock held.
> +	 *
> +	 * Also abort if the page happens to be already frozen. If its
> +	 * frozen then a concurrent vacate may be in progress.
> +	 */
> +	if (!PageSlab(page) || SlabFrozen(page) || !page->inuse)
> +		goto out_locked;
> +
> +	/*
> +	 * We are holding a lock on a slab page and all operations on the
> +	 * slab are blocking.
> +	 */
> +	if (!s->ops->get || !s->ops->kick)
> +		goto out_locked;
> +	freeze_from_list(s, page);
> +	vacated = __kmem_cache_vacate(s, page, flags, vector) == 0;

That is a little funky looking. This may be nicer;

vacated = __kmem_cache_vacate(s, page, flags, vector);
out:
....
return vacated == 0;

> +out:
> +	put_page(page);
> +	kfree(vector);
> +	return vacated;
> +out_locked:
> +	slab_unlock(page);
> +	local_irq_restore(flags);
> +	goto out;
> +
> +}
> +
> +/*
>   * kmem_cache_shrink removes empty slabs from the partial lists and sorts
>   * the remaining slabs by the number of items in use. The slabs with the
>   * most items in use come first. New allocations will then fill those up
> @@ -2337,11 +2530,12 @@ int kmem_cache_shrink(struct kmem_cache 
>  	int node;
>  	int i;
>  	struct kmem_cache_node *n;
> -	struct page *page;
> +	struct page *page, *page2;
>  	struct page *t;
>  	struct list_head *slabs_by_inuse =
>  		kmalloc(sizeof(struct list_head) * s->objects, GFP_KERNEL);
>  	unsigned long flags;
> +	LIST_HEAD(zaplist);
>  
>  	if (!slabs_by_inuse)
>  		return -ENOMEM;
> @@ -2392,8 +2586,44 @@ int kmem_cache_shrink(struct kmem_cache 
>  		for (i = s->objects - 1; i >= 0; i--)
>  			list_splice(slabs_by_inuse + i, n->partial.prev);
>  
> +		/*
> +		 * If we have no functions available to defragment the slabs
> +		 * then we are done.
> +		 */
> +		if (!s->ops->get || !s->ops->kick)
> +			goto out;
> +
> +		/* Take objects with just a few objects off the tail */
> +		while (n->nr_partial > MAX_PARTIAL) {
> +			page = container_of(n->partial.prev, struct page, lru);
> +
> +			/*
> +			 * We are holding the list_lock so we can only
> +			 * trylock the slab
> +			 */
> +			if (page->inuse > s->objects / 4)
> +				break;
> +
> +			if (!slab_trylock(page))
> +				break;
> +
> +			list_move_tail(&page->lru, &zaplist);
> +			n->nr_partial--;
> +			SetSlabFrozen(page);
> +			slab_unlock(page);
> +		}
>  	out:
>  		spin_unlock_irqrestore(&n->list_lock, flags);
> +
> +		/* Now we can free objects in the slabs on the zaplist */
> +		list_for_each_entry_safe(page, page2, &zaplist, lru) {
> +			unsigned long flags;
> +
> +			local_irq_save(flags);
> +			slab_lock(page);
> +			__kmem_cache_vacate(s, page, flags,
> +					(void **)slabs_by_inuse);
> +		}
>  	}
>  
>  	kfree(slabs_by_inuse);
> @@ -3229,6 +3459,20 @@ static ssize_t ops_show(struct kmem_cach
>  		x += sprint_symbol(buf + x, (unsigned long)s->ctor);
>  		x += sprintf(buf + x, "\n");
>  	}
> +
> +	if (s->ops->get) {
> +		x += sprintf(buf + x, "get : ");
> +		x += sprint_symbol(buf + x,
> +				(unsigned long)s->ops->get);
> +		x += sprintf(buf + x, "\n");
> +	}
> +
> +	if (s->ops->kick) {
> +		x += sprintf(buf + x, "kick : ");
> +		x += sprint_symbol(buf + x,
> +				(unsigned long)s->ops->kick);
> +		x += sprintf(buf + x, "\n");
> +	}
>  	return x;
>  }
>  SLAB_ATTR_RO(ops);
> Index: slub/mm/slab.c
> ===================================================================
> --- slub.orig/mm/slab.c	2007-05-18 00:13:39.000000000 -0700
> +++ slub/mm/slab.c	2007-05-18 00:13:40.000000000 -0700
> @@ -2516,6 +2516,15 @@ int kmem_cache_shrink(struct kmem_cache 
>  }
>  EXPORT_SYMBOL(kmem_cache_shrink);
>  
> +/*
> + * SLAB does not support slab defragmentation
> + */
> +int kmem_cache_vacate(struct page *page)
> +{
> +	return 0;
> +}
> +EXPORT_SYMBOL(kmem_cache_vacate);
> +
>  /**
>   * kmem_cache_destroy - delete a cache
>   * @cachep: the cache to destroy
> Index: slub/mm/slob.c
> ===================================================================
> --- slub.orig/mm/slob.c	2007-05-18 00:13:39.000000000 -0700
> +++ slub/mm/slob.c	2007-05-18 00:13:40.000000000 -0700
> @@ -394,6 +394,15 @@ int kmem_cache_shrink(struct kmem_cache 
>  }
>  EXPORT_SYMBOL(kmem_cache_shrink);
>  
> +/*
> + * SLOB does not support slab defragmentation
> + */
> +int kmem_cache_vacate(struct page *page)
> +{
> +	return 0;
> +}
> +EXPORT_SYMBOL(kmem_cache_vacate);
> +
>  int kmem_ptr_validate(struct kmem_cache *a, const void *b)
>  {
>  	return 0;
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
