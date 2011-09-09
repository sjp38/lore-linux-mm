Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CFDFF6B0250
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 07:01:05 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 05/10] mm: Methods for teaching filesystems about PG_swapcache pages
Date: Fri,  9 Sep 2011 12:00:49 +0100
Message-Id: <1315566054-17209-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1315566054-17209-1-git-send-email-mgorman@suse.de>
References: <1315566054-17209-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>

In order to teach filesystems to handle swap cache pages, three new
page functions are introduced:

  pgoff_t page_file_index(struct page *);
  loff_t page_file_offset(struct page *);
  struct address_space *page_file_mapping(struct page *);

page_file_index() - gives the offset of this page in the file in
PAGE_CACHE_SIZE blocks. Like page->index is for mapped pages, this
function also gives the correct index for PG_swapcache pages.

page_file_offset() - uses page_file_index(), so that it will give
the expected result, even for PG_swapcache pages.

page_file_mapping() - gives the mapping backing the actual page;
that is for swap cache pages it will give swap_file->f_mapping.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mm.h      |   25 +++++++++++++++++++++++++
 include/linux/pagemap.h |    5 +++++
 mm/swapfile.c           |   19 +++++++++++++++++++
 3 files changed, 49 insertions(+), 0 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7438071..45442a8 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -787,6 +787,17 @@ static inline void *page_rmapping(struct page *page)
 	return (void *)((unsigned long)page->mapping & ~PAGE_MAPPING_FLAGS);
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
@@ -803,6 +814,20 @@ static inline pgoff_t page_index(struct page *page)
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
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index cfaaa69..d4d4bda 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -286,6 +286,11 @@ static inline loff_t page_offset(struct page *page)
 	return ((loff_t)page->index) << PAGE_CACHE_SHIFT;
 }
 
+static inline loff_t page_file_offset(struct page *page)
+{
+	return ((loff_t)page_file_index(page)) << PAGE_CACHE_SHIFT;
+}
+
 extern pgoff_t linear_hugepage_index(struct vm_area_struct *vma,
 				     unsigned long address);
 
diff --git a/mm/swapfile.c b/mm/swapfile.c
index c49cb33..806b994 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2232,6 +2232,25 @@ struct swap_info_struct *page_swap_info(struct page *page)
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
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
