Message-Id: <20070618095915.600066736@sgi.com>
References: <20070618095838.238615343@sgi.com>
Date: Mon, 18 Jun 2007 02:58:47 -0700
From: clameter@sgi.com
Subject: [patch 09/26] SLUB: Do proper locking during dma slab creation
Content-Disposition: inline; filename=slub_dma_create_lock
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

We modify the kmalloc_cache_dma[] array without proper locking.
Do the proper locking and undo the dma cache creation if another processor
has already created it.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

Index: linux-2.6.22-rc4-mm2/mm/slub.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/slub.c	2007-06-17 18:12:10.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/slub.c	2007-06-17 18:12:13.000000000 -0700
@@ -2310,8 +2310,15 @@ static struct kmem_cache *dma_kmalloc_ca
 	text = kasprintf(flags & ~SLUB_DMA, "kmalloc_dma-%d",
 			(unsigned int)realsize);
 	s = create_kmalloc_cache(x, text, realsize, flags);
-	kmalloc_caches_dma[index] = s;
-	return s;
+	down_write(&slub_lock);
+	if (!kmalloc_caches_dma[index]) {
+		kmalloc_caches_dma[index] = s;
+		up_write(&slub_lock);
+		return s;
+	}
+	up_write(&slub_lock);
+	kmem_cache_destroy(s);
+	return kmalloc_caches_dma[index];
 }
 #endif
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
