Message-Id: <20070614075337.104048463@sgi.com>
References: <20070614075026.607300756@sgi.com>
Date: Thu, 14 Jun 2007 00:50:39 -0700
From: clameter@sgi.com
Subject: [RFC 13/13] I finally found a way to get rid of the nasty list of comparisions in slub_def.h. ilog2 seems to work right for constants.
Content-Disposition: inline; filename=slub_ilog2
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Also update comments

Drop the generation of an unresolved symbol for the case that the size is
too big. A simple BUG_ON sufficies now that we can alloc up to MAX_ORDER
size slab objects.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/slub_def.h |   56 +++++++++--------------------------------------
 1 file changed, 11 insertions(+), 45 deletions(-)

Index: vps/include/linux/slub_def.h
===================================================================
--- vps.orig/include/linux/slub_def.h	2007-06-12 16:09:56.000000000 -0700
+++ vps/include/linux/slub_def.h	2007-06-12 16:32:44.000000000 -0700
@@ -10,6 +10,7 @@
 #include <linux/gfp.h>
 #include <linux/workqueue.h>
 #include <linux/kobject.h>
+#include <linux/log2.h>
 
 struct kmem_cache_node {
 	spinlock_t list_lock;	/* Protect partial list and nr_partial */
@@ -71,8 +72,9 @@ struct kmem_cache {
 extern struct kmem_cache kmalloc_caches[KMALLOC_SHIFT_HIGH + 1];
 
 /*
- * Sorry that the following has to be that ugly but some versions of GCC
- * have trouble with constant propagation and loops.
+ * Determine the kmalloc array index given the object size.
+ *
+ * Return -1 if the object size is not supported.
  */
 static inline int kmalloc_index(size_t size)
 {
@@ -85,42 +87,15 @@ static inline int kmalloc_index(size_t s
 	if (size <= KMALLOC_MIN_SIZE)
 		return KMALLOC_SHIFT_LOW;
 
+	/*
+	 * We map the non power of two slabs to the unused
+	 * log2 values in the kmalloc array.
+	 */
 	if (size > 64 && size <= 96)
 		return 1;
 	if (size > 128 && size <= 192)
 		return 2;
-	if (size <=          8) return 3;
-	if (size <=         16) return 4;
-	if (size <=         32) return 5;
-	if (size <=         64) return 6;
-	if (size <=        128) return 7;
-	if (size <=        256) return 8;
-	if (size <=        512) return 9;
-	if (size <=       1024) return 10;
-	if (size <=   2 * 1024) return 11;
-	if (size <=   4 * 1024) return 12;
-	if (size <=   8 * 1024) return 13;
-	if (size <=  16 * 1024) return 14;
-	if (size <=  32 * 1024) return 15;
-	if (size <=  64 * 1024) return 16;
-	if (size <= 128 * 1024) return 17;
-	if (size <= 256 * 1024) return 18;
-	if (size <=  512 * 1024) return 19;
-	if (size <= 1024 * 1024) return 20;
-	if (size <=  2 * 1024 * 1024) return 21;
-	if (size <=  4 * 1024 * 1024) return 22;
-	if (size <=  8 * 1024 * 1024) return 23;
-	if (size <= 16 * 1024 * 1024) return 24;
-	if (size <= 32 * 1024 * 1024) return 25;
-	return -1;
-
-/*
- * What we really wanted to do and cannot do because of compiler issues is:
- *	int i;
- *	for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_HIGH; i++)
- *		if (size <= (1 << i))
- *			return i;
- */
+	return ilog2(size - 1) + 1;
 }
 
 /*
@@ -137,18 +112,9 @@ static inline struct kmem_cache *kmalloc
 		return NULL;
 
 	/*
-	 * This function only gets expanded if __builtin_constant_p(size), so
-	 * testing it here shouldn't be needed.  But some versions of gcc need
-	 * help.
+	 * If this triggers then the amount of memory requested was too large.
 	 */
-	if (__builtin_constant_p(size) && index < 0) {
-		/*
-		 * Generate a link failure. Would be great if we could
-		 * do something to stop the compile here.
-		 */
-		extern void __kmalloc_size_too_large(void);
-		__kmalloc_size_too_large();
-	}
+	BUG_ON(index < 0);
 	return &kmalloc_caches[index];
 }
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
