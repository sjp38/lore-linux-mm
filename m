Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E96F59000C2
	for <linux-mm@kvack.org>; Thu,  7 Jul 2011 15:04:13 -0400 (EDT)
Subject: Re: slub: [RFC] free slabs without holding locks.
From: Pekka Enberg <penberg@kernel.org>
In-Reply-To: <alpine.DEB.2.00.1106201612310.17524@router.home>
References: <alpine.DEB.2.00.1106201612310.17524@router.home>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Thu, 07 Jul 2011 22:04:09 +0300
Message-ID: <1310065449.21902.60.camel@jaguar>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, rientjes@google.com

On Mon, 2011-06-20 at 16:16 -0500, Christoph Lameter wrote:
> Just saw the slab lockdep problem. We can free from slub without holding
> any locks. I guess something similar can be done for slab but it would be
> more complicated given the nesting level of free_block(). Not sure if this
> brings us anything but it does not look like this is doing anything
> negative to the performance of the allocator.
> 
> 
> 
> Subject: slub: free slabs without holding locks.
> 
> There are two situations in which slub holds a lock while releasing
> pages:
> 
> 	A. During kmem_cache_shrink()
> 	B. During kmem_cache_close()
> 
> For both situations build a list while holding the lock and then
> release the pages later. Both functions are not performance critical.
> 
> After this patch all invocations of free operations are done without
> holding any locks.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Seems reasonable. David, would you mind taking a look at this?

> 
> ---
>  mm/slub.c |   49 +++++++++++++++++++++++++------------------------
>  1 file changed, 25 insertions(+), 24 deletions(-)
> 
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2011-06-20 15:23:38.000000000 -0500
> +++ linux-2.6/mm/slub.c	2011-06-20 16:11:44.572587454 -0500
> @@ -2657,18 +2657,22 @@ static void free_partial(struct kmem_cac
>  {
>  	unsigned long flags;
>  	struct page *page, *h;
> +	LIST_HEAD(empty);
> 
>  	spin_lock_irqsave(&n->list_lock, flags);
>  	list_for_each_entry_safe(page, h, &n->partial, lru) {
> -		if (!page->inuse) {
> -			__remove_partial(n, page);
> -			discard_slab(s, page);
> -		} else {
> -			list_slab_objects(s, page,
> -				"Objects remaining on kmem_cache_close()");
> -		}
> +		if (!page->inuse)
> +			list_move(&page->lru, &empty);
>  	}
>  	spin_unlock_irqrestore(&n->list_lock, flags);
> +
> +	list_for_each_entry_safe(page, h, &empty, lru)
> +		discard_slab(s, page);
> +
> +	if (!list_empty(&n->partial))
> +		list_for_each_entry(page, &n->partial, lru)
> +			list_slab_objects(s, page,
> +				"Objects remaining on kmem_cache_close()");
>  }
> 
>  /*
> @@ -2702,6 +2706,9 @@ void kmem_cache_destroy(struct kmem_cach
>  	s->refcount--;
>  	if (!s->refcount) {
>  		list_del(&s->list);
> +		sysfs_slab_remove(s);
> +		up_write(&slub_lock);
> +
>  		if (kmem_cache_close(s)) {
>  			printk(KERN_ERR "SLUB %s: %s called for cache that "
>  				"still has objects.\n", s->name, __func__);
> @@ -2709,9 +2716,9 @@ void kmem_cache_destroy(struct kmem_cach
>  		}
>  		if (s->flags & SLAB_DESTROY_BY_RCU)
>  			rcu_barrier();
> -		sysfs_slab_remove(s);
> -	}
> -	up_write(&slub_lock);
> +		kfree(s);
> +	} else
> +		up_write(&slub_lock);
>  }
>  EXPORT_SYMBOL(kmem_cache_destroy);
> 
> @@ -2993,29 +3000,23 @@ int kmem_cache_shrink(struct kmem_cache
>  		 * list_lock. page->inuse here is the upper limit.
>  		 */
>  		list_for_each_entry_safe(page, t, &n->partial, lru) {
> -			if (!page->inuse && slab_trylock(page)) {
> -				/*
> -				 * Must hold slab lock here because slab_free
> -				 * may have freed the last object and be
> -				 * waiting to release the slab.
> -				 */
> -				__remove_partial(n, page);
> -				slab_unlock(page);
> -				discard_slab(s, page);
> -			} else {
> -				list_move(&page->lru,
> -				slabs_by_inuse + page->inuse);
> -			}
> +			list_move(&page->lru, slabs_by_inuse + page->inuse);
> +			if (!page->inuse)
> +				n->nr_partial--;
>  		}
> 
>  		/*
>  		 * Rebuild the partial list with the slabs filled up most
>  		 * first and the least used slabs at the end.
>  		 */
> -		for (i = objects - 1; i >= 0; i--)
> +		for (i = objects - 1; i > 0; i--)

What's this hunk about?

>  			list_splice(slabs_by_inuse + i, n->partial.prev);
> 
>  		spin_unlock_irqrestore(&n->list_lock, flags);
> +
> +		/* Release empty slabs */
> +		list_for_each_entry_safe(page, t, slabs_by_inuse, lru)
> +			discard_slab(s, page);
>  	}
> 
>  	kfree(slabs_by_inuse);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
