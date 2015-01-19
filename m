Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 12DC16B0072
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 06:24:04 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id g10so3094080pdj.12
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 03:24:03 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id e12si92147pat.39.2015.01.19.03.24.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jan 2015 03:24:02 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v2 5/7] memcg: free memcg_caches slot on css offline
Date: Mon, 19 Jan 2015 14:23:23 +0300
Message-ID: <127553bc83e64c14608bec8c4326731efc9e0336.1421664712.git.vdavydov@parallels.com>
In-Reply-To: <cover.1421664712.git.vdavydov@parallels.com>
References: <cover.1421664712.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Chinner <david@fromorbit.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

We need to look up a kmem_cache in ->memcg_params.memcg_caches arrays
only on allocations, so there is no need to have the array entries set
until css free - we can clear them on css offline. This will allow us to
reuse array entries more efficiently and avoid costly array relocations.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/slab.h |   10 +++++-----
 mm/memcontrol.c      |   38 ++++++++++++++++++++++++++++++++------
 mm/slab_common.c     |   39 ++++++++++++++++++++++++++++-----------
 3 files changed, 65 insertions(+), 22 deletions(-)

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
index c502f1a92daf..0875217ceb68 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -334,6 +334,7 @@ struct mem_cgroup {
 #if defined(CONFIG_MEMCG_KMEM)
         /* Index in the kmem_cache->memcg_params.memcg_caches array */
 	int kmemcg_id;
+	bool kmem_acct_active;
 #endif
 
 	int last_scanned_node;
@@ -354,7 +355,7 @@ struct mem_cgroup {
 #ifdef CONFIG_MEMCG_KMEM
 bool memcg_kmem_is_active(struct mem_cgroup *memcg)
 {
-	return memcg->kmemcg_id >= 0;
+	return memcg->kmem_acct_active;
 }
 #endif
 
@@ -585,7 +586,7 @@ static void memcg_free_cache_id(int id);
 
 static void disarm_kmem_keys(struct mem_cgroup *memcg)
 {
-	if (memcg_kmem_is_active(memcg)) {
+	if (memcg->kmemcg_id >= 0) {
 		static_key_slow_dec(&memcg_kmem_enabled_key);
 		memcg_free_cache_id(memcg->kmemcg_id);
 	}
@@ -2672,6 +2673,7 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep)
 {
 	struct mem_cgroup *memcg;
 	struct kmem_cache *memcg_cachep;
+	int kmemcg_id;
 
 	VM_BUG_ON(!is_root_cache(cachep));
 
@@ -2679,10 +2681,11 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep)
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
 
@@ -3324,8 +3327,8 @@ static int memcg_activate_kmem(struct mem_cgroup *memcg,
 	int err = 0;
 	int memcg_id;
 
-	if (memcg_kmem_is_active(memcg))
-		return 0;
+	BUG_ON(memcg->kmemcg_id >= 0);
+	BUG_ON(memcg->kmem_acct_active);
 
 	/*
 	 * For simplicity, we won't allow this to be disabled.  It also can't
@@ -3368,6 +3371,7 @@ static int memcg_activate_kmem(struct mem_cgroup *memcg,
 	 * patched.
 	 */
 	memcg->kmemcg_id = memcg_id;
+	memcg->kmem_acct_active = true;
 out:
 	return err;
 }
@@ -4055,6 +4059,22 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
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
@@ -4066,6 +4086,10 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 	return 0;
 }
 
+static void memcg_deactivate_kmem(struct mem_cgroup *memcg)
+{
+}
+
 static void memcg_destroy_kmem(struct mem_cgroup *memcg)
 {
 }
@@ -4622,6 +4646,8 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 	spin_unlock(&memcg->event_list_lock);
 
 	vmpressure_cleanup(&memcg->vmpressure);
+
+	memcg_deactivate_kmem(memcg);
 }
 
 static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 7f90acf3a3ff..bf4a42b2c5ba 100644
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
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
