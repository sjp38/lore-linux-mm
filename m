Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 428276B00F0
	for <linux-mm@kvack.org>; Mon, 14 May 2012 14:01:05 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 6/6] mm: memcg: print statistics from live counters
Date: Mon, 14 May 2012 20:00:51 +0200
Message-Id: <1337018451-27359-7-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1337018451-27359-1-git-send-email-hannes@cmpxchg.org>
References: <1337018451-27359-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Directly print statistics and event counters instead of going through
an intermediate accumulation stage into a separate array, which used
to require defining statistic items in more than one place.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c |  173 +++++++++++++++++++++----------------------------------
 1 file changed, 66 insertions(+), 107 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3ee63f6..b0d343a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -102,6 +102,14 @@ enum mem_cgroup_stat_index {
 	MEM_CGROUP_STAT_NSTATS,
 };
 
+static const char *mem_cgroup_stat_names[] = {
+	"cache",
+	"rss",
+	"mapped_file",
+	"mlock",
+	"swap",
+};
+
 enum mem_cgroup_events_index {
 	MEM_CGROUP_EVENTS_PGPGIN,	/* # of pages paged in */
 	MEM_CGROUP_EVENTS_PGPGOUT,	/* # of pages paged out */
@@ -109,6 +117,14 @@ enum mem_cgroup_events_index {
 	MEM_CGROUP_EVENTS_PGMAJFAULT,	/* # of major page-faults */
 	MEM_CGROUP_EVENTS_NSTATS,
 };
+
+static const char *mem_cgroup_events_names[] = {
+	"pgpgin",
+	"pgpgout",
+	"pgfault",
+	"pgmajfault",
+};
+
 /*
  * Per memcg event counter is incremented at every pagein/pageout. With THP,
  * it will be incremated by the number of pages. This counter is used for
@@ -4250,97 +4266,6 @@ static int mem_cgroup_move_charge_write(struct cgroup *cgrp,
 }
 #endif
 
-
-/* For read statistics */
-enum {
-	MCS_CACHE,
-	MCS_RSS,
-	MCS_FILE_MAPPED,
-	MCS_MLOCK,
-	MCS_SWAP,
-	MCS_PGPGIN,
-	MCS_PGPGOUT,
-	MCS_PGFAULT,
-	MCS_PGMAJFAULT,
-	MCS_INACTIVE_ANON,
-	MCS_ACTIVE_ANON,
-	MCS_INACTIVE_FILE,
-	MCS_ACTIVE_FILE,
-	MCS_UNEVICTABLE,
-	NR_MCS_STAT,
-};
-
-struct mcs_total_stat {
-	s64 stat[NR_MCS_STAT];
-};
-
-static const char *memcg_stat_strings[NR_MCS_STAT] = {
-	"cache",
-	"rss",
-	"mapped_file",
-	"mlock",
-	"swap",
-	"pgpgin",
-	"pgpgout",
-	"pgfault",
-	"pgmajfault",
-	"inactive_anon",
-	"active_anon",
-	"inactive_file",
-	"active_file",
-	"unevictable",
-};
-
-
-static void
-mem_cgroup_get_local_stat(struct mem_cgroup *memcg, struct mcs_total_stat *s)
-{
-	s64 val;
-
-	/* per cpu stat */
-	val = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_CACHE);
-	s->stat[MCS_CACHE] += val * PAGE_SIZE;
-	val = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_RSS);
-	s->stat[MCS_RSS] += val * PAGE_SIZE;
-	val = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_FILE_MAPPED);
-	s->stat[MCS_FILE_MAPPED] += val * PAGE_SIZE;
-	val = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_MLOCK);
-	s->stat[MCS_MLOCK] += val * PAGE_SIZE;
-	if (do_swap_account) {
-		val = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_SWAPOUT);
-		s->stat[MCS_SWAP] += val * PAGE_SIZE;
-	}
-	val = mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_PGPGIN);
-	s->stat[MCS_PGPGIN] += val;
-	val = mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_PGPGOUT);
-	s->stat[MCS_PGPGOUT] += val;
-	val = mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_PGFAULT);
-	s->stat[MCS_PGFAULT] += val;
-	val = mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_PGMAJFAULT);
-	s->stat[MCS_PGMAJFAULT] += val;
-
-	/* per zone stat */
-	val = mem_cgroup_nr_lru_pages(memcg, BIT(LRU_INACTIVE_ANON));
-	s->stat[MCS_INACTIVE_ANON] += val * PAGE_SIZE;
-	val = mem_cgroup_nr_lru_pages(memcg, BIT(LRU_ACTIVE_ANON));
-	s->stat[MCS_ACTIVE_ANON] += val * PAGE_SIZE;
-	val = mem_cgroup_nr_lru_pages(memcg, BIT(LRU_INACTIVE_FILE));
-	s->stat[MCS_INACTIVE_FILE] += val * PAGE_SIZE;
-	val = mem_cgroup_nr_lru_pages(memcg, BIT(LRU_ACTIVE_FILE));
-	s->stat[MCS_ACTIVE_FILE] += val * PAGE_SIZE;
-	val = mem_cgroup_nr_lru_pages(memcg, BIT(LRU_UNEVICTABLE));
-	s->stat[MCS_UNEVICTABLE] += val * PAGE_SIZE;
-}
-
-static void
-mem_cgroup_get_total_stat(struct mem_cgroup *memcg, struct mcs_total_stat *s)
-{
-	struct mem_cgroup *iter;
-
-	for_each_mem_cgroup_tree(iter, memcg)
-		mem_cgroup_get_local_stat(iter, s);
-}
-
 #ifdef CONFIG_NUMA
 static int mem_control_numa_stat_show(struct cgroup *cont, struct cftype *cft,
 				      struct seq_file *m)
@@ -4388,24 +4313,40 @@ static int mem_control_numa_stat_show(struct cgroup *cont, struct cftype *cft,
 }
 #endif /* CONFIG_NUMA */
 
+static const char *mem_cgroup_lru_names[] = {
+	"inactive_anon",
+	"active_anon",
+	"inactive_file",
+	"active_file",
+	"unevictable",
+};
+static inline void mem_cgroup_lru_names_not_uptodate(void)
+{
+	BUILD_BUG_ON(ARRAY_SIZE(mem_cgroup_lru_names) != NR_LRU_LISTS);
+}
+
 static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
 				 struct seq_file *m)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
-	struct mcs_total_stat mystat;
-	int i;
-
-	memset(&mystat, 0, sizeof(mystat));
-	mem_cgroup_get_local_stat(memcg, &mystat);
+	struct mem_cgroup *mi;
+	unsigned int i;
 
-
-	for (i = 0; i < NR_MCS_STAT; i++) {
-		if (i == MCS_SWAP && !do_swap_account)
+	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
+		if (i == MEM_CGROUP_STAT_SWAPOUT && !do_swap_account)
 			continue;
-		seq_printf(m, "%s %llu\n", memcg_stat_strings[i],
-			   (unsigned long long)mystat.stat[i]);
+		seq_printf(m, "%s %ld\n", mem_cgroup_stat_names[i],
+			   mem_cgroup_read_stat(memcg, i) * PAGE_SIZE);
 	}
 
+	for (i = 0; i < MEM_CGROUP_EVENTS_NSTATS; i++)
+		seq_printf(m, "%s %lu\n", mem_cgroup_events_names[i],
+			   mem_cgroup_read_events(memcg, i));
+
+	for (i = 0; i < NR_LRU_LISTS; i++)
+		seq_printf(m, "%s %lu\n", mem_cgroup_lru_names[i],
+			   mem_cgroup_nr_lru_pages(memcg, BIT(i)) * PAGE_SIZE);
+
 	/* Hierarchical information */
 	{
 		unsigned long long limit, memsw_limit;
@@ -4416,13 +4357,31 @@ static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
 				   memsw_limit);
 	}
 
-	memset(&mystat, 0, sizeof(mystat));
-	mem_cgroup_get_total_stat(memcg, &mystat);
-	for (i = 0; i < NR_MCS_STAT; i++) {
-		if (i == MCS_SWAP && !do_swap_account)
+	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
+		long long val = 0;
+
+		if (i == MEM_CGROUP_STAT_SWAPOUT && !do_swap_account)
 			continue;
-		seq_printf(m, "total_%s %llu\n", memcg_stat_strings[i],
-			   (unsigned long long)mystat.stat[i]);
+		for_each_mem_cgroup_tree(mi, memcg)
+			val += mem_cgroup_read_stat(mi, i) * PAGE_SIZE;
+		seq_printf(m, "total_%s %lld\n", mem_cgroup_stat_names[i], val);
+	}
+
+	for (i = 0; i < MEM_CGROUP_EVENTS_NSTATS; i++) {
+		unsigned long long val = 0;
+
+		for_each_mem_cgroup_tree(mi, memcg)
+			val += mem_cgroup_read_events(mi, i);
+		seq_printf(m, "total_%s %llu\n",
+			   mem_cgroup_events_names[i], val);
+	}
+
+	for (i = 0; i < NR_LRU_LISTS; i++) {
+		unsigned long long val = 0;
+
+		for_each_mem_cgroup_tree(mi, memcg)
+			val += mem_cgroup_nr_lru_pages(mi, BIT(i)) * PAGE_SIZE;
+		seq_printf(m, "total_%s %llu\n", mem_cgroup_lru_names[i], val);
 	}
 
 #ifdef CONFIG_DEBUG_VM
-- 
1.7.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
