Date: Mon, 10 Sep 2007 18:42:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] add page->mapping handling interface [1/35] interface
 definitions
Message-Id: <20070910184239.e1f705c9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

 - changes page->mapping from address_space* to unsigned long
 - add page_mapping_anon() function.
 - add linux/page-cache.h
 - add page_inode() function
 - add page_is_pagecache() function
 - add pagecaceh_consisten() function for pagecache consistency test.
 - expoterd swapper_space. inline function page_mapping() refers this.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 include/linux/fs.h         |    1 +
 include/linux/mm.h         |   20 +++++++++++++++++---
 include/linux/mm_types.h   |    2 +-
 include/linux/page-cache.h |   39 +++++++++++++++++++++++++++++++++++++++
 mm/swap_state.c            |    2 ++
 5 files changed, 60 insertions(+), 4 deletions(-)

Index: test-2.6.23-rc4-mm1/include/linux/page-cache.h
===================================================================
--- /dev/null
+++ test-2.6.23-rc4-mm1/include/linux/page-cache.h
@@ -0,0 +1,39 @@
+/*
+ * For interface definitions between memory management and file systems.
+ * - This file defines small interface functions for handling page cache.
+ */
+
+#ifndef _LINUX_PAGECACHE_H
+#define _LINUX_PAGECACHE_H
+
+#include <linux/mm.h>
+/* page_mapping_xxx() function is defined in mm.h */
+
+static inline int page_is_pagecache(struct page *page)
+{
+	if (!page->mapping || (page->mapping & PAGE_MAPPING_ANON))
+		return 0;
+	return 1;
+}
+
+/*
+ * Return an inode this page belongs to
+ */
+
+static inline struct inode *page_inode(struct page *page)
+{
+	if (!page_is_pagecache(page))
+		return NULL;
+	return page_mapping_cache(page)->host;
+}
+
+/*
+ * Test a page is a page-cache of an address_space.
+ */
+static inline int
+pagecache_consistent(struct page *page, struct address_space *as)
+{
+	return (page_mapping(page) == as);
+}
+
+#endif
Index: test-2.6.23-rc4-mm1/include/linux/fs.h
===================================================================
--- test-2.6.23-rc4-mm1.orig/include/linux/fs.h
+++ test-2.6.23-rc4-mm1/include/linux/fs.h
@@ -582,6 +582,7 @@ static inline int mapping_writably_mappe
 	return mapping->i_mmap_writable != 0;
 }
 
+#include <linux/page-cache.h>
 /*
  * Use sequence counter to get consistent i_size on 32-bit processors.
  */
Index: test-2.6.23-rc4-mm1/include/linux/mm_types.h
===================================================================
--- test-2.6.23-rc4-mm1.orig/include/linux/mm_types.h
+++ test-2.6.23-rc4-mm1/include/linux/mm_types.h
@@ -48,7 +48,7 @@ struct page {
 						 * indicates order in the buddy
 						 * system if PG_buddy is set.
 						 */
-		struct address_space *mapping;	/* If low bit clear, points to
+		unsigned long mapping;		/* If low bit clear, points to
 						 * inode address_space, or NULL.
 						 * If page mapped as anonymous
 						 * memory, low bit is set, and
Index: test-2.6.23-rc4-mm1/include/linux/mm.h
===================================================================
--- test-2.6.23-rc4-mm1.orig/include/linux/mm.h
+++ test-2.6.23-rc4-mm1/include/linux/mm.h
@@ -563,7 +563,7 @@ void page_address_init(void);
 extern struct address_space swapper_space;
 static inline struct address_space *page_mapping(struct page *page)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = (struct address_space *)page->mapping;
 
 	VM_BUG_ON(PageSlab(page));
 	if (unlikely(PageSwapCache(page)))
@@ -579,7 +579,21 @@ static inline struct address_space *page
 
 static inline int PageAnon(struct page *page)
 {
-	return ((unsigned long)page->mapping & PAGE_MAPPING_ANON) != 0;
+	return (page->mapping & PAGE_MAPPING_ANON) != 0;
+}
+
+static inline struct anon_vma *page_mapping_anon(struct page *page)
+{
+	if (PageAnon(page))
+		return (struct anon_vma *)(page->mapping - PAGE_MAPPING_ANON);
+	return NULL;
+}
+
+static inline struct address_space *page_mapping_cache(struct page *page)
+{
+	if (PageAnon(page))
+		return NULL;
+	return (struct address_space *) page->mapping;
 }
 
 /*
@@ -848,7 +862,7 @@ static inline pmd_t *pmd_alloc(struct mm
 #define pte_lock_init(_page)	do {					\
 	spin_lock_init(__pte_lockptr(_page));				\
 } while (0)
-#define pte_lock_deinit(page)	((page)->mapping = NULL)
+#define pte_lock_deinit(page)	((page)->mapping = 0)
 #define pte_lockptr(mm, pmd)	({(void)(mm); __pte_lockptr(pmd_page(*(pmd)));})
 #else
 /*
Index: test-2.6.23-rc4-mm1/mm/swap_state.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/mm/swap_state.c
+++ test-2.6.23-rc4-mm1/mm/swap_state.c
@@ -45,6 +45,8 @@ struct address_space swapper_space = {
 	.backing_dev_info = &swap_backing_dev_info,
 };
 
+EXPORT_SYMBOL(swapper_space);
+
 #define INC_CACHE_INFO(x)	do { swap_cache_info.x++; } while (0)
 
 static struct {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
