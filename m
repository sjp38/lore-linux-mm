Date: Tue, 10 Jun 2008 10:06:20 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Collision of SLUB unique ID
In-Reply-To: <200806100244.m5A2iZbV021848@po-mbox301.hop.2iij.net>
Message-ID: <Pine.LNX.4.64.0806101005140.16992@schroedinger.engr.sgi.com>
References: <20080604234622.4b73289c.yoichi_yuasa@tripeaks.co.jp>
 <Pine.LNX.4.64.0806090706230.29723@schroedinger.engr.sgi.com>
 <200806100106.m5A16iKl025150@po-mbox304.hop.2iij.net>
 <Pine.LNX.4.64.0806091821080.12465@schroedinger.engr.sgi.com>
 <200806100244.m5A2iZbV021848@po-mbox301.hop.2iij.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Tue, 10 Jun 2008, Yoichi Yuasa wrote:

> No, the kernel that applies it cannot boot. 

Hmmm... Ok here is an experimental patch that just disables merging for 
192 (in general a bad idea). If this works then we know at least where
to look for the solution.

---
 mm/slub.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2008-06-10 10:02:03.000000000 -0700
+++ linux-2.6/mm/slub.c	2008-06-10 10:04:04.000000000 -0700
@@ -171,7 +171,7 @@ static inline void ClearSlabDebug(struct
  * Set of flags that will prevent slab merging
  */
 #define SLUB_NEVER_MERGE (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER | \
-		SLAB_TRACE | SLAB_DESTROY_BY_RCU)
+		SLAB_TRACE | SLAB_DESTROY_BY_RCU | __SLAB_NOMERGE)
 
 #define SLUB_MERGE_SAME (SLAB_DEBUG_FREE | SLAB_RECLAIM_ACCOUNT | \
 		SLAB_CACHE_DMA)
@@ -187,6 +187,7 @@ static inline void ClearSlabDebug(struct
 /* Internal SLUB flags */
 #define __OBJECT_POISON		0x80000000 /* Poison object */
 #define __SYSFS_ADD_DEFERRED	0x40000000 /* Not yet visible via sysfs */
+#define __SLAB_NOMERGE		0x20000000 /* Never merge this slab */
 
 static int kmem_size = sizeof(struct kmem_cache);
 
@@ -2998,7 +2999,7 @@ void __init kmem_cache_init(void)
 	}
 	if (KMALLOC_MIN_SIZE <= 128) {
 		create_kmalloc_cache(&kmalloc_caches[2],
-				"kmalloc-192", 192, GFP_KERNEL);
+				"kmalloc-192", 192, GFP_KERNEL | __SLAB_NOMERGE);
 		caches++;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
