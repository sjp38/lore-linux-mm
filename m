Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 7E0016B0007
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 12:15:27 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id p187so77309584wmp.1
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 09:15:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qt4si50587425wjc.0.2015.12.21.09.15.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 21 Dec 2015 09:15:26 -0800 (PST)
Date: Mon, 21 Dec 2015 18:15:12 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v5 2/7] dax: support dirty DAX entries in radix tree
Message-ID: <20151221171512.GA7030@quack.suse.cz>
References: <1450502540-8744-1-git-send-email-ross.zwisler@linux.intel.com>
 <1450502540-8744-3-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1450502540-8744-3-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Fri 18-12-15 22:22:15, Ross Zwisler wrote:
> Add support for tracking dirty DAX entries in the struct address_space
> radix tree.  This tree is already used for dirty page writeback, and it
> already supports the use of exceptional (non struct page*) entries.
> 
> In order to properly track dirty DAX pages we will insert new exceptional
> entries into the radix tree that represent dirty DAX PTE or PMD pages.
> These exceptional entries will also contain the writeback addresses for the
> PTE or PMD faults that we can use at fsync/msync time.
> 
> There are currently two types of exceptional entries (shmem and shadow)
> that can be placed into the radix tree, and this adds a third.  We rely on
> the fact that only one type of exceptional entry can be found in a given
> radix tree based on its usage.  This happens for free with DAX vs shmem but
> we explicitly prevent shadow entries from being added to radix trees for
> DAX mappings.
> 
> The only shadow entries that would be generated for DAX radix trees would
> be to track zero page mappings that were created for holes.  These pages
> would receive minimal benefit from having shadow entries, and the choice
> to have only one type of exceptional entry in a given radix tree makes the
> logic simpler both in clear_exceptional_entry() and in the rest of DAX.
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>

The patch looks good to me. Just one comment: When we have this exclusion
between different types of exceptional entries, there is no real need to
have separate counters of 'shadow' and 'dax' entries, is there? We can have
one 'nrexceptional' counter and don't have to grow struct inode
unnecessarily which would be really welcome since DAX isn't a mainstream
feature. Could you please change the code? Thanks!

								Honza
> ---
>  fs/block_dev.c             |  3 ++-
>  fs/inode.c                 |  1 +
>  include/linux/dax.h        |  5 ++++
>  include/linux/fs.h         |  1 +
>  include/linux/radix-tree.h |  9 +++++++
>  mm/filemap.c               | 13 +++++++---
>  mm/truncate.c              | 64 +++++++++++++++++++++++++++-------------------
>  mm/vmscan.c                |  9 ++++++-
>  8 files changed, 73 insertions(+), 32 deletions(-)
> 
> diff --git a/fs/block_dev.c b/fs/block_dev.c
> index c25639e..226dacc 100644
> --- a/fs/block_dev.c
> +++ b/fs/block_dev.c
> @@ -75,7 +75,8 @@ void kill_bdev(struct block_device *bdev)
>  {
>  	struct address_space *mapping = bdev->bd_inode->i_mapping;
>  
> -	if (mapping->nrpages == 0 && mapping->nrshadows == 0)
> +	if (mapping->nrpages == 0 && mapping->nrshadows == 0 &&
> +			mapping->nrdax == 0)
>  		return;
>  
>  	invalidate_bh_lrus();
> diff --git a/fs/inode.c b/fs/inode.c
> index 1be5f90..79d828f 100644
> --- a/fs/inode.c
> +++ b/fs/inode.c
> @@ -496,6 +496,7 @@ void clear_inode(struct inode *inode)
>  	spin_lock_irq(&inode->i_data.tree_lock);
>  	BUG_ON(inode->i_data.nrpages);
>  	BUG_ON(inode->i_data.nrshadows);
> +	BUG_ON(inode->i_data.nrdax);
>  	spin_unlock_irq(&inode->i_data.tree_lock);
>  	BUG_ON(!list_empty(&inode->i_data.private_list));
>  	BUG_ON(!(inode->i_state & I_FREEING));
> diff --git a/include/linux/dax.h b/include/linux/dax.h
> index b415e52..e9d57f68 100644
> --- a/include/linux/dax.h
> +++ b/include/linux/dax.h
> @@ -36,4 +36,9 @@ static inline bool vma_is_dax(struct vm_area_struct *vma)
>  {
>  	return vma->vm_file && IS_DAX(vma->vm_file->f_mapping->host);
>  }
> +
> +static inline bool dax_mapping(struct address_space *mapping)
> +{
> +	return mapping->host && IS_DAX(mapping->host);
> +}
>  #endif
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 3aa5142..b9ac534 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -433,6 +433,7 @@ struct address_space {
>  	/* Protected by tree_lock together with the radix tree */
>  	unsigned long		nrpages;	/* number of total pages */
>  	unsigned long		nrshadows;	/* number of shadow entries */
> +	unsigned long		nrdax;	        /* number of DAX entries */
>  	pgoff_t			writeback_index;/* writeback starts here */
>  	const struct address_space_operations *a_ops;	/* methods */
>  	unsigned long		flags;		/* error bits/gfp mask */
> diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
> index 33170db..f793c99 100644
> --- a/include/linux/radix-tree.h
> +++ b/include/linux/radix-tree.h
> @@ -51,6 +51,15 @@
>  #define RADIX_TREE_EXCEPTIONAL_ENTRY	2
>  #define RADIX_TREE_EXCEPTIONAL_SHIFT	2
>  
> +#define RADIX_DAX_MASK	0xf
> +#define RADIX_DAX_PTE  (0x4 | RADIX_TREE_EXCEPTIONAL_ENTRY)
> +#define RADIX_DAX_PMD  (0x8 | RADIX_TREE_EXCEPTIONAL_ENTRY)
> +#define RADIX_DAX_TYPE(entry) ((__force unsigned long)entry & RADIX_DAX_MASK)
> +#define RADIX_DAX_ADDR(entry) ((void __pmem *)((unsigned long)entry & \
> +			~RADIX_DAX_MASK))
> +#define RADIX_DAX_ENTRY(addr, pmd) ((void *)((__force unsigned long)addr | \
> +			(pmd ? RADIX_DAX_PMD : RADIX_DAX_PTE)))
> +
>  static inline int radix_tree_is_indirect_ptr(void *ptr)
>  {
>  	return (int)((unsigned long)ptr & RADIX_TREE_INDIRECT_PTR);
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 1bb0076..167a4d9 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -11,6 +11,7 @@
>   */
>  #include <linux/export.h>
>  #include <linux/compiler.h>
> +#include <linux/dax.h>
>  #include <linux/fs.h>
>  #include <linux/uaccess.h>
>  #include <linux/capability.h>
> @@ -579,6 +580,12 @@ static int page_cache_tree_insert(struct address_space *mapping,
>  		p = radix_tree_deref_slot_protected(slot, &mapping->tree_lock);
>  		if (!radix_tree_exceptional_entry(p))
>  			return -EEXIST;
> +
> +		if (dax_mapping(mapping)) {
> +			WARN_ON(1);
> +			return -EINVAL;
> +		}
> +
>  		if (shadowp)
>  			*shadowp = p;
>  		mapping->nrshadows--;
> @@ -1242,9 +1249,9 @@ repeat:
>  			if (radix_tree_deref_retry(page))
>  				goto restart;
>  			/*
> -			 * A shadow entry of a recently evicted page,
> -			 * or a swap entry from shmem/tmpfs.  Return
> -			 * it without attempting to raise page count.
> +			 * A shadow entry of a recently evicted page, a swap
> +			 * entry from shmem/tmpfs or a DAX entry.  Return it
> +			 * without attempting to raise page count.
>  			 */
>  			goto export;
>  		}
> diff --git a/mm/truncate.c b/mm/truncate.c
> index 76e35ad..1dc9f29 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -9,6 +9,7 @@
>  
>  #include <linux/kernel.h>
>  #include <linux/backing-dev.h>
> +#include <linux/dax.h>
>  #include <linux/gfp.h>
>  #include <linux/mm.h>
>  #include <linux/swap.h>
> @@ -34,31 +35,39 @@ static void clear_exceptional_entry(struct address_space *mapping,
>  		return;
>  
>  	spin_lock_irq(&mapping->tree_lock);
> -	/*
> -	 * Regular page slots are stabilized by the page lock even
> -	 * without the tree itself locked.  These unlocked entries
> -	 * need verification under the tree lock.
> -	 */
> -	if (!__radix_tree_lookup(&mapping->page_tree, index, &node, &slot))
> -		goto unlock;
> -	if (*slot != entry)
> -		goto unlock;
> -	radix_tree_replace_slot(slot, NULL);
> -	mapping->nrshadows--;
> -	if (!node)
> -		goto unlock;
> -	workingset_node_shadows_dec(node);
> -	/*
> -	 * Don't track node without shadow entries.
> -	 *
> -	 * Avoid acquiring the list_lru lock if already untracked.
> -	 * The list_empty() test is safe as node->private_list is
> -	 * protected by mapping->tree_lock.
> -	 */
> -	if (!workingset_node_shadows(node) &&
> -	    !list_empty(&node->private_list))
> -		list_lru_del(&workingset_shadow_nodes, &node->private_list);
> -	__radix_tree_delete_node(&mapping->page_tree, node);
> +
> +	if (dax_mapping(mapping)) {
> +		if (radix_tree_delete_item(&mapping->page_tree, index, entry))
> +			mapping->nrdax--;
> +	} else {
> +		/*
> +		 * Regular page slots are stabilized by the page lock even
> +		 * without the tree itself locked.  These unlocked entries
> +		 * need verification under the tree lock.
> +		 */
> +		if (!__radix_tree_lookup(&mapping->page_tree, index, &node,
> +					&slot))
> +			goto unlock;
> +		if (*slot != entry)
> +			goto unlock;
> +		radix_tree_replace_slot(slot, NULL);
> +		mapping->nrshadows--;
> +		if (!node)
> +			goto unlock;
> +		workingset_node_shadows_dec(node);
> +		/*
> +		 * Don't track node without shadow entries.
> +		 *
> +		 * Avoid acquiring the list_lru lock if already untracked.
> +		 * The list_empty() test is safe as node->private_list is
> +		 * protected by mapping->tree_lock.
> +		 */
> +		if (!workingset_node_shadows(node) &&
> +		    !list_empty(&node->private_list))
> +			list_lru_del(&workingset_shadow_nodes,
> +					&node->private_list);
> +		__radix_tree_delete_node(&mapping->page_tree, node);
> +	}
>  unlock:
>  	spin_unlock_irq(&mapping->tree_lock);
>  }
> @@ -228,7 +237,8 @@ void truncate_inode_pages_range(struct address_space *mapping,
>  	int		i;
>  
>  	cleancache_invalidate_inode(mapping);
> -	if (mapping->nrpages == 0 && mapping->nrshadows == 0)
> +	if (mapping->nrpages == 0 && mapping->nrshadows == 0 &&
> +			mapping->nrdax == 0)
>  		return;
>  
>  	/* Offsets within partial pages */
> @@ -423,7 +433,7 @@ void truncate_inode_pages_final(struct address_space *mapping)
>  	smp_rmb();
>  	nrshadows = mapping->nrshadows;
>  
> -	if (nrpages || nrshadows) {
> +	if (nrpages || nrshadows || mapping->nrdax) {
>  		/*
>  		 * As truncation uses a lockless tree lookup, cycle
>  		 * the tree lock to make sure any ongoing tree
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 2aec424..8071956 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -46,6 +46,7 @@
>  #include <linux/oom.h>
>  #include <linux/prefetch.h>
>  #include <linux/printk.h>
> +#include <linux/dax.h>
>  
>  #include <asm/tlbflush.h>
>  #include <asm/div64.h>
> @@ -671,9 +672,15 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
>  		 * inode reclaim needs to empty out the radix tree or
>  		 * the nodes are lost.  Don't plant shadows behind its
>  		 * back.
> +		 *
> +		 * We also don't store shadows for DAX mappings because the
> +		 * only page cache pages found in these are zero pages
> +		 * covering holes, and because we don't want to mix DAX
> +		 * exceptional entries and shadow exceptional entries in the
> +		 * same page_tree.
>  		 */
>  		if (reclaimed && page_is_file_cache(page) &&
> -		    !mapping_exiting(mapping))
> +		    !mapping_exiting(mapping) && !dax_mapping(mapping))
>  			shadow = workingset_eviction(mapping, page);
>  		__delete_from_page_cache(page, shadow, memcg);
>  		spin_unlock_irqrestore(&mapping->tree_lock, flags);
> -- 
> 2.5.0
> 
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
