Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id A23AD6B0266
	for <linux-mm@kvack.org>; Mon, 22 Feb 2016 13:59:40 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fl4so95558358pad.0
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 10:59:40 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id af6si41329226pad.226.2016.02.22.10.59.39
        for <linux-mm@kvack.org>;
        Mon, 22 Feb 2016 10:59:39 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v4 0/5] DAX fixes, move flushing calls to FS
Date: Mon, 22 Feb 2016 11:59:17 -0700
Message-Id: <1456167562-28576-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Jens Axboe <axboe@kernel.dk>, Matthew Wilcox <willy@linux.intel.com>, linux-block@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, xfs@oss.sgi.com

Changes since v3:
- Added Reviewed-by tags from Jan Kara.
- Dropped patch 6, "block: use dax_do_io() if blkdev_dax_capable()"

I believe that this series is ready for inclusion in v4.5.  I think it
should be merged for v4.5 because it fixes serious issues with the DAX code
including possible data corruption and kernel OOPSes.

akpm, for the v4.5 merge do you want these patches to go through the -mm
tree, or would it be better if I just sent them to Linus directly?

A working tree can be found here:
https://git.kernel.org/cgit/linux/kernel/git/zwisler/linux.git/log/?h=fsync_bdev_v4

---
Previous summary with issue impacts added:

This patch series fixes several issues with the current DAX code:

1) DAX is used by default on raw block devices that are capable of
supporting it.  This creates an issue because there are still uses of the
block device that use the page cache, and having one block device user
doing DAX I/O and another doing page cache I/O can lead to data corruption.

2) When S_DAX is set on an inode we assume that if there are pages attached
to the mapping (mapping->nrpages != 0), those pages are clean zero pages
that were used to service reads from holes.  This wasn't true in all cases.

3) ext4 online defrag combined with DAX I/O could lead to data corruption.

4) The DAX block/sector zeroing code needs a valid struct block_device,
which it wasn't always getting.  This could lead to a kernel OOPS.

5) The DAX writeback code needs a valid struct block_device, which it
wasn't always getting.  This could lead to a kernel OOPS.

6) The DAX writeback code needs to be called for sync(2) and syncfs(2).
This could lead to data loss.

Dan Williams (1):
  block: disable block device DAX by default

Ross Zwisler (4):
  ext2, ext4: only set S_DAX for regular inodes
  ext4: Online defrag not supported with DAX
  dax: give DAX clearing code correct bdev
  dax: move writeback calls into the filesystems

 block/Kconfig          | 13 +++++++++++++
 fs/block_dev.c         | 19 +++++++++++++++++--
 fs/dax.c               | 21 +++++++++++----------
 fs/ext2/inode.c        | 16 +++++++++++++---
 fs/ext4/inode.c        |  6 +++++-
 fs/ext4/ioctl.c        |  5 +++++
 fs/xfs/xfs_aops.c      |  6 +++++-
 fs/xfs/xfs_aops.h      |  1 +
 fs/xfs/xfs_bmap_util.c |  3 ++-
 include/linux/dax.h    |  8 +++++---
 mm/filemap.c           | 12 ++++--------
 11 files changed, 81 insertions(+), 29 deletions(-)

-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
