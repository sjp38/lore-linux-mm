Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id ACE1E8D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 15:53:17 -0500 (EST)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH v3 1/2] memcg: break out event counters from other stats
Date: Thu, 17 Feb 2011 12:52:47 -0800
Message-Id: <1297975968-19672-2-git-send-email-gthelen@google.com>
In-Reply-To: <1297975968-19672-1-git-send-email-gthelen@google.com>
References: <1297975968-19672-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>

From: Johannes Weiner <hannes@cmpxchg.org>

For increasing and decreasing per-cpu cgroup usage counters it makes
sense to use signed types, as single per-cpu values might go negative
during updates.  But this is not the case for only-ever-increasing
event counters.

All the counters have been signed 64-bit so far, which was enough to
count events even with the sign bit wasted.

This patch:
- divides s64 counters into signed usage counters and unsigned
  monotonically increasing event counters.
- converts unsigned event counters into 'unsigned long' rather than
  'u64'.  This matches the type used by the /proc/vmstat event counters.

The next patch narrows the signed usage counters type (on 32-bit CPUs,
that is).

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Greg Thelen <gthelen@google.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---
Changelog since v2:
- Reworded commit message.

 mm/memcontrol.c |   49 +++++++++++++++++++++++++++++++++++++------------
 1 files changed, 37 insertions(+), 12 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b7e3379..a11ff1e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -93,19 +93,22 @@ enum mem_cgroup_stat_index {
 	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
 	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
 	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
-	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
-	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
 	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
 	MEM_CGROUP_STAT_DATA, /* end of data requires synchronization */
-	/* incremented at every  pagein/pageout */
-	MEM_CGROUP_EVENTS = MEM_CGROUP_STAT_DATA,
 	MEM_CGROUP_ON_MOVE,	/* someone is moving account between groups */
-
 	MEM_CGROUP_STAT_NSTATS,
 };
 
+enum mem_cgroup_events_index {
+	MEM_CGROUP_EVENTS_PGPGIN,	/* # of pages paged in */
+	MEM_CGROUP_EVENTS_PGPGOUT,	/* # of pages paged out */
+	MEM_CGROUP_EVENTS_COUNT,	/* # of pages paged in/out */
+	MEM_CGROUP_EVENTS_NSTATS,
+};
+
 struct mem_cgroup_stat_cpu {
 	s64 count[MEM_CGROUP_STAT_NSTATS];
+	unsigned long events[MEM_CGROUP_EVENTS_NSTATS];
 };
 
 /*
@@ -577,6 +580,22 @@ static void mem_cgroup_swap_statistics(struct mem_cgroup *mem,
 	this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_SWAPOUT], val);
 }
 
+static unsigned long mem_cgroup_read_events(struct mem_cgroup *mem,
+					    enum mem_cgroup_events_index idx)
+{
+	unsigned long val = 0;
+	int cpu;
+
+	for_each_online_cpu(cpu)
+		val += per_cpu(mem->stat->events[idx], cpu);
+#ifdef CONFIG_HOTPLUG_CPU
+	spin_lock(&mem->pcp_counter_lock);
+	val += mem->nocpu_base.events[idx];
+	spin_unlock(&mem->pcp_counter_lock);
+#endif
+	return val;
+}
+
 static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
 					 bool file, int nr_pages)
 {
@@ -589,13 +608,13 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
 
 	/* pagein of a big page is an event. So, ignore page size */
 	if (nr_pages > 0)
-		__this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_PGPGIN_COUNT]);
+		__this_cpu_inc(mem->stat->events[MEM_CGROUP_EVENTS_PGPGIN]);
 	else {
-		__this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_PGPGOUT_COUNT]);
+		__this_cpu_inc(mem->stat->events[MEM_CGROUP_EVENTS_PGPGOUT]);
 		nr_pages = -nr_pages; /* for event */
 	}
 
-	__this_cpu_add(mem->stat->count[MEM_CGROUP_EVENTS], nr_pages);
+	__this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_COUNT], nr_pages);
 
 	preempt_enable();
 }
@@ -617,9 +636,9 @@ static unsigned long mem_cgroup_get_local_zonestat(struct mem_cgroup *mem,
 
 static bool __memcg_event_check(struct mem_cgroup *mem, int event_mask_shift)
 {
-	s64 val;
+	unsigned long val;
 
-	val = this_cpu_read(mem->stat->count[MEM_CGROUP_EVENTS]);
+	val = this_cpu_read(mem->stat->events[MEM_CGROUP_EVENTS_COUNT]);
 
 	return !(val & ((1 << event_mask_shift) - 1));
 }
@@ -1747,6 +1766,12 @@ static void mem_cgroup_drain_pcp_counter(struct mem_cgroup *mem, int cpu)
 		per_cpu(mem->stat->count[i], cpu) = 0;
 		mem->nocpu_base.count[i] += x;
 	}
+	for (i = 0; i < MEM_CGROUP_EVENTS_NSTATS; i++) {
+		unsigned long x = per_cpu(mem->stat->events[i], cpu);
+
+		per_cpu(mem->stat->events[i], cpu) = 0;
+		mem->nocpu_base.events[i] += x;
+	}
 	/* need to clear ON_MOVE value, works as a kind of lock. */
 	per_cpu(mem->stat->count[MEM_CGROUP_ON_MOVE], cpu) = 0;
 	spin_unlock(&mem->pcp_counter_lock);
@@ -3699,9 +3724,9 @@ mem_cgroup_get_local_stat(struct mem_cgroup *mem, struct mcs_total_stat *s)
 	s->stat[MCS_RSS] += val * PAGE_SIZE;
 	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_FILE_MAPPED);
 	s->stat[MCS_FILE_MAPPED] += val * PAGE_SIZE;
-	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_PGPGIN_COUNT);
+	val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_PGPGIN);
 	s->stat[MCS_PGPGIN] += val;
-	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_PGPGOUT_COUNT);
+	val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_PGPGOUT);
 	s->stat[MCS_PGPGOUT] += val;
 	if (do_swap_account) {
 		val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_SWAPOUT);
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
