Date: Wed, 13 Jun 2007 12:12:03 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: [PATCH] slob: poor man's NUMA, take 2.
Message-ID: <20070613031203.GB15009@linux-sh.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Christoph Lameter <clameter@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Here's an updated copy of the patch adding simple NUMA support to SLOB,
against the current -mm version of SLOB this time.

I've tried to address all of the comments on the initial version so far,
but there's obviously still room for improvement.

This approach is not terribly scalable in that we still end up using a
global freelist (and a global spinlock!) across all nodes, making the
partial free page lookup rather expensive. The next step after this will
be moving towards split freelists with finer grained locking.

The scanning of the global freelist could be sped up by simply ignoring
the node id unless __GFP_THISNODE is set. This patch defaults to trying
to match up the node id for the partial pages (whereas the last one just
grabbed the first partial page from the list, regardless of node
placement), but perhaps that's the wrong default and should only be done
for __GFP_THISNODE?

Signed-off-by: Paul Mundt <lethal@linux-sh.org>

--

 include/linux/slab.h |    7 ++++
 mm/slob.c            |   72 +++++++++++++++++++++++++++++++++++++++++++--------
 2 files changed, 68 insertions(+), 11 deletions(-)

diff --git a/mm/slob.c b/mm/slob.c
index 06e5e72..d89f951 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -204,6 +204,23 @@ static int slob_last(slob_t *s)
 	return !((unsigned long)slob_next(s) & ~PAGE_MASK);
 }
 
+static inline void *slob_new_page(gfp_t gfp, int order, int node)
+{
+	void *page;
+
+#ifdef CONFIG_NUMA
+	if (node != -1)
+		page = alloc_pages_node(node, gfp, order);
+	else
+#endif
+		page = alloc_pages(gfp, order);
+
+	if (!page)
+		return NULL;
+
+	return page_address(page);
+}
+
 /*
  * Allocate a slob block within a given slob_page sp.
  */
@@ -258,7 +275,7 @@ static void *slob_page_alloc(struct slob_page *sp, size_t size, int align)
 /*
  * slob_alloc: entry point into the slob allocator.
  */
-static void *slob_alloc(size_t size, gfp_t gfp, int align)
+static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 {
 	struct slob_page *sp;
 	slob_t *b = NULL;
@@ -267,6 +284,15 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align)
 	spin_lock_irqsave(&slob_lock, flags);
 	/* Iterate through each partially free page, try to find room */
 	list_for_each_entry(sp, &free_slob_pages, list) {
+#ifdef CONFIG_NUMA
+		/*
+		 * If there's a node specification, search for a partial
+		 * page with a matching node id in the freelist.
+		 */
+		if (node != -1 && page_to_nid(&sp->page) != node)
+			continue;
+#endif
+
 		if (sp->units >= SLOB_UNITS(size)) {
 			b = slob_page_alloc(sp, size, align);
 			if (b)
@@ -277,7 +303,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align)
 
 	/* Not enough space: must allocate a new page */
 	if (!b) {
-		b = (slob_t *)__get_free_page(gfp);
+		b = slob_new_page(gfp, 0, node);
 		if (!b)
 			return 0;
 		sp = (struct slob_page *)virt_to_page(b);
@@ -381,22 +407,20 @@ out:
 #define ARCH_SLAB_MINALIGN __alignof__(unsigned long)
 #endif
 
-
-void *__kmalloc(size_t size, gfp_t gfp)
+static void *slob_node_alloc(size_t size, gfp_t gfp, int node)
 {
 	int align = max(ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
 
 	if (size < PAGE_SIZE - align) {
 		unsigned int *m;
-		m = slob_alloc(size + align, gfp, align);
+		m = slob_alloc(size + align, gfp, align, node);
 		if (m)
 			*m = size;
 		return (void *)m + align;
 	} else {
 		void *ret;
 
-		ret = (void *) __get_free_pages(gfp | __GFP_COMP,
-						get_order(size));
+		ret = slob_new_page(gfp | __GFP_COMP, get_order(size), node);
 		if (ret) {
 			struct page *page;
 			page = virt_to_page(ret);
@@ -405,8 +429,21 @@ void *__kmalloc(size_t size, gfp_t gfp)
 		return ret;
 	}
 }
+
+void *__kmalloc(size_t size, gfp_t gfp)
+{
+	return slob_node_alloc(size, gfp, -1);
+}
 EXPORT_SYMBOL(__kmalloc);
 
+#ifdef CONFIG_NUMA
+void *__kmalloc_node(size_t size, gfp_t gfp, int node)
+{
+	return slob_node_alloc(size, gfp, node);
+}
+EXPORT_SYMBOL(__kmalloc_node);
+#endif
+
 /**
  * krealloc - reallocate memory. The contents will remain unchanged.
  *
@@ -487,7 +524,7 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size,
 {
 	struct kmem_cache *c;
 
-	c = slob_alloc(sizeof(struct kmem_cache), flags, 0);
+	c = slob_alloc(sizeof(struct kmem_cache), flags, 0, -1);
 
 	if (c) {
 		c->name = name;
@@ -517,22 +554,35 @@ void kmem_cache_destroy(struct kmem_cache *c)
 }
 EXPORT_SYMBOL(kmem_cache_destroy);
 
-void *kmem_cache_alloc(struct kmem_cache *c, gfp_t flags)
+static void *__kmem_cache_alloc(struct kmem_cache *c, gfp_t flags, int node)
 {
 	void *b;
 
 	if (c->size < PAGE_SIZE)
-		b = slob_alloc(c->size, flags, c->align);
+		b = slob_alloc(c->size, flags, c->align, node);
 	else
-		b = (void *)__get_free_pages(flags, get_order(c->size));
+		b = slob_new_page(flags, get_order(c->size), node);
 
 	if (c->ctor)
 		c->ctor(b, c, 0);
 
 	return b;
 }
+
+void *kmem_cache_alloc(struct kmem_cache *c, gfp_t flags)
+{
+	return __kmem_cache_alloc(c, flags, -1);
+}
 EXPORT_SYMBOL(kmem_cache_alloc);
 
+#ifdef CONFIG_NUMA
+void *kmem_cache_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
+{
+	return __kmem_cache_alloc(c, flags, node);
+}
+EXPORT_SYMBOL(kmem_cache_alloc_node);
+#endif
+
 void *kmem_cache_zalloc(struct kmem_cache *c, gfp_t flags)
 {
 	void *ret = kmem_cache_alloc(c, flags);
diff --git a/include/linux/slab.h b/include/linux/slab.h
index a015236..efc87c1 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -200,6 +200,13 @@ static inline void *__kmalloc_node(size_t size, gfp_t flags, int node)
 {
 	return __kmalloc(size, flags);
 }
+#elif defined(CONFIG_SLOB)
+extern void *__kmalloc_node(size_t size, gfp_t flags, int node);
+
+static inline void *kmalloc_node(size_t size, gfp_t flags, int node)
+{
+	return __kmalloc_node(size, flags, node);
+}
 #endif /* !CONFIG_NUMA */
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
