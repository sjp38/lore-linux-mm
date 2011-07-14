Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 135A56B004A
	for <linux-mm@kvack.org>; Wed, 13 Jul 2011 20:25:11 -0400 (EDT)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id p6E0P7Bs026086
	for <linux-mm@kvack.org>; Wed, 13 Jul 2011 17:25:07 -0700
Received: from pvc21 (pvc21.prod.google.com [10.241.209.149])
	by kpbe13.cbf.corp.google.com with ESMTP id p6E0OxZM001778
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 13 Jul 2011 17:25:05 -0700
Received: by pvc21 with SMTP id 21so9151814pvc.11
        for <linux-mm@kvack.org>; Wed, 13 Jul 2011 17:25:05 -0700 (PDT)
Date: Wed, 13 Jul 2011 17:25:04 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: slub: [RFC] free slabs without holding locks.
In-Reply-To: <1310065449.21902.60.camel@jaguar>
Message-ID: <alpine.DEB.2.00.1107131710050.4557@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1106201612310.17524@router.home> <1310065449.21902.60.camel@jaguar>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org

On Thu, 7 Jul 2011, Pekka Enberg wrote:

> > Just saw the slab lockdep problem.

Is the lockdep output available for inclusion in the changelog?

> > We can free from slub without holding
> > any locks. I guess something similar can be done for slab but it would be
> > more complicated given the nesting level of free_block(). Not sure if this
> > brings us anything but it does not look like this is doing anything
> > negative to the performance of the allocator.
> > 
> > 
> > 
> > Subject: slub: free slabs without holding locks.
> > 
> > There are two situations in which slub holds a lock while releasing
> > pages:
> > 
> > 	A. During kmem_cache_shrink()
> > 	B. During kmem_cache_close()
> > 
> > For both situations build a list while holding the lock and then
> > release the pages later. Both functions are not performance critical.
> > 
> > After this patch all invocations of free operations are done without
> > holding any locks.
> > 
> > Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> Seems reasonable. David, would you mind taking a look at this?
> 

Sorry for the delay!

> > 
> > ---
> >  mm/slub.c |   49 +++++++++++++++++++++++++------------------------
> >  1 file changed, 25 insertions(+), 24 deletions(-)
> > 
> > Index: linux-2.6/mm/slub.c
> > ===================================================================
> > --- linux-2.6.orig/mm/slub.c	2011-06-20 15:23:38.000000000 -0500
> > +++ linux-2.6/mm/slub.c	2011-06-20 16:11:44.572587454 -0500
> > @@ -2657,18 +2657,22 @@ static void free_partial(struct kmem_cac
> >  {
> >  	unsigned long flags;
> >  	struct page *page, *h;
> > +	LIST_HEAD(empty);
> > 
> >  	spin_lock_irqsave(&n->list_lock, flags);
> >  	list_for_each_entry_safe(page, h, &n->partial, lru) {
> > -		if (!page->inuse) {
> > -			__remove_partial(n, page);
> > -			discard_slab(s, page);
> > -		} else {
> > -			list_slab_objects(s, page,
> > -				"Objects remaining on kmem_cache_close()");
> > -		}
> > +		if (!page->inuse)
> > +			list_move(&page->lru, &empty);
> >  	}
> >  	spin_unlock_irqrestore(&n->list_lock, flags);
> > +
> > +	list_for_each_entry_safe(page, h, &empty, lru)
> > +		discard_slab(s, page);
> > +
> > +	if (!list_empty(&n->partial))
> > +		list_for_each_entry(page, &n->partial, lru)
> > +			list_slab_objects(s, page,
> > +				"Objects remaining on kmem_cache_close()");
> >  }
> > 
> >  /*

The last iteration to check for any pages remaining on the partial list is 
not safe because partial list manipulation is protected by list_lock.  
That needs to be fixed by testing for page->inuse during the iteration 
while still holding the lock and dropping the later iteration all 
together.

> > @@ -2702,6 +2706,9 @@ void kmem_cache_destroy(struct kmem_cach
> >  	s->refcount--;
> >  	if (!s->refcount) {
> >  		list_del(&s->list);
> > +		sysfs_slab_remove(s);
> > +		up_write(&slub_lock);
> > +
> >  		if (kmem_cache_close(s)) {
> >  			printk(KERN_ERR "SLUB %s: %s called for cache that "
> >  				"still has objects.\n", s->name, __func__);
> > @@ -2709,9 +2716,9 @@ void kmem_cache_destroy(struct kmem_cach
> >  		}
> >  		if (s->flags & SLAB_DESTROY_BY_RCU)
> >  			rcu_barrier();
> > -		sysfs_slab_remove(s);
> > -	}
> > -	up_write(&slub_lock);
> > +		kfree(s);

Why the new kfree() here?  If the refcount is 0, then this should be 
handled when the sysfs entry is released regardless of whether 
sysfs_slab_remove() uses the CONFIG_SYSFS variant or not.  If kfree(s) 
were needed here, we'd be leaking s->name as well.

> > +	} else
> > +		up_write(&slub_lock);
> >  }
> >  EXPORT_SYMBOL(kmem_cache_destroy);
> > 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
