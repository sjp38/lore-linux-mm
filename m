Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id C75D56B0075
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 00:05:36 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id rr13so4925688pbb.9
        for <linux-mm@kvack.org>; Sun, 24 Nov 2013 21:05:36 -0800 (PST)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id sg3si26618563pbb.223.2013.11.24.21.05.34
        for <linux-mm@kvack.org>;
        Sun, 24 Nov 2013 21:05:35 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v8 0/4] zram/zsmalloc promotion
Date: Mon, 25 Nov 2013 14:06:14 +0900
Message-Id: <1385355978-6386-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Bob Liu <bob.liu@oracle.com>, Luigi Semenzato <semenzato@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>

Zram is a simple pseudo block device which can keep data on
in-memory with compressed.[1]

It have been used for many embedded system for several years
One of significant usecase is in-memory swap device.
Because NAND which is very popular on most embedded device
is weak for frequent write without good wear-level
and slow I/O hurts system's responsiblity so zram is really
good choice to use memory efficiently.

In previous trial, there was some argument[2] that zram has
similar goal with zswap so let's merge zram's functionality
into zswap via adding pseudo block device in zswap but I and
some people(At least, Hugh and Rik) believe it's not a good idea.
[2][3][4] and zswap might go writethrough model[5]. It makes
clear difference zram and zswap.

Zram itself is simple/well-designed/good abstraciton so it has
clear market(ex, Android, TV, ChromeOS, some Linux distro) which
is never niche. :)

Another zram-blk's usecase is following as.
The admin can use it as tmpfs so it could help small memory system.
The tmpfs is never good solution for swapless embedded system.

Patch 1 adds new Kconfig for zram to use page table method instead
of copy.

Patch 2 adds more comment for zsmalloc.

Patch 3 moves zsmalloc under mm.

Patch 4 moves zram from driver/staging to driver/blocks, finally.

[1] http://en.wikipedia.org/wiki/Zram
[2] https://lkml.org/lkml/2013/8/21/54
[3] https://lkml.org/lkml/2013/11/13/570
[4] https://lkml.org/lkml/2013/11/7/318
[5] http://www.spinics.net/lists/linux-mm/msg65499.html

 * From v7
  * Remove unnecessary zswap VS zram comparison in cover letter.
  * Add Reviewed-by/Acked-by I forgot.
  * Remove exporting unmap_kernel_range patch. I will do if promotion is done.
  * Move zsmalloc under mm - Hugh
  
Minchan Kim (3):
  zsmalloc: add Kconfig for enabling page table method
  zsmalloc: move it under mm
  zram: promote zram from staging

Nitin Cupta (1):
  zsmalloc: add more comment

 drivers/block/Kconfig                    |    2 +
 drivers/block/Makefile                   |    2 +
 drivers/block/zram/Kconfig               |   25 +
 drivers/block/zram/Makefile              |    3 +
 drivers/block/zram/zram.txt              |   77 +++
 drivers/block/zram/zram_drv.c            |  981 ++++++++++++++++++++++++++
 drivers/staging/Kconfig                  |    4 -
 drivers/staging/Makefile                 |    2 -
 drivers/staging/zram/Kconfig             |   25 -
 drivers/staging/zram/Makefile            |    3 -
 drivers/staging/zram/zram.txt            |   77 ---
 drivers/staging/zram/zram_drv.c          |  982 --------------------------
 drivers/staging/zram/zram_drv.h          |  125 ----
 drivers/staging/zsmalloc/Kconfig         |   11 -
 drivers/staging/zsmalloc/Makefile        |    3 -
 drivers/staging/zsmalloc/zsmalloc-main.c | 1063 -----------------------------
 drivers/staging/zsmalloc/zsmalloc.h      |   43 --
 include/linux/zram_drv.h                 |  124 ++++
 include/linux/zsmalloc.h                 |   50 ++
 mm/Kconfig                               |   25 +
 mm/Makefile                              |    1 +
 mm/zsmalloc.c                            | 1097 ++++++++++++++++++++++++++++++
 22 files changed, 2387 insertions(+), 2338 deletions(-)
 create mode 100644 drivers/block/zram/Kconfig
 create mode 100644 drivers/block/zram/Makefile
 create mode 100644 drivers/block/zram/zram.txt
 create mode 100644 drivers/block/zram/zram_drv.c
 delete mode 100644 drivers/staging/zram/Kconfig
 delete mode 100644 drivers/staging/zram/Makefile
 delete mode 100644 drivers/staging/zram/zram.txt
 delete mode 100644 drivers/staging/zram/zram_drv.c
 delete mode 100644 drivers/staging/zram/zram_drv.h
 delete mode 100644 drivers/staging/zsmalloc/Kconfig
 delete mode 100644 drivers/staging/zsmalloc/Makefile
 delete mode 100644 drivers/staging/zsmalloc/zsmalloc-main.c
 delete mode 100644 drivers/staging/zsmalloc/zsmalloc.h
 create mode 100644 include/linux/zram_drv.h
 create mode 100644 include/linux/zsmalloc.h
 create mode 100644 mm/zsmalloc.c

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
