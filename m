Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id DDCF56B0254
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 12:02:57 -0400 (EDT)
Received: by lbcao8 with SMTP id ao8so52969744lbc.3
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 09:02:57 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id m188si3501230lfe.38.2015.10.08.09.02.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Oct 2015 09:02:56 -0700 (PDT)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH 1/3] slab_common: rename cache create/destroy helpers
Date: Thu, 8 Oct 2015 19:02:39 +0300
Message-ID: <6a18aab2f1c3088377d7fd2207b4cc1a1a743468.1444319304.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

do_kmem_cache_create, do_kmem_cache_shutdown, and do_kmem_cache_release
sound awkward for static helper functions that are not supposed to be
used outside slab_common.c. Rename them to create_cache, shutdown_cache,
and release_caches, respectively. This patch is a pure cleanup and does
not introduce any functional changes.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 mm/slab_common.c | 37 ++++++++++++++++++-------------------
 1 file changed, 18 insertions(+), 19 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 113a6fd597db..c8d2ed7f8330 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -316,10 +316,10 @@ unsigned long calculate_alignment(unsigned long flags,
 	return ALIGN(align, sizeof(void *));
 }
 
-static struct kmem_cache *
-do_kmem_cache_create(const char *name, size_t object_size, size_t size,
-		     size_t align, unsigned long flags, void (*ctor)(void *),
-		     struct mem_cgroup *memcg, struct kmem_cache *root_cache)
+static struct kmem_cache *create_cache(const char *name,
+		size_t object_size, size_t size, size_t align,
+		unsigned long flags, void (*ctor)(void *),
+		struct mem_cgroup *memcg, struct kmem_cache *root_cache)
 {
 	struct kmem_cache *s;
 	int err;
@@ -418,9 +418,9 @@ kmem_cache_create(const char *name, size_t size, size_t align,
 		goto out_unlock;
 	}
 
-	s = do_kmem_cache_create(cache_name, size, size,
-				 calculate_alignment(flags, align, size),
-				 flags, ctor, NULL, NULL);
+	s = create_cache(cache_name, size, size,
+			 calculate_alignment(flags, align, size),
+			 flags, ctor, NULL, NULL);
 	if (IS_ERR(s)) {
 		err = PTR_ERR(s);
 		kfree_const(cache_name);
@@ -448,7 +448,7 @@ out_unlock:
 }
 EXPORT_SYMBOL(kmem_cache_create);
 
-static int do_kmem_cache_shutdown(struct kmem_cache *s,
+static int shutdown_cache(struct kmem_cache *s,
 		struct list_head *release, bool *need_rcu_barrier)
 {
 	if (__kmem_cache_shutdown(s) != 0) {
@@ -469,8 +469,7 @@ static int do_kmem_cache_shutdown(struct kmem_cache *s,
 	return 0;
 }
 
-static void do_kmem_cache_release(struct list_head *release,
-				  bool need_rcu_barrier)
+static void release_caches(struct list_head *release, bool need_rcu_barrier)
 {
 	struct kmem_cache *s, *s2;
 
@@ -536,10 +535,10 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
 	if (!cache_name)
 		goto out_unlock;
 
-	s = do_kmem_cache_create(cache_name, root_cache->object_size,
-				 root_cache->size, root_cache->align,
-				 root_cache->flags, root_cache->ctor,
-				 memcg, root_cache);
+	s = create_cache(cache_name, root_cache->object_size,
+			 root_cache->size, root_cache->align,
+			 root_cache->flags, root_cache->ctor,
+			 memcg, root_cache);
 	/*
 	 * If we could not create a memcg cache, do not complain, because
 	 * that's not critical at all as we can always proceed with the root
@@ -615,14 +614,14 @@ void memcg_destroy_kmem_caches(struct mem_cgroup *memcg)
 		 * The cgroup is about to be freed and therefore has no charges
 		 * left. Hence, all its caches must be empty by now.
 		 */
-		BUG_ON(do_kmem_cache_shutdown(s, &release, &need_rcu_barrier));
+		BUG_ON(shutdown_cache(s, &release, &need_rcu_barrier));
 	}
 	mutex_unlock(&slab_mutex);
 
 	put_online_mems();
 	put_online_cpus();
 
-	do_kmem_cache_release(&release, need_rcu_barrier);
+	release_caches(&release, need_rcu_barrier);
 }
 #endif /* CONFIG_MEMCG_KMEM */
 
@@ -655,12 +654,12 @@ void kmem_cache_destroy(struct kmem_cache *s)
 		goto out_unlock;
 
 	for_each_memcg_cache_safe(c, c2, s) {
-		if (do_kmem_cache_shutdown(c, &release, &need_rcu_barrier))
+		if (shutdown_cache(c, &release, &need_rcu_barrier))
 			busy = true;
 	}
 
 	if (!busy)
-		do_kmem_cache_shutdown(s, &release, &need_rcu_barrier);
+		shutdown_cache(s, &release, &need_rcu_barrier);
 
 out_unlock:
 	mutex_unlock(&slab_mutex);
@@ -668,7 +667,7 @@ out_unlock:
 	put_online_mems();
 	put_online_cpus();
 
-	do_kmem_cache_release(&release, need_rcu_barrier);
+	release_caches(&release, need_rcu_barrier);
 }
 EXPORT_SYMBOL(kmem_cache_destroy);
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
