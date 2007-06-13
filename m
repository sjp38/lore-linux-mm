Date: Wed, 13 Jun 2007 18:21:09 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH] slob: poor man's NUMA, take 2.
Message-ID: <20070613092109.GA16526@linux-sh.org>
References: <20070613031203.GB15009@linux-sh.org> <20070613032857.GN11115@waste.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070613032857.GN11115@waste.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Christoph Lameter <clameter@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 12, 2007 at 10:28:57PM -0500, Matt Mackall wrote:
> On Wed, Jun 13, 2007 at 12:12:03PM +0900, Paul Mundt wrote:
> > +static inline void *slob_new_page(gfp_t gfp, int order, int node)
> > +{
> > +	void *page;
> > +
> > +#ifdef CONFIG_NUMA
> > +	if (node != -1)
> > +		page = alloc_pages_node(node, gfp, order);
> > +	else
> > +#endif
> > +		page = alloc_pages(gfp, order);
> > +
> > +	if (!page)
> > +		return NULL;
> > +
> > +	return page_address(page);
> 
> We might want to leave the inlining decision here to the compiler. The
> ifdef may change that decision..
> 
> > -void *__kmalloc(size_t size, gfp_t gfp)
> > +static void *slob_node_alloc(size_t size, gfp_t gfp, int node)
> 
> See my comment in the last message.
> 
Here's an updated copy with the node variants always defined.

I've left the nid=-1 case in as the default for the non-node variants, as
this is the approach also used by SLUB. alloc_pages() is special cased
for NUMA, and takes the memory policy under advisement when doing the
allocation, so the page ends up in a reasonable place.

Signed-off-by: Paul Mundt <lethal@linux-sh.org>

--

 include/linux/slab.h |   11 +++++++--
 mm/slob.c            |   59 ++++++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 56 insertions(+), 14 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index a015236..97d9b0a 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -63,7 +63,7 @@ int kmem_ptr_validate(struct kmem_cache *cachep, const void *ptr);
 		sizeof(struct __struct), __alignof__(struct __struct),\
 		(__flags), NULL, NULL)
 
-#ifdef CONFIG_NUMA
+#if defined(CONFIG_NUMA) || defined(CONFIG_SLOB)
 extern void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
 #else
 static inline void *kmem_cache_alloc_node(struct kmem_cache *cachep,
@@ -190,7 +190,14 @@ static inline void *kzalloc(size_t size, gfp_t flags)
 }
 #endif
 
-#ifndef CONFIG_NUMA
+#if defined(CONFIG_SLOB)
+extern void *__kmalloc_node(size_t size, gfp_t flags, int node);
+
+static inline void *kmalloc_node(size_t size, gfp_t flags, int node)
+{
+	return __kmalloc_node(size, flags, node);
+}
+#elif !defined(CONFIG_NUMA)
 static inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 {
 	return kmalloc(size, flags);
diff --git a/mm/slob.c b/mm/slob.c
index 06e5e72..07e3730 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -204,6 +204,23 @@ static int slob_last(slob_t *s)
 	return !((unsigned long)slob_next(s) & ~PAGE_MASK);
 }
 
+static void *slob_new_page(gfp_t gfp, int order, int node)
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
+void *__kmalloc_node(size_t size, gfp_t gfp, int node)
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
@@ -405,6 +429,12 @@ void *__kmalloc(size_t size, gfp_t gfp)
 		return ret;
 	}
 }
+EXPORT_SYMBOL(__kmalloc_node);
+
+void *__kmalloc(size_t size, gfp_t gfp)
+{
+	return __kmalloc_node(size, gfp, -1);
+}
 EXPORT_SYMBOL(__kmalloc);
 
 /**
@@ -455,7 +485,6 @@ void kfree(const void *block)
 	} else
 		put_page(&sp->page);
 }
-
 EXPORT_SYMBOL(kfree);
 
 /* can't use ksize for kmem_cache_alloc memory, only kmalloc */
@@ -487,7 +516,7 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size,
 {
 	struct kmem_cache *c;
 
-	c = slob_alloc(sizeof(struct kmem_cache), flags, 0);
+	c = slob_alloc(sizeof(struct kmem_cache), flags, 0, -1);
 
 	if (c) {
 		c->name = name;
@@ -517,20 +546,26 @@ void kmem_cache_destroy(struct kmem_cache *c)
 }
 EXPORT_SYMBOL(kmem_cache_destroy);
 
-void *kmem_cache_alloc(struct kmem_cache *c, gfp_t flags)
+void *kmem_cache_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
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
+EXPORT_SYMBOL(kmem_cache_alloc_node);
+
+void *kmem_cache_alloc(struct kmem_cache *c, gfp_t flags)
+{
+	return kmem_cache_alloc_node(c, flags, -1);
+}
 EXPORT_SYMBOL(kmem_cache_alloc);
 
 void *kmem_cache_zalloc(struct kmem_cache *c, gfp_t flags)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
