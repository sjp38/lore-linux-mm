Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 284F16B0038
	for <linux-mm@kvack.org>; Tue, 16 Aug 2016 05:28:19 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id g124so165928163qkd.1
        for <linux-mm@kvack.org>; Tue, 16 Aug 2016 02:28:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q140si19814304wme.33.2016.08.16.02.28.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 Aug 2016 02:28:18 -0700 (PDT)
Date: Tue, 16 Aug 2016 11:28:16 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 5/7] dax: lock based on slot instead of [mapping, index]
Message-ID: <20160816092816.GE27284@quack2.suse.cz>
References: <20160815190918.20672-1-ross.zwisler@linux.intel.com>
 <20160815190918.20672-6-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160815190918.20672-6-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

On Mon 15-08-16 13:09:16, Ross Zwisler wrote:
> DAX radix tree locking currently locks entries based on the unique
> combination of the 'mapping' pointer and the pgoff_t 'index' for the entry.
> This works for PTEs, but as we move to PMDs we will need to have all the
> offsets within the range covered by the PMD to map to the same bit lock.
> To accomplish this, lock based on the 'slot' pointer in the radix tree
> instead of [mapping, index].

I'm not convinced this is safe. What makes the slot pointer still valid
after you drop tree_lock? At least radix_tree_shrink() or
radix_tree_expand() could move your slot without letting the waiter know
and he would be never woken.

								Honza

> 
> When a PMD entry is present in the tree, all offsets will map to the same
> 'slot' via radix tree lookups, and they will all share the same locking.
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> ---
>  fs/dax.c            | 59 +++++++++++++++++++++--------------------------------
>  include/linux/dax.h |  3 +--
>  mm/filemap.c        |  3 +--
>  3 files changed, 25 insertions(+), 40 deletions(-)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index fed6a52..0f1d053 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -62,11 +62,10 @@ static int __init init_dax_wait_table(void)
>  }
>  fs_initcall(init_dax_wait_table);
>  
> -static wait_queue_head_t *dax_entry_waitqueue(struct address_space *mapping,
> -					      pgoff_t index)
> +static wait_queue_head_t *dax_entry_waitqueue(void **slot)
>  {
> -	unsigned long hash = hash_long((unsigned long)mapping ^ index,
> -				       DAX_WAIT_TABLE_BITS);
> +	unsigned long hash = hash_long((unsigned long)slot,
> +					DAX_WAIT_TABLE_BITS);
>  	return wait_table + hash;
>  }
>  
> @@ -281,25 +280,19 @@ EXPORT_SYMBOL_GPL(dax_do_io);
>  /*
>   * DAX radix tree locking
>   */
> -struct exceptional_entry_key {
> -	struct address_space *mapping;
> -	unsigned long index;
> -};
> -
>  struct wait_exceptional_entry_queue {
>  	wait_queue_t wait;
> -	struct exceptional_entry_key key;
> +	void **slot;
>  };
>  
>  static int wake_exceptional_entry_func(wait_queue_t *wait, unsigned int mode,
>  				       int sync, void *keyp)
>  {
> -	struct exceptional_entry_key *key = keyp;
> +	void **slot = keyp;
>  	struct wait_exceptional_entry_queue *ewait =
>  		container_of(wait, struct wait_exceptional_entry_queue, wait);
>  
> -	if (key->mapping != ewait->key.mapping ||
> -	    key->index != ewait->key.index)
> +	if (slot != ewait->slot)
>  		return 0;
>  	return autoremove_wake_function(wait, mode, sync, NULL);
>  }
> @@ -357,12 +350,10 @@ static void *get_unlocked_mapping_entry(struct address_space *mapping,
>  {
>  	void *ret, **slot;
>  	struct wait_exceptional_entry_queue ewait;
> -	wait_queue_head_t *wq = dax_entry_waitqueue(mapping, index);
> +	wait_queue_head_t *wq;
>  
>  	init_wait(&ewait.wait);
>  	ewait.wait.func = wake_exceptional_entry_func;
> -	ewait.key.mapping = mapping;
> -	ewait.key.index = index;
>  
>  	for (;;) {
>  		ret = __radix_tree_lookup(&mapping->page_tree, index, NULL,
> @@ -373,6 +364,9 @@ static void *get_unlocked_mapping_entry(struct address_space *mapping,
>  				*slotp = slot;
>  			return ret;
>  		}
> +
> +		wq = dax_entry_waitqueue(slot);
> +		ewait.slot = slot;
>  		prepare_to_wait_exclusive(wq, &ewait.wait,
>  					  TASK_UNINTERRUPTIBLE);
>  		spin_unlock_irq(&mapping->tree_lock);
> @@ -445,10 +439,9 @@ restart:
>  	return entry;
>  }
>  
> -void dax_wake_mapping_entry_waiter(struct address_space *mapping,
> -				   pgoff_t index, bool wake_all)
> +void dax_wake_mapping_entry_waiter(void **slot, bool wake_all)
>  {
> -	wait_queue_head_t *wq = dax_entry_waitqueue(mapping, index);
> +	wait_queue_head_t *wq = dax_entry_waitqueue(slot);
>  
>  	/*
>  	 * Checking for locked entry and prepare_to_wait_exclusive() happens
> @@ -456,13 +449,8 @@ void dax_wake_mapping_entry_waiter(struct address_space *mapping,
>  	 * So at this point all tasks that could have seen our entry locked
>  	 * must be in the waitqueue and the following check will see them.
>  	 */
> -	if (waitqueue_active(wq)) {
> -		struct exceptional_entry_key key;
> -
> -		key.mapping = mapping;
> -		key.index = index;
> -		__wake_up(wq, TASK_NORMAL, wake_all ? 0 : 1, &key);
> -	}
> +	if (waitqueue_active(wq))
> +		__wake_up(wq, TASK_NORMAL, wake_all ? 0 : 1, slot);
>  }
>  
>  void dax_unlock_mapping_entry(struct address_space *mapping, pgoff_t index)
> @@ -478,7 +466,7 @@ void dax_unlock_mapping_entry(struct address_space *mapping, pgoff_t index)
>  	}
>  	unlock_slot(mapping, slot);
>  	spin_unlock_irq(&mapping->tree_lock);
> -	dax_wake_mapping_entry_waiter(mapping, index, false);
> +	dax_wake_mapping_entry_waiter(slot, false);
>  }
>  
>  static void put_locked_mapping_entry(struct address_space *mapping,
> @@ -496,14 +484,13 @@ static void put_locked_mapping_entry(struct address_space *mapping,
>   * Called when we are done with radix tree entry we looked up via
>   * get_unlocked_mapping_entry() and which we didn't lock in the end.
>   */
> -static void put_unlocked_mapping_entry(struct address_space *mapping,
> -				       pgoff_t index, void *entry)
> +static void put_unlocked_mapping_entry(void **slot, void *entry)
>  {
>  	if (!radix_tree_exceptional_entry(entry))
>  		return;
>  
>  	/* We have to wake up next waiter for the radix tree entry lock */
> -	dax_wake_mapping_entry_waiter(mapping, index, false);
> +	dax_wake_mapping_entry_waiter(slot, false);
>  }
>  
>  /*
> @@ -512,10 +499,10 @@ static void put_unlocked_mapping_entry(struct address_space *mapping,
>   */
>  int dax_delete_mapping_entry(struct address_space *mapping, pgoff_t index)
>  {
> -	void *entry;
> +	void *entry, **slot;
>  
>  	spin_lock_irq(&mapping->tree_lock);
> -	entry = get_unlocked_mapping_entry(mapping, index, NULL);
> +	entry = get_unlocked_mapping_entry(mapping, index, &slot);
>  	/*
>  	 * This gets called from truncate / punch_hole path. As such, the caller
>  	 * must hold locks protecting against concurrent modifications of the
> @@ -530,7 +517,7 @@ int dax_delete_mapping_entry(struct address_space *mapping, pgoff_t index)
>  	radix_tree_delete(&mapping->page_tree, index);
>  	mapping->nrexceptional--;
>  	spin_unlock_irq(&mapping->tree_lock);
> -	dax_wake_mapping_entry_waiter(mapping, index, true);
> +	dax_wake_mapping_entry_waiter(slot, true);
>  
>  	return 1;
>  }
> @@ -1118,15 +1105,15 @@ int dax_pfn_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
>  {
>  	struct file *file = vma->vm_file;
>  	struct address_space *mapping = file->f_mapping;
> -	void *entry;
> +	void *entry, **slot;
>  	pgoff_t index = vmf->pgoff;
>  
>  	spin_lock_irq(&mapping->tree_lock);
> -	entry = get_unlocked_mapping_entry(mapping, index, NULL);
> +	entry = get_unlocked_mapping_entry(mapping, index, &slot);
>  	if (!entry || !radix_tree_exceptional_entry(entry))
>  		goto out;
>  	radix_tree_tag_set(&mapping->page_tree, index, PAGECACHE_TAG_DIRTY);
> -	put_unlocked_mapping_entry(mapping, index, entry);
> +	put_unlocked_mapping_entry(slot, entry);
>  out:
>  	spin_unlock_irq(&mapping->tree_lock);
>  	return VM_FAULT_NOPAGE;
> diff --git a/include/linux/dax.h b/include/linux/dax.h
> index 9c6dc77..8bcb852 100644
> --- a/include/linux/dax.h
> +++ b/include/linux/dax.h
> @@ -15,8 +15,7 @@ int dax_zero_page_range(struct inode *, loff_t from, unsigned len, get_block_t);
>  int dax_truncate_page(struct inode *, loff_t from, get_block_t);
>  int dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t);
>  int dax_delete_mapping_entry(struct address_space *mapping, pgoff_t index);
> -void dax_wake_mapping_entry_waiter(struct address_space *mapping,
> -				   pgoff_t index, bool wake_all);
> +void dax_wake_mapping_entry_waiter(void **slot, bool wake_all);
>  
>  #ifdef CONFIG_FS_DAX
>  struct page *read_dax_sector(struct block_device *bdev, sector_t n);
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 8a287df..56c4ac7 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -617,8 +617,7 @@ static int page_cache_tree_insert(struct address_space *mapping,
>  			if (node)
>  				workingset_node_pages_dec(node);
>  			/* Wakeup waiters for exceptional entry lock */
> -			dax_wake_mapping_entry_waiter(mapping, page->index,
> -						      false);
> +			dax_wake_mapping_entry_waiter(slot, false);
>  		}
>  	}
>  	radix_tree_replace_slot(slot, page);
> -- 
> 2.9.0
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
