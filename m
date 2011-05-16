Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C1072900115
	for <linux-mm@kvack.org>; Mon, 16 May 2011 16:26:35 -0400 (EDT)
Message-Id: <20110516202633.437021548@linux.com>
Date: Mon, 16 May 2011 15:26:26 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slubllv5 21/25] slub: Prepare inuse field in new_slab()
References: <20110516202605.274023469@linux.com>
Content-Disposition: inline; filename=new_slab
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

inuse will always be set to page->objects. There is no point in
initializing the field to zero in new_slab() and then overwriting
the value in __slab_alloc().

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 mm/slub.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-05-16 12:52:00.000000000 -0500
+++ linux-2.6/mm/slub.c	2011-05-16 12:52:41.421458455 -0500
@@ -1332,7 +1332,7 @@ static struct page *new_slab(struct kmem
 	set_freepointer(s, last, NULL);
 
 	page->freelist = start;
-	page->inuse = 0;
+	page->inuse = page->objects;
 	page->frozen = 1;
 out:
 	return page;
@@ -2022,7 +2022,6 @@ new_slab:
 		 */
 		object = page->freelist;
 		page->freelist = NULL;
-		page->inuse = page->objects;
 
 		stat(s, ALLOC_SLAB);
 		c->node = page_to_nid(page);
@@ -2563,7 +2562,7 @@ static void early_kmem_cache_node_alloc(
 	n = page->freelist;
 	BUG_ON(!n);
 	page->freelist = get_freepointer(kmem_cache_node, n);
-	page->inuse++;
+	page->inuse = 1;
 	page->frozen = 0;
 	kmem_cache_node->node[node] = n;
 #ifdef CONFIG_SLUB_DEBUG

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
