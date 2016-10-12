Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 271DC6B025E
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 18:50:31 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id t25so56084891pfg.3
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 15:50:31 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id m6si9442179pab.331.2016.10.12.15.50.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Oct 2016 15:50:30 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v6 03/17] dax: remove buffer_size_valid()
Date: Wed, 12 Oct 2016 16:50:08 -0600
Message-Id: <20161012225022.15507-4-ross.zwisler@linux.intel.com>
In-Reply-To: <20161012225022.15507-1-ross.zwisler@linux.intel.com>
References: <20161012225022.15507-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

Now that ext4 properly sets bh.b_size when we call get_block() for a hole,
rely on that value and remove the buffer_size_valid() sanity check.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Reviewed-by: Jan Kara <jack@suse.cz>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/dax.c | 22 +---------------------
 1 file changed, 1 insertion(+), 21 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index cc025f8..9b9be8a 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -123,19 +123,6 @@ static bool buffer_written(struct buffer_head *bh)
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
@@ -177,8 +164,6 @@ static ssize_t dax_io(struct inode *inode, struct iov_iter *iter,
 				rc = get_block(inode, block, bh, rw == WRITE);
 				if (rc)
 					break;
-				if (!buffer_size_valid(bh))
-					bh->b_size = 1 << blkbits;
 				bh_max = pos - first + bh->b_size;
 				bdev = bh->b_bdev;
 				/*
@@ -1012,12 +997,7 @@ int dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 
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
