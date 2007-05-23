Date: Tue, 22 May 2007 23:01:18 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: RFC SLUB: Add statistics support for other kernel subsystems.
Message-ID: <Pine.LNX.4.64.0705222257430.31594@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Eric Dumazet <dada1@cosmosbay.com>
List-ID: <linux-mm.kvack.org>

I am not sure if this is useful or if this should take a different form 
.... But Eric and Peter asked me for some of the functionality included here.



Cleanup and export the statistics support that is current used to 
generate the numbers available via sysfs.

Add a function kmem_cache_count() that can determine slabs, pages and objects
in the various types of slab pages.

Also add a function estimate the amount of memory in pages needed in order to
allocate a given number of objects.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/slub_def.h |   27 +++++
 mm/slub.c                |  215 +++++++++++++++++++++++++++++------------------
 2 files changed, 160 insertions(+), 82 deletions(-)

Index: slub/include/linux/slub_def.h
===================================================================
--- slub.orig/include/linux/slub_def.h	2007-05-22 22:46:24.000000000 -0700
+++ slub/include/linux/slub_def.h	2007-05-22 22:49:06.000000000 -0700
@@ -172,4 +172,31 @@ static inline void *kmalloc_node(size_t 
 }
 #endif
 
+/*
+ * Statistics for slabcaches. Calls to kmem_cache_count must specify what
+ * is to be counted and may specify in what units the counting should be
+ * done. If no type is specified then we return counts of slabs.
+ *
+ * Note that -ENOSYS may be returned if a slab is merged with others.
+ * If the combined counts of multiple slabs are acceptable then
+ * KMEM_CACHE_ALIAS may be specified and then the amounts of the
+ * merged slab will be returned.
+ */
+#define KMEM_CACHE_FULL		0x0001	/* Count full slabs */
+#define KMEM_CACHE_PARTIAL	0x0002	/* Count partial slabs */
+#define KMEM_CACHE_PER_CPU	0x0004	/* Count cpu slabs */
+#define KMEM_CACHE_OBJECTS	0x0010	/* Return object counts */
+#define KMEM_CACHE_PAGES	0x0020	/* Return page counts */
+#define KMEM_CACHE_ALIAS	0x0100	/* Allow aliased slabs */
+
+#define KMEM_CACHE_ALL		(KMEM_CACHE_FULL|KMEM_CACHE_PARTIAL|\
+				KMEM_CACHE_PER_CPU)
+
+/* Estimate the worst case of pages needed for a given number of objects */
+unsigned long kmem_cache_estimate_pages(struct kmem_cache *s, int objects);
+
+/* Determine the amount of slabs/pages/objects */
+long kmem_cache_count(struct kmem_cache *s,
+		unsigned long stat_flags, unsigned long *nodes);
+
 #endif /* _LINUX_SLUB_DEF_H */
Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-05-22 22:46:24.000000000 -0700
+++ slub/mm/slub.c	2007-05-22 22:56:31.000000000 -0700
@@ -2398,6 +2398,114 @@ int kmem_cache_shrink(struct kmem_cache 
 }
 EXPORT_SYMBOL(kmem_cache_shrink);
 
+/*
+ * Determine counts of objects / pages
+ */
+static unsigned long count_partial(struct kmem_cache_node *n)
+{
+	unsigned long flags;
+	unsigned long x = 0;
+	struct page *page;
+
+	spin_lock_irqsave(&n->list_lock, flags);
+	list_for_each_entry(page, &n->partial, lru)
+		x += page->inuse;
+	spin_unlock_irqrestore(&n->list_lock, flags);
+	return x;
+}
+
+long kmem_cache_count(struct kmem_cache *s, unsigned long flags,
+	unsigned long *nodes)
+{
+	unsigned long total = 0;
+	int cpu;
+	int node;
+	unsigned long x;
+	unsigned long *per_cpu;
+
+	if (s->refcount > 1 && !(flags & KMEM_CACHE_ALIAS))
+		return -ENOSYS;
+
+	per_cpu = kzalloc(nr_node_ids * sizeof(unsigned long), GFP_KERNEL);
+	if (!per_cpu)
+		return -ENOMEM;
+
+	if (nodes)
+		memset(nodes, 0, nr_node_ids * sizeof(unsigned long));
+
+
+	for_each_possible_cpu(cpu) {
+		struct page *page = s->cpu_slab[cpu];
+		int node;
+
+		if (page) {
+			node = page_to_nid(page);
+			if (flags & KMEM_CACHE_PER_CPU) {
+				int x = 0;
+
+				if (flags & KMEM_CACHE_OBJECTS)
+					x = page->inuse;
+				else
+					x = 1;
+				total += x;
+				if (nodes)
+					nodes[node] += x;
+			}
+			per_cpu[node]++;
+		}
+	}
+
+	for_each_online_node(node) {
+		struct kmem_cache_node *n = get_node(s, node);
+
+		if (flags & KMEM_CACHE_PARTIAL) {
+			if (flags & KMEM_CACHE_OBJECTS)
+				x = count_partial(n);
+			else
+				x = n->nr_partial;
+			total += x;
+			if (nodes)
+				nodes[node] += x;
+		}
+
+		if (flags & KMEM_CACHE_FULL) {
+			int full_slabs = atomic_read(&n->nr_slabs)
+					- per_cpu[node]
+					- n->nr_partial;
+
+			if (flags & KMEM_CACHE_OBJECTS)
+				x = full_slabs * s->objects;
+			else
+				x = full_slabs;
+			total += x;
+			if (nodes)
+				nodes[node] += x;
+		}
+	}
+	if (flags & KMEM_CACHE_PAGES)
+		total <<= s->order;
+	return total;
+}
+EXPORT_SYMBOL(kmem_cache_count);
+
+/*
+ * Determine the worst case scenario of pages needed when allocating the
+ * indicated amount of objects.
+ */
+unsigned long kmem_cache_estimate(struct kmem_cache *s, int objects)
+{
+	unsigned long slabs = (objects + s->objects - 1) / s->objects;
+
+	/*
+	 * Account the possible additional overhead if per cpu slabs are
+	 * currently empty and have to be allocated. This is very unlikely
+	 * but a possible scenario immediately after kmem_cache_shrink.
+	 */
+	slabs += num_online_cpus();
+
+	return slabs << s->order;
+}
+
 /**
  * krealloc - reallocate memory. The contents will remain unchanged.
  * @p: object to reallocate memory for.
@@ -3049,97 +3157,40 @@ static int list_locations(struct kmem_ca
 	return n;
 }
 
-static unsigned long count_partial(struct kmem_cache_node *n)
+static int numa_distribution(char *buf, unsigned long *nodes)
 {
-	unsigned long flags;
-	unsigned long x = 0;
-	struct page *page;
+	int x = 0;
 
-	spin_lock_irqsave(&n->list_lock, flags);
-	list_for_each_entry(page, &n->partial, lru)
-		x += page->inuse;
-	spin_unlock_irqrestore(&n->list_lock, flags);
+#ifdef CONFIG_NUMA
+	int node;
+
+	for_each_online_node(node)
+		if (nodes[node])
+			x += sprintf(buf + x, " N%d=%lu",
+					node, nodes[node]);
+#endif
 	return x;
 }
 
-enum slab_stat_type {
-	SL_FULL,
-	SL_PARTIAL,
-	SL_CPU,
-	SL_OBJECTS
-};
-
-#define SO_FULL		(1 << SL_FULL)
-#define SO_PARTIAL	(1 << SL_PARTIAL)
-#define SO_CPU		(1 << SL_CPU)
-#define SO_OBJECTS	(1 << SL_OBJECTS)
-
-static unsigned long slab_objects(struct kmem_cache *s,
+static long slab_objects(struct kmem_cache *s,
 			char *buf, unsigned long flags)
 {
-	unsigned long total = 0;
-	int cpu;
-	int node;
-	int x;
+	long total;
+	unsigned long x;
 	unsigned long *nodes;
-	unsigned long *per_cpu;
-
-	nodes = kzalloc(2 * sizeof(unsigned long) * nr_node_ids, GFP_KERNEL);
-	per_cpu = nodes + nr_node_ids;
 
-	for_each_possible_cpu(cpu) {
-		struct page *page = s->cpu_slab[cpu];
-		int node;
-
-		if (page) {
-			node = page_to_nid(page);
-			if (flags & SO_CPU) {
-				int x = 0;
-
-				if (flags & SO_OBJECTS)
-					x = page->inuse;
-				else
-					x = 1;
-				total += x;
-				nodes[node] += x;
-			}
-			per_cpu[node]++;
-		}
-	}
-
-	for_each_online_node(node) {
-		struct kmem_cache_node *n = get_node(s, node);
-
-		if (flags & SO_PARTIAL) {
-			if (flags & SO_OBJECTS)
-				x = count_partial(n);
-			else
-				x = n->nr_partial;
-			total += x;
-			nodes[node] += x;
-		}
-
-		if (flags & SO_FULL) {
-			int full_slabs = atomic_read(&n->nr_slabs)
-					- per_cpu[node]
-					- n->nr_partial;
+	nodes = kzalloc(sizeof(unsigned long) * nr_node_ids, GFP_KERNEL);
+	if (!nodes)
+		return 0;
 
-			if (flags & SO_OBJECTS)
-				x = full_slabs * s->objects;
-			else
-				x = full_slabs;
-			total += x;
-			nodes[node] += x;
-		}
+	total = kmem_cache_count(s, flags | KMEM_CACHE_ALIAS, nodes);
+	if (total < 0) {
+		kfree(nodes);
+		return total;
 	}
 
 	x = sprintf(buf, "%lu", total);
-#ifdef CONFIG_NUMA
-	for_each_online_node(node)
-		if (nodes[node])
-			x += sprintf(buf + x, " N%d=%lu",
-					node, nodes[node]);
-#endif
+	x += numa_distribution(buf + x, nodes);
 	kfree(nodes);
 	return x + sprintf(buf + x, "\n");
 }
@@ -3227,25 +3278,25 @@ SLAB_ATTR_RO(aliases);
 
 static ssize_t slabs_show(struct kmem_cache *s, char *buf)
 {
-	return slab_objects(s, buf, SO_FULL|SO_PARTIAL|SO_CPU);
+	return slab_objects(s, buf, KMEM_CACHE_ALL);
 }
 SLAB_ATTR_RO(slabs);
 
 static ssize_t partial_show(struct kmem_cache *s, char *buf)
 {
-	return slab_objects(s, buf, SO_PARTIAL);
+	return slab_objects(s, buf, KMEM_CACHE_PARTIAL);
 }
 SLAB_ATTR_RO(partial);
 
 static ssize_t cpu_slabs_show(struct kmem_cache *s, char *buf)
 {
-	return slab_objects(s, buf, SO_CPU);
+	return slab_objects(s, buf, KMEM_CACHE_PER_CPU);
 }
 SLAB_ATTR_RO(cpu_slabs);
 
 static ssize_t objects_show(struct kmem_cache *s, char *buf)
 {
-	return slab_objects(s, buf, SO_FULL|SO_PARTIAL|SO_CPU|SO_OBJECTS);
+	return slab_objects(s, buf, KMEM_CACHE_ALL|KMEM_CACHE_OBJECTS);
 }
 SLAB_ATTR_RO(objects);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
