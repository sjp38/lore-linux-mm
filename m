Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 781C16B00E9
	for <linux-mm@kvack.org>; Wed, 23 May 2012 16:35:08 -0400 (EDT)
Message-Id: <20120523203506.744566716@linux.com>
Date: Wed, 23 May 2012 15:34:36 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common 03/22] [slob] Remove various small accessors
References: <20120523203433.340661918@linux.com>
Content-Disposition: inline; filename=slob_inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

Those have become so simple that they are no longer needed.

signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slob.c |   49 +++++++++----------------------------------------
 1 file changed, 9 insertions(+), 40 deletions(-)

Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c	2012-05-22 09:05:55.024463914 -0500
+++ linux-2.6/mm/slob.c	2012-05-22 09:10:01.944458789 -0500
@@ -92,14 +92,6 @@ struct slob_block {
 typedef struct slob_block slob_t;
 
 /*
- * free_slob_page: call before a slob_page is returned to the page allocator.
- */
-static inline void free_slob_page(struct page *sp)
-{
-	reset_page_mapcount(sp);
-}
-
-/*
  * All partially free slob pages go on these lists.
  */
 #define SLOB_BREAK1 256
@@ -109,29 +101,6 @@ static LIST_HEAD(free_slob_medium);
 static LIST_HEAD(free_slob_large);
 
 /*
- * is_slob_page: True for all slob pages (false for bigblock pages)
- */
-static inline int is_slob_page(struct page *sp)
-{
-	return PageSlab(sp);
-}
-
-static inline void set_slob_page(struct page *sp)
-{
-	__SetPageSlab(sp);
-}
-
-static inline void clear_slob_page(struct page *sp)
-{
-	__ClearPageSlab(sp);
-}
-
-static inline struct page *slob_page(const void *addr)
-{
-	return virt_to_page(addr);
-}
-
-/*
  * slob_page_free: true for pages on free_slob_pages list.
  */
 static inline int slob_page_free(struct page *sp)
@@ -347,8 +316,8 @@ static void *slob_alloc(size_t size, gfp
 		b = slob_new_pages(gfp & ~__GFP_ZERO, 0, node);
 		if (!b)
 			return NULL;
-		sp = slob_page(b);
-		set_slob_page(sp);
+		sp = virt_to_page(b);
+		__SetPageSlab(sp);
 
 		spin_lock_irqsave(&slob_lock, flags);
 		sp->units = SLOB_UNITS(PAGE_SIZE);
@@ -380,7 +349,7 @@ static void slob_free(void *block, int s
 		return;
 	BUG_ON(!size);
 
-	sp = slob_page(block);
+	sp = virt_to_page(block);
 	units = SLOB_UNITS(size);
 
 	spin_lock_irqsave(&slob_lock, flags);
@@ -390,8 +359,8 @@ static void slob_free(void *block, int s
 		if (slob_page_free(sp))
 			clear_slob_page_free(sp);
 		spin_unlock_irqrestore(&slob_lock, flags);
-		clear_slob_page(sp);
-		free_slob_page(sp);
+		__ClearPageSlab(sp);
+		reset_page_mapcount(sp);
 		slob_free_pages(b, 0);
 		return;
 	}
@@ -508,8 +477,8 @@ void kfree(const void *block)
 		return;
 	kmemleak_free(block);
 
-	sp = slob_page(block);
-	if (is_slob_page(sp)) {
+	sp = virt_to_page(block);
+	if (PageSlab(sp)) {
 		int align = max(ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
 		unsigned int *m = (unsigned int *)(block - align);
 		slob_free(m, *m + align);
@@ -527,8 +496,8 @@ size_t ksize(const void *block)
 	if (unlikely(block == ZERO_SIZE_PTR))
 		return 0;
 
-	sp = slob_page(block);
-	if (is_slob_page(sp)) {
+	sp = virt_to_page(block);
+	if (PageSlab(sp)) {
 		int align = max(ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
 		unsigned int *m = (unsigned int *)(block - align);
 		return SLOB_UNITS(*m) * SLOB_UNIT;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
