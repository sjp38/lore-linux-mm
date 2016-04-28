Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id AC1776B0262
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 17:17:33 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id vv3so139324877pab.2
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 14:17:33 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id fv2si13599089pad.86.2016.04.28.14.17.25
        for <linux-mm@kvack.org>;
        Thu, 28 Apr 2016 14:17:26 -0700 (PDT)
From: Vishal Verma <vishal.l.verma@intel.com>
Subject: [PATCH v4 6/7] dax: for truncate/hole-punch, do zeroing through the driver if possible
Date: Thu, 28 Apr 2016 15:16:57 -0600
Message-Id: <1461878218-3844-7-git-send-email-vishal.l.verma@intel.com>
In-Reply-To: <1461878218-3844-1-git-send-email-vishal.l.verma@intel.com>
References: <1461878218-3844-1-git-send-email-vishal.l.verma@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Vishal Verma <vishal.l.verma@intel.com>, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <matthew@wil.cx>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@fb.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Jeff Moyer <jmoyer@redhat.com>

In the truncate or hole-punch path in dax, we clear out sub-page ranges.
If these sub-page ranges are sector aligned and sized, we can do the
zeroing through the driver instead so that error-clearing is handled
automatically.

For sub-sector ranges, we still have to rely on clear_pmem and have the
possibility of tripping over errors.

Cc: Matthew Wilcox <matthew@wil.cx>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jeff Moyer <jmoyer@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>
Signed-off-by: Vishal Verma <vishal.l.verma@intel.com>
---
 fs/dax.c | 30 +++++++++++++++++++++++++-----
 1 file changed, 25 insertions(+), 5 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 5948d9b..d8c974e 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -1196,6 +1196,20 @@ out:
 }
 EXPORT_SYMBOL_GPL(dax_pfn_mkwrite);
 
+static bool dax_range_is_aligned(struct block_device *bdev,
+				 struct blk_dax_ctl *dax, unsigned int offset,
+				 unsigned int length)
+{
+	unsigned short sector_size = bdev_logical_block_size(bdev);
+
+	if (((u64)dax->addr + offset) % sector_size)
+		return false;
+	if (length % sector_size)
+		return false;
+
+	return true;
+}
+
 /**
  * dax_zero_page_range - zero a range within a page of a DAX file
  * @inode: The file being truncated
@@ -1240,11 +1254,17 @@ int dax_zero_page_range(struct inode *inode, loff_t from, unsigned length,
 			.size = PAGE_SIZE,
 		};
 
-		if (dax_map_atomic(bdev, &dax) < 0)
-			return PTR_ERR(dax.addr);
-		clear_pmem(dax.addr + offset, length);
-		wmb_pmem();
-		dax_unmap_atomic(bdev, &dax);
+		if (dax_range_is_aligned(bdev, &dax, offset, length))
+			return blkdev_issue_zeroout(bdev, dax.sector,
+					length / bdev_logical_block_size(bdev),
+					GFP_NOFS, true);
+		else {
+			if (dax_map_atomic(bdev, &dax) < 0)
+				return PTR_ERR(dax.addr);
+			clear_pmem(dax.addr + offset, length);
+			wmb_pmem();
+			dax_unmap_atomic(bdev, &dax);
+		}
 	}
 
 	return 0;
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
