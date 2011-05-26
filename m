Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 97C8C90010B
	for <linux-mm@kvack.org>; Thu, 26 May 2011 15:03:17 -0400 (EDT)
Message-Id: <20110526190315.017194963@linux.com>
Date: Thu, 26 May 2011 14:03:01 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slub p1 1/4] slub: Prepare inuse field in new_slab()
References: <20110526190300.120896512@linux.com>
Content-Disposition: inline; filename=new_slab
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org

inuse will always be set to page->objects. There is no point in
initializing the field to zero in new_slab() and then overwriting
the value in __slab_alloc().

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 mm/slub.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-05-24 09:41:15.454874919 -0500
+++ linux-2.6/mm/slub.c	2011-05-24 09:41:20.854874883 -0500
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
@@ -2564,7 +2563,7 @@ static void early_kmem_cache_node_alloc(
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
