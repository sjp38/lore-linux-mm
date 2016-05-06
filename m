Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B42096B026E
	for <linux-mm@kvack.org>; Fri,  6 May 2016 17:53:59 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b203so253585812pfb.1
        for <linux-mm@kvack.org>; Fri, 06 May 2016 14:53:59 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id vx8si20608105pac.107.2016.05.06.14.53.58
        for <linux-mm@kvack.org>;
        Fri, 06 May 2016 14:53:58 -0700 (PDT)
From: Vishal Verma <vishal.l.verma@intel.com>
Subject: [PATCH v5 4/5] dax: for truncate/hole-punch, do zeroing through the driver if possible
Date: Fri,  6 May 2016 15:53:10 -0600
Message-Id: <1462571591-3361-5-git-send-email-vishal.l.verma@intel.com>
In-Reply-To: <1462571591-3361-1-git-send-email-vishal.l.verma@intel.com>
References: <1462571591-3361-1-git-send-email-vishal.l.verma@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Vishal Verma <vishal.l.verma@intel.com>, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@fb.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Jeff Moyer <jmoyer@redhat.com>, Boaz Harrosh <boaz@plexistor.com>

In the truncate or hole-punch path in dax, we clear out sub-page ranges.
If these sub-page ranges are sector aligned and sized, we can do the
zeroing through the driver instead so that error-clearing is handled
automatically.

For sub-sector ranges, we still have to rely on clear_pmem and have the
possibility of tripping over errors.

Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jeff Moyer <jmoyer@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>
Signed-off-by: Vishal Verma <vishal.l.verma@intel.com>
---
 Documentation/filesystems/dax.txt | 32 ++++++++++++++++++++++++++++++++
 fs/dax.c                          | 30 +++++++++++++++++++++++++-----
 2 files changed, 57 insertions(+), 5 deletions(-)

diff --git a/Documentation/filesystems/dax.txt b/Documentation/filesystems/dax.txt
index 7bde640..ce4587d 100644
--- a/Documentation/filesystems/dax.txt
+++ b/Documentation/filesystems/dax.txt
@@ -79,6 +79,38 @@ These filesystems may be used for inspiration:
 - ext4: the fourth extended filesystem, see Documentation/filesystems/ext4.txt
 
 
+Handling Media Errors
+---------------------
+
+The libnvdimm subsystem stores a record of known media error locations for
+each pmem block device (in gendisk->badblocks). If we fault at such location,
+or one with a latent error not yet discovered, the application can expect
+to receive a SIGBUS. Libnvdimm also allows clearing of these errors by simply
+writing the affected sectors (through the pmem driver, and if the underlying
+NVDIMM supports the clear_poison DSM defined by ACPI).
+
+Since DAX IO normally doesn't go through the driver/bio path, applications or
+sysadmins have an option to restore the lost data from a prior backup/inbuilt
+redundancy in the following ways:
+
+1. Delete the affected file, and restore from a backup (sysadmin route):
+   This will free the file system blocks that were being used by the file,
+   and the next time they're allocated, they will be zeroed first, which
+   happens through the driver, and will clear bad sectors.
+
+2. Truncate or hole-punch the part of the file that has a bad-block (at least
+   an entire aligned sector has to be hole-punched, but not necessarily an
+   entire filesystem block).
+
+These are the two basic paths that allow DAX filesystems to continue operating
+in the presence of media errors. More robust error recovery mechanisms can be
+built on top of this in the future, for example, involving redundancy/mirroring
+provided at the block layer through DM, or additionally, at the filesystem
+level. These would have to rely on the above two tenets, that error clearing
+can happen either by sending an IO through the driver, or zeroing (also through
+the driver).
+
+
 Shortcomings
 ------------
 
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
