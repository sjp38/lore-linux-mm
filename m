Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7715C6B005C
	for <linux-mm@kvack.org>; Sun, 21 Sep 2014 11:15:54 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fb1so3014299pad.27
        for <linux-mm@kvack.org>; Sun, 21 Sep 2014 08:15:54 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id gh9si12036573pac.62.2014.09.21.08.15.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Sep 2014 08:15:53 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 10/14] memcg: add rwsem to sync against memcg_caches arrays relocation
Date: Sun, 21 Sep 2014 19:14:42 +0400
Message-ID: <4711e5b4c4fcd37d839cd5b23643b3b077b12406.1411301245.git.vdavydov@parallels.com>
In-Reply-To: <cover.1411301245.git.vdavydov@parallels.com>
References: <cover.1411301245.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Dave Chinner <david@fromorbit.com>, Glauber Costa <glommer@gmail.com>, Suleiman Souhlal <suleiman@google.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

We need a stable value of memcg_max_cache_ids in kmem_cache_create()
(memcg_alloc_cache_params() wants it for root caches), where we only
hold the slab_mutex and no memcg-related locks. As a result, we have to
update memcg_cache_ids under the slab_mutex, which we can only take from
the slab's side. This looks awkward and will become even worse when
per-memcg list_lru is introduced, which also wants stable access to
memcg_max_cache_ids.

To get rid of this dependency between the memcg_max_cache_ids and the
slab_mutex, this patch introduces a special rwsem. The rwsem is held for
writing during memcg_caches arrays relocation and memcg_max_cache_ids
updates. Therefore one can take it for reading to get a stable access to
memcg_caches arrays and/or memcg_max_cache_ids.

Currently the semaphore is taken for reading only from
kmem_cache_create, right before taking the slab_mutex, so right now
there's no point in using rwsem instead of mutex. However, once list_lru
is made per-memcg it will allow list_lru initializations to proceed
concurrently.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/memcontrol.h |   15 +++++++++++++--
 mm/memcontrol.c            |   28 ++++++++++++++++++----------
 mm/slab_common.c           |   10 +++++-----
 3 files changed, 36 insertions(+), 17 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 7c1bf0a84950..f2cd342d6544 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -419,8 +419,13 @@ extern struct static_key memcg_kmem_enabled_key;
  * The maximal number of kmem-active memory cgroups that can exist on the
  * system. May grow, but never shrinks. The value returned by memcg_cache_id()
  * is always less.
+ *
+ * To prevent memcg_max_cache_ids from growing, memcg_lock_cache_id_space() can
+ * be used. It's backed by rw semaphore.
  */
 extern int memcg_max_cache_ids;
+extern void memcg_lock_cache_id_space(void);
+extern void memcg_unlock_cache_id_space(void);
 
 static inline bool memcg_kmem_enabled(void)
 {
@@ -449,8 +454,6 @@ void __memcg_kmem_uncharge_pages(struct page *page, int order);
 
 int memcg_cache_id(struct mem_cgroup *memcg);
 
-void memcg_update_array_size(int num_groups);
-
 struct kmem_cache *
 __memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
 
@@ -587,6 +590,14 @@ static inline int memcg_cache_id(struct mem_cgroup *memcg)
 	return -1;
 }
 
+static inline void memcg_lock_cache_id_space(void)
+{
+}
+
+static inline void memcg_unlock_cache_id_space(void)
+{
+}
+
 static inline struct kmem_cache *
 memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 0020824dee96..0c6d412ae5a3 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -621,6 +621,19 @@ static void disarm_sock_keys(struct mem_cgroup *memcg)
 static DEFINE_IDA(memcg_cache_ida);
 int memcg_max_cache_ids;
 
+/* Protects memcg_max_cache_ids */
+static DECLARE_RWSEM(memcg_cache_id_space_sem);
+
+void memcg_lock_cache_id_space(void)
+{
+	down_read(&memcg_cache_id_space_sem);
+}
+
+void memcg_unlock_cache_id_space(void)
+{
+	up_read(&memcg_cache_id_space_sem);
+}
+
 /*
  * MIN_SIZE is different than 1, because we would like to avoid going through
  * the alloc/free process all the time. In a small machine, 4 kmem-limited
@@ -2937,6 +2950,7 @@ static int memcg_alloc_cache_id(void)
 	 * There's no space for the new id in memcg_caches arrays,
 	 * so we have to grow them.
 	 */
+	down_write(&memcg_cache_id_space_sem);
 
 	size = 2 * (id + 1);
 	if (size < MEMCG_CACHES_MIN_SIZE)
@@ -2948,6 +2962,10 @@ static int memcg_alloc_cache_id(void)
 	err = memcg_update_all_caches(size);
 	mutex_unlock(&memcg_slab_mutex);
 
+	if (!err)
+		memcg_max_cache_ids = size;
+	up_write(&memcg_cache_id_space_sem);
+
 	if (err) {
 		ida_simple_remove(&memcg_cache_ida, id);
 		return err;
@@ -2961,16 +2979,6 @@ static void memcg_free_cache_id(int id)
 	ida_simple_remove(&memcg_cache_ida, id);
 }
 
-/*
- * We should update the current array size iff all caches updates succeed. This
- * can only be done from the slab side. The slab mutex needs to be held when
- * calling this.
- */
-void memcg_update_array_size(int num)
-{
-	memcg_max_cache_ids = num;
-}
-
 static void memcg_register_cache(struct mem_cgroup *memcg,
 				 struct kmem_cache *root_cache)
 {
diff --git a/mm/slab_common.c b/mm/slab_common.c
index cc6e18437f6c..4e2b9040a49f 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -157,8 +157,8 @@ int memcg_update_all_caches(int num_memcgs)
 {
 	struct kmem_cache *s;
 	int ret = 0;
-	mutex_lock(&slab_mutex);
 
+	mutex_lock(&slab_mutex);
 	list_for_each_entry(s, &slab_caches, list) {
 		if (!is_root_cache(s))
 			continue;
@@ -169,11 +169,8 @@ int memcg_update_all_caches(int num_memcgs)
 		 * up to this point in an updated state.
 		 */
 		if (ret)
-			goto out;
+			break;
 	}
-
-	memcg_update_array_size(num_memcgs);
-out:
 	mutex_unlock(&slab_mutex);
 	return ret;
 }
@@ -290,6 +287,8 @@ kmem_cache_create(const char *name, size_t size, size_t align,
 
 	get_online_cpus();
 	get_online_mems();
+	memcg_lock_cache_id_space(); /* memcg_alloc_cache_params() needs a
+					stable value of memcg_max_cache_ids */
 
 	mutex_lock(&slab_mutex);
 
@@ -328,6 +327,7 @@ kmem_cache_create(const char *name, size_t size, size_t align,
 out_unlock:
 	mutex_unlock(&slab_mutex);
 
+	memcg_unlock_cache_id_space();
 	put_online_mems();
 	put_online_cpus();
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
