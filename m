Message-Id: <20080216004806.641868389@sgi.com>
References: <20080216004718.047808297@sgi.com>
Date: Fri, 15 Feb 2008 16:47:23 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 05/18] Use page_cache_xxx in mm/rmap.c
Content-Disposition: inline; filename=0006-Use-page_cache_xxx-in-mm-rmap.c.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, David Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

- vma_address(): Check for truncation if this is a file based page.
	return -EFAULT if truncation occurred.
- page_referenced_file(): Only use mapping after we have made sure
  that the mapping is valid and the page is locked.

Use page_cache_xxx in mm/rmap.c

Reviewed-by: Dave Chinner <dgc@sgi.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 mm/rmap.c |   23 +++++++++++++++++++----
 1 file changed, 19 insertions(+), 4 deletions(-)

Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c	2008-02-14 15:20:25.574017171 -0800
+++ linux-2.6/mm/rmap.c	2008-02-15 16:14:40.016907160 -0800
@@ -190,9 +190,21 @@ static void page_unlock_anon_vma(struct 
 static inline unsigned long
 vma_address(struct page *page, struct vm_area_struct *vma)
 {
-	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	pgoff_t pgoff;
 	unsigned long address;
 
+	if (PageAnon(page))
+		pgoff = page->index;
+	else {
+		struct address_space *mapping = page->mapping;
+
+		if (!mapping)
+			/* Page was truncated */
+			return -EFAULT;
+
+		pgoff = page->index << mapping_order(mapping);
+	}
+
 	address = vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
 	if (unlikely(address < vma->vm_start || address >= vma->vm_end)) {
 		/* page should be within @vma mapping range */
@@ -348,7 +360,7 @@ static int page_referenced_file(struct p
 {
 	unsigned int mapcount;
 	struct address_space *mapping = page->mapping;
-	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	pgoff_t pgoff;
 	struct vm_area_struct *vma;
 	struct prio_tree_iter iter;
 	int referenced = 0;
@@ -368,6 +380,9 @@ static int page_referenced_file(struct p
 	 */
 	BUG_ON(!PageLocked(page));
 
+	/* Safe to use mapping */
+	pgoff = page->index << mapping_order(mapping);
+
 	spin_lock(&mapping->i_mmap_lock);
 
 	/*
@@ -468,7 +483,7 @@ out:
 
 static int page_mkclean_file(struct address_space *mapping, struct page *page)
 {
-	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	pgoff_t pgoff = page->index << mapping_order(mapping);
 	struct vm_area_struct *vma;
 	struct prio_tree_iter iter;
 	int ret = 0;
@@ -899,7 +914,7 @@ static int try_to_unmap_anon(struct page
 static int try_to_unmap_file(struct page *page, int migration)
 {
 	struct address_space *mapping = page->mapping;
-	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	pgoff_t pgoff = page->index << mapping_order(mapping);
 	struct vm_area_struct *vma;
 	struct prio_tree_iter iter;
 	int ret = SWAP_AGAIN;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
