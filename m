Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 27A8D6B0005
	for <linux-mm@kvack.org>; Sat, 23 Apr 2016 15:13:58 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id zy2so205373804pac.1
        for <linux-mm@kvack.org>; Sat, 23 Apr 2016 12:13:58 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id k74si14814729pfb.30.2016.04.23.12.13.57
        for <linux-mm@kvack.org>;
        Sat, 23 Apr 2016 12:13:57 -0700 (PDT)
From: Vishal Verma <vishal.l.verma@intel.com>
Subject: [PATCH v3 0/7] dax: handling media errors
Date: Sat, 23 Apr 2016 13:13:35 -0600
Message-Id: <1461438822-3592-1-git-send-email-vishal.l.verma@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Vishal Verma <vishal.l.verma@intel.com>, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <matthew.r.wilcox@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@fb.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Jeff Moyer <jmoyer@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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
  dax: handle media errors in dax_do_io
  dax: for truncate/hole-punch, do zeroing through the driver if
    possible
  dax: fix a comment in dax_zero_page_range and dax_truncate_page

 arch/powerpc/sysdev/axonram.c | 10 +++---
 block/ioctl.c                 |  9 -----
 drivers/block/brd.c           |  9 ++---
 drivers/nvdimm/pmem.c         | 17 +++++++---
 drivers/s390/block/dcssblk.c  | 12 +++----
 fs/block_dev.c                |  7 ++--
 fs/dax.c                      | 78 +++++++++++++++----------------------------
 fs/ext2/inode.c               | 12 +++----
 fs/ext4/inode.c               |  5 +--
 fs/xfs/xfs_aops.c             |  8 ++---
 fs/xfs/xfs_bmap_util.c        | 15 +++------
 include/linux/blkdev.h        |  3 +-
 include/linux/dax.h           | 31 ++++++++++++++++-
 13 files changed, 108 insertions(+), 108 deletions(-)

-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
