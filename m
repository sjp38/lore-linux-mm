Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 137736B0035
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 19:13:36 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id z10so6576132pdj.30
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 16:13:35 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ku6si29136335pbc.96.2013.11.25.16.13.34
        for <linux-mm@kvack.org>;
        Mon, 25 Nov 2013 16:13:34 -0800 (PST)
Date: Mon, 25 Nov 2013 16:13:32 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 9/9] mm: keep page cache radix tree nodes in check
Message-Id: <20131125161332.f9d5f37b6fbaba5a43403131@linux-foundation.org>
In-Reply-To: <1385336308-27121-10-git-send-email-hannes@cmpxchg.org>
References: <1385336308-27121-1-git-send-email-hannes@cmpxchg.org>
	<1385336308-27121-10-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Dave Chinner <david@fromorbit.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Tejun Heo <tj@kernel.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun, 24 Nov 2013 18:38:28 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:

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
> exclusively containing shadow entries on a per-NUMA node list.

Why per-node rather than a global list?

>  A simple shrinker will reclaim these nodes on memory pressure.

Truncate needs to go off and massacre these things as well - some
description of how that happens would be useful.

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
>    space,

Presumably "the lock" == tree_lock.

>    so store a backpointer to it.

<looks at the code>

"it" is the address_space, not tree_lock, yes?

>   The parent pointer is in a
>    union with the 2-word rcu_head, so the backpointer comes at no
>    extra cost as well.

So we have a shrinker walking backwards from radix-tree nodes and
reaching up into address_spaces.  We need to take steps to prevent
those address_spaces from getting shot down (reclaim, umount, truncate,
etc) while we're doing this.  What's happening here?

> 4. The node needs to be linked to an LRU list, which requires a list
>    head inside the node.  This does increase the size of the node, but
>    it does not change the number of objects that fit into a slab page.
>
> ...
>
> --- a/include/linux/list_lru.h
> +++ b/include/linux/list_lru.h
> @@ -32,7 +32,7 @@ struct list_lru {
>  };
>  
>  void list_lru_destroy(struct list_lru *lru);
> -int list_lru_init(struct list_lru *lru);
> +int list_lru_init(struct list_lru *lru, struct lock_class_key *key);

It's a bit of a shame to be adding overhead to non-lockdep kernels.  A
few ifdefs could fix this.

Presumably this is being done to squish some lockdep warning you hit. 
A comment at the list_lru_init() implementation site would be useful. 
One which describes the warning and why it's OK to squish it.

>
> ...
>
>  struct radix_tree_node {
> -	unsigned int	height;		/* Height from the bottom */
> +	unsigned int	path;	/* Offset in parent & height from the bottom */
>  	unsigned int	count;
>  	union {
> -		struct radix_tree_node *parent;	/* Used when ascending tree */
> -		struct rcu_head	rcu_head;	/* Used when freeing node */
> +		/* Used when ascending tree */
> +		struct {
> +			struct radix_tree_node *parent;
> +			void *private;

Private to whom?  The radix-tree implementation?  The radix-tree caller?

> +		};
> +		/* Used when freeing node */
> +		struct rcu_head	rcu_head;
>  	};
> +	struct list_head lru;

Locking for this list?

>  	void __rcu	*slots[RADIX_TREE_MAP_SIZE];
>  	unsigned long	tags[RADIX_TREE_MAX_TAGS][RADIX_TREE_TAG_LONGS];
>  };
>  
>
> ...
>
> +static unsigned long count_shadow_nodes(struct shrinker *shrinker,
> +					struct shrink_control *sc)
> +{
> +	unsigned long count;
> +
> +	local_irq_disable();
> +	count = list_lru_count_node(&workingset_shadow_nodes, sc->nid);
> +	local_irq_enable();

I'm struggling with the local_irq_disable() here.  Presumably it's
there to quash a lockdep warning, but page_cache_tree_delete() and
friends can get away without the local_irq_disable().  Some more
clarity here would be nice.

> +	return count;
> +}
> +
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
> +
> +	/* Coming from the list, inverse the lock order */

"invert" ;)

> +	if (!spin_trylock(&mapping->tree_lock))
> +		return LRU_SKIP;
> +
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
> +
> +	spin_unlock(&mapping->tree_lock);
> +
> +	count_vm_event(WORKINGSET_NODES_RECLAIMED);
> +
> +	return LRU_REMOVED;
> +}
> +
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
