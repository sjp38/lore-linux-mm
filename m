Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id A56F76B0089
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 08:09:12 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v6 26/29] Aggregate memcg cache values in slabinfo
Date: Thu,  1 Nov 2012 16:07:42 +0400
Message-Id: <1351771665-11076-27-git-send-email-glommer@parallels.com>
In-Reply-To: <1351771665-11076-1-git-send-email-glommer@parallels.com>
References: <1351771665-11076-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

When we create caches in memcgs, we need to display their usage
information somewhere. We'll adopt a scheme similar to /proc/meminfo,
with aggregate totals shown in the global file, and per-group
information stored in the group itself.

For the time being, only reads are allowed in the per-group cache.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Christoph Lameter <cl@linux.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
CC: Michal Hocko <mhocko@suse.cz>
CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: Suleiman Souhlal <suleiman@google.com>
CC: Tejun Heo <tj@kernel.org>
---
 include/linux/memcontrol.h |  8 ++++++++
 include/linux/slab.h       |  4 ++++
 mm/memcontrol.c            | 30 +++++++++++++++++++++++++++++-
 mm/slab.h                  | 27 +++++++++++++++++++++++++++
 mm/slab_common.c           | 44 ++++++++++++++++++++++++++++++++++++++++----
 5 files changed, 108 insertions(+), 5 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index d5511cc..c780dd6 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -413,6 +413,11 @@ static inline void sock_release_memcg(struct sock *sk)
 
 #ifdef CONFIG_MEMCG_KMEM
 extern struct static_key memcg_kmem_enabled_key;
+
+extern int memcg_limited_groups_array_size;
+#define for_each_memcg_cache_index(_idx)	\
+	for ((_idx) = 0; i < memcg_limited_groups_array_size; (_idx)++)
+
 static inline bool memcg_kmem_enabled(void)
 {
 	return static_key_false(&memcg_kmem_enabled_key);
@@ -550,6 +555,9 @@ memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
 	return __memcg_kmem_get_cache(cachep, gfp);
 }
 #else
+#define for_each_memcg_cache_index(_idx)	\
+	for (; NULL; )
+
 static inline bool memcg_kmem_enabled(void)
 {
 	return false;
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 0df42db..1232c7f 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -221,6 +221,10 @@ struct memcg_cache_params {
 
 int memcg_update_all_caches(int num_memcgs);
 
+struct seq_file;
+int cache_show(struct kmem_cache *s, struct seq_file *m);
+void print_slabinfo_header(struct seq_file *m);
+
 /*
  * Common kmalloc functions provided by all allocators
  */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6e2575a..35f5cb3 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -570,7 +570,8 @@ static void disarm_sock_keys(struct mem_cgroup *memcg)
  * increase it.
  */
 static struct ida kmem_limited_groups;
-static int memcg_limited_groups_array_size;
+int memcg_limited_groups_array_size;
+
 /*
  * MIN_SIZE is different than 1, because we would like to avoid going through
  * the alloc/free process all the time. In a small machine, 4 kmem-limited
@@ -2763,6 +2764,27 @@ static struct kmem_cache *memcg_params_to_cache(struct memcg_cache_params *p)
 	return cachep->memcg_params->memcg_caches[memcg_cache_id(p->memcg)];
 }
 
+#ifdef CONFIG_SLABINFO
+static int mem_cgroup_slabinfo_read(struct cgroup *cont, struct cftype *cft,
+					struct seq_file *m)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
+	struct memcg_cache_params *params;
+
+	if (!memcg_can_account_kmem(memcg))
+		return -EIO;
+
+	print_slabinfo_header(m);
+
+	mutex_lock(&memcg->slab_caches_mutex);
+	list_for_each_entry(params, &memcg->memcg_slab_caches, list)
+		cache_show(memcg_params_to_cache(params), m);
+	mutex_unlock(&memcg->slab_caches_mutex);
+
+	return 0;
+}
+#endif
+
 static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
 {
 	struct res_counter *fail_res;
@@ -5801,6 +5823,12 @@ static struct cftype mem_cgroup_files[] = {
 		.trigger = mem_cgroup_reset,
 		.read = mem_cgroup_read,
 	},
+#ifdef CONFIG_SLABINFO
+	{
+		.name = "kmem.slabinfo",
+		.read_seq_string = mem_cgroup_slabinfo_read,
+	},
+#endif
 #endif
 	{ },	/* terminate */
 };
diff --git a/mm/slab.h b/mm/slab.h
index 3ef41e1..08ef468 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -130,6 +130,23 @@ static inline bool slab_equal_or_root(struct kmem_cache *s,
 	return (p == s) ||
 		(s->memcg_params && (p == s->memcg_params->root_cache));
 }
+
+/*
+ * We use suffixes to the name in memcg because we can't have caches
+ * created in the system with the same name. But when we print them
+ * locally, better refer to them with the base name
+ */
+static inline const char *cache_name(struct kmem_cache *s)
+{
+	if (!is_root_cache(s))
+		return s->memcg_params->root_cache->name;
+	return s->name;
+}
+
+static inline struct kmem_cache *cache_from_memcg(struct kmem_cache *s, int idx)
+{
+	return s->memcg_params->memcg_caches[idx];
+}
 #else
 static inline bool is_root_cache(struct kmem_cache *s)
 {
@@ -155,6 +172,16 @@ static inline bool slab_equal_or_root(struct kmem_cache *s,
 {
 	return true;
 }
+
+static inline const char *cache_name(struct kmem_cache *s)
+{
+	return s->name;
+}
+
+static inline struct kmem_cache *cache_from_memcg(struct kmem_cache *s, int idx)
+{
+	return NULL;
+}
 #endif
 
 static inline struct kmem_cache *cache_from_obj(struct kmem_cache *s, void *x)
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 04215a5..9a6f421 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -258,7 +258,7 @@ int slab_is_available(void)
 }
 
 #ifdef CONFIG_SLABINFO
-static void print_slabinfo_header(struct seq_file *m)
+void print_slabinfo_header(struct seq_file *m)
 {
 	/*
 	 * Output format version, so at least we can change it
@@ -302,16 +302,43 @@ static void s_stop(struct seq_file *m, void *p)
 	mutex_unlock(&slab_mutex);
 }
 
-static int s_show(struct seq_file *m, void *p)
+static void
+memcg_accumulate_slabinfo(struct kmem_cache *s, struct slabinfo *info)
+{
+	struct kmem_cache *c;
+	struct slabinfo sinfo;
+	int i;
+
+	if (!is_root_cache(s))
+		return;
+
+	for_each_memcg_cache_index(i) {
+		c = cache_from_memcg(s, i);
+		if (!c)
+			continue;
+
+		memset(&sinfo, 0, sizeof(sinfo));
+		get_slabinfo(c, &sinfo);
+
+		info->active_slabs += sinfo.active_slabs;
+		info->num_slabs += sinfo.num_slabs;
+		info->shared_avail += sinfo.shared_avail;
+		info->active_objs += sinfo.active_objs;
+		info->num_objs += sinfo.num_objs;
+	}
+}
+
+int cache_show(struct kmem_cache *s, struct seq_file *m)
 {
-	struct kmem_cache *s = list_entry(p, struct kmem_cache, list);
 	struct slabinfo sinfo;
 
 	memset(&sinfo, 0, sizeof(sinfo));
 	get_slabinfo(s, &sinfo);
 
+	memcg_accumulate_slabinfo(s, &sinfo);
+
 	seq_printf(m, "%-17s %6lu %6lu %6u %4u %4d",
-		   s->name, sinfo.active_objs, sinfo.num_objs, s->size,
+		   cache_name(s), sinfo.active_objs, sinfo.num_objs, s->size,
 		   sinfo.objects_per_slab, (1 << sinfo.cache_order));
 
 	seq_printf(m, " : tunables %4u %4u %4u",
@@ -323,6 +350,15 @@ static int s_show(struct seq_file *m, void *p)
 	return 0;
 }
 
+static int s_show(struct seq_file *m, void *p)
+{
+	struct kmem_cache *s = list_entry(p, struct kmem_cache, list);
+
+	if (!is_root_cache(s))
+		return 0;
+	return cache_show(s, m);
+}
+
 /*
  * slabinfo_op - iterator that generates /proc/slabinfo
  *
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
