Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id ADA266B0035
	for <linux-mm@kvack.org>; Sun, 23 Mar 2014 15:08:41 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id um1so4514324pbc.2
        for <linux-mm@kvack.org>; Sun, 23 Mar 2014 12:08:41 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id tk9si7728991pac.88.2014.03.23.12.08.40
        for <linux-mm@kvack.org>;
        Sun, 23 Mar 2014 12:08:40 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v2 0/6] Page I/O
Date: Sun, 23 Mar 2014 15:08:22 -0400
Message-Id: <cover.1395593198.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, willy@linux.intel.com

Page I/O allows us to read/write pages to storage without allocating any
memory (in particular, it avoids allocating a BIO).  This is nice for
the purposes of swap and reduces overhead for fast storage devices.  The
downside is that it removes all batching from the I/O path, potentially
sending dozens of commands for a large I/O instead of just one.

This iteration of the Page I/O patchset has been tested with xfstests
on ext4 on brd, and there are no unexpected failures.

Changes since v1:

 - Rebased to 3.14-rc7
 - Separate out the clean_buffers() refactoring into its own patch
 - Change the page_endio() interface to take an error code rather than
   a boolean 'success'.  All of its callers prefer this (and my earlier
   patchset got this wrong in one caller).
 - Added kerneldoc to bdev_read_page() and bdev_write_page()
 - bdev_write_page() now does less on failure.  Since its two customers
   (swap and mpage) want to do different things to the page flags on
   failure, let them.
 - Drop the virtio_blk patch, since I don't think it should be included

Keith Busch (1):
  NVMe: Add support for rw_page

Matthew Wilcox (5):
  Factor clean_buffers() out of __mpage_writepage()
  Factor page_endio() out of mpage_end_io()
  Add bdev_read_page() and bdev_write_page()
  swap: Use bdev_read_page() / bdev_write_page()
  brd: Add support for rw_page

 drivers/block/brd.c       |  10 ++++
 drivers/block/nvme-core.c | 129 +++++++++++++++++++++++++++++++++++++---------
 fs/block_dev.c            |  63 ++++++++++++++++++++++
 fs/mpage.c                |  84 +++++++++++++++---------------
 include/linux/blkdev.h    |   4 ++
 include/linux/pagemap.h   |   2 +
 mm/filemap.c              |  25 +++++++++
 mm/page_io.c              |  23 ++++++++-
 8 files changed, 273 insertions(+), 67 deletions(-)

-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
