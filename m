Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id AA77D6B0009
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 22:34:35 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id q63so3312659pfb.0
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 19:34:35 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id uv2si55489081pac.41.2016.02.16.19.34.34
        for <linux-mm@kvack.org>;
        Tue, 16 Feb 2016 19:34:35 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v3 0/6] DAX fixes, move flushing calls to FS
Date: Tue, 16 Feb 2016 20:34:13 -0700
Message-Id: <1455680059-20126-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Jens Axboe <axboe@kernel.dk>, Matthew Wilcox <willy@linux.intel.com>, linux-block@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, xfs@oss.sgi.com

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
which it wasn't always getting.

5) The DAX writeback code needs a valid struct block_device, which it
wasn't always getting.

6) The DAX writeback code needs to be called for sync(2) and syncfs(2).

The last patch in this series reenables the DAX I/O path for raw block
devices when they would otherwise be doing direct I/O.  It can be dropped
if it is too controversial.

Thank you to Dan Williams and Jan Kara for their code contributions to this
set.

A working tree can be found here:
https://git.kernel.org/cgit/linux/kernel/git/zwisler/linux.git/log/?h=fsync_bdev_v3

Dan Williams (2):
  block: disable block device DAX by default
  block: use dax_do_io() if blkdev_dax_capable()

Ross Zwisler (4):
  ext2, ext4: only set S_DAX for regular inodes
  ext4: Online defrag not supported with DAX
  dax: give DAX clearing code correct bdev
  dax: move writeback calls into the filesystems

 block/Kconfig          | 13 +++++++++++++
 block/ioctl.c          |  1 +
 fs/block_dev.c         | 22 +++++++++++++++++++---
 fs/dax.c               | 21 +++++++++++----------
 fs/ext2/inode.c        | 16 +++++++++++++---
 fs/ext4/inode.c        |  6 +++++-
 fs/ext4/ioctl.c        |  5 +++++
 fs/xfs/xfs_aops.c      |  6 +++++-
 fs/xfs/xfs_aops.h      |  1 +
 fs/xfs/xfs_bmap_util.c |  3 ++-
 include/linux/dax.h    |  8 +++++---
 include/linux/fs.h     | 31 +++++++++++++++++++++----------
 mm/filemap.c           | 12 ++++--------
 13 files changed, 105 insertions(+), 40 deletions(-)

-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
