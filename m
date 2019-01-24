Return-Path: <linux-kernel-owner@vger.kernel.org>
Date: Thu, 24 Jan 2019 01:17:18 -0500
From: Chris Down <chris@chrisdown.name>
Subject: [PATCH] mm: Move maxable seq_file logic into a single place
Message-ID: <20190124061718.GA15486@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com
List-ID: <linux-mm.kvack.org>

memcg has a significant number of files exposed to kernfs where their
value is either exposed directly or is "max" in the case of
PAGE_COUNTER_MAX.

There's a fair amount of duplicated code here, since each file involves
turning a seq_file to a css, getting the memcg from the css, safely
reading the counter value, and then doing the right thing depending on
whether the value is PAGE_COUNTER_MAX or not.

This patch adds the macro DEFINE_MEMCG_MAX_OR_VAL, which defines and
implements a generic way to do this work, avoiding fragmenting logic.

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
 mm/memcontrol.c | 78 ++++++++++++-------------------------------------
 1 file changed, 18 insertions(+), 60 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 18f4aefbe0bf..90e2e0ff5ed9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -261,6 +261,19 @@ struct cgroup_subsys_state *vmpressure_to_css(struct vmpressure *vmpr)
 	return &container_of(vmpr, struct mem_cgroup, vmpressure)->css;
 }
 
+/* Convenience macro to define seq_file mutators that can return "max" */
+#define DEFINE_MEMCG_MAX_OR_VAL(name, key)				    \
+	static int name(struct seq_file *m, void *v)			    \
+	{								    \
+		struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m)); \
+		unsigned long val = READ_ONCE(memcg->key);		    \
+		if (val == PAGE_COUNTER_MAX)				    \
+			seq_puts(m, "max\n");				    \
+		else							    \
+			seq_printf(m, "%llu\n", (u64)val * PAGE_SIZE);	    \
+		return 0;						    \
+	}
+
 #ifdef CONFIG_MEMCG_KMEM
 /*
  * This will be the memcg's index in each cache's ->memcg_params.memcg_caches.
@@ -5383,18 +5396,7 @@ static u64 memory_current_read(struct cgroup_subsys_state *css,
 	return (u64)page_counter_read(&memcg->memory) * PAGE_SIZE;
 }
 
-static int memory_min_show(struct seq_file *m, void *v)
-{
-	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
-	unsigned long min = READ_ONCE(memcg->memory.min);
-
-	if (min == PAGE_COUNTER_MAX)
-		seq_puts(m, "max\n");
-	else
-		seq_printf(m, "%llu\n", (u64)min * PAGE_SIZE);
-
-	return 0;
-}
+DEFINE_MEMCG_MAX_OR_VAL(memory_min_show, memory.min)
 
 static ssize_t memory_min_write(struct kernfs_open_file *of,
 				char *buf, size_t nbytes, loff_t off)
@@ -5413,18 +5415,7 @@ static ssize_t memory_min_write(struct kernfs_open_file *of,
 	return nbytes;
 }
 
-static int memory_low_show(struct seq_file *m, void *v)
-{
-	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
-	unsigned long low = READ_ONCE(memcg->memory.low);
-
-	if (low == PAGE_COUNTER_MAX)
-		seq_puts(m, "max\n");
-	else
-		seq_printf(m, "%llu\n", (u64)low * PAGE_SIZE);
-
-	return 0;
-}
+DEFINE_MEMCG_MAX_OR_VAL(memory_low_show, memory.low)
 
 static ssize_t memory_low_write(struct kernfs_open_file *of,
 				char *buf, size_t nbytes, loff_t off)
@@ -5443,18 +5434,7 @@ static ssize_t memory_low_write(struct kernfs_open_file *of,
 	return nbytes;
 }
 
-static int memory_high_show(struct seq_file *m, void *v)
-{
-	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
-	unsigned long high = READ_ONCE(memcg->high);
-
-	if (high == PAGE_COUNTER_MAX)
-		seq_puts(m, "max\n");
-	else
-		seq_printf(m, "%llu\n", (u64)high * PAGE_SIZE);
-
-	return 0;
-}
+DEFINE_MEMCG_MAX_OR_VAL(memory_high_show, high)
 
 static ssize_t memory_high_write(struct kernfs_open_file *of,
 				 char *buf, size_t nbytes, loff_t off)
@@ -5480,18 +5460,7 @@ static ssize_t memory_high_write(struct kernfs_open_file *of,
 	return nbytes;
 }
 
-static int memory_max_show(struct seq_file *m, void *v)
-{
-	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
-	unsigned long max = READ_ONCE(memcg->memory.max);
-
-	if (max == PAGE_COUNTER_MAX)
-		seq_puts(m, "max\n");
-	else
-		seq_printf(m, "%llu\n", (u64)max * PAGE_SIZE);
-
-	return 0;
-}
+DEFINE_MEMCG_MAX_OR_VAL(memory_max_show, memory.max)
 
 static ssize_t memory_max_write(struct kernfs_open_file *of,
 				char *buf, size_t nbytes, loff_t off)
@@ -6620,18 +6589,7 @@ static u64 swap_current_read(struct cgroup_subsys_state *css,
 	return (u64)page_counter_read(&memcg->swap) * PAGE_SIZE;
 }
 
-static int swap_max_show(struct seq_file *m, void *v)
-{
-	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
-	unsigned long max = READ_ONCE(memcg->swap.max);
-
-	if (max == PAGE_COUNTER_MAX)
-		seq_puts(m, "max\n");
-	else
-		seq_printf(m, "%llu\n", (u64)max * PAGE_SIZE);
-
-	return 0;
-}
+DEFINE_MEMCG_MAX_OR_VAL(swap_max_show, swap.max)
 
 static ssize_t swap_max_write(struct kernfs_open_file *of,
 			      char *buf, size_t nbytes, loff_t off)
-- 
2.20.1
