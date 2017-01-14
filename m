Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 426AC6B0261
	for <linux-mm@kvack.org>; Sat, 14 Jan 2017 00:55:06 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id c73so174692814pfb.7
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 21:55:06 -0800 (PST)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id m127si14757771pfb.123.2017.01.13.21.55.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jan 2017 21:55:05 -0800 (PST)
Received: by mail-pf0-x242.google.com with SMTP id y143so10830203pfb.1
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 21:55:05 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 5/9] slab: link memcg kmem_caches on their associated memory cgroup
Date: Sat, 14 Jan 2017 00:54:45 -0500
Message-Id: <20170114055449.11044-6-tj@kernel.org>
In-Reply-To: <20170114055449.11044-1-tj@kernel.org>
References: <20170114055449.11044-1-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vdavydov.dev@gmail.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com, Tejun Heo <tj@kernel.org>

With kmem cgroup support enabled, kmem_caches can be created and
destroyed frequently and a great number of near empty kmem_caches can
accumulate if there are a lot of transient cgroups and the system is
not under memory pressure.  When memory reclaim starts under such
conditions, it can lead to consecutive deactivation and destruction of
many kmem_caches, easily hundreds of thousands on moderately large
systems, exposing scalability issues in the current slab management
code.  This is one of the patches to address the issue.

While a memcg kmem_cache is listed on its root cache's ->children
list, there is no direct way to iterate all kmem_caches which are
assocaited with a memory cgroup.  The only way to iterate them is
walking all caches while filtering out caches which don't match, which
would be most of them.

This makes memcg destruction operations O(N^2) where N is the total
number of slab caches which can be huge.  This combined with the
synchronous RCU operations can tie up a CPU and affect the whole
machine for many hours when memory reclaim triggers offlining and
destruction of the stale memcgs.

This patch adds mem_cgroup->kmem_caches list which goes through
memcg_cache_params->kmem_caches_node of all kmem_caches which are
associated with the memcg.  All memcg specific iterations, including
stat file access, are updated to use the new list instead.

Signed-off-by: Tejun Heo <tj@kernel.org>
Reported-by: Jay Vana <jsvana@fb.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/memcontrol.h |  1 +
 include/linux/slab.h       |  3 +++
 mm/memcontrol.c            |  7 ++++---
 mm/slab.h                  |  6 +++---
 mm/slab_common.c           | 42 ++++++++++++++++++++++++++++++++----------
 5 files changed, 43 insertions(+), 16 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 61d20c1..4de925c 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -253,6 +253,7 @@ struct mem_cgroup {
         /* Index in the kmem_cache->memcg_params.memcg_caches array */
 	int kmemcg_id;
 	enum memcg_kmem_state kmem_state;
+	struct list_head kmem_caches;
 #endif
 
 	int last_scanned_node;
diff --git a/include/linux/slab.h b/include/linux/slab.h
index b310173..54ec959 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -565,6 +565,8 @@ struct memcg_cache_array {
  * @memcg:	Pointer to the memcg this cache belongs to.
  *
  * @children_node: List node for @root_cache->children list.
+ *
+ * @kmem_caches_node: List node for @memcg->kmem_caches list.
  */
 struct memcg_cache_params {
 	struct kmem_cache *root_cache;
@@ -576,6 +578,7 @@ struct memcg_cache_params {
 		struct {
 			struct mem_cgroup *memcg;
 			struct list_head children_node;
+			struct list_head kmem_caches_node;
 		};
 	};
 };
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4048897..a2b20f7f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2839,6 +2839,7 @@ static int memcg_online_kmem(struct mem_cgroup *memcg)
 	 */
 	memcg->kmemcg_id = memcg_id;
 	memcg->kmem_state = KMEM_ONLINE;
+	INIT_LIST_HEAD(&memcg->kmem_caches);
 
 	return 0;
 }
@@ -4004,9 +4005,9 @@ static struct cftype mem_cgroup_legacy_files[] = {
 #ifdef CONFIG_SLABINFO
 	{
 		.name = "kmem.slabinfo",
-		.seq_start = slab_start,
-		.seq_next = slab_next,
-		.seq_stop = slab_stop,
+		.seq_start = memcg_slab_start,
+		.seq_next = memcg_slab_next,
+		.seq_stop = memcg_slab_stop,
 		.seq_show = memcg_slab_show,
 	},
 #endif
diff --git a/mm/slab.h b/mm/slab.h
index 9b3ec3f..b5e0040 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -488,9 +488,9 @@ static inline struct kmem_cache_node *get_node(struct kmem_cache *s, int node)
 
 #endif
 
-void *slab_start(struct seq_file *m, loff_t *pos);
-void *slab_next(struct seq_file *m, void *p, loff_t *pos);
-void slab_stop(struct seq_file *m, void *p);
+void *memcg_slab_start(struct seq_file *m, loff_t *pos);
+void *memcg_slab_next(struct seq_file *m, void *p, loff_t *pos);
+void memcg_slab_stop(struct seq_file *m, void *p);
 int memcg_slab_show(struct seq_file *m, void *p);
 
 void ___cache_free(struct kmem_cache *cache, void *x, unsigned long addr);
diff --git a/mm/slab_common.c b/mm/slab_common.c
index fdf5b6d..74c36d8 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -149,6 +149,7 @@ static int init_memcg_params(struct kmem_cache *s,
 		s->memcg_params.root_cache = root_cache;
 		s->memcg_params.memcg = memcg;
 		INIT_LIST_HEAD(&s->memcg_params.children_node);
+		INIT_LIST_HEAD(&s->memcg_params.kmem_caches_node);
 		return 0;
 	}
 
@@ -219,6 +220,7 @@ int memcg_update_all_caches(int num_memcgs)
 static void unlink_memcg_cache(struct kmem_cache *s)
 {
 	list_del(&s->memcg_params.children_node);
+	list_del(&s->memcg_params.kmem_caches_node);
 }
 #else
 static inline int init_memcg_params(struct kmem_cache *s,
@@ -561,6 +563,7 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
 
 	list_add(&s->memcg_params.children_node,
 		 &root_cache->memcg_params.children);
+	list_add(&s->memcg_params.kmem_caches_node, &memcg->kmem_caches);
 
 	/*
 	 * Since readers won't lock (see cache_from_memcg_idx()), we need a
@@ -616,9 +619,8 @@ void memcg_destroy_kmem_caches(struct mem_cgroup *memcg)
 	get_online_mems();
 
 	mutex_lock(&slab_mutex);
-	list_for_each_entry_safe(s, s2, &slab_caches, list) {
-		if (is_root_cache(s) || s->memcg_params.memcg != memcg)
-			continue;
+	list_for_each_entry_safe(s, s2, &memcg->kmem_caches,
+				 memcg_params.kmem_caches_node) {
 		/*
 		 * The cgroup is about to be freed and therefore has no charges
 		 * left. Hence, all its caches must be empty by now.
@@ -1077,18 +1079,18 @@ static void print_slabinfo_header(struct seq_file *m)
 	seq_putc(m, '\n');
 }
 
-void *slab_start(struct seq_file *m, loff_t *pos)
+static void *slab_start(struct seq_file *m, loff_t *pos)
 {
 	mutex_lock(&slab_mutex);
 	return seq_list_start(&slab_caches, *pos);
 }
 
-void *slab_next(struct seq_file *m, void *p, loff_t *pos)
+static void *slab_next(struct seq_file *m, void *p, loff_t *pos)
 {
 	return seq_list_next(p, &slab_caches, pos);
 }
 
-void slab_stop(struct seq_file *m, void *p)
+static void slab_stop(struct seq_file *m, void *p)
 {
 	mutex_unlock(&slab_mutex);
 }
@@ -1147,15 +1149,35 @@ static int slab_show(struct seq_file *m, void *p)
 }
 
 #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
+void *memcg_slab_start(struct seq_file *m, loff_t *pos)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+
+	mutex_lock(&slab_mutex);
+	return seq_list_start(&memcg->kmem_caches, *pos);
+}
+
+void *memcg_slab_next(struct seq_file *m, void *p, loff_t *pos)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+
+	return seq_list_next(p, &memcg->kmem_caches, pos);
+}
+
+void memcg_slab_stop(struct seq_file *m, void *p)
+{
+	mutex_unlock(&slab_mutex);
+}
+
 int memcg_slab_show(struct seq_file *m, void *p)
 {
-	struct kmem_cache *s = list_entry(p, struct kmem_cache, list);
+	struct kmem_cache *s = list_entry(p, struct kmem_cache,
+					  memcg_params.kmem_caches_node);
 	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
 
-	if (p == slab_caches.next)
+	if (p == memcg->kmem_caches.next)
 		print_slabinfo_header(m);
-	if (!is_root_cache(s) && s->memcg_params.memcg == memcg)
-		cache_show(s, m);
+	cache_show(s, m);
 	return 0;
 }
 #endif
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
