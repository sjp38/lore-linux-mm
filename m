Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 9D0FC6B0309
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 00:59:30 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 0/2] fix livelock because of kswapd stop
Date: Mon, 25 Jun 2012 13:59:25 +0900
Message-Id: <1340600367-23620-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Aaditya Kumar <aaditya.kumar.30@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>

When hotplug offlining happens on zone A, it starts to mark freed page
as MIGRATE_ISOLATE type in buddy for preventing further allocation.
(MIGRATE_ISOLATE is very irony type because it's apparently on buddy
but we can't allocate them).
When the memory shortage happens during hotplug offlining,
current task starts to reclaim, then wake up kswapd.
Kswapd checks watermark, then go sleep because current zone_watermark_ok_safe
doesn't consider MIGRATE_ISOLATE freed page count.
Current task continue to reclaim in direct reclaim path without kswapd's helping.
The problem is that zone->all_unreclaimable is set by only kswapd
so that current task would be looping forever like below.

__alloc_pages_slowpath
restart:
	wake_all_kswapd
rebalance:
	__alloc_pages_direct_reclaim
		do_try_to_free_pages
			if global_reclaim && !all_unreclaimable
				return 1; /* It means we did did_some_progress */
	skip __alloc_pages_may_oom
	should_alloc_retry
		goto rebalance;

[1/2] factor out memory-isolation functions from page_alloc.c to mm/page_isolation.c
      This patch can be merged regardless of [2/2].

[2/2] fix this problem.
      Aaditya, Could you confirm this patch can solve your problem?

Minchan Kim (2):
  mm: Factor out memory isolate functions
  memory-hotplug: fix kswapd looping forever problem

 drivers/base/Kconfig           |    1 +
 include/linux/mmzone.h         |    8 +++
 include/linux/page-isolation.h |    8 +--
 mm/Kconfig                     |    5 ++
 mm/Makefile                    |    4 +-
 mm/page_alloc.c                |  107 +++++++++++++-------------------------
 mm/page_isolation.c            |  110 ++++++++++++++++++++++++++++++++++++++++
 7 files changed, 166 insertions(+), 77 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
