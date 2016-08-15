Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8FCED828F3
	for <linux-mm@kvack.org>; Mon, 15 Aug 2016 15:09:59 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id le9so116540545pab.0
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 12:09:59 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id p4si19115744paz.202.2016.08.15.12.09.54
        for <linux-mm@kvack.org>;
        Mon, 15 Aug 2016 12:09:54 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH 3/7] dax: remove buffer_size_valid()
Date: Mon, 15 Aug 2016 13:09:14 -0600
Message-Id: <20160815190918.20672-4-ross.zwisler@linux.intel.com>
In-Reply-To: <20160815190918.20672-1-ross.zwisler@linux.intel.com>
References: <20160815190918.20672-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

Now that all our supported filesystems (ext2, ext4 and XFS) all properly
set bh.b_size when we call get_block() for a hole, rely on that value and
remove the buffer_size_valid() sanity check.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/dax.c | 22 +---------------------
 1 file changed, 1 insertion(+), 21 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 993dc6f..8030f93 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -121,19 +121,6 @@ static bool buffer_written(struct buffer_head *bh)
 	return buffer_mapped(bh) && !buffer_unwritten(bh);
 }
 
-/*
- * When ext4 encounters a hole, it returns without modifying the buffer_head
- * which means that we can't trust b_size.  To cope with this, we set b_state
- * to 0 before calling get_block and, if any bit is set, we know we can trust
- * b_size.  Unfortunate, really, since ext4 knows precisely how long a hole is
- * and would save us time calling get_block repeatedly.
- */
-static bool buffer_size_valid(struct buffer_head *bh)
-{
-	return bh->b_state != 0;
-}
-
-
 static sector_t to_sector(const struct buffer_head *bh,
 		const struct inode *inode)
 {
@@ -175,8 +162,6 @@ static ssize_t dax_io(struct inode *inode, struct iov_iter *iter,
 				rc = get_block(inode, block, bh, rw == WRITE);
 				if (rc)
 					break;
-				if (!buffer_size_valid(bh))
-					bh->b_size = 1 << blkbits;
 				bh_max = pos - first + bh->b_size;
 				bdev = bh->b_bdev;
 				/*
@@ -1010,12 +995,7 @@ int dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 
 	bdev = bh.b_bdev;
 
-	/*
-	 * If the filesystem isn't willing to tell us the length of a hole,
-	 * just fall back to PTEs.  Calling get_block 512 times in a loop
-	 * would be silly.
-	 */
-	if (!buffer_size_valid(&bh) || bh.b_size < PMD_SIZE) {
+	if (bh.b_size < PMD_SIZE) {
 		dax_pmd_dbg(&bh, address, "allocated block too small");
 		return VM_FAULT_FALLBACK;
 	}
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
