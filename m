Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id AD3A46B00DF
	for <linux-mm@kvack.org>; Thu, 24 Oct 2013 08:05:22 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id un1so2509487pbc.33
        for <linux-mm@kvack.org>; Thu, 24 Oct 2013 05:05:22 -0700 (PDT)
Received: from psmtp.com ([74.125.245.169])
        by mx.google.com with SMTP id it5si802707pbc.185.2013.10.24.05.05.20
        for <linux-mm@kvack.org>;
        Thu, 24 Oct 2013 05:05:21 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v11 02/15] memcg: consolidate callers of memcg_cache_id
Date: Thu, 24 Oct 2013 16:04:53 +0400
Message-ID: <e163eb4f0f4123f3839617666f81e85ee7fbe804.1382603434.git.vdavydov@parallels.com>
In-Reply-To: <cover.1382603434.git.vdavydov@parallels.com>
References: <cover.1382603434.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: glommer@openvz.org, khorenko@parallels.com, devel@openvz.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

From: Glauber Costa <glommer@openvz.org>

Each caller of memcg_cache_id ends up sanitizing its parameters in its own way.
Now that the memcg_cache_id itself is more robust, we can consolidate this.

Also, as suggested by Michal, a special helper memcg_cache_idx is used when the
result is expected to be used directly as an array index to make sure we never
accesses in a negative index.

Signed-off-by: Glauber Costa <glommer@openvz.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   49 +++++++++++++++++++++++++++++--------------------
 1 file changed, 29 insertions(+), 20 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 0712277..0a5cc30 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2937,6 +2937,30 @@ static inline bool memcg_can_account_kmem(struct mem_cgroup *memcg)
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
@@ -2946,7 +2970,7 @@ static struct kmem_cache *memcg_params_to_cache(struct memcg_cache_params *p)
 
 	VM_BUG_ON(p->is_root_cache);
 	cachep = p->root_cache;
-	return cachep->memcg_params->memcg_caches[memcg_cache_id(p->memcg)];
+	return cachep->memcg_params->memcg_caches[memcg_cache_idx(p->memcg)];
 }
 
 #ifdef CONFIG_SLABINFO
@@ -3051,18 +3075,6 @@ void memcg_cache_list_add(struct mem_cgroup *memcg, struct kmem_cache *cachep)
 }
 
 /*
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
-/*
  * This ends up being protected by the set_limit mutex, during normal
  * operation, because that is its main call site.
  *
@@ -3224,7 +3236,7 @@ void memcg_release_cache(struct kmem_cache *s)
 		goto out;
 
 	memcg = s->memcg_params->memcg;
-	id  = memcg_cache_id(memcg);
+	id = memcg_cache_idx(memcg);
 
 	root = s->memcg_params->root_cache;
 	root->memcg_params->memcg_caches[id] = NULL;
@@ -3387,9 +3399,7 @@ static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
 	struct kmem_cache *new_cachep;
 	int idx;
 
-	BUG_ON(!memcg_can_account_kmem(memcg));
-
-	idx = memcg_cache_id(memcg);
+	idx = memcg_cache_idx(memcg);
 
 	mutex_lock(&memcg_cache_mutex);
 	new_cachep = cachep->memcg_params->memcg_caches[idx];
@@ -3562,10 +3572,9 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep,
 	rcu_read_lock();
 	memcg = mem_cgroup_from_task(rcu_dereference(current->mm->owner));
 
-	if (!memcg_can_account_kmem(memcg))
-		goto out;
-
 	idx = memcg_cache_id(memcg);
+	if (idx < 0)
+		return cachep;
 
 	/*
 	 * barrier to mare sure we're always seeing the up to date value.  The
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
