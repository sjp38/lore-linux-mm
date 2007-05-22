Date: Tue, 22 May 2007 09:39:58 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 2/3] slob: remove bigblock tracking
Message-ID: <20070522073958.GE17051@wotan.suse.de>
References: <20070522073910.GD17051@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070522073910.GD17051@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Remove the bigblock lists in favour of using compound pages and going
directly to the page allocator. Allocation size is stored in page->private,
which also makes ksize more accurate than it previously was.

Saves ~.5K of code, and 12-24 bytes overhead per >= PAGE_SIZE allocation.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---

Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c
+++ linux-2.6/mm/slob.c
@@ -18,9 +18,11 @@
  * Above this is an implementation of kmalloc/kfree. Blocks returned
  * from kmalloc are 4-byte aligned and prepended with a 4-byte header.
  * If kmalloc is asked for objects of PAGE_SIZE or larger, it calls
- * __get_free_pages directly so that it can return page-aligned blocks
- * and keeps a linked list of such pages and their orders. These
- * objects are detected in kfree() by their page alignment.
+ * __get_free_pages directly, allocating compound pages so the page order
+ * does not have to be separately tracked, and also stores the exact
+ * allocation size in page->private so that it can be used to accurately
+ * provide ksize(). These objects are detected in kfree() because slob_page()
+ * is false for them.
  *
  * SLAB is emulated on top of SLOB by simply calling constructors and
  * destructors for every SLAB allocation. Objects are returned with the
@@ -29,7 +31,8 @@
  * alignment. Again, objects of page-size or greater are allocated by
  * calling __get_free_pages. As SLAB objects know their size, no separate
  * size bookkeeping is necessary and there is essentially no allocation
- * space overhead.
+ * space overhead, and compound pages aren't needed for multi-page
+ * allocations.
  */
 
 #include <linux/kernel.h>
@@ -381,48 +384,26 @@ out:
  * End of slob allocator proper. Begin kmem_cache_alloc and kmalloc frontend.
  */
 
-struct bigblock {
-	int order;
-	void *pages;
-	struct bigblock *next;
-};
-typedef struct bigblock bigblock_t;
-
-static bigblock_t *bigblocks;
-
-static DEFINE_SPINLOCK(block_lock);
-
-
 void *__kmalloc(size_t size, gfp_t gfp)
 {
-	slob_t *m;
-	bigblock_t *bb;
-	unsigned long flags;
-
 	if (size < PAGE_SIZE - SLOB_UNIT) {
+		slob_t *m;
 		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
 		if (m)
 			m->units = size;
 		return m+1;
-	}
-
-	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
-	if (!bb)
-		return 0;
-
-	bb->order = get_order(size);
-	bb->pages = (void *)__get_free_pages(gfp, bb->order);
+	} else {
+		void *ret;
 
-	if (bb->pages) {
-		spin_lock_irqsave(&block_lock, flags);
-		bb->next = bigblocks;
-		bigblocks = bb;
-		spin_unlock_irqrestore(&block_lock, flags);
-		return bb->pages;
+		ret = (void *) __get_free_pages(gfp | __GFP_COMP,
+						get_order(size));
+		if (ret) {
+			struct page *page;
+			page = virt_to_page(ret);
+			page->private = size;
+		}
+		return ret;
 	}
-
-	slob_free(bb, sizeof(bigblock_t));
-	return 0;
 }
 EXPORT_SYMBOL(__kmalloc);
 
@@ -462,59 +443,33 @@ EXPORT_SYMBOL(krealloc);
 void kfree(const void *block)
 {
 	struct slob_page *sp;
-	slob_t *m;
-	bigblock_t *bb, **last = &bigblocks;
-	unsigned long flags;
 
 	if (!block)
 		return;
 
 	sp = (struct slob_page *)virt_to_page(block);
-	if (!slob_page(sp)) {
-		/* on the big block list */
-		spin_lock_irqsave(&block_lock, flags);
-		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
-			if (bb->pages == block) {
-				*last = bb->next;
-				spin_unlock_irqrestore(&block_lock, flags);
-				free_pages((unsigned long)block, bb->order);
-				slob_free(bb, sizeof(bigblock_t));
-				return;
-			}
-		}
-		spin_unlock_irqrestore(&block_lock, flags);
-		WARN_ON(1);
-		return;
-	}
-
-	m = (slob_t *)block - 1;
-	slob_free(m, m->units + SLOB_UNIT);
-	return;
+	if (slob_page(sp)) {
+		slob_t *m = (slob_t *)block - 1;
+		slob_free(m, m->units + SLOB_UNIT);
+	} else
+		put_page(&sp->page);
 }
 
 EXPORT_SYMBOL(kfree);
 
+/* can't use ksize for kmem_cache_alloc memory, only kmalloc */
 size_t ksize(const void *block)
 {
 	struct slob_page *sp;
-	bigblock_t *bb;
-	unsigned long flags;
 
 	if (!block)
 		return 0;
 
 	sp = (struct slob_page *)virt_to_page(block);
-	if (!slob_page(sp)) {
-		spin_lock_irqsave(&block_lock, flags);
-		for (bb = bigblocks; bb; bb = bb->next)
-			if (bb->pages == block) {
-				spin_unlock_irqrestore(&slob_lock, flags);
-				return PAGE_SIZE << bb->order;
-			}
-		spin_unlock_irqrestore(&block_lock, flags);
-	}
-
-	return ((slob_t *)block - 1)->units + SLOB_UNIT;
+	if (slob_page(sp))
+		return ((slob_t *)block - 1)->units + SLOB_UNIT;
+	else
+		return sp->page.private;
 }
 
 struct kmem_cache {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
