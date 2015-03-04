Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id E6EC26B0073
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 00:00:54 -0500 (EST)
Received: by padfa1 with SMTP id fa1so30191868pad.9
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 21:00:54 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id j4si3380027pbw.212.2015.03.03.21.00.44
        for <linux-mm@kvack.org>;
        Tue, 03 Mar 2015 21:00:45 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 0/7] zsmalloc: compaction support
Date: Wed,  4 Mar 2015 14:01:25 +0900
Message-Id: <1425445292-29061-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Juneho Choi <juno.choi@lge.com>, Gunho Lee <gunho.lee@lge.com>, Luigi Semenzato <semenzato@google.com>, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, opensource.ganesh@gmail.com, Minchan Kim <minchan@kernel.org>

Recently, we started to use zram heavily and some of issues
popped.

1) external fragmentation
I got a report from Juneho Choi that fork failed although there
are plenty of free pages in the system. His investigation revealed
zram is one of the culprit to make heavy fragmentation so there was
no more contiguous 16K page for pgd to fork in the ARM.

2) non-movable pages
Other problem of zram now is that inherently, user want to use
zram as swap in small memory system so they use zRAM with CMA to
use memory efficiently. However, unfortunately, it doesn't work well
because zRAM cannot use CMA's movable pages unless it doesn't support
compaction. I got several reports about that OOM happened with
zram although there are lots of swap space and free space
in CMA area.

3) internal fragmentation
zRAM has started support memory limitation feature to limit
memory usage and I sent a patchset(https://lkml.org/lkml/2014/9/21/148)
for VM to be harmonized with zram-swap to stop anonymous page reclaim
if zram consumed memory up to the limit although there are free space
on the swap. One problem for that direction is zram has no way to know
any hole in memory space zsmalloc allocated by internal fragmentation
so zram would regard swap is full although there are free space in
zsmalloc. For solving the issue, zram want to trigger compaction
of zsmalloc before it decides full or not.

This patchset is first step to support above issues. For that,
it adds indirect layer between handle and object location and
supports manual compaction to solve 3th problem first of all.

After this patchset got merged, next step is to make VM aware
of zsmalloc compaction so that generic compaction will move
zsmalloced-pages automatically in runtime.

In my imaginary experiment(ie, high compress ratio data with
heavy swap in/out on 8G zram-swap), data is as follows,

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

Juneho reported below in his real platform with small aging.
So, I think the benefit would be bigger in real aging system
for a long time.

- frag_ratio increased 3% (ie, higher is better)
- memfree increased about 6MB
- In buddy info, Normal 2^3: 4, 2^2: 1: 2^1 increased, Highmem: 2^1 21 increased

frag ratio after swap fragment
used :        156677 kbytes
total:        166092 kbytes
frag_ratio :  94
meminfo before compaction
MemFree:           83724 kB
Node 0, zone   Normal  13642   1364     57     10     61     17      9      5      4      0      0 
Node 0, zone  HighMem    425     29      1      0      0      0      0      0      0      0      0 

num_migrated :  23630
compaction done

frag ratio after compaction
used :        156673 kbytes
total:        160564 kbytes
frag_ratio :  97
meminfo after compaction
MemFree:           89060 kB
Node 0, zone   Normal  14076   1544     67     14     61     17      9      5      4      0      0 
Node 0, zone  HighMem    863     50      1      0      0      0      0      0      0      0      0 

This patchset adds more logics(about 480 lines) in zsmalloc but
when I tested heavy swapin/out program, the regression for
swapin/out speed is marginal because most of overheads were caused
by compress/decompress and other MM reclaim stuff.

* from v1
  * remove rcu - suggested by Joonsoo
  * iterating biggest size class - Seth
  * add experiment data in description - Juneho

Minchan Kim (7):
  zsmalloc: decouple handle and object
  zsmalloc: factor out obj_[malloc|free]
  zsmalloc: support compaction
  zsmalloc: adjust ZS_ALMOST_FULL
  zram: support compaction
  zsmalloc: record handle in page->private for huge object
  zsmalloc: add fullness into stat

 Documentation/ABI/testing/sysfs-block-zram |  15 +
 drivers/block/zram/zram_drv.c              |  25 +
 drivers/block/zram/zram_drv.h              |   1 +
 include/linux/zsmalloc.h                   |   1 +
 mm/zsmalloc.c                              | 991 +++++++++++++++++++++--------
 5 files changed, 777 insertions(+), 256 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
