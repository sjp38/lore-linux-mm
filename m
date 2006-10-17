Date: Mon, 16 Oct 2006 17:43:54 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: No GFP_DMA check in the slab if no CONFIG_ZONE_DMA is set
Message-ID: <Pine.LNX.4.64.0610161739560.10676@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The GFP_DMA check in the slab is not necessary if there is no ZONE_DMA available.

The SCSI layer still sets GFP_DMA just in case which may cause the
BUG_ON to fire although there cannot be a an issue since systems with 
CONFIG_ZONE_DMA off have no DMA restrictions.

This bug was triggered by Paul Jackson on an SGI Altix system. Altix never 
had any memory below 4G (meaning of ZONE_DMA on ia64) and the driver has
been working for ages.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.19-rc1-mm1/mm/slab.c
===================================================================
--- linux-2.6.19-rc1-mm1.orig/mm/slab.c	2006-10-16 03:42:42.000000000 -0500
+++ linux-2.6.19-rc1-mm1/mm/slab.c	2006-10-16 18:47:43.900899030 -0500
@@ -2624,10 +2624,12 @@ static void cache_init_objs(struct kmem_
 
 static void kmem_flagcheck(struct kmem_cache *cachep, gfp_t flags)
 {
+#ifdef CONFIG_ZONE_DMA
 	if (flags & SLAB_DMA)
 		BUG_ON(!(cachep->gfpflags & GFP_DMA));
 	else
 		BUG_ON(cachep->gfpflags & GFP_DMA);
+#endif
 }
 
 static void *slab_get_obj(struct kmem_cache *cachep, struct slab *slabp,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
