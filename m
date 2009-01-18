Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2B3706B009F
	for <linux-mm@kvack.org>; Sun, 18 Jan 2009 13:01:04 -0500 (EST)
Received: by ti-out-0910.google.com with SMTP id j3so1511269tid.8
        for <linux-mm@kvack.org>; Sun, 18 Jan 2009 10:00:52 -0800 (PST)
Date: Mon, 19 Jan 2009 02:00:38 +0800
From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: [Patch] slob: clean up the code
Message-ID: <20090118180038.GB3292@hack.private>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: cl@linux-foundation.org, penberg@cs.helsinki.fi, linux-mm@kvack.org, mpm@selenic.com, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>


- Use NULL instead of plain 0;
- Rename slob_page() to is_slob_page();
- Define slob_page() to convert void* to struct slob_page*;
- Rename slob_new_page() to slob_new_pages();
- Define slob_free_pages() accordingly.

Compile tests only.

Signed-off-by: WANG Cong <wangcong@zeuux.org>
Cc: Matt Mackall <mpm@selenic.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <cl@linux-foundation.org>

---
diff --git a/mm/slob.c b/mm/slob.c
index bf7e8fc..c9cd31d 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -126,9 +126,9 @@ static LIST_HEAD(free_slob_medium);
 static LIST_HEAD(free_slob_large);
 
 /*
- * slob_page: True for all slob pages (false for bigblock pages)
+ * is_slob_page: True for all slob pages (false for bigblock pages)
  */
-static inline int slob_page(struct slob_page *sp)
+static inline int is_slob_page(struct slob_page *sp)
 {
 	return PageSlobPage((struct page *)sp);
 }
@@ -143,6 +143,11 @@ static inline void clear_slob_page(struct slob_page *sp)
 	__ClearPageSlobPage((struct page *)sp);
 }
 
+static inline struct slob_page *slob_page(const void *addr)
+{
+	return (struct slob_page *)virt_to_page(addr);
+}
+
 /*
  * slob_page_free: true for pages on free_slob_pages list.
  */
@@ -230,7 +235,7 @@ static int slob_last(slob_t *s)
 	return !((unsigned long)slob_next(s) & ~PAGE_MASK);
 }
 
-static void *slob_new_page(gfp_t gfp, int order, int node)
+static void *slob_new_pages(gfp_t gfp, int order, int node)
 {
 	void *page;
 
@@ -247,12 +252,17 @@ static void *slob_new_page(gfp_t gfp, int order, int node)
 	return page_address(page);
 }
 
+static void slob_free_pages(void *b, int order)
+{
+	free_pages((unsigned long)b, order);
+}
+
 /*
  * Allocate a slob block within a given slob_page sp.
  */
 static void *slob_page_alloc(struct slob_page *sp, size_t size, int align)
 {
-	slob_t *prev, *cur, *aligned = 0;
+	slob_t *prev, *cur, *aligned = NULL;
 	int delta = 0, units = SLOB_UNITS(size);
 
 	for (prev = NULL, cur = sp->free; ; prev = cur, cur = slob_next(cur)) {
@@ -349,10 +359,10 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 
 	/* Not enough space: must allocate a new page */
 	if (!b) {
-		b = slob_new_page(gfp & ~__GFP_ZERO, 0, node);
+		b = slob_new_pages(gfp & ~__GFP_ZERO, 0, node);
 		if (!b)
-			return 0;
-		sp = (struct slob_page *)virt_to_page(b);
+			return NULL;
+		sp = slob_page(b);
 		set_slob_page(sp);
 
 		spin_lock_irqsave(&slob_lock, flags);
@@ -384,7 +394,7 @@ static void slob_free(void *block, int size)
 		return;
 	BUG_ON(!size);
 
-	sp = (struct slob_page *)virt_to_page(block);
+	sp = slob_page(block);
 	units = SLOB_UNITS(size);
 
 	spin_lock_irqsave(&slob_lock, flags);
@@ -476,7 +486,7 @@ void *__kmalloc_node(size_t size, gfp_t gfp, int node)
 	} else {
 		void *ret;
 
-		ret = slob_new_page(gfp | __GFP_COMP, get_order(size), node);
+		ret = slob_new_pages(gfp | __GFP_COMP, get_order(size), node);
 		if (ret) {
 			struct page *page;
 			page = virt_to_page(ret);
@@ -494,8 +504,8 @@ void kfree(const void *block)
 	if (unlikely(ZERO_OR_NULL_PTR(block)))
 		return;
 
-	sp = (struct slob_page *)virt_to_page(block);
-	if (slob_page(sp)) {
+	sp = slob_page(block);
+	if (is_slob_page(sp)) {
 		int align = max(ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
 		unsigned int *m = (unsigned int *)(block - align);
 		slob_free(m, *m + align);
@@ -513,8 +523,8 @@ size_t ksize(const void *block)
 	if (unlikely(block == ZERO_SIZE_PTR))
 		return 0;
 
-	sp = (struct slob_page *)virt_to_page(block);
-	if (slob_page(sp)) {
+	sp = slob_page(block);
+	if (is_slob_page(sp)) {
 		int align = max(ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
 		unsigned int *m = (unsigned int *)(block - align);
 		return SLOB_UNITS(*m) * SLOB_UNIT;
@@ -572,7 +582,7 @@ void *kmem_cache_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
 	if (c->size < PAGE_SIZE)
 		b = slob_alloc(c->size, flags, c->align, node);
 	else
-		b = slob_new_page(flags, get_order(c->size), node);
+		b = slob_new_pages(flags, get_order(c->size), node);
 
 	if (c->ctor)
 		c->ctor(b);
@@ -586,7 +596,7 @@ static void __kmem_cache_free(void *b, int size)
 	if (size < PAGE_SIZE)
 		slob_free(b, size);
 	else
-		free_pages((unsigned long)b, get_order(size));
+		slob_free_pages(b, get_order(size));
 }
 
 static void kmem_rcu_free(struct rcu_head *head)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
