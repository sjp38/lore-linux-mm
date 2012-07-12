Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 076656B0093
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 02:41:15 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 03/12] mm: Methods for teaching filesystems about PG_swapcache pages
Date: Thu, 12 Jul 2012 07:40:57 +0100
Message-Id: <1342075266-29593-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1342075266-29593-1-git-send-email-mgorman@suse.de>
References: <1342075266-29593-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Sebastian Andrzej Siewior <sebastian@breakpoint.cc>, Mel Gorman <mgorman@suse.de>

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
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 include/linux/mm.h      |   25 +++++++++++++++++++++++++
 include/linux/pagemap.h |    5 +++++
 mm/swapfile.c           |   19 +++++++++++++++++++
 3 files changed, 49 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index a4549c6..b3d4cd9 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -805,6 +805,17 @@ static inline void *page_rmapping(struct page *page)
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
@@ -821,6 +832,20 @@ static inline pgoff_t page_index(struct page *page)
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
  * Return true if this page is mapped into pagetables.
  */
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 7cfad3b..e42c762 100644
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
index 64408be..f4e02bd 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -33,6 +33,7 @@
 #include <linux/oom.h>
 #include <linux/frontswap.h>
 #include <linux/swapfile.h>
+#include <linux/export.h>
 
 #include <asm/pgtable.h>
 #include <asm/tlbflush.h>
@@ -2299,6 +2300,24 @@ int swapcache_prepare(swp_entry_t entry)
 }
 
 /*
+ * out-of-line __page_file_ methods to avoid include hell.
+ */
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
  * add_swap_count_continuation - called when a swap count is duplicated
  * beyond SWAP_MAP_MAX, it allocates a new page and links that to the entry's
  * page of the original vmalloc'ed swap_map, to hold the continuation count
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
