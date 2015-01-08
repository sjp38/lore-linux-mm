Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 4710F6B0071
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 05:53:46 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id ft15so10586894pdb.4
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 02:53:46 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id bd4si7845420pdb.204.2015.01.08.02.53.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Jan 2015 02:53:44 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v3 4/9] memcg: rename some cache id related variables
Date: Thu, 8 Jan 2015 13:53:14 +0300
Message-ID: <1db1d40bdae6bc67522253b6537abb39ce381459.1420711973.git.vdavydov@parallels.com>
In-Reply-To: <cover.1420711973.git.vdavydov@parallels.com>
References: <cover.1420711973.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@gmail.com>, Dave Chinner <david@fromorbit.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

memcg_limited_groups_array_size, which defines the size of memcg_caches
arrays, sounds rather cumbersome. Also it doesn't point anyhow that it's
related to kmem/caches stuff. So let's rename it to memcg_nr_cache_ids.
It's concise and points us directly to memcg_cache_id.

Also, rename kmem_limited_groups to memcg_cache_ida.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/memcontrol.h |    4 ++--
 mm/memcontrol.c            |   19 +++++++++----------
 mm/slab_common.c           |    4 ++--
 3 files changed, 13 insertions(+), 14 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index d555d6533bd0..b27f183e65cd 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -360,7 +360,7 @@ static inline void sock_release_memcg(struct sock *sk)
 #ifdef CONFIG_MEMCG_KMEM
 extern struct static_key memcg_kmem_enabled_key;
 
-extern int memcg_limited_groups_array_size;
+extern int memcg_nr_cache_ids;
 
 /*
  * Helper macro to loop through all memcg-specific caches. Callers must still
@@ -368,7 +368,7 @@ extern int memcg_limited_groups_array_size;
  * the slab_mutex must be held when looping through those caches
  */
 #define for_each_memcg_cache_index(_idx)	\
-	for ((_idx) = 0; (_idx) < memcg_limited_groups_array_size; (_idx)++)
+	for ((_idx) = 0; (_idx) < memcg_nr_cache_ids; (_idx)++)
 
 static inline bool memcg_kmem_enabled(void)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6c1df48b29f9..355e72b01ad6 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -564,12 +564,11 @@ static void disarm_sock_keys(struct mem_cgroup *memcg)
  *  memcgs, and none but the 200th is kmem-limited, we'd have to have a
  *  200 entry array for that.
  *
- * The current size of the caches array is stored in
- * memcg_limited_groups_array_size.  It will double each time we have to
- * increase it.
+ * The current size of the caches array is stored in memcg_nr_cache_ids. It
+ * will double each time we have to increase it.
  */
-static DEFINE_IDA(kmem_limited_groups);
-int memcg_limited_groups_array_size;
+static DEFINE_IDA(memcg_cache_ida);
+int memcg_nr_cache_ids;
 
 /*
  * MIN_SIZE is different than 1, because we would like to avoid going through
@@ -2547,12 +2546,12 @@ static int memcg_alloc_cache_id(void)
 	int id, size;
 	int err;
 
-	id = ida_simple_get(&kmem_limited_groups,
+	id = ida_simple_get(&memcg_cache_ida,
 			    0, MEMCG_CACHES_MAX_SIZE, GFP_KERNEL);
 	if (id < 0)
 		return id;
 
-	if (id < memcg_limited_groups_array_size)
+	if (id < memcg_nr_cache_ids)
 		return id;
 
 	/*
@@ -2568,7 +2567,7 @@ static int memcg_alloc_cache_id(void)
 
 	err = memcg_update_all_caches(size);
 	if (err) {
-		ida_simple_remove(&kmem_limited_groups, id);
+		ida_simple_remove(&memcg_cache_ida, id);
 		return err;
 	}
 	return id;
@@ -2576,7 +2575,7 @@ static int memcg_alloc_cache_id(void)
 
 static void memcg_free_cache_id(int id)
 {
-	ida_simple_remove(&kmem_limited_groups, id);
+	ida_simple_remove(&memcg_cache_ida, id);
 }
 
 /*
@@ -2586,7 +2585,7 @@ static void memcg_free_cache_id(int id)
  */
 void memcg_update_array_size(int num)
 {
-	memcg_limited_groups_array_size = num;
+	memcg_nr_cache_ids = num;
 }
 
 struct memcg_kmem_cache_create_work {
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 481cf81eadc3..d6cf88c2739f 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -116,7 +116,7 @@ static int memcg_alloc_cache_params(struct mem_cgroup *memcg,
 
 	if (!memcg) {
 		size = offsetof(struct memcg_cache_params, memcg_caches);
-		size += memcg_limited_groups_array_size * sizeof(void *);
+		size += memcg_nr_cache_ids * sizeof(void *);
 	} else
 		size = sizeof(struct memcg_cache_params);
 
@@ -154,7 +154,7 @@ static int memcg_update_cache_params(struct kmem_cache *s, int num_memcgs)
 
 	cur_params = s->memcg_params;
 	memcpy(new_params->memcg_caches, cur_params->memcg_caches,
-	       memcg_limited_groups_array_size * sizeof(void *));
+	       memcg_nr_cache_ids * sizeof(void *));
 
 	new_params->is_root_cache = true;
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
