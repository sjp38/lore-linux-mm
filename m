Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 5547C6B0120
	for <linux-mm@kvack.org>; Wed,  9 May 2012 11:10:12 -0400 (EDT)
Message-Id: <20120509151010.714078243@linux.com>
Date: Wed, 09 May 2012 10:09:57 -0500
From: cl@linux.com
From: Christoph Lameter <cl@linux.com>
Subject: [Slub cleanup 7/9] slub: Separate out kmem_cache_cpu processing from deactivate_slab
References: <20120509150950.243797150@linux.com>
Content-Disposition: inline; filename=separate_deactivate_slab
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Processing on fields of kmem_cache_cpu is cleaner if code working on fields
of this struct is taken out of deactivate_slab().

Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-04-10 10:33:13.906750659 -0500
+++ linux-2.6/mm/slub.c	2012-04-10 10:33:17.798750578 -0500
@@ -1729,14 +1729,12 @@ void init_kmem_cache_cpus(struct kmem_ca
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
@@ -1747,11 +1745,6 @@ static void deactivate_slab(struct kmem_
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
@@ -2009,7 +2002,11 @@ int put_cpu_partial(struct kmem_cache *s
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
@@ -2229,7 +2226,9 @@ redo:
 
 	if (unlikely(!node_match(c, node))) {
 		stat(s, ALLOC_NODE_MISMATCH);
-		deactivate_slab(s, c);
+		deactivate_slab(s, c->page, c->freelist);
+		c->page = NULL;
+		c->freelist = NULL;
 		goto new_slab;
 	}
 
@@ -2289,8 +2288,9 @@ new_slab:
 	if (!alloc_debug_processing(s, c->page, freelist, addr))
 		goto new_slab;	/* Slab failed checks. Next slab needed */
 
-	c->freelist = get_freepointer(s, freelist);
-	deactivate_slab(s, c);
+	deactivate_slab(s, c->page, get_freepointer(s, freelist));
+	c->page = NULL;
+	c->freelist = NULL;
 	local_irq_restore(flags);
 	return freelist;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
