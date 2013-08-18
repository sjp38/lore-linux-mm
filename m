Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 0307C6B0032
	for <linux-mm@kvack.org>; Sun, 18 Aug 2013 04:41:15 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id fa1so3521081pad.19
        for <linux-mm@kvack.org>; Sun, 18 Aug 2013 01:41:15 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH 0/4] mm: merge zram into zswap
Date: Sun, 18 Aug 2013 16:40:45 +0800
Message-Id: <1376815249-6611-1-git-send-email-bob.liu@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, eternaleye@gmail.com, minchan@kernel.org, mgorman@suse.de, gregkh@linuxfoundation.org, akpm@linux-foundation.org, axboe@kernel.dk, sjenning@linux.vnet.ibm.com, ngupta@vflare.org, semenzato@google.com, penberg@iki.fi, sonnyrao@google.com, smbarber@google.com, konrad.wilk@oracle.com, riel@redhat.com, kmpark@infradead.org, Bob Liu <bob.liu@oracle.com>

Both zswap and zram are used to compress anon pages in memory so as to reduce
swap io operation. The main different is that zswap uses zbud as its allocator
while zram uses zsmalloc. The other different is zram will create a block
device, the user need to mkswp and swapon it.

Minchan has areadly try to promote zram/zsmalloc into drivers/block/, but it may
cause increase maintenance headaches. Since the purpose of zswap and zram are
the same, this patch series try to merge them together as Mel suggested.
Dropped zram from staging and extended zswap with the same feature as zram.

zswap todo:
Improve the writeback of zswap pool pages!

Bob Liu (4):
  drivers: staging: drop zram and zsmalloc
  mm: promote zsmalloc to mm/
  mm: zswap: add supporting for zsmalloc
  mm: zswap: create a pseudo device /dev/zram0

 drivers/staging/Kconfig                  |    4 -
 drivers/staging/Makefile                 |    2 -
 drivers/staging/zram/Kconfig             |   25 -
 drivers/staging/zram/Makefile            |    3 -
 drivers/staging/zram/zram.txt            |   77 ---
 drivers/staging/zram/zram_drv.c          |  925 --------------------------
 drivers/staging/zram/zram_drv.h          |  115 ----
 drivers/staging/zsmalloc/Kconfig         |   10 -
 drivers/staging/zsmalloc/Makefile        |    3 -
 drivers/staging/zsmalloc/zsmalloc-main.c | 1063 -----------------------------
 drivers/staging/zsmalloc/zsmalloc.h      |   43 --
 include/linux/zsmalloc.h                 |   44 ++
 mm/Kconfig                               |   51 +-
 mm/Makefile                              |    1 +
 mm/zsmalloc.c                            | 1068 ++++++++++++++++++++++++++++++
 mm/zswap.c                               |  269 +++++++-
 16 files changed, 1418 insertions(+), 2285 deletions(-)
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
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
