Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id CAF8D6B0035
	for <linux-mm@kvack.org>; Sat, 19 Apr 2014 11:53:18 -0400 (EDT)
Received: by mail-qa0-f49.google.com with SMTP id j7so2460975qaq.22
        for <linux-mm@kvack.org>; Sat, 19 Apr 2014 08:53:18 -0700 (PDT)
Received: from mail-qa0-x231.google.com (mail-qa0-x231.google.com [2607:f8b0:400d:c00::231])
        by mx.google.com with ESMTPS id di5si13231080qcb.56.2014.04.19.08.53.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 19 Apr 2014 08:53:18 -0700 (PDT)
Received: by mail-qa0-f49.google.com with SMTP id j7so2469822qaq.36
        for <linux-mm@kvack.org>; Sat, 19 Apr 2014 08:53:18 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH 0/4] mm: zpool: add common api for zswap to use zbud/zsmalloc
Date: Sat, 19 Apr 2014 11:52:40 -0400
Message-Id: <1397922764-1512-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Weijie Yang <weijie.yang@samsung.com>, Johannes Weiner <hannes@cmpxchg.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

In order to allow zswap users to choose between zbud and zsmalloc for
the compressed storage pool, this patch set adds a new api "zpool" that
provides an interface to both zbud and zsmalloc.  Only a minor change
to zbud's interface was needed, as detailed in the first patch;
zsmalloc required shrinking to be added and a minor interface change,
as detailed in the second patch.

I believe Seth originally was using zsmalloc for swap, but there were
concerns about how significant the impact of shrinking zsmalloc would
be when zswap had to start reclaiming pages.  That still may be an
issue, but this at least allows users to choose themselves whether
they want a lower-density or higher-density compressed storage medium.
At least for situations where zswap reclaim is never or rarely reached,
it probably makes sense to use the higher density of zsmalloc.

Note this patch series does not change zram to use zpool, although that
change should be possible as well.


Dan Streetman (4):
  mm: zpool: zbud_alloc() minor param change
  mm: zpool: implement zsmalloc shrinking
  mm: zpool: implement common zpool api to zbud/zsmalloc
  mm: zpool: update zswap to use zpool

 drivers/block/zram/zram_drv.c |   2 +-
 include/linux/zbud.h          |   3 +-
 include/linux/zpool.h         | 166 ++++++++++++++++++
 include/linux/zsmalloc.h      |   7 +-
 mm/Kconfig                    |  43 +++--
 mm/Makefile                   |   1 +
 mm/zbud.c                     |  28 ++--
 mm/zpool.c                    | 380 ++++++++++++++++++++++++++++++++++++++++++
 mm/zsmalloc.c                 | 168 +++++++++++++++++--
 mm/zswap.c                    |  70 ++++----
 10 files changed, 787 insertions(+), 81 deletions(-)
 create mode 100644 include/linux/zpool.h
 create mode 100644 mm/zpool.c

-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
