Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BBADE6B02A3
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 15:12:16 -0400 (EDT)
Message-Id: <20100709190854.930694716@quilx.com>
Date: Fri, 09 Jul 2010 14:07:15 -0500
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [S+Q2 09/19] slub: discard_slab_unlock
References: <20100709190706.938177313@quilx.com>
Content-Disposition: inline; filename=slub_discard_unlock
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

The sequence of unlocking a slab and freeing occurs multiple times.
Put the common into a single function. There is no intend here
to use this to enforce a sequencing of events leading up
to the discarding of a slab page.

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
