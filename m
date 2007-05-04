Message-Id: <20070504103201.055800212@chello.nl>
References: <20070504102651.923946304@chello.nl>
Date: Fri, 04 May 2007 12:27:15 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 24/40] mm: methods for teaching filesystems about PG_swapcache pages
Content-Disposition: inline; filename=mm-page_file_methods.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, James Bottomley <James.Bottomley@SteelEye.com>, Mike Christie <michaelc@cs.wisc.edu>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>
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
CC: Trond Myklebust <trond.myklebust@fys.uio.no>
---
 include/linux/mm.h      |   25 +++++++++++++++++++++++++
 include/linux/pagemap.h |    2 +-
 2 files changed, 26 insertions(+), 1 deletion(-)

Index: linux-2.6-git/include/linux/mm.h
===================================================================
--- linux-2.6-git.orig/include/linux/mm.h	2007-02-21 12:15:01.000000000 +0100
+++ linux-2.6-git/include/linux/mm.h	2007-02-21 12:15:07.000000000 +0100
@@ -594,6 +594,16 @@ static inline struct swap_info_struct *p
 	return get_swap_info_struct(swp_type(swap));
 }
 
+static inline
+struct address_space *page_file_mapping(struct page *page)
+{
+#ifdef CONFIG_SWAP_FILE
+	if (unlikely(PageSwapCache(page)))
+		return page_swap_info(page)->swap_file->f_mapping;
+#endif
+	return page->mapping;
+}
+
 static inline int PageAnon(struct page *page)
 {
 	return ((unsigned long)page->mapping & PAGE_MAPPING_ANON) != 0;
@@ -611,6 +621,21 @@ static inline pgoff_t page_index(struct 
 }
 
 /*
+ * Return the file index of the page. Regular pagecache pages use ->index
+ * whereas swapcache pages use swp_offset(->private)
+ */
+static inline pgoff_t page_file_index(struct page *page)
+{
+#ifdef CONFIG_SWAP_FILE
+	if (unlikely(PageSwapCache(page))) {
+		swp_entry_t swap = { .val = page_private(page) };
+		return swp_offset(swap);
+	}
+#endif
+	return page->index;
+}
+
+/*
  * The atomic page->_mapcount, like _count, starts from -1:
  * so that transitions both from it and to it can be tracked,
  * using atomic_inc_and_test and atomic_add_negative(-1).
Index: linux-2.6-git/include/linux/pagemap.h
===================================================================
--- linux-2.6-git.orig/include/linux/pagemap.h	2007-02-21 12:14:54.000000000 +0100
+++ linux-2.6-git/include/linux/pagemap.h	2007-02-21 12:15:07.000000000 +0100
@@ -120,7 +120,7 @@ extern void __remove_from_page_cache(str
  */
 static inline loff_t page_offset(struct page *page)
 {
-	return ((loff_t)page->index) << PAGE_CACHE_SHIFT;
+	return ((loff_t)page_file_index(page)) << PAGE_CACHE_SHIFT;
 }
 
 static inline pgoff_t linear_page_index(struct vm_area_struct *vma,

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
