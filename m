Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id EF0B36B0036
	for <linux-mm@kvack.org>; Wed,  3 Sep 2014 03:48:22 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id ft15so10441500pdb.20
        for <linux-mm@kvack.org>; Wed, 03 Sep 2014 00:48:19 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id ky5si9482765pbc.155.2014.09.03.00.48.08
        for <linux-mm@kvack.org>;
        Wed, 03 Sep 2014 00:48:10 -0700 (PDT)
Date: Wed, 3 Sep 2014 17:47:24 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v10 09/21] Replace the XIP page fault handler with the
 DAX page fault handler
Message-ID: <20140903074724.GE20473@dastard>
References: <cover.1409110741.git.matthew.r.wilcox@intel.com>
 <4d71d7a13bec3acf703e26bf6b0c7da21a71ebe0.1409110741.git.matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4d71d7a13bec3acf703e26bf6b0c7da21a71ebe0.1409110741.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, willy@linux.intel.com

On Tue, Aug 26, 2014 at 11:45:29PM -0400, Matthew Wilcox wrote:
> Instead of calling aops->get_xip_mem from the fault handler, the
> filesystem passes a get_block_t that is used to find the appropriate
> blocks.
> 
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
> Reviewed-by: Jan Kara <jack@suse.cz>

There's a problem in this code to do with faults into unwritten
extents.

> +static int do_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
> +			get_block_t get_block)
> +{
> +	struct file *file = vma->vm_file;
> +	struct inode *inode = file_inode(file);
> +	struct address_space *mapping = file->f_mapping;
> +	struct page *page;
> +	struct buffer_head bh;
> +	unsigned long vaddr = (unsigned long)vmf->virtual_address;
> +	unsigned blkbits = inode->i_blkbits;
> +	sector_t block;
> +	pgoff_t size;
> +	unsigned long pfn;
> +	int error;
> +	int major = 0;
> +
> +	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
> +	if (vmf->pgoff >= size)
> +		return VM_FAULT_SIGBUS;
> +
> +	memset(&bh, 0, sizeof(bh));
> +	block = (sector_t)vmf->pgoff << (PAGE_SHIFT - blkbits);
> +	bh.b_size = PAGE_SIZE;
> +
> + repeat:
> +	page = find_get_page(mapping, vmf->pgoff);
> +	if (page) {
> +		if (!lock_page_or_retry(page, vma->vm_mm, vmf->flags)) {
> +			page_cache_release(page);
> +			return VM_FAULT_RETRY;
> +		}
> +		if (unlikely(page->mapping != mapping)) {
> +			unlock_page(page);
> +			page_cache_release(page);
> +			goto repeat;
> +		}
> +	}
> +
> +	error = get_block(inode, block, &bh, 0);
> +	if (!error && (bh.b_size < PAGE_SIZE))
> +		error = -EIO;
> +	if (error)
> +		goto unlock_page;

page fault into unwritten region, returns buffer_unwritten(bh) ==
true. Hence buffer_written(bh) is false, and we take this branch:

> +	if (!buffer_written(&bh) && !vmf->cow_page) {
> +		if (vmf->flags & FAULT_FLAG_WRITE) {
> +			error = get_block(inode, block, &bh, 1);

Exactly what are you expecting to happen here? We don't do
allocation because there are already unwritten blocks over this
extent, and so bh will be unchanged when returning. i.e. it will
still be mapping an unwritten extent.

There's another issue here, too. Allocate the block, sets
buffer_new, and we crash before the block is zeroed. Stale data is
exposed to the user if the allocation transaction has already hit
the log. i.e. at minimum data corruption, at worst we just exposed
the contents of /etc/shadow....

....

> +	if (buffer_unwritten(&bh) || buffer_new(&bh))
> +		dax_clear_blocks(inode, bh.b_blocknr, bh.b_size);

Back to unwritten extents, we zero the block here, but the
filesystem still thinks it's an unwritten extent. There's been no IO
completion for the filesystem to mark the extent as containing valid
data.

We do this properly for the do_dax_IO path, but we do not do it
properly in the fault path.

Back to that stale exposure bug: to avoid this stale data exposure,
XFS allocates unwritten extents when doing direct allocation into
holes, then uses IO completion to convert them to written. For DAX,
we are doing direct allocation for page faults (as delayed allocation
makes no sense at all) as well as the IO path, and so we have need
for IO completion callbacks after zeroing just like we do for a
write() via dax_do_io().

Now, I think we can do this pretty easily - the bufferhead has an
endio callback we can use for exactly this purpose. i.e. if the
extent mapping bh is unwritten and the mapping bh->b_end_io is
present, then that end io function needs to be called after
dax_clear_blocks() has run. This will allow the filesystem to then
mark the extents are written, and we have no stale data exposure
issues at all.

In case you hadn't guessed, mmap write IO via DAX doesn't work at
all on XFS with this code. patch below that adds the end_io callback
that makes things work for XFS. I haven't changed the second
get_block() call, but that needs to be removed for unwritten
extents found during the initial lookup (i.e. page fault into
preallocated space).

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

dax: add IO completion callback for page faults

From: Dave Chinner <dchinner@redhat.com>

When a page fault drops into a hole, it needs to allocate an extent.
Filesystems may allocate unwritten extents so that the underlying
contents are not exposed until data is written to the extent. In
that case, we need an io completion callback to run once the blocks
have been zeroed to indicate that it is safe for the filesystem to
mark those blocks written without exposing stale data in the event
of a crash.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/dax.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/dax.c b/fs/dax.c
index 96c4fed..387ca78 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -306,6 +306,7 @@ static int do_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	memset(&bh, 0, sizeof(bh));
 	block = (sector_t)vmf->pgoff << (PAGE_SHIFT - blkbits);
 	bh.b_size = PAGE_SIZE;
+	bh.b_end_io = NULL;
 
  repeat:
 	page = find_get_page(mapping, vmf->pgoff);
@@ -364,8 +365,12 @@ static int do_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		return VM_FAULT_LOCKED;
 	}
 
-	if (buffer_unwritten(&bh) || buffer_new(&bh))
+	if (buffer_unwritten(&bh) || buffer_new(&bh)) {
+		/* XXX: errors zeroing the blocks are propagated how? */
 		dax_clear_blocks(inode, bh.b_blocknr, bh.b_size);
+		if (bh.b_end_io)
+			bh.b_end_io(&bh, 1);
+	}
 
 	/* Check we didn't race with a read fault installing a new page */
 	if (!page && major)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
