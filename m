Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id 8E1FA6B0038
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 10:54:49 -0500 (EST)
Received: by mail-lb0-f169.google.com with SMTP id q8so5500855lbi.14
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 07:54:48 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id z4si10645609lal.119.2014.02.03.07.54.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Feb 2014 07:54:47 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v2 7/7] slub: rework sysfs layout for memcg caches
Date: Mon, 3 Feb 2014 19:54:42 +0400
Message-ID: <3794b40c31cb5370c5490ab1da06fc93fced288c.1391441746.git.vdavydov@parallels.com>
In-Reply-To: <cover.1391441746.git.vdavydov@parallels.com>
References: <cover.1391441746.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, rientjes@google.com, penberg@kernel.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org

Currently, we try to arrange sysfs entries for memcg caches in the same
manner as for global caches. Apart from turning /sys/kernel/slab into a
mess when there are a lot of kmem-active memcgs created, it actually
does not work properly - we won't create more than one link to a memcg
cache in case its parent is merged with another cache. For instance, if
A is a root cache merged with another root cache B, we will have the
following sysfs setup:

  X
  A -> X
  B -> X

where X is some unique id (see create_unique_id()). Now if memcgs M and
N start to allocate from cache A (or B, which is the same), we will get:

  X
  X:M
  X:N
  A -> X
  B -> X
  A:M -> X:M
  A:N -> X:N

Since B is an alias for A, we won't get entries B:M and B:N, which is
confusing.

It is more logical to have entries for memcg caches under the
corresponding root cache's sysfs directory. This would allow us to keep
sysfs layout clean, and avoid such inconsistencies like one described
above.

This patch does the trick. It creates a "cgroup" kset in each root cache
kobject to keep its children caches there.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/slub_def.h |    3 ++
 mm/slub.c                |   85 ++++++++++++++++++++++++++++++++++++++--------
 2 files changed, 73 insertions(+), 15 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index f56bfa9e4526..f2f7398848cf 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -87,6 +87,9 @@ struct kmem_cache {
 #ifdef CONFIG_MEMCG_KMEM
 	struct memcg_cache_params *memcg_params;
 	int max_attr_size; /* for propagation, maximum size of a stored attr */
+#ifdef CONFIG_SYSFS
+	struct kset *memcg_kset;
+#endif
 #endif
 
 #ifdef CONFIG_NUMA
diff --git a/mm/slub.c b/mm/slub.c
index f3d2ef725ed6..d5d1ecc5ace9 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5137,6 +5137,44 @@ static const struct kset_uevent_ops slab_uevent_ops = {
 
 static struct kset *slab_kset;
 
+#ifdef CONFIG_MEMCG_KMEM
+static inline struct kset *cache_kset(struct kmem_cache *s)
+{
+	if (is_root_cache(s))
+		return slab_kset;
+	return s->memcg_params->root_cache->memcg_kset;
+}
+
+static int create_cache_memcg_kset(struct kmem_cache *s)
+{
+	if (!is_root_cache(s))
+		return 0;
+	s->memcg_kset = kset_create_and_add("cgroup", NULL, &s->kobj);
+	if (!s->memcg_kset)
+		return -ENOMEM;
+	return 0;
+}
+
+static void destroy_cache_memcg_kset(struct kmem_cache *s)
+{
+	kset_unregister(s->memcg_kset);
+}
+#else
+static inline struct kset *cache_kset(struct kmem_cache *s)
+{
+	return slab_kset;
+}
+
+static inline int create_cache_memcg_kset(struct kmem_cache *s)
+{
+	return 0;
+}
+
+static inline void destroy_cache_memcg_kset(struct kmem_cache *s)
+{
+}
+#endif /* CONFIG_MEMCG_KMEM */
+
 #define ID_STR_LENGTH 64
 
 /* Create a unique string id for a slab cache:
@@ -5148,7 +5186,8 @@ static char *create_unique_id(struct kmem_cache *s)
 	char *name = kmalloc(ID_STR_LENGTH, GFP_KERNEL);
 	char *p = name;
 
-	BUG_ON(!name);
+	if (!name)
+		return NULL;
 
 	*p++ = ':';
 	/*
@@ -5192,7 +5231,8 @@ static int sysfs_slab_add(struct kmem_cache *s)
 		 * This is typically the case for debug situations. In that
 		 * case we can catch duplicate names easily.
 		 */
-		sysfs_remove_link(&slab_kset->kobj, s->name);
+		if (is_root_cache(s))
+			sysfs_remove_link(&slab_kset->kobj, s->name);
 		name = s->name;
 	} else {
 		/*
@@ -5200,28 +5240,40 @@ static int sysfs_slab_add(struct kmem_cache *s)
 		 * for the symlinks.
 		 */
 		name = create_unique_id(s);
+		if (!name)
+			return -ENOMEM;
 	}
 
-	s->kobj.kset = slab_kset;
+	s->kobj.kset = cache_kset(s);
 	err = kobject_init_and_add(&s->kobj, &slab_ktype, NULL, "%s", name);
-	if (err) {
-		kobject_put(&s->kobj);
-		return err;
-	}
+	if (err)
+		goto out_put_kobj;
+
+	err = create_cache_memcg_kset(s);
+	if (err)
+		goto out_del_kobj;
 
 	err = sysfs_create_group(&s->kobj, &slab_attr_group);
-	if (err) {
-		kobject_del(&s->kobj);
-		kobject_put(&s->kobj);
-		return err;
-	}
+	if (err)
+		goto out_del_memcg_kset;
+
 	kobject_uevent(&s->kobj, KOBJ_ADD);
-	if (!unmergeable) {
+	if (!unmergeable && is_root_cache(s)) {
 		/* Setup first alias */
 		sysfs_slab_alias(s, s->name);
-		kfree(name);
 	}
-	return 0;
+out:
+	if (!unmergeable)
+		kfree(name);
+	return err;
+
+out_del_memcg_kset:
+	destroy_cache_memcg_kset(s);
+out_del_kobj:
+	kobject_del(&s->kobj);
+out_put_kobj:
+	kobject_put(&s->kobj);
+	goto out;
 }
 
 static void sysfs_slab_remove(struct kmem_cache *s)
@@ -5233,6 +5285,7 @@ static void sysfs_slab_remove(struct kmem_cache *s)
 		 */
 		return;
 
+	destroy_cache_memcg_kset(s);
 	kobject_uevent(&s->kobj, KOBJ_REMOVE);
 	kobject_del(&s->kobj);
 	kobject_put(&s->kobj);
@@ -5254,6 +5307,8 @@ static int sysfs_slab_alias(struct kmem_cache *s, const char *name)
 {
 	struct saved_alias *al;
 
+	BUG_ON(!is_root_cache(s));
+
 	if (slab_state == FULL) {
 		/*
 		 * If we have a leftover link then remove it.
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
