Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 91BC66B0039
	for <linux-mm@kvack.org>; Sat, 21 Dec 2013 10:54:21 -0500 (EST)
Received: by mail-lb0-f179.google.com with SMTP id w7so1633375lbi.10
        for <linux-mm@kvack.org>; Sat, 21 Dec 2013 07:54:20 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id m1si5290885lbs.84.2013.12.21.07.54.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 21 Dec 2013 07:54:20 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 07/11] memcg: get rid of kmem_cache_dup
Date: Sat, 21 Dec 2013 19:53:58 +0400
Message-ID: <e9251d4e7a9feaa495ddcabfa89d0f74bd10e191.1387640542.git.vdavydov@parallels.com>
In-Reply-To: <cover.1387640541.git.vdavydov@parallels.com>
References: <cover.1387640541.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: glommer@gmail.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

kmem_cache_dup() is only called from memcg_create_kmem_cache(). The
latter, in fact, does nothing besides this, so let's fold
kmem_cache_dup() into memcg_create_kmem_cache().

This patch also makes the memcg_cache_mutex private to
memcg_create_kmem_cache(), because it is not used anywhere else.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/memcontrol.c |   39 ++++++++-------------------------------
 1 file changed, 8 insertions(+), 31 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 56fc410..ce25f77 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3391,27 +3391,16 @@ void mem_cgroup_destroy_cache(struct kmem_cache *cachep)
 	schedule_work(&cachep->memcg_params->destroy);
 }
 
-/*
- * This lock protects updaters, not readers. We want readers to be as fast as
- * they can, and they will either see NULL or a valid cache value. Our model
- * allow them to see NULL, in which case the root memcg will be selected.
- *
- * We need this lock because multiple allocations to the same cache from a non
- * will span more than one worker. Only one of them can create the cache.
- */
-static DEFINE_MUTEX(memcg_cache_mutex);
-
-/*
- * Called with memcg_cache_mutex held
- */
-static struct kmem_cache *kmem_cache_dup(struct mem_cgroup *memcg,
-					 struct kmem_cache *s)
+static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
+						  struct kmem_cache *s)
 {
 	struct kmem_cache *new;
 	static char *tmp_name = NULL;
+	static DEFINE_MUTEX(mutex);	/* protects tmp_name */
 
-	lockdep_assert_held(&memcg_cache_mutex);
+	BUG_ON(!memcg_can_account_kmem(memcg));
 
+	mutex_lock(&mutex);
 	/*
 	 * kmem_cache_create_memcg duplicates the given name and
 	 * cgroup_name for this name requires RCU context.
@@ -3434,25 +3423,13 @@ static struct kmem_cache *kmem_cache_dup(struct mem_cgroup *memcg,
 
 	if (new)
 		new->allocflags |= __GFP_KMEMCG;
+	else
+		new = s;
 
+	mutex_unlock(&mutex);
 	return new;
 }
 
-static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
-						  struct kmem_cache *cachep)
-{
-	struct kmem_cache *new_cachep;
-
-	BUG_ON(!memcg_can_account_kmem(memcg));
-
-	mutex_lock(&memcg_cache_mutex);
-	new_cachep = kmem_cache_dup(memcg, cachep);
-	if (new_cachep == NULL)
-		new_cachep = cachep;
-	mutex_unlock(&memcg_cache_mutex);
-	return new_cachep;
-}
-
 void kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 {
 	struct kmem_cache *c;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
