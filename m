Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id AF2916B0005
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 17:17:21 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id zy2so139381947pac.1
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 14:17:21 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id fv2si13599089pad.86.2016.04.28.14.17.20
        for <linux-mm@kvack.org>;
        Thu, 28 Apr 2016 14:17:20 -0700 (PDT)
From: Vishal Verma <vishal.l.verma@intel.com>
Subject: [PATCH v4 0/7] dax: handling media errors
Date: Thu, 28 Apr 2016 15:16:51 -0600
Message-Id: <1461878218-3844-1-git-send-email-vishal.l.verma@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Vishal Verma <vishal.l.verma@intel.com>, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <matthew@wil.cx>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@fb.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Jeff Moyer <jmoyer@redhat.com>

Until now, dax has been disabled if media errors were found on
any device. This series attempts to address that.

The first three patches from Dan re-enable dax even when media
errors are present.

The fourth patch from Matthew removes the zeroout path from dax
entirely, making zeroout operations always go through the driver
(The motivation is that if a backing device has media errors,
and we create a sparse file on it, we don't want the initial
zeroing to happen via dax, we want to give the block driver a
chance to clear the errors).

The fifth patch changes how DAX IO is re-routed as direct IO.
We add a new iocb flag for DAX to distinguish it from actual
direct IO, and if we're in O_DIRECT, use the regular direct_IO
path instead of DAX. This gives us an opportunity to do recovery
by doing O_DIRECT writes that will go through the driver to clear
errors from bad sectors.

Patch 6 reduces our calls to clear_pmem from dax in the
truncate/hole-punch cases. We check if the range being truncated
is sector aligned/sized, and if so, send blkdev_issue_zeroout
instead of clear_pmem so that errors can be handled better by
the driver.

Patch 7 fixes a redundant comment in DAX and is mostly unrelated
to the rest of this series.

This series also depends on/is based on Jan Kara's DAX Locking
fixes series [1].


[1]: http://www.spinics.net/lists/linux-mm/msg105819.html

v4:
 - Remove the dax->direct_IO fallbacks entirely. Instead, go through
   the usual direct_IO path when we're in O_DIRECT, and use dax_IO
   for other, non O_DIRECT IO. (Dan, Christoph)

v3:
 - Wrapper-ize the direct_IO fallback again and make an exception
   for -EIOCBQUEUED (Jeff, Dan)
 - Reduce clear_pmem usage in DAX to the minimum


Dan Williams (3):
  block, dax: pass blk_dax_ctl through to drivers
  dax: fallback from pmd to pte on error
  dax: enable dax in the presence of known media errors (badblocks)

Matthew Wilcox (1):
  dax: use sb_issue_zerout instead of calling dax_clear_sectors

Vishal Verma (3):
  fs: prioritize and separate direct_io from dax_io
  dax: for truncate/hole-punch, do zeroing through the driver if
    possible
  dax: fix a comment in dax_zero_page_range and dax_truncate_page

 arch/powerpc/sysdev/axonram.c | 10 +++---
 block/ioctl.c                 |  9 -----
 drivers/block/brd.c           |  9 ++---
 drivers/block/loop.c          |  2 +-
 drivers/nvdimm/pmem.c         | 17 +++++++---
 drivers/s390/block/dcssblk.c  | 12 +++----
 fs/block_dev.c                | 19 ++++++++---
 fs/dax.c                      | 78 +++++++++++++++----------------------------
 fs/ext2/inode.c               | 23 ++++++++-----
 fs/ext4/file.c                |  2 +-
 fs/ext4/inode.c               | 19 +++++++----
 fs/xfs/xfs_aops.c             | 20 +++++++----
 fs/xfs/xfs_bmap_util.c        | 15 +++------
 fs/xfs/xfs_file.c             |  4 +--
 include/linux/blkdev.h        |  3 +-
 include/linux/dax.h           |  1 -
 include/linux/fs.h            | 15 +++++++--
 mm/filemap.c                  |  4 +--
 18 files changed, 134 insertions(+), 128 deletions(-)

-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
