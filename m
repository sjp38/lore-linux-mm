Date: Tue, 12 Jun 2007 18:43:59 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH] numa: mempolicy: dynamic interleave map for system init.
Message-ID: <20070612094359.GA5803@linux-sh.org>
References: <20070607011701.GA14211@linux-sh.org> <20070607180108.0eeca877.akpm@linux-foundation.org> <Pine.LNX.4.64.0706071942240.26636@schroedinger.engr.sgi.com> <20070608032505.GA13227@linux-sh.org> <20070608145011.GE11115@waste.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070608145011.GE11115@waste.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, ak@suse.de, hugh@veritas.com, lee.schermerhorn@hp.com, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 08, 2007 at 09:50:11AM -0500, Matt Mackall wrote:
> SLOB's big scalability problem at this point is number of CPUs.
> Throwing some fine-grained locking at it or the like may be able to
> help with that too.
> 
> Why would you even want to bother making it scale that large? For
> starters, it's less affected by things like dcache fragmentation. The
> majority of pages pinned by long-lived dcache entries will still be
> available to other allocations.
> 
> Haven't given any thought to NUMA yet though..
> 
This is what I've hacked together and tested with my small nodes. It's
not terribly intelligent, and it pushes off most of the logic to the page
allocator. Obviously it's not terribly scalable, and I haven't tested it
with page migration, either. Still, it works for me with my simple tmpfs
+ mpol policy tests.

Tested on a UP + SPARSEMEM (static, not extreme) + NUMA (2 nodes) + SLOB
configuration.

Flame away!

Signed-off-by: Paul Mundt <lethal@linux-sh.org>

--

 include/linux/slab.h |    7 ++++
 mm/slob.c            |   80 ++++++++++++++++++++++++++++++++++++++++++---------
 2 files changed, 73 insertions(+), 14 deletions(-)

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
diff --git a/mm/slob.c b/mm/slob.c
index 71976c5..48af24c 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -74,7 +74,7 @@ static void slob_free(void *b, int size);
 static void slob_timer_cbk(void);
 
 
-static void *slob_alloc(size_t size, gfp_t gfp, int align)
+static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 {
 	slob_t *prev, *cur, *aligned = 0;
 	int delta = 0, units = SLOB_UNITS(size);
@@ -111,12 +111,19 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align)
 			return cur;
 		}
 		if (cur == slobfree) {
+			void *pages;
+
 			spin_unlock_irqrestore(&slob_lock, flags);
 
 			if (size == PAGE_SIZE) /* trying to shrink arena? */
 				return 0;
 
-			cur = (slob_t *)__get_free_page(gfp);
+			if (node == -1)
+				pages = alloc_pages(gfp, 0);
+			else
+				pages = alloc_pages_node(node, gfp, 0);
+
+			cur = page_address(pages);
 			if (!cur)
 				return 0;
 
@@ -161,23 +168,29 @@ static void slob_free(void *block, int size)
 	spin_unlock_irqrestore(&slob_lock, flags);
 }
 
-void *__kmalloc(size_t size, gfp_t gfp)
+static void *__kmalloc_alloc(size_t size, gfp_t gfp, int node)
 {
 	slob_t *m;
 	bigblock_t *bb;
 	unsigned long flags;
+	void *page;
 
 	if (size < PAGE_SIZE - SLOB_UNIT) {
-		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
+		m = slob_alloc(size + SLOB_UNIT, gfp, 0, node);
 		return m ? (void *)(m + 1) : 0;
 	}
 
-	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
+	bb = slob_alloc(sizeof(bigblock_t), gfp, 0, node);
 	if (!bb)
 		return 0;
 
 	bb->order = get_order(size);
-	bb->pages = (void *)__get_free_pages(gfp, bb->order);
+	if (node == -1)
+		page = alloc_pages(gfp, bb->order);
+	else
+		page = alloc_pages_node(node, gfp, bb->order);
+
+	bb->pages = page_address(page);
 
 	if (bb->pages) {
 		spin_lock_irqsave(&block_lock, flags);
@@ -190,8 +203,21 @@ void *__kmalloc(size_t size, gfp_t gfp)
 	slob_free(bb, sizeof(bigblock_t));
 	return 0;
 }
+
+void *__kmalloc(size_t size, gfp_t gfp)
+{
+	return __kmalloc_alloc(size, gfp, -1);
+}
 EXPORT_SYMBOL(__kmalloc);
 
+#ifdef CONFIG_NUMA
+void *__kmalloc_node(size_t size, gfp_t gfp, int node)
+{
+	return __kmalloc_alloc(size, gfp, node);
+}
+EXPORT_SYMBOL(__kmalloc_node);
+#endif
+
 /**
  * krealloc - reallocate memory. The contents will remain unchanged.
  *
@@ -289,7 +315,7 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size,
 {
 	struct kmem_cache *c;
 
-	c = slob_alloc(sizeof(struct kmem_cache), flags, 0);
+	c = slob_alloc(sizeof(struct kmem_cache), flags, 0, -1);
 
 	if (c) {
 		c->name = name;
@@ -317,22 +343,44 @@ void kmem_cache_destroy(struct kmem_cache *c)
 }
 EXPORT_SYMBOL(kmem_cache_destroy);
 
-void *kmem_cache_alloc(struct kmem_cache *c, gfp_t flags)
+static void *__kmem_cache_alloc(struct kmem_cache *c, gfp_t flags, int node)
 {
 	void *b;
 
 	if (c->size < PAGE_SIZE)
-		b = slob_alloc(c->size, flags, c->align);
-	else
-		b = (void *)__get_free_pages(flags, get_order(c->size));
+		b = slob_alloc(c->size, flags, c->align, node);
+	else {
+		void *pages;
+
+		if (node == -1)
+			pages = alloc_pages(flags, get_order(c->size));
+		else
+			pages = alloc_pages_node(node, flags,
+						get_order(c->size));
+
+		b = page_address(pages);
+	}
 
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
@@ -406,10 +454,14 @@ void __init kmem_cache_init(void)
 
 static void slob_timer_cbk(void)
 {
-	void *p = slob_alloc(PAGE_SIZE, 0, PAGE_SIZE-1);
+	int node;
+
+	for_each_online_node(node) {
+		void *p = slob_alloc(PAGE_SIZE, 0, PAGE_SIZE-1, node);
 
-	if (p)
-		free_page((unsigned long)p);
+		if (p)
+			free_page((unsigned long)p);
+	}
 
 	mod_timer(&slob_timer, jiffies + HZ);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
