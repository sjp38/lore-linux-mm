Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 3A7496B0044
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 16:15:33 -0400 (EDT)
Message-Id: <20120802201531.490489455@linux.com>
Date: Thu, 02 Aug 2012 15:15:08 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common [02/19] slub: Use kmem_cache for the kmem_cache structure
References: <20120802201506.266817615@linux.com>
Content-Disposition: inline; filename=slub_use_kmem_cache
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

Do not use kmalloc() but kmem_cache_alloc() for the allocation
of the kmem_cache structures in slub.

This is the way its supposed to be. Recent merges lost
the freeing of the kmem_cache structure and so this is also
fixing memory leak on kmem_cache_destroy() by adding
the missing free action to sysfs_slab_remove().

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-08-01 13:02:18.897656578 -0500
+++ linux-2.6/mm/slub.c	2012-08-01 13:06:02.673597753 -0500
@@ -213,7 +213,7 @@
 static inline void sysfs_slab_remove(struct kmem_cache *s)
 {
 	kfree(s->name);
-	kfree(s);
+	kmem_cache_free(kmem_cache, s);
 }
 
 #endif
@@ -3962,7 +3962,7 @@
 	if (!n)
 		return NULL;
 
-	s = kmalloc(kmem_size, GFP_KERNEL);
+	s = kmem_cache_alloc(kmem_cache, GFP_KERNEL);
 	if (s) {
 		if (kmem_cache_open(s, n,
 				size, align, flags, ctor)) {
@@ -3979,7 +3979,7 @@
 			list_del(&s->list);
 			kmem_cache_close(s);
 		}
-		kfree(s);
+		kmem_cache_free(kmem_cache, s);
 	}
 	kfree(n);
 	return NULL;
@@ -5217,7 +5217,7 @@
 	struct kmem_cache *s = to_slab(kobj);
 
 	kfree(s->name);
-	kfree(s);
+	kmem_cache_free(kmem_cache, s);
 }
 
 static const struct sysfs_ops slab_sysfs_ops = {
@@ -5342,6 +5342,8 @@
 	kobject_uevent(&s->kobj, KOBJ_REMOVE);
 	kobject_del(&s->kobj);
 	kobject_put(&s->kobj);
+	kfree(s->name);
+	kmem_cache_free(kmem_cache, s);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
