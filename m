Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 5DA2B6B0038
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 10:54:48 -0500 (EST)
Received: by mail-la0-f42.google.com with SMTP id hr13so5552505lab.15
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 07:54:47 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id mq2si10641862lbb.167.2014.02.03.07.54.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Feb 2014 07:54:46 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v2 5/7] memcg, slab: do not destroy children caches if parent has aliases
Date: Mon, 3 Feb 2014 19:54:40 +0400
Message-ID: <3b5bba7dec287bc4d77ceb801eb4f6996393f797.1391441746.git.vdavydov@parallels.com>
In-Reply-To: <cover.1391441746.git.vdavydov@parallels.com>
References: <cover.1391441746.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, rientjes@google.com, penberg@kernel.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org

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
 include/linux/memcontrol.h |    5 ---
 mm/memcontrol.c            |    2 +-
 mm/slab.h                  |   17 ++++++++--
 mm/slab_common.c           |   74 +++++++++++++++++++++++++++++---------------
 4 files changed, 65 insertions(+), 33 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index de79a9617e09..1a7d9c6741b7 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -513,7 +513,6 @@ struct kmem_cache *
 __memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
 
 void mem_cgroup_destroy_cache(struct kmem_cache *cachep);
-void kmem_cache_destroy_memcg_children(struct kmem_cache *s);
 
 /**
  * memcg_kmem_newpage_charge: verify if a new kmem allocation is allowed.
@@ -667,10 +666,6 @@ memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
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
index 6a059e73212c..4b8dd7ef18bf 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3428,7 +3428,7 @@ void mem_cgroup_destroy_cache(struct kmem_cache *cachep)
 	schedule_work(&cachep->memcg_params->destroy);
 }
 
-void kmem_cache_destroy_memcg_children(struct kmem_cache *s)
+void __kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 {
 	struct kmem_cache *c;
 	int i;
diff --git a/mm/slab.h b/mm/slab.h
index 3045316b7c9d..b5ad968020a3 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -191,7 +191,16 @@ static inline struct kmem_cache *memcg_root_cache(struct kmem_cache *s)
 		return s;
 	return s->memcg_params->root_cache;
 }
-#else
+
+extern void __kmem_cache_destroy_memcg_children(struct kmem_cache *s);
+
+static inline void kmem_cache_destroy_memcg_children(struct kmem_cache *s)
+{
+	mutex_unlock(&slab_mutex);
+	__kmem_cache_destroy_memcg_children(s);
+	mutex_lock(&slab_mutex);
+}
+#else /* !CONFIG_MEMCG_KMEM */
 static inline bool is_root_cache(struct kmem_cache *s)
 {
 	return true;
@@ -226,7 +235,11 @@ static inline struct kmem_cache *memcg_root_cache(struct kmem_cache *s)
 {
 	return s;
 }
-#endif
+
+static inline void kmem_cache_destroy_memcg_children(struct kmem_cache *s)
+{
+}
+#endif /* CONFIG_MEMCG_KMEM */
 
 static inline struct kmem_cache *cache_from_obj(struct kmem_cache *s, void *x)
 {
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 4dff4bb66f19..f8de8e5a18fd 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -300,38 +300,62 @@ out_free_cache:
 }
 #endif /* CONFIG_MEMCG_KMEM */
 
-void kmem_cache_destroy(struct kmem_cache *s)
+static bool cache_has_children(struct kmem_cache *s)
 {
-	/* Destroy all the children caches if we aren't a memcg cache */
-	kmem_cache_destroy_memcg_children(s);
+	int i;
+
+	if (!is_root_cache(s))
+		return false;
+	for_each_memcg_cache_index(i) {
+		if (cache_from_memcg_idx(s, i))
+			return true;
+	}
+	return false;
+}
 
+void kmem_cache_destroy(struct kmem_cache *s)
+{
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
+	list_del(&s->list);
+	memcg_unregister_cache(s);
+
+	/* Destroy all the children caches if we aren't a memcg cache */
+	kmem_cache_destroy_memcg_children(s);
+	if (cache_has_children(s))
+		goto out_undelete;
+
+	if (__kmem_cache_shutdown(s) != 0) {
+		printk(KERN_ERR "kmem_cache_destroy %s: "
+		       "Slab cache still has objects\n", s->name);
+		dump_stack();
+		goto out_undelete;
 	}
+
+	mutex_unlock(&slab_mutex);
+	if (s->flags & SLAB_DESTROY_BY_RCU)
+		rcu_barrier();
+
+	memcg_free_cache_params(s);
+	kfree(s->name);
+	kmem_cache_free(kmem_cache, s);
+	goto out_put_cpus; /* slab_mutex already unlocked */
+
+out_unlock:
+	mutex_unlock(&slab_mutex);
+out_put_cpus:
 	put_online_cpus();
+	return;
+
+out_undelete:
+	list_add(&s->list, &slab_caches);
+	memcg_register_cache(s);
+	goto out_unlock;
 }
 EXPORT_SYMBOL(kmem_cache_destroy);
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
