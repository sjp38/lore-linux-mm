Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 49B5C6B0038
	for <linux-mm@kvack.org>; Mon,  3 Oct 2016 17:06:01 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id fi2so360111134pad.3
        for <linux-mm@kvack.org>; Mon, 03 Oct 2016 14:06:01 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id m5si38536649pfm.117.2016.10.03.14.06.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 03 Oct 2016 14:06:00 -0700 (PDT)
Date: Mon, 3 Oct 2016 15:05:57 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v4 10/12] dax: add struct iomap based DAX PMD support
Message-ID: <20161003210557.GA28177@linux.intel.com>
References: <1475189370-31634-1-git-send-email-ross.zwisler@linux.intel.com>
 <1475189370-31634-11-git-send-email-ross.zwisler@linux.intel.com>
 <20161003105949.GP6457@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161003105949.GP6457@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Mon, Oct 03, 2016 at 12:59:49PM +0200, Jan Kara wrote:
> On Thu 29-09-16 16:49:28, Ross Zwisler wrote:
> > @@ -420,15 +439,39 @@ restart:
> >  				mapping_gfp_mask(mapping) & ~__GFP_HIGHMEM);
> >  		if (err)
> >  			return ERR_PTR(err);
> > -		entry = (void *)(RADIX_TREE_EXCEPTIONAL_ENTRY |
> > -			       RADIX_DAX_ENTRY_LOCK);
> > +
> > +		/*
> > +		 * Besides huge zero pages the only other thing that gets
> > +		 * downgraded are empty entries which don't need to be
> > +		 * unmapped.
> > +		 */
> > +		if (pmd_downgrade && ((unsigned long)entry & RADIX_DAX_HZP))
> > +			unmap_mapping_range(mapping,
> > +				(index << PAGE_SHIFT) & PMD_MASK, PMD_SIZE, 0);
> > +
> >  		spin_lock_irq(&mapping->tree_lock);
> > -		err = radix_tree_insert(&mapping->page_tree, index, entry);
> > +
> > +		if (pmd_downgrade) {
> > +			radix_tree_delete(&mapping->page_tree, index);
> > +			mapping->nrexceptional--;
> > +			dax_wake_mapping_entry_waiter(entry, mapping, index,
> > +					false);
> > +		}
> 
> Hum, this looks really problematic. Once you have dropped tree_lock,
> anything could have happened with the radix tree - in particular the entry
> you've got from get_unlocked_mapping_entry() can be different by now. Also
> there's no guarantee that someone does not map the huge entry again just
> after your call to unmap_mapping_range() finished.
> 
> So it seems you need to lock the entry (if you have one) before releasing
> tree_lock to stabilize it. That is enough also to block other mappings of
> that entry. Then once you reacquire the tree_lock, you can safely delete it
> and replace it with a different entry.

Yep, great catch.  I'll lock the entry before I drop tree_lock.

> > @@ -623,22 +672,30 @@ static void *dax_insert_mapping_entry(struct address_space *mapping,
> >  		error = radix_tree_preload(vmf->gfp_mask & ~__GFP_HIGHMEM);
> >  		if (error)
> >  			return ERR_PTR(error);
> > +	} else if ((unsigned long)entry & RADIX_DAX_HZP && !hzp) {
> > +		/* replacing huge zero page with PMD block mapping */
> > +		unmap_mapping_range(mapping,
> > +			(vmf->pgoff << PAGE_SHIFT) & PMD_MASK, PMD_SIZE, 0);
> >  	}
> >  
> >  	spin_lock_irq(&mapping->tree_lock);
> > -	new_entry = (void *)((unsigned long)RADIX_DAX_ENTRY(sector, false) |
> > -		       RADIX_DAX_ENTRY_LOCK);
> > +	if (hzp)
> > +		new_entry = RADIX_DAX_HZP_ENTRY();
> > +	else
> > +		new_entry = RADIX_DAX_ENTRY(sector, new_type);
> > +
> >  	if (hole_fill) {
> >  		__delete_from_page_cache(entry, NULL);
> >  		/* Drop pagecache reference */
> >  		put_page(entry);
> > -		error = radix_tree_insert(page_tree, index, new_entry);
> > +		error = __radix_tree_insert(page_tree, index,
> > +				RADIX_DAX_ORDER(new_type), new_entry);
> >  		if (error) {
> >  			new_entry = ERR_PTR(error);
> >  			goto unlock;
> >  		}
> >  		mapping->nrexceptional++;
> > -	} else {
> > +	} else if ((unsigned long)entry & (RADIX_DAX_HZP|RADIX_DAX_EMPTY)) {
> >  		void **slot;
> >  		void *ret;
> 
> Hum, I somewhat dislike how PTE and PMD paths differ here. But it's OK for
> now I guess. Long term we might be better off to do away with zero pages
> for PTEs as well and use exceptional entry and a single zero page like you
> do for PMD. Because the special cases these zero pages cause are a
> headache.

I've been thinking about this as well, and I do think we'd be better off with
a single zero page for PTEs, as we have with PMDs.  It'd reduce the special
casing in the DAX code, and it'd also ensure that we don't waste a bunch of
time and memory creating read-only zero pages to service reads from holes.

I'll look into adding this for v5.

> > +int dax_iomap_pmd_fault(struct vm_area_struct *vma, unsigned long address,
> > +		pmd_t *pmd, unsigned int flags, struct iomap_ops *ops)
> > +{
> > +	struct address_space *mapping = vma->vm_file->f_mapping;
> > +	unsigned long pmd_addr = address & PMD_MASK;
> > +	bool write = flags & FAULT_FLAG_WRITE;
> > +	struct inode *inode = mapping->host;
> > +	struct iomap iomap = { 0 };
> > +	int error, result = 0;
> > +	pgoff_t size, pgoff;
> > +	struct vm_fault vmf;
> > +	void *entry;
> > +	loff_t pos;
> > +
> > +	/* Fall back to PTEs if we're going to COW */
> > +	if (write && !(vma->vm_flags & VM_SHARED)) {
> > +		split_huge_pmd(vma, pmd, address);
> > +		return VM_FAULT_FALLBACK;
> > +	}
> > +
> > +	/* If the PMD would extend outside the VMA */
> > +	if (pmd_addr < vma->vm_start)
> > +		return VM_FAULT_FALLBACK;
> > +	if ((pmd_addr + PMD_SIZE) > vma->vm_end)
> > +		return VM_FAULT_FALLBACK;
> > +
> > +	/*
> > +	 * Check whether offset isn't beyond end of file now. Caller is
> > +	 * supposed to hold locks serializing us with truncate / punch hole so
> > +	 * this is a reliable test.
> > +	 */
> > +	pgoff = linear_page_index(vma, pmd_addr);
> > +	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
> > +
> > +	if (pgoff >= size)
> > +		return VM_FAULT_SIGBUS;
> > +
> > +	/* If the PMD would extend beyond the file size */
> > +	if ((pgoff | PG_PMD_COLOUR) >= size)
> > +		return VM_FAULT_FALLBACK;
> > +
> > +	/*
> > +	 * grab_mapping_entry() will make sure we get a 2M empty entry, a DAX
> > +	 * PMD or a HZP entry.  If it can't (because a 4k page is already in
> > +	 * the tree, for instance), it will return -EEXIST and we just fall
> > +	 * back to 4k entries.
> > +	 */
> > +	entry = grab_mapping_entry(mapping, pgoff, RADIX_DAX_PMD);
> > +	if (IS_ERR(entry))
> > +		return VM_FAULT_FALLBACK;
> > +
> > +	/*
> > +	 * Note that we don't use iomap_apply here.  We aren't doing I/O, only
> > +	 * setting up a mapping, so really we're using iomap_begin() as a way
> > +	 * to look up our filesystem block.
> > +	 */
> > +	pos = (loff_t)pgoff << PAGE_SHIFT;
> > +	error = ops->iomap_begin(inode, pos, PMD_SIZE, write ? IOMAP_WRITE : 0,
> > +			&iomap);
> 
> I'm not quite sure if it is OK to call ->iomap_begin() without ever calling
> ->iomap_end. Specifically the comment before iomap_apply() says:
> 
> "It is assumed that the filesystems will lock whatever resources they
> require in the iomap_begin call, and release them in the iomap_end call."
> 
> so what you do could result in unbalanced allocations / locks / whatever.
> Christoph?

I'll add the iomap_end() calls to both the PTE and PMD iomap fault handlers.

> > +	if (error)
> > +		goto fallback;
> > +	if (iomap.offset + iomap.length < pos + PMD_SIZE)
> > +		goto fallback;
> > +
> > +	vmf.pgoff = pgoff;
> > +	vmf.flags = flags;
> > +	vmf.gfp_mask = mapping_gfp_mask(mapping) | __GFP_FS | __GFP_IO;
> 
> I don't think you want __GFP_FS here - we have already gone through the
> filesystem's pmd_fault() handler which called dax_iomap_pmd_fault() and
> thus we hold various fs locks, freeze protection, ...

I copied this from __get_fault_gfp_mask() in mm/memory.c.  That function is
used by do_page_mkwrite() and __do_fault(), and we eventually get this
vmf->gfp_mask in the PTE fault code.  With the code as it is we get the same
vmf->gfp_mask in both dax_iomap_fault() and dax_iomap_pmd_fault().  It seems
like they should remain consistent - is it wrong to have __GFP_FS in
dax_iomap_fault()?

> > diff --git a/include/linux/dax.h b/include/linux/dax.h
> > index c4a51bb..cacff9e 100644
> > --- a/include/linux/dax.h
> > +++ b/include/linux/dax.h
> > @@ -8,8 +8,33 @@
> >  
> >  struct iomap_ops;
> >  
> > -/* We use lowest available exceptional entry bit for locking */
> > +/*
> > + * We use lowest available bit in exceptional entry for locking, two bits for
> > + * the entry type (PMD & PTE), and two more for flags (HZP and empty).  In
> > + * total five special bits.
> > + */
> > +#define RADIX_DAX_SHIFT	(RADIX_TREE_EXCEPTIONAL_SHIFT + 5)
> >  #define RADIX_DAX_ENTRY_LOCK (1 << RADIX_TREE_EXCEPTIONAL_SHIFT)
> > +/* PTE and PMD types */
> > +#define RADIX_DAX_PTE (1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 1))
> > +#define RADIX_DAX_PMD (1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 2))
> > +/* huge zero page and empty entry flags */
> > +#define RADIX_DAX_HZP (1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 3))
> > +#define RADIX_DAX_EMPTY (1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 4))
> 
> I think we can do with just 2 bits for type instead of 4 but for now this
> is OK I guess.

I guess we could combine the PMD/PTE choice into the same bit (0=PTE, 1=PMD),
but we have three cases for the other types (zero page, empty entry just for
locking, real DAX based entry with storage), so we need at least 2 bits for
those.

Christoph also suggested some reworks to the "type" logic - I'll look at
simplifying the way the flags are used for DAX entries.

Thank you for the review!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
