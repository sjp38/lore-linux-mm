Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 727D96B004A
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 10:20:32 -0400 (EDT)
Date: Thu, 14 Jul 2011 09:20:28 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: slub: [RFC] free slabs without holding locks.
In-Reply-To: <alpine.DEB.2.00.1107131710050.4557@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1107140919050.30512@router.home>
References: <alpine.DEB.2.00.1106201612310.17524@router.home> <1310065449.21902.60.camel@jaguar> <alpine.DEB.2.00.1107131710050.4557@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org

On Wed, 13 Jul 2011, David Rientjes wrote:

> > >  	spin_unlock_irqrestore(&n->list_lock, flags);
> > > +
> > > +	list_for_each_entry_safe(page, h, &empty, lru)
> > > +		discard_slab(s, page);
> > > +
> > > +	if (!list_empty(&n->partial))
> > > +		list_for_each_entry(page, &n->partial, lru)
> > > +			list_slab_objects(s, page,
> > > +				"Objects remaining on kmem_cache_close()");
> > >  }
> > >
> > >  /*
>
> The last iteration to check for any pages remaining on the partial list is
> not safe because partial list manipulation is protected by list_lock.
> That needs to be fixed by testing for page->inuse during the iteration
> while still holding the lock and dropping the later iteration all
> together.

At this point no other process can be accessing the slab anymore. No need
for the list_lock

> > > @@ -2709,9 +2716,9 @@ void kmem_cache_destroy(struct kmem_cach
> > >  		}
> > >  		if (s->flags & SLAB_DESTROY_BY_RCU)
> > >  			rcu_barrier();
> > > -		sysfs_slab_remove(s);
> > > -	}
> > > -	up_write(&slub_lock);
> > > +		kfree(s);
>
> Why the new kfree() here?  If the refcount is 0, then this should be
> handled when the sysfs entry is released regardless of whether
> sysfs_slab_remove() uses the CONFIG_SYSFS variant or not.  If kfree(s)
> were needed here, we'd be leaking s->name as well.

Right. I will fix that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
