Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id CD69D6B0044
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 17:56:48 -0400 (EDT)
Received: by yhpp61 with SMTP id p61so180328yhp.2
        for <linux-mm@kvack.org>; Wed, 11 Apr 2012 14:56:48 -0700 (PDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V2 0/5] memcg softlimit reclaim rework
Date: Wed, 11 Apr 2012 14:56:47 -0700
Message-Id: <1334181407-26064-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-mm@kvack.org

The "soft_limit" was introduced in memcg to support over-committing the
memory resource on the host. Each cgroup configures its "hard_limit" where
it will be throttled or OOM killed by going over the limit. However, the
cgroup can go above the "soft_limit" as long as there is no system-wide
memory contention. So, the "soft_limit" is the kernel mechanism for
re-distributng system spare memory among cgroups.

This patch reworks the softlimit reclaim by hooking it into the new global
reclaim scheme. So the global reclaim path including direct reclaim and
background reclaim will respect the memcg softlimit.

Note:
1. the new implementation of softlimit reclaim is rather simple and first
step for further optimizations. there is no memory pressure balancing between
memcgs for each zone, and that is something we would like to add as follow-ups.

2. this patch is slightly different from the last one posted from Johannes,
where his patch is closer to the reverted implementation by doing hierarchical
reclaim for each selected memcg. However, that is not expected behavior from
user perspective. Considering the following example:

root (32G capacity)
--> A (hard limit 20G, soft limit 15G, usage 16G)
   --> A1 (soft limit 5G, usage 4G)
   --> A2 (soft limit 10G, usage 12G)
--> B (hard limit 20G, soft limit 10G, usage 16G)

Under global reclaim, we shouldn't add pressure on A1 although its parent(A)
exceeds softlimit. This is what admin expects by setting softlimit to the
actual working set size and only reclaim pages under softlimit if system has
trouble to reclaim.

Test on 32G host:
The stats are the memory.vmscan_stat which I didn't included in this patchset. It exports per-memcg based vmscan stats. The stat shows in the following exports the number of pages being reclaimed under global pressure from each memcg. As I can see, there is no pages reclaimed under memcg softlimit until some point (case 3). In that case, there are many reclaimers (20 container + kswapds ) with less reclaimable memcg (above softlimit) and the reclaim priority jumps. That's why we see memcg under softlimit being reclaimed as well.

1. 20 * cat 1G ramdisk containers (hardlimit = 512M, softlimit = 0 by default) + memory hog (for global pressure)
    $ for ((i=0; i<20; i++)); do cat /dev/cgroup/memory/$i/memory.vmscan_stat | grep total_freed_file_pages_by_system_under_hierarchy; done
    total_freed_file_pages_by_system_under_hierarchy 4431458
    total_freed_file_pages_by_system_under_hierarchy 4572150
    total_freed_file_pages_by_system_under_hierarchy 4260969
    total_freed_file_pages_by_system_under_hierarchy 4522491
    total_freed_file_pages_by_system_under_hierarchy 4467898
    total_freed_file_pages_by_system_under_hierarchy 4231144
    total_freed_file_pages_by_system_under_hierarchy 4467987
    total_freed_file_pages_by_system_under_hierarchy 4415137
    total_freed_file_pages_by_system_under_hierarchy 4537076
    total_freed_file_pages_by_system_under_hierarchy 4374586
    total_freed_file_pages_by_system_under_hierarchy 4238208
    total_freed_file_pages_by_system_under_hierarchy 4497263
    total_freed_file_pages_by_system_under_hierarchy 4401839
    total_freed_file_pages_by_system_under_hierarchy 4407700
    total_freed_file_pages_by_system_under_hierarchy 4291009
    total_freed_file_pages_by_system_under_hierarchy 4228416
    total_freed_file_pages_by_system_under_hierarchy 4126986
    total_freed_file_pages_by_system_under_hierarchy 4730479
    total_freed_file_pages_by_system_under_hierarchy 4316904
    total_freed_file_pages_by_system_under_hierarchy 4304469

2. 20 * cat 1G ramdisk containers (hardlimit = 512M, 1-5 container softlimit = 512M) + memory hog (for global pressure)
    total_freed_file_pages_by_system_under_hierarchy 0
    total_freed_file_pages_by_system_under_hierarchy 0
    total_freed_file_pages_by_system_under_hierarchy 0
    total_freed_file_pages_by_system_under_hierarchy 0
    total_freed_file_pages_by_system_under_hierarchy 0
    total_freed_file_pages_by_system_under_hierarchy 4562418
    total_freed_file_pages_by_system_under_hierarchy 4630498
    total_freed_file_pages_by_system_under_hierarchy 4809946
    total_freed_file_pages_by_system_under_hierarchy 4767868
    total_freed_file_pages_by_system_under_hierarchy 4716920
    total_freed_file_pages_by_system_under_hierarchy 4828952
    total_freed_file_pages_by_system_under_hierarchy 4672482
    total_freed_file_pages_by_system_under_hierarchy 4593165
    total_freed_file_pages_by_system_under_hierarchy 4862157
    total_freed_file_pages_by_system_under_hierarchy 4639331
    total_freed_file_pages_by_system_under_hierarchy 4620658
    total_freed_file_pages_by_system_under_hierarchy 4880210
    total_freed_file_pages_by_system_under_hierarchy 4652485
    total_freed_file_pages_by_system_under_hierarchy 4633724
    total_freed_file_pages_by_system_under_hierarchy 4673583

3. 20 * cat 1G ramdisk containers (hardlimit = 512M, 1-10 container softlimit = 512M) + memory hog (for global pressure)
   total_freed_file_pages_by_system_under_hierarchy 7318
   total_freed_file_pages_by_system_under_hierarchy 6612
   total_freed_file_pages_by_system_under_hierarchy 2900
   total_freed_file_pages_by_system_under_hierarchy 5740
   total_freed_file_pages_by_system_under_hierarchy 5353
   total_freed_file_pages_by_system_under_hierarchy 4707
   total_freed_file_pages_by_system_under_hierarchy 4252
   total_freed_file_pages_by_system_under_hierarchy 5518
   total_freed_file_pages_by_system_under_hierarchy 1431
   total_freed_file_pages_by_system_under_hierarchy 5722
   total_freed_file_pages_by_system_under_hierarchy 9538489
   total_freed_file_pages_by_system_under_hierarchy 9334518
   total_freed_file_pages_by_system_under_hierarchy 9727377
   total_freed_file_pages_by_system_under_hierarchy 9602573
   total_freed_file_pages_by_system_under_hierarchy 9771141
   total_freed_file_pages_by_system_under_hierarchy 9769589
   total_freed_file_pages_by_system_under_hierarchy 9610550
   total_freed_file_pages_by_system_under_hierarchy 9535241
   total_freed_file_pages_by_system_under_hierarchy 9912726
   total_freed_file_pages_by_system_under_hierarchy 9502706

Ying Han (5):
  memcg: revert current soft limit reclaim implementation
  memcg: rework softlimit reclaim
  memcg: set soft_limit_in_bytes to 0 by default
  memcg: detect no memcgs above softlimit under zone reclaim.
  memcg: change the target nr_to_reclaim for each memcg under kswapd

 include/linux/memcontrol.h |   18 +--
 include/linux/swap.h       |    4 -
 kernel/res_counter.c       |    1 -
 mm/memcontrol.c            |  397 +-------------------------------------------
 mm/vmscan.c                |  125 ++++++---------
 5 files changed, 65 insertions(+), 480 deletions(-)

-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
