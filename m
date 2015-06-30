Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 587E36B006C
	for <linux-mm@kvack.org>; Tue, 30 Jun 2015 08:36:49 -0400 (EDT)
Received: by pdjd13 with SMTP id d13so5738730pdj.0
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 05:36:49 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id gm4si69864048pbb.71.2015.06.30.05.36.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jun 2015 05:36:48 -0700 (PDT)
Received: by pactm7 with SMTP id tm7so5052539pac.2
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 05:36:48 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCHv4 0/7] mm/zsmalloc: introduce automatic pool compaction
Date: Tue, 30 Jun 2015 21:35:51 +0900
Message-Id: <1435667758-14075-1-git-send-email-sergey.senozhatsky@gmail.com>
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
  zsmalloc/zram: store compaction stats in zspool
  zsmalloc: account the number of compacted pages
  zsmalloc: register a shrinker to trigger auto-compaction

 Documentation/blockdev/zram.txt |   3 +-
 drivers/block/zram/zram_drv.c   |  12 +--
 drivers/block/zram/zram_drv.h   |   1 -
 include/linux/zsmalloc.h        |   1 +
 mm/zsmalloc.c                   | 215 +++++++++++++++++++++++++++-------------
 5 files changed, 154 insertions(+), 78 deletions(-)

-- 
2.5.0.rc0.3.g912bd49

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
