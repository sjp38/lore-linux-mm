Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 8182B6B0037
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 14:04:49 -0400 (EDT)
Received: by mail-la0-f41.google.com with SMTP id fn20so800264lab.14
        for <linux-mm@kvack.org>; Fri, 14 Jun 2013 11:04:47 -0700 (PDT)
From: Glauber Costa <glommer@gmail.com>
Subject: [PATCH v2 2/2] memcg: consolidate callers of memcg_cache_id
Date: Fri, 14 Jun 2013 14:04:36 -0400
Message-Id: <1371233076-936-3-git-send-email-glommer@openvz.org>
In-Reply-To: <1371233076-936-1-git-send-email-glommer@openvz.org>
References: <1371233076-936-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm <linux-mm@kvack.org>, cgroups <cgroups@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Glauber Costa <glommer@openvz.org>

Each caller of memcg_cache_id ends up sanitizing its parameters in its own way.
Now that the memcg_cache_id itself is more robust, we can consolidate this.

There are callers that really cannot handle anything other than a valid memcg
being passed to the function, otherwise something is seriously wrong.  In those
cases, we at least VM_BUG_ON explicitly before using the value any further

Signed-off-by: Glauber Costa <glommer@openvz.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 359a53b..adbc09b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2975,10 +2975,14 @@ static inline bool memcg_can_account_kmem(struct mem_cgroup *memcg)
 static struct kmem_cache *memcg_params_to_cache(struct memcg_cache_params *p)
 {
 	struct kmem_cache *cachep;
+	int idx;
 
 	VM_BUG_ON(p->is_root_cache);
 	cachep = p->root_cache;
-	return cachep->memcg_params->memcg_caches[memcg_cache_id(p->memcg)];
+
+	idx = memcg_cache_id(p->memcg);
+	VM_BUG_ON(idx < 0);
+	return cachep->memcg_params->memcg_caches[idx];
 }
 
 #ifdef CONFIG_SLABINFO
@@ -3246,6 +3250,7 @@ void memcg_release_cache(struct kmem_cache *s)
 
 	memcg = s->memcg_params->memcg;
 	id  = memcg_cache_id(memcg);
+	VM_BUG_ON(id < 0);
 
 	root = s->memcg_params->root_cache;
 	root->memcg_params->memcg_caches[id] = NULL;
@@ -3408,9 +3413,8 @@ static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
 	struct kmem_cache *new_cachep;
 	int idx;
 
-	BUG_ON(!memcg_can_account_kmem(memcg));
-
 	idx = memcg_cache_id(memcg);
+	BUG_ON(!idx < 0);
 
 	mutex_lock(&memcg_cache_mutex);
 	new_cachep = cachep->memcg_params->memcg_caches[idx];
@@ -3583,10 +3587,9 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep,
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
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
