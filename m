Date: Thu, 14 Jun 2007 11:40:08 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH] slob: poor man's NUMA, take 2.
Message-ID: <20070614024008.GA21749@linux-sh.org>
References: <20070613031203.GB15009@linux-sh.org> <20070613032857.GN11115@waste.org> <20070613092109.GA16526@linux-sh.org> <20070613131549.GZ11115@waste.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070613131549.GZ11115@waste.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Christoph Lameter <clameter@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 13, 2007 at 08:15:49AM -0500, Matt Mackall wrote:
> On Wed, Jun 13, 2007 at 06:21:09PM +0900, Paul Mundt wrote:
> > Here's an updated copy with the node variants always defined.
> > 
> > I've left the nid=-1 case in as the default for the non-node variants, as
> > this is the approach also used by SLUB. alloc_pages() is special cased
> > for NUMA, and takes the memory policy under advisement when doing the
> > allocation, so the page ends up in a reasonable place.
> > 
> 
> > +void *__kmalloc(size_t size, gfp_t gfp)
> > +{
> > +	return __kmalloc_node(size, gfp, -1);
> > +}
> >  EXPORT_SYMBOL(__kmalloc);
> 
> > +void *kmem_cache_alloc(struct kmem_cache *c, gfp_t flags)
> > +{
> > +	return kmem_cache_alloc_node(c, flags, -1);
> > +}
> >  EXPORT_SYMBOL(kmem_cache_alloc);
> 
> Now promote these guys to inlines in slab.h. At which point all the
> new NUMA code become a no-op on !NUMA.
> 
If we do that, then slab.h needs a bit of reordering (as we can't use the
existing CONFIG_NUMA ifdefs that exist in slab.h, which the previous
patches built on), which makes the patch a bit more invasive.

Anyways, here's the patch that does that..

Signed-off-by: Paul Mundt <lethal@linux-sh.org>

--

 include/linux/slab.h |   54 ++++++++++++++++++++++++++++++++++++---------------
 mm/slob.c            |   51 ++++++++++++++++++++++++++++++++++--------------
 2 files changed, 76 insertions(+), 29 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index a015236..2eeca65 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -44,7 +44,6 @@ struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
 			void (*)(void *, struct kmem_cache *, unsigned long));
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
-void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
 void *kmem_cache_zalloc(struct kmem_cache *, gfp_t);
 void kmem_cache_free(struct kmem_cache *, void *);
 unsigned int kmem_cache_size(struct kmem_cache *);
@@ -63,9 +62,19 @@ int kmem_ptr_validate(struct kmem_cache *cachep, const void *ptr);
 		sizeof(struct __struct), __alignof__(struct __struct),\
 		(__flags), NULL, NULL)
 
-#ifdef CONFIG_NUMA
+#if defined(CONFIG_SLOB)
+extern void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
+
+static inline void *kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
+{
+	return kmem_cache_alloc_node(cachep, flags, -1);
+}
+#elif defined(CONFIG_NUMA)
+void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
 extern void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
 #else
+void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
+
 static inline void *kmem_cache_alloc_node(struct kmem_cache *cachep,
 					gfp_t flags, int node)
 {
@@ -91,7 +100,6 @@ static inline void *kmem_cache_alloc_node(struct kmem_cache *cachep,
 /*
  * Common kmalloc functions provided by all allocators
  */
-void *__kmalloc(size_t, gfp_t);
 void *__kzalloc(size_t, gfp_t);
 void * __must_check krealloc(const void *, size_t, gfp_t);
 void kfree(const void *);
@@ -110,6 +118,34 @@ static inline void *kcalloc(size_t n, size_t size, gfp_t flags)
 	return __kzalloc(n * size, flags);
 }
 
+#if defined(CONFIG_SLOB)
+extern void *__kmalloc_node(size_t size, gfp_t flags, int node);
+
+static inline void *kmalloc_node(size_t size, gfp_t flags, int node)
+{
+	return __kmalloc_node(size, flags, node);
+}
+
+static inline void *__kmalloc(size_t size, gfp_t flags)
+{
+	return __kmalloc_node(size, flags, -1);
+}
+#elif !defined(CONFIG_NUMA)
+void *__kmalloc(size_t, gfp_t);
+
+static inline void *kmalloc_node(size_t size, gfp_t flags, int node)
+{
+	return kmalloc(size, flags);
+}
+
+static inline void *__kmalloc_node(size_t size, gfp_t flags, int node)
+{
+	return __kmalloc(size, flags);
+}
+#else
+void *__kmalloc(size_t, gfp_t);
+#endif /* !CONFIG_NUMA */
+
 /*
  * Allocator specific definitions. These are mainly used to establish optimized
  * ways to convert kmalloc() calls to kmem_cache_alloc() invocations by selecting
@@ -190,18 +226,6 @@ static inline void *kzalloc(size_t size, gfp_t flags)
 }
 #endif
 
-#ifndef CONFIG_NUMA
-static inline void *kmalloc_node(size_t size, gfp_t flags, int node)
-{
-	return kmalloc(size, flags);
-}
-
-static inline void *__kmalloc_node(size_t size, gfp_t flags, int node)
-{
-	return __kmalloc(size, flags);
-}
-#endif /* !CONFIG_NUMA */
-
 /*
  * kmalloc_track_caller is a special version of kmalloc that records the
  * calling function of the routine calling it for slab leak tracking instead
diff --git a/mm/slob.c b/mm/slob.c
index 06e5e72..b08eca4 100644
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
@@ -405,7 +429,7 @@ void *__kmalloc(size_t size, gfp_t gfp)
 		return ret;
 	}
 }
-EXPORT_SYMBOL(__kmalloc);
+EXPORT_SYMBOL(__kmalloc_node);
 
 /**
  * krealloc - reallocate memory. The contents will remain unchanged.
@@ -455,7 +479,6 @@ void kfree(const void *block)
 	} else
 		put_page(&sp->page);
 }
-
 EXPORT_SYMBOL(kfree);
 
 /* can't use ksize for kmem_cache_alloc memory, only kmalloc */
@@ -487,7 +510,7 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size,
 {
 	struct kmem_cache *c;
 
-	c = slob_alloc(sizeof(struct kmem_cache), flags, 0);
+	c = slob_alloc(sizeof(struct kmem_cache), flags, 0, -1);
 
 	if (c) {
 		c->name = name;
@@ -517,21 +540,21 @@ void kmem_cache_destroy(struct kmem_cache *c)
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
-EXPORT_SYMBOL(kmem_cache_alloc);
+EXPORT_SYMBOL(kmem_cache_alloc_node);
 
 void *kmem_cache_zalloc(struct kmem_cache *c, gfp_t flags)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
