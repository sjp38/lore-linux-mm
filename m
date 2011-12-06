Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id F0B886B005C
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 19:00:07 -0500 (EST)
Received: by eekc50 with SMTP id c50so1830eek.2
        for <linux-mm@kvack.org>; Tue, 06 Dec 2011 16:00:06 -0800 (PST)
From: Ying Han <yinghan@google.com>
Subject: [PATCH 0/3] memcg softlimit reclaim rework
Date: Tue,  6 Dec 2011 15:59:56 -0800
Message-Id: <1323215999-29164-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>
Cc: linux-mm@kvack.org

The "soft_limit" was introduced in memcg to support over-committing the
memory resource on the host. Each cgroup configures its "hard_limit" where
it will be throttled or OOM killed by going over the limit. However, the
cgroup can go above the "soft_limit" as long as there is no system-wide
memory contention. So, the "soft_limit" is the kernel mechanism for
re-distributng system spare memory among cgroups.

This patch reworks the softlimit reclaim by hooking it into the new global
reclaim scheme. So the global reclaim path including direct reclaim and
background reclaim will respect the memcg softlimit. At the same time,
per-memcg reclaim will by default scanning all the memcgs under the
hierarchy.

On a 64G host, creates 12 * 256M (limit_in_bytes) memcgs where each reads from
a 512M ramdisk. At the same time, sets the softlimit to last 6 memcgs. Under
global memory pressure, only the ones (first 6 memcgs) above softlimit got
scanned and reclaimed.

$ for ((i=0; i<12; i++)); do cat /path/$i/memory.limit_in_bytes; done
536870912
536870912
536870912
536870912
536870912
536870912
536870912
536870912
536870912
536870912
536870912
536870912

$ for ((i=0; i<12; i++)); do cat /path/$i/memory.soft_limit_in_bytes; done
0
0
0
0
0
0
536870912
536870912
536870912
536870912
536870912
536870912

$ for ((i=0; i<12; i++)); do cat /path/$i/memory.vmscan_stat; done
total_scanned_file_pages_by_system_under_hierarchy 1992169
total_scanned_file_pages_by_system_under_hierarchy 2065410
total_scanned_file_pages_by_system_under_hierarchy 2056609
total_scanned_file_pages_by_system_under_hierarchy 1974422
total_scanned_file_pages_by_system_under_hierarchy 1835338
total_scanned_file_pages_by_system_under_hierarchy 1729919
total_scanned_file_pages_by_system_under_hierarchy 0
total_scanned_file_pages_by_system_under_hierarchy 0
total_scanned_file_pages_by_system_under_hierarchy 0
total_scanned_file_pages_by_system_under_hierarchy 0
total_scanned_file_pages_by_system_under_hierarchy 0
total_scanned_file_pages_by_system_under_hierarchy 0

Note:
1.The vmscan_stat API was reverted upstream, and I am not asking for inclusion
here. The only reason to have it here is to demonstrate the result of the
softlimit reclaim patchset.
2.The patch is based on next-20111201

Ying Han (3):
  memcg: rework softlimit reclaim
  memcg: revert current soft limit reclaim implementation
  memcg: track reclaim stats in memory.vmscan_stat

 include/linux/memcontrol.h |   36 ++-
 include/linux/swap.h       |    4 -
 kernel/res_counter.c       |    1 -
 mm/memcontrol.c            |  541 +++++++++++++-------------------------------
 mm/vmscan.c                |  116 ++++------
 5 files changed, 233 insertions(+), 465 deletions(-)

-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
