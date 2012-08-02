Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 707F56B005D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 16:15:36 -0400 (EDT)
Message-Id: <20120802201532.623330251@linux.com>
Date: Thu, 02 Aug 2012 15:15:10 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common [04/19] Improve error handling in kmem_cache_create
References: <20120802201506.266817615@linux.com>
Content-Disposition: inline; filename=error_handling_in_kmem_cache_create
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

Instead of using s == NULL use an errorcode. This allows much more
detailed diagnostics as to what went wrong. As we add more functionality
from the slab allocators to the common kmem_cache_create() function we will
also add more error conditions.

Print the error code during the panic as well as in a warning if the module
can handle failure. The API for kmem_cache_create() currently does not allow
the returning of an error code. Return NULL but log the cause of the problem
in the syslog.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux-2.6/mm/slab_common.c
===================================================================
--- linux-2.6.orig/mm/slab_common.c	2012-08-02 14:00:41.547674458 -0500
+++ linux-2.6/mm/slab_common.c	2012-08-02 14:21:07.061676525 -0500
@@ -51,13 +51,13 @@
 struct kmem_cache *kmem_cache_create(const char *name, size_t size, size_t align,
 		unsigned long flags, void (*ctor)(void *))
 {
-	struct kmem_cache *s = NULL;
+	struct kmem_cache *s;
+	int err = 0;
 
 #ifdef CONFIG_DEBUG_VM
 	if (!name || in_interrupt() || size < sizeof(void *) ||
 		size > KMALLOC_MAX_SIZE) {
-		printk(KERN_ERR "kmem_cache_create(%s) integrity check"
-			" failed\n", name);
+		err = -EINVAL;
 		goto out;
 	}
 #endif
@@ -84,11 +84,7 @@
 		}
 
 		if (!strcmp(s->name, name)) {
-			printk(KERN_ERR "kmem_cache_create(%s): Cache name"
-				" already exists.\n",
-				name);
-			dump_stack();
-			s = NULL;
+			err = -EEXIST;
 			goto out_locked;
 		}
 	}
@@ -97,6 +93,8 @@
 #endif
 
 	s = __kmem_cache_create(name, size, align, flags, ctor);
+	if (!s)
+		err = -ENOSYS; /* Until __kmem_cache_create returns code */
 
 #ifdef CONFIG_DEBUG_VM
 out_locked:
@@ -107,8 +105,19 @@
 #ifdef CONFIG_DEBUG_VM
 out:
 #endif
-	if (!s && (flags & SLAB_PANIC))
-		panic("kmem_cache_create: Failed to create slab '%s'\n", name);
+	if (err) {
+
+		if (flags & SLAB_PANIC)
+			panic("kmem_cache_create: Failed to create slab '%s'. Error %d\n",
+				name, err);
+		else {
+			printk(KERN_WARNING "kmem_cache_create(%s) failed with error %d",
+				name, err);
+			dump_stack();
+		}
+
+		return NULL;
+	}
 
 	return s;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
