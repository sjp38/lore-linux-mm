Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id 63D286B0037
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 03:45:32 -0500 (EST)
Received: by mail-lb0-f178.google.com with SMTP id c11so9477012lbj.23
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 00:45:31 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id 9si35717702las.144.2014.01.06.00.45.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 06 Jan 2014 00:45:31 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RESEND 01/11] slab: cleanup kmem_cache_create_memcg() error handling
Date: Mon, 6 Jan 2014 12:44:52 +0400
Message-ID: <87e5f73bf2acdcdef48dc74180cdeef4f8d0f6c5.1388996525.git.vdavydov@parallels.com>
In-Reply-To: <cover.1388996525.git.vdavydov@parallels.com>
References: <cover.1388996525.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, akpm@linux-foundation.org
Cc: glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Pekka Enberg <penberg@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>

Currently kmem_cache_create_memcg() backoffs on failure inside
conditionals, without using gotos. This results in the rollback code
duplication, which makes the function look cumbersome even though on
error we should only free the allocated cache. Since in the next patch I
am going to add yet another rollback function call on error path there,
let's employ labels instead of conditionals for undoing any changes on
failure to keep things clean.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Reviewed-by: Pekka Enberg <penberg@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/slab_common.c |   65 ++++++++++++++++++++++++++----------------------------
 1 file changed, 31 insertions(+), 34 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 0b7bb39..f70df3e 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -171,13 +171,14 @@ kmem_cache_create_memcg(struct mem_cgroup *memcg, const char *name, size_t size,
 			struct kmem_cache *parent_cache)
 {
 	struct kmem_cache *s = NULL;
-	int err = 0;
+	int err;
 
 	get_online_cpus();
 	mutex_lock(&slab_mutex);
 
-	if (!kmem_cache_sanity_check(memcg, name, size) == 0)
-		goto out_locked;
+	err = kmem_cache_sanity_check(memcg, name, size);
+	if (err)
+		goto out_unlock;
 
 	/*
 	 * Some allocators will constraint the set of valid flags to a subset
@@ -189,45 +190,38 @@ kmem_cache_create_memcg(struct mem_cgroup *memcg, const char *name, size_t size,
 
 	s = __kmem_cache_alias(memcg, name, size, align, flags, ctor);
 	if (s)
-		goto out_locked;
+		goto out_unlock;
 
+	err = -ENOMEM;
 	s = kmem_cache_zalloc(kmem_cache, GFP_KERNEL);
-	if (s) {
-		s->object_size = s->size = size;
-		s->align = calculate_alignment(flags, align, size);
-		s->ctor = ctor;
+	if (!s)
+		goto out_unlock;
 
-		if (memcg_register_cache(memcg, s, parent_cache)) {
-			kmem_cache_free(kmem_cache, s);
-			err = -ENOMEM;
-			goto out_locked;
-		}
+	s->object_size = s->size = size;
+	s->align = calculate_alignment(flags, align, size);
+	s->ctor = ctor;
 
-		s->name = kstrdup(name, GFP_KERNEL);
-		if (!s->name) {
-			kmem_cache_free(kmem_cache, s);
-			err = -ENOMEM;
-			goto out_locked;
-		}
+	s->name = kstrdup(name, GFP_KERNEL);
+	if (!s->name)
+		goto out_free_cache;
 
-		err = __kmem_cache_create(s, flags);
-		if (!err) {
-			s->refcount = 1;
-			list_add(&s->list, &slab_caches);
-			memcg_cache_list_add(memcg, s);
-		} else {
-			kfree(s->name);
-			kmem_cache_free(kmem_cache, s);
-		}
-	} else
-		err = -ENOMEM;
+	err = memcg_register_cache(memcg, s, parent_cache);
+	if (err)
+		goto out_free_cache;
+
+	err = __kmem_cache_create(s, flags);
+	if (err)
+		goto out_free_cache;
+
+	s->refcount = 1;
+	list_add(&s->list, &slab_caches);
+	memcg_cache_list_add(memcg, s);
 
-out_locked:
+out_unlock:
 	mutex_unlock(&slab_mutex);
 	put_online_cpus();
 
 	if (err) {
-
 		if (flags & SLAB_PANIC)
 			panic("kmem_cache_create: Failed to create slab '%s'. Error %d\n",
 				name, err);
@@ -236,11 +230,14 @@ out_locked:
 				name, err);
 			dump_stack();
 		}
-
 		return NULL;
 	}
-
 	return s;
+
+out_free_cache:
+	kfree(s->name);
+	kmem_cache_free(kmem_cache, s);
+	goto out_unlock;
 }
 
 struct kmem_cache *
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
