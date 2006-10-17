Date: Tue, 17 Oct 2006 11:25:07 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Reduce CONFIG_ZONE_DMA ifdefs
Message-ID: <Pine.LNX.4.64.0610171123160.14002@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Add a DMA_ZONE constant that can be used to avoid #ifdef DMAs. I hope this 
will make it acceptable to remove ZONE_DMA dependent code such as the 
bouncing logic and also allow us to deal with the GFP_DMA issues in the 
SCSI layer.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.19-rc1-mm1/include/linux/mmzone.h
===================================================================
--- linux-2.6.19-rc1-mm1.orig/include/linux/mmzone.h	2006-10-17 13:08:22.000000000 -0500
+++ linux-2.6.19-rc1-mm1/include/linux/mmzone.h	2006-10-17 13:08:51.018160800 -0500
@@ -149,6 +149,12 @@ enum zone_type {
  * match the requested limits. See gfp_zone() in include/linux/gfp.h
  */
 
+#ifdef CONFIG_ZONE_DMA
+#define DMA_ZONE 1
+#else
+#define DMA_ZONE 0
+#endif
+
 /*
  * Count the active zones.  Note that the use of defined(X) outside
  * #if and family is not necessarily defined so ensure we cannot use
Index: linux-2.6.19-rc1-mm1/mm/slab.c
===================================================================
--- linux-2.6.19-rc1-mm1.orig/mm/slab.c	2006-10-17 13:03:49.472950935 -0500
+++ linux-2.6.19-rc1-mm1/mm/slab.c	2006-10-17 13:08:08.215683664 -0500
@@ -1458,14 +1458,14 @@ void __init kmem_cache_init(void)
 					ARCH_KMALLOC_FLAGS|SLAB_PANIC,
 					NULL, NULL);
 		}
-#ifdef CONFIG_ZONE_DMA
-		sizes->cs_dmacachep = kmem_cache_create(names->name_dma,
+		if (DMA_ZONE)
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
@@ -2298,10 +2298,8 @@ kmem_cache_create (const char *name, siz
 	cachep->slab_size = slab_size;
 	cachep->flags = flags;
 	cachep->gfpflags = 0;
-#ifdef CONFIG_ZONE_DMA
-	if (flags & SLAB_CACHE_DMA)
+	if (DMA_ZONE && (flags & SLAB_CACHE_DMA))
 		cachep->gfpflags |= GFP_DMA;
-#endif
 	cachep->buffer_size = size;
 
 	if (flags & CFLGS_OFF_SLAB) {
@@ -2624,12 +2622,12 @@ static void cache_init_objs(struct kmem_
 
 static void kmem_flagcheck(struct kmem_cache *cachep, gfp_t flags)
 {
-#ifdef CONFIG_ZONE_DMA
-	if (flags & SLAB_DMA)
-		BUG_ON(!(cachep->gfpflags & GFP_DMA));
-	else
-		BUG_ON(cachep->gfpflags & GFP_DMA);
-#endif
+	if (DMA_ZONE) {
+		if (flags & SLAB_DMA)
+			BUG_ON(!(cachep->gfpflags & GFP_DMA));
+		else
+			BUG_ON(cachep->gfpflags & GFP_DMA);
+	}
 }
 
 static void *slab_get_obj(struct kmem_cache *cachep, struct slab *slabp,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
