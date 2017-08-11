Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 459A46B039F
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 01:18:26 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id c196so38163865itc.2
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 22:18:26 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 68si401046itu.2.2017.08.10.22.18.24
        for <linux-mm@kvack.org>;
        Thu, 10 Aug 2017 22:18:25 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 0/7] Replace rw_page with on-stack bio
Date: Fri, 11 Aug 2017 14:17:20 +0900
Message-Id: <1502428647-28928-1-git-send-email-minchan@kernel.org>
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

* from v1
  * Fix trivial mistake
  * simplify on-stack bio code - Matthew

Minchan Kim (7):
  zram: set BDI_CAP_STABLE_WRITES once
  bdi: introduce BDI_CAP_SYNCHRONOUS_IO
  fs: use on-stack-bio if backing device has BDI_CAP_SYNCHRONOUS
    capability
  mm:swap: remove end_swap_bio_write argument
  mm:swap: use on-stack-bio for BDI_CAP_SYNCHRONOUS device
  zram: remove zram_rw_page
  fs: remove rw_page

 drivers/block/brd.c           |  2 +
 drivers/block/zram/zram_drv.c | 68 +++-----------------------------
 drivers/nvdimm/btt.c          |  3 ++
 drivers/nvdimm/pmem.c         |  2 +
 fs/block_dev.c                | 76 ------------------------------------
 fs/mpage.c                    | 56 ++++++++++++++++++---------
 include/linux/backing-dev.h   |  8 ++++
 include/linux/blkdev.h        |  4 --
 include/linux/swap.h          |  6 +--
 mm/page_io.c                  | 90 ++++++++++++++++++++++++-------------------
 mm/swapfile.c                 |  3 ++
 mm/zswap.c                    |  2 +-
 12 files changed, 116 insertions(+), 204 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
