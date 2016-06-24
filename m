Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id CE7DA6B0005
	for <linux-mm@kvack.org>; Fri, 24 Jun 2016 17:44:47 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e189so265519547pfa.2
        for <linux-mm@kvack.org>; Fri, 24 Jun 2016 14:44:47 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id p186si8991849pfg.235.2016.06.24.14.44.46
        for <linux-mm@kvack.org>;
        Fri, 24 Jun 2016 14:44:46 -0700 (PDT)
Date: Fri, 24 Jun 2016 15:44:45 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 1/3] dax: Make cache flushing protected by entry lock
Message-ID: <20160624214445.GA20730@linux.intel.com>
References: <1466523915-14644-1-git-send-email-jack@suse.cz>
 <1466523915-14644-2-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1466523915-14644-2-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Tue, Jun 21, 2016 at 05:45:13PM +0200, Jan Kara wrote:
> Currently, flushing of caches for DAX mappings was ignoring entry lock.
> So far this was ok (modulo a bug that a difference in entry lock could
> cause cache flushing to be mistakenly skipped) but in the following
> patches we will write-protect PTEs on cache flushing and clear dirty
> tags. For that we will need more exclusion. So do cache flushing under
> an entry lock. This allows us to remove one lock-unlock pair of
> mapping->tree_lock as a bonus.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  fs/dax.c | 62 +++++++++++++++++++++++++++++++++++++++-----------------------
>  1 file changed, 39 insertions(+), 23 deletions(-)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index 761495bf5eb9..5209f8cd0bee 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -669,35 +669,54 @@ static int dax_writeback_one(struct block_device *bdev,
>  		struct address_space *mapping, pgoff_t index, void *entry)
>  {
>  	struct radix_tree_root *page_tree = &mapping->page_tree;
> -	int type = RADIX_DAX_TYPE(entry);
> -	struct radix_tree_node *node;
> +	int type;
>  	struct blk_dax_ctl dax;
> -	void **slot;
>  	int ret = 0;
> +	void *entry2, **slot;

Nit: Let's retain the "reverse X-mas tree" ordering of our variable
definitions.

> -	spin_lock_irq(&mapping->tree_lock);
>  	/*
> -	 * Regular page slots are stabilized by the page lock even
> -	 * without the tree itself locked.  These unlocked entries
> -	 * need verification under the tree lock.
> +	 * A page got tagged dirty in DAX mapping? Something is seriously
> +	 * wrong.
>  	 */
> -	if (!__radix_tree_lookup(page_tree, index, &node, &slot))
> -		goto unlock;
> -	if (*slot != entry)
> -		goto unlock;
> -
> -	/* another fsync thread may have already written back this entry */
> -	if (!radix_tree_tag_get(page_tree, index, PAGECACHE_TAG_TOWRITE))
> -		goto unlock;
> +	if (WARN_ON(!radix_tree_exceptional_entry(entry)))
> +		return -EIO;
>  
> +	spin_lock_irq(&mapping->tree_lock);
> +	entry2 = get_unlocked_mapping_entry(mapping, index, &slot);
> +	/* Entry got punched out / reallocated? */
> +	if (!entry2 || !radix_tree_exceptional_entry(entry2))
> +		goto put_unlock;
> +	/*
> +	 * Entry got reallocated elsewhere? No need to writeback. We have to
> +	 * compare sectors as we must not bail out due to difference in lockbit
> +	 * or entry type.
> +	 */
> +	if (RADIX_DAX_SECTOR(entry2) != RADIX_DAX_SECTOR(entry))
> +		goto put_unlock;
> +	type = RADIX_DAX_TYPE(entry2);
>  	if (WARN_ON_ONCE(type != RADIX_DAX_PTE && type != RADIX_DAX_PMD)) {
>  		ret = -EIO;
> -		goto unlock;
> +		goto put_unlock;
>  	}
> +	entry = entry2;

I don't think you need to set 'entry' here - you reset it in 4 lines via
lock_slot(), and don't use it in between.

> +
> +	/* Another fsync thread may have already written back this entry */
> +	if (!radix_tree_tag_get(page_tree, index, PAGECACHE_TAG_TOWRITE))
> +		goto put_unlock;
> +	/* Lock the entry to serialize with page faults */
> +	entry = lock_slot(mapping, slot);

As of this patch nobody unlocks the slot.  :)  A quick test of "write, fsync,
fsync" confirms that it deadlocks.

You introduce the proper calls to unlock the slot via
put_locked_mapping_entry() in patch 3/3 - those probably need to be in this
patch instead.

> +	/*
> +	 * We can clear the tag now but we have to be careful so that concurrent
> +	 * dax_writeback_one() calls for the same index cannot finish before we
> +	 * actually flush the caches. This is achieved as the calls will look
> +	 * at the entry only under tree_lock and once they do that they will
> +	 * see the entry locked and wait for it to unlock.
> +	 */
> +	radix_tree_tag_clear(page_tree, index, PAGECACHE_TAG_TOWRITE);
> +	spin_unlock_irq(&mapping->tree_lock);
>  
>  	dax.sector = RADIX_DAX_SECTOR(entry);
>  	dax.size = (type == RADIX_DAX_PMD ? PMD_SIZE : PAGE_SIZE);
> -	spin_unlock_irq(&mapping->tree_lock);
>  
>  	/*
>  	 * We cannot hold tree_lock while calling dax_map_atomic() because it
> @@ -713,15 +732,12 @@ static int dax_writeback_one(struct block_device *bdev,
>  	}
>  
>  	wb_cache_pmem(dax.addr, dax.size);
> -
> -	spin_lock_irq(&mapping->tree_lock);
> -	radix_tree_tag_clear(page_tree, index, PAGECACHE_TAG_TOWRITE);
> -	spin_unlock_irq(&mapping->tree_lock);
> - unmap:
> +unmap:
>  	dax_unmap_atomic(bdev, &dax);
>  	return ret;
>  
> - unlock:
> +put_unlock:
> +	put_unlocked_mapping_entry(mapping, index, entry2);
>  	spin_unlock_irq(&mapping->tree_lock);
>  	return ret;
>  }
> -- 
> 2.6.6
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
