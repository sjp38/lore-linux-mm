Message-Id: <200405222202.i4MM22r11505@mail.osdl.org>
Subject: [patch 03/57] revert recent swapcache handling changes
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:01:19 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>


Go back to the 2.6.5 concepts, with rmap additions.  In particular:

- Implement Andrea's flavour of page_mapping().  This function opaquely does
  the right thing for pagecache pages, anon pages and for swapcache pages.

  The critical thing here is that page_mapping() returns &swapper_space for
  swapcache pages without actually requiring the storage at page->mapping. 
  This frees page->mapping for the anonmm/anonvma metadata.

- Andrea and Hugh placed the pagecache index of swapcache pages into
  page->private rather than page->index.  So add new page_index() function
  which hides this.

- Make swapper_space.set_page_dirty() again point at
  __set_page_dirty_buffers().  If we don't do that, a bare set_page_dirty()
  will fall through to __set_page_dirty_buffers(), which is silly.

  This way, __set_page_dirty_buffers() can continue to use page->mapping. 
  It should never go near anon or swapcache pages.

- Give swapper_space a ->set_page_dirty address_space_operation method, so
  that set_page_dirty() will not fall through to __set_page_dirty_buffers()
  for swapcache pages.  That function is not set up to handle them.


The main effect of these changes is that swapcache pages are treated more
similarly to pagecache pages.  And we are again tagging swapcache pages as
dirty in their radix tree, which is a requirement if we later wish to
implement swapcache writearound based on tagged radix-tree walks.


---

 25-akpm/fs/buffer.c         |    3 ++-
 25-akpm/include/linux/mm.h  |   20 +++++++++++++++++++-
 25-akpm/mm/page-writeback.c |   38 +++++++++++++++++++++++---------------
 25-akpm/mm/swap_state.c     |    2 ++
 mm/memory.c                 |    0 
 5 files changed, 46 insertions(+), 17 deletions(-)

diff -puN include/linux/mm.h~revert-swapcache-changes include/linux/mm.h
--- 25/include/linux/mm.h~revert-swapcache-changes	2004-05-22 14:56:21.531818192 -0700
+++ 25-akpm/include/linux/mm.h	2004-05-22 14:59:43.929049136 -0700
@@ -415,9 +415,27 @@ void page_address_init(void);
  * address_space which maps the page from disk; whereas "page_mapped"
  * refers to user virtual address space into which the page is mapped.
  */
+extern struct address_space swapper_space;
 static inline struct address_space *page_mapping(struct page *page)
 {
-	return PageAnon(page)? NULL: page->mapping;
+	struct address_space *mapping = NULL;
+
+	if (unlikely(PageSwapCache(page)))
+		mapping = &swapper_space;
+	else if (likely(!PageAnon(page)))
+		mapping = page->mapping;
+	return mapping;
+}
+
+/*
+ * Return the pagecache index of the passed page.  Regular pagecache pages
+ * use ->index whereas swapcache pages use ->private
+ */
+static inline pgoff_t page_index(struct page *page)
+{
+	if (unlikely(PageSwapCache(page)))
+		return page->private;
+	return page->index;
 }
 
 /*
diff -puN mm/swap_state.c~revert-swapcache-changes mm/swap_state.c
--- 25/mm/swap_state.c~revert-swapcache-changes	2004-05-22 14:56:21.533817888 -0700
+++ 25-akpm/mm/swap_state.c	2004-05-22 14:59:44.200007944 -0700
@@ -12,6 +12,7 @@
 #include <linux/swap.h>
 #include <linux/init.h>
 #include <linux/pagemap.h>
+#include <linux/buffer_head.h>
 #include <linux/backing-dev.h>
 
 #include <asm/pgtable.h>
@@ -22,6 +23,7 @@
  */
 static struct address_space_operations swap_aops = {
 	.writepage	= swap_writepage,
+	.set_page_dirty	= __set_page_dirty_nobuffers,
 };
 
 static struct backing_dev_info swap_backing_dev_info = {
diff -puN mm/page-writeback.c~revert-swapcache-changes mm/page-writeback.c
--- 25/mm/page-writeback.c~revert-swapcache-changes	2004-05-22 14:56:21.537817280 -0700
+++ 25-akpm/mm/page-writeback.c	2004-05-22 14:59:44.067028160 -0700
@@ -560,16 +560,17 @@ int __set_page_dirty_nobuffers(struct pa
 	int ret = 0;
 
 	if (!TestSetPageDirty(page)) {
-		struct address_space *mapping = page->mapping;
+		struct address_space *mapping = page_mapping(page);
 
 		if (mapping) {
 			spin_lock_irq(&mapping->tree_lock);
-			if (page->mapping) {	/* Race with truncate? */
-				BUG_ON(page->mapping != mapping);
+			mapping = page_mapping(page);
+			if (mapping) {	/* Race with truncate? */
+				BUG_ON(page_mapping(page) != mapping);
 				if (!mapping->backing_dev_info->memory_backed)
 					inc_page_state(nr_dirty);
 				radix_tree_tag_set(&mapping->page_tree,
-					page->index, PAGECACHE_TAG_DIRTY);
+					page_index(page), PAGECACHE_TAG_DIRTY);
 			}
 			spin_unlock_irq(&mapping->tree_lock);
 			if (!PageSwapCache(page))
@@ -600,14 +601,16 @@ EXPORT_SYMBOL(redirty_page_for_writepage
 int fastcall set_page_dirty(struct page *page)
 {
 	struct address_space *mapping = page_mapping(page);
-	int (*spd)(struct page *);
 
-	if (!mapping) {
-		SetPageDirty(page);
-		return 0;
+	if (likely(mapping)) {
+		int (*spd)(struct page *) = mapping->a_ops->set_page_dirty;
+		if (spd)
+			return (*spd)(page);
+		return __set_page_dirty_buffers(page);
 	}
-	spd = mapping->a_ops->set_page_dirty;
-	return spd? (*spd)(page): __set_page_dirty_buffers(page);
+	if (!PageDirty(page))
+		SetPageDirty(page);
+	return 0;
 }
 EXPORT_SYMBOL(set_page_dirty);
 
@@ -644,7 +647,8 @@ int test_clear_page_dirty(struct page *p
 	if (mapping) {
 		spin_lock_irqsave(&mapping->tree_lock, flags);
 		if (TestClearPageDirty(page)) {
-			radix_tree_tag_clear(&mapping->page_tree, page->index,
+			radix_tree_tag_clear(&mapping->page_tree,
+						page_index(page),
 						PAGECACHE_TAG_DIRTY);
 			spin_unlock_irqrestore(&mapping->tree_lock, flags);
 			if (!mapping->backing_dev_info->memory_backed)
@@ -700,7 +704,8 @@ int __clear_page_dirty(struct page *page
 
 		spin_lock_irqsave(&mapping->tree_lock, flags);
 		if (TestClearPageDirty(page)) {
-			radix_tree_tag_clear(&mapping->page_tree, page->index,
+			radix_tree_tag_clear(&mapping->page_tree,
+						page_index(page),
 						PAGECACHE_TAG_DIRTY);
 			spin_unlock_irqrestore(&mapping->tree_lock, flags);
 			return 1;
@@ -722,7 +727,8 @@ int test_clear_page_writeback(struct pag
 		spin_lock_irqsave(&mapping->tree_lock, flags);
 		ret = TestClearPageWriteback(page);
 		if (ret)
-			radix_tree_tag_clear(&mapping->page_tree, page->index,
+			radix_tree_tag_clear(&mapping->page_tree,
+						page_index(page),
 						PAGECACHE_TAG_WRITEBACK);
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
 	} else {
@@ -742,10 +748,12 @@ int test_set_page_writeback(struct page 
 		spin_lock_irqsave(&mapping->tree_lock, flags);
 		ret = TestSetPageWriteback(page);
 		if (!ret)
-			radix_tree_tag_set(&mapping->page_tree, page->index,
+			radix_tree_tag_set(&mapping->page_tree,
+						page_index(page),
 						PAGECACHE_TAG_WRITEBACK);
 		if (!PageDirty(page))
-			radix_tree_tag_clear(&mapping->page_tree, page->index,
+			radix_tree_tag_clear(&mapping->page_tree,
+						page_index(page),
 						PAGECACHE_TAG_DIRTY);
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
 	} else {
diff -puN fs/buffer.c~revert-swapcache-changes fs/buffer.c
--- 25/fs/buffer.c~revert-swapcache-changes	2004-05-22 14:56:21.538817128 -0700
+++ 25-akpm/fs/buffer.c	2004-05-22 14:59:43.571103552 -0700
@@ -951,7 +951,8 @@ int __set_page_dirty_buffers(struct page
 		if (page->mapping) {	/* Race with truncate? */
 			if (!mapping->backing_dev_info->memory_backed)
 				inc_page_state(nr_dirty);
-			radix_tree_tag_set(&mapping->page_tree, page->index,
+			radix_tree_tag_set(&mapping->page_tree,
+						page_index(page),
 						PAGECACHE_TAG_DIRTY);
 		}
 		spin_unlock_irq(&mapping->tree_lock);
diff -puN mm/memory.c~revert-swapcache-changes mm/memory.c

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
