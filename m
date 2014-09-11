Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 380A46B0035
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 16:54:41 -0400 (EDT)
Received: by mail-ig0-f174.google.com with SMTP id h18so1690806igc.7
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 13:54:40 -0700 (PDT)
Received: from mail-ig0-x22b.google.com (mail-ig0-x22b.google.com [2607:f8b0:4001:c05::22b])
        by mx.google.com with ESMTPS id o10si2486819icf.52.2014.09.11.13.54.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 11 Sep 2014 13:54:39 -0700 (PDT)
Received: by mail-ig0-f171.google.com with SMTP id r10so1697238igi.4
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 13:54:39 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH 00/10] implement zsmalloc shrinking
Date: Thu, 11 Sep 2014 16:53:51 -0400
Message-Id: <1410468841-320-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>, Dan Streetman <ddstreet@ieee.org>

Now that zswap can use zsmalloc as a storage pool via zpool, it will
try to shrink its zsmalloc zs_pool once it reaches its max_pool_percent
limit.  These patches implement zsmalloc shrinking.  The way the pool is
shrunk is by finding a zspage and reclaiming it, by evicting each of its
objects that is in use.

Without these patches zswap, and any other future user of zpool/zsmalloc
that attempts to shrink the zpool/zs_pool, will only get errors and will
be unable to shrink its zpool/zs_pool.  With the ability to shrink, zswap
can keep the most recent compressed pages in memory.

Note that the design of zsmalloc makes it impossible to actually find the
LRU zspage, so each class and fullness group is searched in a round-robin
method to find the next zspage to reclaim.  Each fullness group orders its
zspages in LRU order, so the oldest zspage is used for each fullness group.

---

This patch set applies to linux-next.

Dan Streetman (10):
  zsmalloc: fix init_zspage free obj linking
  zsmalloc: add fullness group list for ZS_FULL zspages
  zsmalloc: always update lru ordering of each zspage
  zsmalloc: move zspage obj freeing to separate function
  zsmalloc: add atomic index to find zspage to reclaim
  zsmalloc: add zs_ops to zs_pool
  zsmalloc: add obj_handle_is_free()
  zsmalloc: add reclaim_zspage()
  zsmalloc: add zs_shrink()
  zsmalloc: implement zs_zpool_shrink() with zs_shrink()

 drivers/block/zram/zram_drv.c |   2 +-
 include/linux/zsmalloc.h      |   7 +-
 mm/zsmalloc.c                 | 314 +++++++++++++++++++++++++++++++++++++-----
 3 files changed, 290 insertions(+), 33 deletions(-)

-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
