Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id A793F6B0039
	for <linux-mm@kvack.org>; Thu, 21 Aug 2014 20:41:42 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so14574194pdj.40
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 17:41:42 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id qo10si28943613pab.167.2014.08.21.17.41.39
        for <linux-mm@kvack.org>;
        Thu, 21 Aug 2014 17:41:41 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v4 0/4] zram memory control enhance
Date: Fri, 22 Aug 2014 09:42:10 +0900
Message-Id: <1408668134-21696-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>, Dan Streetman <ddstreet@ieee.org>, ds2horner@gmail.com, Minchan Kim <minchan@kernel.org>

Currently, zram has no feature to limit memory so theoretically
zram can deplete system memory.
Users have asked for a limit several times as even without exhaustion
zram makes it hard to control memory usage of the platform.
This patchset adds the feature.

Patch 1 makes zs_get_total_size_bytes faster because it would be
used frequently in later patches for the new feature.

Patch 2 changes zs_get_total_size_bytes's return unit from bytes
to page so that zsmalloc doesn't need unnecessary operation(ie,
<< PAGE_SHIFT).

Patch 3 adds new feature. I added the feature into zram layer,
not zsmalloc because limiation is zram's requirement, not zsmalloc
so any other user using zsmalloc(ie, zpool) shouldn't affected
by unnecessary branch of zsmalloc. In future, if every users
of zsmalloc want the feature, then, we could move the feature
from client side to zsmalloc easily but vice versa would be
painful.

Patch 4 adds news facility to report maximum memory usage of zram
so that this avoids user polling frequently via /sys/block/zram0/
mem_used_total and ensures transient max are not missed.

* From v3
 * get_zs_total_size_byte function name change - Dan
 * clarifiction of the document - Dan
 * atomic account instead of introducing new lock in zsmalloc - David
 * remove unnecessary atomic instruction in updating max - David
 
* From v2
 * introduce helper funcntion to update max_used_pages
   for readability - David
 * avoid unncessary zs_get_total_size call in updating loop
   for max_used_pages - David

* From v1
 * rebased on next-20140815
 * fix up race problem - David, Dan
 * reset mem_used_max as current total_bytes, rather than 0 - David
 * resetting works with only "0" write for extensiblilty - David, Dan

Minchan Kim (4):
  zsmalloc: move pages_allocated to zs_pool
  zsmalloc: change return value unit of  zs_get_total_size_bytes
  zram: zram memory size limitation
  zram: report maximum used memory

 Documentation/ABI/testing/sysfs-block-zram |  20 ++++++
 Documentation/blockdev/zram.txt            |  25 +++++--
 drivers/block/zram/zram_drv.c              | 101 ++++++++++++++++++++++++++++-
 drivers/block/zram/zram_drv.h              |   6 ++
 include/linux/zsmalloc.h                   |   2 +-
 mm/zsmalloc.c                              |  30 ++++-----
 6 files changed, 158 insertions(+), 26 deletions(-)

-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
