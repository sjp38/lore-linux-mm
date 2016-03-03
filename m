Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id D69956B007E
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 09:48:16 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id 4so16141439pfd.1
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 06:48:16 -0800 (PST)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id b8si43005203pas.137.2016.03.03.06.48.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Mar 2016 06:48:16 -0800 (PST)
Received: by mail-pa0-x22a.google.com with SMTP id fy10so15919785pac.1
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 06:48:15 -0800 (PST)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCH v3 0/5] mm/zsmalloc: rework compaction and increase density
Date: Thu,  3 Mar 2016 23:45:58 +0900
Message-Id: <1457016363-11339-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hello,

	RFC

Posting as an early preview of zsmalloc compaction and density
improvements.

The patch set will be rebased once Minchan posts his zsmalloc
rework.


zsmalloc knows the watermark after which classes are considered to be
huge - every object stored consumes the entire zspage (which consist
of a single order-0 page). zram, however, has its own statically defined
watermark for `bad' compression and stores every object larger than this
watermark as a PAGE_SIZE, object, IOW, to a ->huge class, this results in
increased memory consumption and memory wastage. And zram's 'bad' watermark
is much lower than zsmalloc's one. Apart from that, 'bad' compressions
are not so rare and expecting that pages passed to zram mostly will be
compressed to 3/4 of page_size is a bit strange. There is no a
compression algorithm with such ratio guarantees. This patch set inverts
this 'huge class watermark' enforcement, it's zsmalloc that knows better,
not zram.

The patch set reduces the number of huge classes, which permits to save
some memory.

zsmalloc classes are known to have fragmentation problems, that's why
compaction has been aidded in the first place. The patch set change
the existing shrinker callback based compaction and introduces a watermark
based one. So now zsmalloc controls class's fragmentation level and
schedules a compaction work on a per-class basis once class fragmentation
jumps above the watermark. Instead of compacting the entire pool
class-by-class we know touch only classes that are known to be heavily
fragmented.


All important patches contain test results and test descriptions.
And it seems that previously weak tests (truncate) are no longer
problematic.


v3:
-- user watermark based per-class compaction (workqueue)
-- remove shrinker compaction callbacks
-- increase order only for huge classes via special #defines
-- renamed zs_get_huge_class_size_watermark() function
-- patches re-ordered

v2:
-- keep ZS_MAX_PAGES_PER_ZSPAGE order of two (Joonsoo)
-- suffice ZS_MIN_ALLOC_SIZE alignment requirement
-- do not change ZS_MAX_PAGES_PER_ZSPAGE on PAE/LPAE and
   on PAGE_SHIFT 16 systems (Joonsoo)

Sergey Senozhatsky (5):
  mm/zsmalloc: introduce class auto-compaction
  mm/zsmalloc: remove shrinker compaction callbacks
  mm/zsmalloc: introduce zs_huge_object()
  zram: use zs_huge_object()
  mm/zsmalloc: reduce the number of huge classes

 drivers/block/zram/zram_drv.c |   2 +-
 drivers/block/zram/zram_drv.h |   6 --
 include/linux/zsmalloc.h      |   2 +
 mm/zsmalloc.c                 | 157 ++++++++++++++++++++----------------------
 4 files changed, 78 insertions(+), 89 deletions(-)

-- 
2.8.0.rc0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
