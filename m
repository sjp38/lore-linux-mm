Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 48A626B006E
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 15:07:30 -0500 (EST)
Message-Id: <20111111200726.286206880@linux.com>
Date: Fri, 11 Nov 2011 14:07:13 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [rfc 02/18] slub: Separate out kmem_cache_cpu processing from deactivate_slab
References: <20111111200711.156817886@linux.com>
Content-Disposition: inline; filename=separate_deactivate_slab
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, Shaohua Li <shaohua.li@intel.com>, Alex Shi <alex.shi@intel.com>, linux-mm@kvack.org

Processing on fields of kmem_cache needs to be outside of deactivate_slab()
since we will be handling that with cmpxchg_double later.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-11-09 11:10:46.111334466 -0600
+++ linux-2.6/mm/slub.c	2011-11-09 11:10:55.671388657 -0600
@@ -1708,14 +1708,12 @@ void init_kmem_cache_cpus(struct kmem_ca
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
 	int tail = DEACTIVATE_TO_HEAD;
 	struct page new;
@@ -1726,11 +1724,6 @@ static void deactivate_slab(struct kmem_
 		tail = DEACTIVATE_TO_TAIL;
 	}
 
-	c->tid = next_tid(c->tid);
-	c->page = NULL;
-	freelist = c->freelist;
-	c->freelist = NULL;
-
 	/*
 	 * Stage one: Free all available per cpu objects back
 	 * to the page freelist while it is still frozen. Leave the
@@ -1976,7 +1969,11 @@ int put_cpu_partial(struct kmem_cache *s
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
@@ -2151,7 +2148,9 @@ static void *__slab_alloc(struct kmem_ca
 redo:
 	if (unlikely(!node_match(c, node))) {
 		stat(s, ALLOC_NODE_MISMATCH);
-		deactivate_slab(s, c);
+		deactivate_slab(s, c->page, c->freelist);
+		c->page = NULL;
+		c->freelist = NULL;
 		goto new_slab;
 	}
 
@@ -2228,8 +2227,9 @@ new_slab:
 	if (!alloc_debug_processing(s, c->page, object, addr))
 		goto new_slab;	/* Slab failed checks. Next slab needed */
 
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
