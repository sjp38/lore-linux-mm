Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 7411F6B0005
	for <linux-mm@kvack.org>; Thu, 24 Mar 2016 19:17:50 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id td3so33061411pab.2
        for <linux-mm@kvack.org>; Thu, 24 Mar 2016 16:17:50 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id tb4si295141pab.121.2016.03.24.16.17.49
        for <linux-mm@kvack.org>;
        Thu, 24 Mar 2016 16:17:49 -0700 (PDT)
From: Vishal Verma <vishal.l.verma@intel.com>
Subject: [PATCH 0/5] dax: handling of media errors
Date: Thu, 24 Mar 2016 17:17:25 -0600
Message-Id: <1458861450-17705-1-git-send-email-vishal.l.verma@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Vishal Verma <vishal.l.verma@intel.com>, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <matthew.r.wilcox@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@fb.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

Until now, dax has been disabled if media errors were found on
any device. This series attempts to address that.

The first three patches from Dan re-enable dax even when media
errors are present.

The fourth patch from Matthew removes the
zeroout path from dax entirely, making zeroout operations always
go through the driver (The motivation is that if a backing device
has media errors, and we create a sparse file on it, we don't
want the initial zeroing to happen via dax, we want to give the
block driver a chance to clear the errors).

The fifth patch changes the behaviour of dax_do_io by adding a
wrapper around it that is passed all the arguments also needed by
__blockdev_do_direct_IO. If (the new) __dax_do_io fails with -EIO
due to a bad block, we simply retry with the direct_IO path which
forces the IO to go through the block driver, and can attempt to
clear the error.

Dan Williams (3):
  block, dax: pass blk_dax_ctl through to drivers
  dax: fallback from pmd to pte on error
  dax: enable dax in the presence of known media errors (badblocks)

Vishal Verma (2):
  dax: use sb_issue_zerout instead of calling dax_clear_sectors
  dax: handle media errors in dax_do_io

 arch/powerpc/sysdev/axonram.c | 10 +++----
 block/ioctl.c                 |  9 ------
 drivers/block/brd.c           |  9 +++---
 drivers/nvdimm/pmem.c         | 17 ++++++++---
 drivers/s390/block/dcssblk.c  | 12 ++++----
 fs/block_dev.c                |  7 +++--
 fs/dax.c                      | 70 +++++++++++++++++++++----------------------
 fs/ext2/inode.c               | 12 ++++----
 fs/ext4/indirect.c            | 11 ++++---
 fs/ext4/inode.c               |  5 ++--
 fs/xfs/xfs_aops.c             |  7 +++--
 fs/xfs/xfs_bmap_util.c        |  9 ------
 include/linux/blkdev.h        |  3 +-
 include/linux/dax.h           |  7 +++--
 14 files changed, 93 insertions(+), 95 deletions(-)

-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
