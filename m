Message-Id: <20070618095915.359753174@sgi.com>
References: <20070618095838.238615343@sgi.com>
Date: Mon, 18 Jun 2007 02:58:46 -0700
From: clameter@sgi.com
Subject: [patch 08/26] SLUB: Extract dma_kmalloc_cache from get_cache.
Content-Disposition: inline; filename=slub_extract_dma_cache
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

The rarely used dma functionality in get_slab() makes the function too
complex. The compiler begins to spill variables from the working set onto
the stack. The created function is only used in extremely rare cases so make
sure that the compiler does not decide on its own to merge it back into
get_slab().

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   66 +++++++++++++++++++++++++++++++++-----------------------------
 1 file changed, 36 insertions(+), 30 deletions(-)

Index: linux-2.6.22-rc4-mm2/mm/slub.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/slub.c	2007-06-17 18:12:04.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/slub.c	2007-06-17 18:12:10.000000000 -0700
@@ -2281,6 +2281,40 @@ panic:
 	panic("Creation of kmalloc slab %s size=%d failed.\n", name, size);
 }
 
+#ifdef CONFIG_ZONE_DMA
+static noinline struct kmem_cache *dma_kmalloc_cache(int index, gfp_t flags)
+{
+	struct kmem_cache *s;
+	struct kmem_cache *x;
+	char *text;
+	size_t realsize;
+
+	s = kmalloc_caches_dma[index];
+	if (s)
+		return s;
+
+	/* Dynamically create dma cache */
+	x = kmalloc(kmem_size, flags & ~SLUB_DMA);
+	if (!x)
+		panic("Unable to allocate memory for dma cache\n");
+
+	if (index <= KMALLOC_SHIFT_HIGH)
+		realsize = 1 << index;
+	else {
+		if (index == 1)
+			realsize = 96;
+		else
+			realsize = 192;
+	}
+
+	text = kasprintf(flags & ~SLUB_DMA, "kmalloc_dma-%d",
+			(unsigned int)realsize);
+	s = create_kmalloc_cache(x, text, realsize, flags);
+	kmalloc_caches_dma[index] = s;
+	return s;
+}
+#endif
+
 static struct kmem_cache *get_slab(size_t size, gfp_t flags)
 {
 	int index = kmalloc_index(size);
@@ -2293,36 +2327,8 @@ static struct kmem_cache *get_slab(size_
 		return NULL;
 
 #ifdef CONFIG_ZONE_DMA
-	if ((flags & SLUB_DMA)) {
-		struct kmem_cache *s;
-		struct kmem_cache *x;
-		char *text;
-		size_t realsize;
-
-		s = kmalloc_caches_dma[index];
-		if (s)
-			return s;
-
-		/* Dynamically create dma cache */
-		x = kmalloc(kmem_size, flags & ~SLUB_DMA);
-		if (!x)
-			panic("Unable to allocate memory for dma cache\n");
-
-		if (index <= KMALLOC_SHIFT_HIGH)
-			realsize = 1 << index;
-		else {
-			if (index == 1)
-				realsize = 96;
-			else
-				realsize = 192;
-		}
-
-		text = kasprintf(flags & ~SLUB_DMA, "kmalloc_dma-%d",
-				(unsigned int)realsize);
-		s = create_kmalloc_cache(x, text, realsize, flags);
-		kmalloc_caches_dma[index] = s;
-		return s;
-	}
+	if ((flags & SLUB_DMA))
+		return dma_kmalloc_cache(index, flags);
 #endif
 	return &kmalloc_caches[index];
 }

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
