Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id DB0D960032A
	for <linux-mm@kvack.org>; Fri, 21 May 2010 17:18:57 -0400 (EDT)
Message-Id: <20100521211539.266599197@quilx.com>
Date: Fri, 21 May 2010 16:14:56 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [RFC V2 SLEB 04/14] SLUB: discard_slab_unlock
References: <20100521211452.659982351@quilx.com>
Content-Disposition: inline; filename=slub_discard_unlock
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The sequence of unlocking a slab and freeing occurs multiple times.
Put the common into a single function.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 mm/slub.c |   16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-05-20 17:16:27.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-05-20 17:16:29.000000000 -0500
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
