Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f42.google.com (mail-yh0-f42.google.com [209.85.213.42])
	by kanga.kvack.org (Postfix) with ESMTP id 8D53D6B0036
	for <linux-mm@kvack.org>; Sat, 24 May 2014 15:07:17 -0400 (EDT)
Received: by mail-yh0-f42.google.com with SMTP id t59so5264501yho.15
        for <linux-mm@kvack.org>; Sat, 24 May 2014 12:07:17 -0700 (PDT)
Received: from mail-yk0-x230.google.com (mail-yk0-x230.google.com [2607:f8b0:4002:c07::230])
        by mx.google.com with ESMTPS id u45si11015903yhi.19.2014.05.24.12.07.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 24 May 2014 12:07:17 -0700 (PDT)
Received: by mail-yk0-f176.google.com with SMTP id q9so5005108ykb.7
        for <linux-mm@kvack.org>; Sat, 24 May 2014 12:07:16 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCHv3 0/6] mm/zpool: add common api for zswap to use zbud/zsmalloc
Date: Sat, 24 May 2014 15:06:03 -0400
Message-Id: <1400958369-3588-1-git-send-email-ddstreet@ieee.org>
In-Reply-To: <1399499496-3216-1-git-send-email-ddstreet@ieee.org>
References: <1399499496-3216-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>, Nitin Gupta <ngupta@vflare.org>
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

In order to allow zswap users to choose between zbud and zsmalloc for
the compressed storage pool, this patch set adds a new api "zpool" that
provides an interface to both zbud and zsmalloc.  Only minor changes
to zbud's interface were needed.  This does not include implementing
shrinking in zsmalloc, which will be sent separately.

I believe Seth originally was using zsmalloc for swap, but there were
concerns about how significant the impact of shrinking zsmalloc would
be when zswap had to start reclaiming pages.  That still may be an
issue, but this at least allows users to choose themselves whether
they want a lower-density or higher-density compressed storage medium.
At least for situations where zswap reclaim is never or rarely reached,
it probably makes sense to use the higher density of zsmalloc.

Note this patch set does not change zram to use zpool, although that
change should be possible as well.

---

Changes since v2 : https://lkml.org/lkml/2014/5/7/927
  -Change zpool to use driver registration instead of hardcoding
   implementations
  -Add module use counting in zbud/zsmalloc

Changes since v1 https://lkml.org/lkml/2014/4/19/97
 -remove zsmalloc shrinking
 -change zbud size param type from unsigned int to size_t
 -remove zpool fallback creation
 -zswap manually falls back to zbud if specified type fails


Dan Streetman (6):
  mm/zbud: zbud_alloc() minor param change
  mm/zbud: change zbud_alloc size type to size_t
  mm/zpool: implement common zpool api to zbud/zsmalloc
  mm/zpool: zbud/zsmalloc implement zpool
  mm/zpool: update zswap to use zpool
  mm/zpool: prevent zbud/zsmalloc from unloading when used

 include/linux/zbud.h  |   2 +-
 include/linux/zpool.h | 214 ++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/Kconfig            |  43 +++++-----
 mm/Makefile           |   1 +
 mm/zbud.c             | 113 ++++++++++++++++++++++----
 mm/zpool.c            | 197 ++++++++++++++++++++++++++++++++++++++++++++++
 mm/zsmalloc.c         |  86 ++++++++++++++++++++
 mm/zswap.c            |  76 ++++++++++--------
 8 files changed, 668 insertions(+), 64 deletions(-)
 create mode 100644 include/linux/zpool.h
 create mode 100644 mm/zpool.c

-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
