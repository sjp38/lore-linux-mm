Message-Id: <20071129011145.414062339@sgi.com>
References: <20071129011052.866354847@sgi.com>
Date: Wed, 28 Nov 2007 17:10:57 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 05/19] Use page_cache_xxx in mm/rmap.c
Content-Disposition: inline; filename=0006-Use-page_cache_xxx-in-mm-rmap.c.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, David Chinner <dgc@sgi.com>, Jens Axboe <jens.axboe@oracle.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, Fengguang Wu <fengguang.wu@gmail.com>, swin wang <wangswin@gmail.com>, totty.lu@gmail.com, hugh@veritas.com, joern@lazybastard.org
List-ID: <linux-mm.kvack.org>

Use page_cache_xxx in mm/rmap.c

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 mm/rmap.c |   13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

Index: mm/mm/rmap.c
===================================================================
--- mm.orig/mm/rmap.c	2007-11-28 12:27:32.312059099 -0800
+++ mm/mm/rmap.c	2007-11-28 14:10:42.758227810 -0800
@@ -190,9 +190,14 @@ static void page_unlock_anon_vma(struct 
 static inline unsigned long
 vma_address(struct page *page, struct vm_area_struct *vma)
 {
-	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	pgoff_t pgoff;
 	unsigned long address;
 
+	if (PageAnon(page))
+		pgoff = page->index;
+	else
+		pgoff = page->index << mapping_order(page->mapping);
+
 	address = vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
 	if (unlikely(address < vma->vm_start || address >= vma->vm_end)) {
 		/* page should be within @vma mapping range */
@@ -345,7 +350,7 @@ static int page_referenced_file(struct p
 {
 	unsigned int mapcount;
 	struct address_space *mapping = page->mapping;
-	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	pgoff_t pgoff = page->index << (page_cache_shift(mapping) - PAGE_SHIFT);
 	struct vm_area_struct *vma;
 	struct prio_tree_iter iter;
 	int referenced = 0;
@@ -464,7 +469,7 @@ out:
 
 static int page_mkclean_file(struct address_space *mapping, struct page *page)
 {
-	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	pgoff_t pgoff = page->index << (page_cache_shift(mapping) - PAGE_SHIFT);
 	struct vm_area_struct *vma;
 	struct prio_tree_iter iter;
 	int ret = 0;
@@ -897,7 +902,7 @@ static int try_to_unmap_anon(struct page
 static int try_to_unmap_file(struct page *page, int migration)
 {
 	struct address_space *mapping = page->mapping;
-	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	pgoff_t pgoff = page->index << (page_cache_shift(mapping) - PAGE_SHIFT);
 	struct vm_area_struct *vma;
 	struct prio_tree_iter iter;
 	int ret = SWAP_AGAIN;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
