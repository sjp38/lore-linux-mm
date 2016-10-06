Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 997FB6B0038
	for <linux-mm@kvack.org>; Thu,  6 Oct 2016 17:34:27 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id tz10so10410468pab.3
        for <linux-mm@kvack.org>; Thu, 06 Oct 2016 14:34:27 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id tz5si13934085pac.308.2016.10.06.14.34.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 06 Oct 2016 14:34:26 -0700 (PDT)
Date: Thu, 6 Oct 2016 15:34:24 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v4 10/12] dax: add struct iomap based DAX PMD support
Message-ID: <20161006213424.GA4569@linux.intel.com>
References: <1475189370-31634-1-git-send-email-ross.zwisler@linux.intel.com>
 <1475189370-31634-11-git-send-email-ross.zwisler@linux.intel.com>
 <20161003105949.GP6457@quack2.suse.cz>
 <20161003210557.GA28177@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161003210557.GA28177@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Mon, Oct 03, 2016 at 03:05:57PM -0600, Ross Zwisler wrote:
> On Mon, Oct 03, 2016 at 12:59:49PM +0200, Jan Kara wrote:
> > On Thu 29-09-16 16:49:28, Ross Zwisler wrote:
<>
> > > +int dax_iomap_pmd_fault(struct vm_area_struct *vma, unsigned long address,
> > > +		pmd_t *pmd, unsigned int flags, struct iomap_ops *ops)
> > > +{
> > > +	struct address_space *mapping = vma->vm_file->f_mapping;
> > > +	unsigned long pmd_addr = address & PMD_MASK;
> > > +	bool write = flags & FAULT_FLAG_WRITE;
> > > +	struct inode *inode = mapping->host;
> > > +	struct iomap iomap = { 0 };
> > > +	int error, result = 0;
> > > +	pgoff_t size, pgoff;
> > > +	struct vm_fault vmf;
> > > +	void *entry;
> > > +	loff_t pos;
> > > +
> > > +	/* Fall back to PTEs if we're going to COW */
> > > +	if (write && !(vma->vm_flags & VM_SHARED)) {
> > > +		split_huge_pmd(vma, pmd, address);
> > > +		return VM_FAULT_FALLBACK;
> > > +	}
> > > +
> > > +	/* If the PMD would extend outside the VMA */
> > > +	if (pmd_addr < vma->vm_start)
> > > +		return VM_FAULT_FALLBACK;
> > > +	if ((pmd_addr + PMD_SIZE) > vma->vm_end)
> > > +		return VM_FAULT_FALLBACK;
> > > +
> > > +	/*
> > > +	 * Check whether offset isn't beyond end of file now. Caller is
> > > +	 * supposed to hold locks serializing us with truncate / punch hole so
> > > +	 * this is a reliable test.
> > > +	 */
> > > +	pgoff = linear_page_index(vma, pmd_addr);
> > > +	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
> > > +
> > > +	if (pgoff >= size)
> > > +		return VM_FAULT_SIGBUS;
> > > +
> > > +	/* If the PMD would extend beyond the file size */
> > > +	if ((pgoff | PG_PMD_COLOUR) >= size)
> > > +		return VM_FAULT_FALLBACK;
> > > +
> > > +	/*
> > > +	 * grab_mapping_entry() will make sure we get a 2M empty entry, a DAX
> > > +	 * PMD or a HZP entry.  If it can't (because a 4k page is already in
> > > +	 * the tree, for instance), it will return -EEXIST and we just fall
> > > +	 * back to 4k entries.
> > > +	 */
> > > +	entry = grab_mapping_entry(mapping, pgoff, RADIX_DAX_PMD);
> > > +	if (IS_ERR(entry))
> > > +		return VM_FAULT_FALLBACK;
> > > +
> > > +	/*
> > > +	 * Note that we don't use iomap_apply here.  We aren't doing I/O, only
> > > +	 * setting up a mapping, so really we're using iomap_begin() as a way
> > > +	 * to look up our filesystem block.
> > > +	 */
> > > +	pos = (loff_t)pgoff << PAGE_SHIFT;
> > > +	error = ops->iomap_begin(inode, pos, PMD_SIZE, write ? IOMAP_WRITE : 0,
> > > +			&iomap);
> > 
> > I'm not quite sure if it is OK to call ->iomap_begin() without ever calling
> > ->iomap_end. Specifically the comment before iomap_apply() says:
> > 
> > "It is assumed that the filesystems will lock whatever resources they
> > require in the iomap_begin call, and release them in the iomap_end call."
> > 
> > so what you do could result in unbalanced allocations / locks / whatever.
> > Christoph?
> 
> I'll add the iomap_end() calls to both the PTE and PMD iomap fault handlers.

Interesting - adding iomap_end() calls to the DAX PTE fault handler causes an
AA deadlock because we try and retake ei->dax_sem.  We take dax_sem in
ext2_dax_fault() before calling into the DAX code, then if we end up going
through the error path in ext2_iomap_end(), we call 
  ext2_write_failed()
    ext2_truncate_blocks()
      dax_sem_down_write()

Where we try and take dax_sem again.  This error path is really only valid for
I/O operations, but we happen to call it for page faults because 'written' in
ext2_iomap_end() is just 0.

So...how should we handle this?  A few ideas:

1) Just continue to omit the calls to iomap_end() in the DAX page fault
handlers for now, and add them when there is useful work to be done in one of
the filesystems.

2) Add an IOMAP_FAULT flag to the flags passed into iomap_begin() and
iomap_end() so make it explicit that we are calling as part of a fault handler
and not an I/O operation, and use this to adjust the error handling in
ext2_iomap_end().

3) Just work around the existing error handling in ext2_iomap_end() by either
unsetting IOMAP_WRITE or by setting 'written' to the size of the fault.

For #2 or #3, probably add a comment explaining the deadlock and why we need
to never call ext2_write_failed() while handling a page fault.

Thoughts?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
