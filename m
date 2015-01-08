Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 02EFB6B0072
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 05:53:51 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id ey11so11058733pad.10
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 02:53:50 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id sy7si8031873pbc.64.2015.01.08.02.53.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Jan 2015 02:53:48 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v3 5/9] memcg: add rwsem to synchronize against memcg_caches arrays relocation
Date: Thu, 8 Jan 2015 13:53:15 +0300
Message-ID: <22cba600b9f6b1a71c68acf21c6e221410e095f6.1420711973.git.vdavydov@parallels.com>
In-Reply-To: <cover.1420711973.git.vdavydov@parallels.com>
References: <cover.1420711973.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@gmail.com>, Dave Chinner <david@fromorbit.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

We need a stable value of memcg_nr_cache_ids in kmem_cache_create()
(memcg_alloc_cache_params() wants it for root caches), where we only
hold the slab_mutex and no memcg-related locks. As a result, we have to
update memcg_nr_cache_ids under the slab_mutex, which we can only take
on the slab's side (see memcg_update_array_size). This looks awkward and
will become even worse when per-memcg list_lru is introduced, which also
wants stable access to memcg_nr_cache_ids.

To get rid of this dependency between the memcg_nr_cache_ids and the
slab_mutex, this patch introduces a special rwsem. The rwsem is held for
writing during memcg_caches arrays relocation and memcg_nr_cache_ids
updates. Therefore one can take it for reading to get a stable access to
memcg_caches arrays and/or memcg_nr_cache_ids.

Currently the semaphore is taken for reading only from
kmem_cache_create, right before taking the slab_mutex, so right now
there's no much point in using rwsem instead of mutex. However, once
list_lru is made per-memcg it will allow list_lru initializations to
proceed concurrently.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/memcontrol.h |   12 ++++++++++--
 mm/memcontrol.c            |   29 +++++++++++++++++++----------
 mm/slab_common.c           |    9 ++++-----
 3 files changed, 33 insertions(+), 17 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index b27f183e65cd..8dafad6bb248 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -361,6 +361,8 @@ static inline void sock_release_memcg(struct sock *sk)
 extern struct static_key memcg_kmem_enabled_key;
 
 extern int memcg_nr_cache_ids;
+extern void memcg_get_cache_ids(void);
+extern void memcg_put_cache_ids(void);
 
 /*
  * Helper macro to loop through all memcg-specific caches. Callers must still
@@ -396,8 +398,6 @@ void __memcg_kmem_uncharge_pages(struct page *page, int order);
 
 int memcg_cache_id(struct mem_cgroup *memcg);
 
-void memcg_update_array_size(int num_groups);
-
 struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep);
 void __memcg_kmem_put_cache(struct kmem_cache *cachep);
 
@@ -531,6 +531,14 @@ static inline int memcg_cache_id(struct mem_cgroup *memcg)
 	return -1;
 }
 
+static inline void memcg_get_cache_ids(void)
+{
+}
+
+static inline void memcg_put_cache_ids(void)
+{
+}
+
 static inline struct kmem_cache *
 memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 355e72b01ad6..3596f44875c1 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -570,6 +570,19 @@ static void disarm_sock_keys(struct mem_cgroup *memcg)
 static DEFINE_IDA(memcg_cache_ida);
 int memcg_nr_cache_ids;
 
+/* Protects memcg_nr_cache_ids */
+static DECLARE_RWSEM(memcg_cache_ids_sem);
+
+void memcg_get_cache_ids(void)
+{
+	down_read(&memcg_cache_ids_sem);
+}
+
+void memcg_put_cache_ids(void)
+{
+	up_read(&memcg_cache_ids_sem);
+}
+
 /*
  * MIN_SIZE is different than 1, because we would like to avoid going through
  * the alloc/free process all the time. In a small machine, 4 kmem-limited
@@ -2558,6 +2571,7 @@ static int memcg_alloc_cache_id(void)
 	 * There's no space for the new id in memcg_caches arrays,
 	 * so we have to grow them.
 	 */
+	down_write(&memcg_cache_ids_sem);
 
 	size = 2 * (id + 1);
 	if (size < MEMCG_CACHES_MIN_SIZE)
@@ -2566,6 +2580,11 @@ static int memcg_alloc_cache_id(void)
 		size = MEMCG_CACHES_MAX_SIZE;
 
 	err = memcg_update_all_caches(size);
+	if (!err)
+		memcg_nr_cache_ids = size;
+
+	up_write(&memcg_cache_ids_sem);
+
 	if (err) {
 		ida_simple_remove(&memcg_cache_ida, id);
 		return err;
@@ -2578,16 +2597,6 @@ static void memcg_free_cache_id(int id)
 	ida_simple_remove(&memcg_cache_ida, id);
 }
 
-/*
- * We should update the current array size iff all caches updates succeed. This
- * can only be done from the slab side. The slab mutex needs to be held when
- * calling this.
- */
-void memcg_update_array_size(int num)
-{
-	memcg_nr_cache_ids = num;
-}
-
 struct memcg_kmem_cache_create_work {
 	struct mem_cgroup *memcg;
 	struct kmem_cache *cachep;
diff --git a/mm/slab_common.c b/mm/slab_common.c
index d6cf88c2739f..42bb22cb4219 100644
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
@@ -369,6 +366,7 @@ kmem_cache_create(const char *name, size_t size, size_t align,
 
 	get_online_cpus();
 	get_online_mems();
+	memcg_get_cache_ids();
 
 	mutex_lock(&slab_mutex);
 
@@ -407,6 +405,7 @@ kmem_cache_create(const char *name, size_t size, size_t align,
 out_unlock:
 	mutex_unlock(&slab_mutex);
 
+	memcg_put_cache_ids();
 	put_online_mems();
 	put_online_cpus();
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
