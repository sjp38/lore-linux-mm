Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id B8B996B0038
	for <linux-mm@kvack.org>; Sun,  7 Jul 2013 11:57:13 -0400 (EDT)
Received: by mail-la0-f48.google.com with SMTP id lx15so3094173lab.7
        for <linux-mm@kvack.org>; Sun, 07 Jul 2013 08:57:11 -0700 (PDT)
From: Glauber Costa <glommer@gmail.com>
Subject: [PATCH v10 02/16] memcg: consolidate callers of memcg_cache_id
Date: Sun,  7 Jul 2013 11:56:42 -0400
Message-Id: <1373212616-11713-3-git-send-email-glommer@openvz.org>
In-Reply-To: <1373212616-11713-1-git-send-email-glommer@openvz.org>
References: <1373212616-11713-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, mgorman@suse.de, david@fromorbit.com, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com, akpm@linux-foundation.org, Glauber Costa <glommer@gmail.com>, Glauber Costa <glommer@openvz.org>, Michal Hocko <mhocko@suse.cz>

From: Glauber Costa <glommer@gmail.com>

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
 mm/memcontrol.c | 49 +++++++++++++++++++++++++++++--------------------
 1 file changed, 29 insertions(+), 20 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 506ad46..f524332 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2941,6 +2941,30 @@ static inline bool memcg_can_account_kmem(struct mem_cgroup *memcg)
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
@@ -2950,7 +2974,7 @@ static struct kmem_cache *memcg_params_to_cache(struct memcg_cache_params *p)
 
 	VM_BUG_ON(p->is_root_cache);
 	cachep = p->root_cache;
-	return cachep->memcg_params->memcg_caches[memcg_cache_id(p->memcg)];
+	return cachep->memcg_params->memcg_caches[memcg_cache_idx(p->memcg)];
 }
 
 #ifdef CONFIG_SLABINFO
@@ -3055,18 +3079,6 @@ void memcg_cache_list_add(struct mem_cgroup *memcg, struct kmem_cache *cachep)
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
@@ -3225,7 +3237,7 @@ void memcg_release_cache(struct kmem_cache *s)
 		goto out;
 
 	memcg = s->memcg_params->memcg;
-	id  = memcg_cache_id(memcg);
+	id  = memcg_cache_idx(memcg);
 
 	root = s->memcg_params->root_cache;
 	root->memcg_params->memcg_caches[id] = NULL;
@@ -3388,9 +3400,7 @@ static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
 	struct kmem_cache *new_cachep;
 	int idx;
 
-	BUG_ON(!memcg_can_account_kmem(memcg));
-
-	idx = memcg_cache_id(memcg);
+	idx = memcg_cache_idx(memcg);
 
 	mutex_lock(&memcg_cache_mutex);
 	new_cachep = cachep->memcg_params->memcg_caches[idx];
@@ -3563,10 +3573,9 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep,
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
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
