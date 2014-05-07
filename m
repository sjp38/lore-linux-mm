Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f50.google.com (mail-yh0-f50.google.com [209.85.213.50])
	by kanga.kvack.org (Postfix) with ESMTP id B91DD6B0083
	for <linux-mm@kvack.org>; Wed,  7 May 2014 17:52:12 -0400 (EDT)
Received: by mail-yh0-f50.google.com with SMTP id 29so1521183yhl.37
        for <linux-mm@kvack.org>; Wed, 07 May 2014 14:52:12 -0700 (PDT)
Received: from mail-yk0-x229.google.com (mail-yk0-x229.google.com [2607:f8b0:4002:c07::229])
        by mx.google.com with ESMTPS id a7si23223568yhb.9.2014.05.07.14.52.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 May 2014 14:52:12 -0700 (PDT)
Received: by mail-yk0-f169.google.com with SMTP id 200so1438211ykr.0
        for <linux-mm@kvack.org>; Wed, 07 May 2014 14:52:12 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCHv2 0/4] mm/zpool: add common api for zswap to use zbud/zsmalloc
Date: Wed,  7 May 2014 17:51:32 -0400
Message-Id: <1399499496-3216-1-git-send-email-ddstreet@ieee.org>
In-Reply-To: <1397922764-1512-1-git-send-email-ddstreet@ieee.org>
References: <1397922764-1512-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>, Nitin Gupta <ngupta@vflare.org>
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

In order to allow zswap users to choose between zbud and zsmalloc for
the compressed storage pool, this patch set adds a new api "zpool" that
provides an interface to both zbud and zsmalloc.  Only a minor changes
to zbud's interface were needed, as detailed in the first two patches.
This does not implement zsmalloc shrinking (which will be submitted
separately), so when using zsmalloc as the pool type, zpool_shrink()
will always fail.

I believe Seth originally was using zsmalloc for swap, but there were
concerns about how significant the impact of shrinking zsmalloc would
be when zswap had to start reclaiming pages.  That still may be an
issue, but this at least allows users to choose themselves whether
they want a lower-density or higher-density compressed storage medium.
At least for situations where zswap reclaim is never or rarely reached,
it probably makes sense to use the higher density of zsmalloc.

Note this patch series does not change zram to use zpool, although that
change should be possible as well.

This patchset is against git://git.cmpxchg.org/linux-mmotm.git
commit a51cc1787cdef3f17536d6a6dc1edd0e7a85988f

Changes since v1 https://lkml.org/lkml/2014/4/19/97
 -remove zsmalloc shrinking
 -change zbud size param type from unsigned int to size_t
 -remove zpool fallback creation
 -zswap manually falls back to zbud if specified type fails

Dan Streetman (4):
  mm/zbud: zbud_alloc() minor param change
  mm/zbud: change zbud_alloc size type to size_t
  mm/zpool: implement common zpool api to zbud/zsmalloc
  mm/zswap: update zswap to use zpool

 include/linux/zbud.h  |   2 +-
 include/linux/zpool.h | 160 +++++++++++++++++++++++
 mm/Kconfig            |  43 ++++---
 mm/Makefile           |   1 +
 mm/zbud.c             |  30 +++--
 mm/zpool.c            | 349 ++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/zswap.c            |  75 ++++++-----
 7 files changed, 596 insertions(+), 64 deletions(-)
 create mode 100644 include/linux/zpool.h
 create mode 100644 mm/zpool.c

-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
