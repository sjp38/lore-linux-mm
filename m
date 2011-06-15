Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 041586B0082
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 23:09:12 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V1 0/2] memcg: break the zone->lru_lock on reclaim
Date: Tue, 14 Jun 2011 20:08:09 -0700
Message-Id: <1308107291-2909-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Suleiman Souhlal <suleiman@google.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

This patch is based on mmotm-2011-05-12-15-52 plus

"[patch 0/8] mm: memcg naturalization -rc2" patchset

"Fix behavior of per-cpu charge cache draining in memcg."

Now with all the efforts of memcg reclaim, we are going to have better
targetting per-memcg reclaim both under global memory pressure and per-memcg
memory pressure. The patch fixes the last piece which making the lru_lock to
be exclusive across memcgs.

The reasons we have the zone->lru_lock shared due to the following:
1. each page is linked both in per-memcg lru as well as per-zone lru due to the
lack of targetting reclaim under global memory pressure.
2. since we have 1), it is easier to maintain and less race conditions to have
the zone->lru_lock shared vs per-memcg lock.

After Johannes patchset, there will be no global lru list when memcg is enabled.
All the pages are in exclusive per-memcg lru. So it makes senses to make the
spinlock exclusive which could be easily causing bad lock contention with lots
of memcgs each running memory intensive workload. The zone->lru_lock is still
being used if memcg is not enabled and there shouldn't be any change in that
condition.

change v1..v0:
1. moved the spinlock lru_lock from mem_cgroup_per_zone struct to lruvec.
the later one is introduced by Johannes patch which I think fits the lock
much better.

2. add the changes in the CONFIG_TRANSPARENT_HUGEPAGE and CONFIG_COMPACTION.

3. fixed up the crash which are caused by the lumpy reclaim earlier on.

Test:
On my 8-core machine, i created 8 memcgs and each is doing a read from a ramdisk file.
The filesize is larger than the hard_limit which triggers the per-memcg direct reclaim.
Here I am using ramdisk to avoid the run-to-run noise from the hard drive.

--------------------------------------------------------------------------------------------------------------------------------------------
class name    con-bounces    contentions   waittime-min   waittime-max waittime-total    acq-bounces   acquisitions   holdtime-min   holdtime-max holdtime-total

Before the patch:

              &(&zone->lru_lock)->rlock:        176843         176913           0.23          31.09      387180.72        1322312        3680197           0.00          45.20     6064010.97
              -------------------------
              &(&zone->lru_lock)->rlock          71797          [<ffffffff810f25a8>] pagevec_lru_move_fn+0x6b/0xc2
              &(&zone->lru_lock)->rlock         105015          [<ffffffff810f2488>] release_pages+0xcd/0x182
              &(&zone->lru_lock)->rlock            101          [<ffffffff810f21ed>] __page_cache_release+0x3f/0x6b
              -------------------------
              &(&zone->lru_lock)->rlock          84143          [<ffffffff810f25a8>] pagevec_lru_move_fn+0x6b/0xc2
              &(&zone->lru_lock)->rlock          92680          [<ffffffff810f2488>] release_pages+0xcd/0x182
              &(&zone->lru_lock)->rlock             90          [<ffffffff810f21ed>] __page_cache_release+0x3f/0x6b

After the patch:

                &(&mz->lru_lock)->rlock:          1911           1911           0.24          13.52        3242.64         100828        3719739           0.00          45.07     5764770.80
                &(&mz->lru_lock)->rlock           1079          [<ffffffff810f24a7>] release_pages+0xe3/0x1a3
                &(&mz->lru_lock)->rlock            815          [<ffffffff810f25c8>] pagevec_lru_move_fn+0x61/0xb1
                &(&mz->lru_lock)->rlock             17          [<ffffffff810f21ef>] __page_cache_release+0x38/0x6b
                &(&mz->lru_lock)->rlock           1207          [<ffffffff810f25c8>] pagevec_lru_move_fn+0x61/0xb1
                &(&mz->lru_lock)->rlock            692          [<ffffffff810f24a7>] release_pages+0xe3/0x1a3
                &(&mz->lru_lock)->rlock             12          [<ffffffff810f21ef>] __page_cache_release+0x38/0x6b

Ying Han (2):
  memcg: break the zone->lru_lock in memcg-aware reclaim
  Move the lru_lock into the lruvec struct.

 include/linux/memcontrol.h |   17 +++++++
 include/linux/mm_types.h   |    2 +-
 include/linux/mmzone.h     |    8 ++--
 mm/compaction.c            |   41 ++++++++++------
 mm/huge_memory.c           |    5 +-
 mm/memcontrol.c            |   66 +++++++++++++++++++++----
 mm/page_alloc.c            |    2 +-
 mm/rmap.c                  |    2 +-
 mm/swap.c                  |   71 ++++++++++++++++------------
 mm/vmscan.c                |  114 ++++++++++++++++++++++++++++++--------------
 10 files changed, 228 insertions(+), 100 deletions(-)

-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
