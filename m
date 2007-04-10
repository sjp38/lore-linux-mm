From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070410032927.18967.68230.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070410032912.18967.67076.sendpatchset@schroedinger.engr.sgi.com>
References: <20070410032912.18967.67076.sendpatchset@schroedinger.engr.sgi.com>
Subject: [SLUB 4/5] Fix another NUMA bootstrap issue
Date: Mon,  9 Apr 2007 20:29:27 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

SLUB : Fix another NUMA bootstrap issue.

Make sure that the bootstrap allocation occurs on the correct node and
that the slab we allocated gets put onto the partial list. Otherwise the rest
of the slab is lost for good.

And while we are at it reduce the amount of #ifdefs by rearranging code.

init_kmem_cache_node already initializes most fields. Avoid memset and just
set the remaining field manually.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc6-mm1/mm/slub.c
===================================================================
--- linux-2.6.21-rc6-mm1.orig/mm/slub.c	2007-04-09 18:20:00.000000000 -0700
+++ linux-2.6.21-rc6-mm1/mm/slub.c	2007-04-09 19:55:32.000000000 -0700
@@ -1379,15 +1379,46 @@ static unsigned long calculate_alignment
 
 static void init_kmem_cache_node(struct kmem_cache_node *n)
 {
-	memset(n, 0, sizeof(struct kmem_cache_node));
+	n->nr_partial = 0;
 	atomic_long_set(&n->nr_slabs, 0);
 	spin_lock_init(&n->list_lock);
 	INIT_LIST_HEAD(&n->partial);
 }
 
+#ifdef CONFIG_NUMA
+/*
+ * No kmalloc_node yet so do it by hand. We know that this is the first
+ * slab on the node for this slabcache. There are no concurrent accesses
+ * possible.
+ *
+ * Note that this function only works on the kmalloc_node_cache
+ * when allocating for the kmalloc_node_cache.
+ */
+struct kmem_cache_node * __init early_kmem_cache_node_alloc(
+					gfp_t gfpflags, int node)
+{
+	struct page *page;
+	struct kmem_cache_node *n;
+
+	BUG_ON(kmalloc_caches->size < sizeof(struct kmem_cache_node));
+	page = new_slab(kmalloc_caches, gfpflags | GFP_THISNODE, node);
+	/* new_slab() disables interupts */
+	local_irq_enable();
+
+	BUG_ON(!page);
+	n = page->freelist;
+	BUG_ON(!n);
+	page->freelist = get_freepointer(kmalloc_caches, n);
+	page->inuse++;
+	kmalloc_caches->node[node] = n;
+	init_kmem_cache_node(n);
+	atomic_long_inc(&n->nr_slabs);
+	add_partial(kmalloc_caches, page);
+	return n;
+}
+
 static void free_kmem_cache_nodes(struct kmem_cache *s)
 {
-#ifdef CONFIG_NUMA
 	int node;
 
 	for_each_online_node(node) {
@@ -1396,12 +1427,10 @@ static void free_kmem_cache_nodes(struct
 			kmem_cache_free(kmalloc_caches, n);
 		s->node[node] = NULL;
 	}
-#endif
 }
 
 static int init_kmem_cache_nodes(struct kmem_cache *s, gfp_t gfpflags)
 {
-#ifdef CONFIG_NUMA
 	int node;
 	int local_node;
 
@@ -1415,45 +1444,37 @@ static int init_kmem_cache_nodes(struct 
 
 		if (local_node == node)
 			n = &s->local_node;
-		else
-		if (slab_state == DOWN) {
-			/*
-			 * No kmalloc_node yet so do it by hand.
-			 * We know that this is the first slab on the
-			 * node for this slabcache. There are no concurrent
-			 * accesses possible.
-			 */
-			struct page *page;
-
-			BUG_ON(s->size < sizeof(struct kmem_cache_node));
-			page = new_slab(kmalloc_caches, gfpflags, node);
-			/* new_slab() disables interupts */
-			local_irq_enable();
-
-			BUG_ON(!page);
-			n = page->freelist;
-			page->freelist = get_freepointer(kmalloc_caches, n);
-			page->inuse++;
-		} else
+		else {
+			if (slab_state == DOWN) {
+				n = early_kmem_cache_node_alloc(gfpflags,
+								node);
+				continue;
+			}
 			n = kmem_cache_alloc_node(kmalloc_caches,
 							gfpflags, node);
 
-		if (!n) {
-			free_kmem_cache_nodes(s);
-			return 0;
-		}
+			if (!n) {
+				free_kmem_cache_nodes(s);
+				return 0;
+			}
 
+		}
 		s->node[node] = n;
 		init_kmem_cache_node(n);
-
-		if (slab_state == DOWN)
-			atomic_long_inc(&n->nr_slabs);
 	}
+	return 1;
+}
 #else
+static void free_kmem_cache_nodes(struct kmem_cache *s)
+{
+}
+
+static int init_kmem_cache_nodes(struct kmem_cache *s, gfp_t gfpflags)
+{
 	init_kmem_cache_node(&s->local_node);
-#endif
 	return 1;
 }
+#endif
 
 int calculate_sizes(struct kmem_cache *s)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
