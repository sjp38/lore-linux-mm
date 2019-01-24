Return-Path: <linux-kernel-owner@vger.kernel.org>
Date: Thu, 24 Jan 2019 14:40:50 -0500
From: Chris Down <chris@chrisdown.name>
Subject: [PATCH 1/2] mm: Create mem_cgroup_from_seq
Message-ID: <20190124194050.GA31341@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com
List-ID: <linux-mm.kvack.org>

This is the start of a series of patches similar to my earlier
DEFINE_MEMCG_MAX_OR_VAL work, but with less Macro Magic(tm).

There are a bunch of places we go from seq_file to mem_cgroup, which
currently requires manually getting the css, then getting the mem_cgroup
from the css. It's in enough places now that having mem_cgroup_from_seq
makes sense (and also makes the next patch a bit nicer).

Signed-off-by: Chris Down <chris@chrisdown.name>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Roman Gushchin <guro@fb.com>
Cc: linux-kernel@vger.kernel.org
Cc: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: kernel-team@fb.com
---
 include/linux/memcontrol.h | 10 ++++++++++
 mm/memcontrol.c            | 24 ++++++++++++------------
 mm/slab_common.c           |  6 +++---
 3 files changed, 25 insertions(+), 15 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index b0eb29ea0d9c..1f3d880b7ca1 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -429,6 +429,11 @@ static inline unsigned short mem_cgroup_id(struct mem_cgroup *memcg)
 }
 struct mem_cgroup *mem_cgroup_from_id(unsigned short id);
 
+static inline struct mem_cgroup *mem_cgroup_from_seq(struct seq_file *m)
+{
+	return mem_cgroup_from_css(seq_css(m));
+}
+
 static inline struct mem_cgroup *lruvec_memcg(struct lruvec *lruvec)
 {
 	struct mem_cgroup_per_node *mz;
@@ -937,6 +942,11 @@ static inline struct mem_cgroup *mem_cgroup_from_id(unsigned short id)
 	return NULL;
 }
 
+static inline struct mem_cgroup *mem_cgroup_from_seq(struct seq_file *m)
+{
+	return NULL;
+}
+
 static inline struct mem_cgroup *lruvec_memcg(struct lruvec *lruvec)
 {
 	return NULL;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 18f4aefbe0bf..98aad31f5226 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3359,7 +3359,7 @@ static int memcg_numa_stat_show(struct seq_file *m, void *v)
 	const struct numa_stat *stat;
 	int nid;
 	unsigned long nr;
-	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+	struct mem_cgroup *memcg = mem_cgroup_from_seq(m);
 
 	for (stat = stats; stat < stats + ARRAY_SIZE(stats); stat++) {
 		nr = mem_cgroup_nr_lru_pages(memcg, stat->lru_mask);
@@ -3410,7 +3410,7 @@ static const char *const memcg1_event_names[] = {
 
 static int memcg_stat_show(struct seq_file *m, void *v)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+	struct mem_cgroup *memcg = mem_cgroup_from_seq(m);
 	unsigned long memory, memsw;
 	struct mem_cgroup *mi;
 	unsigned int i;
@@ -3842,7 +3842,7 @@ static void mem_cgroup_oom_unregister_event(struct mem_cgroup *memcg,
 
 static int mem_cgroup_oom_control_read(struct seq_file *sf, void *v)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(sf));
+	struct mem_cgroup *memcg = mem_cgroup_from_seq(sf);
 
 	seq_printf(sf, "oom_kill_disable %d\n", memcg->oom_kill_disable);
 	seq_printf(sf, "under_oom %d\n", (bool)memcg->under_oom);
@@ -5385,7 +5385,7 @@ static u64 memory_current_read(struct cgroup_subsys_state *css,
 
 static int memory_min_show(struct seq_file *m, void *v)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+	struct mem_cgroup *memcg = mem_cgroup_from_seq(m);
 	unsigned long min = READ_ONCE(memcg->memory.min);
 
 	if (min == PAGE_COUNTER_MAX)
@@ -5415,7 +5415,7 @@ static ssize_t memory_min_write(struct kernfs_open_file *of,
 
 static int memory_low_show(struct seq_file *m, void *v)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+	struct mem_cgroup *memcg = mem_cgroup_from_seq(m);
 	unsigned long low = READ_ONCE(memcg->memory.low);
 
 	if (low == PAGE_COUNTER_MAX)
@@ -5445,7 +5445,7 @@ static ssize_t memory_low_write(struct kernfs_open_file *of,
 
 static int memory_high_show(struct seq_file *m, void *v)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+	struct mem_cgroup *memcg = mem_cgroup_from_seq(m);
 	unsigned long high = READ_ONCE(memcg->high);
 
 	if (high == PAGE_COUNTER_MAX)
@@ -5482,7 +5482,7 @@ static ssize_t memory_high_write(struct kernfs_open_file *of,
 
 static int memory_max_show(struct seq_file *m, void *v)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+	struct mem_cgroup *memcg = mem_cgroup_from_seq(m);
 	unsigned long max = READ_ONCE(memcg->memory.max);
 
 	if (max == PAGE_COUNTER_MAX)
@@ -5544,7 +5544,7 @@ static ssize_t memory_max_write(struct kernfs_open_file *of,
 
 static int memory_events_show(struct seq_file *m, void *v)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+	struct mem_cgroup *memcg = mem_cgroup_from_seq(m);
 
 	seq_printf(m, "low %lu\n",
 		   atomic_long_read(&memcg->memory_events[MEMCG_LOW]));
@@ -5562,7 +5562,7 @@ static int memory_events_show(struct seq_file *m, void *v)
 
 static int memory_stat_show(struct seq_file *m, void *v)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+	struct mem_cgroup *memcg = mem_cgroup_from_seq(m);
 	struct accumulated_stats acc;
 	int i;
 
@@ -5639,7 +5639,7 @@ static int memory_stat_show(struct seq_file *m, void *v)
 
 static int memory_oom_group_show(struct seq_file *m, void *v)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+	struct mem_cgroup *memcg = mem_cgroup_from_seq(m);
 
 	seq_printf(m, "%d\n", memcg->oom_group);
 
@@ -6622,7 +6622,7 @@ static u64 swap_current_read(struct cgroup_subsys_state *css,
 
 static int swap_max_show(struct seq_file *m, void *v)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+	struct mem_cgroup *memcg = mem_cgroup_from_seq(m);
 	unsigned long max = READ_ONCE(memcg->swap.max);
 
 	if (max == PAGE_COUNTER_MAX)
@@ -6652,7 +6652,7 @@ static ssize_t swap_max_write(struct kernfs_open_file *of,
 
 static int swap_events_show(struct seq_file *m, void *v)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+	struct mem_cgroup *memcg = mem_cgroup_from_seq(m);
 
 	seq_printf(m, "max %lu\n",
 		   atomic_long_read(&memcg->memory_events[MEMCG_SWAP_MAX]));
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 81732d05e74a..3dfdbe49ce34 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1424,7 +1424,7 @@ void dump_unreclaimable_slab(void)
 #if defined(CONFIG_MEMCG)
 void *memcg_slab_start(struct seq_file *m, loff_t *pos)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+	struct mem_cgroup *memcg = mem_cgroup_from_seq(m);
 
 	mutex_lock(&slab_mutex);
 	return seq_list_start(&memcg->kmem_caches, *pos);
@@ -1432,7 +1432,7 @@ void *memcg_slab_start(struct seq_file *m, loff_t *pos)
 
 void *memcg_slab_next(struct seq_file *m, void *p, loff_t *pos)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+	struct mem_cgroup *memcg = mem_cgroup_from_seq(m);
 
 	return seq_list_next(p, &memcg->kmem_caches, pos);
 }
@@ -1446,7 +1446,7 @@ int memcg_slab_show(struct seq_file *m, void *p)
 {
 	struct kmem_cache *s = list_entry(p, struct kmem_cache,
 					  memcg_params.kmem_caches_node);
-	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+	struct mem_cgroup *memcg = mem_cgroup_from_seq(m);
 
 	if (p == memcg->kmem_caches.next)
 		print_slabinfo_header(m);
-- 
2.20.1
