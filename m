Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0CBBF6B029E
	for <linux-mm@kvack.org>; Fri, 26 Aug 2016 17:29:37 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ez1so148742037pab.1
        for <linux-mm@kvack.org>; Fri, 26 Aug 2016 14:29:37 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id v88si23178494pfj.110.2016.08.26.14.29.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Aug 2016 14:29:36 -0700 (PDT)
Date: Fri, 26 Aug 2016 15:29:34 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v2 2/9] ext2: tell DAX the size of allocation holes
Message-ID: <20160826212934.GA11265@linux.intel.com>
References: <20160823220419.11717-1-ross.zwisler@linux.intel.com>
 <20160823220419.11717-3-ross.zwisler@linux.intel.com>
 <20160825075728.GA11235@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160825075728.GA11235@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, linux-nvdimm@ml01.01.org, Matthew Wilcox <mawilcox@microsoft.com>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, Andreas Dilger <adilger.kernel@dilger.ca>, Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.com>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org

On Thu, Aug 25, 2016 at 12:57:28AM -0700, Christoph Hellwig wrote:
> Hi Ross,
> 
> can you take at my (fully working, but not fully cleaned up) version
> of the iomap based DAX code here:
> 
> http://git.infradead.org/users/hch/vfs.git/shortlog/refs/heads/iomap-dax
> 
> By using iomap we don't even have the size hole problem and totally
> get out of the reverse-engineer what buffer_heads are trying to tell
> us business.  It also gets rid of the other warts of the DAX path
> due to pretending to be like direct I/O, so this might be a better
> way forward also for ext2/4.

In general I agree that the usage of struct iomap seems more straightforward
than the old way of using struct buffer_head + get_block_t.  I really don't
think we want to have two competing DAX I/O and fault paths, though, which I
assume everyone else agrees with as well.

These changes don't remove the things in XFS needed by the old I/O and fault
paths (e.g.  xfs_get_blocks_direct() is still there an unchanged).  Is the
correct way forward to get buy-in from ext2/ext4 so that they also move to
supporting an iomap based I/O path (xfs_file_iomap_begin(),
xfs_iomap_write_direct(), etc?).  That would allow us to have parallel I/O and
fault paths for a while, then remove the old buffer_head based versions when
the three supported filesystems have moved to iomap.

If ext2 and ext4 don't choose to move to iomap, though, I don't think we want
to have a separate I/O & fault path for iomap/XFS.  That seems too painful,
and the old buffer_head version should continue to work, ugly as it may be.

Assuming we can get buy-in from ext4/ext2, I can work on a PMD version of the
iomap based fault path that is equivalent to the buffer_head based one I sent
out in my series, and we can all eventually move to that.

A few comments/questions on the implementation:

1) In your mail above you say "It also gets rid of the other warts of the DAX
   path due to pretending to be like direct I/O".  I assume by this you mean
   the code in dax_do_io() around DIO_LOCKING, inode_dio_begin(), etc?
   Perhaps there are other things as well in XFS, but this is what I see in
   the DAX code.  If so, yep, this seems like a win.  I don't understand how
   DIO_LOCKING is relevant to the DAX I/O path, as we never mix buffered and
   direct access.

   The comment in dax_do_io() for the inode_dio_begin() call says that it
   prevents the I/O from races with truncate.  Am I correct that we now get
   this protection via the xfs_rw_ilock()/xfs_rw_iunlock() calls in
   xfs_file_dax_write()?

2) Just a nit, I noticed that you used "~(PAGE_SIZE - 1)" in several places in
   iomap_dax_actor() and iomap_dax_fault() instead of PAGE_MASK.  Was this
   intentional?

3) It's kind of weird having iomap_dax_fault() in fs/dax.c but having
   iomap_dax_actor() and iomap_dax_rw() in fs/iomap.c?  I'm guessing the
   latter is placed where it is because it uses iomap_apply(), which is local
   to fs/iomap.c?  Anyway, it would be nice if we could keep them together, if
   possible.

4) In iomap_dax_actor() you do this check:

	WARN_ON_ONCE(iomap->type != IOMAP_MAPPED);

   If we hit this we should bail with -EIO, yea?  Otherwise we could write to
   unmapped space or something horrible.

5) In iomap_dax_fault, I think the "I/O beyond the end of the file" check
   might have been broken.  Take for example an I/O to the second page of a
   file, where the file has size one page.  So:
   
   vmf->pgoff = 1
   i_size_read(inode) = 4096 
   
   Here's the old code in dax_fault():

	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
	if (vmf->pgoff >= size)
		return VM_FAULT_SIGBUS;

   size = (4096 + 4096 - 1) >> PAGE_SHIFT = 1
   vmf->pgoff is 1 and size is 1, so we return SIGBUS

   Here's the new code:

	   if (pos >= i_size_read(inode) + PAGE_SIZE - 1)
		return VM_FAULT_SIGBUS;

   pos = vmf->pgoff << PAGE_SHIFT = 4096
   i_size_read(inode) + PAGE_SIZE  - 1 = 8193
   so, 'pos' isn't >= where we calculate the end of the file to be, so we do I/O

   Basically the old check did the "+ PAGE_SIZE - 1" so that the >> PAGE_SHIFT
   was sure to round up to the next full page.  You don't need this with your
   current logic, so I think the test should just be:

	   if (pos >= i_size_read(inode))
		return VM_FAULT_SIGBUS;

   Right?

6) Regarding the "we don't even have the size hole problem" comment in your
   mail, the current PMD logic requires us to know the size of the hole.  This
   is important so that we can fault in a huge zero page if we have a 2 MiB
   hole.  It's fine if that 2 MiB page then gets fragmented into 4k DAX
   allocations when we start to do writes, but the path the other way doesn't
   work.  If we don't know the size of holes then we can't fault in a 2 MiB
   zero page, so we'll use 4k zero pages to satisfy reads.  This means that if
   later we want to fault in a 2MiB DAX allocation, we don't have a single
   entry that we can use to lock the entire 2MiB range while we clean the
   radix tree an unmap the range from all the user processes.  With the
   current PMD logic this will mean that if someone does a 4k read that faults
   in a 4k zero page, we will only use 4k faults for that range and won't use
   PMDs.

   The current XFS code in the v4.8 tree tells me the size of the hole, and I
   think we need to keep this functionality.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
