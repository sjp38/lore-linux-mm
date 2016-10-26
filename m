Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id EBA246B0274
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 05:21:10 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 79so12357335wmy.6
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 02:21:10 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id sx20si1420949wjb.10.2016.10.26.02.21.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Oct 2016 02:21:09 -0700 (PDT)
Date: Wed, 26 Oct 2016 11:21:07 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 0/5] mm: workingset: radix tree subtleties & single-page
 file refaults
Message-ID: <20161026092107.GC11086@quack2.suse.cz>
References: <20161019172428.7649-1-hannes@cmpxchg.org>
 <CA+55aFzRZCt-t_HJ_40mkuvR4qXj71BoW-Tt6hYOKNpT2yj6cw@mail.gmail.com>
 <20161024184739.GB2125@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161024184739.GB2125@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Dave Jones <davej@codemonkey.org.uk>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, kernel-team <kernel-team@fb.com>

On Mon 24-10-16 14:47:39, Johannes Weiner wrote:
> 
> ---
> 
> From 192c2589a5845d197f758045868844623e06b4db Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Mon, 17 Oct 2016 09:00:04 -0400
> Subject: [PATCH] mm: workingset: restore single-page file refault tracking
> 
> Currently, we account shadow entries in the page cache in the upper
> bits of the radix_tree_node->count, behind the back of the radix tree
> implementation. Because the radix tree code has no awareness of them,
> we have to prevent shadow entries from going through operations where
> the tree implementation relies on or modifies node->count: extending
> and shrinking the tree from and to a single direct root->rnode entry.
> 
> As a consequence, we cannot store shadow entries for files that only
> have index 0 populated, and thus cannot detect refaults from them,
> which in turn degrades the thrashing compensation in LRU reclaim.
> 
> Another consequence is that we rely on subtleties throughout the radix
> tree code, such as the node->count != 1 check in the shrinking code,
> which is meant to exclude multi-entry nodes but also skips nodes with
> only one shadow entry since they are accounted in the upper bits. This
> is error prone, and has in fact caused the bug fixed in d3798ae8c6f3
> ("mm: filemap: don't plant shadow entries without radix tree node").
> 
> To fix this, this patch moves the shadow counter from the upper bits
> of node->count into the new node->exceptional counter, where all
> exceptional entries are explicitely tracked by the radix tree.
> node->count then counts all tree entries again, including shadows.
> 
> Switching from a magic node->count to accounting exceptional entries
> natively in the radix tree code removes the fragile subtleties
> mentioned above. It also allows us to store shadow entries for
> single-page files again, as the radix tree recognizes exceptional
> entries when extending the tree from the root->rnode singleton, and
> thus restore refault detection and thrashing compensation for them.

I like this solution. Just one suggestion: I think
radix_tree_replace_slot() can now do the node counter update on its own and
that would save us having to do quite a bit of accounting outside of the
radix tree code itself and it would be less prone to bugs (forgotten
updates of a counter). What do you think?

								Honza

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  include/linux/radix-tree.h | 11 ++++-------
>  include/linux/swap.h       | 32 --------------------------------
>  lib/radix-tree.c           | 16 +++++++++++++---
>  mm/filemap.c               | 45 ++++++++++++++++++++-------------------------
>  mm/truncate.c              |  6 +++---
>  mm/workingset.c            | 13 ++++++++-----
>  6 files changed, 48 insertions(+), 75 deletions(-)
> 
> diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
> index af3581b8a451..2674ed31fa84 100644
> --- a/include/linux/radix-tree.h
> +++ b/include/linux/radix-tree.h
> @@ -80,14 +80,11 @@ static inline bool radix_tree_is_internal_node(void *ptr)
>  #define RADIX_TREE_MAX_PATH (DIV_ROUND_UP(RADIX_TREE_INDEX_BITS, \
>  					  RADIX_TREE_MAP_SHIFT))
>  
> -/* Internally used bits of node->count */
> -#define RADIX_TREE_COUNT_SHIFT	(RADIX_TREE_MAP_SHIFT + 1)
> -#define RADIX_TREE_COUNT_MASK	((1UL << RADIX_TREE_COUNT_SHIFT) - 1)
> -
>  struct radix_tree_node {
> -	unsigned char	shift;	/* Bits remaining in each slot */
> -	unsigned char	offset;	/* Slot offset in parent */
> -	unsigned int	count;
> +	unsigned char	shift;		/* Bits remaining in each slot */
> +	unsigned char	offset;		/* Slot offset in parent */
> +	unsigned char	count;		/* Total entry count */
> +	unsigned char	exceptional;	/* Exceptional entry count */
>  	union {
>  		struct {
>  			/* Used when ascending tree */
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index a56523cefb9b..660a11de0186 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -248,38 +248,6 @@ bool workingset_refault(void *shadow);
>  void workingset_activation(struct page *page);
>  extern struct list_lru workingset_shadow_nodes;
>  
> -static inline unsigned int workingset_node_pages(struct radix_tree_node *node)
> -{
> -	return node->count & RADIX_TREE_COUNT_MASK;
> -}
> -
> -static inline void workingset_node_pages_inc(struct radix_tree_node *node)
> -{
> -	node->count++;
> -}
> -
> -static inline void workingset_node_pages_dec(struct radix_tree_node *node)
> -{
> -	VM_WARN_ON_ONCE(!workingset_node_pages(node));
> -	node->count--;
> -}
> -
> -static inline unsigned int workingset_node_shadows(struct radix_tree_node *node)
> -{
> -	return node->count >> RADIX_TREE_COUNT_SHIFT;
> -}
> -
> -static inline void workingset_node_shadows_inc(struct radix_tree_node *node)
> -{
> -	node->count += 1U << RADIX_TREE_COUNT_SHIFT;
> -}
> -
> -static inline void workingset_node_shadows_dec(struct radix_tree_node *node)
> -{
> -	VM_WARN_ON_ONCE(!workingset_node_shadows(node));
> -	node->count -= 1U << RADIX_TREE_COUNT_SHIFT;
> -}
> -
>  /* linux/mm/page_alloc.c */
>  extern unsigned long totalram_pages;
>  extern unsigned long totalreserve_pages;
> diff --git a/lib/radix-tree.c b/lib/radix-tree.c
> index 8e6d552c40dd..c7d8452d755e 100644
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
> @@ -522,8 +522,14 @@ static int radix_tree_extend(struct radix_tree_root *root,
>  		node->offset = 0;
>  		node->count = 1;
>  		node->parent = NULL;
> -		if (radix_tree_is_internal_node(slot))
> +		/* Extending an existing node or root->rnode */
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
> @@ -649,6 +655,8 @@ int __radix_tree_insert(struct radix_tree_root *root, unsigned long index,
>  	if (node) {
>  		unsigned offset = get_slot_offset(node, slot);
>  		node->count++;
> +		if (radix_tree_exceptional_entry(item))
> +			node->exceptional++;
>  		BUG_ON(tag_get(node, 0, offset));
>  		BUG_ON(tag_get(node, 1, offset));
>  		BUG_ON(tag_get(node, 2, offset));
> @@ -1561,6 +1569,8 @@ void *radix_tree_delete_item(struct radix_tree_root *root,
>  	delete_sibling_entries(node, node_to_entry(slot), offset);
>  	node->slots[offset] = NULL;
>  	node->count--;
> +	if (radix_tree_exceptional_entry(entry))
> +		node->exceptional--;
>  
>  	__radix_tree_delete_node(root, node);
>  
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 849f459ad078..bf7d88b18374 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -128,20 +128,20 @@ static int page_cache_tree_insert(struct address_space *mapping,
>  		if (!radix_tree_exceptional_entry(p))
>  			return -EEXIST;
>  
> +		if (node) {
> +			node->exceptional--;
> +			node->count--;
> +		}
>  		mapping->nrexceptional--;
> +
>  		if (!dax_mapping(mapping)) {
>  			if (shadowp)
>  				*shadowp = p;
> -			if (node)
> -				workingset_node_shadows_dec(node);
>  		} else {
>  			/* DAX can replace empty locked entry with a hole */
>  			WARN_ON_ONCE(p !=
>  				(void *)(RADIX_TREE_EXCEPTIONAL_ENTRY |
>  					 RADIX_DAX_ENTRY_LOCK));
> -			/* DAX accounts exceptional entries as normal pages */
> -			if (node)
> -				workingset_node_pages_dec(node);
>  			/* Wakeup waiters for exceptional entry lock */
>  			dax_wake_mapping_entry_waiter(mapping, page->index,
>  						      false);
> @@ -150,7 +150,7 @@ static int page_cache_tree_insert(struct address_space *mapping,
>  	radix_tree_replace_slot(slot, page);
>  	mapping->nrpages++;
>  	if (node) {
> -		workingset_node_pages_inc(node);
> +		node->count++;
>  		/*
>  		 * Don't track node that contains actual pages.
>  		 *
> @@ -184,38 +184,33 @@ static void page_cache_tree_delete(struct address_space *mapping,
>  
>  		radix_tree_clear_tags(&mapping->page_tree, node, slot);
>  
> -		if (!node) {
> -			VM_BUG_ON_PAGE(nr != 1, page);
> -			/*
> -			 * We need a node to properly account shadow
> -			 * entries. Don't plant any without. XXX
> -			 */
> -			shadow = NULL;
> -		}
> -
>  		radix_tree_replace_slot(slot, shadow);
>  
> -		if (!node)
> +		if (!node) {
> +			VM_BUG_ON_PAGE(nr != 1, page);
>  			break;
> +		}
>  
> -		workingset_node_pages_dec(node);
> -		if (shadow)
> -			workingset_node_shadows_inc(node);
> -		else
> +		if (shadow) {
> +			node->exceptional++;
> +		} else {
> +			node->count--;
>  			if (__radix_tree_delete_node(&mapping->page_tree, node))
>  				continue;
> +		}
>  
>  		/*
> -		 * Track node that only contains shadow entries. DAX mappings
> -		 * contain no shadow entries and may contain other exceptional
> -		 * entries so skip those.
> +		 * Track node that only contains shadow entries. DAX and SHMEM
> +		 * mappings contain no shadow entries and may contain other
> +		 * exceptional entries so skip those.
>  		 *
>  		 * Avoid acquiring the list_lru lock if already tracked.
>  		 * The list_empty() test is safe as node->private_list is
>  		 * protected by mapping->tree_lock.
>  		 */
> -		if (!dax_mapping(mapping) && !workingset_node_pages(node) &&
> -				list_empty(&node->private_list)) {
> +		if (!dax_mapping(mapping) && !shmem_mapping(mapping) &&
> +		    node->count == node->exceptional &&
> +		    list_empty(&node->private_list)) {
>  			node->private_data = mapping;
>  			list_lru_add(&workingset_shadow_nodes,
>  					&node->private_list);
> diff --git a/mm/truncate.c b/mm/truncate.c
> index a01cce450a26..b9b2a1b42822 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -53,7 +53,8 @@ static void clear_exceptional_entry(struct address_space *mapping,
>  	mapping->nrexceptional--;
>  	if (!node)
>  		goto unlock;
> -	workingset_node_shadows_dec(node);
> +	node->exceptional--;
> +	node->count--;
>  	/*
>  	 * Don't track node without shadow entries.
>  	 *
> @@ -61,8 +62,7 @@ static void clear_exceptional_entry(struct address_space *mapping,
>  	 * The list_empty() test is safe as node->private_list is
>  	 * protected by mapping->tree_lock.
>  	 */
> -	if (!workingset_node_shadows(node) &&
> -	    !list_empty(&node->private_list))
> +	if (!node->exceptional && !list_empty(&node->private_list))
>  		list_lru_del(&workingset_shadow_nodes,
>  				&node->private_list);
>  	__radix_tree_delete_node(&mapping->page_tree, node);
> diff --git a/mm/workingset.c b/mm/workingset.c
> index 5f07db171c03..dfaec27aedd3 100644
> --- a/mm/workingset.c
> +++ b/mm/workingset.c
> @@ -418,23 +418,26 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
>  	 * no pages, so we expect to be able to remove them all and
>  	 * delete and free the empty node afterwards.
>  	 */
> -	if (WARN_ON_ONCE(!workingset_node_shadows(node)))
> +	if (WARN_ON_ONCE(!node->exceptional))
>  		goto out_invalid;
> -	if (WARN_ON_ONCE(workingset_node_pages(node)))
> +	if (WARN_ON_ONCE(node->count != node->exceptional))
>  		goto out_invalid;
>  
>  	for (i = 0; i < RADIX_TREE_MAP_SIZE; i++) {
>  		if (node->slots[i]) {
>  			if (WARN_ON_ONCE(!radix_tree_exceptional_entry(node->slots[i])))
>  				goto out_invalid;
> -			node->slots[i] = NULL;
> -			workingset_node_shadows_dec(node);
> +			if (WARN_ON_ONCE(!node->exceptional))
> +				goto out_invalid;
>  			if (WARN_ON_ONCE(!mapping->nrexceptional))
>  				goto out_invalid;
> +			node->slots[i] = NULL;
> +			node->exceptional--;
> +			node->count--;
>  			mapping->nrexceptional--;
>  		}
>  	}
> -	if (WARN_ON_ONCE(workingset_node_shadows(node)))
> +	if (WARN_ON_ONCE(node->exceptional))
>  		goto out_invalid;
>  	inc_node_state(page_pgdat(virt_to_page(node)), WORKINGSET_NODERECLAIM);
>  	__radix_tree_delete_node(&mapping->page_tree, node);
> -- 
> 2.10.0
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
