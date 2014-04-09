Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id B71606B0031
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 16:49:06 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id v10so2902009pde.25
        for <linux-mm@kvack.org>; Wed, 09 Apr 2014 13:49:05 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id jg5si977821pbb.254.2014.04.09.13.49.04
        for <linux-mm@kvack.org>;
        Wed, 09 Apr 2014 13:49:04 -0700 (PDT)
Date: Wed, 9 Apr 2014 16:48:06 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v7 07/22] Replace the XIP page fault handler with the DAX
 page fault handler
Message-ID: <20140409204806.GF5727@linux.intel.com>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
 <c2e602f401a580c4fac54b9b8f4a6f8dd0ac1071.1395591795.git.matthew.r.wilcox@intel.com>
 <20140408220525.GC26019@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140408220525.GC26019@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Apr 09, 2014 at 12:05:25AM +0200, Jan Kara wrote:
> > +	if (!page)
> > +		return VM_FAULT_OOM;
> > +	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
> > +	if (vmf->pgoff >= size) {
>   Maybe comment here that we have to recheck i_size so that we don't create
> pages in the area truncate_pagecache() has already evicted.

Done.

> > +	dax_get_addr(inode, bh, &vfrom);	/* XXX: error handling */
>   The error handling here is missing as the comment suggests :)

Added.

> > +	if (buffer_unwritten(&bh) || buffer_new(&bh))
> > +		dax_clear_blocks(inode, bh.b_blocknr, bh.b_size);
>   Where is dax_clear_blocks() defined?

Er ... patch 11.  I'll reorder the patches ;-)

> > +
> > +	error = dax_get_pfn(inode, &bh, &pfn);
> > +	if (error > 0)
> > +		error = vm_insert_mixed(vma, vaddr, pfn);
>   When there's a hole (thus page != NULL) and we are called from
> dax_mkwrite(), this will always return EBUSY, correct?

Erm ... it will return -EBUSY if this was the task that previously
faulted on it.  Drat.  See below.

> > +	mutex_unlock(&mapping->i_mmap_mutex);
> > +
> > +	if (page) {
> > +		delete_from_page_cache(page);
> > +		unmap_mapping_range(mapping, vmf->pgoff << PAGE_SHIFT,
> > +							PAGE_CACHE_SIZE, 0);
>   Here we unmap the PTE pointing to the hole page but then we'll have to
> retry the fault again to fill in the pfn we've got? This seems wrong. I'd
> say we want to remap the PTE from the hole page to a pfn we've got while
> holding i_mmap_mutex. remap_pfn_range() almost does what you need, except
> that you also need that to work for normal pages. So you might need to
> create a new helper in mm layer for that.

I think it's easier than that.  How does this look?

@@ -390,9 +389,8 @@ static int do_dax_fault(struct vm_area_struct *vma, struct v
                dax_clear_blocks(inode, bh.b_blocknr, bh.b_size);
 
        error = dax_get_pfn(&bh, &pfn, blkbits);
-       if (error > 0)
-               error = vm_insert_mixed(vma, vaddr, pfn);
-       mutex_unlock(&mapping->i_mmap_mutex);
+       if (error <= 0)
+               goto unlock;
 
        if (page) {
                delete_from_page_cache(page);
@@ -402,6 +400,9 @@ static int do_dax_fault(struct vm_area_struct *vma, struct v
                page_cache_release(page);
        }
 
+       error = vm_insert_mixed(vma, vaddr, pfn);
+       mutex_unlock(&mapping->i_mmap_mutex);
+
        if (error == -ENOMEM)
                return VM_FAULT_OOM;
        /* -EBUSY is fine, somebody else faulted on the same PTE */
@@ -409,6 +410,8 @@ static int do_dax_fault(struct vm_area_struct *vma, struct v
                BUG_ON(error);
        return VM_FAULT_NOPAGE | major;
 
+ unlock:
+       mutex_unlock(&mapping->i_mmap_mutex);
  sigbus:
        if (page) {
                unlock_page(page);


> > +int dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
> > +			get_block_t get_block)
> > +{
> > +	int result;
> > +	struct super_block *sb = file_inode(vma->vm_file)->i_sb;
> > +
> > +	sb_start_pagefault(sb);
>   You don't need any filesystem freeze protection for the fault handler
> since that's not going to modify the filesystem.

Err ... we might allocate a block as a result of doing a write to a hole.
Or does that not count as 'modifying the filesystem' in this context?

> > +	file_update_time(vma->vm_file);
>   Why do you update m/ctime? We are only reading the file...

... except that it might be a write fault.  I think we modify the file
iff we return VM_FAULT_MAJOR from do_dax_fault().  So I'd be open to
something like this:

	sb_start_pagefault(sb);
	result = do_dax_fault(vma, vmf, get_block);
	if (result & VM_FAULT_MAJOR)
		file_update_time(vma->vm_file);
	sb_end_pagefault(sb);

Would that work better for you?

> > @@ -70,7 +101,7 @@ const struct file_operations ext2_file_operations = {
> >  #ifdef CONFIG_COMPAT
> >  	.compat_ioctl	= ext2_compat_ioctl,
> >  #endif
> > -	.mmap		= generic_file_mmap,
> > +	.mmap		= ext2_file_mmap,
>   So what's the point of ext2_file_operations ever handling IS_DAX()
> inodes? Actually ext2_file_operations and ext2_xip_file_operations seem to
> be the same after this patch so either you drop ext2_xip_file_operations
> (I'm for this) or you can leave generic_file_mmap here and assume
> ext2_file_mmap is always called for IS_DAX() inodes.

The goal is to get them the same.  At this point, the only sticky point is:

        .splice_read    = generic_file_splice_read,
        .splice_write   = generic_file_splice_write,

And splice is pretty damn sticky for DAX.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
