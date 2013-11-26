Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f51.google.com (mail-bk0-f51.google.com [209.85.214.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0D20C6B00A2
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 17:06:06 -0500 (EST)
Received: by mail-bk0-f51.google.com with SMTP id 6so2914346bkj.10
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 14:06:06 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id rm2si11356511bkb.96.2013.11.26.14.06.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 26 Nov 2013 14:06:05 -0800 (PST)
Date: Tue, 26 Nov 2013 17:05:17 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 9/9] mm: keep page cache radix tree nodes in check
Message-ID: <20131126220517.GH22729@cmpxchg.org>
References: <1385336308-27121-1-git-send-email-hannes@cmpxchg.org>
 <1385336308-27121-10-git-send-email-hannes@cmpxchg.org>
 <20131125161332.f9d5f37b6fbaba5a43403131@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131125161332.f9d5f37b6fbaba5a43403131@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Tejun Heo <tj@kernel.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Nov 25, 2013 at 04:13:32PM -0800, Andrew Morton wrote:
> On Sun, 24 Nov 2013 18:38:28 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > Previously, page cache radix tree nodes were freed after reclaim
> > emptied out their page pointers.  But now reclaim stores shadow
> > entries in their place, which are only reclaimed when the inodes
> > themselves are reclaimed.  This is problematic for bigger files that
> > are still in use after they have a significant amount of their cache
> > reclaimed, without any of those pages actually refaulting.  The shadow
> > entries will just sit there and waste memory.  In the worst case, the
> > shadow entries will accumulate until the machine runs out of memory.
> > 
> > To get this under control, the VM will track radix tree nodes
> > exclusively containing shadow entries on a per-NUMA node list.
> 
> Why per-node rather than a global list?

The radix tree nodes should always be allocated node-local, so it made
sense to string them up locally as well and prevent otherwise
independent workloads on separate nodes to contend for the same global
lock and list.

> >  A simple shrinker will reclaim these nodes on memory pressure.
> 
> Truncate needs to go off and massacre these things as well - some
> description of how that happens would be useful.

What do you mean?  Truncate operates on a range in the tree and
deletes these items the same way page entries are deleted.  It's a
regular tree deletion.  Only the shrinker is special because it
reaches into the tree coming from a tree node, not from the root and
an index.

> > A few things need to be stored in the radix tree node to implement the
> > shadow node LRU and allow tree deletions coming from the list:
> > 
> > 1. There is no index available that would describe the reverse path
> >    from the node up to the tree root, which is needed to perform a
> >    deletion.  To solve this, encode in each node its offset inside the
> >    parent.  This can be stored in the unused upper bits of the same
> >    member that stores the node's height at no extra space cost.
> > 
> > 2. The number of shadow entries needs to be counted in addition to the
> >    regular entries, to quickly detect when the node is ready to go to
> >    the shadow node LRU list.  The current entry count is an unsigned
> >    int but the maximum number of entries is 64, so a shadow counter
> >    can easily be stored in the unused upper bits.
> > 
> > 3. Tree modification needs the lock, which is located in the address
> >    space,
> 
> Presumably "the lock" == tree_lock.

Yes, will clarify.

> >    so store a backpointer to it.
> 
> <looks at the code>
> 
> "it" is the address_space, not tree_lock, yes?

Yes, the address space so we can get to both the lock and the tree
root.  Will clarify.

> >   The parent pointer is in a
> >    union with the 2-word rcu_head, so the backpointer comes at no
> >    extra cost as well.
> 
> So we have a shrinker walking backwards from radix-tree nodes and
> reaching up into address_spaces.  We need to take steps to prevent
> those address_spaces from getting shot down (reclaim, umount, truncate,
> etc) while we're doing this.  What's happening here?

Ah, now the question about truncate above makes more sense as well.
Teardown makes sure the node is unlinked from the LRU, so holding the
lru_lock while the node is on the LRU pins the whole address space and
keeps teardown from finishing.

Dave already said that the lru_lock time is too long, though, so I'll
have to change the reclaimer to use RCU.  radix_tree_node is already
RCU-freed.  Teardown can mark the node dead under the tree lock, while
the shrinker can optimistically can take the tree lock of a node under
RCU, then verify the node is still alive.

I'll rework this and document the lifetime management properly.

> > 4. The node needs to be linked to an LRU list, which requires a list
> >    head inside the node.  This does increase the size of the node, but
> >    it does not change the number of objects that fit into a slab page.
> >
> > ...
> >
> > --- a/include/linux/list_lru.h
> > +++ b/include/linux/list_lru.h
> > @@ -32,7 +32,7 @@ struct list_lru {
> >  };
> >  
> >  void list_lru_destroy(struct list_lru *lru);
> > -int list_lru_init(struct list_lru *lru);
> > +int list_lru_init(struct list_lru *lru, struct lock_class_key *key);
> 
> It's a bit of a shame to be adding overhead to non-lockdep kernels.  A
> few ifdefs could fix this.
> 
> Presumably this is being done to squish some lockdep warning you hit. 
> A comment at the list_lru_init() implementation site would be useful. 
> One which describes the warning and why it's OK to squish it.

Yes, the other users of list_lru have an IRQ-unsafe lru_lock, so I
added a separate class for the IRQ-safe version.

> >  struct radix_tree_node {
> > -	unsigned int	height;		/* Height from the bottom */
> > +	unsigned int	path;	/* Offset in parent & height from the bottom */
> >  	unsigned int	count;
> >  	union {
> > -		struct radix_tree_node *parent;	/* Used when ascending tree */
> > -		struct rcu_head	rcu_head;	/* Used when freeing node */
> > +		/* Used when ascending tree */
> > +		struct {
> > +			struct radix_tree_node *parent;
> > +			void *private;
> 
> Private to whom?  The radix-tree implementation?  The radix-tree caller?

The caller.  Isn't that a standard name?  page->private,
mapping->private*, etc.?  Anyway, will add a comment.

> 
> > +		};
> > +		/* Used when freeing node */
> > +		struct rcu_head	rcu_head;
> >  	};
> > +	struct list_head lru;
> 
> Locking for this list?

The list_lru lock.  I'll document this.

> >  	void __rcu	*slots[RADIX_TREE_MAP_SIZE];
> >  	unsigned long	tags[RADIX_TREE_MAX_TAGS][RADIX_TREE_TAG_LONGS];
> >  };
> >  
> >
> > ...
> >
> > +static unsigned long count_shadow_nodes(struct shrinker *shrinker,
> > +					struct shrink_control *sc)
> > +{
> > +	unsigned long count;
> > +
> > +	local_irq_disable();
> > +	count = list_lru_count_node(&workingset_shadow_nodes, sc->nid);
> > +	local_irq_enable();
> 
> I'm struggling with the local_irq_disable() here.  Presumably it's
> there to quash a lockdep warning, but page_cache_tree_delete() and
> friends can get away without the local_irq_disable().  Some more
> clarity here would be nice.

Yes, we are nesting the lru_lock inside the IRQ-safe
mapping->tree_lock, lockdep complains about that.

page_cache_tree_delete() and friends also disable IRQs by using
spin_lock_irq().

As I said in the email to Dave, it would be great to teach lockdep to
not complain because the deadlock scenario (irq tries to acquire lock
held in process context) is not possible in our case: the irq context
does not actually acquire the lru_lock.

> > +	return count;
> > +}
> > +
> > +#define NOIRQ_BATCH 32
> > +
> > +static enum lru_status shadow_lru_isolate(struct list_head *item,
> > +					  spinlock_t *lru_lock,
> > +					  void *arg)
> > +{
> > +	struct address_space *mapping;
> > +	struct radix_tree_node *node;
> > +	unsigned long *batch = arg;
> > +	unsigned int i;
> > +
> > +	node = container_of(item, struct radix_tree_node, lru);
> > +	mapping = node->private;
> > +
> > +	/* Don't disable IRQs for too long */
> > +	if (--(*batch) == 0) {
> > +		spin_unlock_irq(lru_lock);
> > +		*batch = NOIRQ_BATCH;
> > +		spin_lock_irq(lru_lock);
> > +		return LRU_RETRY;
> > +	}
> > +
> > +	/* Coming from the list, inverse the lock order */
> 
> "invert" ;)

Thanks :)

> > +	if (!spin_trylock(&mapping->tree_lock))
> > +		return LRU_SKIP;
> > +
> > +	/*
> > +	 * The nodes should only contain one or more shadow entries,
> > +	 * no pages, so we expect to be able to remove them all and
> > +	 * delete and free the empty node afterwards.
> > +	 */
> > +
> > +	BUG_ON(!node->count);
> > +	BUG_ON(node->count & RADIX_TREE_COUNT_MASK);
> > +
> > +	for (i = 0; i < RADIX_TREE_MAP_SIZE; i++) {
> > +		if (node->slots[i]) {
> > +			BUG_ON(!radix_tree_exceptional_entry(node->slots[i]));
> > +			node->slots[i] = NULL;
> > +			BUG_ON(node->count < (1U << RADIX_TREE_COUNT_SHIFT));
> > +			node->count -= 1U << RADIX_TREE_COUNT_SHIFT;
> > +			BUG_ON(!mapping->nrshadows);
> > +			mapping->nrshadows--;
> > +		}
> > +	}
> > +	list_del_init(&node->lru);
> > +	BUG_ON(node->count);
> > +	if (!__radix_tree_delete_node(&mapping->page_tree, node))
> > +		BUG();
> > +
> > +	spin_unlock(&mapping->tree_lock);
> > +
> > +	count_vm_event(WORKINGSET_NODES_RECLAIMED);
> > +
> > +	return LRU_REMOVED;
> > +}
> > +
> >
> > ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
