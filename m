Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 276176B0074
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 15:07:33 -0500 (EST)
Message-Id: <20111111200729.024403984@linux.com>
Date: Fri, 11 Nov 2011 14:07:17 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [rfc 06/18] slub: Use page variable instead of c->page.
References: <20111111200711.156817886@linux.com>
Content-Disposition: inline; filename=use_paget
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, Shaohua Li <shaohua.li@intel.com>, Alex Shi <alex.shi@intel.com>, linux-mm@kvack.org

The kmem_cache_cpu object pointed to by c will become
volatile with the lockless patches later so extract
the c->page pointer at certain times.

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 mm/slub.c |   17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-11-09 11:11:25.881561697 -0600
+++ linux-2.6/mm/slub.c	2011-11-09 11:11:32.231598204 -0600
@@ -2160,6 +2160,7 @@ static void *__slab_alloc(struct kmem_ca
 			  unsigned long addr, struct kmem_cache_cpu *c)
 {
 	void *freelist;
+	struct page *page;
 	unsigned long flags;
 
 	local_irq_save(flags);
@@ -2172,13 +2173,14 @@ static void *__slab_alloc(struct kmem_ca
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
@@ -2186,7 +2188,7 @@ redo:
 
 	stat(s, ALLOC_SLOWPATH);
 
-	freelist = get_freelist(s, c->page);
+	freelist = get_freelist(s, page);
 
 	if (unlikely(!freelist)) {
 		c->page = NULL;
@@ -2210,8 +2212,8 @@ load_freelist:
 new_slab:
 
 	if (c->partial) {
-		c->page = c->partial;
-		c->partial = c->page->next;
+		page = c->page = c->partial;
+		c->partial = page->next;
 		stat(s, CPU_PARTIAL_ALLOC);
 		c->freelist = NULL;
 		goto redo;
@@ -2231,13 +2233,14 @@ new_slab:
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
