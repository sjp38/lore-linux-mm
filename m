Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 684E4900138
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 02:51:26 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH] memcg: remove unneeded preempt_disable
Date: Wed, 17 Aug 2011 23:50:53 -0700
Message-Id: <1313650253-21794-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Greg Thelen <gthelen@google.com>

Both mem_cgroup_charge_statistics() and mem_cgroup_move_account() were
unnecessarily disabling preemption when adjusting per-cpu counters:
    preempt_disable()
    __this_cpu_xxx()
    __this_cpu_yyy()
    preempt_enable()

This change does not disable preemption and thus CPU switch is possible
within these routines.  This does not cause a problem because the total
of all cpu counters is summed when reporting stats.  Now both
mem_cgroup_charge_statistics() and mem_cgroup_move_account() look like:
    this_cpu_xxx()
    this_cpu_yyy()

Reported-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Greg Thelen <gthelen@google.com>
---
 mm/memcontrol.c |   20 +++++++-------------
 1 files changed, 7 insertions(+), 13 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c6faa32..048b205 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -664,24 +664,20 @@ static unsigned long mem_cgroup_read_events(struct mem_cgroup *mem,
 static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
 					 bool file, int nr_pages)
 {
-	preempt_disable();
-
 	if (file)
-		__this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_CACHE], nr_pages);
+		this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_CACHE], nr_pages);
 	else
-		__this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_RSS], nr_pages);
+		this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_RSS], nr_pages);
 
 	/* pagein of a big page is an event. So, ignore page size */
 	if (nr_pages > 0)
-		__this_cpu_inc(mem->stat->events[MEM_CGROUP_EVENTS_PGPGIN]);
+		this_cpu_inc(mem->stat->events[MEM_CGROUP_EVENTS_PGPGIN]);
 	else {
-		__this_cpu_inc(mem->stat->events[MEM_CGROUP_EVENTS_PGPGOUT]);
+		this_cpu_inc(mem->stat->events[MEM_CGROUP_EVENTS_PGPGOUT]);
 		nr_pages = -nr_pages; /* for event */
 	}
 
-	__this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_COUNT], nr_pages);
-
-	preempt_enable();
+	this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_COUNT], nr_pages);
 }
 
 unsigned long
@@ -2713,10 +2709,8 @@ static int mem_cgroup_move_account(struct page *page,
 
 	if (PageCgroupFileMapped(pc)) {
 		/* Update mapped_file data for mem_cgroup */
-		preempt_disable();
-		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
-		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
-		preempt_enable();
+		this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
+		this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
 	}
 	mem_cgroup_charge_statistics(from, PageCgroupCache(pc), -nr_pages);
 	if (uncharge)
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
