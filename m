Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A883B6B0262
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 03:45:09 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id c78so4643652wme.1
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 00:45:09 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b11si8855311wjs.147.2016.10.12.00.45.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Oct 2016 00:45:08 -0700 (PDT)
Date: Wed, 12 Oct 2016 09:45:05 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v5 15/17] dax: add struct iomap based DAX PMD support
Message-ID: <20161012074505.GC13896@quack2.suse.cz>
References: <1475874544-24842-1-git-send-email-ross.zwisler@linux.intel.com>
 <1475874544-24842-16-git-send-email-ross.zwisler@linux.intel.com>
 <20161011083152.GG6952@quack2.suse.cz>
 <20161011225130.GC32165@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161011225130.GC32165@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Tue 11-10-16 16:51:30, Ross Zwisler wrote:
> On Tue, Oct 11, 2016 at 10:31:52AM +0200, Jan Kara wrote:
> > On Fri 07-10-16 15:09:02, Ross Zwisler wrote:
> > > diff --git a/fs/dax.c b/fs/dax.c
> > > index ac3cd05..e51d51f 100644
> > > --- a/fs/dax.c
> > > +++ b/fs/dax.c
> > > @@ -281,7 +281,7 @@ static wait_queue_head_t *dax_entry_waitqueue(struct address_space *mapping,
> > >  	 * queue to the start of that PMD.  This ensures that all offsets in
> > >  	 * the range covered by the PMD map to the same bit lock.
> > >  	 */
> > > -	if (RADIX_DAX_TYPE(entry) == RADIX_DAX_PMD)
> > > +	if ((unsigned long)entry & RADIX_DAX_PMD)
> > >  		index &= ~((1UL << (PMD_SHIFT - PAGE_SHIFT)) - 1);
> > 
> > I agree with Christoph - helper for masking type bits would make this
> > nicer.
> 
> Fixed via a dax_flag_test() helper as I outlined in the mail to Christoph.  It
> seems clean to me, but if you or Christoph feel strongly that it would be
> cleaner as a local 'flags' variable, I'll make the change.

One idea I had is that you could have helpers like:

dax_is_pmd_entry()
dax_is_pte_entry()
dax_is_empty_entry()
dax_is_hole_entry()

And then you would use these helpers - all the flags would be hidden in the
helpers so even if we decide to change the flagging scheme to compress
things or so, it should be pretty local change.

> > > -		entry = (void *)(RADIX_TREE_EXCEPTIONAL_ENTRY |
> > > -			       RADIX_DAX_ENTRY_LOCK);
> > > +
> > > +		/*
> > > +		 * Besides huge zero pages the only other thing that gets
> > > +		 * downgraded are empty entries which don't need to be
> > > +		 * unmapped.
> > > +		 */
> > > +		if (pmd_downgrade && ((unsigned long)entry & RADIX_DAX_HZP))
> > > +			unmap_mapping_range(mapping,
> > > +				(index << PAGE_SHIFT) & PMD_MASK, PMD_SIZE, 0);
> > > +
> > >  		spin_lock_irq(&mapping->tree_lock);
> > > -		err = radix_tree_insert(&mapping->page_tree, index, entry);
> > > +
> > > +		if (pmd_downgrade) {
> > > +			radix_tree_delete(&mapping->page_tree, index);
> > > +			mapping->nrexceptional--;
> > > +			dax_wake_mapping_entry_waiter(mapping, index, entry,
> > > +					false);
> > 
> > You need to set 'wake_all' argument here to true. Otherwise there could be
> > waiters waiting for non-existent entry forever...
> 
> Interesting.   Fixed, but let me make sure I understand.  So is the issue that
> you could have say 2 tasks waiting on a PMD index that has been rounded down
> to the PMD index via dax_entry_waitqueue()?
> 
> The person holding the lock on the entry would remove the PMD, insert a PTE
> and wake just one of the PMD aligned waiters.  That waiter would wake up, do
> something PTE based (since the PMD space is now polluted with PTEs), and then
> wake any waiters on it's PTE index.  Meanwhile, the second waiter could sleep
> forever on the PMD aligned index.  Is this correct?

Yes.

> So, perhaps more succinctly:
> 
> Thread 1		Thread 2		Thread 3
> --------		--------		--------
> index 0x202, hold PMD lock 0x200
> 			index 0x203, sleep on 0x200
> 						index 0x204, sleep on 0x200
> downgrade, removing 0x200
> wake one waiter on 0x200
> insert PTE @ 0x202
> 			wake up, grab index 0x203
> 			...
> 			wake one waiter on index 0x203
> 
> 						... sleeps forever
> Right?
 
Exactly.

> > > @@ -608,22 +683,28 @@ static void *dax_insert_mapping_entry(struct address_space *mapping,
> > >  		error = radix_tree_preload(vmf->gfp_mask & ~__GFP_HIGHMEM);
> > >  		if (error)
> > >  			return ERR_PTR(error);
> > > +	} else if (((unsigned long)entry & RADIX_DAX_HZP) &&
> > > +			!(flags & RADIX_DAX_HZP)) {
> > > +		/* replacing huge zero page with PMD block mapping */
> > > +		unmap_mapping_range(mapping,
> > > +			(vmf->pgoff << PAGE_SHIFT) & PMD_MASK, PMD_SIZE, 0);
> > >  	}
> > >  
> > >  	spin_lock_irq(&mapping->tree_lock);
> > > -	new_entry = (void *)((unsigned long)RADIX_DAX_ENTRY(sector, false) |
> > > -		       RADIX_DAX_ENTRY_LOCK);
> > > +	new_entry = dax_radix_entry(sector, flags);
> > > +
> > 
> > You've lost the RADIX_DAX_ENTRY_LOCK flag here?
> 
> Oh, nope, that's embedded in the dax_radix_entry() helper:
> 
> /* entries begin locked */
> static inline void *dax_radix_entry(sector_t sector, unsigned long flags)
> {
> 	return (void *)(RADIX_TREE_EXCEPTIONAL_ENTRY | flags |
> 			((unsigned long)sector << RADIX_DAX_SHIFT) |
> 			RADIX_DAX_ENTRY_LOCK);
> }
> 
> I'll s/dax_radix_entry/dax_radix_locked_entry/ or something to make this
> clearer to the reader.

Yep, that would be better. Thanks!

> > >  	if (hole_fill) {
> > >  		__delete_from_page_cache(entry, NULL);
> > >  		/* Drop pagecache reference */
> > >  		put_page(entry);
> > > -		error = radix_tree_insert(page_tree, index, new_entry);
> > > +		error = __radix_tree_insert(page_tree, index,
> > > +				dax_radix_order(new_entry), new_entry);
> > >  		if (error) {
> > >  			new_entry = ERR_PTR(error);
> > >  			goto unlock;
> > >  		}
> > >  		mapping->nrexceptional++;
> > > -	} else {
> > > +	} else if ((unsigned long)entry & (RADIX_DAX_HZP|RADIX_DAX_EMPTY)) {
> > >  		void **slot;
> > >  		void *ret;
> > 
> > Uh, why this condition need to change? Is it some protection so that we
> > don't replace a mapped PMD entry with PTE one?
> 
> Yea, the logic was that if we have a radix tree that has PMDs in it, and some
> new process comes along doing PTE faults, we can just leave the DAX mapped PMD
> entries in the tree.  Locking, dirtying and flushing will happen on PMD basis
> for all processes.

Yup, I got this and I agree with that.

> If you think this is dangerous or not worth the effort we can make it like the
> hole case where any PTE sized faults will result in an unmap and a downgrade
> to PTE sized entries in the radix tree.

Ok, so probably I'm somewhat surprised that the logic that mapped PMD entry
is not replaced by a PTE entry is handled down in
dax_insert_mapping_entry(). But now looking at this it is just how we work
in other cases as well so please just add a comment there.

Longer term we may just shortcut the fault if grab_mapping_entry() will
return us entry of type we can use. That can save us quite some work if
several processes are mapping the same file. But again that's an
optimization to do once the PMD, iomap, and page protection works settle.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
