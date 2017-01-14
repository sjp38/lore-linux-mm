Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id BCAB86B025E
	for <linux-mm@kvack.org>; Sat, 14 Jan 2017 00:55:01 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id n189so4453603pga.4
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 21:55:01 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id z72si14728017pgd.233.2017.01.13.21.55.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jan 2017 21:55:00 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id 204so343663pge.2
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 21:55:00 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 3/9] slab: simplify shutdown_memcg_caches()
Date: Sat, 14 Jan 2017 00:54:43 -0500
Message-Id: <20170114055449.11044-4-tj@kernel.org>
In-Reply-To: <20170114055449.11044-1-tj@kernel.org>
References: <20170114055449.11044-1-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vdavydov.dev@gmail.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com, Tejun Heo <tj@kernel.org>

shutdown_memcg_caches() shuts down all memcg caches associated with a
root cache.  It first walks the index table clearing and shutting down
each entry and then shuts down the ones on
root_cache->memcg_params.list.  As active caches are on both the table
and the list, they're stashed away from the list to avoid shutting
down twice and then get spliced back later.

This is unnecessarily complication.  All memcg caches are on
root_cache->memcg_params.list.  The function can simply clear the
index table and shut down all caches on the list.  There's no need to
muck with temporary stashing.

Simplify the code.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/slab_common.c | 32 +++++---------------------------
 1 file changed, 5 insertions(+), 27 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 851c75e..45aa67c 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -634,48 +634,26 @@ static int shutdown_memcg_caches(struct kmem_cache *s)
 {
 	struct memcg_cache_array *arr;
 	struct kmem_cache *c, *c2;
-	LIST_HEAD(busy);
 	int i;
 
 	BUG_ON(!is_root_cache(s));
 
 	/*
-	 * First, shutdown active caches, i.e. caches that belong to online
-	 * memory cgroups.
+	 * First, clear the pointers to all memcg caches so that they will
+	 * never be accessed even if the root cache stays alive.
 	 */
 	arr = rcu_dereference_protected(s->memcg_params.memcg_caches,
 					lockdep_is_held(&slab_mutex));
-	for_each_memcg_cache_index(i) {
-		c = arr->entries[i];
-		if (!c)
-			continue;
-		if (shutdown_cache(c))
-			/*
-			 * The cache still has objects. Move it to a temporary
-			 * list so as not to try to destroy it for a second
-			 * time while iterating over inactive caches below.
-			 */
-			list_move(&c->memcg_params.list, &busy);
-		else
-			/*
-			 * The cache is empty and will be destroyed soon. Clear
-			 * the pointer to it in the memcg_caches array so that
-			 * it will never be accessed even if the root cache
-			 * stays alive.
-			 */
-			arr->entries[i] = NULL;
-	}
+	for_each_memcg_cache_index(i)
+		arr->entries[i] = NULL;
 
 	/*
-	 * Second, shutdown all caches left from memory cgroups that are now
-	 * offline.
+	 * Shutdown all caches.
 	 */
 	list_for_each_entry_safe(c, c2, &s->memcg_params.list,
 				 memcg_params.list)
 		shutdown_cache(c);
 
-	list_splice(&busy, &s->memcg_params.list);
-
 	/*
 	 * A cache being destroyed must be empty. In particular, this means
 	 * that all per memcg caches attached to it must be empty too.
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
