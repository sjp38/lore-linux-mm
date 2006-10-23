Date: Mon, 23 Oct 2006 16:06:48 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Reduce CONFIG_ZONE_DMA ifdefs
In-Reply-To: <20061017170236.35dce526.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0610231603260.960@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0610171123160.14002@schroedinger.engr.sgi.com>
 <20061017170236.35dce526.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

V1->V2 use CONFIG_ZONE_DMA_FLAG that was defined in mm/Kconfig.

Reduce #ifdef CONFIG_ZONE_DMA

This reduces the #ifdefs in the slab allocator by adding a new
CONFIG_ZONE_DMA_FLAG in mm/Kconfig. The definitions for the
page allocator are already minimal and orthogonal to
CONFIG_ZONE_DMA32 and CONFIG_HIGHMEM.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.19-rc2-mm2/mm/slab.c
===================================================================
--- linux-2.6.19-rc2-mm2.orig/mm/slab.c	2006-10-23 17:13:10.372360786 -0500
+++ linux-2.6.19-rc2-mm2/mm/slab.c	2006-10-23 17:28:49.336065747 -0500
@@ -1458,14 +1458,14 @@ void __init kmem_cache_init(void)
 					ARCH_KMALLOC_FLAGS|SLAB_PANIC,
 					NULL, NULL);
 		}
-#ifdef CONFIG_ZONE_DMA
-		sizes->cs_dmacachep = kmem_cache_create(names->name_dma,
+		if (CONFIG_ZONE_DMA_FLAG)
+			sizes->cs_dmacachep = kmem_cache_create(
+					names->name_dma,
 					sizes->cs_size,
 					ARCH_KMALLOC_MINALIGN,
 					ARCH_KMALLOC_FLAGS|SLAB_CACHE_DMA|
 						SLAB_PANIC,
 					NULL, NULL);
-#endif
 		sizes++;
 		names++;
 	}
@@ -2297,10 +2297,8 @@ kmem_cache_create (const char *name, siz
 	cachep->slab_size = slab_size;
 	cachep->flags = flags;
 	cachep->gfpflags = 0;
-#ifdef CONFIG_ZONE_DMA
-	if (flags & SLAB_CACHE_DMA)
+	if (CONFIG_ZONE_DMA_FLAG && (flags & SLAB_CACHE_DMA))
 		cachep->gfpflags |= GFP_DMA;
-#endif
 	cachep->buffer_size = size;
 
 	if (flags & CFLGS_OFF_SLAB) {
@@ -2623,12 +2621,12 @@ static void cache_init_objs(struct kmem_
 
 static void kmem_flagcheck(struct kmem_cache *cachep, gfp_t flags)
 {
-#ifdef CONFIG_ZONE_DMA
-	if (flags & SLAB_DMA)
-		BUG_ON(!(cachep->gfpflags & GFP_DMA));
-	else
-		BUG_ON(cachep->gfpflags & GFP_DMA);
-#endif
+	if (CONFIG_ZONE_DMA_FLAG) {
+		if (flags & SLAB_DMA)
+			BUG_ON(!(cachep->gfpflags & GFP_DMA));
+		else
+			BUG_ON(cachep->gfpflags & GFP_DMA);
+	}
 }
 
 static void *slab_get_obj(struct kmem_cache *cachep, struct slab *slabp,
Index: linux-2.6.19-rc2-mm2/mm/Kconfig
===================================================================
--- linux-2.6.19-rc2-mm2.orig/mm/Kconfig	2006-10-23 17:13:10.382127229 -0500
+++ linux-2.6.19-rc2-mm2/mm/Kconfig	2006-10-23 17:52:25.537437185 -0500
@@ -242,3 +242,9 @@ config READAHEAD_SMOOTH_AGING
 		- have the danger of readahead thrashing(i.e. memory tight)
 
 	  This feature is only available on non-NUMA systems.
+
+config ZONE_DMA_FLAG
+	int
+	default "0" if !ZONE_DMA
+	default "1"
+

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
