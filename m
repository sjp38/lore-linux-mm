Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 568736B000D
	for <linux-mm@kvack.org>; Tue,  6 Feb 2018 10:34:07 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id a61so1784585pla.22
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 07:34:07 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 1-v6si1505327plp.678.2018.02.06.07.34.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Feb 2018 07:34:04 -0800 (PST)
Date: Tue, 6 Feb 2018 07:33:59 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [LSF/MM TOPIC] lru_lock scalability
Message-ID: <20180206153359.GA31089@bombadil.infradead.org>
References: <2a16be43-0757-d342-abfb-d4d043922da9@oracle.com>
 <20180201094431.GA20742@bombadil.infradead.org>
 <af831ebd-6acf-1f83-c531-39895ab2eddb@oracle.com>
 <20180202170003.GA16840@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180202170003.GA16840@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, steven.sistare@oracle.com, pasha.tatashin@oracle.com, yossi.lev@oracle.com, Dave.Dice@oracle.com, akpm@linux-foundation.org, mhocko@kernel.org, ldufour@linux.vnet.ibm.com, dave@stgolabs.net, khandual@linux.vnet.ibm.com, ak@linux.intel.com, mgorman@suse.de, Peter Zijlstra <peterz@infradead.org>

On Fri, Feb 02, 2018 at 09:00:03AM -0800, Matthew Wilcox wrote:
> On Thu, Feb 01, 2018 at 11:07:56PM -0500, Daniel Jordan wrote:
> > I looked through your latest XArray series (v6).  Am I understanding it correctly that a removal (xa_erase) is an exclusive operation within one XArray, i.e. that only one thread can do this at once?  Not sure how XQueue would implement removal though, so the answer might be different for it.
> 
> That's currently the case for the XArray, yes.  Peter Zijlstra wrote a
> paper over ten years ago for allowing multiple simultaneous page-cache
> writers.  https://www.kernel.org/doc/ols/2007/ols2007v2-pages-311-318.pdf
> 
> I'm not sure it's applicable to the current XArray which has grown other
> features, but it should be implementable for the XQueue.

I wrote a proposal ...


Scaling the XArray
==================

Building on Peter Zijlstra's paper about allowing simultaneous insertion
and deletion of pages from the page cache [1] I examine how the XArray
may be adapted to allow similar scalability.

First, CPUs now behave rather differently in terms of locking than
they did in 2007.  (Some) Intel CPUs now implement lock elision that
may make this technique counterproductive.  Second, it is generally a
bad idea to take a lock for a short period of time; we prefer batching
APIs where multiple operations are performed without releasing the lock
(generally 16 operations is the correct knee of the curve).  Third,
bouncing cachelines between CPUs costs rather more than taking a lock.
For the sake of argument, let's assume that we can find the space in
each xa_node for a spinlock, and call it the node_lock.

In terms of differences between the radix tree and the XArray,
the lock is now integrated into the struct xarray instead of being
allocated separately.  The RADIX_TREE_CONTEXT detailed in the paper is
a great parallel to the xa_state.  At the time the paper was written,
the concurrent page cache had not been integrated.

With all that in mind, let's analyse the current operations in the XArray
and see which might benefit from pushing the lock down to the leaf node.
Taking a lock in each node as we walk down the tree is going to result
in dirtying cache lines all the way down the tree.  But we can use the
RCU lock to protect ourselves as we walk all the way down the tree, and
only take a lock at the leaf node.  We'll dirty that cacheline anyway
when we modify the tree.

As noted in the original paper, some operations need to walk back up the
tree again, such as setting/clearing a tag.  For these rarer operations,
we can keep using the xa_lock (in the root of the array).  Unfortuantely,
storing a NULL pointer involves clearing tags, so those operations can't
be done in parallel.  That said, removing pages from the page cache is
rather less common than adding pages to the page cache, and they tend
to be removed in a batch, so this may not be a problem.  Storing NULL
may also require shrinking the tree which would also require the xa_lock.

When deleting a node, we'll take the xa_lock first (because in order to
delete a node, we need to be storing NULL), and then we will acquire the
node_lock from bottom to top, releasing each lock before acquiring the
one above it in the tree.  Since we will never acquire more than one
node_lock at a time, there is no lock ordering problem.  The xa_lock
nests above the node_lock in the locking hierarchy.

Expanding the tree is also going to require the xa_lock.  Fortunately,
we detect the need to grow the tree at the start of the walk, so we
can also acquire the xa_lock then.  When adding a new node to the tree
which is not at the root, we take the node_lock of the parent node.
That means we need to walk down the tree, see a NULL, take the node_lock,
re-check that it's NULL, and then allocate a new node (if it's not NULL,
we drop the node_lock and continue the walk).

Let's look at (a simplified version of) somewhere that takes the xa_lock
today and see how we might avoid it:

        do {
                xas_lock_irq(&xas);
                old = xas_create(&xas);
                if (xas_error(&xas))
                        goto unlock;
                if (old) {
                        xas_set_err(&xas, -EEXIST);
                        goto unlock;
                }
                xas_store(&xas, page);
unlock:
                xas_unlock_irq(&xas);
        } while (xas_nomem(&xas, gfp));

becomes:

	do {
		xas_maybe_lock_irq(&xas, page);
		old = xas_create(&xas);
		if (xas_error(&xas))
			goto unlock;
                if (old) {
                        xas_set_err(&xas, -EEXIST);
                        goto unlock;
                }
                xas_store(&xas, page);
unlock:
                xas_maybe_unlock_irq(&xas);
        } while (xas_nomem(&xas, gfp));

We can hide all the changes inside two new inline functions:

static inline void xas_maybe_lock_irq(struct xa_state *xas, void *entry)
{
	if (entry) {
		rcu_read_lock();
		xas_start(&xas);
		if (!xas_bounds(&xas))
			return;
	}

	xas_lock_irq(&xas);
	xas->locked = XAS_LOCKED_HEAD;
}

static inline void xas_maybe_unlock_irq(struct xa_state *xas)
{
	if (xas->locked & XAS_LOCKED_NODE)
		spin_unlock(&xas->xa_node->node_lock);
	if (xas->locked & XAS_LOCKED_HEAD)
		xas_unlock_irq(&xas);
	rcu_read_unlock();
	xas->locked = 0;
}

xas_create() will take the node_lock unless xas->locked ==
XAS_LOCKED_HEAD.  It will also verify that the xa_node has not been
removed from the tree.

The race condition I'm concerned with here is a tree with just one
non-NULL element at offset 12345678 and then a store of NULL to index
12345678 simultaneous with a store of not-NULL to index 12345677.
The first store takes the xa_lock, but the second store ignores the
lock and walks all the way down the tree to the root node, which the
first node is busy trying to delete.  Both stores will try to take
the node_lock in the leaf node; if the second store wins that race,
everything is fine as the first store will see the node is not empty
after it has stored NULL and it won't try to free any nodes.

If the first store wins the race, the second store will get the node_lock
and then see that node->parent indicates the node has been RCU-freed.
At this point, it should drop the node_lock, acquire the xa_lock and
restart from the top of the tree (allocating nodes all the way back
down again).  Since the first store was holding the xa_lock, the second
store will see only the results of the final store.

[1] https://www.kernel.org/doc/ols/2007/ols2007v2-pages-311-318.pdf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
