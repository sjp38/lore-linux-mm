Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0298B6B0266
	for <linux-mm@kvack.org>; Sat, 14 Jan 2017 13:49:01 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id a29so63894110qtb.6
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 10:49:00 -0800 (PST)
Received: from mail-qk0-x244.google.com (mail-qk0-x244.google.com. [2607:f8b0:400d:c09::244])
        by mx.google.com with ESMTPS id a4si11017417qkd.7.2017.01.14.10.49.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Jan 2017 10:49:00 -0800 (PST)
Received: by mail-qk0-x244.google.com with SMTP id a20so11484798qkc.3
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 10:49:00 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 3/8] slab: reorganize memcg_cache_params
Date: Sat, 14 Jan 2017 13:48:29 -0500
Message-Id: <20170114184834.8658-4-tj@kernel.org>
In-Reply-To: <20170114184834.8658-1-tj@kernel.org>
References: <20170114184834.8658-1-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vdavydov.dev@gmail.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com, Tejun Heo <tj@kernel.org>

We're gonna change how memcg caches are iterated.  In preparation,
clean up and reorganize memcg_cache_params.

* The shared ->list is replaced by ->children in root and
  ->children_node in children.

* ->is_root_cache is removed.  Instead ->root_cache is moved out of
  the child union and now used by both root and children.  NULL
  indicates root cache.  Non-NULL a memcg one.

This patch doesn't cause any observable behavior changes.

Signed-off-by: Tejun Heo <tj@kernel.org>
Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/slab.h | 33 ++++++++++++++++++++++++---------
 mm/slab.h            |  6 +++---
 mm/slab_common.c     | 25 +++++++++++++------------
 3 files changed, 40 insertions(+), 24 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 084b12b..2e83922 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -545,22 +545,37 @@ struct memcg_cache_array {
  * array to be accessed without taking any locks, on relocation we free the old
  * version only after a grace period.
  *
- * Child caches will hold extra metadata needed for its operation. Fields are:
+ * Root and child caches hold different metadata.
  *
- * @memcg: pointer to the memcg this cache belongs to
- * @root_cache: pointer to the global, root cache, this cache was derived from
+ * @root_cache:	Common to root and child caches.  NULL for root, pointer to
+ *		the root cache for children.
  *
- * Both root and child caches of the same kind are linked into a list chained
- * through @list.
+ * The following fields are specific to root caches.
+ *
+ * @memcg_caches: kmemcg ID indexed table of child caches.  This table is
+ *		used to index child cachces during allocation and cleared
+ *		early during shutdown.
+ *
+ * @children:	List of all child caches.  While the child caches are also
+ *		reachable through @memcg_caches, a child cache remains on
+ *		this list until it is actually destroyed.
+ *
+ * The following fields are specific to child caches.
+ *
+ * @memcg:	Pointer to the memcg this cache belongs to.
+ *
+ * @children_node: List node for @root_cache->children list.
  */
 struct memcg_cache_params {
-	bool is_root_cache;
-	struct list_head list;
+	struct kmem_cache *root_cache;
 	union {
-		struct memcg_cache_array __rcu *memcg_caches;
+		struct {
+			struct memcg_cache_array __rcu *memcg_caches;
+			struct list_head children;
+		};
 		struct {
 			struct mem_cgroup *memcg;
-			struct kmem_cache *root_cache;
+			struct list_head children_node;
 		};
 	};
 };
diff --git a/mm/slab.h b/mm/slab.h
index 3fa2d77..9b3ec3f 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -203,12 +203,12 @@ int __kmem_cache_alloc_bulk(struct kmem_cache *, gfp_t, size_t, void **);
  * slab_mutex.
  */
 #define for_each_memcg_cache(iter, root) \
-	list_for_each_entry(iter, &(root)->memcg_params.list, \
-			    memcg_params.list)
+	list_for_each_entry(iter, &(root)->memcg_params.children, \
+			    memcg_params.children_node)
 
 static inline bool is_root_cache(struct kmem_cache *s)
 {
-	return s->memcg_params.is_root_cache;
+	return !s->memcg_params.root_cache;
 }
 
 static inline bool slab_equal_or_root(struct kmem_cache *s,
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 851c75e..ad9cc55 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -135,9 +135,9 @@ int __kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t nr,
 #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
 void slab_init_memcg_params(struct kmem_cache *s)
 {
-	s->memcg_params.is_root_cache = true;
-	INIT_LIST_HEAD(&s->memcg_params.list);
+	s->memcg_params.root_cache = NULL;
 	RCU_INIT_POINTER(s->memcg_params.memcg_caches, NULL);
+	INIT_LIST_HEAD(&s->memcg_params.children);
 }
 
 static int init_memcg_params(struct kmem_cache *s,
@@ -145,10 +145,10 @@ static int init_memcg_params(struct kmem_cache *s,
 {
 	struct memcg_cache_array *arr;
 
-	if (memcg) {
-		s->memcg_params.is_root_cache = false;
-		s->memcg_params.memcg = memcg;
+	if (root_cache) {
 		s->memcg_params.root_cache = root_cache;
+		s->memcg_params.memcg = memcg;
+		INIT_LIST_HEAD(&s->memcg_params.children_node);
 		return 0;
 	}
 
@@ -218,7 +218,7 @@ int memcg_update_all_caches(int num_memcgs)
 
 static void unlink_memcg_cache(struct kmem_cache *s)
 {
-	list_del(&s->memcg_params.list);
+	list_del(&s->memcg_params.children_node);
 }
 #else
 static inline int init_memcg_params(struct kmem_cache *s,
@@ -559,7 +559,8 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
 		goto out_unlock;
 	}
 
-	list_add(&s->memcg_params.list, &root_cache->memcg_params.list);
+	list_add(&s->memcg_params.children_node,
+		 &root_cache->memcg_params.children);
 
 	/*
 	 * Since readers won't lock (see cache_from_memcg_idx()), we need a
@@ -655,7 +656,7 @@ static int shutdown_memcg_caches(struct kmem_cache *s)
 			 * list so as not to try to destroy it for a second
 			 * time while iterating over inactive caches below.
 			 */
-			list_move(&c->memcg_params.list, &busy);
+			list_move(&c->memcg_params.children_node, &busy);
 		else
 			/*
 			 * The cache is empty and will be destroyed soon. Clear
@@ -670,17 +671,17 @@ static int shutdown_memcg_caches(struct kmem_cache *s)
 	 * Second, shutdown all caches left from memory cgroups that are now
 	 * offline.
 	 */
-	list_for_each_entry_safe(c, c2, &s->memcg_params.list,
-				 memcg_params.list)
+	list_for_each_entry_safe(c, c2, &s->memcg_params.children,
+				 memcg_params.children_node)
 		shutdown_cache(c);
 
-	list_splice(&busy, &s->memcg_params.list);
+	list_splice(&busy, &s->memcg_params.children);
 
 	/*
 	 * A cache being destroyed must be empty. In particular, this means
 	 * that all per memcg caches attached to it must be empty too.
 	 */
-	if (!list_empty(&s->memcg_params.list))
+	if (!list_empty(&s->memcg_params.children))
 		return -EBUSY;
 	return 0;
 }
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
