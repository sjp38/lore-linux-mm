Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2DC868D004B
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 16:24:20 -0400 (EDT)
Message-Id: <20110330202417.488647335@linux.com>
Date: Wed, 30 Mar 2011 15:23:46 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slubll1 04/19] slub: Move node determination out of hotpath
References: <20110330202342.669400887@linux.com>
Content-Disposition: inline; filename=move_slab_node
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>

If the node does not change then there is no need to recalculate
the node from the page struct. So move the node determination
into the places where we acquire a new slab page.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-03-25 15:12:43.000000000 -0500
+++ linux-2.6/mm/slub.c	2011-03-28 08:50:41.000000000 -0500
@@ -1822,7 +1822,6 @@ load_freelist:
 	c->freelist = get_freepointer(s, object);
 	page->inuse = page->objects;
 	page->freelist = NULL;
-	c->node = page_to_nid(page);
 
 unlock_out:
 	slab_unlock(page);
@@ -1839,8 +1838,10 @@ another_slab:
 new_slab:
 	page = get_partial(s, gfpflags, node);
 	if (page) {
-		c->page = page;
 		stat(s, ALLOC_FROM_PARTIAL);
+load_from_page:
+		c->node = page_to_nid(page);
+		c->page = page;
 		goto load_freelist;
 	}
 
@@ -1861,8 +1862,8 @@ new_slab:
 
 		slab_lock(page);
 		__SetPageSlubFrozen(page);
-		c->page = page;
-		goto load_freelist;
+
+		goto load_from_page;
 	}
 	if (!(gfpflags & __GFP_NOWARN) && printk_ratelimit())
 		slab_out_of_memory(s, gfpflags, node);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
