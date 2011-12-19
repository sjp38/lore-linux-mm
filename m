Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id ACE736B004D
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 03:20:17 -0500 (EST)
Received: by iacb35 with SMTP id b35so8196102iac.14
        for <linux-mm@kvack.org>; Mon, 19 Dec 2011 00:20:17 -0800 (PST)
Message-ID: <4EEEF3B3.909@gmail.com>
Date: Mon, 19 Dec 2011 16:20:03 +0800
From: "nai.xia" <nai.xia@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] radix_tree: take radix_tree_path off stack
References: <alpine.LSU.2.00.1112182234310.1503@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1112182234310.1503@eggly.anvils>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On 2011a1'12ae??19ae?JPY 14:41, Hugh Dickins wrote:
> Down, down in the deepest depths of GFP_NOIO page reclaim, we have
> shrink_page_list() calling __remove_mapping() calling __delete_from_
> swap_cache() or __delete_from_page_cache().
>
> You would not expect those to need much stack, but in fact they call
> radix_tree_delete(): which declares a 192-byte radix_tree_path array
> on its stack (to record the node,offsets it visits when descending,
> in case it needs to ascend to update them).  And if any tag is still
> set [1], that calls radix_tree_tag_clear(), which declares a further
> such 192-byte radix_tree_path array on the stack.  (At least we have
> interrupts disabled here, so won't then be pushing registers too.)
>
> That was probably a good choice when most users were 32-bit (array
> of half the size), and adding fields to radix_tree_node would have
> bloated it unnecessarily.  But nowadays many are 64-bit, and each
> radix_tree_node contains a struct rcu_head, which is only used when

Can rcu_head in someway unionized with radix_tree_node->height
and radix_tree_node->count? count is always referenced under lock
and only the first node's height is referenced during lookup.
Seems like if we atomically set root->rnode to NULL, before
freeing the last node, we can ensure a valid read of the
radix_tree_node->height when lookup by following it with
a root->rnode == NULL test.

I am not very sure of course, just a naive feeling.


> freeing; whereas the radix_tree_path info is only used for updating
> the tree (deleting, clearing tags or setting tags if tagged) when a
> lock must be held, of no interest when accessing the tree locklessly.
>
> So add a parent pointer to the radix_tree_node, in union with the
> rcu_head, and remove all uses of the radix_tree_path.  There would
> be space in that union to save the offset when descending as before
> (we can argue that a lock must already be held to exclude other users),
> but recalculating it when ascending is both easy (a constant shift and
> a constant mask) and uncommon, so it seems better just to do that.
>
> Two little optimizations: no need to decrement height when descending,
> adjusting shift is enough; and once radix_tree_tag_if_tagged() has set
> tag on a node and its ancestors, it need not ascend from that node again.
>
> perf on the radix tree test harness reports radix_tree_insert() as 2%
> slower (now having to set parent), but radix_tree_delete() 24% faster.
> Surely that's an exaggeration from rtth's artificially low map shift 3,
> but forcing it back to 6 still rates radix_tree_delete() 8% faster.
>
> [1] Can a pagecache tag (dirty, writeback or towrite) actually still be
> set at the time of radix_tree_delete()?  Perhaps not if the filesystem
> is well-behaved.  But although I've not tracked any stack overflow down
> to this cause, I have observed a curious case in which a dirty tag is
> set and left set on tmpfs: page migration's migrate_page_copy() happens
> to use __set_page_dirty_nobuffers() to set PageDirty on the newpage,
> and that sets PAGECACHE_TAG_DIRTY as a side-effect - harmless to a
> filesystem which doesn't use tags, except for this stack depth issue.
>
> Signed-off-by: Hugh Dickins<hughd@google.com>
> ----
>
>   lib/radix-tree.c |  148 +++++++++++++++++++++------------------------
>   1 file changed, 70 insertions(+), 78 deletions(-)
>
> --- 3.2-rc6/lib/radix-tree.c	2011-11-07 19:24:53.342418579 -0800
> +++ linux/lib/radix-tree.c	2011-12-16 20:40:26.152758485 -0800
> @@ -48,16 +48,14 @@
>   struct radix_tree_node {
>   	unsigned int	height;		/* Height from the bottom */
>   	unsigned int	count;
> -	struct rcu_head	rcu_head;
> +	union {
> +		struct radix_tree_node *parent;	/* Used when ascending tree */
> +		struct rcu_head	rcu_head;	/* Used when freeing node */
> +	};
>   	void __rcu	*slots[RADIX_TREE_MAP_SIZE];
>   	unsigned long	tags[RADIX_TREE_MAX_TAGS][RADIX_TREE_TAG_LONGS];
>   };
>
> -struct radix_tree_path {
> -	struct radix_tree_node *node;
> -	int offset;
> -};
> -
>   #define RADIX_TREE_INDEX_BITS  (8 /* CHAR_BIT */ * sizeof(unsigned long))
>   #define RADIX_TREE_MAX_PATH (DIV_ROUND_UP(RADIX_TREE_INDEX_BITS, \
>   					  RADIX_TREE_MAP_SHIFT))
> @@ -256,6 +254,7 @@ static inline unsigned long radix_tree_m
>   static int radix_tree_extend(struct radix_tree_root *root, unsigned long index)
>   {
>   	struct radix_tree_node *node;
> +	struct radix_tree_node *slot;
>   	unsigned int height;
>   	int tag;
>
> @@ -274,18 +273,23 @@ static int radix_tree_extend(struct radi
>   		if (!(node = radix_tree_node_alloc(root)))
>   			return -ENOMEM;
>
> -		/* Increase the height.  */
> -		node->slots[0] = indirect_to_ptr(root->rnode);
> -
>   		/* Propagate the aggregated tag info into the new root */
>   		for (tag = 0; tag<  RADIX_TREE_MAX_TAGS; tag++) {
>   			if (root_tag_get(root, tag))
>   				tag_set(node, tag, 0);
>   		}
>
> +		/* Increase the height.  */
>   		newheight = root->height+1;
>   		node->height = newheight;
>   		node->count = 1;
> +		node->parent = NULL;
> +		slot = root->rnode;
> +		if (newheight>  1) {
> +			slot = indirect_to_ptr(slot);
> +			slot->parent = node;
> +		}
> +		node->slots[0] = slot;
>   		node = ptr_to_indirect(node);
>   		rcu_assign_pointer(root->rnode, node);
>   		root->height = newheight;
> @@ -331,6 +335,7 @@ int radix_tree_insert(struct radix_tree_
>   			if (!(slot = radix_tree_node_alloc(root)))
>   				return -ENOMEM;
>   			slot->height = height;
> +			slot->parent = node;
>   			if (node) {
>   				rcu_assign_pointer(node->slots[offset], slot);
>   				node->count++;
> @@ -504,47 +509,41 @@ EXPORT_SYMBOL(radix_tree_tag_set);
>   void *radix_tree_tag_clear(struct radix_tree_root *root,
>   			unsigned long index, unsigned int tag)
>   {
> -	/*
> -	 * The radix tree path needs to be one longer than the maximum path
> -	 * since the "list" is null terminated.
> -	 */
> -	struct radix_tree_path path[RADIX_TREE_MAX_PATH + 1], *pathp = path;
> +	struct radix_tree_node *node = NULL;
>   	struct radix_tree_node *slot = NULL;
>   	unsigned int height, shift;
> +	int uninitialized_var(offset);
>
>   	height = root->height;
>   	if (index>  radix_tree_maxindex(height))
>   		goto out;
>
> -	shift = (height - 1) * RADIX_TREE_MAP_SHIFT;
> -	pathp->node = NULL;
> +	shift = height * RADIX_TREE_MAP_SHIFT;
>   	slot = indirect_to_ptr(root->rnode);
>
> -	while (height>  0) {
> -		int offset;
> -
> +	while (shift) {
>   		if (slot == NULL)
>   			goto out;
>
> +		shift -= RADIX_TREE_MAP_SHIFT;
>   		offset = (index>>  shift)&  RADIX_TREE_MAP_MASK;
> -		pathp[1].offset = offset;
> -		pathp[1].node = slot;
> +		node = slot;
>   		slot = slot->slots[offset];
> -		pathp++;
> -		shift -= RADIX_TREE_MAP_SHIFT;
> -		height--;
>   	}
>
>   	if (slot == NULL)
>   		goto out;
>
> -	while (pathp->node) {
> -		if (!tag_get(pathp->node, tag, pathp->offset))
> +	while (node) {
> +		if (!tag_get(node, tag, offset))
>   			goto out;
> -		tag_clear(pathp->node, tag, pathp->offset);
> -		if (any_tag_set(pathp->node, tag))
> +		tag_clear(node, tag, offset);
> +		if (any_tag_set(node, tag))
>   			goto out;
> -		pathp--;
> +
> +		index>>= RADIX_TREE_MAP_SHIFT;
> +		offset = index&  RADIX_TREE_MAP_MASK;
> +		node = node->parent;
>   	}
>
>   	/* clear the root's tag bit */
> @@ -646,8 +645,7 @@ unsigned long radix_tree_range_tag_if_ta
>   		unsigned int iftag, unsigned int settag)
>   {
>   	unsigned int height = root->height;
> -	struct radix_tree_path path[height];
> -	struct radix_tree_path *pathp = path;
> +	struct radix_tree_node *node = NULL;
>   	struct radix_tree_node *slot;
>   	unsigned int shift;
>   	unsigned long tagged = 0;
> @@ -671,14 +669,8 @@ unsigned long radix_tree_range_tag_if_ta
>   	shift = (height - 1) * RADIX_TREE_MAP_SHIFT;
>   	slot = indirect_to_ptr(root->rnode);
>
> -	/*
> -	 * we fill the path from (root->height - 2) to 0, leaving the index at
> -	 * (root->height - 1) as a terminator. Zero the node in the terminator
> -	 * so that we can use this to end walk loops back up the path.
> -	 */
> -	path[height - 1].node = NULL;
> -
>   	for (;;) {
> +		unsigned long upindex;
>   		int offset;
>
>   		offset = (index>>  shift)&  RADIX_TREE_MAP_MASK;
> @@ -686,12 +678,10 @@ unsigned long radix_tree_range_tag_if_ta
>   			goto next;
>   		if (!tag_get(slot, iftag, offset))
>   			goto next;
> -		if (height>  1) {
> +		if (shift) {
>   			/* Go down one level */
> -			height--;
>   			shift -= RADIX_TREE_MAP_SHIFT;
> -			path[height - 1].node = slot;
> -			path[height - 1].offset = offset;
> +			node = slot;
>   			slot = slot->slots[offset];
>   			continue;
>   		}
> @@ -701,15 +691,21 @@ unsigned long radix_tree_range_tag_if_ta
>   		tag_set(slot, settag, offset);
>
>   		/* walk back up the path tagging interior nodes */
> -		pathp =&path[0];
> -		while (pathp->node) {
> +		upindex = index;
> +		while (node) {
> +			upindex>>= RADIX_TREE_MAP_SHIFT;
> +			offset = upindex&  RADIX_TREE_MAP_MASK;
> +
>   			/* stop if we find a node with the tag already set */
> -			if (tag_get(pathp->node, settag, pathp->offset))
> +			if (tag_get(node, settag, offset))
>   				break;
> -			tag_set(pathp->node, settag, pathp->offset);
> -			pathp++;
> +			tag_set(node, settag, offset);
> +			node = node->parent;
>   		}
>
> +		/* optimization: no need to walk up from this node again */
> +		node = NULL;
> +
>   next:
>   		/* Go to next item at level determined by 'shift' */
>   		index = ((index>>  shift) + 1)<<  shift;
> @@ -724,8 +720,7 @@ next:
>   			 * last_index is guaranteed to be in the tree, what
>   			 * we do below cannot wander astray.
>   			 */
> -			slot = path[height - 1].node;
> -			height++;
> +			slot = slot->parent;
>   			shift += RADIX_TREE_MAP_SHIFT;
>   		}
>   	}
> @@ -1299,7 +1294,7 @@ static inline void radix_tree_shrink(str
>   	/* try to shrink tree height */
>   	while (root->height>  0) {
>   		struct radix_tree_node *to_free = root->rnode;
> -		void *newptr;
> +		struct radix_tree_node *slot;
>
>   		BUG_ON(!radix_tree_is_indirect_ptr(to_free));
>   		to_free = indirect_to_ptr(to_free);
> @@ -1320,10 +1315,12 @@ static inline void radix_tree_shrink(str
>   		 * (to_free->slots[0]), it will be safe to dereference the new
>   		 * one (root->rnode) as far as dependent read barriers go.
>   		 */
> -		newptr = to_free->slots[0];
> -		if (root->height>  1)
> -			newptr = ptr_to_indirect(newptr);
> -		root->rnode = newptr;
> +		slot = to_free->slots[0];
> +		if (root->height>  1) {
> +			slot->parent = NULL;
> +			slot = ptr_to_indirect(slot);
> +		}
> +		root->rnode = slot;
>   		root->height--;
>
>   		/*
> @@ -1363,16 +1360,12 @@ static inline void radix_tree_shrink(str
>    */
>   void *radix_tree_delete(struct radix_tree_root *root, unsigned long index)
>   {
> -	/*
> -	 * The radix tree path needs to be one longer than the maximum path
> -	 * since the "list" is null terminated.
> -	 */
> -	struct radix_tree_path path[RADIX_TREE_MAX_PATH + 1], *pathp = path;
> +	struct radix_tree_node *node = NULL;
>   	struct radix_tree_node *slot = NULL;
>   	struct radix_tree_node *to_free;
>   	unsigned int height, shift;
>   	int tag;
> -	int offset;
> +	int uninitialized_var(offset);
>
>   	height = root->height;
>   	if (index>  radix_tree_maxindex(height))
> @@ -1385,39 +1378,35 @@ void *radix_tree_delete(struct radix_tre
>   		goto out;
>   	}
>   	slot = indirect_to_ptr(slot);
> -
> -	shift = (height - 1) * RADIX_TREE_MAP_SHIFT;
> -	pathp->node = NULL;
> +	shift = height * RADIX_TREE_MAP_SHIFT;
>
>   	do {
>   		if (slot == NULL)
>   			goto out;
>
> -		pathp++;
> +		shift -= RADIX_TREE_MAP_SHIFT;
>   		offset = (index>>  shift)&  RADIX_TREE_MAP_MASK;
> -		pathp->offset = offset;
> -		pathp->node = slot;
> +		node = slot;
>   		slot = slot->slots[offset];
> -		shift -= RADIX_TREE_MAP_SHIFT;
> -		height--;
> -	} while (height>  0);
> +	} while (shift);
>
>   	if (slot == NULL)
>   		goto out;
>
>   	/*
> -	 * Clear all tags associated with the just-deleted item
> +	 * Clear all tags associated with the item to be deleted.
> +	 * This way of doing it would be inefficient, but seldom is any set.
>   	 */
>   	for (tag = 0; tag<  RADIX_TREE_MAX_TAGS; tag++) {
> -		if (tag_get(pathp->node, tag, pathp->offset))
> +		if (tag_get(node, tag, offset))
>   			radix_tree_tag_clear(root, index, tag);
>   	}
>
>   	to_free = NULL;
>   	/* Now free the nodes we do not need anymore */
> -	while (pathp->node) {
> -		pathp->node->slots[pathp->offset] = NULL;
> -		pathp->node->count--;
> +	while (node) {
> +		node->slots[offset] = NULL;
> +		node->count--;
>   		/*
>   		 * Queue the node for deferred freeing after the
>   		 * last reference to it disappears (set NULL, above).
> @@ -1425,17 +1414,20 @@ void *radix_tree_delete(struct radix_tre
>   		if (to_free)
>   			radix_tree_node_free(to_free);
>
> -		if (pathp->node->count) {
> -			if (pathp->node == indirect_to_ptr(root->rnode))
> +		if (node->count) {
> +			if (node == indirect_to_ptr(root->rnode))
>   				radix_tree_shrink(root);
>   			goto out;
>   		}
>
>   		/* Node with zero slots in use so free it */
> -		to_free = pathp->node;
> -		pathp--;
> +		to_free = node;
>
> +		index>>= RADIX_TREE_MAP_SHIFT;
> +		offset = index&  RADIX_TREE_MAP_MASK;
> +		node = node->parent;
>   	}
> +
>   	root_tag_clear_all(root);
>   	root->height = 0;
>   	root->rnode = NULL;
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email:<a href=mailto:"dont@kvack.org">  email@kvack.org</a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
