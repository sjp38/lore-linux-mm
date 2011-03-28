Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 61E2E8D003B
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 02:13:27 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH 0/2] Reduce reclaim from per-zone LRU in global kswapd
Date: Sun, 27 Mar 2011 23:12:53 -0700
Message-Id: <1301292775-4091-1-git-send-email-yinghan@google.com>
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
per-zone LRU. However, the return value is ignored. This patch adds the logic
where no per-zone reclaim happens if the soft reclaim raise the free pages
above the zone's high_wmark.

This is part of the effort which tries to reduce reclaiming pages in global
LRU in memcg. The per-memcg background reclaim patchset further enhances the
per-cgroup targetting reclaim, which I should have V4 posted shortly.

Try running multiple memory intensive workloads within seperate memcgs. Watch
the counters for both soft_steal in memory.stat and skip_reclaim in zoneinfo.

$ egrep 'steal|scan' /dev/cgroup/A/memory.stat
soft_steal 304640
total_soft_steal 304640

$ egrep skip /proc/zoneinfo
nr_skip_reclaim_global 0
nr_skip_reclaim_global 381
nr_skip_reclaim_global 387

Ying Han (2):
  check the return value of soft_limit reclaim
  add two stats to monitor soft_limit reclaim.

 Documentation/cgroups/memory.txt |    2 ++
 include/linux/memcontrol.h       |    5 +++++
 include/linux/mmzone.h           |    1 +
 mm/memcontrol.c                  |   14 ++++++++++++++
 mm/vmscan.c                      |   16 +++++++++++++++-
 mm/vmstat.c                      |    1 +
 6 files changed, 38 insertions(+), 1 deletions(-)

-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
