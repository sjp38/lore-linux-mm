Message-Id: <20070618095913.872115919@sgi.com>
References: <20070618095838.238615343@sgi.com>
Date: Mon, 18 Jun 2007 02:58:40 -0700
From: clameter@sgi.com
Subject: [patch 02/26] Slab allocators: Consolidate code for krealloc in mm/util.c
Content-Disposition: inline; filename=slab_allocators_consolidate_krealloc
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

The size of a kmalloc object is readily available via ksize().
ksize is provided by all allocators and thus we canb implement
krealloc in a generic way.

Implement krealloc in mm/util.c and drop slab specific implementations
of krealloc.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slab.c |   46 ----------------------------------------------
 mm/slob.c |   33 ---------------------------------
 mm/slub.c |   37 -------------------------------------
 mm/util.c |   34 ++++++++++++++++++++++++++++++++++
 4 files changed, 34 insertions(+), 116 deletions(-)

Index: linux-2.6.22-rc4-mm2/mm/slab.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/slab.c	2007-06-16 18:58:02.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/slab.c	2007-06-16 18:58:10.000000000 -0700
@@ -3715,52 +3715,6 @@ EXPORT_SYMBOL(__kmalloc);
 #endif
 
 /**
- * krealloc - reallocate memory. The contents will remain unchanged.
- * @p: object to reallocate memory for.
- * @new_size: how many bytes of memory are required.
- * @flags: the type of memory to allocate.
- *
- * The contents of the object pointed to are preserved up to the
- * lesser of the new and old sizes.  If @p is %NULL, krealloc()
- * behaves exactly like kmalloc().  If @size is 0 and @p is not a
- * %NULL pointer, the object pointed to is freed.
- */
-void *krealloc(const void *p, size_t new_size, gfp_t flags)
-{
-	struct kmem_cache *cache, *new_cache;
-	void *ret;
-
-	if (unlikely(!p))
-		return kmalloc_track_caller(new_size, flags);
-
-	if (unlikely(!new_size)) {
-		kfree(p);
-		return NULL;
-	}
-
-	cache = virt_to_cache(p);
-	new_cache = __find_general_cachep(new_size, flags);
-
-	/*
- 	 * If new size fits in the current cache, bail out.
- 	 */
-	if (likely(cache == new_cache))
-		return (void *)p;
-
-	/*
- 	 * We are on the slow-path here so do not use __cache_alloc
- 	 * because it bloats kernel text.
- 	 */
-	ret = kmalloc_track_caller(new_size, flags);
-	if (ret) {
-		memcpy(ret, p, min(new_size, ksize(p)));
-		kfree(p);
-	}
-	return ret;
-}
-EXPORT_SYMBOL(krealloc);
-
-/**
  * kmem_cache_free - Deallocate an object
  * @cachep: The cache the allocation was from.
  * @objp: The previously allocated object.
Index: linux-2.6.22-rc4-mm2/mm/slob.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/slob.c	2007-06-16 18:58:02.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/slob.c	2007-06-16 18:58:10.000000000 -0700
@@ -407,39 +407,6 @@ void *__kmalloc(size_t size, gfp_t gfp)
 }
 EXPORT_SYMBOL(__kmalloc);
 
-/**
- * krealloc - reallocate memory. The contents will remain unchanged.
- *
- * @p: object to reallocate memory for.
- * @new_size: how many bytes of memory are required.
- * @flags: the type of memory to allocate.
- *
- * The contents of the object pointed to are preserved up to the
- * lesser of the new and old sizes.  If @p is %NULL, krealloc()
- * behaves exactly like kmalloc().  If @size is 0 and @p is not a
- * %NULL pointer, the object pointed to is freed.
- */
-void *krealloc(const void *p, size_t new_size, gfp_t flags)
-{
-	void *ret;
-
-	if (unlikely(!p))
-		return kmalloc_track_caller(new_size, flags);
-
-	if (unlikely(!new_size)) {
-		kfree(p);
-		return NULL;
-	}
-
-	ret = kmalloc_track_caller(new_size, flags);
-	if (ret) {
-		memcpy(ret, p, min(new_size, ksize(p)));
-		kfree(p);
-	}
-	return ret;
-}
-EXPORT_SYMBOL(krealloc);
-
 void kfree(const void *block)
 {
 	struct slob_page *sp;
Index: linux-2.6.22-rc4-mm2/mm/slub.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/slub.c	2007-06-16 18:58:02.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/slub.c	2007-06-16 18:58:10.000000000 -0700
@@ -2476,43 +2476,6 @@ int kmem_cache_shrink(struct kmem_cache 
 }
 EXPORT_SYMBOL(kmem_cache_shrink);
 
-/**
- * krealloc - reallocate memory. The contents will remain unchanged.
- * @p: object to reallocate memory for.
- * @new_size: how many bytes of memory are required.
- * @flags: the type of memory to allocate.
- *
- * The contents of the object pointed to are preserved up to the
- * lesser of the new and old sizes.  If @p is %NULL, krealloc()
- * behaves exactly like kmalloc().  If @size is 0 and @p is not a
- * %NULL pointer, the object pointed to is freed.
- */
-void *krealloc(const void *p, size_t new_size, gfp_t flags)
-{
-	void *ret;
-	size_t ks;
-
-	if (unlikely(!p || p == ZERO_SIZE_PTR))
-		return kmalloc(new_size, flags);
-
-	if (unlikely(!new_size)) {
-		kfree(p);
-		return ZERO_SIZE_PTR;
-	}
-
-	ks = ksize(p);
-	if (ks >= new_size)
-		return (void *)p;
-
-	ret = kmalloc(new_size, flags);
-	if (ret) {
-		memcpy(ret, p, min(new_size, ks));
-		kfree(p);
-	}
-	return ret;
-}
-EXPORT_SYMBOL(krealloc);
-
 /********************************************************************
  *			Basic setup of slabs
  *******************************************************************/
Index: linux-2.6.22-rc4-mm2/mm/util.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/util.c	2007-06-16 18:58:02.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/util.c	2007-06-16 19:01:26.000000000 -0700
@@ -81,6 +81,40 @@ void *kmemdup(const void *src, size_t le
 }
 EXPORT_SYMBOL(kmemdup);
 
+/**
+ * krealloc - reallocate memory. The contents will remain unchanged.
+ * @p: object to reallocate memory for.
+ * @new_size: how many bytes of memory are required.
+ * @flags: the type of memory to allocate.
+ *
+ * The contents of the object pointed to are preserved up to the
+ * lesser of the new and old sizes.  If @p is %NULL, krealloc()
+ * behaves exactly like kmalloc().  If @size is 0 and @p is not a
+ * %NULL pointer, the object pointed to is freed.
+ */
+void *krealloc(const void *p, size_t new_size, gfp_t flags)
+{
+	void *ret;
+	size_t ks;
+
+	if (unlikely(!new_size)) {
+		kfree(p);
+		return NULL;
+	}
+
+	ks = ksize(p);
+	if (ks >= new_size)
+		return (void *)p;
+
+	ret = kmalloc_track_caller(new_size, flags);
+	if (ret) {
+		memcpy(ret, p, min(new_size, ks));
+		kfree(p);
+	}
+	return ret;
+}
+EXPORT_SYMBOL(krealloc);
+
 /*
  * strndup_user - duplicate an existing string from user space
  * @s: The string to duplicate

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
