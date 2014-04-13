Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 4C5E36B00B4
	for <linux-mm@kvack.org>; Sun, 13 Apr 2014 19:00:02 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id r10so7336705pdi.7
        for <linux-mm@kvack.org>; Sun, 13 Apr 2014 16:00:01 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id l4si7739007pbn.508.2014.04.13.16.00.01
        for <linux-mm@kvack.org>;
        Sun, 13 Apr 2014 16:00:01 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v3 0/7] Page I/O
Date: Sun, 13 Apr 2014 18:59:49 -0400
Message-Id: <cover.1397429628.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, willy@linux.intel.com

Hi Andrew,

Now that 3.15-rc1 is out, could you queue these patches for 3.16 please?
Patches 1-3 & 7 are, IMO, worthwhile cleanups / bug fixes, regardless
of the rest of the patch set.

If this patch series gets in, I'll take care of including the NVMe
driver piece.  It'll be a bit more tricky than the proof of concept that
I've been flashing around because we have to make sure that the device
responds better to page sized I/Os than accumulating larger I/Os.

It's indisputably a win for brd and for other NVM technology devices
that are accessed synchronously rather than through DMA.

Matthew Wilcox (7):
  Remove block_write_full_page_endio()
  Factor clean_buffers() out of __mpage_writepage()
  Factor page_endio() out of mpage_end_io()
  Add bdev_read_page() and bdev_write_page()
  swap: Use bdev_read_page() / bdev_write_page()
  brd: Add support for rw_page
  brd: Return -ENOSPC rather than -ENOMEM on page allocation failure

 drivers/block/brd.c         | 16 +++++++--
 fs/block_dev.c              | 63 ++++++++++++++++++++++++++++++++++
 fs/buffer.c                 | 21 +++---------
 fs/ext4/page-io.c           |  2 +-
 fs/mpage.c                  | 84 +++++++++++++++++++++++----------------------
 fs/ocfs2/file.c             |  2 +-
 include/linux/blkdev.h      |  4 +++
 include/linux/buffer_head.h |  2 --
 include/linux/pagemap.h     |  2 ++
 mm/filemap.c                | 25 ++++++++++++++
 mm/page_io.c                | 23 +++++++++++--
 11 files changed, 178 insertions(+), 66 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
