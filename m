Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id D07356B0032
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 01:55:30 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v6 0/5] zram/zsmalloc promotion
Date: Wed, 14 Aug 2013 14:55:31 +0900
Message-Id: <1376459736-7384-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Luigi Semenzato <semenzato@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>

It's 6th trial of zram/zsmalloc promotion.
[patch 5, zram: promote zram from staging] explains why we need zram.

Main reason to block promotion is there was no review of zsmalloc part
while Jens already acked zram part.

At that time, zsmalloc was used for zram, zcache and zswap so everybody
wanted to make it general and at last, Mel reviewed it.
Most of review was related to zswap dumping mechanism which can pageout
compressed page into swap in runtime and zswap gives up using zsmalloc
and invented a new wheel, zbud. Other reviews were not major.
http://lkml.indiana.edu/hypermail/linux/kernel/1304.1/04334.html

Zcache don't use zsmalloc either so only zsmalloc user is zram now.
So I think there is no concern any more.

Patch 1 adds new Kconfig for zram to use page table method instead
of copy. Andrew suggested it.

Patch 2 adds lots of commnt for zsmalloc.

Patch 3 moves zsmalloc under driver/staging/zram because zram is only
user for zram now.

Patch 4 makes unmap_kernel_range exportable function because zsmalloc
have used map_vm_area which is already exported function but zsmalloc
need to use unmap_kernel_range and it should be built with module.

Patch 5 moves zram from driver/staging to driver/blocks, finally.

It touches mm, staging, blocks so I am not sure who is right position
maintainer so I will Cc Andrw, Jens and Greg.

This patch is based on next-20130813.

Thanks.

Minchan Kim (4):
  zsmalloc: add Kconfig for enabling page table method
  zsmalloc: move it under zram
  mm: export unmap_kernel_range
  zram: promote zram from staging

Nitin Cupta (1):
  zsmalloc: add more comment

 drivers/block/Kconfig                    |    2 +
 drivers/block/Makefile                   |    1 +
 drivers/block/zram/Kconfig               |   37 +
 drivers/block/zram/Makefile              |    3 +
 drivers/block/zram/zram.txt              |   71 ++
 drivers/block/zram/zram_drv.c            |  987 +++++++++++++++++++++++++++
 drivers/block/zram/zsmalloc.c            | 1084 ++++++++++++++++++++++++++++++
 drivers/staging/Kconfig                  |    4 -
 drivers/staging/Makefile                 |    2 -
 drivers/staging/zram/Kconfig             |   25 -
 drivers/staging/zram/Makefile            |    3 -
 drivers/staging/zram/zram.txt            |   77 ---
 drivers/staging/zram/zram_drv.c          |  984 ---------------------------
 drivers/staging/zram/zram_drv.h          |  125 ----
 drivers/staging/zsmalloc/Kconfig         |   10 -
 drivers/staging/zsmalloc/Makefile        |    3 -
 drivers/staging/zsmalloc/zsmalloc-main.c | 1063 -----------------------------
 drivers/staging/zsmalloc/zsmalloc.h      |   43 --
 include/linux/zram.h                     |  123 ++++
 include/linux/zsmalloc.h                 |   52 ++
 mm/vmalloc.c                             |    1 +
 21 files changed, 2361 insertions(+), 2339 deletions(-)
 create mode 100644 drivers/block/zram/Kconfig
 create mode 100644 drivers/block/zram/Makefile
 create mode 100644 drivers/block/zram/zram.txt
 create mode 100644 drivers/block/zram/zram_drv.c
 create mode 100644 drivers/block/zram/zsmalloc.c
 delete mode 100644 drivers/staging/zram/Kconfig
 delete mode 100644 drivers/staging/zram/Makefile
 delete mode 100644 drivers/staging/zram/zram.txt
 delete mode 100644 drivers/staging/zram/zram_drv.c
 delete mode 100644 drivers/staging/zram/zram_drv.h
 delete mode 100644 drivers/staging/zsmalloc/Kconfig
 delete mode 100644 drivers/staging/zsmalloc/Makefile
 delete mode 100644 drivers/staging/zsmalloc/zsmalloc-main.c
 delete mode 100644 drivers/staging/zsmalloc/zsmalloc.h
 create mode 100644 include/linux/zram.h
 create mode 100644 include/linux/zsmalloc.h

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
