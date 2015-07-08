Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 910816B0038
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 07:32:47 -0400 (EDT)
Received: by pabvl15 with SMTP id vl15so130327373pab.1
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 04:32:47 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id dd8si3670103pdb.122.2015.07.08.04.32.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jul 2015 04:32:46 -0700 (PDT)
Received: by pactm7 with SMTP id tm7so130431058pac.2
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 04:32:46 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH v7 0/7] mm/zsmalloc: introduce automatic pool compaction
Date: Wed,  8 Jul 2015 20:31:46 +0900
Message-Id: <1436355113-12417-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hello,

Hopefully the final version.

This patch set tweaks compaction and makes it possible to trigger
pool compaction automatically when system is getting low on memory.

zsmalloc in some cases can suffer from a notable fragmentation and
compaction can release some considerable amount of memory. The problem
here is that currently we fully rely on user space to perform compaction
when needed. However, performing zsmalloc compaction is not always an
obvious thing to do. For example, suppose we have a `idle' fragmented
(compaction was never performed) zram device and system is getting low
on memory due to some 3rd party user processes (gcc LTO, or firefox, etc.).
It's quite unlikely that user space will issue zpool compaction in this
case. Besides, user space cannot tell for sure how badly pool is
fragmented; however, this info is known to zsmalloc and, hence, to a
shrinker.

v7:
-- minor coding styles cleanups and tweaks

v6:
-- use new zs_pool stats API (Minchan)

v5:
-- account freed pages correctly

v4: address review notes (Minchan)
-- do not abort __zs_compact() quickly (Minchan)
-- switch zsmalloc compaction to operate in terms of freed pages
-- micro-optimize zs_can_compact() (Minchan)

v3:
-- drop almost_empty waterline adjustment patch (Minchan)
-- do not hold class->lock for the entire compaction period (Minchan)

v2:
-- use a slab shrinker instead of triggering compaction from zs_free (Minchan)

Sergey Senozhatsky (7):
  zsmalloc: drop unused variable `nr_to_migrate'
  zsmalloc: always keep per-class stats
  zsmalloc: introduce zs_can_compact() function
  zsmalloc: cosmetic compaction code adjustments
  zsmalloc/zram: introduce zs_pool_stats api
  zsmalloc: account the number of compacted pages
  zsmalloc: use shrinker to trigger auto-compaction

 Documentation/blockdev/zram.txt |   3 +-
 drivers/block/zram/zram_drv.c   |  15 +--
 drivers/block/zram/zram_drv.h   |   1 -
 include/linux/zsmalloc.h        |   6 ++
 mm/zsmalloc.c                   | 204 ++++++++++++++++++++++++++++------------
 5 files changed, 161 insertions(+), 68 deletions(-)

-- 
2.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
