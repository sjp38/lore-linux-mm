Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id AAECB6B0266
	for <linux-mm@kvack.org>; Fri,  6 May 2016 17:53:39 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id xm6so174511393pab.3
        for <linux-mm@kvack.org>; Fri, 06 May 2016 14:53:39 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id l9si20592411pav.105.2016.05.06.14.53.38
        for <linux-mm@kvack.org>;
        Fri, 06 May 2016 14:53:38 -0700 (PDT)
From: Vishal Verma <vishal.l.verma@intel.com>
Subject: [PATCH v5 0/5] dax: handling media errors (clear-on-zero only)
Date: Fri,  6 May 2016 15:53:06 -0600
Message-Id: <1462571591-3361-1-git-send-email-vishal.l.verma@intel.com>
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

Patch 4 reduces our calls to clear_pmem from dax in the
truncate/hole-punch cases. We check if the range being truncated
is sector aligned/sized, and if so, send blkdev_issue_zeroout
instead of clear_pmem so that errors can be handled better by
the driver.

Patch 5 fixes a redundant comment in DAX and is mostly unrelated
to the rest of this series.

This series also depends on/is based on Jan Kara's DAX Locking
fixes series [1].


[1]: http://www.spinics.net/lists/linux-mm/msg105819.html

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


Dan Williams (2):
  dax: fallback from pmd to pte on error
  dax: enable dax in the presence of known media errors (badblocks)

Matthew Wilcox (1):
  dax: use sb_issue_zerout instead of calling dax_clear_sectors

Vishal Verma (2):
  dax: for truncate/hole-punch, do zeroing through the driver if
    possible
  dax: fix a comment in dax_zero_page_range and dax_truncate_page

 Documentation/filesystems/dax.txt | 32 ++++++++++++++++
 arch/powerpc/sysdev/axonram.c     |  2 +-
 block/ioctl.c                     |  9 -----
 drivers/block/brd.c               |  2 +-
 drivers/nvdimm/pmem.c             | 10 ++++-
 drivers/s390/block/dcssblk.c      |  2 +-
 fs/block_dev.c                    |  2 +-
 fs/dax.c                          | 78 ++++++++++++++-------------------------
 fs/ext2/inode.c                   |  7 ++--
 fs/xfs/xfs_bmap_util.c            | 15 ++------
 include/linux/blkdev.h            |  2 +-
 include/linux/dax.h               |  1 -
 12 files changed, 80 insertions(+), 82 deletions(-)

-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
