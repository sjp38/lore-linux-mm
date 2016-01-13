Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id DC957828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 02:37:19 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id cy9so354015675pac.0
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 23:37:19 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id os9si91619pab.169.2016.01.12.23.37.19
        for <linux-mm@kvack.org>;
        Tue, 12 Jan 2016 23:37:19 -0800 (PST)
Date: Wed, 13 Jan 2016 00:37:16 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v8 2/9] dax: fix conversion of holes to PMDs
Message-ID: <20160113073716.GC30496@linux.intel.com>
References: <1452230879-18117-1-git-send-email-ross.zwisler@linux.intel.com>
 <1452230879-18117-3-git-send-email-ross.zwisler@linux.intel.com>
 <20160112094451.GS6262@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160112094451.GS6262@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com

On Tue, Jan 12, 2016 at 10:44:51AM +0100, Jan Kara wrote:
> On Thu 07-01-16 22:27:52, Ross Zwisler wrote:
> > When we get a DAX PMD fault for a write it is possible that there could be
> > some number of 4k zero pages already present for the same range that were
> > inserted to service reads from a hole.  These 4k zero pages need to be
> > unmapped from the VMAs and removed from the struct address_space radix tree
> > before the real DAX PMD entry can be inserted.
> > 
> > For PTE faults this same use case also exists and is handled by a
> > combination of unmap_mapping_range() to unmap the VMAs and
> > delete_from_page_cache() to remove the page from the address_space radix
> > tree.
> > 
> > For PMD faults we do have a call to unmap_mapping_range() (protected by a
> > buffer_new() check), but nothing clears out the radix tree entry.  The
> > buffer_new() check is also incorrect as the current ext4 and XFS filesystem
> > code will never return a buffer_head with BH_New set, even when allocating
> > new blocks over a hole.  Instead the filesystem will zero the blocks
> > manually and return a buffer_head with only BH_Mapped set.
> > 
> > Fix this situation by removing the buffer_new() check and adding a call to
> > truncate_inode_pages_range() to clear out the radix tree entries before we
> > insert the DAX PMD.
> > 
> > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> > Reported-by: Dan Williams <dan.j.williams@intel.com>
> > Tested-by: Dan Williams <dan.j.williams@intel.com>
> 
> Just two nits below. Nothing serious so you can add:
> 
> Reviewed-by: Jan Kara <jack@suse.cz>

Cool, thank you for the review!

> > ---
> >  fs/dax.c | 20 ++++++++++----------
> >  1 file changed, 10 insertions(+), 10 deletions(-)
> > 
> > diff --git a/fs/dax.c b/fs/dax.c
> > index 513bba5..5b84a46 100644
> > --- a/fs/dax.c
> > +++ b/fs/dax.c
> > @@ -589,6 +589,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
> >  	bool write = flags & FAULT_FLAG_WRITE;
> >  	struct block_device *bdev;
> >  	pgoff_t size, pgoff;
> > +	loff_t lstart, lend;
> >  	sector_t block;
> >  	int result = 0;
> >  
> > @@ -643,15 +644,13 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
> >  		goto fallback;
> >  	}
> >  
> > -	/*
> > -	 * If we allocated new storage, make sure no process has any
> > -	 * zero pages covering this hole
> > -	 */
> > -	if (buffer_new(&bh)) {
> > -		i_mmap_unlock_read(mapping);
> > -		unmap_mapping_range(mapping, pgoff << PAGE_SHIFT, PMD_SIZE, 0);
> > -		i_mmap_lock_read(mapping);
> > -	}
> > +	/* make sure no process has any zero pages covering this hole */
> > +	lstart = pgoff << PAGE_SHIFT;
> > +	lend = lstart + PMD_SIZE - 1; /* inclusive */
> > +	i_mmap_unlock_read(mapping);
> 
> Just a nit but is there reason why we grab i_mmap_lock_read(mapping) only
> to release it a few lines below? The bh checks inside the locked region
> don't seem to rely on i_mmap_lock...

I think we can probably just take it when we're done with the truncate() -
I'll fix for v9.

> > +	unmap_mapping_range(mapping, lstart, PMD_SIZE, 0);
> > +	truncate_inode_pages_range(mapping, lstart, lend);
> 
> These two calls can be shortened as:
> 
> truncate_pagecache_range(inode, lstart, lend);

Nice.  I'll change it for v9.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
