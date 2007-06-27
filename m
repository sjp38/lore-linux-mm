Date: Wed, 27 Jun 2007 05:51:51 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: SLUB: Simplify dma index -> size calculation
Message-ID: <Pine.LNX.4.64.0706270549190.26887@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

There is no need to caculate the dma slab size ourselves. We can simply 
lookup the size of the corresponding non dma slab.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

Index: linux-2.6.22-rc4-mm2/mm/slub.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/slub.c	2007-06-23 12:05:36.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/slub.c	2007-06-23 12:05:46.000000000 -0700
@@ -2481,15 +2481,7 @@ static noinline struct kmem_cache *dma_k
 	if (!x)
 		panic("Unable to allocate memory for dma cache\n");
 
-	if (index <= KMALLOC_SHIFT_HIGH)
-		realsize = 1 << index;
-	else {
-		if (index == 1)
-			realsize = 96;
-		else
-			realsize = 192;
-	}
-
+	realsize = kmalloc_caches[index].objsize;
 	text = kasprintf(flags & ~SLUB_DMA, "kmalloc_dma-%d",
 			(unsigned int)realsize);
 	s = create_kmalloc_cache(x, text, realsize, flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
