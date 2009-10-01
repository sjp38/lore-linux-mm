Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 78095600034
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 09:29:22 -0400 (EDT)
From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: [PATCH 24/31] mm: methods for teaching filesystems about PG_swapcache pages
Date: Thu,  1 Oct 2009 19:39:43 +0530
Message-Id: <1254406183-16519-1-git-send-email-sjayaraman@suse.de>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: netdev@vger.kernel.org, Neil Brown <neilb@suse.de>, Miklos Szeredi <mszeredi@suse.cz>, Wouter Verhelst <w@uter.be>, Peter Zijlstra <a.p.zijlstra@chello.nl>, trond.myklebust@fys.uio.no, Suresh Jayaraman <sjayaraman@suse.de>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl> 

In order to teach filesystems to handle swap cache pages, three new page
functions are introduced:

  pgoff_t page_file_index(struct page *);
  loff_t page_file_offset(struct page *);
  struct address_space *page_file_mapping(struct page *);

page_file_index() - gives the offset of this page in the file in
PAGE_CACHE_SIZE blocks. Like page->index is for mapped pages, this function
also gives the correct index for PG_swapcache pages.

page_file_offset() - uses page_file_index(), so that it will give the expected
result, even for PG_swapcache pages.

page_file_mapping() - gives the mapping backing the actual page; that is for
swap cache pages it will give swap_file->f_mapping.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
---
 include/linux/mm.h      |   25 +++++++++++++++++++++++++
 include/linux/pagemap.h |    5 +++++
 mm/swapfile.c           |   19 +++++++++++++++++++
 3 files changed, 49 insertions(+)

Index: mmotm/include/linux/mm.h
===================================================================
--- mmotm.orig/include/linux/mm.h
+++ mmotm/include/linux/mm.h
@@ -634,6 +634,17 @@ static inline struct address_space *page
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
@@ -650,6 +661,20 @@ static inline pgoff_t page_index(struct
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
Index: mmotm/include/linux/pagemap.h
===================================================================
--- mmotm.orig/include/linux/pagemap.h
+++ mmotm/include/linux/pagemap.h
@@ -279,6 +279,11 @@ static inline loff_t page_offset(struct
 	return ((loff_t)page->index) << PAGE_CACHE_SHIFT;
 }
 
+static inline loff_t page_file_offset(struct page *page)
+{
+	return ((loff_t)page_file_index(page)) << PAGE_CACHE_SHIFT;
+}
+
 static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
 					unsigned long address)
 {
Index: mmotm/mm/swapfile.c
===================================================================
--- mmotm.orig/mm/swapfile.c
+++ mmotm/mm/swapfile.c
@@ -2190,6 +2190,25 @@ struct swap_info_struct *page_swap_info(
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
