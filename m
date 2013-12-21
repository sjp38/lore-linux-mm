Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 1EBB06B0044
	for <linux-mm@kvack.org>; Sat, 21 Dec 2013 10:54:25 -0500 (EST)
Received: by mail-la0-f45.google.com with SMTP id eh20so1587564lab.4
        for <linux-mm@kvack.org>; Sat, 21 Dec 2013 07:54:25 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id 6si5269662laz.155.2013.12.21.07.54.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 21 Dec 2013 07:54:24 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 09/11] memcg, slab: RCU protect memcg_params for root caches
Date: Sat, 21 Dec 2013 19:54:00 +0400
Message-ID: <cbe037c8ad6d63f9ce11a3d952dcd859135b3864.1387640542.git.vdavydov@parallels.com>
In-Reply-To: <cover.1387640541.git.vdavydov@parallels.com>
References: <cover.1387640541.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: glommer@gmail.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

We relocate root cache's memcg_params whenever we need to grow the
memcg_caches array to accommodate all kmem-active memory cgroups.
Currently on relocation we free the old version immediately, which can
lead to use-after-free, because the memcg_caches array is accessed
lock-free (see cache_from_memcg_idx()). This patch fixes this by making
memcg_params RCU-protected for root caches.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/slab.h |    9 +++++++--
 mm/memcontrol.c      |   15 ++++++++-------
 mm/slab.h            |   16 +++++++++++++++-
 3 files changed, 30 insertions(+), 10 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 1e2f4fe..a060142 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -513,7 +513,9 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
  *
  * Both the root cache and the child caches will have it. For the root cache,
  * this will hold a dynamically allocated array large enough to hold
- * information about the currently limited memcgs in the system.
+ * information about the currently limited memcgs in the system. To allow the
+ * array to be accessed without taking any locks, on relocation we free the old
+ * version only after a grace period.
  *
  * Child caches will hold extra metadata needed for its operation. Fields are:
  *
@@ -528,7 +530,10 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 struct memcg_cache_params {
 	bool is_root_cache;
 	union {
-		struct kmem_cache *memcg_caches[0];
+		struct {
+			struct rcu_head rcu_head;
+			struct kmem_cache *memcg_caches[0];
+		};
 		struct {
 			struct mem_cgroup *memcg;
 			struct list_head list;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ce25f77..a7521c3 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3142,18 +3142,17 @@ int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
 
 	if (num_groups > memcg_limited_groups_array_size) {
 		int i;
+		struct memcg_cache_params *new_params;
 		ssize_t size = memcg_caches_array_size(num_groups);
 
 		size *= sizeof(void *);
 		size += offsetof(struct memcg_cache_params, memcg_caches);
 
-		s->memcg_params = kzalloc(size, GFP_KERNEL);
-		if (!s->memcg_params) {
-			s->memcg_params = cur_params;
+		new_params = kzalloc(size, GFP_KERNEL);
+		if (!new_params)
 			return -ENOMEM;
-		}
 
-		s->memcg_params->is_root_cache = true;
+		new_params->is_root_cache = true;
 
 		/*
 		 * There is the chance it will be bigger than
@@ -3167,7 +3166,7 @@ int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
 		for (i = 0; i < memcg_limited_groups_array_size; i++) {
 			if (!cur_params->memcg_caches[i])
 				continue;
-			s->memcg_params->memcg_caches[i] =
+			new_params->memcg_caches[i] =
 						cur_params->memcg_caches[i];
 		}
 
@@ -3180,7 +3179,9 @@ int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
 		 * bigger than the others. And all updates will reset this
 		 * anyway.
 		 */
-		kfree(cur_params);
+		rcu_assign_pointer(s->memcg_params, new_params);
+		if (cur_params)
+			kfree_rcu(cur_params, rcu_head);
 	}
 	return 0;
 }
diff --git a/mm/slab.h b/mm/slab.h
index 72d1f9d..8184a7c 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -160,14 +160,28 @@ static inline const char *cache_name(struct kmem_cache *s)
 	return s->name;
 }
 
+/*
+ * Note, we protect with RCU only the memcg_caches array, not per-memcg caches.
+ * That said the caller must assure the memcg's cache won't go away. Since once
+ * created a memcg's cache is destroyed only along with the root cache, it is
+ * true if we are going to allocate from the cache or hold a reference to the
+ * root cache by other means. Otherwise, we should hold either the slab_mutex
+ * or the memcg's slab_caches_mutex while calling this function and accessing
+ * the returned value.
+ */
 static inline struct kmem_cache *
 cache_from_memcg_idx(struct kmem_cache *s, int idx)
 {
 	struct kmem_cache *cachep;
+	struct memcg_cache_params *params;
 
 	if (!s->memcg_params)
 		return NULL;
-	cachep = s->memcg_params->memcg_caches[idx];
+
+	rcu_read_lock();
+	params = rcu_dereference(s->memcg_params);
+	cachep = params->memcg_caches[idx];
+	rcu_read_unlock();
 
 	/*
 	 * Make sure we will access the up-to-date value. The code updating
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
