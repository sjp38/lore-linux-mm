Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8524B4403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 08:03:50 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id w123so44876958pfb.0
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 05:03:50 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id g14si16624507pfd.189.2016.02.04.05.03.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Feb 2016 05:03:49 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH 1/3] mm: memcontrol: make tree_{stat,events} fetch all stats
Date: Thu, 4 Feb 2016 16:03:37 +0300
Message-ID: <57ff0330b597738127ae0f9ca331016719bea7d8.1454589800.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Currently, tree_{stat,events} helpers can only get one stat index at a
time, so when there are a lot of stats to be reported one has to call it
over and over again (see memory_stat_show). This is neither effective,
nor does it look good. Instead, let's make these helpers take a snapshot
of all available counters.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 mm/memcontrol.c | 57 +++++++++++++++++++++++++++++++--------------------------
 1 file changed, 31 insertions(+), 26 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f36b20f5b3ed..606dda49e671 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2717,39 +2717,42 @@ static int mem_cgroup_hierarchy_write(struct cgroup_subsys_state *css,
 	return retval;
 }
 
-static unsigned long tree_stat(struct mem_cgroup *memcg,
-			       enum mem_cgroup_stat_index idx)
+static void tree_stat(struct mem_cgroup *memcg, unsigned long *stat)
 {
 	struct mem_cgroup *iter;
-	unsigned long val = 0;
+	int i;
 
-	for_each_mem_cgroup_tree(iter, memcg)
-		val += mem_cgroup_read_stat(iter, idx);
+	memset(stat, 0, sizeof(*stat) * MEMCG_NR_STAT);
 
-	return val;
+	for_each_mem_cgroup_tree(iter, memcg) {
+		for (i = 0; i < MEMCG_NR_STAT; i++)
+			stat[i] += mem_cgroup_read_stat(iter, i);
+	}
 }
 
-static unsigned long tree_events(struct mem_cgroup *memcg,
-				 enum mem_cgroup_events_index idx)
+static void tree_events(struct mem_cgroup *memcg, unsigned long *events)
 {
 	struct mem_cgroup *iter;
-	unsigned long val = 0;
+	int i;
 
-	for_each_mem_cgroup_tree(iter, memcg)
-		val += mem_cgroup_read_events(iter, idx);
+	memset(events, 0, sizeof(*events) * MEMCG_NR_EVENTS);
 
-	return val;
+	for_each_mem_cgroup_tree(iter, memcg) {
+		for (i = 0; i < MEMCG_NR_EVENTS; i++)
+			events[i] += mem_cgroup_read_events(iter, i);
+	}
 }
 
 static unsigned long mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
 {
+	unsigned long stat[MEMCG_NR_STAT];
 	unsigned long val;
 
 	if (mem_cgroup_is_root(memcg)) {
-		val = tree_stat(memcg, MEM_CGROUP_STAT_CACHE);
-		val += tree_stat(memcg, MEM_CGROUP_STAT_RSS);
+		tree_stat(memcg, stat);
+		val = stat[MEM_CGROUP_STAT_CACHE] + stat[MEM_CGROUP_STAT_RSS];
 		if (swap)
-			val += tree_stat(memcg, MEM_CGROUP_STAT_SWAP);
+			val += stat[MEM_CGROUP_STAT_SWAP];
 	} else {
 		if (!swap)
 			val = page_counter_read(&memcg->memory);
@@ -5075,6 +5078,8 @@ static int memory_events_show(struct seq_file *m, void *v)
 static int memory_stat_show(struct seq_file *m, void *v)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+	unsigned long stat[MEMCG_NR_STAT];
+	unsigned long events[MEMCG_NR_EVENTS];
 	int i;
 
 	/*
@@ -5088,22 +5093,22 @@ static int memory_stat_show(struct seq_file *m, void *v)
 	 * Current memory state:
 	 */
 
+	tree_stat(memcg, stat);
+	tree_events(memcg, events);
+
 	seq_printf(m, "anon %llu\n",
-		   (u64)tree_stat(memcg, MEM_CGROUP_STAT_RSS) * PAGE_SIZE);
+		   (u64)stat[MEM_CGROUP_STAT_RSS] * PAGE_SIZE);
 	seq_printf(m, "file %llu\n",
-		   (u64)tree_stat(memcg, MEM_CGROUP_STAT_CACHE) * PAGE_SIZE);
+		   (u64)stat[MEM_CGROUP_STAT_CACHE] * PAGE_SIZE);
 	seq_printf(m, "sock %llu\n",
-		   (u64)tree_stat(memcg, MEMCG_SOCK) * PAGE_SIZE);
+		   (u64)stat[MEMCG_SOCK] * PAGE_SIZE);
 
 	seq_printf(m, "file_mapped %llu\n",
-		   (u64)tree_stat(memcg, MEM_CGROUP_STAT_FILE_MAPPED) *
-		   PAGE_SIZE);
+		   (u64)stat[MEM_CGROUP_STAT_FILE_MAPPED] * PAGE_SIZE);
 	seq_printf(m, "file_dirty %llu\n",
-		   (u64)tree_stat(memcg, MEM_CGROUP_STAT_DIRTY) *
-		   PAGE_SIZE);
+		   (u64)stat[MEM_CGROUP_STAT_DIRTY] * PAGE_SIZE);
 	seq_printf(m, "file_writeback %llu\n",
-		   (u64)tree_stat(memcg, MEM_CGROUP_STAT_WRITEBACK) *
-		   PAGE_SIZE);
+		   (u64)stat[MEM_CGROUP_STAT_WRITEBACK] * PAGE_SIZE);
 
 	for (i = 0; i < NR_LRU_LISTS; i++) {
 		struct mem_cgroup *mi;
@@ -5118,9 +5123,9 @@ static int memory_stat_show(struct seq_file *m, void *v)
 	/* Accumulated memory events */
 
 	seq_printf(m, "pgfault %lu\n",
-		   tree_events(memcg, MEM_CGROUP_EVENTS_PGFAULT));
+		   events[MEM_CGROUP_EVENTS_PGFAULT]);
 	seq_printf(m, "pgmajfault %lu\n",
-		   tree_events(memcg, MEM_CGROUP_EVENTS_PGMAJFAULT));
+		   events[MEM_CGROUP_EVENTS_PGMAJFAULT]);
 
 	return 0;
 }
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
