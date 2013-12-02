Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 9F9076B006C
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 06:20:02 -0500 (EST)
Received: by mail-lb0-f179.google.com with SMTP id l4so8215902lbv.24
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 03:20:01 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id yf5si18900181lab.107.2013.12.02.03.20.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Dec 2013 03:20:01 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v12 02/18] memcg: consolidate callers of memcg_cache_id
Date: Mon, 2 Dec 2013 15:19:37 +0400
Message-ID: <1fc239729f563958c3200920af4e7845e2a6c798.1385974612.git.vdavydov@parallels.com>
In-Reply-To: <cover.1385974612.git.vdavydov@parallels.com>
References: <cover.1385974612.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@suse.cz, dchinner@redhat.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, vdavydov@parallels.com, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

From: Glauber Costa <glommer@openvz.org>

Each caller of memcg_cache_id ends up sanitizing its parameters in its own way.
Now that the memcg_cache_id itself is more robust, we can consolidate this.

Also, as suggested by Michal, a special helper memcg_cache_idx is used when the
result is expected to be used directly as an array index to make sure we never
accesses in a negative index.

Signed-off-by: Glauber Costa <glommer@openvz.org>
Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   49 +++++++++++++++++++++++++++++--------------------
 1 file changed, 29 insertions(+), 20 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 02b5176..144cb4c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2960,6 +2960,30 @@ static inline bool memcg_can_account_kmem(struct mem_cgroup *memcg)
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
@@ -2969,7 +2993,7 @@ static struct kmem_cache *memcg_params_to_cache(struct memcg_cache_params *p)
 
 	VM_BUG_ON(p->is_root_cache);
 	cachep = p->root_cache;
-	return cache_from_memcg_idx(cachep, memcg_cache_id(p->memcg));
+	return cache_from_memcg_idx(cachep, memcg_cache_idx(p->memcg));
 }
 
 #ifdef CONFIG_SLABINFO
@@ -3067,18 +3091,6 @@ void memcg_cache_list_add(struct mem_cgroup *memcg, struct kmem_cache *cachep)
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
@@ -3240,7 +3252,7 @@ void memcg_release_cache(struct kmem_cache *s)
 		goto out;
 
 	memcg = s->memcg_params->memcg;
-	id  = memcg_cache_id(memcg);
+	id = memcg_cache_idx(memcg);
 
 	root = s->memcg_params->root_cache;
 	root->memcg_params->memcg_caches[id] = NULL;
@@ -3403,9 +3415,7 @@ static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
 	struct kmem_cache *new_cachep;
 	int idx;
 
-	BUG_ON(!memcg_can_account_kmem(memcg));
-
-	idx = memcg_cache_id(memcg);
+	idx = memcg_cache_idx(memcg);
 
 	mutex_lock(&memcg_cache_mutex);
 	new_cachep = cache_from_memcg_idx(cachep, idx);
@@ -3578,10 +3588,9 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep,
 	rcu_read_lock();
 	memcg = mem_cgroup_from_task(rcu_dereference(current->mm->owner));
 
-	if (!memcg_can_account_kmem(memcg))
-		goto out;
-
 	idx = memcg_cache_id(memcg);
+	if (idx < 0)
+		goto out;
 
 	/*
 	 * barrier to mare sure we're always seeing the up to date value.  The
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
