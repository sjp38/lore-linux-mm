Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id DA7DC6B0267
	for <linux-mm@kvack.org>; Mon, 22 Feb 2016 13:59:41 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id ho8so98020405pac.2
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 10:59:41 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id af6si41329226pad.226.2016.02.22.10.59.40
        for <linux-mm@kvack.org>;
        Mon, 22 Feb 2016 10:59:40 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v4 1/5] block: disable block device DAX by default
Date: Mon, 22 Feb 2016 11:59:18 -0700
Message-Id: <1456167562-28576-2-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1456167562-28576-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1456167562-28576-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dan Williams <dan.j.williams@intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Jens Axboe <axboe@kernel.dk>, Matthew Wilcox <willy@linux.intel.com>, linux-block@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, xfs@oss.sgi.com, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@fb.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Al Viro <viro@ftp.linux.org.uk>, Ross Zwisler <ross.zwisler@linux.intel.com>

From: Dan Williams <dan.j.williams@intel.com>

The recent *sync enabling discovered that we are inserting into the
block_device pagecache counter to the expectations of the dirty data
tracking for dax mappings.  This can lead to data corruption.

We want to support DAX for block devices eventually, but it requires
wider changes to properly manage the pagecache.

  [<ffffffff81576d93>] dump_stack+0x85/0xc2
  [<ffffffff812b9ee0>] dax_writeback_mapping_range+0x60/0xe0
  [<ffffffff812a1d4f>] blkdev_writepages+0x3f/0x50
  [<ffffffff811db011>] do_writepages+0x21/0x30
  [<ffffffff811cb6a6>] __filemap_fdatawrite_range+0xc6/0x100
  [<ffffffff811cb75a>] filemap_write_and_wait+0x4a/0xa0
  [<ffffffff812a15e0>] set_blocksize+0x70/0xd0
  [<ffffffff812a273d>] sb_set_blocksize+0x1d/0x50
  [<ffffffff8132ac9b>] ext4_fill_super+0x75b/0x3360
  [<ffffffff81583381>] ? vsnprintf+0x201/0x4c0
  [<ffffffff815836d9>] ? snprintf+0x49/0x60
  [<ffffffff81263010>] mount_bdev+0x180/0x1b0
  [<ffffffff8132a540>] ? ext4_calculate_overhead+0x370/0x370
  [<ffffffff8131ad95>] ext4_mount+0x15/0x20
  [<ffffffff81263908>] mount_fs+0x38/0x170

Mark the support broken so its disabled by default, but otherwise still
available for testing.

Cc: Jan Kara <jack@suse.cz>
Cc: Jens Axboe <axboe@fb.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: Al Viro <viro@ftp.linux.org.uk>
Reported-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Suggested-by: Dave Chinner <david@fromorbit.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 block/Kconfig  | 13 +++++++++++++
 fs/block_dev.c |  6 +++++-
 2 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/block/Kconfig b/block/Kconfig
index 161491d..0363cd7 100644
--- a/block/Kconfig
+++ b/block/Kconfig
@@ -88,6 +88,19 @@ config BLK_DEV_INTEGRITY
 	T10/SCSI Data Integrity Field or the T13/ATA External Path
 	Protection.  If in doubt, say N.
 
+config BLK_DEV_DAX
+	bool "Block device DAX support"
+	depends on FS_DAX
+	depends on BROKEN
+	help
+	  When DAX support is available (CONFIG_FS_DAX) raw block
+	  devices can also support direct userspace access to the
+	  storage capacity via MMAP(2) similar to a file on a
+	  DAX-enabled filesystem.  However, the DAX I/O-path disables
+	  some standard I/O-statistics, and the MMAP(2) path has some
+	  operational differences due to bypassing the page
+	  cache.  If in doubt, say N.
+
 config BLK_DEV_THROTTLING
 	bool "Block layer bio throttling support"
 	depends on BLK_CGROUP=y
diff --git a/fs/block_dev.c b/fs/block_dev.c
index 39b3a17..31c6d10 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -1201,7 +1201,11 @@ static int __blkdev_get(struct block_device *bdev, fmode_t mode, int for_part)
 		bdev->bd_disk = disk;
 		bdev->bd_queue = disk->queue;
 		bdev->bd_contains = bdev;
-		bdev->bd_inode->i_flags = disk->fops->direct_access ? S_DAX : 0;
+		if (IS_ENABLED(CONFIG_BLK_DEV_DAX) && disk->fops->direct_access)
+			bdev->bd_inode->i_flags = S_DAX;
+		else
+			bdev->bd_inode->i_flags = 0;
+
 		if (!partno) {
 			ret = -ENXIO;
 			bdev->bd_part = disk_get_part(disk, partno);
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
