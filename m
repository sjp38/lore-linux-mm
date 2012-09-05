Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 210706B005D
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 20:20:35 -0400 (EDT)
Message-Id: <0000013993ccbf50-814ada10-2cc1-4729-b312-d13bf8392174-000000@email.amazonses.com>
Date: Wed, 5 Sep 2012 00:20:33 +0000
From: Christoph Lameter <cl@linux.com>
Subject: C14 [03/14] Improve error handling in kmem_cache_create
References: <20120904230609.691088980@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org

Instead of using s == NULL use an errorcode. This allows much more
detailed diagnostics as to what went wrong. As we add more functionality
from the slab allocators to the common kmem_cache_create() function we will
also add more error conditions.

Print the error code during the panic as well as in a warning if the module
can handle failure. The API for kmem_cache_create() currently does not allow
the returning of an error code. Return NULL but log the cause of the problem
in the syslog.

Reviewed-by: Glauber Costa <glommer@parallels.com>
Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: Christoph Lameter <cl@linux.com>
---
 mm/slab_common.c |   30 +++++++++++++++++++++++++-----
 1 file changed, 25 insertions(+), 5 deletions(-)

Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c	2012-09-04 18:00:13.098023913 -0500
+++ linux/mm/slab_common.c	2012-09-04 18:01:59.755688501 -0500
@@ -98,16 +98,36 @@ struct kmem_cache *kmem_cache_create(con
 		unsigned long flags, void (*ctor)(void *))
 {
 	struct kmem_cache *s = NULL;
+	int err = 0;
 
 	get_online_cpus();
 	mutex_lock(&slab_mutex);
-	if (kmem_cache_sanity_check(name, size) == 0)
-		s = __kmem_cache_create(name, size, align, flags, ctor);
+
+	if (!kmem_cache_sanity_check(name, size) == 0)
+		goto out_locked;
+
+
+	s = __kmem_cache_create(name, size, align, flags, ctor);
+	if (!s)
+		err = -ENOSYS; /* Until __kmem_cache_create returns code */
+
+out_locked:
 	mutex_unlock(&slab_mutex);
 	put_online_cpus();
 
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
