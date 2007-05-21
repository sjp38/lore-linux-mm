Date: Mon, 21 May 2007 12:51:47 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: SLUB: Use ilog2 instead of series of constant comparisons.
Message-ID: <Pine.LNX.4.64.0705211250410.27950@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

I finally found a way to get rid of the nasty list of comparisions in
slub_def.h. ilog2 seems to work right for constants.

Also update comments

Drop the generation of an unresolved symbol for the case that the size is
too big. A simple BUG_ON sufficies now that we can alloc up to MAX_ORDER
size slab objects.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/slub_def.h |   66 ++++++++++++++---------------------------------
 1 file changed, 20 insertions(+), 46 deletions(-)

Index: slub/include/linux/slub_def.h
===================================================================
--- slub.orig/include/linux/slub_def.h	2007-05-21 11:38:19.000000000 -0700
+++ slub/include/linux/slub_def.h	2007-05-21 11:58:16.000000000 -0700
@@ -10,6 +10,7 @@
 #include <linux/gfp.h>
 #include <linux/workqueue.h>
 #include <linux/kobject.h>
+#include <linux/log2.h>
 
 struct kmem_cache_node {
 	spinlock_t list_lock;	/* Protect partial list and nr_partial */
@@ -58,6 +59,8 @@ struct kmem_cache {
  */
 #define KMALLOC_SHIFT_LOW 3
 
+#define KMALLOC_MIN_SIZE (1UL << KMALLOC_SHIFT_LOW)
+
 /*
  * We keep the general caches in an array of slab caches that are used for
  * 2^x bytes of allocations.
@@ -65,56 +68,36 @@ struct kmem_cache {
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
 	/*
-	 * We should return 0 if size == 0 but we use the smallest object
-	 * here for SLAB legacy reasons.
+	 * We should return 0 if size == 0 (which would result in the
+	 * kmalloc caller to get NULL) but we use the smallest object
+	 * here for legacy reasons. Just issue a warning so that
+	 * we can discover locations where we do 0 sized allocations.
 	 */
 	WARN_ON_ONCE(size == 0);
 
 	if (size > KMALLOC_MAX_SIZE)
 		return -1;
 
+	if (size <= KMALLOC_MIN_SIZE)
+		return KMALLOC_SHIFT_LOW;
+
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
@@ -131,18 +114,9 @@ static inline struct kmem_cache *kmalloc
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
