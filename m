Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 513046B0253
	for <linux-mm@kvack.org>; Tue, 28 Jun 2016 17:38:59 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e189so60944192pfa.2
        for <linux-mm@kvack.org>; Tue, 28 Jun 2016 14:38:59 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id y89si412204pff.0.2016.06.28.14.38.58
        for <linux-mm@kvack.org>;
        Tue, 28 Jun 2016 14:38:58 -0700 (PDT)
Date: Tue, 28 Jun 2016 15:38:57 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 3/3] dax: Clear dirty entry tags on cache flush
Message-ID: <20160628213857.GA15457@linux.intel.com>
References: <1466523915-14644-1-git-send-email-jack@suse.cz>
 <1466523915-14644-4-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1466523915-14644-4-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Tue, Jun 21, 2016 at 05:45:15PM +0200, Jan Kara wrote:
> Currently we never clear dirty tags in DAX mappings and thus address
> ranges to flush accumulate. Now that we have locking of radix tree
> entries, we have all the locking necessary to reliably clear the radix
> tree dirty tag when flushing caches for corresponding address range.
> Similarly to page_mkclean() we also have to write-protect pages to get a
> page fault when the page is next written to so that we can mark the
> entry dirty again.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

I think we still have a race where we can end up with a writeable PTE but a
clean DAX radix tree entry.  Here is the flow:

Thread 1					Thread 2
======== 					========
wp_pfn_shared()
  dax_pfn_mkwrite()
    get_unlocked_mapping_entry()
    radix_tree_tag_set(DIRTY)
    put_unlocked_mapping_entry()
						dax_writeback_one()
						  lock_slot()
						  radix_tree_tag_clear(TOWRITE)
						  dax_mapping_entry_mkclean()
						  wb_cache_pmem()
						  radix_tree_tag_clear(DIRTY)
						  put_locked_mapping_entry()
  wp_page_reuse()
    maybe_mkwrite()

When this ends the radix tree entry will have been written back and the
TOWRITE and DIRTY radix tree tags will have been cleared, but the PTE will be
writeable due to the last maybe_mkwrite() call.  This will result in no new
dax_pfn_mkwrite() calls happening to re-dirty the radix tree entry.

Essentially the problem is that we don't hold any locks through all the work
done by wp_pfn_shared() so that we can do maybe_mkwrite() safely.

Perhaps we can lock the radix tree slot in dax_pfn_mkwrite(), then have
another callback into DAX after the wp_page_reuse() => maybe_mkwrite() to
unlock the slot?  This would guarantee that they happen together from DAX's
point of view.

Thread 1's flow would then be:

Thread 1
========
wp_pfn_shared()
  dax_pfn_mkwrite()
    lock_slot()
    radix_tree_tag_set(DIRTY)
  wp_page_reuse()
    maybe_mkwrite()
    new_dax_call_to_unlock_slot()
      put_unlocked_mapping_entry()

> ---
>  fs/dax.c | 69 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 68 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index 5209f8cd0bee..c0c4eecb5f73 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -31,6 +31,7 @@
>  #include <linux/vmstat.h>
>  #include <linux/pfn_t.h>
>  #include <linux/sizes.h>
> +#include <linux/mmu_notifier.h>
>  
>  /*
>   * We use lowest available bit in exceptional entry for locking, other two
> @@ -665,6 +666,59 @@ static void *dax_insert_mapping_entry(struct address_space *mapping,
>  	return new_entry;
>  }
>  
> +static inline unsigned long
> +pgoff_address(pgoff_t pgoff, struct vm_area_struct *vma)
> +{
> +	unsigned long address;
> +
> +	address = vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
> +	VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma);
> +	return address;
> +}
> +
> +/* Walk all mappings of a given index of a file and writeprotect them */
> +static void dax_mapping_entry_mkclean(struct address_space *mapping,
> +				      pgoff_t index, unsigned long pfn)
> +{
> +	struct vm_area_struct *vma;
> +	pte_t *ptep;
> +	pte_t pte;
> +	spinlock_t *ptl;
> +	bool changed;
> +
> +	i_mmap_lock_read(mapping);
> +	vma_interval_tree_foreach(vma, &mapping->i_mmap, index, index) {
> +		unsigned long address;
> +
> +		cond_resched();

Do we really need to cond_resched() between every PTE clean?  Maybe it would
be better to cond_resched() after each call to dax_writeback_one() in
dax_writeback_mapping_range() or something so we can be sure we've done a good
amount of work between each?

> +
> +		if (!(vma->vm_flags & VM_SHARED))
> +			continue;
> +
> +		address = pgoff_address(index, vma);
> +		changed = false;
> +		if (follow_pte(vma->vm_mm, address, &ptep, &ptl))
> +			continue;
> +		if (pfn != pte_pfn(*ptep))
> +			goto unlock;
> +		if (!pte_dirty(*ptep) && !pte_write(*ptep))
> +			goto unlock;
> +
> +		flush_cache_page(vma, address, pfn);
> +		pte = ptep_clear_flush(vma, address, ptep);
> +		pte = pte_wrprotect(pte);
> +		pte = pte_mkclean(pte);
> +		set_pte_at(vma->vm_mm, address, ptep, pte);
> +		changed = true;
> +unlock:
> +		pte_unmap_unlock(pte, ptl);
> +
> +		if (changed)
> +			mmu_notifier_invalidate_page(vma->vm_mm, address);
> +	}
> +	i_mmap_unlock_read(mapping);
> +}
> +
>  static int dax_writeback_one(struct block_device *bdev,
>  		struct address_space *mapping, pgoff_t index, void *entry)
>  {
> @@ -723,17 +777,30 @@ static int dax_writeback_one(struct block_device *bdev,
>  	 * eventually calls cond_resched().
>  	 */
>  	ret = dax_map_atomic(bdev, &dax);
> -	if (ret < 0)
> +	if (ret < 0) {
> +		put_locked_mapping_entry(mapping, index, entry);
>  		return ret;
> +	}
>  
>  	if (WARN_ON_ONCE(ret < dax.size)) {
>  		ret = -EIO;
>  		goto unmap;
>  	}
>  
> +	dax_mapping_entry_mkclean(mapping, index, pfn_t_to_pfn(dax.pfn));
>  	wb_cache_pmem(dax.addr, dax.size);
> +	/*
> +	 * After we have flushed the cache, we can clear the dirty tag. There
> +	 * cannot be new dirty data in the pfn after the flush has completed as
> +	 * the pfn mappings are writeprotected and fault waits for mapping
> +	 * entry lock.
> +	 */
> +	spin_lock_irq(&mapping->tree_lock);
> +	radix_tree_tag_clear(page_tree, index, PAGECACHE_TAG_DIRTY);
> +	spin_unlock_irq(&mapping->tree_lock);
>  unmap:
>  	dax_unmap_atomic(bdev, &dax);
> +	put_locked_mapping_entry(mapping, index, entry);
>  	return ret;
>  
>  put_unlock:
> -- 
> 2.6.6
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
