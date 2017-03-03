Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id AF45E6B0388
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 15:39:41 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id t184so139422562pgt.1
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 12:39:41 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 1si11578236plk.2.2017.03.03.12.39.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 12:39:40 -0800 (PST)
Date: Fri, 3 Mar 2017 12:39:20 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [LSF/MM TOPIC] Movable memory and reliable higher order
 allocations
Message-ID: <20170303203920.GR16328@bombadil.infradead.org>
References: <alpine.DEB.2.20.1702281526170.31946@east.gentwo.org>
 <20170228231733.GI16328@bombadil.infradead.org>
 <20170302041238.GM16328@bombadil.infradead.org>
 <alpine.DEB.2.20.1703021111350.31249@east.gentwo.org>
 <20170302205540.GQ16328@bombadil.infradead.org>
 <alpine.DEB.2.20.1703030915170.16721@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1703030915170.16721@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Jesper Dangaard Brouer <brouer@redhat.com>, riel@redhat.com, Mel Gorman <mel@csn.ul.ie>

On Fri, Mar 03, 2017 at 09:24:23AM -0600, Christoph Lameter wrote:
> > We may need to negotiate the API a little ;-)
> 
> Well lets continue the fun then.

It is a fun little dance!  It'd help if you posted your current code;
I'm trying to reason about what you're probably doing and why, and a
bit less guesswork would make it easier.

> > > Locks are held. Interrupts are disabled. No slab operations may be
> > > performed and any operations on the slab page will cause that the
> > > concurrent access to block.
> > >
> > > The callback must establish a stable reference to the slab objects.
> > > Meaning generally a additional refcount is added so that any free
> > > operations will not remove the object. This is required in order to ensure
> > > that free operations will not interfere with reclaim processing.
> >
> > I don't currently have a way to do that.  There is a refcount on the node,
> > but if somebody does an operation which causes the node to be removed
> > from the tree (something like splatting a huge page over the top of it),
> > we ignore the refcount and free the node.  However, since it's been in
> > the tree, we pass it to RCU to free, so if you hold the RCU read lock in
> > addition to your other locks, the xarray can satisfy your requirements
> > that the object not be handed back to slab.
> 
> We need a general solution here. Objects having a refcount is the common
> way to provide an existence guarantee. Holding rcu_locks in a
> function that performs slab operations or lenghty object inspection
> calling a variety of VM operations is not advisable.

Even if I had a refcount, it wouldn't solve your problem.  Look at
the dcache:

        if (!(dentry->d_flags & DCACHE_RCUACCESS))
                __d_free(&dentry->d_u.d_rcu);
        else
                call_rcu(&dentry->d_u.d_rcu, __d_free);

and the inode freeing routine is much the same:

        if (inode->i_sb->s_op->destroy_inode)
                inode->i_sb->s_op->destroy_inode(inode);
        else
                call_rcu(&inode->i_rcu, i_callback);

So all three of the most important reclaimable caches free their data
using RCU.  And once an object has gone onto the RCU lists, there's no
refcount that's going to avoid it being passed from RCU to the slab.
Your best bet for avoiding having somebody call kmem_cache_free() on
one of the objects in your list is to hold off RCU.

Of course, I now realise that taking the RCU read lock is not going
to help.  Your critical section will not pre-date all callers of RCU,
so we can have a situation like this:

CPU A		CPU B		CPU C
read_lock
get node
		spin_lock
		call_rcu
		spin_unlock
read stale data
				read_lock
				mark slab page as blocking
read_unlock
		kmem_cache_free()
				read_unlock

and CPU B is going to block in softirq context.  Nasty.  I also don't see
how to avoid it.  Unless by "block", you mean "will spin on slab_lock()",
which isn't too bad, I suppose.

> > > This is required to have a stable array of objects to work on. If the
> > > objects could be freed at any time then the objects could not be inspected
> > > for state nor could an array of pointers to the objects be passed on for
> > > future processing.
> >
> > If I can free some, but not all of the objects, is that worth doing,
> > or should I return NULL here?
> 
> The objects are all objects from the same slab page. If you cannot free
> one then the whole slab page must remain. It it advantageous to not free
> objects. The slab can then be used for more allocations and filled up
> again.

OK.  So how about we have the following functions:

bool can_free(void **objects, unsigned int nr);
void reclaim(void **objects, unsigned int nr);

I don't think the kmem_cache is actually useful to any of the callees.
And until we have a user, let's not complicate the interface with the
ability to pass a private data structure around -- again, i don't see
it being useful for dentries or inodes.

The callee can take references or whetever else is useful to mark
objects as being targetted for reclaim in 'can_free', but may not sleep,
and should not take a long time to execute (because we're potentially
delaying somebody in irq context).

In reclaim, anything goes, no locks are held by slab, kmem_cache_alloc
can be called.  When reclaim() returns, slab will evaluate the state
of the page and free it back to the page allocator if everything is
freed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
