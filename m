Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 548C86B003D
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 03:45:39 -0500 (EST)
Received: by mail-la0-f42.google.com with SMTP id ec20so9698815lab.15
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 00:45:38 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id y7si35753531lal.14.2014.01.06.00.45.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 06 Jan 2014 00:45:38 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RESEND 06/11] memcg, slab: fix races in per-memcg cache creation/destruction
Date: Mon, 6 Jan 2014 12:44:57 +0400
Message-ID: <75f6caa087d0e3e9a57eb30f7675c90ebdc08dab.1388996525.git.vdavydov@parallels.com>
In-Reply-To: <cover.1388996525.git.vdavydov@parallels.com>
References: <cover.1388996525.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, akpm@linux-foundation.org
Cc: glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

We obtain a per-memcg cache from a root kmem_cache by dereferencing an
entry of the root cache's memcg_params::memcg_caches array. If we find
no cache for a memcg there on allocation, we initiate the memcg cache
creation (see memcg_kmem_get_cache()). The cache creation proceeds
asynchronously in memcg_create_kmem_cache() in order to avoid lock
clashes, so there can be several threads trying to create the same
kmem_cache concurrently, but only one of them may succeed. However, due
to a race in the code, it is not always true. The point is that the
memcg_caches array can be relocated when we activate kmem accounting for
a memcg (see memcg_update_all_caches(), memcg_update_cache_size()). If
memcg_update_cache_size() and memcg_create_kmem_cache() proceed
concurrently as described below, we can leak a kmem_cache.

Asume two threads schedule creation of the same kmem_cache. One of them
successfully creates it. Another one should fail then, but if
memcg_create_kmem_cache() interleaves with memcg_update_cache_size() as
follows, it won't:

  memcg_create_kmem_cache()             memcg_update_cache_size()
  (called w/o mutexes held)             (called with slab_mutex,
                                         set_limit_mutex held)
  -------------------------             -------------------------

  mutex_lock(&memcg_cache_mutex)

                                        s->memcg_params=kzalloc(...)

  new_cachep=cache_from_memcg_idx(cachep,idx)
  // new_cachep==NULL => proceed to creation

                                        s->memcg_params->memcg_caches[i]
                                            =cur_params->memcg_caches[i]

  // kmem_cache_create_memcg takes slab_mutex
  // so we will hang around until
  // memcg_update_cache_size finishes, but
  // nothing will prevent it from succeeding so
  // memcg_caches[idx] will be overwritten in
  // memcg_register_cache!

  new_cachep = kmem_cache_create_memcg(...)
  mutex_unlock(&memcg_cache_mutex)

Let's fix this by moving the check for existence of the memcg cache to
kmem_cache_create_memcg() to be called under the slab_mutex and make it
return NULL if so.

A similar race is possible when destroying a memcg cache (see
kmem_cache_destroy()). Since memcg_unregister_cache(), which clears the
pointer in the memcg_caches array, is called w/o protection, we can race
with memcg_update_cache_size() and omit clearing the pointer. Therefore
memcg_unregister_cache() should be moved before we release the
slab_mutex.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/memcontrol.c  |   23 ++++++++++++++---------
 mm/slab_common.c |   14 +++++++++++++-
 2 files changed, 27 insertions(+), 10 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d918626..56fc410 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3228,6 +3228,12 @@ void memcg_register_cache(struct kmem_cache *s)
 	if (is_root_cache(s))
 		return;
 
+	/*
+	 * Holding the slab_mutex assures nobody will touch the memcg_caches
+	 * array while we are modifying it.
+	 */
+	lockdep_assert_held(&slab_mutex);
+
 	root = s->memcg_params->root_cache;
 	memcg = s->memcg_params->memcg;
 	id = memcg_cache_id(memcg);
@@ -3247,6 +3253,7 @@ void memcg_register_cache(struct kmem_cache *s)
 	 * before adding it to the memcg_slab_caches list, otherwise we can
 	 * fail to convert memcg_params_to_cache() while traversing the list.
 	 */
+	VM_BUG_ON(root->memcg_params->memcg_caches[id]);
 	root->memcg_params->memcg_caches[id] = s;
 
 	mutex_lock(&memcg->slab_caches_mutex);
@@ -3263,6 +3270,12 @@ void memcg_unregister_cache(struct kmem_cache *s)
 	if (is_root_cache(s))
 		return;
 
+	/*
+	 * Holding the slab_mutex assures nobody will touch the memcg_caches
+	 * array while we are modifying it.
+	 */
+	lockdep_assert_held(&slab_mutex);
+
 	root = s->memcg_params->root_cache;
 	memcg = s->memcg_params->memcg;
 	id = memcg_cache_id(memcg);
@@ -3276,6 +3289,7 @@ void memcg_unregister_cache(struct kmem_cache *s)
 	 * after removing it from the memcg_slab_caches list, otherwise we can
 	 * fail to convert memcg_params_to_cache() while traversing the list.
 	 */
+	VM_BUG_ON(!root->memcg_params->memcg_caches[id]);
 	root->memcg_params->memcg_caches[id] = NULL;
 
 	css_put(&memcg->css);
@@ -3428,22 +3442,13 @@ static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
 						  struct kmem_cache *cachep)
 {
 	struct kmem_cache *new_cachep;
-	int idx;
 
 	BUG_ON(!memcg_can_account_kmem(memcg));
 
-	idx = memcg_cache_id(memcg);
-
 	mutex_lock(&memcg_cache_mutex);
-	new_cachep = cache_from_memcg_idx(cachep, idx);
-	if (new_cachep)
-		goto out;
-
 	new_cachep = kmem_cache_dup(memcg, cachep);
 	if (new_cachep == NULL)
 		new_cachep = cachep;
-
-out:
 	mutex_unlock(&memcg_cache_mutex);
 	return new_cachep;
 }
diff --git a/mm/slab_common.c b/mm/slab_common.c
index db24ec4..f34707e 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -180,6 +180,18 @@ kmem_cache_create_memcg(struct mem_cgroup *memcg, const char *name, size_t size,
 	if (err)
 		goto out_unlock;
 
+	if (memcg) {
+		/*
+		 * Since per-memcg caches are created asynchronously on first
+		 * allocation (see memcg_kmem_get_cache()), several threads can
+		 * try to create the same cache, but only one of them may
+		 * succeed. Therefore if we get here and see the cache has
+		 * already been created, we silently return NULL.
+		 */
+		if (cache_from_memcg_idx(parent_cache, memcg_cache_id(memcg)))
+			goto out_unlock;
+	}
+
 	/*
 	 * Some allocators will constraint the set of valid flags to a subset
 	 * of all flags. We expect them to define CACHE_CREATE_MASK in this
@@ -261,11 +273,11 @@ void kmem_cache_destroy(struct kmem_cache *s)
 		list_del(&s->list);
 
 		if (!__kmem_cache_shutdown(s)) {
+			memcg_unregister_cache(s);
 			mutex_unlock(&slab_mutex);
 			if (s->flags & SLAB_DESTROY_BY_RCU)
 				rcu_barrier();
 
-			memcg_unregister_cache(s);
 			memcg_free_cache_params(s);
 			kfree(s->name);
 			kmem_cache_free(kmem_cache, s);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
