Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1DD406B00CD
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 10:43:03 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 3/8] mm: memcg: clean up fault accounting
Date: Wed, 23 Nov 2011 16:42:26 +0100
Message-Id: <1322062951-1756-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1322062951-1756-1-git-send-email-hannes@cmpxchg.org>
References: <1322062951-1756-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Johannes Weiner <jweiner@redhat.com>

The fault accounting functions have a single, memcg-internal user, so
they don't need to be global.  In fact, their one-line bodies can be
directly folded into the caller.  And since faults happen one at a
time, use this_cpu_inc() directly instead of this_cpu_add(foo, 1).

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
---
 mm/memcontrol.c |   14 ++------------
 1 files changed, 2 insertions(+), 12 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 473b99f..d825af9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -589,16 +589,6 @@ static void mem_cgroup_swap_statistics(struct mem_cgroup *memcg,
 	this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_SWAPOUT], val);
 }
 
-void mem_cgroup_pgfault(struct mem_cgroup *memcg, int val)
-{
-	this_cpu_add(memcg->stat->events[MEM_CGROUP_EVENTS_PGFAULT], val);
-}
-
-void mem_cgroup_pgmajfault(struct mem_cgroup *memcg, int val)
-{
-	this_cpu_add(memcg->stat->events[MEM_CGROUP_EVENTS_PGMAJFAULT], val);
-}
-
 static unsigned long mem_cgroup_read_events(struct mem_cgroup *memcg,
 					    enum mem_cgroup_events_index idx)
 {
@@ -913,10 +903,10 @@ void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
 
 	switch (idx) {
 	case PGMAJFAULT:
-		mem_cgroup_pgmajfault(memcg, 1);
+		this_cpu_inc(memcg->stat->events[MEM_CGROUP_EVENTS_PGFAULT]);
 		break;
 	case PGFAULT:
-		mem_cgroup_pgfault(memcg, 1);
+		this_cpu_inc(memcg->stat->events[MEM_CGROUP_EVENTS_PGMAJFAULT]);
 		break;
 	default:
 		BUG();
-- 
1.7.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
