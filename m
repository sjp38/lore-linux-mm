Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 9C7796B003C
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 17:44:19 -0400 (EDT)
Received: by mail-ie0-f171.google.com with SMTP id x19so9950640ier.2
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 14:44:19 -0700 (PDT)
Received: from mail-ig0-x232.google.com (mail-ig0-x232.google.com [2607:f8b0:4001:c05::232])
        by mx.google.com with ESMTPS id g10si40570314icm.99.2014.07.02.14.44.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 02 Jul 2014 14:44:18 -0700 (PDT)
Received: by mail-ig0-f178.google.com with SMTP id hn18so782464igb.5
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 14:44:17 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCHv5 0/4] mm/zpool: add common api for zswap to use zbud/zsmalloc
Date: Wed,  2 Jul 2014 17:43:59 -0400
Message-Id: <1404337439-10938-1-git-send-email-ddstreet@ieee.org>
In-Reply-To: <1401747586-11861-1-git-send-email-ddstreet@ieee.org>
References: <1401747586-11861-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>, Nitin Gupta <ngupta@vflare.org>
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

In order to allow zswap users to choose between zbud and zsmalloc for
the compressed storage pool, this patch set adds a new api "zpool" that
provides an interface to both zbud and zsmalloc.  This does not include
implementing shrinking in zsmalloc, which will be sent separately.

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
Changes since v4 : https://lkml.org/lkml/2014/6/2/711
  -omit first patch, that removed gfp_t param from zpool_malloc()
  -move function doc from zpool.h to zpool.c
  -move module usage refcounting into patch that adds zpool
  -add extra refcounting to prevent driver unregister if in use
  -add doc clarifying concurrency usage
  -make zbud/zsmalloc zpool functions static
  -typo corrections

Changes since v3 : https://lkml.org/lkml/2014/5/24/130
  -In zpool_shrink() use # pages instead of # bytes
  -Add reclaimed param to zpool_shrink() to indicate to caller
   # pages actually reclaimed
  -move module usage counting to zpool, from zbud/zsmalloc
  -update zbud_zpool_shrink() to call zbud_reclaim_page() in a
   loop until requested # pages have been reclaimed (or error)

Changes since v2 : https://lkml.org/lkml/2014/5/7/927
  -Change zpool to use driver registration instead of hardcoding
   implementations
  -Add module use counting in zbud/zsmalloc

Changes since v1 https://lkml.org/lkml/2014/4/19/97
 -remove zsmalloc shrinking
 -change zbud size param type from unsigned int to size_t
 -remove zpool fallback creation
 -zswap manually falls back to zbud if specified type fails


Dan Streetman (4):
  mm/zbud: change zbud_alloc size type to size_t
  mm/zpool: implement common zpool api to zbud/zsmalloc
  mm/zpool: zbud/zsmalloc implement zpool
  mm/zpool: update zswap to use zpool

 include/linux/zbud.h  |   2 +-
 include/linux/zpool.h | 106 +++++++++++++++
 mm/Kconfig            |  43 +++---
 mm/Makefile           |   1 +
 mm/zbud.c             |  98 +++++++++++++-
 mm/zpool.c            | 364 ++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/zsmalloc.c         |  84 ++++++++++++
 mm/zswap.c            |  75 ++++++-----
 8 files changed, 722 insertions(+), 51 deletions(-)
 create mode 100644 include/linux/zpool.h
 create mode 100644 mm/zpool.c

-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
