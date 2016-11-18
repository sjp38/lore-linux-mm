Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 564FB6B03B3
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 03:13:55 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id w13so8450929wmw.0
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 00:13:55 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bo9si3864008wjb.202.2016.11.18.00.13.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 18 Nov 2016 00:13:53 -0800 (PST)
Date: Fri, 18 Nov 2016 09:13:52 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 6/9] lib: radix-tree: add entry deletion support to
 __radix_tree_replace()
Message-ID: <20161118081352.GF18676@quack2.suse.cz>
References: <20161117191138.22769-1-hannes@cmpxchg.org>
 <20161117193058.GC23430@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161117193058.GC23430@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu 17-11-16 14:30:58, Johannes Weiner wrote:
> Page cache shadow entry handling will be a lot simpler when it can use
> a single generic replacement function for pages, shadow entries, and
> emptying slots.
> 
> Make __radix_tree_replace() properly account insertions and deletions
> in node->count and garbage collect nodes as they become empty. Then
> re-implement radix_tree_delete() on top of it.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Seeing this patch, just ignore my nit to the previous patch. Also it would
have been easier to review this patch if you split out the move of those
two functions into a separate patch and state it's just a code move...

Anyway, the result looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza


> ---
>  lib/radix-tree.c | 227 ++++++++++++++++++++++++++++---------------------------
>  1 file changed, 116 insertions(+), 111 deletions(-)
> 
> diff --git a/lib/radix-tree.c b/lib/radix-tree.c
> index f91d5b0af654..5d8930f3b3d8 100644
> --- a/lib/radix-tree.c
> +++ b/lib/radix-tree.c
> @@ -539,6 +539,107 @@ static int radix_tree_extend(struct radix_tree_root *root,
>  }
>  
>  /**
> + *	radix_tree_shrink    -    shrink radix tree to minimum height
> + *	@root		radix tree root
> + */
> +static inline bool radix_tree_shrink(struct radix_tree_root *root)
> +{
> +	bool shrunk = false;
> +
> +	for (;;) {
> +		struct radix_tree_node *node = root->rnode;
> +		struct radix_tree_node *child;
> +
> +		if (!radix_tree_is_internal_node(node))
> +			break;
> +		node = entry_to_node(node);
> +
> +		/*
> +		 * The candidate node has more than one child, or its child
> +		 * is not at the leftmost slot, or the child is a multiorder
> +		 * entry, we cannot shrink.
> +		 */
> +		if (node->count != 1)
> +			break;
> +		child = node->slots[0];
> +		if (!child)
> +			break;
> +		if (!radix_tree_is_internal_node(child) && node->shift)
> +			break;
> +
> +		if (radix_tree_is_internal_node(child))
> +			entry_to_node(child)->parent = NULL;
> +
> +		/*
> +		 * We don't need rcu_assign_pointer(), since we are simply
> +		 * moving the node from one part of the tree to another: if it
> +		 * was safe to dereference the old pointer to it
> +		 * (node->slots[0]), it will be safe to dereference the new
> +		 * one (root->rnode) as far as dependent read barriers go.
> +		 */
> +		root->rnode = child;
> +
> +		/*
> +		 * We have a dilemma here. The node's slot[0] must not be
> +		 * NULLed in case there are concurrent lookups expecting to
> +		 * find the item. However if this was a bottom-level node,
> +		 * then it may be subject to the slot pointer being visible
> +		 * to callers dereferencing it. If item corresponding to
> +		 * slot[0] is subsequently deleted, these callers would expect
> +		 * their slot to become empty sooner or later.
> +		 *
> +		 * For example, lockless pagecache will look up a slot, deref
> +		 * the page pointer, and if the page has 0 refcount it means it
> +		 * was concurrently deleted from pagecache so try the deref
> +		 * again. Fortunately there is already a requirement for logic
> +		 * to retry the entire slot lookup -- the indirect pointer
> +		 * problem (replacing direct root node with an indirect pointer
> +		 * also results in a stale slot). So tag the slot as indirect
> +		 * to force callers to retry.
> +		 */
> +		if (!radix_tree_is_internal_node(child))
> +			node->slots[0] = RADIX_TREE_RETRY;
> +
> +		radix_tree_node_free(node);
> +		shrunk = true;
> +	}
> +
> +	return shrunk;
> +}
> +
> +static bool delete_node(struct radix_tree_root *root,
> +			struct radix_tree_node *node)
> +{
> +	bool deleted = false;
> +
> +	do {
> +		struct radix_tree_node *parent;
> +
> +		if (node->count) {
> +			if (node == entry_to_node(root->rnode))
> +				deleted |= radix_tree_shrink(root);
> +			return deleted;
> +		}
> +
> +		parent = node->parent;
> +		if (parent) {
> +			parent->slots[node->offset] = NULL;
> +			parent->count--;
> +		} else {
> +			root_tag_clear_all(root);
> +			root->rnode = NULL;
> +		}
> +
> +		radix_tree_node_free(node);
> +		deleted = true;
> +
> +		node = parent;
> +	} while (node);
> +
> +	return deleted;
> +}
> +
> +/**
>   *	__radix_tree_create	-	create a slot in a radix tree
>   *	@root:		radix tree root
>   *	@index:		index key
> @@ -759,18 +860,20 @@ static void replace_slot(struct radix_tree_root *root,
>  			 bool warn_typeswitch)
>  {
>  	void *old = rcu_dereference_raw(*slot);
> -	int exceptional;
> +	int count, exceptional;
>  
>  	WARN_ON_ONCE(radix_tree_is_internal_node(item));
> -	WARN_ON_ONCE(!!item - !!old);
>  
> +	count = !!item - !!old;
>  	exceptional = !!radix_tree_exceptional_entry(item) -
>  		      !!radix_tree_exceptional_entry(old);
>  
> -	WARN_ON_ONCE(warn_typeswitch && exceptional);
> +	WARN_ON_ONCE(warn_typeswitch && (count || exceptional));
>  
> -	if (node)
> +	if (node) {
> +		node->count += count;
>  		node->exceptional += exceptional;
> +	}
>  
>  	rcu_assign_pointer(*slot, item);
>  }
> @@ -790,12 +893,14 @@ void __radix_tree_replace(struct radix_tree_root *root,
>  			  void **slot, void *item)
>  {
>  	/*
> -	 * This function supports replacing exceptional entries, but
> -	 * that needs accounting against the node unless the slot is
> -	 * root->rnode.
> +	 * This function supports replacing exceptional entries and
> +	 * deleting entries, but that needs accounting against the
> +	 * node unless the slot is root->rnode.
>  	 */
>  	replace_slot(root, node, slot, item,
>  		     !node && slot != (void **)&root->rnode);
> +
> +	delete_node(root, node);
>  }
>  
>  /**
> @@ -810,8 +915,8 @@ void __radix_tree_replace(struct radix_tree_root *root,
>   *
>   * NOTE: This cannot be used to switch between non-entries (empty slots),
>   * regular entries, and exceptional entries, as that requires accounting
> - * inside the radix tree node. When switching from one type of entry to
> - * another, use __radix_tree_lookup() and __radix_tree_replace().
> + * inside the radix tree node. When switching from one type of entry or
> + * deleting, use __radix_tree_lookup() and __radix_tree_replace().
>   */
>  void radix_tree_replace_slot(struct radix_tree_root *root,
>  			     void **slot, void *item)
> @@ -1467,75 +1572,6 @@ unsigned long radix_tree_locate_item(struct radix_tree_root *root, void *item)
>  #endif /* CONFIG_SHMEM && CONFIG_SWAP */
>  
>  /**
> - *	radix_tree_shrink    -    shrink radix tree to minimum height
> - *	@root		radix tree root
> - */
> -static inline bool radix_tree_shrink(struct radix_tree_root *root)
> -{
> -	bool shrunk = false;
> -
> -	for (;;) {
> -		struct radix_tree_node *node = root->rnode;
> -		struct radix_tree_node *child;
> -
> -		if (!radix_tree_is_internal_node(node))
> -			break;
> -		node = entry_to_node(node);
> -
> -		/*
> -		 * The candidate node has more than one child, or its child
> -		 * is not at the leftmost slot, or the child is a multiorder
> -		 * entry, we cannot shrink.
> -		 */
> -		if (node->count != 1)
> -			break;
> -		child = node->slots[0];
> -		if (!child)
> -			break;
> -		if (!radix_tree_is_internal_node(child) && node->shift)
> -			break;
> -
> -		if (radix_tree_is_internal_node(child))
> -			entry_to_node(child)->parent = NULL;
> -
> -		/*
> -		 * We don't need rcu_assign_pointer(), since we are simply
> -		 * moving the node from one part of the tree to another: if it
> -		 * was safe to dereference the old pointer to it
> -		 * (node->slots[0]), it will be safe to dereference the new
> -		 * one (root->rnode) as far as dependent read barriers go.
> -		 */
> -		root->rnode = child;
> -
> -		/*
> -		 * We have a dilemma here. The node's slot[0] must not be
> -		 * NULLed in case there are concurrent lookups expecting to
> -		 * find the item. However if this was a bottom-level node,
> -		 * then it may be subject to the slot pointer being visible
> -		 * to callers dereferencing it. If item corresponding to
> -		 * slot[0] is subsequently deleted, these callers would expect
> -		 * their slot to become empty sooner or later.
> -		 *
> -		 * For example, lockless pagecache will look up a slot, deref
> -		 * the page pointer, and if the page has 0 refcount it means it
> -		 * was concurrently deleted from pagecache so try the deref
> -		 * again. Fortunately there is already a requirement for logic
> -		 * to retry the entire slot lookup -- the indirect pointer
> -		 * problem (replacing direct root node with an indirect pointer
> -		 * also results in a stale slot). So tag the slot as indirect
> -		 * to force callers to retry.
> -		 */
> -		if (!radix_tree_is_internal_node(child))
> -			node->slots[0] = RADIX_TREE_RETRY;
> -
> -		radix_tree_node_free(node);
> -		shrunk = true;
> -	}
> -
> -	return shrunk;
> -}
> -
> -/**
>   *	__radix_tree_delete_node    -    try to free node after clearing a slot
>   *	@root:		radix tree root
>   *	@node:		node containing @index
> @@ -1549,33 +1585,7 @@ static inline bool radix_tree_shrink(struct radix_tree_root *root)
>  bool __radix_tree_delete_node(struct radix_tree_root *root,
>  			      struct radix_tree_node *node)
>  {
> -	bool deleted = false;
> -
> -	do {
> -		struct radix_tree_node *parent;
> -
> -		if (node->count) {
> -			if (node == entry_to_node(root->rnode))
> -				deleted |= radix_tree_shrink(root);
> -			return deleted;
> -		}
> -
> -		parent = node->parent;
> -		if (parent) {
> -			parent->slots[node->offset] = NULL;
> -			parent->count--;
> -		} else {
> -			root_tag_clear_all(root);
> -			root->rnode = NULL;
> -		}
> -
> -		radix_tree_node_free(node);
> -		deleted = true;
> -
> -		node = parent;
> -	} while (node);
> -
> -	return deleted;
> +	return delete_node(root, node);
>  }
>  
>  static inline void delete_sibling_entries(struct radix_tree_node *node,
> @@ -1632,12 +1642,7 @@ void *radix_tree_delete_item(struct radix_tree_root *root,
>  		node_tag_clear(root, node, tag, offset);
>  
>  	delete_sibling_entries(node, node_to_entry(slot), offset);
> -	node->slots[offset] = NULL;
> -	node->count--;
> -	if (radix_tree_exceptional_entry(entry))
> -		node->exceptional--;
> -
> -	__radix_tree_delete_node(root, node);
> +	__radix_tree_replace(root, node, slot, NULL);
>  
>  	return entry;
>  }
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
