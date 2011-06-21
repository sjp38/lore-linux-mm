Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 27AA990013A
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 18:42:16 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [RFC PATCH 0/5] softlimit reclaim and zone->lru_lock rework
Date: Tue, 21 Jun 2011 15:41:25 -0700
Message-Id: <1308696090-31569-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Suleiman Souhlal <suleiman@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

The patchset is based on mmotm-2011-05-12-15-52 plus the following patches.

[BUGFIX][PATCH 5/5] memcg: fix percpu cached charge draining frequency
[patch 1/8] memcg: remove unused retry signal from reclaim
[patch 2/8] mm: memcg-aware global reclaim
[patch 3/8] memcg: reclaim statistics
[patch 6/8] vmscan: change zone_nr_lru_pages to take memcg instead of scan control
[patch 7/8] vmscan: memcg-aware unevictable page rescue scanner
[patch 8/8] mm: make per-memcg lru lists exclusive

This patchset comes only after Johannes "memcg naturalization" effort. I don't
expect this to be merged soon. The reason for me to post it here for syncing up
with ppl with the current status of the effort. And also comments and code reviews
are welcomed.

This patchset includes:
1. rework softlimit reclaim on priority based. this depends on the "memcg-aware
global reclaim" patch.
2. break the zone->lru_lock for memcg reclaim. this depends on the "per-memcg
lru lists exclusive" patch.

I would definitely make them as two seperate patches later. For now, this is
only to sync-up with folks on the status of the effort.

Ying Han (5):
  Revert soft_limit reclaim changes under global pressure.
  Revert soft limit reclaim implementation in memcg.
  rework softlimit reclaim.
  memcg: break the zone->lru_lock in memcg-aware reclaim
  Move the lru_lock into the lruvec struct.

 include/linux/memcontrol.h |   35 ++-
 include/linux/mm_types.h   |    2 +-
 include/linux/mmzone.h     |    8 +-
 include/linux/swap.h       |    5 -
 mm/compaction.c            |   41 +++--
 mm/huge_memory.c           |    5 +-
 mm/memcontrol.c            |  502 ++++++--------------------------------------
 mm/page_alloc.c            |    2 +-
 mm/rmap.c                  |    2 +-
 mm/swap.c                  |   71 ++++---
 mm/vmscan.c                |  186 ++++++++---------
 11 files changed, 246 insertions(+), 613 deletions(-)

-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
