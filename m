Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0E5246B025F
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 02:50:34 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id i192so26302943pgc.11
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 23:50:34 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id u128si446718pfb.392.2017.08.07.23.50.31
        for <linux-mm@kvack.org>;
        Mon, 07 Aug 2017 23:50:32 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v1 0/6] Remove rw_page
Date: Tue,  8 Aug 2017 15:50:18 +0900
Message-Id: <1502175024-28338-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, "karam . lee" <karam.lee@lge.com>, seungho1.park@lge.com, Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, jack@suse.cz, Jens Axboe <axboe@kernel.dk>, Vishal Verma <vishal.l.verma@intel.com>, linux-nvdimm@lists.01.org, kernel-team <kernel-team@lge.com>, Minchan Kim <minchan@kernel.org>

Recently, there was a dicussion about removing rw_page due to maintainance
burden[1] but the problem was zram because zram has a clear win for the
benchmark at that time. The reason why only zram have a win is due to
bio allocation wait time from mempool under extreme memory pressure.

Christoph Hellwig suggested we can use on-stack-bio for rw_page devices.
This patch implements it and replace rw_page operations with on-stack-bio
and then finally, remove rw_page interface completely.

This patch is based on linux-next-20170804

[1] http://lkml.kernel.org/r/<20170728165604.10455-1-ross.zwisler@linux.intel.com>

Minchan Kim (6):
  bdi: introduce BDI_CAP_SYNC
  fs: use on-stack-bio if backing device has BDI_CAP_SYNC capability
  mm:swap: remove end_swap_bio_write argument
  mm:swap: use on-stack-bio for BDI_CAP_SYNC devices
  zram: remove zram_rw_page
  fs: remove rw_page

 drivers/block/brd.c           |   2 +
 drivers/block/zram/zram_drv.c |  54 +---------------
 drivers/nvdimm/btt.c          |   2 +
 drivers/nvdimm/pmem.c         |   2 +
 fs/block_dev.c                |  76 ----------------------
 fs/mpage.c                    |  45 +++++++++++--
 include/linux/backing-dev.h   |   7 ++
 include/linux/blkdev.h        |   4 --
 include/linux/swap.h          |   6 +-
 mm/page_io.c                  | 145 +++++++++++++++++++++++++-----------------
 mm/swapfile.c                 |   3 +
 mm/zswap.c                    |   2 +-
 12 files changed, 147 insertions(+), 201 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
