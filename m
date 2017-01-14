Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 984C36B0266
	for <linux-mm@kvack.org>; Sat, 14 Jan 2017 00:55:08 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 194so4470252pgd.7
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 21:55:08 -0800 (PST)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id 64si14710007pgj.306.2017.01.13.21.55.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jan 2017 21:55:07 -0800 (PST)
Received: by mail-pf0-x244.google.com with SMTP id 19so83325pfo.3
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 21:55:07 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 6/9] slab: don't put memcg caches on slab_caches list
Date: Sat, 14 Jan 2017 00:54:46 -0500
Message-Id: <20170114055449.11044-7-tj@kernel.org>
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

slab_caches currently lists all caches including root and memcg ones.
This is the only data structure which lists the root caches and
iterating root caches can only be done by walking the list while
skipping over memcg caches.  As there can be a huge number of memcg
caches, this can become very expensive.

This also can make /proc/slabinfo behave very badly.  seq_file
processes reads in 4k chunks and seeks to the previous Nth position on
slab_caches list to resume after each chunk.  With a lot of memcg
cache churns on the list, reading /proc/slabinfo can become very slow
and its content often ends up with duplicate and/or missing entries.

As the previous patch made it unnecessary to walk slab_caches to
iterate memcg-specific caches, there is no reason to keep memcg caches
on the list.  This patch makes slab_caches include only the root
caches.  As this makes slab_cache->list unused for memcg caches,
->memcg_params.children_node is removed and ->list is used instead.

Signed-off-by: Tejun Heo <tj@kernel.org>
Reported-by: Jay Vana <jsvana@fb.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/slab.h |  3 ---
 mm/slab.h            |  3 +--
 mm/slab_common.c     | 58 +++++++++++++++++++++++++---------------------------
 3 files changed, 29 insertions(+), 35 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 54ec959..63d543d 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -564,8 +564,6 @@ struct memcg_cache_array {
  *
  * @memcg:	Pointer to the memcg this cache belongs to.
  *
- * @children_node: List node for @root_cache->children list.
- *
  * @kmem_caches_node: List node for @memcg->kmem_caches list.
  */
 struct memcg_cache_params {
@@ -577,7 +575,6 @@ struct memcg_cache_params {
 		};
 		struct {
 			struct mem_cgroup *memcg;
-			struct list_head children_node;
 			struct list_head kmem_caches_node;
 		};
 	};
diff --git a/mm/slab.h b/mm/slab.h
index b5e0040..8f47a44 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -203,8 +203,7 @@ int __kmem_cache_alloc_bulk(struct kmem_cache *, gfp_t, size_t, void **);
  * slab_mutex.
  */
 #define for_each_memcg_cache(iter, root) \
-	list_for_each_entry(iter, &(root)->memcg_params.children, \
-			    memcg_params.children_node)
+	list_for_each_entry(iter, &(root)->memcg_params.children, list)
 
 static inline bool is_root_cache(struct kmem_cache *s)
 {
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 74c36d8..c0d0126 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -68,6 +68,22 @@ unsigned int kmem_cache_size(struct kmem_cache *s)
 EXPORT_SYMBOL(kmem_cache_size);
 
 #ifdef CONFIG_DEBUG_VM
+static void kmem_cache_verify_name(struct kmem_cache *s)
+{
+	char tmp;
+	int res;
+
+	/*
+	 * This happens when the module gets unloaded and doesn't destroy
+	 * its slab cache and no-one else reuses the vmalloc area of the
+	 * module.  Print a warning.
+	 */
+	res = probe_kernel_address(s->name, tmp);
+	if (res)
+		pr_err("Slab cache with size %d has lost its name\n",
+		       s->object_size);
+}
+
 static int kmem_cache_sanity_check(const char *name, size_t size)
 {
 	struct kmem_cache *s = NULL;
@@ -79,20 +95,12 @@ static int kmem_cache_sanity_check(const char *name, size_t size)
 	}
 
 	list_for_each_entry(s, &slab_caches, list) {
-		char tmp;
-		int res;
+		struct kmem_cache *c;
 
-		/*
-		 * This happens when the module gets unloaded and doesn't
-		 * destroy its slab cache and no-one else reuses the vmalloc
-		 * area of the module.  Print a warning.
-		 */
-		res = probe_kernel_address(s->name, tmp);
-		if (res) {
-			pr_err("Slab cache with size %d has lost its name\n",
-			       s->object_size);
-			continue;
-		}
+		kmem_cache_verify_name(s);
+
+		for_each_memcg_cache(c, s)
+			kmem_cache_verify_name(c);
 	}
 
 	WARN_ON(strchr(name, ' '));	/* It confuses parsers */
@@ -148,7 +156,6 @@ static int init_memcg_params(struct kmem_cache *s,
 	if (root_cache) {
 		s->memcg_params.root_cache = root_cache;
 		s->memcg_params.memcg = memcg;
-		INIT_LIST_HEAD(&s->memcg_params.children_node);
 		INIT_LIST_HEAD(&s->memcg_params.kmem_caches_node);
 		return 0;
 	}
@@ -178,9 +185,6 @@ static int update_memcg_params(struct kmem_cache *s, int new_array_size)
 {
 	struct memcg_cache_array *old, *new;
 
-	if (!is_root_cache(s))
-		return 0;
-
 	new = kzalloc(sizeof(struct memcg_cache_array) +
 		      new_array_size * sizeof(void *), GFP_KERNEL);
 	if (!new)
@@ -219,7 +223,6 @@ int memcg_update_all_caches(int num_memcgs)
 
 static void unlink_memcg_cache(struct kmem_cache *s)
 {
-	list_del(&s->memcg_params.children_node);
 	list_del(&s->memcg_params.kmem_caches_node);
 }
 #else
@@ -243,10 +246,10 @@ static inline void unlink_memcg_cache(struct kmem_cache *s)
  */
 int slab_unmergeable(struct kmem_cache *s)
 {
-	if (slab_nomerge || (s->flags & SLAB_NEVER_MERGE))
+	if (!is_root_cache(s))
 		return 1;
 
-	if (!is_root_cache(s))
+	if (slab_nomerge || (s->flags & SLAB_NEVER_MERGE))
 		return 1;
 
 	if (s->ctor)
@@ -360,7 +363,8 @@ static struct kmem_cache *create_cache(const char *name,
 		goto out_free_cache;
 
 	s->refcount = 1;
-	list_add(&s->list, &slab_caches);
+	if (is_root_cache(s))
+		list_add(&s->list, &slab_caches);
 out:
 	if (err)
 		return ERR_PTR(err);
@@ -561,8 +565,7 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
 		goto out_unlock;
 	}
 
-	list_add(&s->memcg_params.children_node,
-		 &root_cache->memcg_params.children);
+	list_add(&s->list, &root_cache->memcg_params.children);
 	list_add(&s->memcg_params.kmem_caches_node, &memcg->kmem_caches);
 
 	/*
@@ -593,9 +596,6 @@ void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
 
 	mutex_lock(&slab_mutex);
 	list_for_each_entry(s, &slab_caches, list) {
-		if (!is_root_cache(s))
-			continue;
-
 		arr = rcu_dereference_protected(s->memcg_params.memcg_caches,
 						lockdep_is_held(&slab_mutex));
 		c = arr->entries[idx];
@@ -653,8 +653,7 @@ static int shutdown_memcg_caches(struct kmem_cache *s)
 	/*
 	 * Shutdown all caches.
 	 */
-	list_for_each_entry_safe(c, c2, &s->memcg_params.children,
-				 memcg_params.children_node)
+	list_for_each_entry_safe(c, c2, &s->memcg_params.children, list)
 		shutdown_cache(c);
 
 	/*
@@ -1143,8 +1142,7 @@ static int slab_show(struct seq_file *m, void *p)
 
 	if (p == slab_caches.next)
 		print_slabinfo_header(m);
-	if (is_root_cache(s))
-		cache_show(s, m);
+	cache_show(s, m);
 	return 0;
 }
 
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
