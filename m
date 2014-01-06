Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id 5967C6B003B
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 03:45:35 -0500 (EST)
Received: by mail-lb0-f175.google.com with SMTP id w6so9655076lbh.34
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 00:45:34 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id rc10si35757242lbb.89.2014.01.06.00.45.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 06 Jan 2014 00:45:34 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RESEND 05/11] memcg: fix possible NULL deref while traversing memcg_slab_caches list
Date: Mon, 6 Jan 2014 12:44:56 +0400
Message-ID: <a50a6ead66e13ff257441a6d01e60185b4f9c1fe.1388996525.git.vdavydov@parallels.com>
In-Reply-To: <cover.1388996525.git.vdavydov@parallels.com>
References: <cover.1388996525.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, akpm@linux-foundation.org
Cc: glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

All caches of the same memory cgroup are linked in the memcg_slab_caches
list via kmem_cache::memcg_params::list. This list is traversed, for
example, when we read memory.kmem.slabinfo. Since the list actually
consists of memcg_cache_params objects, we have to convert an element of
the list to a kmem_cache object using memcg_params_to_cache(), which
obtains the pointer to the cache from the memcg_params::memcg_caches
array of the corresponding root cache. That said the pointer to a
kmem_cache in its parent's memcg_params must be initialized before
adding the cache to the list, and cleared only after it has been
unlinked. Currently it is vice-versa, which can result in a NULL ptr
dereference while traversing the memcg_slab_caches list. This patch
restores the correct order.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/memcontrol.c |   25 ++++++++++++++++++-------
 1 file changed, 18 insertions(+), 7 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 999e7d4..d918626 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3234,9 +3234,6 @@ void memcg_register_cache(struct kmem_cache *s)
 
 	css_get(&memcg->css);
 
-	mutex_lock(&memcg->slab_caches_mutex);
-	list_add(&s->memcg_params->list, &memcg->memcg_slab_caches);
-	mutex_unlock(&memcg->slab_caches_mutex);
 
 	/*
 	 * Since readers won't lock (see cache_from_memcg_idx()), we need a
@@ -3245,7 +3242,16 @@ void memcg_register_cache(struct kmem_cache *s)
 	 */
 	smp_wmb();
 
+	/*
+	 * Initialize the pointer to this cache in its parent's memcg_params
+	 * before adding it to the memcg_slab_caches list, otherwise we can
+	 * fail to convert memcg_params_to_cache() while traversing the list.
+	 */
 	root->memcg_params->memcg_caches[id] = s;
+
+	mutex_lock(&memcg->slab_caches_mutex);
+	list_add(&s->memcg_params->list, &memcg->memcg_slab_caches);
+	mutex_unlock(&memcg->slab_caches_mutex);
 }
 
 void memcg_unregister_cache(struct kmem_cache *s)
@@ -3257,16 +3263,21 @@ void memcg_unregister_cache(struct kmem_cache *s)
 	if (is_root_cache(s))
 		return;
 
-	memcg = s->memcg_params->memcg;
-	id  = memcg_cache_id(memcg);
-
 	root = s->memcg_params->root_cache;
-	root->memcg_params->memcg_caches[id] = NULL;
+	memcg = s->memcg_params->memcg;
+	id = memcg_cache_id(memcg);
 
 	mutex_lock(&memcg->slab_caches_mutex);
 	list_del(&s->memcg_params->list);
 	mutex_unlock(&memcg->slab_caches_mutex);
 
+	/*
+	 * Clear the pointer to this cache in its parent's memcg_params only
+	 * after removing it from the memcg_slab_caches list, otherwise we can
+	 * fail to convert memcg_params_to_cache() while traversing the list.
+	 */
+	root->memcg_params->memcg_caches[id] = NULL;
+
 	css_put(&memcg->css);
 }
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
