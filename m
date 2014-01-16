Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 3B4416B006C
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 20:25:14 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id r10so1883958pdi.20
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 17:25:13 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id ai8si5303034pad.270.2014.01.15.17.25.10
        for <linux-mm@kvack.org>;
        Wed, 15 Jan 2014 17:25:11 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v5 22/22] XIP: Add support for unwritten extents
Date: Wed, 15 Jan 2014 20:24:40 -0500
Message-Id: <21d60639d747cdd683831ce57e7c753c9fa29ac1.1389779962.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1389779961.git.matthew.r.wilcox@intel.com>
References: <cover.1389779961.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1389779961.git.matthew.r.wilcox@intel.com>
References: <cover.1389779961.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>

For read() and pagefault, we treat unwritten extents as holes.
For write(), we have to zero parts of the block that we're not going to
write to.  For holepunches, something's gone quite strangely wrong if we
get an unwritten extent from get_block, considering that the filesystem's
calling us to write zeroes to a partially written extent ...

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 Documentation/filesystems/xip.txt |  7 +++----
 fs/xip.c                          | 44 +++++++++++++++++++++++++++------------
 2 files changed, 34 insertions(+), 17 deletions(-)

diff --git a/Documentation/filesystems/xip.txt b/Documentation/filesystems/xip.txt
index b158de6..5e9a0c76 100644
--- a/Documentation/filesystems/xip.txt
+++ b/Documentation/filesystems/xip.txt
@@ -60,10 +60,9 @@ Filesystem support consists of
   truncates and page faults
 
 The get_block() callback passed to xip_do_io(), xip_fault(), xip_mkwrite()
-and xip_truncate_page() must not return uninitialised extents.  It must zero
-any blocks that it returns, and it must ensure that simultaneous calls to
-get_block() (for example by a page-fault racing with a read() or a write())
-work correctly.
+and xip_truncate_page() may return uninitialised extents.  If it does, it
+must ensure that simultaneous calls to get_block() (for example by a
+page-fault racing with a read() or a write()) work correctly.
 
 These filesystems may be used for inspiration:
 - ext2: the second extended filesystem, see Documentation/filesystems/ext2.txt
diff --git a/fs/xip.c b/fs/xip.c
index 88a516b..d160320 100644
--- a/fs/xip.c
+++ b/fs/xip.c
@@ -79,6 +79,12 @@ static long xip_get_pfn(struct inode *inode, struct buffer_head *bh,
 	return ops->direct_access(bdev, sector, &addr, pfn, bh->b_size);
 }
 
+/* true if a buffer_head represents written data */
+static bool buffer_written(struct buffer_head *bh)
+{
+	return buffer_mapped(bh) && !buffer_unwritten(bh);
+}
+
 static ssize_t xip_io(int rw, struct inode *inode, const struct iovec *iov,
 			loff_t start, loff_t end, unsigned nr_segs,
 			get_block_t get_block, struct buffer_head *bh)
@@ -103,21 +109,29 @@ static ssize_t xip_io(int rw, struct inode *inode, const struct iovec *iov,
 			retval = get_block(inode, block, bh, rw == WRITE);
 			if (retval)
 				break;
-			if (buffer_mapped(bh)) {
-				retval = xip_get_addr(inode, bh, &addr);
-				if (retval < 0)
-					break;
-				addr += offset - (block << inode->i_blkbits);
-				hole = false;
-				size = retval;
-			} else {
-				if (rw == WRITE) {
+			if (rw == WRITE) {
+				if (!buffer_mapped(bh)) {
 					retval = -EIO;
 					break;
 				}
+				hole = false;
+			} else {
+				hole = !buffer_written(bh);
+			}
+
+			if (hole) {
 				addr = NULL;
-				hole = true;
 				size = bh->b_size;
+			} else {
+				unsigned first;
+				retval = xip_get_addr(inode, bh, &addr);
+				if (retval < 0)
+					break;
+				size = retval;
+				first = offset - (block << inode->i_blkbits);
+				if (buffer_unwritten(bh))
+					memset(addr, 0, first);
+				addr += first;
 			}
 			max = offset + size;
 		}
@@ -265,7 +279,7 @@ static int do_xip_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	if (error || bh.b_size < PAGE_SIZE)
 		return VM_FAULT_SIGBUS;
 
-	if (!buffer_mapped(&bh) && !vmf->cow_page) {
+	if (!buffer_written(&bh) && !vmf->cow_page) {
 		if (vmf->flags & FAULT_FLAG_WRITE) {
 			error = get_block(inode, block, &bh, 1);
 			count_vm_event(PGMAJFAULT);
@@ -286,7 +300,7 @@ static int do_xip_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		return VM_FAULT_SIGBUS;
 	}
 	if (vmf->cow_page) {
-		if (buffer_mapped(&bh))
+		if (buffer_written(&bh))
 			copy_user_bh(vmf->cow_page, inode, &bh, vaddr);
 		else
 			clear_user_highpage(vmf->cow_page, vaddr);
@@ -397,7 +411,11 @@ int xip_zero_page_range(struct inode *inode, loff_t from, unsigned length,
 	err = get_block(inode, index, &bh, 0);
 	if (err < 0)
 		return err;
-	if (buffer_mapped(&bh)) {
+	if (buffer_written(&bh)) {
+		/*
+		 * Should this be BUG_ON(!buffer_mapped)?  Surely we should
+		 * never be called for an unmapped block ...
+		 */
 		void *addr;
 		err = xip_get_addr(inode, &bh, &addr);
 		if (err)
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
