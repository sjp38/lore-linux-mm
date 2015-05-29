Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 27CCB6B0075
	for <linux-mm@kvack.org>; Fri, 29 May 2015 11:06:03 -0400 (EDT)
Received: by padbw4 with SMTP id bw4so62555420pad.0
        for <linux-mm@kvack.org>; Fri, 29 May 2015 08:06:02 -0700 (PDT)
Received: from mail-pd0-x231.google.com (mail-pd0-x231.google.com. [2607:f8b0:400e:c02::231])
        by mx.google.com with ESMTPS id ex2si8787272pbc.106.2015.05.29.08.06.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 08:06:02 -0700 (PDT)
Received: by pdbqa5 with SMTP id qa5so55625134pdb.0
        for <linux-mm@kvack.org>; Fri, 29 May 2015 08:06:01 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCH 00/10] zsmalloc auto-compaction
Date: Sat, 30 May 2015 00:05:18 +0900
Message-Id: <1432911928-14654-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hello,

RFC

this is 4.3 material, but I wanted to publish it sooner to gain
responses and to settle it down before 4.3 merge window opens.

in short, this series tweaks zsmalloc's compaction and adds
auto-compaction support. auto-compaction is not aimed to replace
manual compaction, intead it's supposed to be good enough. yet
it surely slows down zsmalloc in some scenarious. whilst simple
un-tar test didn't show any significant performance difference


quote from commit 0007:

this test copies a 1.3G linux kernel tar to mounted zram disk,
and extracts it.

w/auto-compaction:

cat /sys/block/zram0/mm_stat
 1171456    26006    86016        0    86016    32781        0

time tar xf linux-3.10.tar.gz -C linux

real    0m16.970s
user    0m15.247s
sys     0m8.477s

du -sh linux
2.0G    linux

cat /sys/block/zram0/mm_stat
3547353088 2993384270 3011088384        0 3011088384    24310      108

=====================================================================

w/o auto compaction:

cat /sys/block/zram0/mm_stat
 1171456    26000    81920        0    81920    32781        0

time tar xf linux-3.10.tar.gz -C linux

real    0m16.983s
user    0m15.267s
sys     0m8.417s

du -sh linux
2.0G    linux

cat /sys/block/zram0/mm_stat
3548917760 2993566924 3011317760        0 3011317760    23928        0



Sergey Senozhatsky (10):
  zsmalloc: drop unused variable `nr_to_migrate'
  zsmalloc: always keep per-class stats
  zsmalloc: introduce zs_can_compact() function
  zsmalloc: cosmetic compaction code adjustments
  zsmalloc: add `num_migrated' to zs_pool
  zsmalloc: move compaction functions
  zsmalloc: introduce auto-compact support
  zsmalloc: export zs_pool `num_migrated'
  zram: remove `num_migrated' from zram_stats
  zsmalloc: lower ZS_ALMOST_FULL waterline

 drivers/block/zram/zram_drv.c |  12 +-
 drivers/block/zram/zram_drv.h |   1 -
 include/linux/zsmalloc.h      |   1 +
 mm/zsmalloc.c                 | 578 +++++++++++++++++++++---------------------
 4 files changed, 296 insertions(+), 296 deletions(-)

-- 
2.4.2.337.gfae46aa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
