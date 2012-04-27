Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id DA27D6B004D
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 12:36:24 -0400 (EDT)
Date: Fri, 27 Apr 2012 10:29:12 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: slub memory hotplug: Allocate kmem_cache_node structure on new
 node
Message-ID: <alpine.DEB.2.00.1204271020530.29198@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org

Could you test this patch and see if it does the correct thing on a memory
hotplug system?



Fix the bringup of a new memory node that used to simply alloate a management
structure from a foreign node to use the bootstrap functions to allocate
the kmem_cache_node structure from the correct node.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   40 +++++++++++++++++++++++++++-------------
 1 file changed, 27 insertions(+), 13 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-04-27 02:40:50.000000000 -0500
+++ linux-2.6/mm/slub.c	2012-04-27 04:19:02.183694195 -0500
@@ -1021,7 +1021,7 @@ static inline void inc_slabs_node(struct
 	 * May be called early in order to allocate a slab for the
 	 * kmem_cache_node structure. Solve the chicken-egg
 	 * dilemma by deferring the increment of the count during
-	 * bootstrap (see early_kmem_cache_node_alloc).
+	 * bootstrap (see kmem_cache_node_first_alloc).
 	 */
 	if (n) {
 		atomic_long_inc(&n->nr_slabs);
@@ -2801,15 +2801,23 @@ static inline int alloc_kmem_cache_cpus(
 static struct kmem_cache *kmem_cache_node;

 /*
- * No kmalloc_node yet so do it by hand. We know that this is the first
- * slab on the node for this slabcache. There are no concurrent accesses
- * possible.
+ * Solve the chicken egg dilemma of needing a per node structure from
+ * the kmem_cache_node slab cache from the node that we want the structure for.
+ *
+ * We cannot allocate from the slab since the kmem_cache_node structure is
+ * missing. So allocate a slab page and manually configure it so that the first
+ * object can be used for the kmem_cache_node structure of the kmem_cache_node
+ * slabcache. Then initialize the kmem_cache_node structure to have the correct
+ * values and make it usable. After that additional kmem_cache_node structures
+ * can be allocated via the regular allocator functions.
  *
  * Note that this function only works on the kmalloc_node_cache
- * when allocating for the kmalloc_node_cache. This is used for bootstrapping
- * memory on a fresh node that has no slab structures yet.
+ * when performing an initial allocation for kmalloc_node_cache.
+ *
+ * This function is required for bootstrapping
+ * slab caches on a fresh node that has no slab structures yet.
  */
-static void early_kmem_cache_node_alloc(int node)
+static void kmem_cache_node_first_alloc(int node)
 {
 	struct page *page;
 	struct kmem_cache_node *n;
@@ -2864,7 +2872,7 @@ static int init_kmem_cache_nodes(struct
 		struct kmem_cache_node *n;

 		if (slab_state == DOWN) {
-			early_kmem_cache_node_alloc(node);
+			kmem_cache_node_first_alloc(node);
 			continue;
 		}
 		n = kmem_cache_alloc_node(kmem_cache_node,
@@ -3614,12 +3622,18 @@ static int slab_mem_going_online_callbac
 	 * online.
 	 */
 	down_read(&slub_lock);
+
+	/*
+	 * Must have a kmem_cache_node structure for the kmem_cache_node
+	 * structure first on the target node otherwise we cannot allocate
+	 * kmem_cache_node structures for other slab caches on the new node.
+	 */
+	kmem_cache_node_first_alloc(nid);
+
 	list_for_each_entry(s, &slab_caches, list) {
-		/*
-		 * XXX: kmem_cache_alloc_node will fallback to other nodes
-		 *      since memory is not yet available from the node that
-		 *      is brought up.
-		 */
+		if (s == kmem_cache_node)
+			continue;
+
 		n = kmem_cache_alloc(kmem_cache_node, GFP_KERNEL);
 		if (!n) {
 			ret = -ENOMEM;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
