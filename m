Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 63CFF4403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 11:40:01 -0500 (EST)
Received: by mail-pf0-f174.google.com with SMTP id w123so50333586pfb.0
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 08:40:01 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ca7si17564450pad.240.2016.02.04.08.40.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Feb 2016 08:40:00 -0800 (PST)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv4] mm: slab: shutdown caches only after releasing sysfs file
Date: Thu, 4 Feb 2016 19:39:48 +0300
Message-ID: <1454603988-24856-1-git-send-email-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, Dmitry Safonov <dsafonov@virtuozzo.com>, Vladimir Davydov <vdavydov@virtuozzo.com>

As shutdown cache will uninitialize kmem_cache state, it shouldn't be
done till the last reference to sysfs file object is dropped.
In the other case it will result in race with dereferencing garbage.

Fixes the following panic:
[43963.463055] BUG: unable to handle kernel
[43963.463090] NULL pointer dereference at 0000000000000020
[43963.463146] IP: [<ffffffff811c6959>] list_locations+0x169/0x4e0
[43963.463185] PGD 257304067 PUD 438456067 PMD 0
[43963.463220] Oops: 0000 [#1] SMP
[43963.463850] CPU: 3 PID: 973074 Comm: cat ve: 0 Not tainted 3.10.0-229.7.2.ovz.9.30-00007-japdoll-dirty #2 9.30
[43963.463913] Hardware name: DEPO Computers To Be Filled By O.E.M./H67DE3, BIOS L1.60c 07/14/2011
[43963.463976] task: ffff88042a5dc5b0 ti: ffff88037f8d8000 task.ti: ffff88037f8d8000
[43963.464036] RIP: 0010:[<ffffffff811c6959>]  [<ffffffff811c6959>] list_locations+0x169/0x4e0
[43963.464725] Call Trace:
[43963.464756]  [<ffffffff811c6d1d>] alloc_calls_show+0x1d/0x30
[43963.464793]  [<ffffffff811c15ab>] slab_attr_show+0x1b/0x30
[43963.464829]  [<ffffffff8125d27a>] sysfs_read_file+0x9a/0x1a0
[43963.464865]  [<ffffffff811e3c6c>] vfs_read+0x9c/0x170
[43963.464900]  [<ffffffff811e4798>] SyS_read+0x58/0xb0
[43963.464936]  [<ffffffff81612d49>] system_call_fastpath+0x16/0x1b
[43963.464970] Code: 5e 07 12 00 b9 00 04 00 00 3d 00 04 00 00 0f 4f c1 3d 00 04 00 00 89 45 b0 0f 84 c3 00 00 00 48 63 45 b0 49 8b 9c c4 f8 00 00 00 <48> 8b 43 20 48 85 c0 74 b6 48 89 df e8 46 37 44 00 48 8b 53 10
[43963.465119] RIP  [<ffffffff811c6959>] list_locations+0x169/0x4e0
[43963.465155]  RSP <ffff88037f8dbe28>
[43963.465185] CR2: 0000000000000020

So, I reworked destroy code path to delete sysfs file and on release of
kobject shutdown and remove kmem_cache.

Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
---
v2: Down with SLAB_SUPPORTS_SYSFS thing.                                         
v3: Moved sysfs_slab_remove inside shutdown_cache                                
v4: Reworked all to shutdown & free caches on object->release() 

 include/linux/slub_def.h |   5 +-
 mm/slab.h                |   2 +-
 mm/slab_common.c         | 139 ++++++++++++++++++++++-------------------------
 mm/slub.c                |  22 +++++++-
 4 files changed, 88 insertions(+), 80 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index b7e57927..a6bf41a 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -103,9 +103,10 @@ struct kmem_cache {
 
 #ifdef CONFIG_SYSFS
 #define SLAB_SUPPORTS_SYSFS
-void sysfs_slab_remove(struct kmem_cache *);
+int sysfs_slab_remove(struct kmem_cache *);
+void sysfs_slab_remove_cancel(struct kmem_cache *s);
 #else
-static inline void sysfs_slab_remove(struct kmem_cache *s)
+void sysfs_slab_remove_cancel(struct kmem_cache *s)
 {
 }
 #endif
diff --git a/mm/slab.h b/mm/slab.h
index 834ad24..ec87600 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -141,7 +141,7 @@ static inline unsigned long kmem_cache_flags(unsigned long object_size,
 
 int __kmem_cache_shutdown(struct kmem_cache *);
 int __kmem_cache_shrink(struct kmem_cache *, bool);
-void slab_kmem_cache_release(struct kmem_cache *);
+int slab_kmem_cache_release(struct kmem_cache *);
 
 struct seq_file;
 struct file;
diff --git a/mm/slab_common.c b/mm/slab_common.c
index b50aef0..3ad3d22 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -448,33 +448,58 @@ out_unlock:
 }
 EXPORT_SYMBOL(kmem_cache_create);
 
-static int shutdown_cache(struct kmem_cache *s,
+static void prepare_caches_release(struct kmem_cache *s,
 		struct list_head *release, bool *need_rcu_barrier)
 {
-	if (__kmem_cache_shutdown(s) != 0)
-		return -EBUSY;
-
 	if (s->flags & SLAB_DESTROY_BY_RCU)
 		*need_rcu_barrier = true;
 
 	list_move(&s->list, release);
-	return 0;
 }
 
-static void release_caches(struct list_head *release, bool need_rcu_barrier)
+#ifdef SLAB_SUPPORTS_SYSFS
+#define release_one_cache sysfs_slab_remove
+#else
+#define release_one_cache slab_kmem_cache_release
+#endif
+
+static int release_caches_type(struct list_head *release, bool children)
 {
 	struct kmem_cache *s, *s2;
+	int ret = 0;
 
+	list_for_each_entry_safe(s, s2, release, list) {
+		if (is_root_cache(s) == children)
+			continue;
+
+		ret += release_one_cache(s);
+	}
+	return ret;
+}
+
+static void release_caches(struct list_head *release, bool need_rcu_barrier)
+{
 	if (need_rcu_barrier)
 		rcu_barrier();
 
-	list_for_each_entry_safe(s, s2, release, list) {
-#ifdef SLAB_SUPPORTS_SYSFS
-		sysfs_slab_remove(s);
-#else
-		slab_kmem_cache_release(s);
-#endif
-	}
+	/* remove children in the first place, remove root on success */
+	if (!release_caches_type(release, true))
+		release_caches_type(release, false);
+}
+
+static void release_cache_cancel(struct kmem_cache *s)
+{
+	sysfs_slab_remove_cancel(s);
+
+	get_online_cpus();
+	get_online_mems();
+	mutex_lock(&slab_mutex);
+
+	list_move(&s->list, &slab_caches);
+
+	mutex_unlock(&slab_mutex);
+	put_online_mems();
+	put_online_cpus();
 }
 
 #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
@@ -589,16 +614,14 @@ void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
 	put_online_cpus();
 }
 
-static int __shutdown_memcg_cache(struct kmem_cache *s,
+static void prepare_memcg_empty_caches(struct kmem_cache *s,
 		struct list_head *release, bool *need_rcu_barrier)
 {
 	BUG_ON(is_root_cache(s));
 
-	if (shutdown_cache(s, release, need_rcu_barrier))
-		return -EBUSY;
+	prepare_caches_release(s, release, need_rcu_barrier);
 
-	list_del(&s->memcg_params.list);
-	return 0;
+	list_del_init(&s->memcg_params.list);
 }
 
 void memcg_destroy_kmem_caches(struct mem_cgroup *memcg)
@@ -614,11 +637,12 @@ void memcg_destroy_kmem_caches(struct mem_cgroup *memcg)
 	list_for_each_entry_safe(s, s2, &slab_caches, list) {
 		if (is_root_cache(s) || s->memcg_params.memcg != memcg)
 			continue;
+
 		/*
 		 * The cgroup is about to be freed and therefore has no charges
 		 * left. Hence, all its caches must be empty by now.
 		 */
-		BUG_ON(__shutdown_memcg_cache(s, &release, &need_rcu_barrier));
+		prepare_memcg_empty_caches(s, &release, &need_rcu_barrier);
 	}
 	mutex_unlock(&slab_mutex);
 
@@ -628,81 +652,53 @@ void memcg_destroy_kmem_caches(struct mem_cgroup *memcg)
 	release_caches(&release, need_rcu_barrier);
 }
 
-static int shutdown_memcg_caches(struct kmem_cache *s,
+static void prepare_memcg_filled_caches(struct kmem_cache *s,
 		struct list_head *release, bool *need_rcu_barrier)
 {
 	struct memcg_cache_array *arr;
 	struct kmem_cache *c, *c2;
-	LIST_HEAD(busy);
-	int i;
 
 	BUG_ON(!is_root_cache(s));
 
-	/*
-	 * First, shutdown active caches, i.e. caches that belong to online
-	 * memory cgroups.
-	 */
 	arr = rcu_dereference_protected(s->memcg_params.memcg_caches,
 					lockdep_is_held(&slab_mutex));
-	for_each_memcg_cache_index(i) {
-		c = arr->entries[i];
-		if (!c)
-			continue;
-		if (__shutdown_memcg_cache(c, release, need_rcu_barrier))
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
 
-	/*
-	 * Second, shutdown all caches left from memory cgroups that are now
-	 * offline.
-	 */
+	/* move children caches to release list */
 	list_for_each_entry_safe(c, c2, &s->memcg_params.list,
 				 memcg_params.list)
-		__shutdown_memcg_cache(c, release, need_rcu_barrier);
-
-	list_splice(&busy, &s->memcg_params.list);
+		prepare_caches_release(c, release, need_rcu_barrier);
 
-	/*
-	 * A cache being destroyed must be empty. In particular, this means
-	 * that all per memcg caches attached to it must be empty too.
-	 */
-	if (!list_empty(&s->memcg_params.list))
-		return -EBUSY;
-	return 0;
+	/* root cache to the same place */
+	prepare_caches_release(s, release, need_rcu_barrier);
 }
+
 #else
-static inline int shutdown_memcg_caches(struct kmem_cache *s,
-		struct list_head *release, bool *need_rcu_barrier)
-{
-	return 0;
-}
+#define prepare_memcg_filled_caches prepare_caches_release
 #endif /* CONFIG_MEMCG && !CONFIG_SLOB */
 
-void slab_kmem_cache_release(struct kmem_cache *s)
+int slab_kmem_cache_release(struct kmem_cache *s)
 {
+	if (__kmem_cache_shutdown(s)) {
+		WARN(1, "release slub cache %s failed: it still has objects\n",
+			s->name);
+		release_cache_cancel(s);
+		return 1;
+	}
+
+#ifdef CONFIG_MEMCG
+	list_del(&s->memcg_params.list);
+#endif
+
 	destroy_memcg_params(s);
 	kfree_const(s->name);
 	kmem_cache_free(kmem_cache, s);
+	return 0;
 }
 
 void kmem_cache_destroy(struct kmem_cache *s)
 {
 	LIST_HEAD(release);
 	bool need_rcu_barrier = false;
-	int err;
 
 	if (unlikely(!s))
 		return;
@@ -716,15 +712,8 @@ void kmem_cache_destroy(struct kmem_cache *s)
 	if (s->refcount)
 		goto out_unlock;
 
-	err = shutdown_memcg_caches(s, &release, &need_rcu_barrier);
-	if (!err)
-		err = shutdown_cache(s, &release, &need_rcu_barrier);
+	prepare_memcg_filled_caches(s, &release, &need_rcu_barrier);
 
-	if (err) {
-		pr_err("kmem_cache_destroy %s: "
-		       "Slab cache still has objects\n", s->name);
-		dump_stack();
-	}
 out_unlock:
 	mutex_unlock(&slab_mutex);
 
diff --git a/mm/slub.c b/mm/slub.c
index 2e1355a..373aa6d 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5429,14 +5429,14 @@ out_del_kobj:
 	goto out;
 }
 
-void sysfs_slab_remove(struct kmem_cache *s)
+int sysfs_slab_remove(struct kmem_cache *s)
 {
 	if (slab_state < FULL)
 		/*
 		 * Sysfs has not been setup yet so no need to remove the
 		 * cache from sysfs.
 		 */
-		return;
+		return 0;
 
 #ifdef CONFIG_MEMCG
 	kset_unregister(s->memcg_kset);
@@ -5444,6 +5444,24 @@ void sysfs_slab_remove(struct kmem_cache *s)
 	kobject_uevent(&s->kobj, KOBJ_REMOVE);
 	kobject_del(&s->kobj);
 	kobject_put(&s->kobj);
+	return 0;
+}
+
+void sysfs_slab_remove_cancel(struct kmem_cache *s)
+{
+	int ret;
+
+	if (slab_state < FULL)
+		return;
+
+	/* tricky */
+	kobject_get(&s->kobj);
+	ret = kobject_add(&s->kobj, NULL, "%s", s->name);
+	kobject_uevent(&s->kobj, KOBJ_ADD);
+
+#ifdef CONFIG_MEMCG
+	s->memcg_kset = kset_create_and_add("cgroup", NULL, &s->kobj);
+#endif
 }
 
 /*
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
