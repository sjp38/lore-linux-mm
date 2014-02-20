Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id 0EC756B0072
	for <linux-mm@kvack.org>; Thu, 20 Feb 2014 02:22:17 -0500 (EST)
Received: by mail-la0-f52.google.com with SMTP id c6so1022291lan.25
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 23:22:17 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id gp1si2931836lbc.75.2014.02.19.23.22.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Feb 2014 23:22:16 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v3 5/7] memcg, slab: do not destroy children caches if parent has aliases
Date: Thu, 20 Feb 2014 11:22:07 +0400
Message-ID: <d783c642d7695675b4eb35fef62f87b7a56bc094.1392879001.git.vdavydov@parallels.com>
In-Reply-To: <cover.1392879001.git.vdavydov@parallels.com>
References: <cover.1392879001.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, akpm@linux-foundation.org
Cc: rientjes@google.com, penberg@kernel.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org

Currently we destroy children caches at the very beginning of
kmem_cache_destroy(). This is wrong, because the root cache will not
necessarily be destroyed in the end - if it has aliases (refcount > 0),
kmem_cache_destroy() will simply decrement its refcount and return. In
this case, at best we will get a bunch of warnings in dmesg, like this
one:

  kmem_cache_destroy kmalloc-32:0: Slab cache still has objects
  CPU: 1 PID: 7139 Comm: modprobe Tainted: G    B   W    3.13.0+ #117
  Hardware name:
   ffff88007d7a6368 ffff880039b07e48 ffffffff8168cc2e ffff88007d7a6d68
   ffff88007d7a6300 ffff880039b07e68 ffffffff81175e9f 0000000000000000
   ffff88007d7a6300 ffff880039b07e98 ffffffff811b67c7 ffff88003e803c00
  Call Trace:
   [<ffffffff8168cc2e>] dump_stack+0x49/0x5b
   [<ffffffff81175e9f>] kmem_cache_destroy+0xdf/0xf0
   [<ffffffff811b67c7>] kmem_cache_destroy_memcg_children+0x97/0xc0
   [<ffffffff81175dcf>] kmem_cache_destroy+0xf/0xf0
   [<ffffffffa0130b21>] xfs_mru_cache_uninit+0x21/0x30 [xfs]
   [<ffffffffa01893ea>] exit_xfs_fs+0x2e/0xc44 [xfs]
   [<ffffffff810eeb58>] SyS_delete_module+0x198/0x1f0
   [<ffffffff816994f9>] system_call_fastpath+0x16/0x1b

At worst - if kmem_cache_destroy() will race with an allocation from a
memcg cache - the kernel will panic.

This patch fixes this by moving children caches destruction after the
check if the cache has aliases. Plus, it forbids destroying a root cache
if it still has children caches, because each children cache keeps a
reference to its parent.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/memcontrol.h |    6 +---
 mm/memcontrol.c            |   13 ++++----
 mm/slab_common.c           |   75 +++++++++++++++++++++++++++++---------------
 3 files changed, 57 insertions(+), 37 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 01a506a9e57b..af63e6004c62 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -513,7 +513,7 @@ struct kmem_cache *
 __memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
 
 void mem_cgroup_destroy_cache(struct kmem_cache *cachep);
-void kmem_cache_destroy_memcg_children(struct kmem_cache *s);
+int __kmem_cache_destroy_memcg_children(struct kmem_cache *s);
 
 /**
  * memcg_kmem_newpage_charge: verify if a new kmem allocation is allowed.
@@ -667,10 +667,6 @@ memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
 {
 	return cachep;
 }
-
-static inline void kmem_cache_destroy_memcg_children(struct kmem_cache *s)
-{
-}
 #endif /* CONFIG_MEMCG_KMEM */
 #endif /* _LINUX_MEMCONTROL_H */
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b07e08f97460..8a87614b6238 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3386,15 +3386,10 @@ void mem_cgroup_destroy_cache(struct kmem_cache *cachep)
 	schedule_work(&cachep->memcg_params->destroy);
 }
 
-void kmem_cache_destroy_memcg_children(struct kmem_cache *s)
+int __kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 {
 	struct kmem_cache *c;
-	int i;
-
-	if (!s->memcg_params)
-		return;
-	if (!s->memcg_params->is_root_cache)
-		return;
+	int i, failed = 0;
 
 	/*
 	 * If the cache is being destroyed, we trust that there is no one else
@@ -3428,8 +3423,12 @@ void kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 		c->memcg_params->dead = false;
 		cancel_work_sync(&c->memcg_params->destroy);
 		kmem_cache_destroy(c);
+
+		if (cache_from_memcg_idx(s, i))
+			failed++;
 	}
 	mutex_unlock(&activate_kmem_mutex);
+	return failed;
 }
 
 static void mem_cgroup_destroy_all_caches(struct mem_cgroup *memcg)
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 0c2879ff414c..f3cfccf76dda 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -301,39 +301,64 @@ out_unlock:
 	mutex_unlock(&slab_mutex);
 	put_online_cpus();
 }
+
+static int kmem_cache_destroy_memcg_children(struct kmem_cache *s)
+{
+	int rc;
+
+	if (!s->memcg_params ||
+	    !s->memcg_params->is_root_cache)
+		return 0;
+
+	mutex_unlock(&slab_mutex);
+	rc = __kmem_cache_destroy_memcg_children(s);
+	mutex_lock(&slab_mutex);
+
+	return rc;
+}
+#else
+static int kmem_cache_destroy_memcg_children(struct kmem_cache *s)
+{
+	return 0;
+}
 #endif /* CONFIG_MEMCG_KMEM */
 
 void kmem_cache_destroy(struct kmem_cache *s)
 {
-	/* Destroy all the children caches if we aren't a memcg cache */
-	kmem_cache_destroy_memcg_children(s);
-
 	get_online_cpus();
 	mutex_lock(&slab_mutex);
+
 	s->refcount--;
-	if (!s->refcount) {
-		list_del(&s->list);
-		memcg_unregister_cache(s);
-
-		if (!__kmem_cache_shutdown(s)) {
-			mutex_unlock(&slab_mutex);
-			if (s->flags & SLAB_DESTROY_BY_RCU)
-				rcu_barrier();
-
-			memcg_free_cache_params(s);
-			kfree(s->name);
-			kmem_cache_free(kmem_cache, s);
-		} else {
-			list_add(&s->list, &slab_caches);
-			memcg_register_cache(s);
-			mutex_unlock(&slab_mutex);
-			printk(KERN_ERR "kmem_cache_destroy %s: Slab cache still has objects\n",
-				s->name);
-			dump_stack();
-		}
-	} else {
-		mutex_unlock(&slab_mutex);
+	if (s->refcount)
+		goto out_unlock;
+
+	if (kmem_cache_destroy_memcg_children(s) != 0)
+		goto out_unlock;
+
+	list_del(&s->list);
+	memcg_unregister_cache(s);
+
+	if (__kmem_cache_shutdown(s) != 0) {
+		list_add(&s->list, &slab_caches);
+		memcg_register_cache(s);
+		printk(KERN_ERR "kmem_cache_destroy %s: "
+		       "Slab cache still has objects\n", s->name);
+		dump_stack();
+		goto out_unlock;
 	}
+
+	mutex_unlock(&slab_mutex);
+	if (s->flags & SLAB_DESTROY_BY_RCU)
+		rcu_barrier();
+
+	memcg_free_cache_params(s);
+	kfree(s->name);
+	kmem_cache_free(kmem_cache, s);
+	goto out_put_cpus;
+
+out_unlock:
+	mutex_unlock(&slab_mutex);
+out_put_cpus:
 	put_online_cpus();
 }
 EXPORT_SYMBOL(kmem_cache_destroy);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
