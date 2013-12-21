Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 4E61A6B003A
	for <linux-mm@kvack.org>; Sat, 21 Dec 2013 10:54:26 -0500 (EST)
Received: by mail-la0-f53.google.com with SMTP id mc6so1631134lab.12
        for <linux-mm@kvack.org>; Sat, 21 Dec 2013 07:54:25 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id rc10si5266600lbb.179.2013.12.21.07.54.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 21 Dec 2013 07:54:24 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 04/11] memcg, slab: fix barrier usage when accessing memcg_caches
Date: Sat, 21 Dec 2013 19:53:55 +0400
Message-ID: <519657f631ee090942106f77f203c2b9e3453345.1387640542.git.vdavydov@parallels.com>
In-Reply-To: <cover.1387640541.git.vdavydov@parallels.com>
References: <cover.1387640541.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: glommer@gmail.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

Each root kmem_cache has pointers to per-memcg caches stored in its
memcg_params::memcg_caches array. Whenever we want to allocate a slab
for a memcg, we access this array to get per-memcg cache to allocate
from (see memcg_kmem_get_cache()). The access must be lock-free for
performance reasons, so we should use barriers to assert the kmem_cache
is up-to-date.

First, we should place a write barrier immediately before setting the
pointer to it in the memcg_caches array in order to make sure nobody
will see a partially initialized object. Second, we should issue a read
barrier before dereferencing the pointer to conform to the write
barrier.

However, currently the barrier usage looks rather strange. We have a
write barrier *after* setting the pointer and a read barrier *before*
reading the pointer, which is incorrect. This patch fixes this.

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
 mm/memcontrol.c |   24 ++++++++++--------------
 mm/slab.h       |   12 +++++++++++-
 2 files changed, 21 insertions(+), 15 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f8eb994..999e7d4 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3238,12 +3238,14 @@ void memcg_register_cache(struct kmem_cache *s)
 	list_add(&s->memcg_params->list, &memcg->memcg_slab_caches);
 	mutex_unlock(&memcg->slab_caches_mutex);
 
-	root->memcg_params->memcg_caches[id] = s;
 	/*
-	 * the readers won't lock, make sure everybody sees the updated value,
-	 * so they won't put stuff in the queue again for no reason
+	 * Since readers won't lock (see cache_from_memcg_idx()), we need a
+	 * barrier here to ensure nobody will see the kmem_cache partially
+	 * initialized.
 	 */
-	wmb();
+	smp_wmb();
+
+	root->memcg_params->memcg_caches[id] = s;
 }
 
 void memcg_unregister_cache(struct kmem_cache *s)
@@ -3569,7 +3571,7 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep,
 					  gfp_t gfp)
 {
 	struct mem_cgroup *memcg;
-	int idx;
+	struct kmem_cache *memcg_cachep;
 
 	VM_BUG_ON(!cachep->memcg_params);
 	VM_BUG_ON(!cachep->memcg_params->is_root_cache);
@@ -3583,15 +3585,9 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep,
 	if (!memcg_can_account_kmem(memcg))
 		goto out;
 
-	idx = memcg_cache_id(memcg);
-
-	/*
-	 * barrier to mare sure we're always seeing the up to date value.  The
-	 * code updating memcg_caches will issue a write barrier to match this.
-	 */
-	read_barrier_depends();
-	if (likely(cache_from_memcg_idx(cachep, idx))) {
-		cachep = cache_from_memcg_idx(cachep, idx);
+	memcg_cachep = cache_from_memcg_idx(cachep, memcg_cache_id(memcg));
+	if (likely(memcg_cachep)) {
+		cachep = memcg_cachep;
 		goto out;
 	}
 
diff --git a/mm/slab.h b/mm/slab.h
index 0859c42..72d1f9d 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -163,9 +163,19 @@ static inline const char *cache_name(struct kmem_cache *s)
 static inline struct kmem_cache *
 cache_from_memcg_idx(struct kmem_cache *s, int idx)
 {
+	struct kmem_cache *cachep;
+
 	if (!s->memcg_params)
 		return NULL;
-	return s->memcg_params->memcg_caches[idx];
+	cachep = s->memcg_params->memcg_caches[idx];
+
+	/*
+	 * Make sure we will access the up-to-date value. The code updating
+	 * memcg_caches issues a write barrier to match this (see
+	 * memcg_register_cache()).
+	 */
+	smp_read_barrier_depends();
+	return cachep;
 }
 
 static inline struct kmem_cache *memcg_root_cache(struct kmem_cache *s)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
