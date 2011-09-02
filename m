Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3CF9B900146
	for <linux-mm@kvack.org>; Fri,  2 Sep 2011 16:47:44 -0400 (EDT)
Message-Id: <20110902204741.441221474@linux.com>
Date: Fri, 02 Sep 2011 15:47:01 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slub rfc1 04/12] slub: Separate out kmem_cache_cpu processing from deactivate_slab
References: <20110902204657.105194589@linux.com>
Content-Disposition: inline; filename=separate_deactivate_slab
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, linux-mm@kvack.org

Processing on fields of kmem_cache needs to be separate since we will be
handling that with cmpxchg_double later.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-09-02 08:20:19.021219504 -0500
+++ linux-2.6/mm/slub.c	2011-09-02 08:20:25.911219458 -0500
@@ -1771,14 +1771,12 @@ void init_kmem_cache_cpus(struct kmem_ca
 /*
  * Remove the cpu slab
  */
-static void deactivate_slab(struct kmem_cache *s, struct kmem_cache_cpu *c)
+static void deactivate_slab(struct kmem_cache *s, struct page *page, void *freelist)
 {
 	enum slab_modes { M_NONE, M_PARTIAL, M_FULL, M_FREE };
-	struct page *page = c->page;
 	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
 	int lock = 0;
 	enum slab_modes l = M_NONE, m = M_NONE;
-	void *freelist;
 	void *nextfree;
 	int tail = 0;
 	struct page new;
@@ -1789,11 +1787,6 @@ static void deactivate_slab(struct kmem_
 		tail = 1;
 	}
 
-	c->tid = next_tid(c->tid);
-	c->page = NULL;
-	freelist = c->freelist;
-	c->freelist = NULL;
-
 	/*
 	 * Stage one: Free all available per cpu objects back
 	 * to the page freelist while it is still frozen. Leave the
@@ -1922,7 +1915,11 @@ redo:
 static inline void flush_slab(struct kmem_cache *s, struct kmem_cache_cpu *c)
 {
 	stat(s, CPUSLAB_FLUSH);
-	deactivate_slab(s, c);
+	deactivate_slab(s, c->page, c->freelist);
+
+	c->tid = next_tid(c->tid);
+	c->page = NULL;
+	c->freelist = NULL;
 }
 
 /*
@@ -2069,7 +2066,9 @@ static void *__slab_alloc(struct kmem_ca
 
 	if (unlikely(!node_match(c, node))) {
 		stat(s, ALLOC_NODE_MISMATCH);
-		deactivate_slab(s, c);
+		deactivate_slab(s, c->page, c->freelist);
+		c->page = NULL;
+		c->freelist = NULL;
 		goto new_slab;
 	}
 
@@ -2156,8 +2155,9 @@ debug:
 	if (!object || !alloc_debug_processing(s, page, object, addr))
 		goto new_slab;
 
-	c->freelist = get_freepointer(s, object);
-	deactivate_slab(s, c);
+	deactivate_slab(s, c->page, get_freepointer(s, object));
+	c->page = NULL;
+	c->freelist = NULL;
 	local_irq_restore(flags);
 	return object;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
