Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 24AC46B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 16:58:24 -0400 (EDT)
Received: by pabxg6 with SMTP id xg6so74140454pab.0
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 13:58:23 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id sv6si9913860pbc.7.2015.03.26.13.58.21
        for <linux-mm@kvack.org>;
        Thu, 26 Mar 2015 13:58:22 -0700 (PDT)
Date: Fri, 27 Mar 2015 07:58:05 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/3] RFC: dax: dax_prepare_freeze
Message-ID: <20150326205805.GC28129@dastard>
References: <55100B78.501@plexistor.com>
 <55100D10.6090902@plexistor.com>
 <20150323224047.GQ28621@dastard>
 <551100E3.9010007@plexistor.com>
 <20150325022221.GA31342@dastard>
 <55126D77.7040105@plexistor.com>
 <20150325092922.GH31342@dastard>
 <55128BC6.7090105@plexistor.com>
 <20150325200024.GJ31342@dastard>
 <5513BD01.5080603@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5513BD01.5080603@plexistor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>

On Thu, Mar 26, 2015 at 10:02:09AM +0200, Boaz Harrosh wrote:
> On 03/25/2015 10:00 PM, Dave Chinner wrote:
> > On Wed, Mar 25, 2015 at 12:19:50PM +0200, Boaz Harrosh wrote:
> >> On 03/25/2015 11:29 AM, Dave Chinner wrote:
> >>> On Wed, Mar 25, 2015 at 10:10:31AM +0200, Boaz Harrosh wrote:
> >>>> On 03/25/2015 04:22 AM, Dave Chinner wrote:
> >>>>> On Tue, Mar 24, 2015 at 08:14:59AM +0200, Boaz Harrosh wrote:
> >>>> <>
> >> <>
> >>>> The sync does happen, .fsync of the FS is called on each
> >>>> file just as if the user called it. If this is broken it just
> >>>> needs to be fixed there at the .fsync vector. POSIX mandate
> >>>> persistence at .fsync so at the vfs layer we rely on that.
> >>>
> >>> right now, the filesystems will see that there are no dirty pages
> >>> on the inode, and then just sync the inode metadata. They will do
> >>> nothing else as filesystems are not aware of CPU cachelines at all.
> >>>
> >>
> >> Sigh yes. There is this bug. And I am sitting on a wide fix for this.
> >>
> >> The strategy is. All Kernel writes are done with a new copy_user_nt.
> >> NT stands for none-temporal. This shows 20% improvements since cachelines
> >> need not be fetched when written too.
> > 
> > That's unenforcable for mmap writes from userspace. And those are
> > the writes that will trigger the dirty write mapping problem.
> > 
> 
> So for them I was thinking of just doing the .fsync on every
> unmap (ie vm_operations_struct->close)

That is not necessary, I think - it can be handled by the background
writeback thread just fine.

> So now we know that only inodes that have an active vm mapping
> are in need of sync.

Easy enough.

> >> Please note that even if we properly .fsync cachlines the page-faults
> >> are orthogonal to this. There is no point in making mmapped dax pages
> >> read-only after every .fsync and pay a page-fault. We should leave them
> >> mapped has is. The only place that we need page protection is at freeze
> >> time.
> > 
> > Actually, current behaviour of filesystems is that fsync cleans all
> > the pages in the range, and means all the mappings are marked
> > read-only and so we get new calls into .page_mkwrite when write
> > faults occur. We need that .page_mkwrite call to be able to a)
> > update the mtime of the inode, and b) mark the inode "data dirty" so
> > that fsync knows it needs to do something....
> > 
> > Hence I'd much prefer we start with identical behaviour to normal
> > files, then we can optimise from a sane start point when write page
> > faults show up as a performance problem. i.e. Correctness first,
> > performance second.
> 
> OK, (you see when you speak slow I understand fast ;-)). I agree then
> I'll see if I can schedule some time for this. My boss will be very
> angry with me about this. But I will need help please, and some hands
> holding. Unless someone else volunteers to work on this ?

It's not hard - you should be able to make somethign work from the
untested, uncompiled skeleton below....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

dax: hack in dirty mapping tracking to fsync/sync/writeback

Not-signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/dax.c            | 27 ++++++++++++++++++++++++++-
 fs/xfs/xfs_file.c   |  2 ++
 mm/page-writeback.c |  5 +++++
 3 files changed, 33 insertions(+), 1 deletion(-)

diff --git a/fs/dax.c b/fs/dax.c
index 0121f7d..61cbd76 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -27,6 +27,29 @@
 #include <linux/uio.h>
 #include <linux/vmstat.h>
 
+/*
+ * flush the mapping to the persistent domain within the byte range of (start,
+ * end). This is required by data integrity operations to ensure file data is on
+ * persistent storage prior to completion of the operation. It also requires us
+ * to clean the mappings (i.e. write -> RO) so that we'll get a new fault when
+ * the file is written to again so wehave an indication that we need to flush
+ * the mapping if a data integrity operation takes place.
+ *
+ * We don't need commits to storage here - the filesystems will issue flushes
+ * appropriately at the conclusion of the data integrity operation via REQ_FUA
+ * writes or blkdev_issue_flush() commands.  This requires the DAX block device
+ * to implement persistent storage domain fencing/commits on receiving a
+ * REQ_FLUSH or REQ_FUA request so that this works as expected by the higher
+ * layers.
+ */
+int dax_flush_mapping(struct address_space *mapping, loff_t start, loff_t end)
+{
+	/* XXX: make ptes in range clean */
+
+	/* XXX: flush CPU caches  */
+	return 0;
+}
+
 int dax_clear_blocks(struct inode *inode, sector_t block, long size)
 {
 	struct block_device *bdev = inode->i_sb->s_bdev;
@@ -472,8 +495,10 @@ int dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		file_update_time(vma->vm_file);
 	}
 	result = __dax_fault(vma, vmf, get_block, complete_unwritten);
-	if (vmf->flags & FAULT_FLAG_WRITE)
+	if (vmf->flags & FAULT_FLAG_WRITE) {
+		__mark_inode_dirty(file_inode(vma->vm_file, I_DIRTY_PAGES);
 		sb_end_pagefault(sb);
+	}
 
 	return result;
 }
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 8017175..43e6c8e 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -1453,6 +1453,8 @@ xfs_filemap_page_mkwrite(
 	}
 
 	xfs_iunlock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
+	if (IS_DAX(inode))
+		__mark_inode_dirty(file_inode(vma->vm_file, I_DIRTY_PAGES);
 	sb_end_pagefault(inode->i_sb);
 
 	return ret;
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 45e187b..aa2fa76 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2029,6 +2029,11 @@ int do_writepages(struct address_space *mapping, struct writeback_control *wbc)
 
 	if (wbc->nr_to_write <= 0)
 		return 0;
+
+	if (wbc->sync == WB_SYNC_ALL && IS_DAX(mapping->host))
+		return dax_flush_mapping(mapping, wbc->range_start,
+						  wbc->range_end);
+
 	if (mapping->a_ops->writepages)
 		ret = mapping->a_ops->writepages(mapping, wbc);
 	else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
