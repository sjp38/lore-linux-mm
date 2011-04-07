Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5DD4F8D003B
	for <linux-mm@kvack.org>; Thu,  7 Apr 2011 02:40:14 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [RFC no patch yet] memcg: revisit soft_limit reclaim on contention
Date: Wed,  6 Apr 2011 23:39:20 -0700
Message-Id: <1302158360-8382-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org

This is to follow-up the proposal on improving current soft_limit reclaim after
the LSF this year. Before start prototyping, I would like to summarize the
problems we've observed and the new design in some details.

What is "soft_limit"?
The "soft_limit was introduced in memcg to support over-committing the memory
resource on the host. Each cgroup can be configured with "hard_limit", where it
will be throttled or OOM killed by going over the limit. However, the allocation
can go above the "soft_limit" as long as there is no memory contention. The
"soft_limit" is the kernel mechanism for re-distributing spare memory resource
among cgroups.

What is the problem?
Right now, the softlimit reclaim happens at global background reclaim, and acts
as best-effort before the global LRU scanning. However the global LRU reclaim
breaks the isolation badly and we need to eliminate the double LRU at the end.
Moving towards that direction, the first step is to have efficient targeting
reclaim.

What we have now?
The current implementation of softlimit is based on per-zone RB tree, where only
the cgroup exceeds the soft_limit the most being selected for reclaim.
1. It takes no consideration of how many pages actually allocated on the zone
from this cgroup. The RB tree is indexed by the cgroup_(usage - soft_limit).
2. It makes less sense to only reclaim from one cgroup rather than reclaiming
all cgroups based on calculated propotion. This is required for fairness.
3. The target of the soft limit reclaim is to bring one cgroup's usage under its
soft_limit. However the target of global memory pressure is to reclaim pages
above the zone's high_wmark.

So the current softlimit reclaim is far from fulfilling the efficiency
requirement. The following design is based on the discussion on LSF mm session
and hallway talks with Rik, Michal and Kamezawa.

Proposed design:
1. softlimit reclaim is triggered under global memory pressure, both at
background and direct reclaim.
2. the target of the softlimit reclaim is consistent with global reclaim where
we check the zone's watermarks instead.
3. round-robin across the cgroups where they have memory allocated on the zone
and also exceed the softlimit configured.
4. the change should be a noop where memcg is not configured.
5. be able to have the ability of zone balance w/o the global LRU reclaim.

More details:
Build per-zone memcg list which links mem_cgroup_per_zone for all memcgs
exceeded their soft_limit and have memory allocated on the zone.
1. new cgroup is examed and inserted once per 1024 increments of
mem_cgroup_commit_charge().
2. under global memory pressure, we iterate the list and try to reclaim a target
number of pages from each cgroup.
3. the target number is per-cgroup and is calculated based on per-memcg lru
fraction and soft_limit exceeds. We could borrow the existing get_scan_count()
but adding the soft_limit factor on top of that.
4. move the cgroup to the tail if the target number of pages being reclaimed.
5. remove the cgroup from the list if the usage dropped below the soft_limit.
6. after reclaiming from each cgroup, check the zone watermark. If the free pages
goes above the high_wmark + balance_gap, break the reclaim loop.
7. reclaim strategies should be consistent w/ global reclaim. for example, we want
to scan each cgroup's file-lru first and then the anon-lru for the next iteration.

And more:
1. there was a question on how to do zone balancing w/o global LRU. This could be
solved by building another cgroup list per-zone, where we also link cgroups under
their soft_limit. We won't scan the list unless the first list being exhausted and
the free pages is still under the high_wmark.
2. the soft limit does not support high order reclaim, which means it won't have
lumpy reclaim. it is ok with memory compaction enabled.
3. one of the tricky part is to calculate the target nr_to_scan for each cgroup,
especially combining the current heuristics with soft_limit exceeds. it depends how
much weight we need to put on the second. One way is to make the ratio to be user
configurable.

Action Items:
0. revert some of the changes in current soft_limit reclaim
1. implement the softlimit reclaim described above
2. add the soft_limit reclaim into global direct reclaim
3. eliminate the global lru and remove the lru field in page_cgroup
4. separate out the zone->lru lock and make a per-memcg-per-zone lock

Thank you for reading.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
