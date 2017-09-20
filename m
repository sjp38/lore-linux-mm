Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 47A276B0253
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 01:43:34 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id j16so3529813pga.6
        for <linux-mm@kvack.org>; Tue, 19 Sep 2017 22:43:34 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id i189si2505344pge.813.2017.09.19.22.43.32
        for <linux-mm@kvack.org>;
        Tue, 19 Sep 2017 22:43:32 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 0/4] skip swapcache for super fast device
Date: Wed, 20 Sep 2017 14:43:21 +0900
Message-Id: <1505886205-9671-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team <kernel-team@lge.com>, Christoph Hellwig <hch@lst.de>, Minchan Kim <minchan@kernel.org>

With fast swap storage, platform want to use swap more aggressively
and swap-in is crucial to application latency.

The rw_page based synchronous devices like zram, pmem and btt are such
fast storage. When I profile swapin performance with zram lz4 decompress
test, S/W overhead is more than 70%. Maybe, it would be bigger in nvdimm.

This patch aims for reducing swap-in latency via skipping swapcache
if swap device is synchronous device like rw_page based device.

It enhances 45% my swapin test(5G sequential swapin, no readahead,
from 2.41sec to 1.64sec).

Andrew, [1] is zram specific patch so could be applied separately
but this patch is based on that so I include it in this series.

* From v1
  * style fix
  * a bug fix
  * drop page-cluster based readahead off
    * This regression could be solved by other patch from Huang.
      http://lkml.kernel.org/r/87tw04in60.fsf@yhuang-dev.intel.com
  
Minchan Kim (4):
  [1] zram: set BDI_CAP_STABLE_WRITES once
  [2] bdi: introduce BDI_CAP_SYNCHRONOUS_IO
  [3] mm:swap: introduce SWP_SYNCHRONOUS_IO
  [4] mm:swap: skip swapcache for swapin of synchronous device

 drivers/block/brd.c           |  2 ++
 drivers/block/zram/zram_drv.c | 16 +++++--------
 drivers/nvdimm/btt.c          |  3 +++
 drivers/nvdimm/pmem.c         |  2 ++
 include/linux/backing-dev.h   |  8 +++++++
 include/linux/swap.h          | 14 +++++++++++-
 mm/memory.c                   | 52 ++++++++++++++++++++++++++++++-------------
 mm/page_io.c                  |  6 ++---
 mm/swapfile.c                 | 14 ++++++++----
 9 files changed, 83 insertions(+), 34 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
