Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id D2DE76B0261
	for <linux-mm@kvack.org>; Wed, 11 May 2016 17:09:22 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id xm6so77612827pab.3
        for <linux-mm@kvack.org>; Wed, 11 May 2016 14:09:22 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id j9si12334420pan.36.2016.05.11.14.09.22
        for <linux-mm@kvack.org>;
        Wed, 11 May 2016 14:09:22 -0700 (PDT)
From: Vishal Verma <vishal.l.verma@intel.com>
Subject: [PATCH v7 4/6] dax: export a low-level __dax_zero_page_range helper
Date: Wed, 11 May 2016 15:08:50 -0600
Message-Id: <1463000932-31680-5-git-send-email-vishal.l.verma@intel.com>
In-Reply-To: <1463000932-31680-1-git-send-email-vishal.l.verma@intel.com>
References: <1463000932-31680-1-git-send-email-vishal.l.verma@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Christoph Hellwig <hch@lst.de>, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@fb.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Jeff Moyer <jmoyer@redhat.com>, Boaz Harrosh <boaz@plexistor.com>

From: Christoph Hellwig <hch@lst.de>

This allows XFS to perform zeroing using the iomap infrastructure and
avoid buffer heads.

[vishal: fix conflicts with dax-error-handling]
Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/dax.c            | 35 ++++++++++++++++++++---------------
 include/linux/dax.h |  7 +++++++
 2 files changed, 27 insertions(+), 15 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 0abbbb6..651d4b1 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -947,6 +947,23 @@ int dax_pfn_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 }
 EXPORT_SYMBOL_GPL(dax_pfn_mkwrite);
 
+int __dax_zero_page_range(struct block_device *bdev, sector_t sector,
+		unsigned int offset, unsigned int length)
+{
+	struct blk_dax_ctl dax = {
+		.sector		= sector,
+		.size		= PAGE_SIZE,
+	};
+
+	if (dax_map_atomic(bdev, &dax) < 0)
+		return PTR_ERR(dax.addr);
+	clear_pmem(dax.addr + offset, length);
+	wmb_pmem();
+	dax_unmap_atomic(bdev, &dax);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(__dax_zero_page_range);
+
 /**
  * dax_zero_page_range - zero a range within a page of a DAX file
  * @inode: The file being truncated
@@ -982,23 +999,11 @@ int dax_zero_page_range(struct inode *inode, loff_t from, unsigned length,
 	bh.b_bdev = inode->i_sb->s_bdev;
 	bh.b_size = PAGE_SIZE;
 	err = get_block(inode, index, &bh, 0);
-	if (err < 0)
+	if (err < 0 || !buffer_written(&bh))
 		return err;
-	if (buffer_written(&bh)) {
-		struct block_device *bdev = bh.b_bdev;
-		struct blk_dax_ctl dax = {
-			.sector = to_sector(&bh, inode),
-			.size = PAGE_SIZE,
-		};
 
-		if (dax_map_atomic(bdev, &dax) < 0)
-			return PTR_ERR(dax.addr);
-		clear_pmem(dax.addr + offset, length);
-		wmb_pmem();
-		dax_unmap_atomic(bdev, &dax);
-	}
-
-	return 0;
+	return __dax_zero_page_range(bh.b_bdev, to_sector(&bh, inode),
+			offset, length);
 }
 EXPORT_SYMBOL_GPL(dax_zero_page_range);
 
diff --git a/include/linux/dax.h b/include/linux/dax.h
index 7f853ff..90fbc99 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -14,12 +14,19 @@ int __dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t);
 
 #ifdef CONFIG_FS_DAX
 struct page *read_dax_sector(struct block_device *bdev, sector_t n);
+int __dax_zero_page_range(struct block_device *bdev, sector_t sector,
+		unsigned int offset, unsigned int length);
 #else
 static inline struct page *read_dax_sector(struct block_device *bdev,
 		sector_t n)
 {
 	return ERR_PTR(-ENXIO);
 }
+static inline int __dax_zero_page_range(struct block_device *bdev,
+		sector_t sector, unsigned int offset, unsigned int length)
+{
+	return -ENXIO;
+}
 #endif
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
