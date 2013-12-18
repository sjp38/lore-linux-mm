Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id E99286B0035
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 08:17:09 -0500 (EST)
Received: by mail-la0-f51.google.com with SMTP id ec20so3870598lab.10
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 05:17:09 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id rc10si2874878lbb.164.2013.12.18.05.17.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 05:17:08 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 6/6] memcg, slab: RCU protect memcg_params for root caches
Date: Wed, 18 Dec 2013 17:16:57 +0400
Message-ID: <be8f2fede0fbc45496c06f7bc6cc2272b9b81cc4.1387372122.git.vdavydov@parallels.com>
In-Reply-To: <6f02b2d079ffd0990ae335339c803337b13ecd8c.1387372122.git.vdavydov@parallels.com>
References: <6f02b2d079ffd0990ae335339c803337b13ecd8c.1387372122.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

We update root cache's memcg_params whenever we need to grow the
memcg_caches array to accommodate all kmem-active memory cgroups.
Currently we free the old version immediately then, which can lead to
use-after-free, because the memcg_caches array is accessed lock-free.
This patch fixes this by making memcg_params RCU-protected.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Glauber Costa <glommer@gmail.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/slab.h |    5 ++++-
 mm/memcontrol.c      |   15 ++++++++-------
 mm/slab.h            |    8 +++++++-
 3 files changed, 19 insertions(+), 9 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 1e2f4fe..f7e5649 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -528,7 +528,10 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
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
index ad8de6a..379fc5f 100644
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
index 1d8b53f..53b81a9 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -164,10 +164,16 @@ static inline struct kmem_cache *
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
+
 	smp_read_barrier_depends();	/* see memcg_register_cache() */
 	return cachep;
 }
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
