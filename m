Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 675886B0074
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 09:13:34 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id et14so24486069pad.3
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 06:13:34 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id yt1si5702841pab.64.2015.01.16.06.13.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jan 2015 06:13:32 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 4/6] memcg: free memcg_caches slot on css offline
Date: Fri, 16 Jan 2015 17:13:04 +0300
Message-ID: <0488f6e83839cb30745f0dbe6ad3344152343a37.1421411660.git.vdavydov@parallels.com>
In-Reply-To: <cover.1421411660.git.vdavydov@parallels.com>
References: <cover.1421411660.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

We need to look up a kmem_cache in ->memcg_params.memcg_caches arrays
only on allocations, so there is no need to have the array entries set
until css free - we can clear them on css offline. This will allow us to
reuse array entries more efficiently and avoid costly array relocations.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/slab.h |   10 +++++-----
 mm/memcontrol.c      |   38 ++++++++++++++++++++++++++++++++------
 mm/slab_common.c     |   39 ++++++++++++++++++++++++++++-----------
 mm/vmscan.c          |    2 +-
 4 files changed, 66 insertions(+), 23 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 26d99f41b410..ed2ffaab59ea 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -115,13 +115,12 @@ int slab_is_available(void);
 struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
 			unsigned long,
 			void (*)(void *));
-#ifdef CONFIG_MEMCG_KMEM
-void memcg_create_kmem_cache(struct mem_cgroup *, struct kmem_cache *);
-void memcg_destroy_kmem_caches(struct mem_cgroup *);
-#endif
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
-void kmem_cache_free(struct kmem_cache *, void *);
+
+void memcg_create_kmem_cache(struct mem_cgroup *, struct kmem_cache *);
+void memcg_deactivate_kmem_caches(struct mem_cgroup *);
+void memcg_destroy_kmem_caches(struct mem_cgroup *);
 
 /*
  * Please use this macro to create slab caches. Simply specify the
@@ -288,6 +287,7 @@ static __always_inline int kmalloc_index(size_t size)
 
 void *__kmalloc(size_t size, gfp_t flags);
 void *kmem_cache_alloc(struct kmem_cache *, gfp_t flags);
+void kmem_cache_free(struct kmem_cache *, void *);
 
 #ifdef CONFIG_NUMA
 void *__kmalloc_node(size_t size, gfp_t flags, int node);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f03bd5b2797e..b82ddb68ffd6 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -347,6 +347,7 @@ struct mem_cgroup {
 #if defined(CONFIG_MEMCG_KMEM)
         /* Index in the kmem_cache->memcg_params.memcg_caches array */
 	int kmemcg_id;
+	bool kmem_acct_active;
 #endif
 
 	int last_scanned_node;
@@ -367,7 +368,7 @@ struct mem_cgroup {
 #ifdef CONFIG_MEMCG_KMEM
 bool memcg_kmem_is_active(struct mem_cgroup *memcg)
 {
-	return memcg->kmemcg_id >= 0;
+	return memcg->kmem_acct_active;
 }
 #endif
 
@@ -611,7 +612,7 @@ static void memcg_free_cache_id(int id);
 
 static void disarm_kmem_keys(struct mem_cgroup *memcg)
 {
-	if (memcg_kmem_is_active(memcg)) {
+	if (memcg->kmemcg_id >= 0) {
 		static_key_slow_dec(&memcg_kmem_enabled_key);
 		memcg_free_cache_id(memcg->kmemcg_id);
 	}
@@ -2675,6 +2676,7 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep)
 {
 	struct mem_cgroup *memcg;
 	struct kmem_cache *memcg_cachep;
+	int kmemcg_id;
 
 	VM_BUG_ON(!is_root_cache(cachep));
 
@@ -2682,10 +2684,11 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep)
 		return cachep;
 
 	memcg = get_mem_cgroup_from_mm(current->mm);
-	if (!memcg_kmem_is_active(memcg))
+	kmemcg_id = ACCESS_ONCE(memcg->kmemcg_id);
+	if (kmemcg_id < 0)
 		goto out;
 
-	memcg_cachep = cache_from_memcg_idx(cachep, memcg_cache_id(memcg));
+	memcg_cachep = cache_from_memcg_idx(cachep, kmemcg_id);
 	if (likely(memcg_cachep))
 		return memcg_cachep;
 
@@ -3327,8 +3330,8 @@ static int memcg_activate_kmem(struct mem_cgroup *memcg,
 	int err = 0;
 	int memcg_id;
 
-	if (memcg_kmem_is_active(memcg))
-		return 0;
+	BUG_ON(memcg->kmemcg_id >= 0);
+	BUG_ON(memcg->kmem_acct_active);
 
 	/*
 	 * For simplicity, we won't allow this to be disabled.  It also can't
@@ -3371,6 +3374,7 @@ static int memcg_activate_kmem(struct mem_cgroup *memcg,
 	 * patched.
 	 */
 	memcg->kmemcg_id = memcg_id;
+	memcg->kmem_acct_active = true;
 out:
 	return err;
 }
@@ -4046,6 +4050,22 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 	return mem_cgroup_sockets_init(memcg, ss);
 }
 
+static void memcg_deactivate_kmem(struct mem_cgroup *memcg)
+{
+	if (!memcg->kmem_acct_active)
+		return;
+
+	/*
+	 * Clear the 'active' flag before clearing memcg_caches arrays entries.
+	 * Since we take the slab_mutex in memcg_deactivate_kmem_caches(), it
+	 * guarantees no cache will be created for this cgroup after we are
+	 * done (see memcg_create_kmem_cache()).
+	 */
+	memcg->kmem_acct_active = false;
+
+	memcg_deactivate_kmem_caches(memcg);
+}
+
 static void memcg_destroy_kmem(struct mem_cgroup *memcg)
 {
 	memcg_destroy_kmem_caches(memcg);
@@ -4057,6 +4077,10 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 	return 0;
 }
 
+static void memcg_deactivate_kmem(struct mem_cgroup *memcg)
+{
+}
+
 static void memcg_destroy_kmem(struct mem_cgroup *memcg)
 {
 }
@@ -4661,6 +4685,8 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 	spin_unlock(&memcg->event_list_lock);
 
 	vmpressure_cleanup(&memcg->vmpressure);
+
+	memcg_deactivate_kmem(memcg);
 }
 
 static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 512ee119e5c3..741bef834e5e 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -439,18 +439,8 @@ static int do_kmem_cache_shutdown(struct kmem_cache *s,
 		*need_rcu_barrier = true;
 
 #ifdef CONFIG_MEMCG_KMEM
-	if (!is_root_cache(s)) {
-		int idx;
-		struct memcg_cache_array *arr;
-
-		idx = memcg_cache_id(s->memcg_params.memcg);
-		arr = rcu_dereference_protected(s->memcg_params.root_cache->
-						memcg_params.memcg_caches,
-						lockdep_is_held(&slab_mutex));
-		BUG_ON(arr->entries[idx] != s);
-		arr->entries[idx] = NULL;
+	if (!is_root_cache(s))
 		list_del(&s->memcg_params.list);
-	}
 #endif
 	list_move(&s->list, release);
 	return 0;
@@ -498,6 +488,13 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
 
 	mutex_lock(&slab_mutex);
 
+	/*
+	 * The memory cgroup could have been deactivated while the cache
+	 * creation work was pending.
+	 */
+	if (!memcg_kmem_is_active(memcg))
+		goto out_unlock;
+
 	idx = memcg_cache_id(memcg);
 	arr = rcu_dereference_protected(root_cache->memcg_params.memcg_caches,
 					lockdep_is_held(&slab_mutex));
@@ -547,6 +544,26 @@ out_unlock:
 	put_online_cpus();
 }
 
+void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
+{
+	int idx;
+	struct memcg_cache_array *arr;
+	struct kmem_cache *s;
+
+	idx = memcg_cache_id(memcg);
+
+	mutex_lock(&slab_mutex);
+	list_for_each_entry(s, &slab_caches, list) {
+		if (!is_root_cache(s))
+			continue;
+
+		arr = rcu_dereference_protected(s->memcg_params.memcg_caches,
+						lockdep_is_held(&slab_mutex));
+		arr->entries[idx] = NULL;
+	}
+	mutex_unlock(&slab_mutex);
+}
+
 void memcg_destroy_kmem_caches(struct mem_cgroup *memcg)
 {
 	LIST_HEAD(release);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 16f3e45742d6..87ef846d5709 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -377,7 +377,7 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 	struct shrinker *shrinker;
 	unsigned long freed = 0;
 
-	if (memcg && !memcg_kmem_is_active(memcg))
+	if (memcg_cache_id(memcg) < 0)
 		return 0;
 
 	if (nr_scanned == 0)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
