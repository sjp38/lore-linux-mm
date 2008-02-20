Message-Id: <20080220150308.230961000@chello.nl>
References: <20080220144610.548202000@chello.nl>
Date: Wed, 20 Feb 2008 15:46:33 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 23/28] mm: methods for teaching filesystems about PG_swapcache pages
Content-Disposition: inline; filename=mm-page_file_methods.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

In order to teach filesystems to handle swap cache pages, two new page
functions are introduced:

  pgoff_t page_file_index(struct page *);
  struct address_space *page_file_mapping(struct page *);

page_file_index - gives the offset of this page in the file in PAGE_CACHE_SIZE
blocks. Like page->index is for mapped pages, this function also gives the
correct index for PG_swapcache pages.

page_file_mapping - gives the mapping backing the actual page; that is for
swap cache pages it will give swap_file->f_mapping.

page_offset() is modified to use page_file_index(), so that it will give the
expected result, even for PG_swapcache pages.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/mm.h      |   25 +++++++++++++++++++++++++
 include/linux/pagemap.h |    2 +-
 mm/swapfile.c           |   19 +++++++++++++++++++
 3 files changed, 45 insertions(+), 1 deletion(-)

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -600,6 +600,17 @@ static inline struct address_space *page
 	return mapping;
 }
 
+extern struct address_space *__page_file_mapping(struct page *);
+
+static inline
+struct address_space *page_file_mapping(struct page *page)
+{
+	if (unlikely(PageSwapCache(page)))
+		return __page_file_mapping(page);
+
+	return page->mapping;
+}
+
 static inline int PageAnon(struct page *page)
 {
 	return ((unsigned long)page->mapping & PAGE_MAPPING_ANON) != 0;
@@ -616,6 +627,20 @@ static inline pgoff_t page_index(struct 
 	return page->index;
 }
 
+extern pgoff_t __page_file_index(struct page *page);
+
+/*
+ * Return the file index of the page. Regular pagecache pages use ->index
+ * whereas swapcache pages use swp_offset(->private)
+ */
+static inline pgoff_t page_file_index(struct page *page)
+{
+	if (unlikely(PageSwapCache(page)))
+		return __page_file_index(page);
+
+	return page->index;
+}
+
 /*
  * The atomic page->_mapcount, like _count, starts from -1:
  * so that transitions both from it and to it can be tracked,
Index: linux-2.6/include/linux/pagemap.h
===================================================================
--- linux-2.6.orig/include/linux/pagemap.h
+++ linux-2.6/include/linux/pagemap.h
@@ -145,7 +145,7 @@ extern void __remove_from_page_cache(str
  */
 static inline loff_t page_offset(struct page *page)
 {
-	return ((loff_t)page->index) << PAGE_CACHE_SHIFT;
+	return ((loff_t)page_file_index(page)) << PAGE_CACHE_SHIFT;
 }
 
 static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
Index: linux-2.6/mm/swapfile.c
===================================================================
--- linux-2.6.orig/mm/swapfile.c
+++ linux-2.6/mm/swapfile.c
@@ -1818,6 +1818,25 @@ struct swap_info_struct *page_swap_info(
 }
 
 /*
+ * out-of-line __page_file_ methods to avoid include hell.
+ */
+
+struct address_space *__page_file_mapping(struct page *page)
+{
+	VM_BUG_ON(!PageSwapCache(page));
+	return page_swap_info(page)->swap_file->f_mapping;
+}
+EXPORT_SYMBOL_GPL(__page_file_mapping);
+
+pgoff_t __page_file_index(struct page *page)
+{
+	swp_entry_t swap = { .val = page_private(page) };
+	VM_BUG_ON(!PageSwapCache(page));
+	return swp_offset(swap);
+}
+EXPORT_SYMBOL_GPL(__page_file_index);
+
+/*
  * swap_lock prevents swap_map being freed. Don't grab an extra
  * reference on the swaphandle, it doesn't matter if it becomes unused.
  */

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
