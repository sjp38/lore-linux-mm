Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id D7542900016
	for <linux-mm@kvack.org>; Fri,  5 Jun 2015 08:04:34 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so52375757pdb.2
        for <linux-mm@kvack.org>; Fri, 05 Jun 2015 05:04:34 -0700 (PDT)
Received: from mail-pd0-x230.google.com (mail-pd0-x230.google.com. [2607:f8b0:400e:c02::230])
        by mx.google.com with ESMTPS id p4si10677963pdl.50.2015.06.05.05.04.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jun 2015 05:04:33 -0700 (PDT)
Received: by pdjn11 with SMTP id n11so14443729pdj.0
        for <linux-mm@kvack.org>; Fri, 05 Jun 2015 05:04:33 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCHv2 0/8] introduce automatic pool compaction
Date: Fri,  5 Jun 2015 21:03:50 +0900
Message-Id: <1433505838-23058-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

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

v2:
-- use a slab shrinker instead of triggering compaction from zs_free (Minchan)

Sergey Senozhatsky (8):
  zsmalloc: drop unused variable `nr_to_migrate'
  zsmalloc: partial page ordering within a fullness_list
  zsmalloc: lower ZS_ALMOST_FULL waterline
  zsmalloc: always keep per-class stats
  zsmalloc: introduce zs_can_compact() function
  zsmalloc: cosmetic compaction code adjustments
  zsmalloc/zram: move `num_migrated' to zs_pool
  zsmalloc: register a shrinker to trigger auto-compaction

 drivers/block/zram/zram_drv.c |  12 +--
 drivers/block/zram/zram_drv.h |   1 -
 include/linux/zsmalloc.h      |   1 +
 mm/zsmalloc.c                 | 228 +++++++++++++++++++++++++++---------------
 4 files changed, 152 insertions(+), 90 deletions(-)

-- 
2.4.2.387.gf86f31a

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
