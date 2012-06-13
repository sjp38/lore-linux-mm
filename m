Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 228936B0089
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 11:25:26 -0400 (EDT)
Message-Id: <20120613152524.444246406@linux.com>
Date: Wed, 13 Jun 2012 10:25:08 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common [17/20] Move duping of slab name to slab_common.c
References: <20120613152451.465596612@linux.com>
Content-Disposition: inline; filename=dup_name_in_common
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

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
--- linux-2.6.orig/mm/slab_common.c	2012-06-13 03:44:40.949477453 -0500
+++ linux-2.6/mm/slab_common.c	2012-06-13 03:45:14.429476759 -0500
@@ -53,6 +53,7 @@ struct kmem_cache *kmem_cache_create(con
 		unsigned long flags, void (*ctor)(void *))
 {
 	struct kmem_cache *s = NULL;
+	char *n;
 
 #ifdef CONFIG_DEBUG_VM
 	if (!name || in_interrupt() || size < sizeof(void *) ||
@@ -97,14 +98,22 @@ struct kmem_cache *kmem_cache_create(con
 	WARN_ON(strchr(name, ' '));	/* It confuses parsers */
 #endif
 
-	s = __kmem_cache_create(name, size, align, flags, ctor);
+	n = kstrdup(name, GFP_KERNEL);
+	if (!n)
+		goto oops;
 
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
+	} else
+		kfree(n);
 
 oops:
 	mutex_unlock(&slab_mutex);
@@ -128,6 +137,7 @@ void kmem_cache_destroy(struct kmem_cach
 		if (s->flags & SLAB_DESTROY_BY_RCU)
 			rcu_barrier();
 
+		kfree(s->name);
 		kmem_cache_free(kmem_cache, s);
 	} else {
 		list_add(&s->list, &slab_caches);
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-06-13 03:44:40.945477453 -0500
+++ linux-2.6/mm/slub.c	2012-06-13 03:45:14.393476760 -0500
@@ -3926,10 +3926,6 @@ struct kmem_cache *__kmem_cache_create(c
 		return s;
 	}
 
-	n = kstrdup(name, GFP_KERNEL);
-	if (!n)
-		return NULL;
-
 	s = kmalloc(kmem_size, GFP_KERNEL);
 	if (s) {
 		if (kmem_cache_open(s, n,
@@ -3947,7 +3943,6 @@ struct kmem_cache *__kmem_cache_create(c
 		}
 		kfree(s);
 	}
-	kfree(n);
 	return NULL;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
