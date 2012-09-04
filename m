Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 534A66B006C
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 06:14:13 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so1218749ghr.14
        for <linux-mm@kvack.org>; Tue, 04 Sep 2012 03:14:12 -0700 (PDT)
From: Ezequiel Garcia <elezegarcia@gmail.com>
Subject: [PATCH v2] mm, slob: Drop usage of page->private for storing page-sized allocations
Date: Tue,  4 Sep 2012 07:13:57 -0300
Message-Id: <1346753637-13389-1-git-send-email-elezegarcia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Ezequiel Garcia <elezegarcia@gmail.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Glauber Costa <glommer@parallels.com>

This field was being used to store size allocation so it could be
retrieved by ksize(). However, it is a bad practice to not mark a page
as a slab page and then use fields for special purposes.
There is no need to store the allocated size and
ksize() can simply return PAGE_SIZE << compound_order(page).

Cc: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@parallels.com>
Signed-off-by: Ezequiel Garcia <elezegarcia@gmail.com>
---
Changes from v1:
 * Rebased on top of slab/next

 mm/slob.c |   24 ++++++++++--------------
 1 files changed, 10 insertions(+), 14 deletions(-)

diff --git a/mm/slob.c b/mm/slob.c
index 45d4ca7..ae46edc 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -28,9 +28,8 @@
  * from kmalloc are prepended with a 4-byte header with the kmalloc size.
  * If kmalloc is asked for objects of PAGE_SIZE or larger, it calls
  * alloc_pages() directly, allocating compound pages so the page order
- * does not have to be separately tracked, and also stores the exact
- * allocation size in page->private so that it can be used to accurately
- * provide ksize(). These objects are detected in kfree() because slob_page()
+ * does not have to be separately tracked.
+ * These objects are detected in kfree() because PageSlab()
  * is false for them.
  *
  * SLAB is emulated on top of SLOB by simply calling constructors and
@@ -454,11 +453,6 @@ void *__kmalloc_node(size_t size, gfp_t gfp, int node)
 		if (likely(order))
 			gfp |= __GFP_COMP;
 		ret = slob_new_pages(gfp, order, node);
-		if (ret) {
-			struct page *page;
-			page = virt_to_page(ret);
-			page->private = size;
-		}
 
 		trace_kmalloc_node(_RET_IP_, ret,
 				   size, PAGE_SIZE << order, gfp, node);
@@ -493,18 +487,20 @@ EXPORT_SYMBOL(kfree);
 size_t ksize(const void *block)
 {
 	struct page *sp;
+	int align;
+	unsigned int *m;
 
 	BUG_ON(!block);
 	if (unlikely(block == ZERO_SIZE_PTR))
 		return 0;
 
 	sp = virt_to_page(block);
-	if (PageSlab(sp)) {
-		int align = max(ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
-		unsigned int *m = (unsigned int *)(block - align);
-		return SLOB_UNITS(*m) * SLOB_UNIT;
-	} else
-		return sp->private;
+	if (unlikely(!PageSlab(sp)))
+		return PAGE_SIZE << compound_order(sp);
+
+	align = max(ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
+	m = (unsigned int *)(block - align);
+	return SLOB_UNITS(*m) * SLOB_UNIT;
 }
 EXPORT_SYMBOL(ksize);
 
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
