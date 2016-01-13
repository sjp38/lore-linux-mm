Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 3E111828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 17:01:50 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id l65so311630379wmf.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 14:01:50 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id i74si41778390wmc.39.2016.01.13.14.01.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 14:01:49 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 1/2] mm: memcontrol: basic memory statistics in cgroup2 memory controller
Date: Wed, 13 Jan 2016 17:01:08 -0500
Message-Id: <1452722469-24704-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1452722469-24704-1-git-send-email-hannes@cmpxchg.org>
References: <1452722469-24704-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Provide a cgroup2 memory.stat that provides statistics on LRU memory
and fault event counters. More consumers and breakdowns will follow.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 57 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 57 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c26ffac..8645852 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2767,6 +2767,18 @@ static unsigned long tree_stat(struct mem_cgroup *memcg,
 	return val;
 }
 
+static unsigned long tree_events(struct mem_cgroup *memcg,
+				 enum mem_cgroup_events_index idx)
+{
+	struct mem_cgroup *iter;
+	unsigned long val = 0;
+
+	for_each_mem_cgroup_tree(iter, memcg)
+		val += mem_cgroup_read_events(iter, idx);
+
+	return val;
+}
+
 static unsigned long mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
 {
 	unsigned long val;
@@ -5095,6 +5107,46 @@ static int memory_events_show(struct seq_file *m, void *v)
 	return 0;
 }
 
+static int memory_stat_show(struct seq_file *m, void *v)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+	int i;
+
+	/* Memory consumer totals */
+
+	seq_printf(m, "anon %lu\n",
+		   tree_stat(memcg, MEM_CGROUP_STAT_RSS) * PAGE_SIZE);
+	seq_printf(m, "file %lu\n",
+		   tree_stat(memcg, MEM_CGROUP_STAT_CACHE) * PAGE_SIZE);
+
+	/* Per-consumer breakdowns */
+
+	for (i = 0; i < NR_LRU_LISTS; i++) {
+		struct mem_cgroup *mi;
+		unsigned long val = 0;
+
+		for_each_mem_cgroup_tree(mi, memcg)
+			val += mem_cgroup_nr_lru_pages(mi, BIT(i)) * PAGE_SIZE;
+		seq_printf(m, "%s %lu\n", mem_cgroup_lru_names[i], val);
+	}
+
+	seq_printf(m, "file_mapped %lu\n",
+		   tree_stat(memcg, MEM_CGROUP_STAT_FILE_MAPPED) * PAGE_SIZE);
+	seq_printf(m, "file_dirty %lu\n",
+		   tree_stat(memcg, MEM_CGROUP_STAT_DIRTY) * PAGE_SIZE);
+	seq_printf(m, "file_writeback %lu\n",
+		   tree_stat(memcg, MEM_CGROUP_STAT_WRITEBACK) * PAGE_SIZE);
+
+	/* Memory management events */
+
+	seq_printf(m, "pgfault %lu\n",
+		   tree_events(memcg, MEM_CGROUP_EVENTS_PGFAULT));
+	seq_printf(m, "pgmajfault %lu\n",
+		   tree_events(memcg, MEM_CGROUP_EVENTS_PGMAJFAULT));
+
+	return 0;
+}
+
 static struct cftype memory_files[] = {
 	{
 		.name = "current",
@@ -5125,6 +5177,11 @@ static struct cftype memory_files[] = {
 		.file_offset = offsetof(struct mem_cgroup, events_file),
 		.seq_show = memory_events_show,
 	},
+	{
+		.name = "stat",
+		.flags = CFTYPE_NOT_ON_ROOT,
+		.seq_show = memory_stat_show,
+	},
 	{ }	/* terminate */
 };
 
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
