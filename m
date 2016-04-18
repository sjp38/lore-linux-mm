Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E20F56B0268
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 17:36:09 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w143so200724wmw.2
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 14:36:09 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c76si790049wmh.32.2016.04.18.14.35.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Apr 2016 14:35:52 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 09/18] dax: Remove zeroing from dax_io()
Date: Mon, 18 Apr 2016 23:35:32 +0200
Message-Id: <1461015341-20153-10-git-send-email-jack@suse.cz>
In-Reply-To: <1461015341-20153-1-git-send-email-jack@suse.cz>
References: <1461015341-20153-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-ext4@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>, Jan Kara <jack@suse.cz>

All the filesystems are now zeroing blocks themselves for DAX IO to avoid
races between dax_io() and dax_fault(). Remove the zeroing code from
dax_io() and add warning to catch the case when somebody unexpectedly
returns new or unwritten buffer.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c | 28 ++++++++++------------------
 1 file changed, 10 insertions(+), 18 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index ccb8bc399d78..7c0036dd1570 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -119,18 +119,6 @@ int dax_clear_sectors(struct block_device *bdev, sector_t _sector, long _size)
 }
 EXPORT_SYMBOL_GPL(dax_clear_sectors);
 
-/* the clear_pmem() calls are ordered by a wmb_pmem() in the caller */
-static void dax_new_buf(void __pmem *addr, unsigned size, unsigned first,
-		loff_t pos, loff_t end)
-{
-	loff_t final = end - pos + first; /* The final byte of the buffer */
-
-	if (first > 0)
-		clear_pmem(addr, first);
-	if (final < size)
-		clear_pmem(addr + final, size - final);
-}
-
 static bool buffer_written(struct buffer_head *bh)
 {
 	return buffer_mapped(bh) && !buffer_unwritten(bh);
@@ -169,6 +157,9 @@ static ssize_t dax_io(struct inode *inode, struct iov_iter *iter,
 	struct blk_dax_ctl dax = {
 		.addr = (void __pmem *) ERR_PTR(-EIO),
 	};
+	unsigned blkbits = inode->i_blkbits;
+	sector_t file_blks = (i_size_read(inode) + (1 << blkbits) - 1)
+								>> blkbits;
 
 	if (rw == READ)
 		end = min(end, i_size_read(inode));
@@ -176,7 +167,6 @@ static ssize_t dax_io(struct inode *inode, struct iov_iter *iter,
 	while (pos < end) {
 		size_t len;
 		if (pos == max) {
-			unsigned blkbits = inode->i_blkbits;
 			long page = pos >> PAGE_SHIFT;
 			sector_t block = page << (PAGE_SHIFT - blkbits);
 			unsigned first = pos - (block << blkbits);
@@ -192,6 +182,13 @@ static ssize_t dax_io(struct inode *inode, struct iov_iter *iter,
 					bh->b_size = 1 << blkbits;
 				bh_max = pos - first + bh->b_size;
 				bdev = bh->b_bdev;
+				/*
+				 * We allow uninitialized buffers for writes
+				 * beyond EOF as those cannot race with faults
+				 */
+				WARN_ON_ONCE(
+					(buffer_new(bh) && block < file_blks) ||
+					(rw == WRITE && buffer_unwritten(bh)));
 			} else {
 				unsigned done = bh->b_size -
 						(bh_max - (pos - first));
@@ -211,11 +208,6 @@ static ssize_t dax_io(struct inode *inode, struct iov_iter *iter,
 					rc = map_len;
 					break;
 				}
-				if (buffer_unwritten(bh) || buffer_new(bh)) {
-					dax_new_buf(dax.addr, map_len, first,
-							pos, end);
-					need_wmb = true;
-				}
 				dax.addr += first;
 				size = map_len - first;
 			}
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
