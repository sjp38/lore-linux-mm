Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 367D46B01B5
	for <linux-mm@kvack.org>; Fri, 21 May 2010 17:19:04 -0400 (EDT)
Message-Id: <20100521211545.336946412@quilx.com>
Date: Fri, 21 May 2010 16:15:06 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [RFC V2 SLEB 14/14] SLEB: Allocate off node objects from remote shared caches
References: <20100521211452.659982351@quilx.com>
Content-Disposition: inline; filename=sled_off_node_from_shared
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is in a draft state.

Leave the cpu queue alone for off node accesses and go directly to the
remote shared cache for alloations.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 include/linux/slub_def.h |    1 
 mm/slub.c                |  184 ++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 142 insertions(+), 43 deletions(-)

Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2010-05-21 15:30:47.000000000 -0500
+++ linux-2.6/include/linux/slub_def.h	2010-05-21 15:34:45.000000000 -0500
@@ -42,7 +42,6 @@ struct kmem_cache_cpu {
 	unsigned stat[NR_SLUB_STAT_ITEMS];
 #endif
 	int objects;		/* Number of objects available */
-	int node;		/* The node of the page (or -1 for debug) */
 	void *object[BOOT_QUEUE_SIZE];		/* List of objects */
 };
 
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-05-21 15:30:47.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-05-21 15:37:04.000000000 -0500
@@ -1616,19 +1616,6 @@ static void resize_cpu_queue(struct kmem
 	}
 }
 
-/*
- * Check if the objects in a per cpu structure fit numa
- * locality expectations.
- */
-static inline int node_match(struct kmem_cache_cpu *c, int node)
-{
-#ifdef CONFIG_NUMA
-	if (node != -1 && c->node != node)
-		return 0;
-#endif
-	return 1;
-}
-
 static unsigned long count_partial(struct kmem_cache_node *n,
 					int (*get_count)(struct page *))
 {
@@ -1718,9 +1705,9 @@ void retrieve_objects(struct kmem_cache 
 	}
 }
 
+#ifdef CONFIG_NUMA
 static inline int find_numa_node(struct kmem_cache *s, int selected_node)
 {
-#ifdef CONFIG_NUMA
 	if (s->flags & SLAB_MEM_SPREAD &&
 			!in_interrupt() &&
 			selected_node == SLAB_NODE_UNSPECIFIED) {
@@ -1731,10 +1718,113 @@ static inline int find_numa_node(struct 
 		if (current->mempolicy)
 			return slab_node(current->mempolicy);
 	}
-#endif
 	return selected_node;
 }
 
+/*
+ * Try to allocate a partial slab from a specific node.
+ */
+static struct page *__get_partial_node(struct kmem_cache_node *n)
+{
+	struct page *page;
+
+	if (!n->nr_partial)
+		return NULL;
+
+	list_for_each_entry(page, &n->partial, lru)
+		if (lock_and_freeze_slab(n, page))
+			goto out;
+	page = NULL;
+out:
+	return page;
+}
+
+
+void *off_node_alloc(struct kmem_cache *s, int node, gfp_t gfpflags)
+{
+	void *object = NULL;
+	struct kmem_cache_node *n = get_node(s, node);
+
+	spin_lock(&n->shared_lock);
+
+	while (!object) {
+		/* Direct allocation from remote shared cache */
+		if (n->objects) {
+#if 0
+			/* Taking a hot object remotely  */
+			object = n->object[--n->objects];
+#else
+			/* Take a cold object from the remote shared cache */
+			object = n->object[0];
+			n->objects--;
+			memcpy(n->object, n->object + 1, n->objects * sizeof(void *));
+#endif
+			break;
+		}
+
+		while (n->objects < s->batch) {
+			struct page *new;
+			int d;
+
+			/* Should be getting cold remote page !! This is hot */
+			new = __get_partial_node(n);
+			if (unlikely(!new)) {
+
+				spin_unlock(&n->shared_lock);
+
+				if (gfpflags & __GFP_WAIT)
+					local_irq_enable();
+
+				new = new_slab(s, gfpflags, node);
+
+				if (gfpflags & __GFP_WAIT)
+					local_irq_disable();
+
+				spin_lock(&n->shared_lock);
+
+ 				if (!new)
+					goto out;
+
+				stat(s, ALLOC_SLAB);
+				slab_lock(new);
+			} else
+				stat(s, ALLOC_FROM_PARTIAL);
+
+			d = min(s->batch - n->objects, available(new));
+			retrieve_objects(s, new, n->object + n->objects, d);
+			n->objects += d;
+
+			if (!all_objects_used(new))
+
+				add_partial(get_node(s, page_to_nid(new)), new, 1);
+
+			else
+				add_full(s, get_node(s, page_to_nid(new)), new);
+
+			slab_unlock(new);
+		}
+	}
+out:
+	spin_unlock(&n->shared_lock);
+	return object;
+}
+
+/*
+ * Check if the objects in a per cpu structure fit numa
+ * locality expectations.
+ */
+static inline int node_local(int node)
+{
+	if (node != -1 || numa_node_id() != node)
+		return 0;
+	return 1;
+}
+
+#else
+static inline int find_numa_node(struct kmem_cache *s, int selected_node) { return selected_node; }
+static inline void *off_node_alloc(struct kmem_cache *s, int node, gfp_t gfpflags) { return NULL; }
+static inline int node_local(int node) { return 1; }
+#endif
 
 static void *slab_alloc(struct kmem_cache *s,
 		gfp_t gfpflags, int node, unsigned long addr)
@@ -1753,36 +1843,41 @@ redo:
 	node = find_numa_node(s, node);
 	local_irq_save(flags);
 	c = __this_cpu_ptr(s->cpu_slab);
-	if (unlikely(!c->objects || !node_match(c, node))) {
+	if (unlikely(!c->objects || !node_local(node))) {
+
+		struct kmem_cache_node *n;
 
 		gfpflags &= gfp_allowed_mask;
 
-		if (unlikely(!node_match(c, node))) {
-			flush_cpu_objects(s, c);
-			c->node = node;
-		} else {
-			struct kmem_cache_node *n = get_node(s, c->node);
+		if (unlikely(!node_local(node))) {
+			object = off_node_alloc(s, node, gfpflags);
+			if (!object)
+				goto oom;
+			else
+				goto got_object;
+		}
 
-			/*
-			 * Node specified is matching the stuff that we cache,
-			 * so we could retrieve objects from the shared cache
-			 * of the indicated node if there would be anything
-			 * there.
-			 */
-			if (n->objects) {
-				int d;
+		n = get_node(s, numa_node_id());
 
-				spin_lock(&n->shared_lock);
-				d = min(min(s->batch, s->shared), n->objects);
-				if (d > 0) {
-					memcpy(c->object + c->objects,
-						n->object + n->objects - d,
-						d * sizeof(void *));
-					n->objects -= d;
-					c->objects += d;
-				}
-				spin_unlock(&n->shared_lock);
+		/*
+		 * Node specified is matching the stuff that we cache,
+		 * so we could retrieve objects from the shared cache
+		 * of the indicated node if there would be anything
+		 * there.
+		 */
+		if (n->objects) {
+			int d;
+
+			spin_lock(&n->shared_lock);
+			d = min(min(s->batch, s->shared), n->objects);
+			if (d > 0) {
+				memcpy(c->object + c->objects,
+					n->object + n->objects - d,
+					d * sizeof(void *));
+				n->objects -= d;
+				c->objects += d;
 			}
+			spin_unlock(&n->shared_lock);
 		}
 
 		while (c->objects < s->batch) {
@@ -1833,6 +1928,8 @@ redo:
 
 	object = c->object[--c->objects];
 
+got_object:
+
 	if (unlikely(debug_on(s))) {
 		if (!alloc_debug_processing(s, object, addr))
 			goto redo;
@@ -1962,8 +2059,10 @@ static void slab_free(struct kmem_cache 
 	if (!(s->flags & SLAB_DEBUG_OBJECTS))
 		debug_check_no_obj_freed(object, s->objsize);
 
+#ifdef CONFIG_NUMA
 	if (numa_off_node_free(s, x))
 		goto out;
+#endif
 
 	if (unlikely(c->objects >= s->queue)) {
 
@@ -3941,8 +4040,9 @@ static ssize_t show_slab_objects(struct 
 
 		for_each_possible_cpu(cpu) {
 			struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu_slab, cpu);
+			int node = cpu_to_node(cpu);
 
-			if (!c || c->node < 0)
+			if (!c)
 				continue;
 
 			if (c->objects) {
@@ -3954,9 +4054,9 @@ static ssize_t show_slab_objects(struct 
 					x = 1;
 
 				total += x;
-				nodes[c->node] += x;
+				nodes[node] += x;
 			}
-			per_cpu[c->node]++;
+			per_cpu[node]++;
 		}
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
