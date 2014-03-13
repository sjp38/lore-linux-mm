Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id 6E53E6B0038
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 11:06:58 -0400 (EDT)
Received: by mail-lb0-f181.google.com with SMTP id c11so768315lbj.26
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 08:06:57 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id y6si1643739lal.131.2014.03.13.08.06.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Mar 2014 08:06:56 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RESEND -mm 03/12] memcg: fix root vs memcg cache destruction race
Date: Thu, 13 Mar 2014 19:06:41 +0400
Message-ID: <a8fb0bd1ff3f3ac1a2f7a44e1eceef9c7d80bb62.1394708827.git.vdavydov@parallels.com>
In-Reply-To: <cover.1394708827.git.vdavydov@parallels.com>
References: <cover.1394708827.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

When a root cache is being destroyed and we are about to initiate
destruction of its child caches (see kmem_cache_destroy_memcg_children),
we should handle races with pending memcg cache destruction works
somehow. Currently, we simply cancel the memcg_params::destroy work
before calling kmem_cache_destroy for a memcg cache, but that's totally
wrong, because the work handler may destroy and free the cache resulting
in a use-after-free in cancel_work_sync. Furthermore, we do not handle
the case when memcg cache destruction is scheduled after we start to
destroy the root cache - that's possible, because nothing prevents
memcgs from going offline while we are destroying a root cache. In that
case we are likely to get a use-after-free in the work handler.

This patch resolves the race as follows:

1) It makes kmem_cache_destroy silently exit if it is called for a memcg
   cache while the corresponding root cache is being destroyed, leaving
   the destruction to kmem_cache_destroy_memcg_children. That makes call
   to cancel_work_sync safe if it is called from the root cache
   destruction path.

2) It moves cancel_work_sync to be called after we unregistered a child
   cache from its memcg. That prevents the work from being rescheduled
   from memcg offline path.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@gmail.com>
---
 include/linux/memcontrol.h |    2 +-
 include/linux/slab.h       |    1 +
 mm/memcontrol.c            |   22 ++-----------
 mm/slab_common.c           |   77 ++++++++++++++++++++++++++++++++++++--------
 4 files changed, 69 insertions(+), 33 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index bbe48913c56e..689442999562 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -512,7 +512,7 @@ void memcg_update_array_size(int num_groups);
 struct kmem_cache *
 __memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
 
-int __kmem_cache_destroy_memcg_children(struct kmem_cache *s);
+int kmem_cache_destroy_memcg_children(struct kmem_cache *s);
 
 /**
  * memcg_kmem_newpage_charge: verify if a new kmem allocation is allowed.
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 3ed53de256ea..ee9f1b0382ac 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -117,6 +117,7 @@ struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
 			void (*)(void *));
 #ifdef CONFIG_MEMCG_KMEM
 void kmem_cache_create_memcg(struct mem_cgroup *, struct kmem_cache *);
+void kmem_cache_destroy_memcg(struct kmem_cache *, bool);
 #endif
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index cf32254ae1ee..21974ec406bb 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3280,10 +3280,10 @@ static void kmem_cache_destroy_work_func(struct work_struct *w)
 			return;
 	}
 
-	kmem_cache_destroy(cachep);
+	kmem_cache_destroy_memcg(cachep, false);
 }
 
-int __kmem_cache_destroy_memcg_children(struct kmem_cache *s)
+int kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 {
 	struct kmem_cache *c;
 	int i, failed = 0;
@@ -3313,23 +3313,7 @@ int __kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 		if (!c)
 			continue;
 
-		/*
-		 * We will now manually delete the caches, so to avoid races
-		 * we need to cancel all pending destruction workers and
-		 * proceed with destruction ourselves.
-		 *
-		 * kmem_cache_destroy() will call kmem_cache_shrink internally,
-		 * and that could spawn the workers again: it is likely that
-		 * the cache still have active pages until this very moment.
-		 * This would lead us back to memcg_release_pages().
-		 *
-		 * But that will not execute at all if the refcount is > 0, so
-		 * increment it to guarantee we are in control.
-		 */
-		atomic_inc(&c->memcg_params->refcount);
-		cancel_work_sync(&c->memcg_params->destroy);
-		kmem_cache_destroy(c);
-
+		kmem_cache_destroy_memcg(c, true);
 		if (cache_from_memcg_idx(s, i))
 			failed++;
 	}
diff --git a/mm/slab_common.c b/mm/slab_common.c
index f3cfccf76dda..05ba3cd1b507 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -302,28 +302,70 @@ out_unlock:
 	put_online_cpus();
 }
 
-static int kmem_cache_destroy_memcg_children(struct kmem_cache *s)
+static void __kmem_cache_destroy(struct kmem_cache *, bool);
+
+void kmem_cache_destroy_memcg(struct kmem_cache *s, bool destroying_root)
+{
+	BUG_ON(is_root_cache(s));
+	__kmem_cache_destroy(s, destroying_root);
+}
+
+static int __kmem_cache_shutdown_memcg(struct kmem_cache *s,
+				       bool destroying_root)
 {
-	int rc;
+	int rc = 0;
 
-	if (!s->memcg_params ||
-	    !s->memcg_params->is_root_cache)
+	if (!destroying_root) {
+		struct kmem_cache *root;
+
+		root = memcg_root_cache(s);
+		BUG_ON(root == s);
+		/*
+		 * If we are racing with the root cache destruction, let
+		 * kmem_cache_destroy_memcg_children() finish with this cache.
+		 */
+		if (!root->refcount) {
+			s->refcount++;
+			return 1;
+		}
+	}
+
+	if (!s->memcg_params)
 		return 0;
 
 	mutex_unlock(&slab_mutex);
-	rc = __kmem_cache_destroy_memcg_children(s);
+	if (s->memcg_params->is_root_cache) {
+		rc = kmem_cache_destroy_memcg_children(s);
+	} else {
+		/*
+		 * There might be a destruction work pending, which needs to be
+		 * cancelled before we start to destroy the cache.
+		 *
+		 * This should be done after we deleted all the references to
+		 * this cache, otherwise the work could be rescheduled.
+		 *
+		 * __kmem_cache_shutdown() will call kmem_cache_shrink()
+		 * internally, and that could spawn the worker again. We
+		 * increment the refcount to avoid that.
+		 */
+		if (destroying_root) {
+			cancel_work_sync(&s->memcg_params->destroy);
+			atomic_inc(&s->memcg_params->refcount);
+		}
+	}
 	mutex_lock(&slab_mutex);
 
 	return rc;
 }
 #else
-static int kmem_cache_destroy_memcg_children(struct kmem_cache *s)
+static int __kmem_cache_shutdown_memcg(struct kmem_cache *s,
+				       bool destroying_root)
 {
 	return 0;
 }
 #endif /* CONFIG_MEMCG_KMEM */
 
-void kmem_cache_destroy(struct kmem_cache *s)
+static void __kmem_cache_destroy(struct kmem_cache *s, bool destroying_root)
 {
 	get_online_cpus();
 	mutex_lock(&slab_mutex);
@@ -332,19 +374,17 @@ void kmem_cache_destroy(struct kmem_cache *s)
 	if (s->refcount)
 		goto out_unlock;
 
-	if (kmem_cache_destroy_memcg_children(s) != 0)
-		goto out_unlock;
-
 	list_del(&s->list);
 	memcg_unregister_cache(s);
 
+	if (__kmem_cache_shutdown_memcg(s, destroying_root) != 0)
+		goto out_undelete;
+
 	if (__kmem_cache_shutdown(s) != 0) {
-		list_add(&s->list, &slab_caches);
-		memcg_register_cache(s);
 		printk(KERN_ERR "kmem_cache_destroy %s: "
 		       "Slab cache still has objects\n", s->name);
 		dump_stack();
-		goto out_unlock;
+		goto out_undelete;
 	}
 
 	mutex_unlock(&slab_mutex);
@@ -360,6 +400,17 @@ out_unlock:
 	mutex_unlock(&slab_mutex);
 out_put_cpus:
 	put_online_cpus();
+	return;
+out_undelete:
+	list_add(&s->list, &slab_caches);
+	memcg_register_cache(s);
+	goto out_unlock;
+}
+
+void kmem_cache_destroy(struct kmem_cache *s)
+{
+	BUG_ON(!is_root_cache(s));
+	__kmem_cache_destroy(s, true);
 }
 EXPORT_SYMBOL(kmem_cache_destroy);
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
