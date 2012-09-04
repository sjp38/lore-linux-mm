Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 7C61D6B0080
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 19:18:36 -0400 (EDT)
Message-Id: <000001399393fdc6-df18910c-f78c-4e11-b1fd-89415ff19a58-000000@email.amazonses.com>
Date: Tue, 4 Sep 2012 23:18:33 +0000
From: Christoph Lameter <cl@linux.com>
Subject: C14 [09/14] Move duping of slab name to slab_common.c
References: <20120904230609.691088980@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Duping of the slabname has to be done by each slab. Moving this code
to slab_common avoids duplicate implementations.

With this patch we have common string handling for all slab allocators.
Strings passed to kmem_cache_create() are copied internally. Subsystems
can create temporary strings to create slab caches.

Slabs allocated in early states of bootstrap will never be freed (and those
can never be freed since they are essential to slab allocator operations).
During bootstrap we therefore do not have to worry about duping names.

Reviewed-by: Glauber Costa <glommer@parallels.com>
Signed-off-by: Christoph Lameter <cl@linux.com>
---
 mm/slab_common.c |   30 +++++++++++++++++++++---------
 mm/slub.c        |   21 ++-------------------
 2 files changed, 23 insertions(+), 28 deletions(-)

Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c	2012-09-04 18:00:16.802081734 -0500
+++ linux/mm/slab_common.c	2012-09-04 18:01:55.531622575 -0500
@@ -100,6 +100,7 @@ struct kmem_cache *kmem_cache_create(con
 {
 	struct kmem_cache *s = NULL;
 	int err = 0;
+	char *n;
 
 	get_online_cpus();
 	mutex_lock(&slab_mutex);
@@ -108,16 +109,26 @@ struct kmem_cache *kmem_cache_create(con
 		goto out_locked;
 
 
-	s = __kmem_cache_create(name, size, align, flags, ctor);
-	if (!s)
-		err = -ENOSYS; /* Until __kmem_cache_create returns code */
+	n = kstrdup(name, GFP_KERNEL);
+	if (!n) {
+		err = -ENOMEM;
+		goto out_locked;
+	}
+
+	s = __kmem_cache_create(n, size, align, flags, ctor);
 
-	/*
-	 * Check if the slab has actually been created and if it was a
-	 * real instatiation. Aliases do not belong on the list
-	 */
-	if (s && s->refcount == 1)
-		list_add(&s->list, &slab_caches);
+	if (s) {
+		/*
+		 * Check if the slab has actually been created and if it was a
+		 * real instatiation. Aliases do not belong on the list
+		 */
+		if (s->refcount == 1)
+			list_add(&s->list, &slab_caches);
+
+	} else {
+		kfree(n);
+		err = -ENOSYS; /* Until __kmem_cache_create returns code */
+	}
 
 out_locked:
 	mutex_unlock(&slab_mutex);
@@ -153,6 +164,7 @@ void kmem_cache_destroy(struct kmem_cach
 			if (s->flags & SLAB_DESTROY_BY_RCU)
 				rcu_barrier();
 
+			kfree(s->name);
 			kmem_cache_free(kmem_cache, s);
 		} else {
 			list_add(&s->list, &slab_caches);
Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2012-09-04 18:00:16.806081796 -0500
+++ linux/mm/slub.c	2012-09-04 18:01:55.543622767 -0500
@@ -210,10 +210,7 @@ static void sysfs_slab_remove(struct kme
 static inline int sysfs_slab_add(struct kmem_cache *s) { return 0; }
 static inline int sysfs_slab_alias(struct kmem_cache *s, const char *p)
 							{ return 0; }
-static inline void sysfs_slab_remove(struct kmem_cache *s)
-{
-	kfree(s->name);
-}
+static inline void sysfs_slab_remove(struct kmem_cache *s) { }
 
 #endif
 
@@ -3929,7 +3926,6 @@ struct kmem_cache *__kmem_cache_create(c
 		size_t align, unsigned long flags, void (*ctor)(void *))
 {
 	struct kmem_cache *s;
-	char *n;
 
 	s = find_mergeable(size, align, flags, name, ctor);
 	if (s) {
@@ -3948,13 +3944,9 @@ struct kmem_cache *__kmem_cache_create(c
 		return s;
 	}
 
-	n = kstrdup(name, GFP_KERNEL);
-	if (!n)
-		return NULL;
-
 	s = kmem_cache_alloc(kmem_cache, GFP_KERNEL);
 	if (s) {
-		if (kmem_cache_open(s, n,
+		if (kmem_cache_open(s, name,
 				size, align, flags, ctor)) {
 			int r;
 
@@ -3969,7 +3961,6 @@ struct kmem_cache *__kmem_cache_create(c
 		}
 		kmem_cache_free(kmem_cache, s);
 	}
-	kfree(n);
 	return NULL;
 }
 
@@ -5200,13 +5191,6 @@ static ssize_t slab_attr_store(struct ko
 	return err;
 }
 
-static void kmem_cache_release(struct kobject *kobj)
-{
-	struct kmem_cache *s = to_slab(kobj);
-
-	kfree(s->name);
-}
-
 static const struct sysfs_ops slab_sysfs_ops = {
 	.show = slab_attr_show,
 	.store = slab_attr_store,
@@ -5214,7 +5198,6 @@ static const struct sysfs_ops slab_sysfs
 
 static struct kobj_type slab_ktype = {
 	.sysfs_ops = &slab_sysfs_ops,
-	.release = kmem_cache_release
 };
 
 static int uevent_filter(struct kset *kset, struct kobject *kobj)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
