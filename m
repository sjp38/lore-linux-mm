Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id AF5126B0074
	for <linux-mm@kvack.org>; Thu, 18 Jun 2015 07:47:33 -0400 (EDT)
Received: by pdbci14 with SMTP id ci14so6581704pdb.2
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 04:47:33 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id xe2si11003786pbb.87.2015.06.18.04.47.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jun 2015 04:47:32 -0700 (PDT)
Received: by pacyx8 with SMTP id yx8so59885893pac.2
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 04:47:32 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCH v3 0/7] introduce automatic pool compaction
Date: Thu, 18 Jun 2015 20:46:37 +0900
Message-Id: <1434628004-11144-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hello,

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

v3:
-- drop almost_empty waterline adjustment patch (Minchan)
-- do not hold class->lock for the entire compaction period (Minchan)

v2:
-- use a slab shrinker instead of triggering compaction from zs_free (Minchan)

Sergey Senozhatsky (7):
  zsmalloc: drop unused variable `nr_to_migrate'
  zsmalloc: partial page ordering within a fullness_list
  zsmalloc: always keep per-class stats
  zsmalloc: introduce zs_can_compact() function
  zsmalloc: cosmetic compaction code adjustments
  zsmalloc/zram: move `num_migrated' to zs_pool
  zsmalloc: register a shrinker to trigger auto-compaction

 drivers/block/zram/zram_drv.c |  12 +--
 drivers/block/zram/zram_drv.h |   1 -
 include/linux/zsmalloc.h      |   1 +
 mm/zsmalloc.c                 | 220 +++++++++++++++++++++++++++---------------
 4 files changed, 150 insertions(+), 84 deletions(-)

-- 
2.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
