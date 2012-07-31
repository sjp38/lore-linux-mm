Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 93AE56B0073
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 13:36:36 -0400 (EDT)
Message-Id: <20120731173634.744568366@linux.com>
Date: Tue, 31 Jul 2012 12:36:22 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common [2/9] slub: Use kmem_cache for the kmem_cache structure
References: <20120731173620.432853182@linux.com>
Content-Disposition: inline; filename=slub_use_kmem_cache
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

Do not use kmalloc() but kmem_cache_alloc() for the allocation
of the kmem_cache structures in slub.

This is the way its supposed to be. Recent merges lost
the freeing of the kmem_cache structure and so this is also
fixing memory leak on kmem_cache_destroy() by adding
the missing free action to sysfs_slab_remove().

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-07-31 11:58:40.617457553 -0500
+++ linux-2.6/mm/slub.c	2012-07-31 11:58:47.529574942 -0500
@@ -3938,7 +3938,7 @@
 	if (!n)
 		return NULL;
 
-	s = kmalloc(kmem_size, GFP_KERNEL);
+	s = kmem_cache_alloc(kmem_cache, GFP_KERNEL);
 	if (s) {
 		if (kmem_cache_open(s, n,
 				size, align, flags, ctor)) {
@@ -5318,6 +5318,8 @@
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
