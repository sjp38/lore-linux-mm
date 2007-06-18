Message-Id: <20070618095914.097484951@sgi.com>
References: <20070618095838.238615343@sgi.com>
Date: Mon, 18 Jun 2007 02:58:41 -0700
From: clameter@sgi.com
Subject: [patch 03/26] Slab allocators: Consistent ZERO_SIZE_PTR support and NULL result semantics
Content-Disposition: inline; filename=slab_allocators_consolidate_zero_size_ptr
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

Define ZERO_OR_NULL_PTR macro to be able to remove the checks
from the allocators. Move ZERO_SIZE_PTR related stuff into slab.h.

Make ZERO_SIZE_PTR work for all slab allocators and get rid of the
WARN_ON_ONCE(size == 0) that is still remaining in SLAB.

Make slub return NULL like the other allocators if a too large
memory segment is requested via __kmalloc.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/slab.h     |   13 +++++++++++++
 include/linux/slab_def.h |   12 ++++++++++++
 include/linux/slub_def.h |   11 -----------
 mm/slab.c                |   14 ++++++++------
 mm/slob.c                |   13 ++++++++-----
 mm/slub.c                |   29 ++++++++++++++++-------------
 mm/util.c                |    2 +-
 7 files changed, 58 insertions(+), 36 deletions(-)

Index: linux-2.6.22-rc4-mm2/include/linux/slab.h
===================================================================
--- linux-2.6.22-rc4-mm2.orig/include/linux/slab.h	2007-06-12 12:04:57.000000000 -0700
+++ linux-2.6.22-rc4-mm2/include/linux/slab.h	2007-06-17 20:35:03.000000000 -0700
@@ -33,6 +33,19 @@
 #define SLAB_RECLAIM_ACCOUNT	0x00020000UL		/* Objects are reclaimable */
 #define SLAB_TEMPORARY		SLAB_RECLAIM_ACCOUNT	/* Objects are short-lived */
 /*
+ * ZERO_SIZE_PTR will be returned for zero sized kmalloc requests.
+ *
+ * Dereferencing ZERO_SIZE_PTR will lead to a distinct access fault.
+ *
+ * ZERO_SIZE_PTR can be passed to kfree though in the same way that NULL can.
+ * Both make kfree a no-op.
+ */
+#define ZERO_SIZE_PTR ((void *)16)
+
+#define ZERO_OR_NULL_PTR(x) ((unsigned long)(x) < \
+				(unsigned long)ZERO_SIZE_PTR)
+
+/*
  * struct kmem_cache related prototypes
  */
 void __init kmem_cache_init(void);
Index: linux-2.6.22-rc4-mm2/include/linux/slab_def.h
===================================================================
--- linux-2.6.22-rc4-mm2.orig/include/linux/slab_def.h	2007-06-04 17:57:25.000000000 -0700
+++ linux-2.6.22-rc4-mm2/include/linux/slab_def.h	2007-06-17 20:35:03.000000000 -0700
@@ -29,6 +29,10 @@ static inline void *kmalloc(size_t size,
 {
 	if (__builtin_constant_p(size)) {
 		int i = 0;
+
+		if (!size)
+			return ZERO_SIZE_PTR;
+
 #define CACHE(x) \
 		if (size <= x) \
 			goto found; \
@@ -55,6 +59,10 @@ static inline void *kzalloc(size_t size,
 {
 	if (__builtin_constant_p(size)) {
 		int i = 0;
+
+		if (!size)
+			return ZERO_SIZE_PTR;
+
 #define CACHE(x) \
 		if (size <= x) \
 			goto found; \
@@ -84,6 +92,10 @@ static inline void *kmalloc_node(size_t 
 {
 	if (__builtin_constant_p(size)) {
 		int i = 0;
+
+		if (!size)
+			return ZERO_SIZE_PTR;
+
 #define CACHE(x) \
 		if (size <= x) \
 			goto found; \
Index: linux-2.6.22-rc4-mm2/include/linux/slub_def.h
===================================================================
--- linux-2.6.22-rc4-mm2.orig/include/linux/slub_def.h	2007-06-17 19:10:33.000000000 -0700
+++ linux-2.6.22-rc4-mm2/include/linux/slub_def.h	2007-06-17 20:35:03.000000000 -0700
@@ -160,17 +160,6 @@ static inline struct kmem_cache *kmalloc
 #endif
 
 
-/*
- * ZERO_SIZE_PTR will be returned for zero sized kmalloc requests.
- *
- * Dereferencing ZERO_SIZE_PTR will lead to a distinct access fault.
- *
- * ZERO_SIZE_PTR can be passed to kfree though in the same way that NULL can.
- * Both make kfree a no-op.
- */
-#define ZERO_SIZE_PTR ((void *)16)
-
-
 static inline void *kmalloc(size_t size, gfp_t flags)
 {
 	if (__builtin_constant_p(size) && !(flags & SLUB_DMA)) {
Index: linux-2.6.22-rc4-mm2/mm/slab.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/slab.c	2007-06-17 19:10:33.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/slab.c	2007-06-17 20:35:08.000000000 -0700
@@ -774,7 +774,9 @@ static inline struct kmem_cache *__find_
 	 */
 	BUG_ON(malloc_sizes[INDEX_AC].cs_cachep == NULL);
 #endif
-	WARN_ON_ONCE(size == 0);
+	if (!size)
+		return ZERO_SIZE_PTR;
+
 	while (size > csizep->cs_size)
 		csizep++;
 
@@ -2340,7 +2342,7 @@ kmem_cache_create (const char *name, siz
 		 * this should not happen at all.
 		 * But leave a BUG_ON for some lucky dude.
 		 */
-		BUG_ON(!cachep->slabp_cache);
+		BUG_ON(ZERO_OR_NULL_PTR(cachep->slabp_cache));
 	}
 	cachep->ctor = ctor;
 	cachep->name = name;
@@ -3642,8 +3644,8 @@ __do_kmalloc_node(size_t size, gfp_t fla
 	struct kmem_cache *cachep;
 
 	cachep = kmem_find_general_cachep(size, flags);
-	if (unlikely(cachep == NULL))
-		return NULL;
+	if (unlikely(ZERO_OR_NULL_PTR(cachep)))
+		return cachep;
 	return kmem_cache_alloc_node(cachep, flags, node);
 }
 
@@ -3749,7 +3751,7 @@ void kfree(const void *objp)
 	struct kmem_cache *c;
 	unsigned long flags;
 
-	if (unlikely(!objp))
+	if (unlikely(ZERO_OR_NULL_PTR(objp)))
 		return;
 	local_irq_save(flags);
 	kfree_debugcheck(objp);
@@ -4436,7 +4438,7 @@ const struct seq_operations slabstats_op
  */
 size_t ksize(const void *objp)
 {
-	if (unlikely(objp == NULL))
+	if (unlikely(ZERO_OR_NULL_PTR(objp)))
 		return 0;
 
 	return obj_size(virt_to_cache(objp));
Index: linux-2.6.22-rc4-mm2/mm/slob.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/slob.c	2007-06-17 19:10:33.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/slob.c	2007-06-17 20:35:04.000000000 -0700
@@ -306,7 +306,7 @@ static void slob_free(void *block, int s
 	slobidx_t units;
 	unsigned long flags;
 
-	if (!block)
+	if (ZERO_OR_NULL_PTR(block))
 		return;
 	BUG_ON(!size);
 
@@ -384,11 +384,14 @@ out:
 
 void *__kmalloc(size_t size, gfp_t gfp)
 {
+	unsigned int *m;
 	int align = max(ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
 
 	if (size < PAGE_SIZE - align) {
-		unsigned int *m;
-		m = slob_alloc(size + align, gfp, align);
+		if (!size)
+			return ZERO_SIZE_PTR;
+
+		m = slob_alloc(size + align, gfp, align);
 		if (m)
 			*m = size;
 		return (void *)m + align;
@@ -411,7 +414,7 @@ void kfree(const void *block)
 {
 	struct slob_page *sp;
 
-	if (!block)
+	if (ZERO_OR_NULL_PTR(block))
 		return;
 
 	sp = (struct slob_page *)virt_to_page(block);
@@ -430,7 +433,7 @@ size_t ksize(const void *block)
 {
 	struct slob_page *sp;
 
-	if (!block)
+	if (ZERO_OR_NULL_PTR(block))
 		return 0;
 
 	sp = (struct slob_page *)virt_to_page(block);
Index: linux-2.6.22-rc4-mm2/mm/util.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/util.c	2007-06-17 19:10:33.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/util.c	2007-06-17 20:35:03.000000000 -0700
@@ -99,7 +99,7 @@ void *krealloc(const void *p, size_t new
 
 	if (unlikely(!new_size)) {
 		kfree(p);
-		return NULL;
+		return ZERO_SIZE_PTR;
 	}
 
 	ks = ksize(p);
Index: linux-2.6.22-rc4-mm2/mm/slub.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/slub.c	2007-06-17 19:10:33.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/slub.c	2007-06-17 20:35:04.000000000 -0700
@@ -2279,10 +2279,11 @@ static struct kmem_cache *get_slab(size_
 	int index = kmalloc_index(size);
 
 	if (!index)
-		return NULL;
+		return ZERO_SIZE_PTR;
 
 	/* Allocation too large? */
-	BUG_ON(index < 0);
+	if (index < 0)
+		return NULL;
 
 #ifdef CONFIG_ZONE_DMA
 	if ((flags & SLUB_DMA)) {
@@ -2323,9 +2324,10 @@ void *__kmalloc(size_t size, gfp_t flags
 {
 	struct kmem_cache *s = get_slab(size, flags);
 
-	if (s)
-		return slab_alloc(s, flags, -1, __builtin_return_address(0));
-	return ZERO_SIZE_PTR;
+	if (ZERO_OR_NULL_PTR(s))
+		return s;
+
+	return slab_alloc(s, flags, -1, __builtin_return_address(0));
 }
 EXPORT_SYMBOL(__kmalloc);
 
@@ -2334,9 +2336,10 @@ void *__kmalloc_node(size_t size, gfp_t 
 {
 	struct kmem_cache *s = get_slab(size, flags);
 
-	if (s)
-		return slab_alloc(s, flags, node, __builtin_return_address(0));
-	return ZERO_SIZE_PTR;
+	if (ZERO_OR_NULL_PTR(s))
+		return s;
+
+	return slab_alloc(s, flags, node, __builtin_return_address(0));
 }
 EXPORT_SYMBOL(__kmalloc_node);
 #endif
@@ -2387,7 +2390,7 @@ void kfree(const void *x)
 	 * this comparison would be true for all "negative" pointers
 	 * (which would cover the whole upper half of the address space).
 	 */
-	if ((unsigned long)x <= (unsigned long)ZERO_SIZE_PTR)
+	if (ZERO_OR_NULL_PTR(x))
 		return;
 
 	page = virt_to_head_page(x);
@@ -2706,8 +2709,8 @@ void *__kmalloc_track_caller(size_t size
 {
 	struct kmem_cache *s = get_slab(size, gfpflags);
 
-	if (!s)
-		return ZERO_SIZE_PTR;
+	if (ZERO_OR_NULL_PTR(s))
+		return s;
 
 	return slab_alloc(s, gfpflags, -1, caller);
 }
@@ -2717,8 +2720,8 @@ void *__kmalloc_node_track_caller(size_t
 {
 	struct kmem_cache *s = get_slab(size, gfpflags);
 
-	if (!s)
-		return ZERO_SIZE_PTR;
+	if (ZERO_OR_NULL_PTR(s))
+		return s;
 
 	return slab_alloc(s, gfpflags, node, caller);
 }

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
