Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 557FF8D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 01:56:57 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V3 0/2] Reduce reclaim from per-zone LRU in global kswapd
Date: Mon, 28 Mar 2011 22:56:24 -0700
Message-Id: <1301378186-23199-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

The global kswapd scans per-zone LRU and reclaims pages regardless of the
cgroup. It breaks memory isolation since one cgroup can end up reclaiming
pages from another cgroup. Instead we should rely on memcg-aware target
reclaim including per-memcg kswapd and soft_limit hierarchical reclaim under
memory pressure.

In the global background reclaim, we do soft reclaim before scanning the
per-zone LRU. However, the return value is ignored. This patch is the first
step to skip shrink_zone() if soft_limit reclaim does enough work.

This is part of the effort which tries to reduce reclaiming pages in global
LRU in memcg. The per-memcg background reclaim patchset further enhances the
per-cgroup targetting reclaim, which I should have V4 posted shortly.

Try running multiple memory intensive workloads within seperate memcgs. Watch
the counters of soft_steal in memory.stat.

$ cat /dev/cgroup/A/memory.stat | grep 'soft'
soft_steal 240000
soft_scan 240000
total_soft_steal 240000
total_soft_scan 240000

Ying Han (2):
  count the soft_limit reclaim in global background reclaim
  add stats to monitor soft_limit reclaim

 Documentation/cgroups/memory.txt |    4 +++
 include/linux/memcontrol.h       |    7 +++--
 include/linux/swap.h             |    3 +-
 mm/memcontrol.c                  |   54 +++++++++++++++++++++++++++++++------
 mm/vmscan.c                      |   16 +++++++++--
 5 files changed, 68 insertions(+), 16 deletions(-)

-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
