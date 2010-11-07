Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id BD5B66B0087
	for <linux-mm@kvack.org>; Sun,  7 Nov 2010 17:15:10 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 3/4] memcg: break out event counters from other stats
Date: Sun,  7 Nov 2010 23:14:38 +0100
Message-Id: <20101107220353.684449249@cmpxchg.org>
In-Reply-To: <20101107215030.007259800@cmpxchg.org>
References: <20101107215030.007259800@cmpxchg.org>
References: <1288973333-7891-1-git-send-email-minchan.kim@gmail.com> <20101106010357.GD23393@cmpxchg.org> <AANLkTin9m65JVKRuStZ1-qhU5_1AY-GcbBRC0TodsfYC@mail.gmail.com> <20101107215030.007259800@cmpxchg.org>
Content-Disposition: inline; filename=memcg-break-out-event-counters-from-other-stats.patch
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Young <hidave.darkstar@gmail.com>, Andrea Righi <arighi@develer.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

For increasing and decreasing per-cpu cgroup usage counters it makes
sense to use signed types, as single per-cpu values might go negative
during updates.  But this is not the case for only-ever-increasing
event counters.

All the counters have been signed 64-bit so far, which was enough to
count events even with the sign bit wasted.

The next patch narrows the usage counters type (on 32-bit CPUs, that
is), though, so break out the event counters and make them unsigned
words as they should have been from the start.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c |   49 +++++++++++++++++++++++++++++++++++++------------
 1 file changed, 37 insertions(+), 12 deletions(-)

--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -85,21 +85,23 @@ enum mem_cgroup_stat_index {
 	 */
 	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
 	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
-	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
-	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
 	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
 	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
 	MEM_CGROUP_STAT_FILE_DIRTY,	/* # of dirty pages in page cache */
 	MEM_CGROUP_STAT_FILE_WRITEBACK,		/* # of pages under writeback */
 	MEM_CGROUP_STAT_FILE_UNSTABLE_NFS,	/* # of NFS unstable pages */
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
 enum {
 	MEM_CGROUP_DIRTY_RATIO,
 	MEM_CGROUP_DIRTY_LIMIT_IN_BYTES,
@@ -109,6 +111,7 @@ enum {
 
 struct mem_cgroup_stat_cpu {
 	s64 count[MEM_CGROUP_STAT_NSTATS];
+	unsigned long events[MEM_CGROUP_EVENTS_NSTATS];
 };
 
 /*
@@ -612,6 +615,22 @@ static void mem_cgroup_swap_statistics(s
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
 					 struct page_cgroup *pc,
 					 bool charge)
@@ -626,10 +645,10 @@ static void mem_cgroup_charge_statistics
 		__this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_RSS], val);
 
 	if (charge)
-		__this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_PGPGIN_COUNT]);
+		__this_cpu_inc(mem->stat->events[MEM_CGROUP_EVENTS_PGPGIN]);
 	else
-		__this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_PGPGOUT_COUNT]);
-	__this_cpu_inc(mem->stat->count[MEM_CGROUP_EVENTS]);
+		__this_cpu_inc(mem->stat->events[MEM_CGROUP_EVENTS_PGPGOUT]);
+	__this_cpu_inc(mem->stat->events[MEM_CGROUP_EVENTS_COUNT]);
 
 	preempt_enable();
 }
@@ -651,9 +670,9 @@ static unsigned long mem_cgroup_get_loca
 
 static bool __memcg_event_check(struct mem_cgroup *mem, int event_mask_shift)
 {
-	s64 val;
+	unsigned long val;
 
-	val = this_cpu_read(mem->stat->count[MEM_CGROUP_EVENTS]);
+	val = this_cpu_read(mem->stat->events[MEM_CGROUP_EVENTS_COUNT]);
 
 	return !(val & ((1 << event_mask_shift) - 1));
 }
@@ -2055,6 +2074,12 @@ static void mem_cgroup_drain_pcp_counter
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
@@ -3892,9 +3917,9 @@ mem_cgroup_get_local_stat(struct mem_cgr
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
