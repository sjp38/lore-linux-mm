Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id D3F9C6B0055
	for <linux-mm@kvack.org>; Sun, 21 Sep 2014 11:15:49 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id ft15so2828617pdb.38
        for <linux-mm@kvack.org>; Sun, 21 Sep 2014 08:15:49 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ck6si11992739pdb.104.2014.09.21.08.15.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Sep 2014 08:15:47 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 09/14] memcg: rename some cache id related variables
Date: Sun, 21 Sep 2014 19:14:41 +0400
Message-ID: <04aef0cce8877175f4ea7563b45310bef4b59e57.1411301245.git.vdavydov@parallels.com>
In-Reply-To: <cover.1411301245.git.vdavydov@parallels.com>
References: <cover.1411301245.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Dave Chinner <david@fromorbit.com>, Glauber Costa <glommer@gmail.com>, Suleiman Souhlal <suleiman@google.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

memcg_limited_groups_array_size, which defines the size of memcg_caches
arrays, sounds rather cumbersome. Also it doesn't point anyhow that it's
related to kmem/caches stuff. So let's rename it to memcg_max_cache_ids.
It's concise and points us directly to memcg_cache_id.

Also, rename kmem_limited_groups to memcg_cache_ida, because it's not a
container for groups, but the memcg_cache_id allocator.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/memcontrol.h |    9 ++++++++-
 mm/memcontrol.c            |   19 +++++++++----------
 mm/slab_common.c           |    4 ++--
 3 files changed, 19 insertions(+), 13 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index e57a097cf393..7c1bf0a84950 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -415,7 +415,12 @@ static inline void sock_release_memcg(struct sock *sk)
 #ifdef CONFIG_MEMCG_KMEM
 extern struct static_key memcg_kmem_enabled_key;
 
-extern int memcg_limited_groups_array_size;
+/*
+ * The maximal number of kmem-active memory cgroups that can exist on the
+ * system. May grow, but never shrinks. The value returned by memcg_cache_id()
+ * is always less.
+ */
+extern int memcg_max_cache_ids;
 
 static inline bool memcg_kmem_enabled(void)
 {
@@ -545,6 +550,8 @@ memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
 	return __memcg_kmem_get_cache(cachep, gfp);
 }
 #else
+#define memcg_max_cache_ids 0
+
 static inline bool memcg_kmem_enabled(void)
 {
 	return false;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d665d715090b..0020824dee96 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -615,12 +615,11 @@ static void disarm_sock_keys(struct mem_cgroup *memcg)
  *  memcgs, and none but the 200th is kmem-limited, we'd have to have a
  *  200 entry array for that.
  *
- * The current size of the caches array is stored in
- * memcg_limited_groups_array_size.  It will double each time we have to
- * increase it.
+ * The current size of the caches array is stored in memcg_max_cache_ids. It
+ * will double each time we have to increase it.
  */
-static DEFINE_IDA(kmem_limited_groups);
-int memcg_limited_groups_array_size;
+static DEFINE_IDA(memcg_cache_ida);
+int memcg_max_cache_ids;
 
 /*
  * MIN_SIZE is different than 1, because we would like to avoid going through
@@ -2926,12 +2925,12 @@ static int memcg_alloc_cache_id(void)
 	int id, size;
 	int err;
 
-	id = ida_simple_get(&kmem_limited_groups,
+	id = ida_simple_get(&memcg_cache_ida,
 			    0, MEMCG_CACHES_MAX_SIZE, GFP_KERNEL);
 	if (id < 0)
 		return id;
 
-	if (id < memcg_limited_groups_array_size)
+	if (id < memcg_max_cache_ids)
 		return id;
 
 	/*
@@ -2950,7 +2949,7 @@ static int memcg_alloc_cache_id(void)
 	mutex_unlock(&memcg_slab_mutex);
 
 	if (err) {
-		ida_simple_remove(&kmem_limited_groups, id);
+		ida_simple_remove(&memcg_cache_ida, id);
 		return err;
 	}
 	return id;
@@ -2959,7 +2958,7 @@ static int memcg_alloc_cache_id(void)
 
 static void memcg_free_cache_id(int id)
 {
-	ida_simple_remove(&kmem_limited_groups, id);
+	ida_simple_remove(&memcg_cache_ida, id);
 }
 
 /*
@@ -2969,7 +2968,7 @@ static void memcg_free_cache_id(int id)
  */
 void memcg_update_array_size(int num)
 {
-	memcg_limited_groups_array_size = num;
+	memcg_max_cache_ids = num;
 }
 
 static void memcg_register_cache(struct mem_cgroup *memcg,
diff --git a/mm/slab_common.c b/mm/slab_common.c
index d4add958843c..cc6e18437f6c 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -98,7 +98,7 @@ static int memcg_alloc_cache_params(struct mem_cgroup *memcg,
 
 	if (!memcg) {
 		size = offsetof(struct memcg_cache_params, memcg_caches);
-		size += memcg_limited_groups_array_size * sizeof(void *);
+		size += memcg_max_cache_ids * sizeof(void *);
 	} else
 		size = sizeof(struct memcg_cache_params);
 
@@ -138,7 +138,7 @@ static int memcg_update_cache_params(struct kmem_cache *s, int num_memcgs)
 
 	cur_params = s->memcg_params;
 	memcpy(new_params->memcg_caches, cur_params->memcg_caches,
-	       memcg_limited_groups_array_size * sizeof(void *));
+	       memcg_max_cache_ids * sizeof(void *));
 
 	new_params->is_root_cache = true;
 	INIT_LIST_HEAD(&new_params->memcg_caches_list);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
