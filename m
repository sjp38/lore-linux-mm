Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 717926B0036
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 13:39:37 -0500 (EST)
Received: by mail-lb0-f172.google.com with SMTP id c11so653994lbj.3
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 10:39:36 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id g9si6045768lam.48.2014.02.05.10.39.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Feb 2014 10:39:35 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v15 02/13] memcg: consolidate callers of memcg_cache_id
Date: Wed, 5 Feb 2014 22:39:18 +0400
Message-ID: <06051a312a856bd1c179d71457d1f0057f9e2491.1391624021.git.vdavydov@parallels.com>
In-Reply-To: <cover.1391624021.git.vdavydov@parallels.com>
References: <cover.1391624021.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: dchinner@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, glommer@gmail.com, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Glauber Costa <glommer@openvz.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

From: Glauber Costa <glommer@openvz.org>

Each caller of memcg_cache_id ends up sanitizing its parameters in its own way.
Now that the memcg_cache_id itself is more robust, we can consolidate this.

Also, as suggested by Michal, a special helper memcg_cache_idx is used when the
result is expected to be used directly as an array index to make sure we never
access in a negative index.

Signed-off-by: Glauber Costa <glommer@openvz.org>
Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   48 +++++++++++++++++++++++++++++++-----------------
 1 file changed, 31 insertions(+), 17 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 75758fc5c50c..9d1245dc993a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3008,6 +3008,30 @@ static inline bool memcg_can_account_kmem(struct mem_cgroup *memcg)
 }
 
 /*
+ * helper for acessing a memcg's index. It will be used as an index in the
+ * child cache array in kmem_cache, and also to derive its name. This function
+ * will return -1 when this is not a kmem-limited memcg.
+ */
+int memcg_cache_id(struct mem_cgroup *memcg)
+{
+	if (!memcg || !memcg_can_account_kmem(memcg))
+		return -1;
+	return memcg->kmemcg_id;
+}
+
+/*
+ * This helper around memcg_cache_id is not intented for use outside memcg
+ * core. It is meant for places where the cache id is used directly as an array
+ * index
+ */
+static int memcg_cache_idx(struct mem_cgroup *memcg)
+{
+	int ret = memcg_cache_id(memcg);
+	BUG_ON(ret < 0);
+	return ret;
+}
+
+/*
  * This is a bit cumbersome, but it is rarely used and avoids a backpointer
  * in the memcg_cache_params struct.
  */
@@ -3017,7 +3041,7 @@ static struct kmem_cache *memcg_params_to_cache(struct memcg_cache_params *p)
 
 	VM_BUG_ON(p->is_root_cache);
 	cachep = p->root_cache;
-	return cache_from_memcg_idx(cachep, memcg_cache_id(p->memcg));
+	return cache_from_memcg_idx(cachep, memcg_cache_idx(p->memcg));
 }
 
 #ifdef CONFIG_SLABINFO
@@ -3103,18 +3127,6 @@ static void memcg_uncharge_kmem(struct mem_cgroup *memcg, u64 size)
 		css_put(&memcg->css);
 }
 
-/*
- * helper for acessing a memcg's index. It will be used as an index in the
- * child cache array in kmem_cache, and also to derive its name. This function
- * will return -1 when this is not a kmem-limited memcg.
- */
-int memcg_cache_id(struct mem_cgroup *memcg)
-{
-	if (!memcg || !memcg_can_account_kmem(memcg))
-		return -1;
-	return memcg->kmemcg_id;
-}
-
 static size_t memcg_caches_array_size(int num_groups)
 {
 	ssize_t size;
@@ -3246,7 +3258,7 @@ void memcg_register_cache(struct kmem_cache *s)
 
 	root = s->memcg_params->root_cache;
 	memcg = s->memcg_params->memcg;
-	id = memcg_cache_id(memcg);
+	id = memcg_cache_idx(memcg);
 
 	css_get(&memcg->css);
 
@@ -3288,7 +3300,7 @@ void memcg_unregister_cache(struct kmem_cache *s)
 
 	root = s->memcg_params->root_cache;
 	memcg = s->memcg_params->memcg;
-	id = memcg_cache_id(memcg);
+	id = memcg_cache_idx(memcg);
 
 	mutex_lock(&memcg->slab_caches_mutex);
 	list_del(&s->memcg_params->list);
@@ -3573,6 +3585,7 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep,
 {
 	struct mem_cgroup *memcg;
 	struct kmem_cache *memcg_cachep;
+	int id;
 
 	VM_BUG_ON(!cachep->memcg_params);
 	VM_BUG_ON(!cachep->memcg_params->is_root_cache);
@@ -3583,10 +3596,11 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep,
 	rcu_read_lock();
 	memcg = mem_cgroup_from_task(rcu_dereference(current->mm->owner));
 
-	if (!memcg_can_account_kmem(memcg))
+	id = memcg_cache_id(memcg);
+	if (id < 0)
 		goto out;
 
-	memcg_cachep = cache_from_memcg_idx(cachep, memcg_cache_id(memcg));
+	memcg_cachep = cache_from_memcg_idx(cachep, id);
 	if (likely(memcg_cachep)) {
 		cachep = memcg_cachep;
 		goto out;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
