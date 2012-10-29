Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id A3F2A6B006C
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 04:51:06 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v3 0/3] zram/zsmalloc promotion
Date: Mon, 29 Oct 2012 17:56:46 +0900
Message-Id: <1351501009-15111-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Jens Axboe <axboe@kernel.dk>, Dan Magenheimer <dan.magenheimer@oracle.com>, Pekka Enberg <penberg@cs.helsinki.fi>, gaowanlong@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

This patchset promotes zram/zsmalloc from staging.
Both are very clean and zram have been used by many embedded product
for a long time.
It's time to go out of staging.

Greg, Jens is already OK that zram is located under driver/blocks/.
The issue remained is where we put zsmalloc.
The candidate is two under mm/ or under lib/
Konrad and Nitin wanted to put zsmalloc into lib/ instead of mm/.

Quote from Nitin
"
I think mm/ directory should only contain the code which is intended
for global use such as the slab allocator, page reclaim code etc.
zsmalloc is used by only one (or possibly two) drivers, so lib/ seems
to be the right place.
"

Quote from Konrand
"
I like the idea of keeping it in /lib or /mm. Actually 'lib' sounds more
appropriate since it is dealing with storing a bunch of pages in a nice
layout for great density purposes.
"

In fact, there is some history about that.

Why I put zsmalloc into under mm firstly was that Andrew had a concern
about using strut page's some fields freely in zsmalloc so he wanted
to maintain it in mm/ if I remember correctly.

So I and Nitin tried to ask the opinion to akpm several times
(at least 6 and even I sent such patch a few month ago) but didn't get
any reply from him so I guess he doesn't have any concern about that
any more.

In point of view that it's an another slab-like allocator,
it might be proper under mm but it's not popular as current mm's
allocators(/SLUB/SLOB and page allocator).

Frankly speaking, I don't care whether we put it to mm/ or lib/.
It seems contributors(ex, Nitin and Konrad) like lib/ and Andrew is still
silent. That's why I am biased into lib/ now.

If someone yell we should keep it to mm/ by logical claim, I can change
my mind easily. Please raise your hand.

If Andrew doesn't have a concern about that any more, I would like to
locate it into /lib.

This patchset is based on next-20121029

Minchan Kim (3):
  zsmalloc: promote to lib/
  zram: promote zram from staging
  zram: select ZSMALLOC when ZRAM is configured

 drivers/block/Kconfig                    |    1 +
 drivers/block/Makefile                   |    1 +
 drivers/block/zram/Kconfig               |   26 +
 drivers/block/zram/Makefile              |    3 +
 drivers/block/zram/zram.txt              |   76 +++
 drivers/block/zram/zram_drv.c            |  793 ++++++++++++++++++++++
 drivers/block/zram/zram_drv.h            |  119 ++++
 drivers/block/zram/zram_sysfs.c          |  225 +++++++
 drivers/staging/Kconfig                  |    4 -
 drivers/staging/Makefile                 |    1 -
 drivers/staging/zcache/zcache-main.c     |    4 +-
 drivers/staging/zram/Kconfig             |   25 -
 drivers/staging/zram/Makefile            |    3 -
 drivers/staging/zram/zram.txt            |   76 ---
 drivers/staging/zram/zram_drv.c          |  793 ----------------------
 drivers/staging/zram/zram_drv.h          |  120 ----
 drivers/staging/zram/zram_sysfs.c        |  225 -------
 drivers/staging/zsmalloc/Kconfig         |   10 -
 drivers/staging/zsmalloc/Makefile        |    3 -
 drivers/staging/zsmalloc/zsmalloc-main.c | 1064 ------------------------------
 drivers/staging/zsmalloc/zsmalloc.h      |   43 --
 include/linux/zsmalloc.h                 |   43 ++
 lib/Kconfig                              |   18 +
 lib/Makefile                             |    1 +
 lib/zsmalloc.c                           | 1064 ++++++++++++++++++++++++++++++
 25 files changed, 2372 insertions(+), 2369 deletions(-)
 create mode 100644 drivers/block/zram/Kconfig
 create mode 100644 drivers/block/zram/Makefile
 create mode 100644 drivers/block/zram/zram.txt
 create mode 100644 drivers/block/zram/zram_drv.c
 create mode 100644 drivers/block/zram/zram_drv.h
 create mode 100644 drivers/block/zram/zram_sysfs.c
 delete mode 100644 drivers/staging/zram/Kconfig
 delete mode 100644 drivers/staging/zram/Makefile
 delete mode 100644 drivers/staging/zram/zram.txt
 delete mode 100644 drivers/staging/zram/zram_drv.c
 delete mode 100644 drivers/staging/zram/zram_drv.h
 delete mode 100644 drivers/staging/zram/zram_sysfs.c
 delete mode 100644 drivers/staging/zsmalloc/Kconfig
 delete mode 100644 drivers/staging/zsmalloc/Makefile
 delete mode 100644 drivers/staging/zsmalloc/zsmalloc-main.c
 delete mode 100644 drivers/staging/zsmalloc/zsmalloc.h
 create mode 100644 include/linux/zsmalloc.h
 create mode 100644 lib/zsmalloc.c

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
