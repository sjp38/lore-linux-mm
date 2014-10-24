Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7FC2C6B0073
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 06:38:09 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id lj1so922059pab.18
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 03:38:09 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id se6si3990933pac.1.2014.10.24.03.38.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Oct 2014 03:38:08 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v2 5/9] memcg: add rwsem to sync against memcg_caches arrays relocation
Date: Fri, 24 Oct 2014 14:37:36 +0400
Message-ID: <aa1d5e1a2453738487eafc66bcef3cc566455aeb.1414145863.git.vdavydov@parallels.com>
In-Reply-To: <cover.1414145862.git.vdavydov@parallels.com>
References: <cover.1414145862.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@gmail.com>, Dave Chinner <david@fromorbit.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

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
index e1a894c1018f..eebb56b94d23 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -395,8 +395,13 @@ extern struct static_key memcg_kmem_enabled_key;
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
 
 /*
  * Helper macro to loop through all memcg-specific caches. Callers must still
@@ -433,8 +438,6 @@ void __memcg_kmem_uncharge_pages(struct page *page, int order);
 
 int memcg_cache_id(struct mem_cgroup *memcg);
 
-void memcg_update_array_size(int num_groups);
-
 struct kmem_cache *
 __memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
 
@@ -571,6 +574,14 @@ static inline int memcg_cache_id(struct mem_cgroup *memcg)
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
index fc1e2067a4c4..444bf8fe5f1d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -595,6 +595,19 @@ static void disarm_sock_keys(struct mem_cgroup *memcg)
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
@@ -2599,6 +2612,7 @@ static int memcg_alloc_cache_id(void)
 	 * There's no space for the new id in memcg_caches arrays,
 	 * so we have to grow them.
 	 */
+	down_write(&memcg_cache_id_space_sem);
 
 	size = 2 * (id + 1);
 	if (size < MEMCG_CACHES_MIN_SIZE)
@@ -2610,6 +2624,10 @@ static int memcg_alloc_cache_id(void)
 	err = memcg_update_all_caches(size);
 	mutex_unlock(&memcg_slab_mutex);
 
+	if (!err)
+		memcg_max_cache_ids = size;
+	up_write(&memcg_cache_id_space_sem);
+
 	if (err) {
 		ida_simple_remove(&memcg_cache_ida, id);
 		return err;
@@ -2622,16 +2640,6 @@ static void memcg_free_cache_id(int id)
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
index 41fe0ad199f2..879c1a8c54ba 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -169,8 +169,8 @@ int memcg_update_all_caches(int num_memcgs)
 {
 	struct kmem_cache *s;
 	int ret = 0;
-	mutex_lock(&slab_mutex);
 
+	mutex_lock(&slab_mutex);
 	list_for_each_entry(s, &slab_caches, list) {
 		if (!is_root_cache(s))
 			continue;
@@ -181,11 +181,8 @@ int memcg_update_all_caches(int num_memcgs)
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
@@ -365,6 +362,8 @@ kmem_cache_create(const char *name, size_t size, size_t align,
 
 	get_online_cpus();
 	get_online_mems();
+	memcg_lock_cache_id_space(); /* memcg_alloc_cache_params() needs a
+					stable value of memcg_max_cache_ids */
 
 	mutex_lock(&slab_mutex);
 
@@ -403,6 +402,7 @@ kmem_cache_create(const char *name, size_t size, size_t align,
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
