Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 199056B0068
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 15:53:11 -0400 (EDT)
Message-Id: <20120601195309.291946115@linux.com>
Date: Fri, 01 Jun 2012 14:53:02 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common [17/20] Move duping of slab name to slab_common.c
References: <20120601195245.084749371@linux.com>
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
--- linux-2.6.orig/mm/slab_common.c	2012-05-30 08:33:47.000000000 -0500
+++ linux-2.6/mm/slab_common.c	2012-05-30 08:34:05.694181356 -0500
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
--- linux-2.6.orig/mm/slub.c	2012-05-30 08:33:47.042181744 -0500
+++ linux-2.6/mm/slub.c	2012-05-30 08:34:05.698181356 -0500
@@ -3913,10 +3913,6 @@ struct kmem_cache *__kmem_cache_create(c
 		return s;
 	}
 
-	n = kstrdup(name, GFP_KERNEL);
-	if (!n)
-		return NULL;
-
 	s = kmalloc(kmem_size, GFP_KERNEL);
 	if (s) {
 		if (kmem_cache_open(s, n,
@@ -3934,7 +3930,6 @@ struct kmem_cache *__kmem_cache_create(c
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
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
