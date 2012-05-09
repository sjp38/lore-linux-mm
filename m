Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id E21126B0122
	for <linux-mm@kvack.org>; Wed,  9 May 2012 11:10:12 -0400 (EDT)
Message-Id: <20120509151011.276276132@linux.com>
Date: Wed, 09 May 2012 10:09:58 -0500
From: cl@linux.com
From: Christoph Lameter <cl@linux.com>
Subject: [Slub cleanup 8/9] slub: Use page variable instead of c->page.
References: <20120509150950.243797150@linux.com>
Content-Disposition: inline; filename=use_page_var
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Store the value of c->page to avoid additional fetches
from per cpu data.

Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: Christoph Lameter <cl@linux.com>


---
 mm/slub.c |   17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-04-10 10:33:17.798750578 -0500
+++ linux-2.6/mm/slub.c	2012-04-10 10:33:26.850750391 -0500
@@ -2208,6 +2208,7 @@ static void *__slab_alloc(struct kmem_ca
 			  unsigned long addr, struct kmem_cache_cpu *c)
 {
 	void *freelist;
+	struct page *page;
 	unsigned long flags;
 
 	local_irq_save(flags);
@@ -2220,13 +2221,14 @@ static void *__slab_alloc(struct kmem_ca
 	c = this_cpu_ptr(s->cpu_slab);
 #endif
 
-	if (!c->page)
+	page = c->page;
+	if (!page)
 		goto new_slab;
 redo:
 
 	if (unlikely(!node_match(c, node))) {
 		stat(s, ALLOC_NODE_MISMATCH);
-		deactivate_slab(s, c->page, c->freelist);
+		deactivate_slab(s, page, c->freelist);
 		c->page = NULL;
 		c->freelist = NULL;
 		goto new_slab;
@@ -2239,7 +2241,7 @@ redo:
 
 	stat(s, ALLOC_SLOWPATH);
 
-	freelist = get_freelist(s, c->page);
+	freelist = get_freelist(s, page);
 
 	if (!freelist) {
 		c->page = NULL;
@@ -2264,8 +2266,8 @@ load_freelist:
 new_slab:
 
 	if (c->partial) {
-		c->page = c->partial;
-		c->partial = c->page->next;
+		page = c->page = c->partial;
+		c->partial = page->next;
 		stat(s, CPU_PARTIAL_ALLOC);
 		c->freelist = NULL;
 		goto redo;
@@ -2281,14 +2283,15 @@ new_slab:
 		return NULL;
 	}
 
+	page = c->page;
 	if (likely(!kmem_cache_debug(s)))
 		goto load_freelist;
 
 	/* Only entered in the debug case */
-	if (!alloc_debug_processing(s, c->page, freelist, addr))
+	if (!alloc_debug_processing(s, page, freelist, addr))
 		goto new_slab;	/* Slab failed checks. Next slab needed */
 
-	deactivate_slab(s, c->page, get_freepointer(s, freelist));
+	deactivate_slab(s, page, get_freepointer(s, freelist));
 	c->page = NULL;
 	c->freelist = NULL;
 	local_irq_restore(flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
