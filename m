Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 620ED6B0035
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 21:04:38 -0500 (EST)
Received: by mail-pb0-f45.google.com with SMTP id rp16so8903275pbb.18
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 18:04:38 -0800 (PST)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id ot3si11999950pac.195.2013.12.10.18.04.35
        for <linux-mm@kvack.org>;
        Tue, 10 Dec 2013 18:04:37 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v9 0/4] zram/zsmalloc promotion
Date: Wed, 11 Dec 2013 11:04:35 +0900
Message-Id: <1386727479-18502-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Luigi Semenzato <semenzato@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Bob Liu <bob.liu@oracle.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>

Zram is a simple pseudo block device which can keep data on
in-memory with compressed[1].

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

 * From v8
  * Move zram.txt into Documentation/blockdev/ - Jerome
  * Rebased on next-20131210
  
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

 Documentation/blockdev/zram.txt          |   77 +++
 drivers/block/Kconfig                    |    2 +
 drivers/block/Makefile                   |    1 +
 drivers/block/zram/Kconfig               |   25 +
 drivers/block/zram/Makefile              |    3 +
 drivers/block/zram/zram_drv.c            |  994 +++++++++++++++++++++++++++
 drivers/block/zram/zram_drv.h            |  124 ++++
 drivers/staging/Kconfig                  |    4 -
 drivers/staging/Makefile                 |    2 -
 drivers/staging/zram/Kconfig             |   25 -
 drivers/staging/zram/Makefile            |    3 -
 drivers/staging/zram/zram.txt            |   77 ---
 drivers/staging/zram/zram_drv.c          |  994 ---------------------------
 drivers/staging/zram/zram_drv.h          |  125 ----
 drivers/staging/zsmalloc/Kconfig         |   11 -
 drivers/staging/zsmalloc/Makefile        |    3 -
 drivers/staging/zsmalloc/zsmalloc-main.c | 1072 -----------------------------
 drivers/staging/zsmalloc/zsmalloc.h      |   43 --
 include/linux/zsmalloc.h                 |   50 ++
 mm/Kconfig                               |   25 +
 mm/Makefile                              |    1 +
 mm/zsmalloc.c                            | 1106 ++++++++++++++++++++++++++++++
 22 files changed, 2408 insertions(+), 2359 deletions(-)
 create mode 100644 Documentation/blockdev/zram.txt
 create mode 100644 drivers/block/zram/Kconfig
 create mode 100644 drivers/block/zram/Makefile
 create mode 100644 drivers/block/zram/zram_drv.c
 create mode 100644 drivers/block/zram/zram_drv.h
 delete mode 100644 drivers/staging/zram/Kconfig
 delete mode 100644 drivers/staging/zram/Makefile
 delete mode 100644 drivers/staging/zram/zram.txt
 delete mode 100644 drivers/staging/zram/zram_drv.c
 delete mode 100644 drivers/staging/zram/zram_drv.h
 delete mode 100644 drivers/staging/zsmalloc/Kconfig
 delete mode 100644 drivers/staging/zsmalloc/Makefile
 delete mode 100644 drivers/staging/zsmalloc/zsmalloc-main.c
 delete mode 100644 drivers/staging/zsmalloc/zsmalloc.h
 create mode 100644 include/linux/zsmalloc.h
 create mode 100644 mm/zsmalloc.c

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
