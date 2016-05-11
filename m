Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7B3FD6B0005
	for <linux-mm@kvack.org>; Wed, 11 May 2016 17:09:17 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id xm6so77609684pab.3
        for <linux-mm@kvack.org>; Wed, 11 May 2016 14:09:17 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id j9si12334420pan.36.2016.05.11.14.09.16
        for <linux-mm@kvack.org>;
        Wed, 11 May 2016 14:09:16 -0700 (PDT)
From: Vishal Verma <vishal.l.verma@intel.com>
Subject: [PATCH v7 0/6] dax: handling media errors (clear-on-zero only)
Date: Wed, 11 May 2016 15:08:46 -0600
Message-Id: <1463000932-31680-1-git-send-email-vishal.l.verma@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Vishal Verma <vishal.l.verma@intel.com>, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@fb.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Jeff Moyer <jmoyer@redhat.com>, Boaz Harrosh <boaz@plexistor.com>

Until now, dax has been disabled if media errors were found on
any device. This series attempts to address that.

The first two patches from Dan re-enable dax even when media
errors are present.

The third patch from Matthew removes the zeroout path from dax
entirely, making zeroout operations always go through the driver
(The motivation is that if a backing device has media errors,
and we create a sparse file on it, we don't want the initial
zeroing to happen via dax, we want to give the block driver a
chance to clear the errors).

Patch 4 from Christoph exports a low level dax helper for zeroing

Patch 5 reduces our calls to clear_pmem from dax in the
truncate/hole-punch cases. We check if the range being truncated
is sector aligned/sized, and if so, send blkdev_issue_zeroout
instead of clear_pmem so that errors can be handled better by
the driver.

Patch 6 fixes a redundant comment in DAX and is mostly unrelated
to the rest of this series.

This series also depends on/is based on Jan Kara's Ext4 and DAX
fixups series:
http://marc.info/?l=linux-ext4&m=146295959100848&w=2
http://marc.info/?l=linux-ext4&m=146296078001307&w=2

v7:
 - Fix the dax alignment check to only check 'offset' and 'length'
   for alignment as that's all that is needed. (Jan)
 - Fix the blockdev_issue_zeroout call to zero the correct sector
 - Rebase to v4.6-rc7 + the two patch-series from Jan linked above
 - Add a patch from Christoph's iomap series:
   http://www.spinics.net/lists/xfs/msg39656.html

v6:
 - Use IS_ALIGNED in dax_range_is_aligned instead of open coding
   an alignment check (Jan)
 - Collect all Reveiwed-by tags so far.

v5:
 - Drop the patch that attempts to clear-errors-on-write till we
   reach consensus on how to handle that.
 - Don't pass blk_dax_ctl to direct_access, instead pass in all the
   required arguments individually (Christoph, Dan)

v4:
 - Remove the dax->direct_IO fallbacks entirely. Instead, go through
   the usual direct_IO path when we're in O_DIRECT, and use dax_IO
   for other, non O_DIRECT IO. (Dan, Christoph)

v3:
 - Wrapper-ize the direct_IO fallback again and make an exception
   for -EIOCBQUEUED (Jeff, Dan)
 - Reduce clear_pmem usage in DAX to the minimum



Christoph Hellwig (1):
  dax: export a low-level __dax_zero_page_range helper

Dan Williams (2):
  dax: fallback from pmd to pte on error
  dax: enable dax in the presence of known media errors (badblocks)

Matthew Wilcox (1):
  dax: use sb_issue_zerout instead of calling dax_clear_sectors

Vishal Verma (2):
  dax: for truncate/hole-punch, do zeroing through the driver if
    possible
  dax: fix a comment in dax_zero_page_range and dax_truncate_page

 Documentation/filesystems/dax.txt |  32 ++++++++++++
 arch/powerpc/sysdev/axonram.c     |   2 +-
 block/ioctl.c                     |   9 ----
 drivers/block/brd.c               |   2 +-
 drivers/nvdimm/pmem.c             |  10 +++-
 drivers/s390/block/dcssblk.c      |   2 +-
 fs/block_dev.c                    |   2 +-
 fs/dax.c                          | 104 ++++++++++++++++----------------------
 fs/ext2/inode.c                   |   7 ++-
 fs/xfs/xfs_bmap_util.c            |  15 ++----
 include/linux/blkdev.h            |   2 +-
 include/linux/dax.h               |   8 ++-
 12 files changed, 103 insertions(+), 92 deletions(-)

-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
