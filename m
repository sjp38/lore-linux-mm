Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id BA0599000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 12:25:39 -0400 (EDT)
Received: by iwg8 with SMTP id 8so955640iwg.14
        for <linux-mm@kvack.org>; Tue, 26 Apr 2011 09:25:38 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [RFC 0/8] Prevent LRU churing
Date: Wed, 27 Apr 2011 01:25:17 +0900
Message-Id: <cover.1303833415.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>

There are some places to isolated and putback.
For example, compaction does it for getting contiguous page.
The problem is that if we isolate page in the middle of LRU and putback it, 
we lose LRU history as putback_lru_page inserts the page into head of LRU list. 
It means we can evict working set pages.
This problem is discussed at LSF/MM.

This patch is for solving the problem as two methods.

 * anti-churning
   when we isolate page on LRU list, let's not isolate page we can't handle
 * de-churning
   when we putback page on LRU list, let's insert isolate page into previous lru position.

[1,2,3/8] is related to anti-churing.
[4,5/8] is things I found during making this series and 
it's not dependent on this series so it could be merged. 
[6,7,8/8] is related to de-churing. 
[6/8] is core of in-order putback support but it has a problem on hugepage like
physicall contiguos page stream. It's pointed out by Rik. I have another idea to 
solve it. It is written down on description of [6/8]. Please look at it.

It's just RFC so I need more time to make code clearness and test and get data.
But before futher progress, I hope listen about approach, design, 
review the code(ex, locking, naming and so on) or anyting welcome. 

This patches are based on mmotm-2011-04-14-15-08 and my simple test is passed.

Thanks. 

Minchan Kim (8):
  [1/8] Only isolate page we can handle
  [2/8] compaction: make isolate_lru_page with filter aware
  [3/8] vmscan: make isolate_lru_page with filter aware
  [4/8] Make clear description of putback_lru_page
  [5/8] compaction: remove active list counting
  [6/8] In order putback lru core
  [7/8] migration: make in-order-putback aware
  [8/8] compaction: make compaction use in-order putback

 include/linux/migrate.h  |    6 ++-
 include/linux/mm_types.h |    7 +++
 include/linux/swap.h     |    5 ++-
 mm/compaction.c          |   27 ++++++---
 mm/internal.h            |    2 +
 mm/memcontrol.c          |    2 +-
 mm/memory-failure.c      |    2 +-
 mm/memory_hotplug.c      |    2 +-
 mm/mempolicy.c           |    4 +-
 mm/migrate.c             |  133 +++++++++++++++++++++++++++++++++++++---------
 mm/swap.c                |    2 +-
 mm/vmscan.c              |  110 ++++++++++++++++++++++++++++++++++----
 12 files changed, 247 insertions(+), 55 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
