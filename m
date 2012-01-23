Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 23C376B0070
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 15:17:11 -0500 (EST)
Message-Id: <20120123201709.433927049@linux.com>
Date: Mon, 23 Jan 2012 14:16:53 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [Slub cleanup 7/9] slub: Separate out kmem_cache_cpu processing from deactivate_slab
References: <20120123201646.924319545@linux.com>
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
--- linux-2.6.orig/mm/slub.c	2012-01-13 08:47:28.506748438 -0600
+++ linux-2.6/mm/slub.c	2012-01-13 08:47:31.930748367 -0600
@@ -1712,14 +1712,12 @@ void init_kmem_cache_cpus(struct kmem_ca
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
@@ -1730,11 +1728,6 @@ static void deactivate_slab(struct kmem_
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
@@ -1992,7 +1985,11 @@ int put_cpu_partial(struct kmem_cache *s
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
@@ -2204,7 +2201,9 @@ redo:
 
 	if (unlikely(!node_match(c, node))) {
 		stat(s, ALLOC_NODE_MISMATCH);
-		deactivate_slab(s, c);
+		deactivate_slab(s, c->page, c->freelist);
+		c->page = NULL;
+		c->freelist = NULL;
 		goto new_slab;
 	}
 
@@ -2264,8 +2263,9 @@ new_slab:
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
