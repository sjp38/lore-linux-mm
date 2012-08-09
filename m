Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id C70446B0082
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 10:22:06 -0400 (EDT)
Message-Id: <20120809135635.132538987@linux.com>
Date: Thu, 09 Aug 2012 08:56:33 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common11r [10/20] Move duping of slab name to slab_common.c
References: <20120809135623.574621297@linux.com>
Content-Disposition: inline; filename=dup_name_in_common
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Duping of the slabname has to be done by each slab. Moving this code
to slab_common avoids duplicate implementations.

With this patch we have common string handling for all slab allocators.
Strings passed to kmem_cache_create() are copied internally. Subsystems
can create temporary strings to create slab caches.

Slabs allocated in early states of bootstrap will never be freed (and those
can never be freed since they are essential to slab allocator operations).
During bootstrap we therefore do not have to worry about duping names.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slab_common.c |   24 +++++++++++++++++-------
 mm/slub.c        |    5 -----
 2 files changed, 17 insertions(+), 12 deletions(-)

Index: linux-2.6/mm/slab_common.c
===================================================================
--- linux-2.6.orig/mm/slab_common.c	2012-08-08 09:54:18.576146705 -0500
+++ linux-2.6/mm/slab_common.c	2012-08-08 09:54:31.016169589 -0500
@@ -54,6 +54,7 @@ struct kmem_cache *kmem_cache_create(con
 {
 	struct kmem_cache *s;
 	int err = 0;
+	char *n;
 
 #ifdef CONFIG_DEBUG_VM
 	if (!name || in_interrupt() || size < sizeof(void *) ||
@@ -93,20 +94,28 @@ struct kmem_cache *kmem_cache_create(con
 	WARN_ON(strchr(name, ' '));	/* It confuses parsers */
 #endif
 
-	s = __kmem_cache_create(name, size, align, flags, ctor);
-	if (!s)
-		err = -ENOSYS; /* Until __kmem_cache_create returns code */
+	n = kstrdup(name, GFP_KERNEL);
+	if (!n) {
+		err = -ENOMEM;
+		goto out_locked;
+	}
 
-	/*
-	 * Check if the slab has actually been created and if it was a
-	 * real instatiation. Aliases do not belong on the list
-	 */
-	if (s && s->refcount == 1)
-		list_add(&s->list, &slab_caches);
+	s = __kmem_cache_create(n, size, align, flags, ctor);
+
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
 
-#ifdef CONFIG_DEBUG_VM
 out_locked:
-#endif
 	mutex_unlock(&slab_mutex);
 	put_online_cpus();
 
@@ -143,6 +152,7 @@ void kmem_cache_destroy(struct kmem_cach
 			if (s->flags & SLAB_DESTROY_BY_RCU)
 				rcu_barrier();
 
+			kfree(s->name);
 			kmem_cache_free(kmem_cache, s);
 		} else {
 			list_add(&s->list, &slab_caches);
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-08-08 09:54:18.572146697 -0500
+++ linux-2.6/mm/slub.c	2012-08-08 09:54:20.788150792 -0500
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
 
@@ -3922,7 +3919,6 @@ struct kmem_cache *__kmem_cache_create(c
 		size_t align, unsigned long flags, void (*ctor)(void *))
 {
 	struct kmem_cache *s;
-	char *n;
 
 	s = find_mergeable(size, align, flags, name, ctor);
 	if (s) {
@@ -3941,13 +3937,9 @@ struct kmem_cache *__kmem_cache_create(c
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
 
@@ -3962,7 +3954,6 @@ struct kmem_cache *__kmem_cache_create(c
 		}
 		kmem_cache_free(kmem_cache, s);
 	}
-	kfree(n);
 	return NULL;
 }
 
@@ -5193,13 +5184,6 @@ static ssize_t slab_attr_store(struct ko
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
@@ -5207,7 +5191,6 @@ static const struct sysfs_ops slab_sysfs
 
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
