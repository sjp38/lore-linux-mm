Message-Id: <20070618095915.826976488@sgi.com>
References: <20070618095838.238615343@sgi.com>
Date: Mon, 18 Jun 2007 02:58:48 -0700
From: clameter@sgi.com
Subject: [patch 10/26] SLUB: Faster more efficient slab determination for __kmalloc.
Content-Disposition: inline; filename=slub_faster_kmalloc_slab
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

kmalloc_index is a long series of comparisons. The attempt to replace
kmalloc_index with something more efficient like ilog2 failed due to
compiler issues with constant folding on gcc 3.3 / powerpc.

kmalloc_index()'es long list of comparisons works fine for constant folding
since all the comparisons are optimized away. However, SLUB also uses
kmalloc_index to determine the slab to use for the __kmalloc_xxx functions.
This leads to a large set of comparisons in get_slab().

The patch here allows to get rid of that list of comparisons in get_slab():

1. If the requested size is larger than 192 then we can simply use
   fls to determine the slab index since all larger slabs are
   of the power of two type.

2. If the requested size is smaller then we cannot use fls since there
   are non power of two caches to be considered. However, the sizes are
   in a managable range. So we divide the size by 8. Then we have only
   24 possibilities left and then we simply look up the kmalloc index
   in a table.

Code size of slub.o decreases by more than 200 bytes through this patch.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   73 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 65 insertions(+), 8 deletions(-)

Index: linux-2.6.22-rc4-mm2/mm/slub.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/slub.c	2007-06-17 18:12:13.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/slub.c	2007-06-17 18:12:16.000000000 -0700
@@ -2322,20 +2322,59 @@ static struct kmem_cache *dma_kmalloc_ca
 }
 #endif
 
+/*
+ * Conversion table for small slabs sizes / 8 to the index in the
+ * kmalloc array. This is necessary for slabs < 192 since we have non power
+ * of two cache sizes there. The size of larger slabs can be determined using
+ * fls.
+ */
+static s8 size_index[24] = {
+	3,	/* 8 */
+	4,	/* 16 */
+	5,	/* 24 */
+	5,	/* 32 */
+	6,	/* 40 */
+	6,	/* 48 */
+	6,	/* 56 */
+	6,	/* 64 */
+	1,	/* 72 */
+	1,	/* 80 */
+	1,	/* 88 */
+	1,	/* 96 */
+	7,	/* 104 */
+	7,	/* 112 */
+	7,	/* 120 */
+	7,	/* 128 */
+	2,	/* 136 */
+	2,	/* 144 */
+	2,	/* 152 */
+	2,	/* 160 */
+	2,	/* 168 */
+	2,	/* 176 */
+	2,	/* 184 */
+	2	/* 192 */
+};
+
 static struct kmem_cache *get_slab(size_t size, gfp_t flags)
 {
-	int index = kmalloc_index(size);
+	int index;
 
-	if (!index)
-		return ZERO_SIZE_PTR;
+	if (size <= 192) {
+		if (!size)
+			return ZERO_SIZE_PTR;
 
-	/* Allocation too large? */
-	if (index < 0)
-		return NULL;
+		index = size_index[(size - 1) / 8];
+	} else {
+		if (size > KMALLOC_MAX_SIZE)
+			return NULL;
+
+		index = fls(size - 1) + 1;
+	}
 
 #ifdef CONFIG_ZONE_DMA
-	if ((flags & SLUB_DMA))
+	if (unlikely((flags & SLUB_DMA)))
 		return dma_kmalloc_cache(index, flags);
+
 #endif
 	return &kmalloc_caches[index];
 }
@@ -2550,6 +2589,24 @@ void __init kmem_cache_init(void)
 		caches++;
 	}
 
+
+	/*
+	 * Patch up the size_index table if we have strange large alignment
+	 * requirements for the kmalloc array. This is only the case for
+	 * mips it seems. The standard arches will not generate any code here.
+	 *
+	 * Largest permitted alignment is 256 bytes due to the way we
+	 * handle the index determination for the smaller caches.
+	 *
+	 * Make sure that nothing crazy happens if someone starts tinkering
+	 * around with ARCH_KMALLOC_MINALIGN
+	 */
+	BUG_ON(KMALLOC_MIN_SIZE > 256 ||
+		(KMALLOC_MIN_SIZE & (KMALLOC_MIN_SIZE - 1)));
+
+	for (i = 8; i < KMALLOC_MIN_SIZE;i++)
+		size_index[(i - 1) / 8] = KMALLOC_SHIFT_LOW;
+
 	slab_state = UP;
 
 	/* Provide the correct kmalloc names now that the caches are up */

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
