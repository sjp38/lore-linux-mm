Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 29F8A6B0012
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 10:55:48 -0400 (EDT)
Received: by iyl8 with SMTP id 8so2795700iyl.14
        for <linux-mm@kvack.org>; Thu, 30 Jun 2011 07:55:44 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v4 00/10] Prevent LRU churning
Date: Thu, 30 Jun 2011 23:55:10 +0900
Message-Id: <cover.1309444657.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>

Changelog since v3
 o Patch reordering - suggested by Mel and Michal
 o Bug fix of trace-vmscan-postprocess - pointed out by Mel
 o Clean up(function naming, mistakes in previos version)
 o bitwise type usage for isolate_mode_t - suggested by Mel
 o Add comment ilru handling in migrate.c - suggested by Mel
 o Reduce zone->lru_lock - pointed out by Mel

Changelog since v2
 o Remove ISOLATE_BOTH - suggested by Johannes
 o change description slightly
 o Clean up unman_and_move
 o Add Reviewed-by and Acked-by

Changelog since v1
 o Rebase on 2.6.39
 o change description slightly

There are some places to isolate and putback pages.
For example, compaction does it for getting contiguous page.
The problem is that if we isolate page in the middle of LRU and putback it
we lose LRU history as putback_lru_page inserts the page into head of LRU list.

LRU history is important parameter to select victim page in curre page reclaim
when memory pressure is heavy. Unfortunately, if someone want to allocate high-order page
and memory pressure is heavy, it would trigger compaction and we end up lost LRU history.
It means we can evict working set pages and system latency would be high.

This patch is for solving the problem with two methods.

 * Anti-churning
   when we isolate page on LRU list, let's not isolate page we can't handle
 * De-churning
   when we putback page on LRU list in migration, let's insert new page into old page's lru position.

[1,2,5/10] is just clean up.
[3,4/10] is related to Anti-churning.
[6,7,8/10] is related to De-churning.
[9/10] is adding to new tracepoints which is never for merge but just show the effect.
[10/10] is enhancement of ilru.

I test it in my mahchine(2G DRAM, Intel Core 2 Duo), test scenario is following as.

1) Boot up
2) decompress 10G compressed file
3) Run many applications and switch attached script(which is made by Wu) and
4) kernel compile

I think this is worst-case scenario since there are many contiguous pages when machine boots up.
It means system memory isn't aging so that many pages are contiguous-LRU order. It could make
bad effect on inorder-lru but I solved the problem. Please see description of [6/9].

Test result is following as.

1) Elapased time 10GB file decompressed.
Old			inorder			inorder + pagevec flush[10/10]
01:47:50.88		01:43:16.16		01:40:27.18

2) failure of inorder lru
For test, it isolated 375756 pages. Only 45875 pages(12%) are put backed to
out-of-order(ie, head of LRU) Others, 329963 pages(88%) are put backed to in-order
(ie, position of old page in LRU).

Welcome to any comments.

You can see Wu's test script and all-at-once patch in following URL.
http://www.kernel.org/pub/linux/kernel/people/minchan/inorder_putback/v4/

Minchan Kim (10):
  [1/10] compaction: trivial clean up acct_isolated
  [2/10] Change isolate mode from #define to bitwise type
  [3/10] compaction: make isolate_lru_page with filter aware
  [4/10] zone_reclaim: make isolate_lru_page with filter aware
  [5/10] migration: clean up unmap_and_move
  [6/10] migration: introudce migrate_ilru_pages
  [7/10] compaction: make compaction use in-order putback
  [8/10] ilru: reduce zone->lru_lock
  [9/10] add inorder-lru tracepoints for just measurement
  [10/10] compaction: add drain ilru of pagevec

 .../trace/postprocess/trace-vmscan-postprocess.pl  |    8 +-
 include/linux/memcontrol.h                         |    3 +-
 include/linux/migrate.h                            |   87 ++++++++
 include/linux/mm_types.h                           |   22 ++-
 include/linux/mmzone.h                             |   12 +
 include/linux/pagevec.h                            |    1 +
 include/linux/swap.h                               |   15 +-
 include/trace/events/inorder_putback.h             |   88 ++++++++
 include/trace/events/vmscan.h                      |    8 +-
 mm/compaction.c                                    |   47 ++---
 mm/internal.h                                      |    1 +
 mm/memcontrol.c                                    |    3 +-
 mm/migrate.c                                       |  213 ++++++++++++++++---
 mm/swap.c                                          |  217 +++++++++++++++++++-
 mm/vmscan.c                                        |  122 ++++++++---
 15 files changed, 738 insertions(+), 109 deletions(-)
 create mode 100644 include/trace/events/inorder_putback.h

-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
