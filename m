Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id 15CF56B0037
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 08:17:09 -0500 (EST)
Received: by mail-lb0-f169.google.com with SMTP id u14so2045121lbd.14
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 05:17:09 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id ax2si2893447lbc.60.2013.12.18.05.17.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 05:17:08 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 5/6] memcg: clear memcg_params after removing cache from memcg_slab_caches list
Date: Wed, 18 Dec 2013 17:16:56 +0400
Message-ID: <ae3ba60101a33b9659506267236d1d792ffc4693.1387372122.git.vdavydov@parallels.com>
In-Reply-To: <6f02b2d079ffd0990ae335339c803337b13ecd8c.1387372122.git.vdavydov@parallels.com>
References: <6f02b2d079ffd0990ae335339c803337b13ecd8c.1387372122.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

All caches of the same memory cgroup are linked in the memcg_slab_caches
list via kmem_cache::memcg_params::list. This list is traversed when we
read memory.kmem.slabinfo. Since the list actually consists of
memcg_cache_params objects, to convert an element of the list to a
kmem_cache object, we use memcg_params_to_cache(), which obtains the
pointer to the cache from the memcg_params::memcg_caches array of the
root cache, but on cache destruction this pointer is cleared before the
removal of the cache from the list, which potentially can result in a
NULL ptr dereference. Let's fix this by clearing the pointer to a cache
in the memcg_params::memcg_caches array of its parent only after it
cannot be accessed by the memcg_slab_caches list.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Glauber Costa <glommer@gmail.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/memcontrol.c |   16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 62b9991..ad8de6a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3241,6 +3241,11 @@ void memcg_register_cache(struct kmem_cache *s)
 	 */
 	smp_wmb();
 
+	/*
+	 * Initialize the pointer to this cache in its parent's memcg_params
+	 * before adding it to the memcg_slab_caches list, otherwise we can
+	 * fail to convert memcg_params_to_cache() while traversing the list.
+	 */
 	root->memcg_params->memcg_caches[id] = s;
 
 	mutex_lock(&memcg->slab_caches_mutex);
@@ -3265,15 +3270,20 @@ void memcg_release_cache(struct kmem_cache *s)
 		goto out;
 
 	memcg = s->memcg_params->memcg;
-	id  = memcg_cache_id(memcg);
-
+	id = memcg_cache_id(memcg);
 	root = s->memcg_params->root_cache;
-	root->memcg_params->memcg_caches[id] = NULL;
 
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
 out:
 	kfree(s->memcg_params);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
