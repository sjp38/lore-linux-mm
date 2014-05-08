Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 74AD36B00A7
	for <linux-mm@kvack.org>; Wed,  7 May 2014 20:30:40 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id lj1so1869500pab.28
        for <linux-mm@kvack.org>; Wed, 07 May 2014 17:30:40 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id ko6si2681144pbc.313.2014.05.07.17.30.38
        for <linux-mm@kvack.org>;
        Wed, 07 May 2014 17:30:39 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC PATCH 0/3] Aggressively allocate the pages on cma reserved memory
Date: Thu,  8 May 2014 09:32:21 +0900
Message-Id: <1399509144-8898-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

This series tries to improve CMA.

CMA is introduced to provide physically contiguous pages at runtime
without reserving memory area. But, current implementation works like as
reserving memory approach, because allocation on cma reserved region only
occurs as fallback of migrate_movable allocation. We can allocate from it
when there is no movable page. In that situation, kswapd would be invoked
easily since unmovable and reclaimable allocation consider
(free pages - free CMA pages) as free memory on the system and free memory
may be lower than high watermark in that case. If kswapd start to reclaim
memory, then fallback allocation doesn't occur much.

In my experiment, I found that if system memory has 1024 MB memory and
has 512 MB reserved memory for CMA, kswapd is mostly invoked around
the 512MB free memory boundary. And invoked kswapd tries to make free
memory until (free pages - free CMA pages) is higher than high watermark,
so free memory on meminfo is moving around 512MB boundary consistently.

To fix this problem, we should allocate the pages on cma reserved memory
more aggressively and intelligenetly. Patch 2 implements the solution.
Patch 1 is the simple optimization which remove useless re-trial and patch 3
is for removing useless alloc flag, so these are not important.
See patch 2 for more detailed description.

This patchset is based on v3.15-rc4.

Thanks.
Joonsoo Kim (3):
  CMA: remove redundant retrying code in __alloc_contig_migrate_range
  CMA: aggressively allocate the pages on cma reserved memory when not
    used
  CMA: always treat free cma pages as non-free on watermark checking

 include/linux/mmzone.h |    6 +++
 mm/compaction.c        |    4 --
 mm/internal.h          |    3 +-
 mm/page_alloc.c        |  117 +++++++++++++++++++++++++++++++++++++++---------
 4 files changed, 102 insertions(+), 28 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
