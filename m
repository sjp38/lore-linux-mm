Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id EF6456B0062
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 08:35:26 -0400 (EDT)
Received: by mail-gg0-f169.google.com with SMTP id i1so59730ggm.14
        for <linux-mm@kvack.org>; Fri, 19 Oct 2012 05:35:26 -0700 (PDT)
From: Ezequiel Garcia <elezegarcia@gmail.com>
Subject: [PATCH v2 3/3] mm/sl[aou]b: Move common kmem_cache_size() to slab.h
Date: Fri, 19 Oct 2012 09:33:12 -0300
Message-Id: <1350649992-25988-3-git-send-email-elezegarcia@gmail.com>
In-Reply-To: <1350649992-25988-1-git-send-email-elezegarcia@gmail.com>
References: <1350649992-25988-1-git-send-email-elezegarcia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Tim Bird <tim.bird@am.sony.com>, Ezequiel Garcia <elezegarcia@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

This function is identically defined in all three allocators
and it's trivial to move it to slab.h

Since now it's static, inline, header-defined function
this patch also drops the EXPORT_SYMBOL tag.

Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Matt Mackall <mpm@selenic.com>
Signed-off-by: Ezequiel Garcia <elezegarcia@gmail.com>
---
Changes from v1:
 * Declare kmem_cache_size() static inline

 include/linux/slab.h |    9 ++++++++-
 mm/slab.c            |    6 ------
 mm/slob.c            |    6 ------
 mm/slub.c            |    9 ---------
 4 files changed, 8 insertions(+), 22 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 83d1a14..743a104 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -128,7 +128,6 @@ struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
 void kmem_cache_free(struct kmem_cache *, void *);
-unsigned int kmem_cache_size(struct kmem_cache *);
 
 /*
  * Please use this macro to create slab caches. Simply specify the
@@ -388,6 +387,14 @@ static inline void *kzalloc_node(size_t size, gfp_t flags, int node)
 	return kmalloc_node(size, flags | __GFP_ZERO, node);
 }
 
+/*
+ * Determine the size of a slab object
+ */
+static inline unsigned int kmem_cache_size(struct kmem_cache *s)
+{
+	return s->object_size;
+}
+
 void __init kmem_cache_init_late(void);
 
 #endif	/* _LINUX_SLAB_H */
diff --git a/mm/slab.c b/mm/slab.c
index 87c55b0..92a3fec 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3969,12 +3969,6 @@ void kfree(const void *objp)
 }
 EXPORT_SYMBOL(kfree);
 
-unsigned int kmem_cache_size(struct kmem_cache *cachep)
-{
-	return cachep->object_size;
-}
-EXPORT_SYMBOL(kmem_cache_size);
-
 /*
  * This initializes kmem_list3 or resizes various caches for all nodes.
  */
diff --git a/mm/slob.c b/mm/slob.c
index 287a88a..fffbc82 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -604,12 +604,6 @@ void kmem_cache_free(struct kmem_cache *c, void *b)
 }
 EXPORT_SYMBOL(kmem_cache_free);
 
-unsigned int kmem_cache_size(struct kmem_cache *c)
-{
-	return c->object_size;
-}
-EXPORT_SYMBOL(kmem_cache_size);
-
 int __kmem_cache_shutdown(struct kmem_cache *c)
 {
 	/* No way to check for remaining objects */
diff --git a/mm/slub.c b/mm/slub.c
index a0d6984..1f826b0 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3127,15 +3127,6 @@ error:
 	return -EINVAL;
 }
 
-/*
- * Determine the size of a slab object
- */
-unsigned int kmem_cache_size(struct kmem_cache *s)
-{
-	return s->object_size;
-}
-EXPORT_SYMBOL(kmem_cache_size);
-
 static void list_slab_objects(struct kmem_cache *s, struct page *page,
 							const char *text)
 {
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
