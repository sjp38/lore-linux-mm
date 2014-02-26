Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id C087B6B00A4
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 10:07:26 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id g10so1052010pdj.22
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 07:07:26 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id gp2si1308662pac.215.2014.02.26.07.07.21
        for <linux-mm@kvack.org>;
        Wed, 26 Feb 2014 07:07:22 -0800 (PST)
Date: Wed, 26 Feb 2014 10:07:19 -0500
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH v6 23/22] Bugfixes
Message-ID: <20140226150719.GE5744@linux.intel.com>
References: <1393337918-28265-1-git-send-email-matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1393337918-28265-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Tue, Feb 25, 2014 at 09:18:16AM -0500, Matthew Wilcox wrote:
> Seven xfstests still fail reliably with DAX that pass reliably without
> DAX: ext4/301 generic/{075,091,112,127,223,263}

With the patches below, we're down to just two additional failures,
ext4/301 and generic/223.  I'll fold these patches into the right place
for a v7 of the patchset, but I thought it unsporting to send out a new
version of such a large patchset the day after.

I've now had a review with Kirill of the page fault path.  We identified
some ... infelicities in the mm code, but nothing that's worse than the
current XIP code.

commit 714bad38915139f381e28681ab46e2e2f7202556
Author: Matthew Wilcox <willy@linux.intel.com>
Date:   Wed Feb 26 08:00:46 2014 -0500

    Only call get_block when necessary
    
    In the dax_io function, we would call get_block when we got to the end
    of the current block returned by dax_get_addr().  When using a driver
    like PRD, that's fine, but using BRD means that we stop on every page
    boundary.  The problem is that we lose information from the first call
    when doing this.  For example, if a write crosses a page boundary, the
    first time around the loop the filesystem allocates two pages, BH_New is
    set and we zero the start of the first page.  The second time around the
    loop, the filesystem just returns the existing block with BH_New clear,
    so we don't zero the tail of the second page.
    
    This patch adds tracking for how far through the buffer_head we've got,
    and will only call get_block() again once we've got to the end of the
    previous buffer.
    
    Fixes generic/263.  Now generic/{075,091,112,127} also pass; 075 was
    looking like the same problem from Ross's investigation.

commit 1f1fd14eb17dc19ecb757f896dd7573af79b5699
Author: Matthew Wilcox <willy@linux.intel.com>
Date:   Tue Feb 25 14:41:30 2014 -0500

    Clear new or unwritten blocks in page fault handler
    
    Test generic/263 mmaps the end of the file, writes to it, then checks
    the bytes after EOF are zero.  They were not being zeroed before, so we
    must do it.

commit 4d21ffcf353b8c83a599fe09ae8657ba05da1c76
Author: Matthew Wilcox <matthew.r.wilcox@intel.com>
Date:   Tue Feb 25 12:06:42 2014 -0500

    Initialise cow_page in do_page_mkwrite()
    
    We will end up checking cow_page when turning a hole into a written page,
    so it needs to be zero.

 fs/dax.c    | 47 +++++++++++++++++++++++++++++++++++++----------
 mm/memory.c |  1 +
 2 files changed, 38 insertions(+), 10 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 6308197..2640db6 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -100,6 +100,19 @@ static bool buffer_written(struct buffer_head *bh)
 	return buffer_mapped(bh) && !buffer_unwritten(bh);
 }
 
+/*
+ * When ext4 encounters a hole, it likes to return without modifying the
+ * buffer_head which means that we can't trust b_size.  To cope with this,
+ * we set b_state to 0 before calling get_block and, if any bit is set, we
+ * know we can trust b_size.  Unfortunate, really, since ext4 does know
+ * precisely how long a hole is and would save us time calling get_block
+ * repeatedly.
+ */
+static bool buffer_size_valid(struct buffer_head *bh)
+{
+	return bh->b_state != 0;
+}
+
 static ssize_t dax_io(int rw, struct inode *inode, const struct iovec *iov,
 			loff_t start, loff_t end, get_block_t get_block,
 			struct buffer_head *bh)
@@ -110,6 +123,7 @@ static ssize_t dax_io(int rw, struct inode *inode, const struct iovec *iov,
 	unsigned copied = 0;
 	loff_t offset = start;
 	loff_t max = start;
+	loff_t bh_max = start;
 	void *addr;
 	bool hole = false;
 
@@ -119,15 +133,27 @@ static ssize_t dax_io(int rw, struct inode *inode, const struct iovec *iov,
 	while (offset < end) {
 		void __user *buf = iov[seg].iov_base + copied;
 
-		if (max == offset) {
+		if (offset == max) {
 			sector_t block = offset >> inode->i_blkbits;
 			unsigned first = offset - (block << inode->i_blkbits);
 			long size;
-			memset(bh, 0, sizeof(*bh));
-			bh->b_size = ALIGN(end - offset, PAGE_SIZE);
-			retval = get_block(inode, block, bh, rw == WRITE);
-			if (retval)
-				break;
+
+			if (offset == bh_max) {
+				bh->b_size = PAGE_ALIGN(end - offset);
+				bh->b_state = 0;
+				retval = get_block(inode, block, bh,
+								rw == WRITE);
+				if (retval)
+					break;
+				if (!buffer_size_valid(bh))
+					bh->b_size = 1 << inode->i_blkbits;
+				bh_max = offset - first + bh->b_size;
+			} else {
+				unsigned done = bh->b_size - (bh_max -
+							(offset - first));
+				bh->b_blocknr += done >> inode->i_blkbits;
+				bh->b_size -= done;
+			}
 			if (rw == WRITE) {
 				if (!buffer_mapped(bh)) {
 					retval = -EIO;
@@ -140,10 +166,7 @@ static ssize_t dax_io(int rw, struct inode *inode, const struct iovec *iov,
 
 			if (hole) {
 				addr = NULL;
-				if (buffer_uptodate(bh))
-					size = bh->b_size - first;
-				else
-					size = (1 << inode->i_blkbits) - first;
+				size = bh->b_size - first;
 			} else {
 				retval = dax_get_addr(inode, bh, &addr);
 				if (retval < 0)
@@ -209,6 +232,7 @@ ssize_t dax_do_io(int rw, struct kiocb *iocb, struct inode *inode,
 	ssize_t retval = -EINVAL;
 	loff_t end = offset;
 
+	memset(&bh, 0, sizeof(bh));
 	for (seg = 0; seg < nr_segs; seg++)
 		end += iov[seg].iov_len;
 
@@ -314,6 +338,9 @@ static int do_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		}
 	}
 
+	if (buffer_unwritten(&bh) || buffer_new(&bh))
+		dax_clear_blocks(inode, bh.b_blocknr, bh.b_size);
+
 	/* Recheck i_size under i_mmap_mutex */
 	mutex_lock(&mapping->i_mmap_mutex);
 	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
diff --git a/mm/memory.c b/mm/memory.c
index 4e1bdee..3c6b8b2 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2672,6 +2672,7 @@ static int do_page_mkwrite(struct vm_area_struct *vma, struct page *page,
 	vmf.pgoff = page->index;
 	vmf.flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
 	vmf.page = page;
+	vmf.cow_page = NULL;
 
 	ret = vma->vm_ops->page_mkwrite(vma, &vmf);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
