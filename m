Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id EB3136B005A
	for <linux-mm@kvack.org>; Sat, 13 Oct 2012 12:34:41 -0400 (EDT)
From: Richard Kennedy <richard@rsk.demon.co.uk>
Subject: [PATCH 2/2] SLUB: increase the range of slab sizes available to kmalloc, allowing a somewhat more effient use of memory.
Date: Sat, 13 Oct 2012 17:31:25 +0100
Message-Id: <1350145885-6099-3-git-send-email-richard@rsk.demon.co.uk>
In-Reply-To: <1350145885-6099-2-git-send-email-richard@rsk.demon.co.uk>
References: <1350145885-6099-1-git-send-email-richard@rsk.demon.co.uk>
 <1350145885-6099-2-git-send-email-richard@rsk.demon.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Richard Kennedy <richard@rsk.demon.co.uk>

This patch add new slabs sized at 1.5 * 2^n.
i.e - 24,48,96,192,384,768,1.5k,3k,6k
Most of which already exist as kmem_cache slabs, except for 1.5k, 3k & 6k.

There is no extra overhead for statically sized kmalloc, and only a small change for dynamically sized ones.

Minimal code changes:
	new list of slab sizes
	new kmalloc functions
	re-factored slub initialisation

other than that the core slub code remains unchanged.

No measurable significant performance difference, nothing above the noise anyway.

Only tested on x86_64, so may not work on other architectures.
The code should support the use of KMALLOC_MIN_SIZE, but I have no hardware to test this on.

compiled with gcc 4.7.2
patch against 3.6

Signed-off-by: Richard Kennedy <richard@rsk.demon.co.uk>
---
 include/linux/slub_def.h |  95 +++++++++++++--------------
 mm/slub.c                | 162 ++++++++++++++++++-----------------------------
 2 files changed, 108 insertions(+), 149 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index df448ad..3c36009 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -143,62 +143,63 @@ struct kmem_cache {
 #endif
 
 /*
- * We keep the general caches in an array of slab caches that are used for
- * 2^x bytes of allocations.
+ * the table of slab sizes, should handle all of the arch cases
+ * -- but only tested on x86_64 -- caveat emptor
  */
-extern struct kmem_cache *kmalloc_caches[SLUB_PAGE_SHIFT];
 
-/*
- * Sorry that the following has to be that ugly but some versions of GCC
- * have trouble with constant propagation and loops.
+static const short __slab_sizes[] = {0, 8, 12, 16, 24, 32, 48, 64, 96,
+				     128, 192, 256, 384, 512, 768, 1024,
+				     1536, 2048, 3072, 4096, 6144, 8192};
+
+/* very ugly, but gcc will optimize these away.
+ * the comment on the original finction says :-
+ * >  Sorry that the following has to be that ugly but some versions of GCC
+ * >  have trouble with constant propagation and loops.
+ * so a simple loop just won't work.
+ *
+ * Don't allow anything smaller than, or not aligned to KMALLOC_MIN_SIZE
  */
-static __always_inline int kmalloc_index(size_t size)
+static __always_inline short __test_slab_size(size_t size, short index)
 {
-	if (!size)
+	if (__slab_sizes[index] % KMALLOC_MIN_SIZE ||
+	     __slab_sizes[index] < size)
 		return 0;
+	return 1;
+}
+
+static __always_inline short kmalloc_index(size_t size)
+{
+	if (!size) return 0;
+	if (__test_slab_size(size, 1)) return 1;
+	if (__test_slab_size(size, 2)) return 2;
+	if (__test_slab_size(size, 3)) return 3;
+	if (__test_slab_size(size, 4)) return 4;
+	if (__test_slab_size(size, 5)) return 5;
+	if (__test_slab_size(size, 6)) return 6;
+	if (__test_slab_size(size, 7)) return 7;
+	if (__test_slab_size(size, 8)) return 8;
+	if (__test_slab_size(size, 9)) return 9;
+	if (__test_slab_size(size, 10)) return 10;
+	if (__test_slab_size(size, 11)) return 11;
+	if (__test_slab_size(size, 12)) return 12;
+	if (__test_slab_size(size, 13)) return 13;
+	if (__test_slab_size(size, 14)) return 14;
+	if (__test_slab_size(size, 15)) return 15;
+	if (__test_slab_size(size, 16)) return 16;
+	if (__test_slab_size(size, 17)) return 17;
+	if (__test_slab_size(size, 18)) return 18;
+	if (__test_slab_size(size, 19)) return 19;
+	if (__test_slab_size(size, 20)) return 20;
+	if (__test_slab_size(size, 21)) return 21;
 
-	if (size <= KMALLOC_MIN_SIZE)
-		return KMALLOC_SHIFT_LOW;
-
-	if (KMALLOC_MIN_SIZE <= 32 && size > 64 && size <= 96)
-		return 1;
-	if (KMALLOC_MIN_SIZE <= 64 && size > 128 && size <= 192)
-		return 2;
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
-/*
- * The following is only needed to support architectures with a larger page
- * size than 4k. We need to support 2 * PAGE_SIZE here. So for a 64k page
- * size we would have to go up to 128k.
- */
-	if (size <=   8 * 1024) return 13;
-	if (size <=  16 * 1024) return 14;
-	if (size <=  32 * 1024) return 15;
-	if (size <=  64 * 1024) return 16;
-	if (size <= 128 * 1024) return 17;
-	if (size <= 256 * 1024) return 18;
-	if (size <= 512 * 1024) return 19;
-	if (size <= 1024 * 1024) return 20;
-	if (size <=  2 * 1024 * 1024) return 21;
 	BUG();
-	return -1; /* Will never be reached */
+	return -1;
+}
 
 /*
- * What we really wanted to do and cannot do because of compiler issues is:
- *	int i;
- *	for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_HIGH; i++)
- *		if (size <= (1 << i))
- *			return i;
+ * We keep the general caches in an array of slab caches
  */
-}
+extern struct kmem_cache *kmalloc_caches[ARRAY_SIZE(__slab_sizes)];
 
 /*
  * Find the slab cache for a given combination of allocation flags and size.
@@ -208,7 +209,7 @@ static __always_inline int kmalloc_index(size_t size)
  */
 static __always_inline struct kmem_cache *kmalloc_slab(size_t size)
 {
-	int index = kmalloc_index(size);
+	short index = kmalloc_index(size);
 
 	if (index == 0)
 		return NULL;
diff --git a/mm/slub.c b/mm/slub.c
index 804ac42..5949f78 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3223,13 +3223,13 @@ EXPORT_SYMBOL(kmem_cache_destroy);
  *		Kmalloc subsystem
  *******************************************************************/
 
-struct kmem_cache *kmalloc_caches[SLUB_PAGE_SHIFT];
+struct kmem_cache *kmalloc_caches[ARRAY_SIZE(__slab_sizes)];
 EXPORT_SYMBOL(kmalloc_caches);
 
 static struct kmem_cache *kmem_cache;
 
 #ifdef CONFIG_ZONE_DMA
-static struct kmem_cache *kmalloc_dma_caches[SLUB_PAGE_SHIFT];
+static struct kmem_cache *kmalloc_dma_caches[ARRAY_SIZE(__slab_sizes)];
 #endif
 
 static int __init setup_slub_min_order(char *str)
@@ -3291,55 +3291,36 @@ panic:
 	return NULL;
 }
 
-/*
- * Conversion table for small slabs sizes / 8 to the index in the
- * kmalloc array. This is necessary for slabs < 192 since we have non power
- * of two cache sizes there. The size of larger slabs can be determined using
- * fls.
- */
-static s8 size_index[24] = {
-	3,	/* 8 */
-	4,	/* 16 */
-	5,	/* 24 */
-	5,	/* 32 */
-	6,	/* 40 */
-	6,	/* 48 */
-	6,	/* 56 */
-	6,	/* 64 */
-	1,	/* 72 */
-	1,	/* 80 */
-	1,	/* 88 */
-	1,	/* 96 */
-	7,	/* 104 */
-	7,	/* 112 */
-	7,	/* 120 */
-	7,	/* 128 */
-	2,	/* 136 */
-	2,	/* 144 */
-	2,	/* 152 */
-	2,	/* 160 */
-	2,	/* 168 */
-	2,	/* 176 */
-	2,	/* 184 */
-	2	/* 192 */
-};
-
-static inline int size_index_elem(size_t bytes)
+static __always_inline short get_slab_index(size_t size)
 {
-	return (bytes - 1) / 8;
+	short index;
+
+	/*
+	 * All slabs must be aligned to KMALLOC_MIN_SIZE
+	 * so disallow the half sized slab between MIN & 2*MIN
+	 */
+	if (size <= KMALLOC_MIN_SIZE * 2) {
+		if (size > KMALLOC_MIN_SIZE)
+			return kmalloc_index(KMALLOC_MIN_SIZE * 2);
+		return kmalloc_index(KMALLOC_MIN_SIZE);
+	}
+
+	size--;
+	index = fls(size);
+	if (test_bit(index - 2, &size))
+		return (index - 3) * 2 + 1;
+	return (index - 3) * 2;
 }
 
+
 static struct kmem_cache *get_slab(size_t size, gfp_t flags)
 {
-	int index;
+	short index;
 
-	if (size <= 192) {
-		if (!size)
-			return ZERO_SIZE_PTR;
+	if (!size)
+		return ZERO_SIZE_PTR;
 
-		index = size_index[size_index_elem(size)];
-	} else
-		index = fls(size - 1);
+	index = get_slab_index(size);
 
 #ifdef CONFIG_ZONE_DMA
 	if (unlikely((flags & SLUB_DMA)))
@@ -3715,6 +3696,20 @@ void __init kmem_cache_init(void)
 	struct kmem_cache *temp_kmem_cache_node;
 	unsigned long kmalloc_size;
 
+	/*
+	 * do a simple smoke test to verify that get_slab_index is ok
+	 * and matches __slab_sizes correctly.
+	 * note i == 0 is unused
+	 */
+	for (i = 1; i < ARRAY_SIZE(__slab_sizes); i++) {
+		short index;
+		if (__slab_sizes[i] % KMALLOC_MIN_SIZE)
+			continue;
+		index = get_slab_index(__slab_sizes[i]);
+		BUG_ON(index != i);
+	}
+
+
 	if (debug_guardpage_minorder())
 		slub_max_order = 0;
 
@@ -3782,64 +3777,29 @@ void __init kmem_cache_init(void)
 	BUILD_BUG_ON(KMALLOC_MIN_SIZE > 256 ||
 		(KMALLOC_MIN_SIZE & (KMALLOC_MIN_SIZE - 1)));
 
-	for (i = 8; i < KMALLOC_MIN_SIZE; i += 8) {
-		int elem = size_index_elem(i);
-		if (elem >= ARRAY_SIZE(size_index))
-			break;
-		size_index[elem] = KMALLOC_SHIFT_LOW;
-	}
 
-	if (KMALLOC_MIN_SIZE == 64) {
-		/*
-		 * The 96 byte size cache is not used if the alignment
-		 * is 64 byte.
-		 */
-		for (i = 64 + 8; i <= 96; i += 8)
-			size_index[size_index_elem(i)] = 7;
-	} else if (KMALLOC_MIN_SIZE == 128) {
-		/*
-		 * The 192 byte sized cache is not used if the alignment
-		 * is 128 byte. Redirect kmalloc to use the 256 byte cache
-		 * instead.
-		 */
-		for (i = 128 + 8; i <= 192; i += 8)
-			size_index[size_index_elem(i)] = 8;
-	}
-
-	/* Caches that are not of the two-to-the-power-of size */
-	if (KMALLOC_MIN_SIZE <= 32) {
-		kmalloc_caches[1] = create_kmalloc_cache("kmalloc-96", 96, 0);
-		caches++;
-	}
-
-	if (KMALLOC_MIN_SIZE <= 64) {
-		kmalloc_caches[2] = create_kmalloc_cache("kmalloc-192", 192, 0);
-		caches++;
-	}
-
-	for (i = KMALLOC_SHIFT_LOW; i < SLUB_PAGE_SHIFT; i++) {
-		kmalloc_caches[i] = create_kmalloc_cache("kmalloc", 1 << i, 0);
+	for (i = 1; i < ARRAY_SIZE(__slab_sizes); i++) {
+		if (__slab_sizes[i] % KMALLOC_MIN_SIZE) {
+			kmalloc_caches[i] = 0;
+			continue;
+		}
+		kmalloc_caches[i] = create_kmalloc_cache("kmalloc",
+							 __slab_sizes[i], 0);
 		caches++;
 	}
 
 	slab_state = UP;
 
 	/* Provide the correct kmalloc names now that the caches are up */
-	if (KMALLOC_MIN_SIZE <= 32) {
-		kmalloc_caches[1]->name = kstrdup(kmalloc_caches[1]->name, GFP_NOWAIT);
-		BUG_ON(!kmalloc_caches[1]->name);
-	}
-
-	if (KMALLOC_MIN_SIZE <= 64) {
-		kmalloc_caches[2]->name = kstrdup(kmalloc_caches[2]->name, GFP_NOWAIT);
-		BUG_ON(!kmalloc_caches[2]->name);
-	}
 
-	for (i = KMALLOC_SHIFT_LOW; i < SLUB_PAGE_SHIFT; i++) {
-		char *s = kasprintf(GFP_NOWAIT, "kmalloc-%d", 1 << i);
-
-		BUG_ON(!s);
-		kmalloc_caches[i]->name = s;
+	for (i = 1; i < ARRAY_SIZE(kmalloc_caches); i++) {
+		struct kmem_cache *slab = kmalloc_caches[i];
+		if (slab && slab->size) {
+			char *name = kasprintf(GFP_NOWAIT, "kmalloc-%d",
+						slab->object_size);
+			BUG_ON(!name);
+			slab->name = name;
+		}
 	}
 
 #ifdef CONFIG_SMP
@@ -3847,16 +3807,14 @@ void __init kmem_cache_init(void)
 #endif
 
 #ifdef CONFIG_ZONE_DMA
-	for (i = 0; i < SLUB_PAGE_SHIFT; i++) {
-		struct kmem_cache *s = kmalloc_caches[i];
-
-		if (s && s->size) {
-			char *name = kasprintf(GFP_NOWAIT,
-				 "dma-kmalloc-%d", s->object_size);
-
+	for (i = 1; i < ARRAY_SIZE(kmalloc_caches); i++) {
+		struct kmem_cache *slab = kmalloc_caches[i];
+		if (slab && slab->size) {
+			char *name = kasprintf(GFP_NOWAIT, "dma-kmalloc-%d",
+					       slab->object_size);
 			BUG_ON(!name);
 			kmalloc_dma_caches[i] = create_kmalloc_cache(name,
-				s->object_size, SLAB_CACHE_DMA);
+				slab->object_size, SLAB_CACHE_DMA);
 		}
 	}
 #endif
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
