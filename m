Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f41.google.com (mail-bk0-f41.google.com [209.85.214.41])
	by kanga.kvack.org (Postfix) with ESMTP id C34D36B0035
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 18:18:35 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id na10so423141bkb.0
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 15:18:35 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id yk3si2623188bkb.71.2014.01.20.15.18.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 20 Jan 2014 15:18:34 -0800 (PST)
Date: Mon, 20 Jan 2014 18:17:37 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 9/9] mm: keep page cache radix tree nodes in check
Message-ID: <20140120231737.GS6963@cmpxchg.org>
References: <1389377443-11755-1-git-send-email-hannes@cmpxchg.org>
 <1389377443-11755-10-git-send-email-hannes@cmpxchg.org>
 <20140117000517.GB18112@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140117000517.GB18112@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Bob Liu <bob.liu@oracle.com>, Christoph Hellwig <hch@infradead.org>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>, Metin Doslu <metin@citusdata.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Ozgun Erdogan <ozgun@citusdata.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Roman Gushchin <klamm@yandex-team.ru>, Ryan Mallon <rmallon@gmail.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Jan 17, 2014 at 11:05:17AM +1100, Dave Chinner wrote:
> On Fri, Jan 10, 2014 at 01:10:43PM -0500, Johannes Weiner wrote:
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
> > Per-NUMA rather than global because we expect the radix tree nodes
> > themselves to be allocated node-locally and we want to reduce
> > cross-node references of otherwise independent cache workloads.  A
> > simple shrinker will then reclaim these nodes on memory pressure.
> > 
> > A few things need to be stored in the radix tree node to implement the
> > shadow node LRU and allow tree deletions coming from the list:
> 
> Just a couple of things with the list_lru interfaces.
> 
> ....
> > @@ -123,9 +129,39 @@ static void page_cache_tree_delete(struct address_space *mapping,
> >  		 * same time and miss a shadow entry.
> >  		 */
> >  		smp_wmb();
> > -	} else
> > -		radix_tree_delete(&mapping->page_tree, page->index);
> > +	}
> >  	mapping->nrpages--;
> > +
> > +	if (!node) {
> > +		/* Clear direct pointer tags in root node */
> > +		mapping->page_tree.gfp_mask &= __GFP_BITS_MASK;
> > +		radix_tree_replace_slot(slot, shadow);
> > +		return;
> > +	}
> > +
> > +	/* Clear tree tags for the removed page */
> > +	index = page->index;
> > +	offset = index & RADIX_TREE_MAP_MASK;
> > +	for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++) {
> > +		if (test_bit(offset, node->tags[tag]))
> > +			radix_tree_tag_clear(&mapping->page_tree, index, tag);
> > +	}
> > +
> > +	/* Delete page, swap shadow entry */
> > +	radix_tree_replace_slot(slot, shadow);
> > +	node->count--;
> > +	if (shadow)
> > +		node->count += 1U << RADIX_TREE_COUNT_SHIFT;
> > +	else
> > +		if (__radix_tree_delete_node(&mapping->page_tree, node))
> > +			return;
> > +
> > +	/* Only shadow entries in there, keep track of this node */
> > +	if (!(node->count & RADIX_TREE_COUNT_MASK) &&
> > +	    list_empty(&node->private_list)) {
> > +		node->private_data = mapping;
> > +		list_lru_add(&workingset_shadow_nodes, &node->private_list);
> > +	}
> 
> You can't do this list_empty(&node->private_list) check safely
> externally to the list_lru code - only time that entry can be
> checked safely is under the LRU list locks. This is the reason that
> list_lru_add/list_lru_del return a boolean to indicate is the object
> was added/removed from the list - they do this list_empty() check
> internally. i.e. the correct, safe way to do conditionally update
> state iff the object was added to the LRU is:
> 
> 	if (!(node->count & RADIX_TREE_COUNT_MASK)) {
> 		if (list_lru_add(&workingset_shadow_nodes, &node->private_list))
> 			node->private_data = mapping;
> 	}
> 
> > +	radix_tree_replace_slot(slot, page);
> > +	mapping->nrpages++;
> > +	if (node) {
> > +		node->count++;
> > +		/* Installed page, can't be shadow-only anymore */
> > +		if (!list_empty(&node->private_list))
> > +			list_lru_del(&workingset_shadow_nodes,
> > +				     &node->private_list);
> > +	}
> 
> Same issue here:
> 
> 	if (node) {
> 		node->count++;
> 		list_lru_del(&workingset_shadow_nodes, &node->private_list);
> 	}

All modifications to node->private_list happen under
mapping->tree_lock, and modifications of a neighboring link should not
affect the outcome of the list_empty(), so I don't think the lru lock
is necessary.

It would be cleaner to take it of course, but that would mean adding
an unconditional NUMAnode-wide lock to every page cache population.

> >  static int __add_to_page_cache_locked(struct page *page,
> > diff --git a/mm/list_lru.c b/mm/list_lru.c
> > index 72f9decb0104..47a9faf4070b 100644
> > --- a/mm/list_lru.c
> > +++ b/mm/list_lru.c
> > @@ -88,10 +88,18 @@ restart:
> >  		ret = isolate(item, &nlru->lock, cb_arg);
> >  		switch (ret) {
> >  		case LRU_REMOVED:
> > +		case LRU_REMOVED_RETRY:
> >  			if (--nlru->nr_items == 0)
> >  				node_clear(nid, lru->active_nodes);
> >  			WARN_ON_ONCE(nlru->nr_items < 0);
> >  			isolated++;
> > +			/*
> > +			 * If the lru lock has been dropped, our list
> > +			 * traversal is now invalid and so we have to
> > +			 * restart from scratch.
> > +			 */
> > +			if (ret == LRU_REMOVED_RETRY)
> > +				goto restart;
> >  			break;
> >  		case LRU_ROTATE:
> >  			list_move_tail(item, &nlru->list);
> 
> I think that we need to assert that the list lru lock is correctly
> held here on return with LRU_REMOVED_RETRY. i.e.
> 
> 		case LRU_REMOVED_RETRY:
> 			assert_spin_locked(&nlru->lock);
> 		case LRU_REMOVED:

Ah, good idea.  How about adding it to LRU_RETRY as well?

> > +/*
> > + * Page cache radix tree nodes containing only shadow entries can grow
> > + * excessively on certain workloads.  That's why they are tracked on
> > + * per-(NUMA)node lists and pushed back by a shrinker, but with a
> > + * slightly higher threshold than regular shrinkers so we don't
> > + * discard the entries too eagerly - after all, during light memory
> > + * pressure is exactly when we need them.
> > + */
> > +
> > +struct list_lru workingset_shadow_nodes;
> > +
> > +static unsigned long count_shadow_nodes(struct shrinker *shrinker,
> > +					struct shrink_control *sc)
> > +{
> > +	return list_lru_count_node(&workingset_shadow_nodes, sc->nid);
> > +}
> > +
> > +static enum lru_status shadow_lru_isolate(struct list_head *item,
> > +					  spinlock_t *lru_lock,
> > +					  void *arg)
> > +{
> > +	unsigned long *nr_reclaimed = arg;
> > +	struct address_space *mapping;
> > +	struct radix_tree_node *node;
> > +	unsigned int i;
> > +	int ret;
> > +
> > +	/*
> > +	 * Page cache insertions and deletions synchroneously maintain
> > +	 * the shadow node LRU under the mapping->tree_lock and the
> > +	 * lru_lock.  Because the page cache tree is emptied before
> > +	 * the inode can be destroyed, holding the lru_lock pins any
> > +	 * address_space that has radix tree nodes on the LRU.
> > +	 *
> > +	 * We can then safely transition to the mapping->tree_lock to
> > +	 * pin only the address_space of the particular node we want
> > +	 * to reclaim, take the node off-LRU, and drop the lru_lock.
> > +	 */
> > +
> > +	node = container_of(item, struct radix_tree_node, private_list);
> > +	mapping = node->private_data;
> > +
> > +	/* Coming from the list, invert the lock order */
> > +	if (!spin_trylock_irq(&mapping->tree_lock)) {
> > +		spin_unlock(lru_lock);
> > +		ret = LRU_RETRY;
> > +		goto out;
> > +	}
> > +
> > +	list_del_init(item);
> > +	spin_unlock(lru_lock);
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
> > +	BUG_ON(node->count);
> > +	inc_zone_state(page_zone(virt_to_page(node)), WORKINGSET_NODERECLAIM);
> > +	if (!__radix_tree_delete_node(&mapping->page_tree, node))
> > +		BUG();
> > +	(*nr_reclaimed)++;
> > +
> > +	spin_unlock_irq(&mapping->tree_lock);
> > +	ret = LRU_REMOVED_RETRY;
> > +out:
> > +	cond_resched();
> > +	spin_lock(lru_lock);
> > +	return ret;
> > +}
> > +
> > +static unsigned long scan_shadow_nodes(struct shrinker *shrinker,
> > +				       struct shrink_control *sc)
> > +{
> > +	unsigned long nr_reclaimed = 0;
> > +
> > +	list_lru_walk_node(&workingset_shadow_nodes, sc->nid,
> > +			   shadow_lru_isolate, &nr_reclaimed, &sc->nr_to_scan);
> > +
> > +	return nr_reclaimed;
> 
> list_lru_walk_node() returns the number of reclaimed objects (i.e.
> the number of objects that returned LRU_REMOVED/LRU_REMOVED_RETRY
> from the ->isolate callback). You don't need to count nr_reclaimed
> yourself.

Good catch, this is a leftover from before LRU_REMOVED_RETRY.  Removed
the ad-hoc counter altogether.

> > +static struct shrinker workingset_shadow_shrinker = {
> > +	.count_objects = count_shadow_nodes,
> > +	.scan_objects = scan_shadow_nodes,
> > +	.seeks = DEFAULT_SEEKS * 4,
> > +	.flags = SHRINKER_NUMA_AWARE,
> > +};
> 
> Can you add a comment explaining how you calculated the .seeks
> value? It's important to document the weighings/importance
> we give to slab reclaim so we can determine if it's actually
> acheiving the desired balance under different loads...

This is not an exact science, to say the least.

The shadow entries are mostly self-regulated, so I don't want the
shrinker to interfere while the machine is just regularly trimming
caches during normal operation.

It should only kick in when either a) reclaim is picking up and the
scan-to-reclaim ratio increases due to mapped pages, dirty cache,
swapping etc. or b) the number of objects compared to LRU pages
becomes excessive.

I think that is what most shrinkers with an elevated seeks value want,
but this translates very awkwardly (and not completely) to the current
cost model, and we should probably rework that interface.

"Seeks" currently encodes 3 ratios:

  1. the cost of creating an object vs. a page

  2. the expected number of objects vs. pages

  3. the cost of reclaiming an object vs. a page

but they are not necessarily correlated.  How I would like to
configure the shadow shrinker instead is:

  o scan objects when reclaim efficiency is down to 75%, because they
    are more valuable than use-once cache but less than workingset

  o scan objects when the ratio between them and the number of pages
    exceeds 1/32 (one shadow entry for each resident page, up to 64
    entries per shrinkable object, assume 50% packing for robustness)

  o as the expected balance between objects and lru pages is 1:32,
    reclaim one object for every 32 reclaimed LRU pages, instead of
    assuming that number of scanned pages corresponds meaningfully to
    number of objects to scan.

"4" just doesn't have the same ring to it.

It would be great if we could eliminate the reclaim cost assumption by
turning the nr_to_scan into a nr_to_reclaim, and then set the other
two ratios independently.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
