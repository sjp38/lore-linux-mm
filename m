Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9B4446B01F7
	for <linux-mm@kvack.org>; Fri, 14 May 2010 14:43:09 -0400 (EDT)
Message-Id: <20100514183944.425832866@quilx.com>
References: <20100514183908.118952419@quilx.com>
Date: Fri, 14 May 2010 13:39:12 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [RFC SLEB 04/10] SLUB: discard_slab_unlock
Content-Disposition: inline; filename=slub_discard_unlock
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The sequence of unlocking a slab and freeing it occurs multiple times.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 mm/slub.c |   16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-04-28 10:33:30.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-04-28 10:35:49.000000000 -0500
@@ -1268,6 +1268,13 @@ static __always_inline int slab_trylock(
 	return rc;
 }
 
+static void discard_slab_unlock(struct kmem_cache *s,
+	struct page *page)
+{
+	slab_unlock(page);
+	discard_slab(s, page);
+}
+
 /*
  * Management of partially allocated slabs
  */
@@ -1441,9 +1448,8 @@ static void unfreeze_slab(struct kmem_ca
 			add_partial(n, page, 1);
 			slab_unlock(page);
 		} else {
-			slab_unlock(page);
 			stat(s, FREE_SLAB);
-			discard_slab(s, page);
+			discard_slab_unlock(s, page);
 		}
 	}
 }
@@ -1826,9 +1832,8 @@ slab_empty:
 		remove_partial(s, page);
 		stat(s, FREE_REMOVE_PARTIAL);
 	}
-	slab_unlock(page);
 	stat(s, FREE_SLAB);
-	discard_slab(s, page);
+	discard_slab_unlock(s, page);
 	return;
 
 debug:
@@ -2905,8 +2910,7 @@ int kmem_cache_shrink(struct kmem_cache 
 				 */
 				list_del(&page->lru);
 				n->nr_partial--;
-				slab_unlock(page);
-				discard_slab(s, page);
+				discard_slab_unlock(s, page);
 			} else {
 				list_move(&page->lru,
 				slabs_by_inuse + page->inuse);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
