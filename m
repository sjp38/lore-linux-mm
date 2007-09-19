Date: Wed, 19 Sep 2007 16:43:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] page->mapping clarification [1/3] base functions
Message-Id: <20070919164308.281f9960.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, ricknu-0@student.ltu.se, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Rebased to 2.6.23-rc6-mm1 and reflected comments.
Not so aggresive as previous version.
(I'm not in a hurry if -mm is busy.)

Any comments are welcome.

Thanks,
-Kame
==
A clarification of page <-> fs interface (page cache).

At first, each FS has to access to struct page->mapping directly.
But it's not just pointer. (we use special 1bit enconding for anon.)

Although there is historical consensus that page->mapping points to its inode's
address space, I think adding some neat helper functon is not bad.

This patch adds page-cache.h which containes page<->address_space<->inode
function which is required (used) by subsystems.

Following functions are added

 * page_mapping_cache() ... returns address space if a page is page cache
 * page_mapping_anon()  ... returns anon_vma if a page is anonymous page.
 * page_is_pagecache()  ... returns true if a page is page-cache.
 * page_inode()         ... returns inode which a page-cache belongs to.
 * is_page_consistent() ... returns true if a page is still valid page cache 

Followings are moved 
 * page_mapping()       ... returns swapper_space or address_space a page is on.
			    (from mm.h)
 * page_index()         ... returns position of a page in its inode
			    (from mm.h)
 * remove_mapping()     ... a safe routine to remove page->mapping from page.
			    (from swap.h)

Changelog V1 -> V2:
 - for 2.6.23-rc6-mm1.
 - use bool type.
 - moved related functions to page-cache.h
 - renamed some functions.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 include/linux/fs.h         |    6 +-
 include/linux/mm.h         |   40 ---------------
 include/linux/page-cache.h |  118 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/swap.h       |    1 
 4 files changed, 123 insertions(+), 42 deletions(-)

Index: linux-2.6.23-rc6-mm1/include/linux/page-cache.h
===================================================================
--- /dev/null
+++ linux-2.6.23-rc6-mm1/include/linux/page-cache.h
@@ -0,0 +1,118 @@
+#ifndef _LINUX_PAGE_CACHE_H
+#define _LINUX_PAGE_CACHE_H
+#ifdef __KERNEL__
+
+#include <linux/mm.h>
+#include <linux/fs.h>
+#include <linux/rmap.h>
+/*
+ * This file defines interface function among page-cache and FS.
+ *
+ * page_mapping()       ... returns swapper_space or address_space a page is on.
+ *                          Will be used by routines walks by LRU.
+ * page_mapping_cache() ... returns address space if a page is page cache
+ *                          Will be used by FS.
+ * page_mapping_anon()  ... returns anon_vma if a page is anonymous page.
+ *                          Will be used by VM subsystem
+ * page_is_pagecache()  ... returns true if a page is page-cache.
+ * page_inode()         ... returns inode which a page-cache belongs to.
+ * page_index()         ... returns position of a page in its inode
+ * is_page_consistent() ... returns true if a page is still valid on specified
+ *                          address space.
+ * remove_mapping()     ... a safe routine to remove page->mapping from page.
+ */
+extern  struct address_space swapper_space;
+
+/*
+ * On an anonymous page mapped into a user virtual memory area,
+ * page->mapping points to its anon_vma, not to a struct address_space;
+ * with the PAGE_MAPPING_ANON bit set to distinguish it.
+ *
+ * Please note that, confusingly, "page_mapping" refers to the inode
+ * address_space which maps the page from disk; whereas "page_mapped"
+ * refers to user virtual address space into which the page is mapped.
+ */
+#define PAGE_MAPPING_ANON       1
+
+static inline bool PageAnon(struct page *page)
+{
+	return (((unsigned long)page->mapping & PAGE_MAPPING_ANON) != 0);
+}
+
+static inline struct anon_vma *page_mapping_anon(struct page *page)
+{
+	if (!page->mapping || !PageAnon(page))
+		return NULL;
+	return (struct anon_vma *)
+		((unsigned long)page->mapping - PAGE_MAPPING_ANON);
+}
+
+static inline struct address_space *page_mapping_cache(struct page *page)
+{
+	if (!page->mapping || PageAnon(page))
+		return NULL;
+	return page->mapping;
+}
+
+/*
+ * Automatically detect 'what the page is' and returns address_space.
+ *
+ * If page is swap cache, returns &swapper_space.
+ * If page is page cache, returns inode's address space it belongs to
+ * If page is anon, returns NULL.
+ */
+
+static inline struct address_space *page_mapping(struct page *page)
+{
+	struct address_space *mapping = page->mapping;
+
+	VM_BUG_ON(PageSlab(page));
+	if (unlikely(PageSwapCache(page)))
+		mapping = &swapper_space;
+#ifdef CONFIG_SLUB
+	else if (unlikely(PageSlab(page)))
+		mapping = NULL;
+#endif
+        else if (unlikely((unsigned long)mapping & PAGE_MAPPING_ANON))
+		mapping = NULL;
+        return mapping;
+
+}
+
+static inline bool page_is_pagecache(struct page *page)
+{
+	return (page_mapping_cache(page) != NULL);
+}
+
+static inline struct inode *page_inode(struct page *page)
+{
+	if (!page_is_pagecache(page))
+		return NULL;
+	return page_mapping_cache(page)->host;
+}
+/*
+ * Return the pagecache index of the passed page.  Regular pagecache pages
+ * use ->index whereas swapcache pages use ->private
+ */
+static inline pgoff_t page_index(struct page *page)
+{
+	if (unlikely(PageSwapCache(page)))
+		return page_private(page);
+	return page->index;
+}
+
+/*
+ * Returns true if a page is belongs to mapping.
+ */
+static inline bool
+is_page_consistent(struct page *page, struct address_space *mapping)
+{
+	struct address_space *check = page_mapping_cache(page);
+	return (check == mapping);
+}
+
+/* defined in mm/vmscan.c. Must be called under lock_page(). */
+extern int remove_mapping(struct address_space *mapping, struct page *page);
+
+#endif /* __KERNEL__ */
+#endif /* _LINUX_PAGE_CACHE_H */
Index: linux-2.6.23-rc6-mm1/include/linux/mm.h
===================================================================
--- linux-2.6.23-rc6-mm1.orig/include/linux/mm.h
+++ linux-2.6.23-rc6-mm1/include/linux/mm.h
@@ -550,46 +550,6 @@ void page_address_init(void);
 #endif
 
 /*
- * On an anonymous page mapped into a user virtual memory area,
- * page->mapping points to its anon_vma, not to a struct address_space;
- * with the PAGE_MAPPING_ANON bit set to distinguish it.
- *
- * Please note that, confusingly, "page_mapping" refers to the inode
- * address_space which maps the page from disk; whereas "page_mapped"
- * refers to user virtual address space into which the page is mapped.
- */
-#define PAGE_MAPPING_ANON	1
-
-extern struct address_space swapper_space;
-static inline struct address_space *page_mapping(struct page *page)
-{
-	struct address_space *mapping = page->mapping;
-
-	VM_BUG_ON(PageSlab(page));
-	if (unlikely(PageSwapCache(page)))
-		mapping = &swapper_space;
-	else if (unlikely((unsigned long)mapping & PAGE_MAPPING_ANON))
-		mapping = NULL;
-	return mapping;
-}
-
-static inline int PageAnon(struct page *page)
-{
-	return ((unsigned long)page->mapping & PAGE_MAPPING_ANON) != 0;
-}
-
-/*
- * Return the pagecache index of the passed page.  Regular pagecache pages
- * use ->index whereas swapcache pages use ->private
- */
-static inline pgoff_t page_index(struct page *page)
-{
-	if (unlikely(PageSwapCache(page)))
-		return page_private(page);
-	return page->index;
-}
-
-/*
  * The atomic page->_mapcount, like _count, starts from -1:
  * so that transitions both from it and to it can be tracked,
  * using atomic_inc_and_test and atomic_add_negative(-1).
Index: linux-2.6.23-rc6-mm1/include/linux/fs.h
===================================================================
--- linux-2.6.23-rc6-mm1.orig/include/linux/fs.h
+++ linux-2.6.23-rc6-mm1/include/linux/fs.h
@@ -517,12 +517,16 @@ struct address_space {
 	struct list_head	private_list;	/* ditto */
 	struct address_space	*assoc_mapping;	/* ditto */
 } __attribute__((aligned(sizeof(long))));
+
+
+#include <linux/page-cache.h>
+
+
 	/*
 	 * On most architectures that alignment is already the case; but
 	 * must be enforced here for CRIS, to let the least signficant bit
 	 * of struct page's "mapping" pointer be used for PAGE_MAPPING_ANON.
 	 */
-
 struct block_device {
 	dev_t			bd_dev;  /* not a kdev_t - it's a search key */
 	struct inode *		bd_inode;	/* will die */
Index: linux-2.6.23-rc6-mm1/include/linux/swap.h
===================================================================
--- linux-2.6.23-rc6-mm1.orig/include/linux/swap.h
+++ linux-2.6.23-rc6-mm1/include/linux/swap.h
@@ -196,7 +196,6 @@ extern unsigned long try_to_free_mem_con
 extern int __isolate_lru_page(struct page *page, int mode);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
-extern int remove_mapping(struct address_space *mapping, struct page *page);
 extern long vm_total_pages;
 
 #ifdef CONFIG_NUMA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
