Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 68C9A6B007E
	for <linux-mm@kvack.org>; Fri,  6 May 2016 00:13:53 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 4so206824972pfw.0
        for <linux-mm@kvack.org>; Thu, 05 May 2016 21:13:53 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id vy3si15628276pac.128.2016.05.05.21.13.52
        for <linux-mm@kvack.org>;
        Thu, 05 May 2016 21:13:52 -0700 (PDT)
Date: Thu, 5 May 2016 22:13:50 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 16/18] dax: New fault locking
Message-ID: <20160506041350.GA29628@linux.intel.com>
References: <1461015341-20153-1-git-send-email-jack@suse.cz>
 <1461015341-20153-17-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1461015341-20153-17-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>

On Mon, Apr 18, 2016 at 11:35:39PM +0200, Jan Kara wrote:
> Currently DAX page fault locking is racy.
> 
> CPU0 (write fault)		CPU1 (read fault)
> 
> __dax_fault()			__dax_fault()
>   get_block(inode, block, &bh, 0) -> not mapped
> 				  get_block(inode, block, &bh, 0)
> 				    -> not mapped
>   if (!buffer_mapped(&bh))
>     if (vmf->flags & FAULT_FLAG_WRITE)
>       get_block(inode, block, &bh, 1) -> allocates blocks
>   if (page) -> no
> 				  if (!buffer_mapped(&bh))
> 				    if (vmf->flags & FAULT_FLAG_WRITE) {
> 				    } else {
> 				      dax_load_hole();
> 				    }
>   dax_insert_mapping()
> 
> And we are in a situation where we fail in dax_radix_entry() with -EIO.
> 
> Another problem with the current DAX page fault locking is that there is
> no race-free way to clear dirty tag in the radix tree. We can always
> end up with clean radix tree and dirty data in CPU cache.
> 
> We fix the first problem by introducing locking of exceptional radix
> tree entries in DAX mappings acting very similarly to page lock and thus
> synchronizing properly faults against the same mapping index. The same
> lock can later be used to avoid races when clearing radix tree dirty
> tag.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
> @@ -300,6 +324,259 @@ ssize_t dax_do_io(struct kiocb *iocb, struct inode *inode,
>  EXPORT_SYMBOL_GPL(dax_do_io);
>  
>  /*
> + * DAX radix tree locking
> + */
> +struct exceptional_entry_key {
> +	struct radix_tree_root *root;
> +	unsigned long index;
> +};

I believe that we basically just need the struct exceptional_entry_key to
uniquely identify an entry, correct?  I agree that we get this with the pair
[struct radix_tree_root, index], but we also get it with
[struct address_space, index], and we might want to use the latter here since
that's the pair that is used to look up the wait queue in
dax_entry_waitqueue().  Functionally I don't think it matters (correct me if
I'm wrong), but it makes for a nicer symmetry.

> +/*
> + * Find radix tree entry at given index. If it points to a page, return with
> + * the page locked. If it points to the exceptional entry, return with the
> + * radix tree entry locked. If the radix tree doesn't contain given index,
> + * create empty exceptional entry for the index and return with it locked.
> + *
> + * Note: Unlike filemap_fault() we don't honor FAULT_FLAG_RETRY flags. For
> + * persistent memory the benefit is doubtful. We can add that later if we can
> + * show it helps.
> + */
> +static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index)
> +{
> +	void *ret, **slot;
> +
> +restart:
> +	spin_lock_irq(&mapping->tree_lock);
> +	ret = get_unlocked_mapping_entry(mapping, index, &slot);
> +	/* No entry for given index? Make sure radix tree is big enough. */
> +	if (!ret) {
> +		int err;
> +
> +		spin_unlock_irq(&mapping->tree_lock);
> +		err = radix_tree_preload(
> +				mapping_gfp_mask(mapping) & ~__GFP_HIGHMEM);

In the conversation about v2 of this series you said:

> Note that we take the hit for dropping the lock only if we really need to
> allocate new radix tree node so about once per 64 new entries. So it is not
> too bad.

I think this is incorrect.  We get here whenever we get a NULL return from
__radix_tree_lookup().  I believe that this happens if we don't have a node,
in which case we need an allocation, but I think it also happens in the case
where we do have a node and we just have a NULL slot in that node.

For the behavior you're looking for (only preload if you need to do an
allocation), you probably need to check the 'slot' we get back from
get_unlocked_mapping_entry(), yea?

> +/*
> + * Delete exceptional DAX entry at @index from @mapping. Wait for radix tree
> + * entry to get unlocked before deleting it.
> + */
> +int dax_delete_mapping_entry(struct address_space *mapping, pgoff_t index)
> +{
> +	void *entry;
> +
> +	spin_lock_irq(&mapping->tree_lock);
> +	entry = get_unlocked_mapping_entry(mapping, index, NULL);
> +	/*
> +	 * Caller should make sure radix tree modifications don't race and
> +	 * we have seen exceptional entry here before.
> +	 */
> +	if (WARN_ON_ONCE(!entry || !radix_tree_exceptional_entry(entry))) {

dax_delete_mapping_entry() is only called from clear_exceptional_entry().
With this new code we've changed the behavior of that call path a little.

In the various places where clear_exceptional_entry() is called, the code
batches up a bunch of entries in a pvec via pagevec_lookup_entries().  We
don't hold the mapping->tree_lock between the time this lookup happens and the
time that the entry is passed to clear_exceptional_entry(). This is why the
old code did a verification that the entry passed in matched what was still
currently present in the radix tree.  This was done in the DAX case via
radix_tree_delete_item(), and it was open coded in clear_exceptional_entry()
for the page cache case.  In both cases if the entry didn't match what was
currently in the tree, we bailed without doing anything.

This new code doesn't verify against the 'entry' passed to
clear_exceptional_entry(), but instead makes sure it is an exceptional entry
before removing, and if not it does a WARN_ON_ONCE().

This changes things because:

a) If the exceptional entry changed, say from a plain lock entry to an actual
DAX entry, we wouldn't notice, and we would just clear the latter out.  My
guess is that this is fine, I just wanted to call it out.

b) If we have a non-exceptional entry here now, say because our lock entry has
been swapped out for a zero page, we will WARN_ON_ONCE() and return without a
removal.  I think we may want to silence the WARN_ON_ONCE(), as I believe this
could happen during normal operation and we don't want to scare anyone. :)

> +/*
>   * The user has performed a load from a hole in the file.  Allocating
>   * a new page in the file would cause excessive storage usage for
>   * workloads with sparse files.  We allocate a page cache page instead.
> @@ -307,15 +584,24 @@ EXPORT_SYMBOL_GPL(dax_do_io);
>   * otherwise it will simply fall out of the page cache under memory
>   * pressure without ever having been dirtied.
>   */
> -static int dax_load_hole(struct address_space *mapping, struct page *page,
> -							struct vm_fault *vmf)
> +static int dax_load_hole(struct address_space *mapping, void *entry,
> +			 struct vm_fault *vmf)
>  {
> -	if (!page)
> -		page = find_or_create_page(mapping, vmf->pgoff,
> -						GFP_KERNEL | __GFP_ZERO);
> -	if (!page)
> -		return VM_FAULT_OOM;
> +	struct page *page;
> +
> +	/* Hole page already exists? Return it...  */
> +	if (!radix_tree_exceptional_entry(entry)) {
> +		vmf->page = entry;
> +		return VM_FAULT_LOCKED;
> +	}
>  
> +	/* This will replace locked radix tree entry with a hole page */
> +	page = find_or_create_page(mapping, vmf->pgoff,
> +				   vmf->gfp_mask | __GFP_ZERO);

This replacement happens via page_cache_tree_insert(), correct?  In this case,
who wakes up anyone waiting on the old lock entry that we just killed?  In the
non-hole case we would traverse through put_locked_mapping_entry(), but I
don't see that in the hole case.

> @@ -963,23 +1228,18 @@ EXPORT_SYMBOL_GPL(dax_pmd_fault);
>  int dax_pfn_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
>  {
>  	struct file *file = vma->vm_file;
> -	int error;
> -
> -	/*
> -	 * We pass NO_SECTOR to dax_radix_entry() because we expect that a
> -	 * RADIX_DAX_PTE entry already exists in the radix tree from a
> -	 * previous call to __dax_fault().  We just want to look up that PTE
> -	 * entry using vmf->pgoff and make sure the dirty tag is set.  This
> -	 * saves us from having to make a call to get_block() here to look
> -	 * up the sector.
> -	 */
> -	error = dax_radix_entry(file->f_mapping, vmf->pgoff, NO_SECTOR, false,
> -			true);
> +	struct address_space *mapping = file->f_mapping;
> +	void *entry;
> +	pgoff_t index = vmf->pgoff;
>  
> -	if (error == -ENOMEM)
> -		return VM_FAULT_OOM;
> -	if (error)
> -		return VM_FAULT_SIGBUS;
> +	spin_lock_irq(&mapping->tree_lock);
> +	entry = get_unlocked_mapping_entry(mapping, index, NULL);
> +	if (!entry || !radix_tree_exceptional_entry(entry))
> +		goto out;
> +	radix_tree_tag_set(&mapping->page_tree, index, PAGECACHE_TAG_DIRTY);
> +	put_unlocked_mapping_entry(mapping, index, entry);

I really like how simple this function has become. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
