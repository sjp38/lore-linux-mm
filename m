Date: Wed, 12 Sep 2007 11:45:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] overwride page->mapping [1/3] cleanup
Message-Id: <20070912114533.3ffc5235.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070912114322.e4d8a86e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070912114322.e4d8a86e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>, "Lee.Schermerhorn@hp.com" <Lee.Schermerhorn@hp.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Clean up: Gather all page->mapping handling functions to page-cache.h

no functional changes. (will be merged to "add page->mapping interface function"
patch.)

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 include/linux/mm.h         |   47 --------------------------------------------
 include/linux/page-cache.h |   48 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 48 insertions(+), 47 deletions(-)

Index: test-2.6.23-rc4-mm1/include/linux/mm.h
===================================================================
--- test-2.6.23-rc4-mm1.orig/include/linux/mm.h
+++ test-2.6.23-rc4-mm1/include/linux/mm.h
@@ -550,53 +550,6 @@ void page_address_init(void);
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
-	struct address_space *mapping = (struct address_space *)page->mapping;
-
-	VM_BUG_ON(PageSlab(page));
-	if (unlikely(PageSwapCache(page)))
-		mapping = &swapper_space;
-#ifdef CONFIG_SLUB
-	else if (unlikely(PageSlab(page)))
-		mapping = NULL;
-#endif
-	else if (unlikely((unsigned long)mapping & PAGE_MAPPING_ANON))
-		mapping = NULL;
-	return mapping;
-}
-
-static inline int PageAnon(struct page *page)
-{
-	return (page->mapping & PAGE_MAPPING_ANON) != 0;
-}
-
-static inline struct anon_vma *page_mapping_anon(struct page *page)
-{
-	if (PageAnon(page))
-		return (struct anon_vma *)(page->mapping - PAGE_MAPPING_ANON);
-	return NULL;
-}
-
-static inline struct address_space *page_mapping_cache(struct page *page)
-{
-	if (PageAnon(page))
-		return NULL;
-	return (struct address_space *) page->mapping;
-}
-
-/*
  * Return the pagecache index of the passed page.  Regular pagecache pages
  * use ->index whereas swapcache pages use ->private
  */
Index: test-2.6.23-rc4-mm1/include/linux/page-cache.h
===================================================================
--- test-2.6.23-rc4-mm1.orig/include/linux/page-cache.h
+++ test-2.6.23-rc4-mm1/include/linux/page-cache.h
@@ -7,8 +7,56 @@
 #define _LINUX_PAGECACHE_H
 
 #include <linux/mm.h>
+#include <linux/rmap.h>
 /* page_mapping_xxx() function is defined in mm.h */
 
+/*
+ * On an anonymous page mapped into a user virtual memory area,
+ * page->mapping points to its anon_vma, not to a struct address_space;
+ * with the PAGE_MAPPING_ANON bit set to distinguish it.
+ *
+ * Please note that, confusingly, "page_mapping" refers to the inode
+ * address_space which maps the page from disk; whereas "page_mapped"
+ * refers to user virtual address space into which the page is mapped.
+ */
+#define PAGE_MAPPING_ANON	1
+
+static inline int PageAnon(struct page *page)
+{
+	return (page->mapping & PAGE_MAPPING_ANON) != 0;
+}
+
+extern struct address_space swapper_space;
+static inline struct address_space *page_mapping(struct page *page)
+{
+	struct address_space *mapping = (struct address_space *)page->mapping;
+
+	VM_BUG_ON(PageSlab(page));
+	if (unlikely(PageSwapCache(page)))
+		mapping = &swapper_space;
+#ifdef CONFIG_SLUB
+	else if (unlikely(PageSlab(page)))
+		mapping = NULL;
+#endif
+	else if (unlikely((unsigned long)mapping & PAGE_MAPPING_ANON))
+		mapping = NULL;
+	return mapping;
+}
+
+static inline struct anon_vma *page_mapping_anon(struct page *page)
+{
+	if (!page->mapping || !PageAnon(page))
+		return NULL;
+	return (struct anon_vma *)(page->mapping - PAGE_MAPPING_ANON);
+}
+
+static inline struct address_space *page_mapping_cache(struct page *page)
+{
+	if (!page->mapping || PageAnon(page))
+		return NULL;
+	return (struct address_space *)page->mapping;
+}
+
 static inline int page_is_pagecache(struct page *page)
 {
 	if (!page->mapping || (page->mapping & PAGE_MAPPING_ANON))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
