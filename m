Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E0C436B0069
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 04:11:45 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id m72so3153030wmc.0
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 01:11:45 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u14si649937wmu.116.2017.10.19.01.11.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Oct 2017 01:11:43 -0700 (PDT)
Date: Thu, 19 Oct 2017 10:11:42 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/8] mm, truncate: Do not check mapping for every page
 being truncated
Message-ID: <20171019081142.GA17891@quack2.suse.cz>
References: <20171018075952.10627-1-mgorman@techsingularity.net>
 <20171018075952.10627-3-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171018075952.10627-3-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dave Chinner <david@fromorbit.com>

On Wed 18-10-17 08:59:46, Mel Gorman wrote:
> During truncation, the mapping has already been checked for shmem and dax
> so it's known that workingset_update_node is required. This patch avoids
> the checks on mapping for each page being truncated. In all other cases,
> a lookup helper is used to determine if workingset_update_node() needs
> to be called. The one danger is that the API is slightly harder to use as
> calling workingset_update_node directly without checking for dax or shmem
> mappings could lead to surprises. However, the API rarely needs to be used
> and hopefully the comment is enough to give people the hint.
> 
> sparsetruncate (tiny)
>                               4.14.0-rc4             4.14.0-rc4
>                              oneirq-v1r1        pickhelper-v1r1
> Min          Time      141.00 (   0.00%)      140.00 (   0.71%)
> 1st-qrtle    Time      142.00 (   0.00%)      141.00 (   0.70%)
> 2nd-qrtle    Time      142.00 (   0.00%)      142.00 (   0.00%)
> 3rd-qrtle    Time      143.00 (   0.00%)      143.00 (   0.00%)
> Max-90%      Time      144.00 (   0.00%)      144.00 (   0.00%)
> Max-95%      Time      147.00 (   0.00%)      145.00 (   1.36%)
> Max-99%      Time      195.00 (   0.00%)      191.00 (   2.05%)
> Max          Time      230.00 (   0.00%)      205.00 (  10.87%)
> Amean        Time      144.37 (   0.00%)      143.82 (   0.38%)
> Stddev       Time       10.44 (   0.00%)        9.00 (  13.74%)
> Coeff        Time        7.23 (   0.00%)        6.26 (  13.41%)
> Best99%Amean Time      143.72 (   0.00%)      143.34 (   0.26%)
> Best95%Amean Time      142.37 (   0.00%)      142.00 (   0.26%)
> Best90%Amean Time      142.19 (   0.00%)      141.85 (   0.24%)
> Best75%Amean Time      141.92 (   0.00%)      141.58 (   0.24%)
> Best50%Amean Time      141.69 (   0.00%)      141.31 (   0.27%)
> Best25%Amean Time      141.38 (   0.00%)      140.97 (   0.29%)
> 
> As you'd expect, the gain is marginal but it can be detected. The differences
> in bonnie are all within the noise which is not surprising given the impact
> on the microbenchmark.
> 
> radix_tree_update_node_t is a callback for some radix operations that
> optionally passes in a private field. The only user of the callback is
> workingset_update_node and as it no longer requires a mapping, the private
> field is removed.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

The patch looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza


> ---
>  fs/dax.c                              |  2 +-
>  include/linux/radix-tree.h            |  7 +++----
>  include/linux/swap.h                  | 13 ++++++++++++-
>  lib/idr.c                             |  2 +-
>  lib/radix-tree.c                      | 30 +++++++++++++-----------------
>  mm/filemap.c                          |  7 ++++---
>  mm/shmem.c                            |  2 +-
>  mm/truncate.c                         |  2 +-
>  mm/workingset.c                       | 10 ++--------
>  tools/testing/radix-tree/multiorder.c |  2 +-
>  10 files changed, 39 insertions(+), 38 deletions(-)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index f001d8c72a06..3318ae9046e6 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -565,7 +565,7 @@ static void *dax_insert_mapping_entry(struct address_space *mapping,
>  		ret = __radix_tree_lookup(page_tree, index, &node, &slot);
>  		WARN_ON_ONCE(ret != entry);
>  		__radix_tree_replace(page_tree, node, slot,
> -				     new_entry, NULL, NULL);
> +				     new_entry, NULL);
>  		entry = new_entry;
>  	}
>  
> diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
> index 567ebb5eaab0..0ca448c1cb42 100644
> --- a/include/linux/radix-tree.h
> +++ b/include/linux/radix-tree.h
> @@ -301,18 +301,17 @@ void *__radix_tree_lookup(const struct radix_tree_root *, unsigned long index,
>  void *radix_tree_lookup(const struct radix_tree_root *, unsigned long);
>  void __rcu **radix_tree_lookup_slot(const struct radix_tree_root *,
>  					unsigned long index);
> -typedef void (*radix_tree_update_node_t)(struct radix_tree_node *, void *);
> +typedef void (*radix_tree_update_node_t)(struct radix_tree_node *);
>  void __radix_tree_replace(struct radix_tree_root *, struct radix_tree_node *,
>  			  void __rcu **slot, void *entry,
> -			  radix_tree_update_node_t update_node, void *private);
> +			  radix_tree_update_node_t update_node);
>  void radix_tree_iter_replace(struct radix_tree_root *,
>  		const struct radix_tree_iter *, void __rcu **slot, void *entry);
>  void radix_tree_replace_slot(struct radix_tree_root *,
>  			     void __rcu **slot, void *entry);
>  void __radix_tree_delete_node(struct radix_tree_root *,
>  			      struct radix_tree_node *,
> -			      radix_tree_update_node_t update_node,
> -			      void *private);
> +			      radix_tree_update_node_t update_node);
>  void radix_tree_iter_delete(struct radix_tree_root *,
>  			struct radix_tree_iter *iter, void __rcu **slot);
>  void *radix_tree_delete_item(struct radix_tree_root *, unsigned long, void *);
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 8a807292037f..257c48a525c8 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -292,7 +292,18 @@ struct vma_swap_readahead {
>  void *workingset_eviction(struct address_space *mapping, struct page *page);
>  bool workingset_refault(void *shadow);
>  void workingset_activation(struct page *page);
> -void workingset_update_node(struct radix_tree_node *node, void *private);
> +
> +/* Do not use directly, use workingset_lookup_update */
> +void workingset_update_node(struct radix_tree_node *node);
> +
> +/* Returns workingset_update_node() if the mapping has shadow entries. */
> +#define workingset_lookup_update(mapping)				\
> +({									\
> +	radix_tree_update_node_t __helper = workingset_update_node;	\
> +	if (dax_mapping(mapping) || shmem_mapping(mapping))		\
> +		__helper = NULL;					\
> +	__helper;							\
> +})
>  
>  /* linux/mm/page_alloc.c */
>  extern unsigned long totalram_pages;
> diff --git a/lib/idr.c b/lib/idr.c
> index edd9b2be1651..2593ce513a18 100644
> --- a/lib/idr.c
> +++ b/lib/idr.c
> @@ -171,7 +171,7 @@ void *idr_replace_ext(struct idr *idr, void *ptr, unsigned long id)
>  	if (!slot || radix_tree_tag_get(&idr->idr_rt, id, IDR_FREE))
>  		return ERR_PTR(-ENOENT);
>  
> -	__radix_tree_replace(&idr->idr_rt, node, slot, ptr, NULL, NULL);
> +	__radix_tree_replace(&idr->idr_rt, node, slot, ptr, NULL);
>  
>  	return entry;
>  }
> diff --git a/lib/radix-tree.c b/lib/radix-tree.c
> index 8b1feca1230a..c8d55565fafa 100644
> --- a/lib/radix-tree.c
> +++ b/lib/radix-tree.c
> @@ -677,8 +677,7 @@ static int radix_tree_extend(struct radix_tree_root *root, gfp_t gfp,
>   *	@root		radix tree root
>   */
>  static inline bool radix_tree_shrink(struct radix_tree_root *root,
> -				     radix_tree_update_node_t update_node,
> -				     void *private)
> +				     radix_tree_update_node_t update_node)
>  {
>  	bool shrunk = false;
>  
> @@ -739,7 +738,7 @@ static inline bool radix_tree_shrink(struct radix_tree_root *root,
>  		if (!radix_tree_is_internal_node(child)) {
>  			node->slots[0] = (void __rcu *)RADIX_TREE_RETRY;
>  			if (update_node)
> -				update_node(node, private);
> +				update_node(node);
>  		}
>  
>  		WARN_ON_ONCE(!list_empty(&node->private_list));
> @@ -752,7 +751,7 @@ static inline bool radix_tree_shrink(struct radix_tree_root *root,
>  
>  static bool delete_node(struct radix_tree_root *root,
>  			struct radix_tree_node *node,
> -			radix_tree_update_node_t update_node, void *private)
> +			radix_tree_update_node_t update_node)
>  {
>  	bool deleted = false;
>  
> @@ -762,8 +761,8 @@ static bool delete_node(struct radix_tree_root *root,
>  		if (node->count) {
>  			if (node_to_entry(node) ==
>  					rcu_dereference_raw(root->rnode))
> -				deleted |= radix_tree_shrink(root, update_node,
> -								private);
> +				deleted |= radix_tree_shrink(root,
> +								update_node);
>  			return deleted;
>  		}
>  
> @@ -1173,7 +1172,6 @@ static int calculate_count(struct radix_tree_root *root,
>   * @slot:		pointer to slot in @node
>   * @item:		new item to store in the slot.
>   * @update_node:	callback for changing leaf nodes
> - * @private:		private data to pass to @update_node
>   *
>   * For use with __radix_tree_lookup().  Caller must hold tree write locked
>   * across slot lookup and replacement.
> @@ -1181,7 +1179,7 @@ static int calculate_count(struct radix_tree_root *root,
>  void __radix_tree_replace(struct radix_tree_root *root,
>  			  struct radix_tree_node *node,
>  			  void __rcu **slot, void *item,
> -			  radix_tree_update_node_t update_node, void *private)
> +			  radix_tree_update_node_t update_node)
>  {
>  	void *old = rcu_dereference_raw(*slot);
>  	int exceptional = !!radix_tree_exceptional_entry(item) -
> @@ -1201,9 +1199,9 @@ void __radix_tree_replace(struct radix_tree_root *root,
>  		return;
>  
>  	if (update_node)
> -		update_node(node, private);
> +		update_node(node);
>  
> -	delete_node(root, node, update_node, private);
> +	delete_node(root, node, update_node);
>  }
>  
>  /**
> @@ -1225,7 +1223,7 @@ void __radix_tree_replace(struct radix_tree_root *root,
>  void radix_tree_replace_slot(struct radix_tree_root *root,
>  			     void __rcu **slot, void *item)
>  {
> -	__radix_tree_replace(root, NULL, slot, item, NULL, NULL);
> +	__radix_tree_replace(root, NULL, slot, item, NULL);
>  }
>  EXPORT_SYMBOL(radix_tree_replace_slot);
>  
> @@ -1242,7 +1240,7 @@ void radix_tree_iter_replace(struct radix_tree_root *root,
>  				const struct radix_tree_iter *iter,
>  				void __rcu **slot, void *item)
>  {
> -	__radix_tree_replace(root, iter->node, slot, item, NULL, NULL);
> +	__radix_tree_replace(root, iter->node, slot, item, NULL);
>  }
>  
>  #ifdef CONFIG_RADIX_TREE_MULTIORDER
> @@ -1972,7 +1970,6 @@ EXPORT_SYMBOL(radix_tree_gang_lookup_tag_slot);
>   *	@root:		radix tree root
>   *	@node:		node containing @index
>   *	@update_node:	callback for changing leaf nodes
> - *	@private:	private data to pass to @update_node
>   *
>   *	After clearing the slot at @index in @node from radix tree
>   *	rooted at @root, call this function to attempt freeing the
> @@ -1980,10 +1977,9 @@ EXPORT_SYMBOL(radix_tree_gang_lookup_tag_slot);
>   */
>  void __radix_tree_delete_node(struct radix_tree_root *root,
>  			      struct radix_tree_node *node,
> -			      radix_tree_update_node_t update_node,
> -			      void *private)
> +			      radix_tree_update_node_t update_node)
>  {
> -	delete_node(root, node, update_node, private);
> +	delete_node(root, node, update_node);
>  }
>  
>  static bool __radix_tree_delete(struct radix_tree_root *root,
> @@ -2001,7 +1997,7 @@ static bool __radix_tree_delete(struct radix_tree_root *root,
>  			node_tag_clear(root, node, tag, offset);
>  
>  	replace_slot(slot, NULL, node, -1, exceptional);
> -	return node && delete_node(root, node, NULL, NULL);
> +	return node && delete_node(root, node, NULL);
>  }
>  
>  /**
> diff --git a/mm/filemap.c b/mm/filemap.c
> index dba68e1d9869..e59580feefd9 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -35,6 +35,7 @@
>  #include <linux/hugetlb.h>
>  #include <linux/memcontrol.h>
>  #include <linux/cleancache.h>
> +#include <linux/shmem_fs.h>
>  #include <linux/rmap.h>
>  #include "internal.h"
>  
> @@ -134,7 +135,7 @@ static int page_cache_tree_insert(struct address_space *mapping,
>  			*shadowp = p;
>  	}
>  	__radix_tree_replace(&mapping->page_tree, node, slot, page,
> -			     workingset_update_node, mapping);
> +			     workingset_lookup_update(mapping));
>  	mapping->nrpages++;
>  	return 0;
>  }
> @@ -162,7 +163,7 @@ static void page_cache_tree_delete(struct address_space *mapping,
>  
>  		radix_tree_clear_tags(&mapping->page_tree, node, slot);
>  		__radix_tree_replace(&mapping->page_tree, node, slot, shadow,
> -				     workingset_update_node, mapping);
> +				workingset_lookup_update(mapping));
>  	}
>  
>  	page->mapping = NULL;
> @@ -360,7 +361,7 @@ page_cache_tree_delete_batch(struct address_space *mapping, int count,
>  		}
>  		radix_tree_clear_tags(&mapping->page_tree, iter.node, slot);
>  		__radix_tree_replace(&mapping->page_tree, iter.node, slot, NULL,
> -				     workingset_update_node, mapping);
> +				workingset_lookup_update(mapping));
>  		total_pages++;
>  	}
>  	mapping->nrpages -= total_pages;
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 07a1d22807be..a72f68aee6a4 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -338,7 +338,7 @@ static int shmem_radix_tree_replace(struct address_space *mapping,
>  	if (item != expected)
>  		return -ENOENT;
>  	__radix_tree_replace(&mapping->page_tree, node, pslot,
> -			     replacement, NULL, NULL);
> +			     replacement, NULL);
>  	return 0;
>  }
>  
> diff --git a/mm/truncate.c b/mm/truncate.c
> index 3dfa2d5e642e..d578d542a6ee 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -42,7 +42,7 @@ static void clear_shadow_entry(struct address_space *mapping, pgoff_t index,
>  	if (*slot != entry)
>  		goto unlock;
>  	__radix_tree_replace(&mapping->page_tree, node, slot, NULL,
> -			     workingset_update_node, mapping);
> +			     workingset_update_node);
>  	mapping->nrexceptional--;
>  unlock:
>  	spin_unlock_irq(&mapping->tree_lock);
> diff --git a/mm/workingset.c b/mm/workingset.c
> index 7119cd745ace..0f7b4fb130e3 100644
> --- a/mm/workingset.c
> +++ b/mm/workingset.c
> @@ -339,14 +339,8 @@ void workingset_activation(struct page *page)
>  
>  static struct list_lru shadow_nodes;
>  
> -void workingset_update_node(struct radix_tree_node *node, void *private)
> +void workingset_update_node(struct radix_tree_node *node)
>  {
> -	struct address_space *mapping = private;
> -
> -	/* Only regular page cache has shadow entries */
> -	if (dax_mapping(mapping) || shmem_mapping(mapping))
> -		return;
> -
>  	/*
>  	 * Track non-empty nodes that contain only shadow entries;
>  	 * unlink those that contain pages or are being freed.
> @@ -474,7 +468,7 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
>  		goto out_invalid;
>  	inc_lruvec_page_state(virt_to_page(node), WORKINGSET_NODERECLAIM);
>  	__radix_tree_delete_node(&mapping->page_tree, node,
> -				 workingset_update_node, mapping);
> +				 workingset_lookup_update(mapping));
>  
>  out_invalid:
>  	spin_unlock(&mapping->tree_lock);
> diff --git a/tools/testing/radix-tree/multiorder.c b/tools/testing/radix-tree/multiorder.c
> index 06c71178d07d..59245b3d587c 100644
> --- a/tools/testing/radix-tree/multiorder.c
> +++ b/tools/testing/radix-tree/multiorder.c
> @@ -618,7 +618,7 @@ static void multiorder_account(void)
>  	__radix_tree_insert(&tree, 1 << 5, 5, (void *)0x12);
>  	__radix_tree_lookup(&tree, 1 << 5, &node, &slot);
>  	assert(node->count == node->exceptional * 2);
> -	__radix_tree_replace(&tree, node, slot, NULL, NULL, NULL);
> +	__radix_tree_replace(&tree, node, slot, NULL, NULL);
>  	assert(node->exceptional == 0);
>  
>  	item_kill_tree(&tree);
> -- 
> 2.14.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
