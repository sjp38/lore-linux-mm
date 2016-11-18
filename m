Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B71C36B03AE
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 02:39:19 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id a20so7744774wme.5
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 23:39:19 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id mn20si6377247wjb.216.2016.11.17.23.39.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 17 Nov 2016 23:39:18 -0800 (PST)
Date: Fri, 18 Nov 2016 08:39:17 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 4/9] lib: radix-tree: native accounting of exceptional
 entries
Message-ID: <20161118073917.GD18676@quack2.suse.cz>
References: <20161117191138.22769-1-hannes@cmpxchg.org>
 <20161117192945.GA23430@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161117192945.GA23430@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu 17-11-16 14:29:45, Johannes Weiner wrote:
> The way the page cache is sneaking shadow entries of evicted pages
> into the radix tree past the node entry accounting and tracking them
> manually in the upper bits of node->count is fraught with problems.
> 
> These shadow entries are marked in the tree as exceptional entries,
> which are a native concept to the radix tree. Maintain an explicit
> counter of exceptional entries in the radix tree node. Subsequent
> patches will switch shadow entry tracking over to that counter.
> 
> DAX and shmem are the other users of exceptional entries. Since slot
> replacements that change the entry type from regular to exceptional
> must now be accounted, introduce a __radix_tree_replace() function
> that does replacement and accounting, and switch DAX and shmem over.
> 
> The increase in radix tree node size is temporary. A followup patch
> switches the shadow tracking to this new scheme and we'll no longer
> need the upper bits in node->count and shrink that back to one byte.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/dax.c                   |  5 +++--
>  include/linux/radix-tree.h | 10 +++++++---
>  lib/radix-tree.c           | 46 +++++++++++++++++++++++++++++++++++++++++++---
>  mm/shmem.c                 |  8 ++++----
>  4 files changed, 57 insertions(+), 12 deletions(-)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index 014defd2e744..db78bae0dc0f 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -643,12 +643,13 @@ static void *dax_insert_mapping_entry(struct address_space *mapping,
>  		}
>  		mapping->nrexceptional++;
>  	} else {
> +		struct radix_tree_node *node;
>  		void **slot;
>  		void *ret;
>  
> -		ret = __radix_tree_lookup(page_tree, index, NULL, &slot);
> +		ret = __radix_tree_lookup(page_tree, index, &node, &slot);
>  		WARN_ON_ONCE(ret != entry);
> -		radix_tree_replace_slot(slot, new_entry);
> +		__radix_tree_replace(page_tree, node, slot, new_entry);
>  	}
>  	if (vmf->flags & FAULT_FLAG_WRITE)
>  		radix_tree_tag_set(page_tree, index, PAGECACHE_TAG_DIRTY);
> diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
> index af3581b8a451..7ced8a70cc8b 100644
> --- a/include/linux/radix-tree.h
> +++ b/include/linux/radix-tree.h
> @@ -85,9 +85,10 @@ static inline bool radix_tree_is_internal_node(void *ptr)
>  #define RADIX_TREE_COUNT_MASK	((1UL << RADIX_TREE_COUNT_SHIFT) - 1)
>  
>  struct radix_tree_node {
> -	unsigned char	shift;	/* Bits remaining in each slot */
> -	unsigned char	offset;	/* Slot offset in parent */
> -	unsigned int	count;
> +	unsigned char	shift;		/* Bits remaining in each slot */
> +	unsigned char	offset;		/* Slot offset in parent */
> +	unsigned int	count;		/* Total entry count */
> +	unsigned char	exceptional;	/* Exceptional entry count */
>  	union {
>  		struct {
>  			/* Used when ascending tree */
> @@ -276,6 +277,9 @@ void *__radix_tree_lookup(struct radix_tree_root *root, unsigned long index,
>  			  struct radix_tree_node **nodep, void ***slotp);
>  void *radix_tree_lookup(struct radix_tree_root *, unsigned long);
>  void **radix_tree_lookup_slot(struct radix_tree_root *, unsigned long);
> +void __radix_tree_replace(struct radix_tree_root *root,
> +			  struct radix_tree_node *node,
> +			  void **slot, void *item);
>  bool __radix_tree_delete_node(struct radix_tree_root *root,
>  			      struct radix_tree_node *node);
>  void *radix_tree_delete_item(struct radix_tree_root *, unsigned long, void *);
> diff --git a/lib/radix-tree.c b/lib/radix-tree.c
> index 8e6d552c40dd..7885796d35ae 100644
> --- a/lib/radix-tree.c
> +++ b/lib/radix-tree.c
> @@ -220,10 +220,10 @@ static void dump_node(struct radix_tree_node *node, unsigned long index)
>  {
>  	unsigned long i;
>  
> -	pr_debug("radix node: %p offset %d tags %lx %lx %lx shift %d count %d parent %p\n",
> +	pr_debug("radix node: %p offset %d tags %lx %lx %lx shift %d count %d exceptional %d parent %p\n",
>  		node, node->offset,
>  		node->tags[0][0], node->tags[1][0], node->tags[2][0],
> -		node->shift, node->count, node->parent);
> +		node->shift, node->count, node->exceptional, node->parent);
>  
>  	for (i = 0; i < RADIX_TREE_MAP_SIZE; i++) {
>  		unsigned long first = index | (i << node->shift);
> @@ -522,8 +522,13 @@ static int radix_tree_extend(struct radix_tree_root *root,
>  		node->offset = 0;
>  		node->count = 1;
>  		node->parent = NULL;
> -		if (radix_tree_is_internal_node(slot))
> +		if (radix_tree_is_internal_node(slot)) {
>  			entry_to_node(slot)->parent = node;
> +		} else {
> +			/* Moving an exceptional root->rnode to a node */
> +			if (radix_tree_exceptional_entry(slot))
> +				node->exceptional = 1;
> +		}
>  		node->slots[0] = slot;
>  		slot = node_to_entry(node);
>  		rcu_assign_pointer(root->rnode, slot);
> @@ -649,6 +654,8 @@ int __radix_tree_insert(struct radix_tree_root *root, unsigned long index,
>  	if (node) {
>  		unsigned offset = get_slot_offset(node, slot);
>  		node->count++;
> +		if (radix_tree_exceptional_entry(item))
> +			node->exceptional++;
>  		BUG_ON(tag_get(node, 0, offset));
>  		BUG_ON(tag_get(node, 1, offset));
>  		BUG_ON(tag_get(node, 2, offset));
> @@ -747,6 +754,37 @@ void *radix_tree_lookup(struct radix_tree_root *root, unsigned long index)
>  EXPORT_SYMBOL(radix_tree_lookup);
>  
>  /**
> + * __radix_tree_replace		- replace item in a slot
> + * @root:	radix tree root
> + * @node:	pointer to tree node
> + * @slot:	pointer to slot in @node
> + * @item:	new item to store in the slot.
> + *
> + * For use with __radix_tree_lookup().  Caller must hold tree write locked
> + * across slot lookup and replacement.
> + */
> +void __radix_tree_replace(struct radix_tree_root *root,
> +			  struct radix_tree_node *node,
> +			  void **slot, void *item)
> +{
> +	void *old = rcu_dereference_raw(*slot);
> +	int exceptional;
> +
> +	WARN_ON_ONCE(radix_tree_is_internal_node(item));
> +	WARN_ON_ONCE(!!item - !!old);
> +
> +	exceptional = !!radix_tree_exceptional_entry(item) -
> +		      !!radix_tree_exceptional_entry(old);
> +
> +	WARN_ON_ONCE(exceptional && !node && slot != (void **)&root->rnode);
> +
> +	if (node)
> +		node->exceptional += exceptional;
> +
> +	rcu_assign_pointer(*slot, item);
> +}
> +
> +/**
>   *	radix_tree_tag_set - set a tag on a radix tree node
>   *	@root:		radix tree root
>   *	@index:		index key
> @@ -1561,6 +1599,8 @@ void *radix_tree_delete_item(struct radix_tree_root *root,
>  	delete_sibling_entries(node, node_to_entry(slot), offset);
>  	node->slots[offset] = NULL;
>  	node->count--;
> +	if (radix_tree_exceptional_entry(entry))
> +		node->exceptional--;
>  
>  	__radix_tree_delete_node(root, node);
>  
> diff --git a/mm/shmem.c b/mm/shmem.c
> index ad7813d73ea7..7f3a08df25c9 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -300,18 +300,18 @@ void shmem_uncharge(struct inode *inode, long pages)
>  static int shmem_radix_tree_replace(struct address_space *mapping,
>  			pgoff_t index, void *expected, void *replacement)
>  {
> +	struct radix_tree_node *node;
>  	void **pslot;
>  	void *item;
>  
>  	VM_BUG_ON(!expected);
>  	VM_BUG_ON(!replacement);
> -	pslot = radix_tree_lookup_slot(&mapping->page_tree, index);
> -	if (!pslot)
> +	item = __radix_tree_lookup(&mapping->page_tree, index, &node, &pslot);
> +	if (!item)
>  		return -ENOENT;
> -	item = radix_tree_deref_slot_protected(pslot, &mapping->tree_lock);
>  	if (item != expected)
>  		return -ENOENT;
> -	radix_tree_replace_slot(pslot, replacement);
> +	__radix_tree_replace(&mapping->page_tree, node, pslot, replacement);
>  	return 0;
>  }
>  
> -- 
> 2.10.2
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
