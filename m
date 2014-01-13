Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id EBF616B0035
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 02:39:12 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id kp14so1128765pab.23
        for <linux-mm@kvack.org>; Sun, 12 Jan 2014 23:39:12 -0800 (PST)
Received: from LGEAMRELO01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id db2si1424614pbb.247.2014.01.12.23.39.09
        for <linux-mm@kvack.org>;
        Sun, 12 Jan 2014 23:39:11 -0800 (PST)
Date: Mon, 13 Jan 2014 16:39:47 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [patch 9/9] mm: keep page cache radix tree nodes in check
Message-ID: <20140113073947.GR1992@bbox>
References: <1389377443-11755-1-git-send-email-hannes@cmpxchg.org>
 <1389377443-11755-10-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1389377443-11755-10-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Bob Liu <bob.liu@oracle.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>, Metin Doslu <metin@citusdata.com>, Michel Lespinasse <walken@google.com>, Ozgun Erdogan <ozgun@citusdata.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Roman Gushchin <klamm@yandex-team.ru>, Ryan Mallon <rmallon@gmail.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Jan 10, 2014 at 01:10:43PM -0500, Johannes Weiner wrote:
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
> Per-NUMA rather than global because we expect the radix tree nodes
> themselves to be allocated node-locally and we want to reduce
> cross-node references of otherwise independent cache workloads.  A
> simple shrinker will then reclaim these nodes on memory pressure.
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
> 3. Tree modification needs tree lock and tree root, which are located
>    in the address space, so store an address_space backpointer in the
>    node.  The parent pointer of the node is in a union with the 2-word
>    rcu_head, so the backpointer comes at no extra cost as well.
> 
> 4. The node needs to be linked to an LRU list, which requires a list
>    head inside the node.  This does increase the size of the node, but
>    it does not change the number of objects that fit into a slab page.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  include/linux/list_lru.h   |   2 +
>  include/linux/mmzone.h     |   1 +
>  include/linux/radix-tree.h |  32 +++++++++---
>  include/linux/swap.h       |   1 +
>  lib/radix-tree.c           |  36 ++++++++------
>  mm/filemap.c               |  77 +++++++++++++++++++++++------
>  mm/list_lru.c              |   8 +++
>  mm/truncate.c              |  20 +++++++-
>  mm/vmstat.c                |   1 +
>  mm/workingset.c            | 121 +++++++++++++++++++++++++++++++++++++++++++++
>  10 files changed, 259 insertions(+), 40 deletions(-)
> 
> diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
> index 3ce541753c88..b02fc233eadd 100644
> --- a/include/linux/list_lru.h
> +++ b/include/linux/list_lru.h
> @@ -13,6 +13,8 @@
>  /* list_lru_walk_cb has to always return one of those */
>  enum lru_status {
>  	LRU_REMOVED,		/* item removed from list */
> +	LRU_REMOVED_RETRY,	/* item removed, but lock has been
> +				   dropped and reacquired */
>  	LRU_ROTATE,		/* item referenced, give another pass */
>  	LRU_SKIP,		/* item cannot be locked, skip */
>  	LRU_RETRY,		/* item not freeable. May drop the lock
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 118ba9f51e86..8cac5a7ef7a7 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -144,6 +144,7 @@ enum zone_stat_item {
>  #endif
>  	WORKINGSET_REFAULT,
>  	WORKINGSET_ACTIVATE,
> +	WORKINGSET_NODERECLAIM,
>  	NR_ANON_TRANSPARENT_HUGEPAGES,
>  	NR_FREE_CMA_PAGES,
>  	NR_VM_ZONE_STAT_ITEMS };
> diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
> index 13636c40bc42..33170dbd9db4 100644
> --- a/include/linux/radix-tree.h
> +++ b/include/linux/radix-tree.h
> @@ -72,21 +72,37 @@ static inline int radix_tree_is_indirect_ptr(void *ptr)
>  #define RADIX_TREE_TAG_LONGS	\
>  	((RADIX_TREE_MAP_SIZE + BITS_PER_LONG - 1) / BITS_PER_LONG)
>  
> +#define RADIX_TREE_INDEX_BITS  (8 /* CHAR_BIT */ * sizeof(unsigned long))
> +#define RADIX_TREE_MAX_PATH (DIV_ROUND_UP(RADIX_TREE_INDEX_BITS, \
> +					  RADIX_TREE_MAP_SHIFT))
> +
> +/* Height component in node->path */
> +#define RADIX_TREE_HEIGHT_SHIFT	(RADIX_TREE_MAX_PATH + 1)
> +#define RADIX_TREE_HEIGHT_MASK	((1UL << RADIX_TREE_HEIGHT_SHIFT) - 1)
> +
> +/* Internally used bits of node->count */
> +#define RADIX_TREE_COUNT_SHIFT	(RADIX_TREE_MAP_SHIFT + 1)
> +#define RADIX_TREE_COUNT_MASK	((1UL << RADIX_TREE_COUNT_SHIFT) - 1)
> +
>  struct radix_tree_node {
> -	unsigned int	height;		/* Height from the bottom */
> +	unsigned int	path;	/* Offset in parent & height from the bottom */
>  	unsigned int	count;
>  	union {
> -		struct radix_tree_node *parent;	/* Used when ascending tree */
> -		struct rcu_head	rcu_head;	/* Used when freeing node */
> +		struct {
> +			/* Used when ascending tree */
> +			struct radix_tree_node *parent;
> +			/* For tree user */
> +			void *private_data;
> +		};
> +		/* Used when freeing node */
> +		struct rcu_head	rcu_head;
>  	};
> +	/* For tree user */
> +	struct list_head private_list;
>  	void __rcu	*slots[RADIX_TREE_MAP_SIZE];
>  	unsigned long	tags[RADIX_TREE_MAX_TAGS][RADIX_TREE_TAG_LONGS];
>  };
>  
> -#define RADIX_TREE_INDEX_BITS  (8 /* CHAR_BIT */ * sizeof(unsigned long))
> -#define RADIX_TREE_MAX_PATH (DIV_ROUND_UP(RADIX_TREE_INDEX_BITS, \
> -					  RADIX_TREE_MAP_SHIFT))
> -
>  /* root tags are stored in gfp_mask, shifted by __GFP_BITS_SHIFT */
>  struct radix_tree_root {
>  	unsigned int		height;
> @@ -251,7 +267,7 @@ void *__radix_tree_lookup(struct radix_tree_root *root, unsigned long index,
>  			  struct radix_tree_node **nodep, void ***slotp);
>  void *radix_tree_lookup(struct radix_tree_root *, unsigned long);
>  void **radix_tree_lookup_slot(struct radix_tree_root *, unsigned long);
> -bool __radix_tree_delete_node(struct radix_tree_root *root, unsigned long index,
> +bool __radix_tree_delete_node(struct radix_tree_root *root,
>  			      struct radix_tree_node *node);
>  void *radix_tree_delete_item(struct radix_tree_root *, unsigned long, void *);
>  void *radix_tree_delete(struct radix_tree_root *, unsigned long);
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index b83cf61403ed..102e37bc82d5 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -264,6 +264,7 @@ struct swap_list_t {
>  void *workingset_eviction(struct address_space *mapping, struct page *page);
>  bool workingset_refault(void *shadow);
>  void workingset_activation(struct page *page);
> +extern struct list_lru workingset_shadow_nodes;
>  
>  /* linux/mm/page_alloc.c */
>  extern unsigned long totalram_pages;
> diff --git a/lib/radix-tree.c b/lib/radix-tree.c
> index e601c56a43d0..0a0895371447 100644
> --- a/lib/radix-tree.c
> +++ b/lib/radix-tree.c
> @@ -342,7 +342,8 @@ static int radix_tree_extend(struct radix_tree_root *root, unsigned long index)
>  
>  		/* Increase the height.  */
>  		newheight = root->height+1;
> -		node->height = newheight;
> +		BUG_ON(newheight & ~RADIX_TREE_HEIGHT_MASK);
> +		node->path = newheight;

Nitpick:
It would be better to add some accessor for path and offset for
readability and future enhance?

>  		node->count = 1;
>  		node->parent = NULL;
>  		slot = root->rnode;
> @@ -400,11 +401,12 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
>  			/* Have to add a child node.  */
>  			if (!(slot = radix_tree_node_alloc(root)))
>  				return -ENOMEM;
> -			slot->height = height;
> +			slot->path = height;
>  			slot->parent = node;
>  			if (node) {
>  				rcu_assign_pointer(node->slots[offset], slot);
>  				node->count++;
> +				slot->path |= offset << RADIX_TREE_HEIGHT_SHIFT;
>  			} else
>  				rcu_assign_pointer(root->rnode, ptr_to_indirect(slot));
>  		}
> @@ -496,7 +498,7 @@ void *__radix_tree_lookup(struct radix_tree_root *root, unsigned long index,
>  	}
>  	node = indirect_to_ptr(node);
>  
> -	height = node->height;
> +	height = node->path & RADIX_TREE_HEIGHT_MASK;
>  	if (index > radix_tree_maxindex(height))
>  		return NULL;
>  
> @@ -702,7 +704,7 @@ int radix_tree_tag_get(struct radix_tree_root *root,
>  		return (index == 0);
>  	node = indirect_to_ptr(node);
>  
> -	height = node->height;
> +	height = node->path & RADIX_TREE_HEIGHT_MASK;
>  	if (index > radix_tree_maxindex(height))
>  		return 0;
>  
> @@ -739,7 +741,7 @@ void **radix_tree_next_chunk(struct radix_tree_root *root,
>  {
>  	unsigned shift, tag = flags & RADIX_TREE_ITER_TAG_MASK;
>  	struct radix_tree_node *rnode, *node;
> -	unsigned long index, offset;
> +	unsigned long index, offset, height;
>  
>  	if ((flags & RADIX_TREE_ITER_TAGGED) && !root_tag_get(root, tag))
>  		return NULL;
> @@ -770,7 +772,8 @@ void **radix_tree_next_chunk(struct radix_tree_root *root,
>  		return NULL;
>  
>  restart:
> -	shift = (rnode->height - 1) * RADIX_TREE_MAP_SHIFT;
> +	height = rnode->path & RADIX_TREE_HEIGHT_MASK;
> +	shift = (height - 1) * RADIX_TREE_MAP_SHIFT;
>  	offset = index >> shift;
>  
>  	/* Index outside of the tree */
> @@ -1140,7 +1143,7 @@ static unsigned long __locate(struct radix_tree_node *slot, void *item,
>  	unsigned int shift, height;
>  	unsigned long i;
>  
> -	height = slot->height;
> +	height = slot->path & RADIX_TREE_HEIGHT_MASK;
>  	shift = (height-1) * RADIX_TREE_MAP_SHIFT;
>  
>  	for ( ; height > 1; height--) {
> @@ -1203,7 +1206,8 @@ unsigned long radix_tree_locate_item(struct radix_tree_root *root, void *item)
>  		}
>  
>  		node = indirect_to_ptr(node);
> -		max_index = radix_tree_maxindex(node->height);
> +		max_index = radix_tree_maxindex(node->path &
> +						RADIX_TREE_HEIGHT_MASK);
>  		if (cur_index > max_index)
>  			break;
>  
> @@ -1297,7 +1301,7 @@ static inline void radix_tree_shrink(struct radix_tree_root *root)
>   *
>   *	Returns %true if @node was freed, %false otherwise.
>   */
> -bool __radix_tree_delete_node(struct radix_tree_root *root, unsigned long index,
> +bool __radix_tree_delete_node(struct radix_tree_root *root,
>  			      struct radix_tree_node *node)
>  {
>  	bool deleted = false;
> @@ -1316,9 +1320,10 @@ bool __radix_tree_delete_node(struct radix_tree_root *root, unsigned long index,
>  
>  		parent = node->parent;
>  		if (parent) {
> -			index >>= RADIX_TREE_MAP_SHIFT;
> +			unsigned int offset;
>  
> -			parent->slots[index & RADIX_TREE_MAP_MASK] = NULL;
> +			offset = node->path >> RADIX_TREE_HEIGHT_SHIFT;
> +			parent->slots[offset] = NULL;
>  			parent->count--;
>  		} else {
>  			root_tag_clear_all(root);
> @@ -1382,7 +1387,7 @@ void *radix_tree_delete_item(struct radix_tree_root *root,
>  	node->slots[offset] = NULL;
>  	node->count--;
>  
> -	__radix_tree_delete_node(root, index, node);
> +	__radix_tree_delete_node(root, node);
>  
>  	return entry;
>  }
> @@ -1415,9 +1420,12 @@ int radix_tree_tagged(struct radix_tree_root *root, unsigned int tag)
>  EXPORT_SYMBOL(radix_tree_tagged);
>  
>  static void
> -radix_tree_node_ctor(void *node)
> +radix_tree_node_ctor(void *arg)
>  {
> -	memset(node, 0, sizeof(struct radix_tree_node));
> +	struct radix_tree_node *node = arg;
> +
> +	memset(node, 0, sizeof(*node));
> +	INIT_LIST_HEAD(&node->private_list);
>  }
>  
>  static __init unsigned long __maxindex(unsigned int height)
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 65a374c0df4f..b93e223b59a9 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -110,11 +110,17 @@
>  static void page_cache_tree_delete(struct address_space *mapping,
>  				   struct page *page, void *shadow)
>  {
> -	if (shadow) {
> -		void **slot;
> +	struct radix_tree_node *node;
> +	unsigned long index;
> +	unsigned int offset;
> +	unsigned int tag;
> +	void **slot;
>  
> -		slot = radix_tree_lookup_slot(&mapping->page_tree, page->index);
> -		radix_tree_replace_slot(slot, shadow);
> +	VM_BUG_ON(!PageLocked(page));
> +
> +	__radix_tree_lookup(&mapping->page_tree, page->index, &node, &slot);
> +
> +	if (shadow) {
>  		mapping->nrshadows++;
>  		/*
>  		 * Make sure the nrshadows update is committed before
> @@ -123,9 +129,39 @@ static void page_cache_tree_delete(struct address_space *mapping,
>  		 * same time and miss a shadow entry.
>  		 */
>  		smp_wmb();
> -	} else
> -		radix_tree_delete(&mapping->page_tree, page->index);
> +	}
>  	mapping->nrpages--;
> +
> +	if (!node) {
> +		/* Clear direct pointer tags in root node */
> +		mapping->page_tree.gfp_mask &= __GFP_BITS_MASK;
> +		radix_tree_replace_slot(slot, shadow);
> +		return;
> +	}
> +
> +	/* Clear tree tags for the removed page */
> +	index = page->index;
> +	offset = index & RADIX_TREE_MAP_MASK;
> +	for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++) {
> +		if (test_bit(offset, node->tags[tag]))
> +			radix_tree_tag_clear(&mapping->page_tree, index, tag);
> +	}
> +
> +	/* Delete page, swap shadow entry */
> +	radix_tree_replace_slot(slot, shadow);
> +	node->count--;
> +	if (shadow)
> +		node->count += 1U << RADIX_TREE_COUNT_SHIFT;

Nitpick2:
It should be a function of workingset.c rather than exposing
RADIX_TREE_COUNT_SHIFT?

IMO, It would be better to provide some accessor functions here, too.

I didn't review locking part yet and will review it tomorrow with
fresh brain. :)

> +	else
> +		if (__radix_tree_delete_node(&mapping->page_tree, node))
> +			return;
> +
> +	/* Only shadow entries in there, keep track of this node */
> +	if (!(node->count & RADIX_TREE_COUNT_MASK) &&
> +	    list_empty(&node->private_list)) {
> +		node->private_data = mapping;
> +		list_lru_add(&workingset_shadow_nodes, &node->private_list);
> +	}
>  }
>  
>  /*
> @@ -471,27 +507,36 @@ EXPORT_SYMBOL_GPL(replace_page_cache_page);
>  static int page_cache_tree_insert(struct address_space *mapping,
>  				  struct page *page, void **shadowp)
>  {
> +	struct radix_tree_node *node;
>  	void **slot;
>  	int error;
>  
> -	slot = radix_tree_lookup_slot(&mapping->page_tree, page->index);
> -	if (slot) {
> +	error = __radix_tree_create(&mapping->page_tree, page->index,
> +				    &node, &slot);
> +	if (error)
> +		return error;
> +	if (*slot) {
>  		void *p;
>  
>  		p = radix_tree_deref_slot_protected(slot, &mapping->tree_lock);
>  		if (!radix_tree_exceptional_entry(p))
>  			return -EEXIST;
> -		radix_tree_replace_slot(slot, page);
> -		mapping->nrshadows--;
> -		mapping->nrpages++;
>  		if (shadowp)
>  			*shadowp = p;
> -		return 0;
> +		mapping->nrshadows--;
> +		if (node)
> +			node->count -= 1U << RADIX_TREE_COUNT_SHIFT;
>  	}
> -	error = radix_tree_insert(&mapping->page_tree, page->index, page);
> -	if (!error)
> -		mapping->nrpages++;
> -	return error;
> +	radix_tree_replace_slot(slot, page);
> +	mapping->nrpages++;
> +	if (node) {
> +		node->count++;
> +		/* Installed page, can't be shadow-only anymore */
> +		if (!list_empty(&node->private_list))
> +			list_lru_del(&workingset_shadow_nodes,
> +				     &node->private_list);
> +	}
> +	return 0;
>  }
>  
>  static int __add_to_page_cache_locked(struct page *page,
> diff --git a/mm/list_lru.c b/mm/list_lru.c
> index 72f9decb0104..47a9faf4070b 100644
> --- a/mm/list_lru.c
> +++ b/mm/list_lru.c
> @@ -88,10 +88,18 @@ restart:
>  		ret = isolate(item, &nlru->lock, cb_arg);
>  		switch (ret) {
>  		case LRU_REMOVED:
> +		case LRU_REMOVED_RETRY:
>  			if (--nlru->nr_items == 0)
>  				node_clear(nid, lru->active_nodes);
>  			WARN_ON_ONCE(nlru->nr_items < 0);
>  			isolated++;
> +			/*
> +			 * If the lru lock has been dropped, our list
> +			 * traversal is now invalid and so we have to
> +			 * restart from scratch.
> +			 */
> +			if (ret == LRU_REMOVED_RETRY)
> +				goto restart;
>  			break;
>  		case LRU_ROTATE:
>  			list_move_tail(item, &nlru->list);
> diff --git a/mm/truncate.c b/mm/truncate.c
> index 97606fa4c458..5c2615d7f4da 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -25,6 +25,9 @@
>  static void clear_exceptional_entry(struct address_space *mapping,
>  				    pgoff_t index, void *entry)
>  {
> +	struct radix_tree_node *node;
> +	void **slot;
> +
>  	/* Handled by shmem itself */
>  	if (shmem_mapping(mapping))
>  		return;
> @@ -35,8 +38,21 @@ static void clear_exceptional_entry(struct address_space *mapping,
>  	 * without the tree itself locked.  These unlocked entries
>  	 * need verification under the tree lock.
>  	 */
> -	if (radix_tree_delete_item(&mapping->page_tree, index, entry) == entry)
> -		mapping->nrshadows--;
> +	if (!__radix_tree_lookup(&mapping->page_tree, index, &node, &slot))
> +		goto unlock;
> +	if (*slot != entry)
> +		goto unlock;
> +	radix_tree_replace_slot(slot, NULL);
> +	mapping->nrshadows--;
> +	if (!node)
> +		goto unlock;
> +	node->count -= 1U << RADIX_TREE_COUNT_SHIFT;
> +	/* No more shadow entries, stop tracking the node */
> +	if (!(node->count >> RADIX_TREE_COUNT_SHIFT) &&
> +	    !list_empty(&node->private_list))
> +		list_lru_del(&workingset_shadow_nodes, &node->private_list);
> +	__radix_tree_delete_node(&mapping->page_tree, node);
> +unlock:
>  	spin_unlock_irq(&mapping->tree_lock);
>  }
>  
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 3ac830d1b533..baa3ba586685 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -772,6 +772,7 @@ const char * const vmstat_text[] = {
>  #endif
>  	"workingset_refault",
>  	"workingset_activate",
> +	"workingset_nodereclaim",
>  	"nr_anon_transparent_hugepages",
>  	"nr_free_cma",
>  	"nr_dirty_threshold",
> diff --git a/mm/workingset.c b/mm/workingset.c
> index 8a6c7cff4923..7bb1a432c137 100644
> --- a/mm/workingset.c
> +++ b/mm/workingset.c
> @@ -251,3 +251,124 @@ void workingset_activation(struct page *page)
>  {
>  	atomic_long_inc(&page_zone(page)->inactive_age);
>  }
> +
> +/*
> + * Page cache radix tree nodes containing only shadow entries can grow
> + * excessively on certain workloads.  That's why they are tracked on
> + * per-(NUMA)node lists and pushed back by a shrinker, but with a
> + * slightly higher threshold than regular shrinkers so we don't
> + * discard the entries too eagerly - after all, during light memory
> + * pressure is exactly when we need them.
> + */
> +
> +struct list_lru workingset_shadow_nodes;
> +
> +static unsigned long count_shadow_nodes(struct shrinker *shrinker,
> +					struct shrink_control *sc)
> +{
> +	return list_lru_count_node(&workingset_shadow_nodes, sc->nid);
> +}
> +
> +static enum lru_status shadow_lru_isolate(struct list_head *item,
> +					  spinlock_t *lru_lock,
> +					  void *arg)
> +{
> +	unsigned long *nr_reclaimed = arg;
> +	struct address_space *mapping;
> +	struct radix_tree_node *node;
> +	unsigned int i;
> +	int ret;
> +
> +	/*
> +	 * Page cache insertions and deletions synchroneously maintain
> +	 * the shadow node LRU under the mapping->tree_lock and the
> +	 * lru_lock.  Because the page cache tree is emptied before
> +	 * the inode can be destroyed, holding the lru_lock pins any
> +	 * address_space that has radix tree nodes on the LRU.
> +	 *
> +	 * We can then safely transition to the mapping->tree_lock to
> +	 * pin only the address_space of the particular node we want
> +	 * to reclaim, take the node off-LRU, and drop the lru_lock.
> +	 */
> +
> +	node = container_of(item, struct radix_tree_node, private_list);
> +	mapping = node->private_data;
> +
> +	/* Coming from the list, invert the lock order */
> +	if (!spin_trylock_irq(&mapping->tree_lock)) {
> +		spin_unlock(lru_lock);
> +		ret = LRU_RETRY;
> +		goto out;
> +	}
> +
> +	list_del_init(item);
> +	spin_unlock(lru_lock);
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
> +	BUG_ON(node->count);
> +	inc_zone_state(page_zone(virt_to_page(node)), WORKINGSET_NODERECLAIM);
> +	if (!__radix_tree_delete_node(&mapping->page_tree, node))
> +		BUG();
> +	(*nr_reclaimed)++;
> +
> +	spin_unlock_irq(&mapping->tree_lock);
> +	ret = LRU_REMOVED_RETRY;
> +out:
> +	cond_resched();
> +	spin_lock(lru_lock);
> +	return ret;
> +}
> +
> +static unsigned long scan_shadow_nodes(struct shrinker *shrinker,
> +				       struct shrink_control *sc)
> +{
> +	unsigned long nr_reclaimed = 0;
> +
> +	list_lru_walk_node(&workingset_shadow_nodes, sc->nid,
> +			   shadow_lru_isolate, &nr_reclaimed, &sc->nr_to_scan);
> +
> +	return nr_reclaimed;
> +}
> +
> +static struct shrinker workingset_shadow_shrinker = {
> +	.count_objects = count_shadow_nodes,
> +	.scan_objects = scan_shadow_nodes,
> +	.seeks = DEFAULT_SEEKS * 4,
> +	.flags = SHRINKER_NUMA_AWARE,
> +};
> +
> +static int __init workingset_init(void)
> +{
> +	int ret;
> +
> +	ret = list_lru_init(&workingset_shadow_nodes);
> +	if (ret)
> +		goto err;
> +	ret = register_shrinker(&workingset_shadow_shrinker);
> +	if (ret)
> +		goto err_list_lru;
> +	return 0;
> +err_list_lru:
> +	list_lru_destroy(&workingset_shadow_nodes);
> +err:
> +	return ret;
> +}
> +module_init(workingset_init);
> -- 
> 1.8.4.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
