Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id DC1896B0070
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 01:14:38 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so50813738pab.4
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 22:14:38 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id rm3si7059014pbc.142.2015.01.20.22.14.34
        for <linux-mm@kvack.org>;
        Tue, 20 Jan 2015 22:14:36 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v1 00/10] zsmalloc compaction support
Date: Wed, 21 Jan 2015 15:14:16 +0900
Message-Id: <1421820866-26521-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, Nitin Gupta <ngupta@vflare.org>, Juneho Choi <juno.choi@lge.com>, Gunho Lee <gunho.lee@lge.com>, Luigi Semenzato <semenzato@google.com>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>

Recently, there was issue about zsmalloc fragmentation and
I got a report from Juneho that new fork failed although there
are plenty of free pages in the system.
His investigation revealed zram is one of the culprit to make
heavy fragmentation so there was no more contiguous 16K page
for pgd to fork in the ARM.

This patchset implement *basic* zsmalloc compaction support
and zram utilizes it so admin can do

        "echo 1 > /sys/block/zram0/compact"

In my experiment(high compress ratio data with heavy swap in/out
on zram 8G swap), data is as follows,

Before =
zram allocated object :      60212066 bytes
zram total used:     140103680 bytes
ratio:         42.98 percent
MemFree:          840192 kB

Compaction

After =
frag ratio after compaction
zram allocated object :      60212066 bytes
zram total used:      76185600 bytes
ratio:         79.03 percent
MemFree:          901932 kB

This patchset adds more logics in zsmalloc but when I tested
heavy swapin/out program, the regression is marginal because
most of overheads were caused by compress/decompress and
other MM reclaim stuff.

Minchan Kim (10):
  zram: avoid calling of zram_meta_free under init_lock
  zsmalloc: decouple handle and object
  zsmalloc: implement reverse mapping
  zsmalloc: factor out obj_[malloc|free]
  zsmalloc: add status bit
  zsmalloc: support compaction
  zsmalloc: adjust ZS_ALMOST_FULL
  zram: support compaction
  zsmalloc: add fullness into stat
  zsmalloc: record handle in page->private for huge object

 Documentation/ABI/testing/sysfs-block-zram |    8 +
 drivers/block/zram/zram_drv.c              |   30 +-
 drivers/block/zram/zram_drv.h              |    1 +
 include/linux/zsmalloc.h                   |    1 +
 mm/zsmalloc.c                              | 1008 +++++++++++++++++++++-------
 5 files changed, 786 insertions(+), 262 deletions(-)

-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
