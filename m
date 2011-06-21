Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8DDF7900154
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 18:42:18 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [RFC PATCH 3/5] rework softlimit reclaim.
Date: Tue, 21 Jun 2011 15:41:28 -0700
Message-Id: <1308696090-31569-4-git-send-email-yinghan@google.com>
In-Reply-To: <1308696090-31569-1-git-send-email-yinghan@google.com>
References: <1308696090-31569-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Suleiman Souhlal <suleiman@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

The "soft_limit was introduced in memcg to support over-committing the memory
resource on the host. Each cgroup can be configured with "hard_limit", where it
will be throttled or OOM killed by going over the limit. However, the
allocation can go above the "soft_limit" as long as there is no memory
contention.

The current implementation of softlimit reclaim has its disadvantages:
1. It is triggered under global reclaim, and acts as best-effort before the
global LRU scanning.

2. It is based on per-zone RB tree where only the cgroup exceeds the soft_limit
the most being selected for reclaim. In another word, there is no fairness.

3. It takes no consideration of how many pages actually allocated on the zone
from this cgroup.

4. The target of the softlimit reclaim is to bring one cgroup's usage under its
soft_limit, where the global reclaim has different target.

After the "memcg-aware global reclaim" work from Johannes, we have the ability
to have the softlimit reclaim better integrated to the rest of reclaim logics.

Here is how it works now:
1. The soft_limit is integrated into shrink_zone() which is being call from both
targetting and global reclaim. However, we only check soft_limit under global
reclaim.

2. The mem_cgroup_hierarchy_walk() now is integrated inside shrink_zone(). And
the soft_limit works as a filter of which memcgs to reclaim from based on the
reclaim priority.

3. Don't reclaim from a memcg (under its soft_limit) unless the page reclaim is
under trouble. Now we picked DEFAULT_PRIORITY-3 (as mhocko suggested) which
causes scanning on zones(unbalanced) and memcgs(above soft_limit) 3 times before
start looking into other memcgs (under soft_limit).

TODO:
1. The concern is we might end up burning cpu w/o getting much depends how much
low-hanging fruits for the first 3 interation. this is a trade-off of providing
the user expectation of "soft_limit". Runing through more workload and evaluate
the result would be needed.

Signed-off-by: Ying Han <yinghan@google.com>
---
 include/linux/memcontrol.h |    7 +++++++
 mm/memcontrol.c            |    5 +++++
 mm/vmscan.c                |    4 ++++
 3 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index ca5a18d..864c369 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -101,6 +101,7 @@ extern void mem_cgroup_end_migration(struct mem_cgroup *mem,
 struct mem_cgroup *mem_cgroup_hierarchy_walk(struct mem_cgroup *,
 					     struct mem_cgroup *);
 void mem_cgroup_stop_hierarchy_walk(struct mem_cgroup *, struct mem_cgroup *);
+bool mem_cgroup_soft_limit_exceeded(struct mem_cgroup *);
 
 /*
  * For memory reclaim.
@@ -341,6 +342,12 @@ static inline void mem_cgroup_stop_hierarchy_walk(struct mem_cgroup *r,
 {
 }
 
+static inline bool mem_cgroup_soft_limit_exceeded(struct mem_cgroup *root,
+						  struct mem_cgroup *mem)
+{
+	return false;
+}
+
 static inline void
 mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5228039..f2a1892 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1317,6 +1317,11 @@ void mem_cgroup_stop_hierarchy_walk(struct mem_cgroup *root,
 		css_put(&mem->css);
 }
 
+bool mem_cgroup_soft_limit_exceeded(struct mem_cgroup *mem)
+{
+	return res_counter_soft_limit_excess(&mem->res);
+}
+
 static unsigned long mem_cgroup_reclaim(struct mem_cgroup *mem,
 					gfp_t gfp_mask,
 					unsigned long flags)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index d9376d1..85dcdd6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1992,6 +1992,10 @@ static void shrink_zone(int priority, struct zone *zone,
 		unsigned long scanned = sc->nr_scanned;
 		unsigned long nr_reclaimed;
 
+		if (global_reclaim(sc) && priority > DEF_PRIORITY - 3 &&
+			!mem_cgroup_soft_limit_exceeded(mem))
+			continue;
+
 		sc->mem_cgroup = mem;
 		do_shrink_zone(priority, zone, sc);
 		mem_cgroup_count_reclaim(mem, current_is_kswapd(),
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
