Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 95D016B0254
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 15:08:53 -0400 (EDT)
Date: Tue, 15 Jun 2010 14:05:36 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: slub: discard_slab_unlock
Message-ID: <alpine.DEB.2.00.1006151405020.10865@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Subject: slub: discard_slab_unlock

The sequence of unlocking a slab and freeing occurs multiple times.
Put the common into a single function.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 mm/slub.c |   16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-06-01 08:58:50.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-06-01 08:58:54.000000000 -0500
@@ -1260,6 +1260,13 @@ static __always_inline int slab_trylock(
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
@@ -1437,9 +1444,8 @@ static void unfreeze_slab(struct kmem_ca
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
@@ -1822,9 +1828,8 @@ slab_empty:
 		remove_partial(s, page);
 		stat(s, FREE_REMOVE_PARTIAL);
 	}
-	slab_unlock(page);
 	stat(s, FREE_SLAB);
-	discard_slab(s, page);
+	discard_slab_unlock(s, page);
 	return;

 debug:
@@ -2893,8 +2898,7 @@ int kmem_cache_shrink(struct kmem_cache
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
