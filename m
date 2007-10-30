Message-Id: <20071030160914.849009000@chello.nl>
References: <20071030160401.296770000@chello.nl>
Date: Tue, 30 Oct 2007 17:04:25 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 24/33] mm: prepare swap entry methods for use in page methods
Content-Disposition: inline; filename=mm-swap_entry_methods.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Move around the swap entry methods in preparation for use from
page methods.

Also provide a function to obtain the swap_info_struct backing
a swap cache page.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/mm.h      |    8 ++++++++
 include/linux/swap.h    |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/swapops.h |   44 --------------------------------------------
 mm/swapfile.c           |    1 +
 4 files changed, 57 insertions(+), 44 deletions(-)

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -12,6 +12,7 @@
 #include <linux/prio_tree.h>
 #include <linux/debug_locks.h>
 #include <linux/mm_types.h>
+#include <linux/swap.h>
 
 struct mempolicy;
 struct anon_vma;
@@ -573,6 +574,13 @@ static inline struct address_space *page
 	return mapping;
 }
 
+static inline struct swap_info_struct *page_swap_info(struct page *page)
+{
+	swp_entry_t swap = { .val = page_private(page) };
+	BUG_ON(!PageSwapCache(page));
+	return get_swap_info_struct(swp_type(swap));
+}
+
 static inline int PageAnon(struct page *page)
 {
 	return ((unsigned long)page->mapping & PAGE_MAPPING_ANON) != 0;
Index: linux-2.6/include/linux/swap.h
===================================================================
--- linux-2.6.orig/include/linux/swap.h
+++ linux-2.6/include/linux/swap.h
@@ -80,6 +80,50 @@ typedef struct {
 } swp_entry_t;
 
 /*
+ * swapcache pages are stored in the swapper_space radix tree.  We want to
+ * get good packing density in that tree, so the index should be dense in
+ * the low-order bits.
+ *
+ * We arrange the `type' and `offset' fields so that `type' is at the five
+ * high-order bits of the swp_entry_t and `offset' is right-aligned in the
+ * remaining bits.
+ *
+ * swp_entry_t's are *never* stored anywhere in their arch-dependent format.
+ */
+#define SWP_TYPE_SHIFT(e)	(sizeof(e.val) * 8 - MAX_SWAPFILES_SHIFT)
+#define SWP_OFFSET_MASK(e)	((1UL << SWP_TYPE_SHIFT(e)) - 1)
+
+/*
+ * Store a type+offset into a swp_entry_t in an arch-independent format
+ */
+static inline swp_entry_t swp_entry(unsigned long type, pgoff_t offset)
+{
+	swp_entry_t ret;
+
+	ret.val = (type << SWP_TYPE_SHIFT(ret)) |
+			(offset & SWP_OFFSET_MASK(ret));
+	return ret;
+}
+
+/*
+ * Extract the `type' field from a swp_entry_t.  The swp_entry_t is in
+ * arch-independent format
+ */
+static inline unsigned swp_type(swp_entry_t entry)
+{
+	return (entry.val >> SWP_TYPE_SHIFT(entry));
+}
+
+/*
+ * Extract the `offset' field from a swp_entry_t.  The swp_entry_t is in
+ * arch-independent format
+ */
+static inline pgoff_t swp_offset(swp_entry_t entry)
+{
+	return entry.val & SWP_OFFSET_MASK(entry);
+}
+
+/*
  * current->reclaim_state points to one of these when a task is running
  * memory reclaim
  */
@@ -326,6 +370,10 @@ static inline int valid_swaphandles(swp_
 	return 0;
 }
 
+static inline struct swap_info_struct *get_swap_info_struct(unsigned type)
+{
+	return NULL;
+}
 #define can_share_swap_page(p)			(page_mapcount(p) == 1)
 
 static inline int move_to_swap_cache(struct page *page, swp_entry_t entry)
Index: linux-2.6/include/linux/swapops.h
===================================================================
--- linux-2.6.orig/include/linux/swapops.h
+++ linux-2.6/include/linux/swapops.h
@@ -1,48 +1,4 @@
 /*
- * swapcache pages are stored in the swapper_space radix tree.  We want to
- * get good packing density in that tree, so the index should be dense in
- * the low-order bits.
- *
- * We arrange the `type' and `offset' fields so that `type' is at the five
- * high-order bits of the swp_entry_t and `offset' is right-aligned in the
- * remaining bits.
- *
- * swp_entry_t's are *never* stored anywhere in their arch-dependent format.
- */
-#define SWP_TYPE_SHIFT(e)	(sizeof(e.val) * 8 - MAX_SWAPFILES_SHIFT)
-#define SWP_OFFSET_MASK(e)	((1UL << SWP_TYPE_SHIFT(e)) - 1)
-
-/*
- * Store a type+offset into a swp_entry_t in an arch-independent format
- */
-static inline swp_entry_t swp_entry(unsigned long type, pgoff_t offset)
-{
-	swp_entry_t ret;
-
-	ret.val = (type << SWP_TYPE_SHIFT(ret)) |
-			(offset & SWP_OFFSET_MASK(ret));
-	return ret;
-}
-
-/*
- * Extract the `type' field from a swp_entry_t.  The swp_entry_t is in
- * arch-independent format
- */
-static inline unsigned swp_type(swp_entry_t entry)
-{
-	return (entry.val >> SWP_TYPE_SHIFT(entry));
-}
-
-/*
- * Extract the `offset' field from a swp_entry_t.  The swp_entry_t is in
- * arch-independent format
- */
-static inline pgoff_t swp_offset(swp_entry_t entry)
-{
-	return entry.val & SWP_OFFSET_MASK(entry);
-}
-
-/*
  * Convert the arch-dependent pte representation of a swp_entry_t into an
  * arch-independent swp_entry_t.
  */
Index: linux-2.6/mm/swapfile.c
===================================================================
--- linux-2.6.orig/mm/swapfile.c
+++ linux-2.6/mm/swapfile.c
@@ -1768,6 +1768,7 @@ get_swap_info_struct(unsigned type)
 {
 	return &swap_info[type];
 }
+EXPORT_SYMBOL_GPL(get_swap_info_struct);
 
 /*
  * swap_lock prevents swap_map being freed. Don't grab an extra

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
