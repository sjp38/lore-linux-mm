Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id 1E13D6B003A
	for <linux-mm@kvack.org>; Sun,  2 Feb 2014 11:34:01 -0500 (EST)
Received: by mail-la0-f50.google.com with SMTP id ec20so4747534lab.37
        for <linux-mm@kvack.org>; Sun, 02 Feb 2014 08:34:01 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id 1si8921767laj.111.2014.02.02.08.33.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Feb 2014 08:33:58 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 6/8] slub: rework sysfs layout for memcg caches
Date: Sun, 2 Feb 2014 20:33:51 +0400
Message-ID: <0c3f85d43565359c5924042f010a868e7099f0e3.1391356789.git.vdavydov@parallels.com>
In-Reply-To: <cover.1391356789.git.vdavydov@parallels.com>
References: <cover.1391356789.git.vdavydov@parallels.com>
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
 mm/slub.c                |   88 +++++++++++++++++++++++++++++++++++++---------
 2 files changed, 74 insertions(+), 17 deletions(-)

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
index a33d88afb61d..c3cf0129eda5 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5125,6 +5125,44 @@ static const struct kset_uevent_ops slab_uevent_ops = {
 
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
@@ -5136,7 +5174,8 @@ static char *create_unique_id(struct kmem_cache *s)
 	char *name = kmalloc(ID_STR_LENGTH, GFP_KERNEL);
 	char *p = name;
 
-	BUG_ON(!name);
+	if (!name)
+		return NULL;
 
 	*p++ = ':';
 	/*
@@ -5160,8 +5199,7 @@ static char *create_unique_id(struct kmem_cache *s)
 
 #ifdef CONFIG_MEMCG_KMEM
 	if (!is_root_cache(s))
-		p += sprintf(p, "-%08d",
-				memcg_cache_id(s->memcg_params->memcg));
+		p += sprintf(p, ":%d", memcg_cache_id(s->memcg_params->memcg));
 #endif
 
 	BUG_ON(p > name + ID_STR_LENGTH - 1);
@@ -5180,7 +5218,8 @@ static int sysfs_slab_add(struct kmem_cache *s)
 		 * This is typically the case for debug situations. In that
 		 * case we can catch duplicate names easily.
 		 */
-		sysfs_remove_link(&slab_kset->kobj, s->name);
+		if (is_root_cache(s))
+			sysfs_remove_link(&slab_kset->kobj, s->name);
 		name = s->name;
 	} else {
 		/*
@@ -5188,28 +5227,40 @@ static int sysfs_slab_add(struct kmem_cache *s)
 		 * for the symlinks.
 		 */
 		name = create_unique_id(s);
+		if (!name)
+			return -ENOMEM;
 	}
 
-	s->kobj.kset = slab_kset;
+	s->kobj.kset = cache_kset(s);
 	err = kobject_init_and_add(&s->kobj, &slab_ktype, NULL, name);
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
@@ -5221,6 +5272,7 @@ static void sysfs_slab_remove(struct kmem_cache *s)
 		 */
 		return;
 
+	destroy_cache_memcg_kset(s);
 	kobject_uevent(&s->kobj, KOBJ_REMOVE);
 	kobject_del(&s->kobj);
 	kobject_put(&s->kobj);
@@ -5242,6 +5294,8 @@ static int sysfs_slab_alias(struct kmem_cache *s, const char *name)
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
