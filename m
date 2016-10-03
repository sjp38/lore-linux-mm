Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 37D0E6B0069
	for <linux-mm@kvack.org>; Mon,  3 Oct 2016 06:59:53 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id d64so77601554wmh.1
        for <linux-mm@kvack.org>; Mon, 03 Oct 2016 03:59:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id yz4si34143429wjc.87.2016.10.03.03.59.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 03 Oct 2016 03:59:51 -0700 (PDT)
Date: Mon, 3 Oct 2016 12:59:49 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v4 10/12] dax: add struct iomap based DAX PMD support
Message-ID: <20161003105949.GP6457@quack2.suse.cz>
References: <1475189370-31634-1-git-send-email-ross.zwisler@linux.intel.com>
 <1475189370-31634-11-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1475189370-31634-11-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Thu 29-09-16 16:49:28, Ross Zwisler wrote:
> DAX PMDs have been disabled since Jan Kara introduced DAX radix tree based
> locking.  This patch allows DAX PMDs to participate in the DAX radix tree
> based locking scheme so that they can be re-enabled using the new struct
> iomap based fault handlers.
> 
> There are currently three types of DAX 4k entries: 4k zero pages, 4k DAX
> mappings that have an associated block allocation, and 4k DAX empty
> entries.  The empty entries exist to provide locking for the duration of a
> given page fault.
> 
> This patch adds three equivalent 2MiB DAX entries: Huge Zero Page (HZP)
> entries, PMD DAX entries that have associated block allocations, and 2 MiB
> DAX empty entries.
> 
> Unlike the 4k case where we insert a struct page* into the radix tree for
> 4k zero pages, for HZP we insert a DAX exceptional entry with the new
> RADIX_DAX_HZP flag set.  This is because we use a single 2 MiB zero page in
> every 2MiB hole mapping, and it doesn't make sense to have that same struct
> page* with multiple entries in multiple trees.  This would cause contention
> on the single page lock for the one Huge Zero Page, and it would break the
> page->index and page->mapping associations that are assumed to be valid in
> many other places in the kernel.
> 
> One difficult use case is when one thread is trying to use 4k entries in
> radix tree for a given offset, and another thread is using 2 MiB entries
> for that same offset.  The current code handles this by making the 2 MiB
> user fall back to 4k entries for most cases.  This was done because it is
> the simplest solution, and because the use of 2MiB pages is already
> opportunistic.
> 
> If we were to try to upgrade from 4k pages to 2MiB pages for a given range,
> we run into the problem of how we lock out 4k page faults for the entire
> 2MiB range while we clean out the radix tree so we can insert the 2MiB
> entry.  We can solve this problem if we need to, but I think that the cases
> where both 2MiB entries and 4K entries are being used for the same range
> will be rare enough and the gain small enough that it probably won't be
> worth the complexity.
...
>  restart:
>  	spin_lock_irq(&mapping->tree_lock);
>  	entry = get_unlocked_mapping_entry(mapping, index, &slot);
> +
> +	if (entry && new_type == RADIX_DAX_PMD) {
> +		if (!radix_tree_exceptional_entry(entry) ||
> +				RADIX_DAX_TYPE(entry) == RADIX_DAX_PTE) {
> +			spin_unlock_irq(&mapping->tree_lock);
> +			return ERR_PTR(-EEXIST);
> +		}
> +	} else if (entry && new_type == RADIX_DAX_PTE) {
> +		if (radix_tree_exceptional_entry(entry) &&
> +		    RADIX_DAX_TYPE(entry) == RADIX_DAX_PMD &&
> +		    (unsigned long)entry & (RADIX_DAX_HZP|RADIX_DAX_EMPTY)) {
> +			pmd_downgrade = true;
> +		}
> +	}
> +
>  	/* No entry for given index? Make sure radix tree is big enough. */
> -	if (!entry) {
> +	if (!entry || pmd_downgrade) {
>  		int err;
>  
>  		spin_unlock_irq(&mapping->tree_lock);
> @@ -420,15 +439,39 @@ restart:
>  				mapping_gfp_mask(mapping) & ~__GFP_HIGHMEM);
>  		if (err)
>  			return ERR_PTR(err);
> -		entry = (void *)(RADIX_TREE_EXCEPTIONAL_ENTRY |
> -			       RADIX_DAX_ENTRY_LOCK);
> +
> +		/*
> +		 * Besides huge zero pages the only other thing that gets
> +		 * downgraded are empty entries which don't need to be
> +		 * unmapped.
> +		 */
> +		if (pmd_downgrade && ((unsigned long)entry & RADIX_DAX_HZP))
> +			unmap_mapping_range(mapping,
> +				(index << PAGE_SHIFT) & PMD_MASK, PMD_SIZE, 0);
> +
>  		spin_lock_irq(&mapping->tree_lock);
> -		err = radix_tree_insert(&mapping->page_tree, index, entry);
> +
> +		if (pmd_downgrade) {
> +			radix_tree_delete(&mapping->page_tree, index);
> +			mapping->nrexceptional--;
> +			dax_wake_mapping_entry_waiter(entry, mapping, index,
> +					false);
> +		}

Hum, this looks really problematic. Once you have dropped tree_lock,
anything could have happened with the radix tree - in particular the entry
you've got from get_unlocked_mapping_entry() can be different by now. Also
there's no guarantee that someone does not map the huge entry again just
after your call to unmap_mapping_range() finished.

So it seems you need to lock the entry (if you have one) before releasing
tree_lock to stabilize it. That is enough also to block other mappings of
that entry. Then once you reacquire the tree_lock, you can safely delete it
and replace it with a different entry.

> +
> +		entry = RADIX_DAX_EMPTY_ENTRY(new_type);
> +
> +		err = __radix_tree_insert(&mapping->page_tree, index,
> +				RADIX_DAX_ORDER(new_type), entry);
>  		radix_tree_preload_end();
>  		if (err) {
>  			spin_unlock_irq(&mapping->tree_lock);
> -			/* Someone already created the entry? */
> -			if (err == -EEXIST)
> +			/*
> +			 * Someone already created the entry?  This is a
> +			 * normal failure when inserting PMDs in a range
> +			 * that already contains PTEs.  In that case we want
> +			 * to return -EEXIST immediately.
> +			 */
> +			if (err == -EEXIST && new_type == RADIX_DAX_PTE)
>  				goto restart;
>  			return ERR_PTR(err);
>  		}
> @@ -596,11 +639,17 @@ static int copy_user_dax(struct block_device *bdev, sector_t sector, size_t size
>  	return 0;
>  }
>  
> -#define DAX_PMD_INDEX(page_index) (page_index & (PMD_MASK >> PAGE_SHIFT))
> -
> +/*
> + * By this point grab_mapping_entry() has ensured that we have a locked entry
> + * of the appropriate size so we don't have to worry about downgrading PMDs to
> + * PTEs.  If we happen to be trying to insert a PTE and there is a PMD
> + * already in the tree, we will skip the insertion and just dirty the PMD as
> + * appropriate.
> + */
>  static void *dax_insert_mapping_entry(struct address_space *mapping,
>  				      struct vm_fault *vmf,
> -				      void *entry, sector_t sector)
> +				      void *entry, sector_t sector,
> +				      unsigned long new_type, bool hzp)
>  {
>  	struct radix_tree_root *page_tree = &mapping->page_tree;
>  	int error = 0;
> @@ -623,22 +672,30 @@ static void *dax_insert_mapping_entry(struct address_space *mapping,
>  		error = radix_tree_preload(vmf->gfp_mask & ~__GFP_HIGHMEM);
>  		if (error)
>  			return ERR_PTR(error);
> +	} else if ((unsigned long)entry & RADIX_DAX_HZP && !hzp) {
> +		/* replacing huge zero page with PMD block mapping */
> +		unmap_mapping_range(mapping,
> +			(vmf->pgoff << PAGE_SHIFT) & PMD_MASK, PMD_SIZE, 0);
>  	}
>  
>  	spin_lock_irq(&mapping->tree_lock);
> -	new_entry = (void *)((unsigned long)RADIX_DAX_ENTRY(sector, false) |
> -		       RADIX_DAX_ENTRY_LOCK);
> +	if (hzp)
> +		new_entry = RADIX_DAX_HZP_ENTRY();
> +	else
> +		new_entry = RADIX_DAX_ENTRY(sector, new_type);
> +
>  	if (hole_fill) {
>  		__delete_from_page_cache(entry, NULL);
>  		/* Drop pagecache reference */
>  		put_page(entry);
> -		error = radix_tree_insert(page_tree, index, new_entry);
> +		error = __radix_tree_insert(page_tree, index,
> +				RADIX_DAX_ORDER(new_type), new_entry);
>  		if (error) {
>  			new_entry = ERR_PTR(error);
>  			goto unlock;
>  		}
>  		mapping->nrexceptional++;
> -	} else {
> +	} else if ((unsigned long)entry & (RADIX_DAX_HZP|RADIX_DAX_EMPTY)) {
>  		void **slot;
>  		void *ret;

Hum, I somewhat dislike how PTE and PMD paths differ here. But it's OK for
now I guess. Long term we might be better off to do away with zero pages
for PTEs as well and use exceptional entry and a single zero page like you
do for PMD. Because the special cases these zero pages cause are a
headache.

>  
> @@ -694,6 +751,18 @@ static int dax_writeback_one(struct block_device *bdev,
>  		goto unlock;
>  	}
>  
> +	if (WARN_ON_ONCE((unsigned long)entry & RADIX_DAX_EMPTY)) {
> +		ret = -EIO;
> +		goto unlock;
> +	}
> +
> +	/*
> +	 * Even if dax_writeback_mapping_range() was given a wbc->range_start
> +	 * in the middle of a PMD, the 'index' we are given will be aligned to
> +	 * the start index of the PMD, as will the sector we pull from
> +	 * 'entry'.  This allows us to flush for PMD_SIZE and not have to
> +	 * worry about partial PMD writebacks.
> +	 */
>  	dax.sector = RADIX_DAX_SECTOR(entry);
>  	dax.size = (type == RADIX_DAX_PMD ? PMD_SIZE : PAGE_SIZE);
>  	spin_unlock_irq(&mapping->tree_lock);

<snip>

> +int dax_iomap_pmd_fault(struct vm_area_struct *vma, unsigned long address,
> +		pmd_t *pmd, unsigned int flags, struct iomap_ops *ops)
> +{
> +	struct address_space *mapping = vma->vm_file->f_mapping;
> +	unsigned long pmd_addr = address & PMD_MASK;
> +	bool write = flags & FAULT_FLAG_WRITE;
> +	struct inode *inode = mapping->host;
> +	struct iomap iomap = { 0 };
> +	int error, result = 0;
> +	pgoff_t size, pgoff;
> +	struct vm_fault vmf;
> +	void *entry;
> +	loff_t pos;
> +
> +	/* Fall back to PTEs if we're going to COW */
> +	if (write && !(vma->vm_flags & VM_SHARED)) {
> +		split_huge_pmd(vma, pmd, address);
> +		return VM_FAULT_FALLBACK;
> +	}
> +
> +	/* If the PMD would extend outside the VMA */
> +	if (pmd_addr < vma->vm_start)
> +		return VM_FAULT_FALLBACK;
> +	if ((pmd_addr + PMD_SIZE) > vma->vm_end)
> +		return VM_FAULT_FALLBACK;
> +
> +	/*
> +	 * Check whether offset isn't beyond end of file now. Caller is
> +	 * supposed to hold locks serializing us with truncate / punch hole so
> +	 * this is a reliable test.
> +	 */
> +	pgoff = linear_page_index(vma, pmd_addr);
> +	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
> +
> +	if (pgoff >= size)
> +		return VM_FAULT_SIGBUS;
> +
> +	/* If the PMD would extend beyond the file size */
> +	if ((pgoff | PG_PMD_COLOUR) >= size)
> +		return VM_FAULT_FALLBACK;
> +
> +	/*
> +	 * grab_mapping_entry() will make sure we get a 2M empty entry, a DAX
> +	 * PMD or a HZP entry.  If it can't (because a 4k page is already in
> +	 * the tree, for instance), it will return -EEXIST and we just fall
> +	 * back to 4k entries.
> +	 */
> +	entry = grab_mapping_entry(mapping, pgoff, RADIX_DAX_PMD);
> +	if (IS_ERR(entry))
> +		return VM_FAULT_FALLBACK;
> +
> +	/*
> +	 * Note that we don't use iomap_apply here.  We aren't doing I/O, only
> +	 * setting up a mapping, so really we're using iomap_begin() as a way
> +	 * to look up our filesystem block.
> +	 */
> +	pos = (loff_t)pgoff << PAGE_SHIFT;
> +	error = ops->iomap_begin(inode, pos, PMD_SIZE, write ? IOMAP_WRITE : 0,
> +			&iomap);

I'm not quite sure if it is OK to call ->iomap_begin() without ever calling
->iomap_end. Specifically the comment before iomap_apply() says:

"It is assumed that the filesystems will lock whatever resources they
require in the iomap_begin call, and release them in the iomap_end call."

so what you do could result in unbalanced allocations / locks / whatever.
Christoph?

> +	if (error)
> +		goto fallback;
> +	if (iomap.offset + iomap.length < pos + PMD_SIZE)
> +		goto fallback;
> +
> +	vmf.pgoff = pgoff;
> +	vmf.flags = flags;
> +	vmf.gfp_mask = mapping_gfp_mask(mapping) | __GFP_FS | __GFP_IO;

I don't think you want __GFP_FS here - we have already gone through the
filesystem's pmd_fault() handler which called dax_iomap_pmd_fault() and
thus we hold various fs locks, freeze protection, ...

> +
> +	switch (iomap.type) {
> +	case IOMAP_MAPPED:
> +		result = dax_pmd_insert_mapping(vma, pmd, &vmf, address,
> +				&iomap, pos, write, &entry);
> +		break;
> +	case IOMAP_UNWRITTEN:
> +	case IOMAP_HOLE:
> +		if (WARN_ON_ONCE(write))
> +			goto fallback;
> +		result = dax_pmd_load_hole(vma, pmd, &vmf, address, &iomap,
> +				&entry);
> +		break;
> +	default:
> +		WARN_ON_ONCE(1);
> +		result = VM_FAULT_FALLBACK;
> +		break;
> +	}
> +
> +	if (result == VM_FAULT_FALLBACK)
> +		count_vm_event(THP_FAULT_FALLBACK);
> +
> + unlock_entry:
> +	put_locked_mapping_entry(mapping, pgoff, entry);
> +	return result;
> +
> + fallback:
> +	count_vm_event(THP_FAULT_FALLBACK);
> +	result = VM_FAULT_FALLBACK;
> +	goto unlock_entry;
> +}
> +EXPORT_SYMBOL_GPL(dax_iomap_pmd_fault);
> +#endif /* CONFIG_FS_DAX_PMD */
>  #endif /* CONFIG_FS_IOMAP */
> diff --git a/include/linux/dax.h b/include/linux/dax.h
> index c4a51bb..cacff9e 100644
> --- a/include/linux/dax.h
> +++ b/include/linux/dax.h
> @@ -8,8 +8,33 @@
>  
>  struct iomap_ops;
>  
> -/* We use lowest available exceptional entry bit for locking */
> +/*
> + * We use lowest available bit in exceptional entry for locking, two bits for
> + * the entry type (PMD & PTE), and two more for flags (HZP and empty).  In
> + * total five special bits.
> + */
> +#define RADIX_DAX_SHIFT	(RADIX_TREE_EXCEPTIONAL_SHIFT + 5)
>  #define RADIX_DAX_ENTRY_LOCK (1 << RADIX_TREE_EXCEPTIONAL_SHIFT)
> +/* PTE and PMD types */
> +#define RADIX_DAX_PTE (1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 1))
> +#define RADIX_DAX_PMD (1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 2))
> +/* huge zero page and empty entry flags */
> +#define RADIX_DAX_HZP (1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 3))
> +#define RADIX_DAX_EMPTY (1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 4))

I think we can do with just 2 bits for type instead of 4 but for now this
is OK I guess.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
