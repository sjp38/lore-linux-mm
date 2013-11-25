Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 950316B0038
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 18:50:31 -0500 (EST)
Received: by mail-pb0-f46.google.com with SMTP id md12so6785463pbc.5
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 15:50:31 -0800 (PST)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id d5si1302607pac.289.2013.11.25.15.50.28
        for <linux-mm@kvack.org>;
        Mon, 25 Nov 2013 15:50:30 -0800 (PST)
Date: Tue, 26 Nov 2013 10:49:21 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [patch 9/9] mm: keep page cache radix tree nodes in check
Message-ID: <20131125234921.GK8803@dastard>
References: <1385336308-27121-1-git-send-email-hannes@cmpxchg.org>
 <1385336308-27121-10-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1385336308-27121-10-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Tejun Heo <tj@kernel.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun, Nov 24, 2013 at 06:38:28PM -0500, Johannes Weiner wrote:
> Previously, page cache radix tree nodes were freed after reclaim
> emptied out their page pointers.  But now reclaim stores shadow
> entries in their place, which are only reclaimed when the inodes
> themselves are reclaimed.  This is problematic for bigger files that
> are still in use after they have a significant amount of their cache
> reclaimed, without any of those pages actually refaulting.  The shadow
> entries will just sit there and waste memory.  In the worst case, the
> shadow entries will accumulate until the machine runs out of memory.
> 
> To get this under control, the VM will track radix tree nodes
> exclusively containing shadow entries on a per-NUMA node list.  A
> simple shrinker will reclaim these nodes on memory pressure.
> 
> A few things need to be stored in the radix tree node to implement the
> shadow node LRU and allow tree deletions coming from the list:
> 
> 1. There is no index available that would describe the reverse path
>    from the node up to the tree root, which is needed to perform a
>    deletion.  To solve this, encode in each node its offset inside the
>    parent.  This can be stored in the unused upper bits of the same
>    member that stores the node's height at no extra space cost.
> 
> 2. The number of shadow entries needs to be counted in addition to the
>    regular entries, to quickly detect when the node is ready to go to
>    the shadow node LRU list.  The current entry count is an unsigned
>    int but the maximum number of entries is 64, so a shadow counter
>    can easily be stored in the unused upper bits.
> 
> 3. Tree modification needs the lock, which is located in the address
>    space, so store a backpointer to it.  The parent pointer is in a
>    union with the 2-word rcu_head, so the backpointer comes at no
>    extra cost as well.
> 
> 4. The node needs to be linked to an LRU list, which requires a list
>    head inside the node.  This does increase the size of the node, but
>    it does not change the number of objects that fit into a slab page.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  fs/super.c                    |   4 +-
>  fs/xfs/xfs_buf.c              |   2 +-
>  fs/xfs/xfs_qm.c               |   2 +-
>  include/linux/list_lru.h      |   2 +-
>  include/linux/radix-tree.h    |  30 +++++++---
>  include/linux/swap.h          |   1 +
>  include/linux/vm_event_item.h |   1 +
>  lib/radix-tree.c              |  36 +++++++-----
>  mm/filemap.c                  |  70 ++++++++++++++++++++----
>  mm/list_lru.c                 |   4 +-
>  mm/truncate.c                 |  19 ++++++-
>  mm/vmstat.c                   |   2 +
>  mm/workingset.c               | 124 ++++++++++++++++++++++++++++++++++++++++++
>  13 files changed, 255 insertions(+), 42 deletions(-)
> 
> diff --git a/fs/super.c b/fs/super.c
> index 0225c20..a958d52 100644
> --- a/fs/super.c
> +++ b/fs/super.c
> @@ -196,9 +196,9 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
>  		INIT_HLIST_BL_HEAD(&s->s_anon);
>  		INIT_LIST_HEAD(&s->s_inodes);
>  
> -		if (list_lru_init(&s->s_dentry_lru))
> +		if (list_lru_init(&s->s_dentry_lru, NULL))
>  			goto err_out;
> -		if (list_lru_init(&s->s_inode_lru))
> +		if (list_lru_init(&s->s_inode_lru, NULL))
>  			goto err_out_dentry_lru;

rather than modifying all the callers of list_lru_init(), can you
add a new function list_lru_init_key() and implement list_lru_init()
as a wrapper around it?

[snip radix tree modifications I didn't look at]

>  static int page_cache_tree_insert(struct address_space *mapping,
>  				  struct page *page, void **shadowp)
>  {
....
> +	radix_tree_replace_slot(slot, page);
> +	if (node) {
> +		node->count++;
> +		/* Installed page, can't be shadow-only anymore */
> +		if (!list_empty(&node->lru))
> +			list_lru_del(&workingset_shadow_nodes, &node->lru);
> +	}
> +	return 0;

Hmmmmm - what's the overhead of direct management of LRU removal
here? Most list_lru code uses lazy removal (i.e. via the shrinker)
to avoid having to touch the LRU when adding new references to an
object.....

> +
> +/*
> + * Page cache radix tree nodes containing only shadow entries can grow
> + * excessively on certain workloads.  That's why they are tracked on
> + * per-(NUMA)node lists and pushed back by a shrinker, but with a
> + * slightly higher threshold than regular shrinkers so we don't
> + * discard the entries too eagerly - after all, during light memory
> + * pressure is exactly when we need them.
> + *
> + * The list_lru lock nests inside the IRQ-safe mapping->tree_lock, so
> + * we have to disable IRQs for any list_lru operation as well.
> + */
> +
> +struct list_lru workingset_shadow_nodes;
> +
> +static unsigned long count_shadow_nodes(struct shrinker *shrinker,
> +					struct shrink_control *sc)
> +{
> +	unsigned long count;
> +
> +	local_irq_disable();
> +	count = list_lru_count_node(&workingset_shadow_nodes, sc->nid);
> +	local_irq_enable();

The count returned is not perfectly accurate, and the use of it in
the shrinker will be concurrent with other modifications, so
disabling IRQs here doesn't add any anything but unnecessary
overhead.

> +#define NOIRQ_BATCH 32
> +
> +static enum lru_status shadow_lru_isolate(struct list_head *item,
> +					  spinlock_t *lru_lock,
> +					  void *arg)
> +{
> +	struct address_space *mapping;
> +	struct radix_tree_node *node;
> +	unsigned long *batch = arg;
> +	unsigned int i;
> +
> +	node = container_of(item, struct radix_tree_node, lru);
> +	mapping = node->private;
> +
> +	/* Don't disable IRQs for too long */
> +	if (--(*batch) == 0) {
> +		spin_unlock_irq(lru_lock);
> +		*batch = NOIRQ_BATCH;
> +		spin_lock_irq(lru_lock);
> +		return LRU_RETRY;
> +	}

Ugh.

> +	/* Coming from the list, inverse the lock order */
> +	if (!spin_trylock(&mapping->tree_lock))
> +		return LRU_SKIP;

Why not spin_trylock_irq(&mapping->tree_lock) and get rid of the
nasty irq batching stuff? The LRU list is internally consistent,
so I don't see why irqs need to be disabled to walk across the
objects in the list - we only need that to avoid taking an interrupt
while holding the mapping->tree_lock() and the interrupt running
I/O completion which may try to take the mapping->tree_lock....

> +	/*
> +	 * The nodes should only contain one or more shadow entries,
> +	 * no pages, so we expect to be able to remove them all and
> +	 * delete and free the empty node afterwards.
> +	 */
> +
> +	BUG_ON(!node->count);
> +	BUG_ON(node->count & RADIX_TREE_COUNT_MASK);
> +
> +	for (i = 0; i < RADIX_TREE_MAP_SIZE; i++) {
> +		if (node->slots[i]) {
> +			BUG_ON(!radix_tree_exceptional_entry(node->slots[i]));
> +			node->slots[i] = NULL;
> +			BUG_ON(node->count < (1U << RADIX_TREE_COUNT_SHIFT));
> +			node->count -= 1U << RADIX_TREE_COUNT_SHIFT;
> +			BUG_ON(!mapping->nrshadows);
> +			mapping->nrshadows--;
> +		}
> +	}
> +	list_del_init(&node->lru);
> +	BUG_ON(node->count);
> +	if (!__radix_tree_delete_node(&mapping->page_tree, node))
> +		BUG();

That's a lot of work to be doing under the LRU spinlock and with
irqs disabled. That's going to cause hold-off issues for other LRU
operations on the node, and other operations on the CPU....

Given that we should always be removing the item from the head of
the LRU list (except when we can't get the mapping lock), I'd
suggest that it would be better to do something like this:

	/*
	 * Coming from the list, inverse the lock order. Drop the
	 * list lock, too, so that if a caller is spinning on it we
	 * don't get stuck here.
	 */
	if (!spin_trylock(&mapping->tree_lock)) {
		spin_unlock(lru_lock);
		goto out_retry;
	}

	/*
	 * The nodes should only contain one or more shadow entries,
	 * no pages, so we expect to be able to remove them all and
	 * delete and free the empty node afterwards.
	 */
	list_del_init(&node->lru);
	spin_unlock(lru_lock);

	BUG_ON(!node->count);
	BUG_ON(node->count & RADIX_TREE_COUNT_MASK);
.....
	if (!__radix_tree_delete_node(&mapping->page_tree, node))
		BUG();

	spin_unlock_irq(&mapping->tree_lock);
	count_vm_event(WORKINGSET_NODES_RECLAIMED);

out_retry:
	cond_resched();
	spin_lock(lru_lock);
	return LRU_RETRY;
}

So that we don't hold off other LRU operations, we don't hold IRQs
disabled for too long, and we don't cause too much scheduler latency
when doing long scans...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
