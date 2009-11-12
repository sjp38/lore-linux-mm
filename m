Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 558BA6B0062
	for <linux-mm@kvack.org>; Thu, 12 Nov 2009 18:20:40 -0500 (EST)
Date: Thu, 12 Nov 2009 23:20:21 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 6/6] ksm: stable_node point to page and back
In-Reply-To: <Pine.LNX.4.64.0911122303450.3378@sister.anvils>
Message-ID: <Pine.LNX.4.64.0911122319080.4050@sister.anvils>
References: <Pine.LNX.4.64.0911122303450.3378@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Add a pointer to the ksm page into struct stable_node, holding a
reference to the page while the node exists.  Put a pointer to the
stable_node into the ksm page's ->mapping.

Then we don't need get_ksm_page() while traversing the stable tree:
the page to compare against is sure to be present and correct, even
if it's no longer visible through any of its existing rmap_items.

And we can handle the forked ksm page case more efficiently:
no need to memcmp our way through the tree to find its match.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 include/linux/ksm.h |   24 +++++++---
 mm/ksm.c            |   99 ++++++++++++++----------------------------
 2 files changed, 51 insertions(+), 72 deletions(-)

--- ksm5/include/linux/ksm.h	2009-11-04 10:52:45.000000000 +0000
+++ ksm6/include/linux/ksm.h	2009-11-12 15:29:06.000000000 +0000
@@ -12,6 +12,8 @@
 #include <linux/sched.h>
 #include <linux/vmstat.h>
 
+struct stable_node;
+
 #ifdef CONFIG_KSM
 int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 		unsigned long end, int advice, unsigned long *vm_flags);
@@ -34,7 +36,8 @@ static inline void ksm_exit(struct mm_st
 /*
  * A KSM page is one of those write-protected "shared pages" or "merged pages"
  * which KSM maps into multiple mms, wherever identical anonymous page content
- * is found in VM_MERGEABLE vmas.  It's a PageAnon page, with NULL anon_vma.
+ * is found in VM_MERGEABLE vmas.  It's a PageAnon page, pointing not to any
+ * anon_vma, but to that page's node of the stable tree.
  */
 static inline int PageKsm(struct page *page)
 {
@@ -42,15 +45,22 @@ static inline int PageKsm(struct page *p
 				(PAGE_MAPPING_ANON | PAGE_MAPPING_KSM);
 }
 
-/*
- * But we have to avoid the checking which page_add_anon_rmap() performs.
- */
+static inline struct stable_node *page_stable_node(struct page *page)
+{
+	return PageKsm(page) ? page_rmapping(page) : NULL;
+}
+
+static inline void set_page_stable_node(struct page *page,
+					struct stable_node *stable_node)
+{
+	page->mapping = (void *)stable_node +
+				(PAGE_MAPPING_ANON | PAGE_MAPPING_KSM);
+}
+
 static inline void page_add_ksm_rmap(struct page *page)
 {
-	if (atomic_inc_and_test(&page->_mapcount)) {
-		page->mapping = (void *) (PAGE_MAPPING_ANON | PAGE_MAPPING_KSM);
+	if (atomic_inc_and_test(&page->_mapcount))
 		__inc_zone_page_state(page, NR_ANON_PAGES);
-	}
 }
 #else  /* !CONFIG_KSM */
 
--- ksm5/mm/ksm.c	2009-11-12 15:29:00.000000000 +0000
+++ ksm6/mm/ksm.c	2009-11-12 15:29:06.000000000 +0000
@@ -107,10 +107,12 @@ struct ksm_scan {
 
 /**
  * struct stable_node - node of the stable rbtree
+ * @page: pointer to struct page of the ksm page
  * @node: rb node of this ksm page in the stable tree
  * @hlist: hlist head of rmap_items using this ksm page
  */
 struct stable_node {
+	struct page *page;
 	struct rb_node node;
 	struct hlist_head hlist;
 };
@@ -435,23 +437,6 @@ out:		page = NULL;
 }
 
 /*
- * get_ksm_page: checks if the page at the virtual address in rmap_item
- * is still PageKsm, in which case we can trust the content of the page,
- * and it returns the gotten page; but NULL if the page has been zapped.
- */
-static struct page *get_ksm_page(struct rmap_item *rmap_item)
-{
-	struct page *page;
-
-	page = get_mergeable_page(rmap_item);
-	if (page && !PageKsm(page)) {
-		put_page(page);
-		page = NULL;
-	}
-	return page;
-}
-
-/*
  * Removing rmap_item from stable or unstable tree.
  * This function will clean the information from the stable/unstable tree.
  */
@@ -465,6 +450,9 @@ static void remove_rmap_item_from_tree(s
 		if (stable_node->hlist.first)
 			ksm_pages_sharing--;
 		else {
+			set_page_stable_node(stable_node->page, NULL);
+			put_page(stable_node->page);
+
 			rb_erase(&stable_node->node, &root_stable_tree);
 			free_stable_node(stable_node);
 			ksm_pages_shared--;
@@ -740,8 +728,7 @@ out:
  * try_to_merge_one_page - take two pages and merge them into one
  * @vma: the vma that holds the pte pointing to page
  * @page: the PageAnon page that we want to replace with kpage
- * @kpage: the PageKsm page (or newly allocated page which page_add_ksm_rmap
- *         will make PageKsm) that we want to map instead of page
+ * @kpage: the PageKsm page that we want to map instead of page
  *
  * This function returns 0 if the pages were merged, -EFAULT otherwise.
  */
@@ -793,6 +780,9 @@ static int try_to_merge_with_ksm_page(st
 	struct vm_area_struct *vma;
 	int err = -EFAULT;
 
+	if (page == kpage)			/* ksm page forked */
+		return 0;
+
 	down_read(&mm->mmap_sem);
 	if (ksm_test_exit(mm))
 		goto out;
@@ -846,6 +836,9 @@ static struct page *try_to_merge_two_pag
 		goto up;
 
 	copy_user_highpage(kpage, page, rmap_item->address, vma);
+
+	set_page_stable_node(kpage, NULL);	/* mark it PageKsm */
+
 	err = try_to_merge_one_page(vma, page, kpage);
 up:
 	up_read(&mm->mmap_sem);
@@ -876,41 +869,31 @@ up:
  * This function returns the stable tree node of identical content if found,
  * NULL otherwise.
  */
-static struct stable_node *stable_tree_search(struct page *page,
-					      struct page **tree_pagep)
+static struct stable_node *stable_tree_search(struct page *page)
 {
 	struct rb_node *node = root_stable_tree.rb_node;
 	struct stable_node *stable_node;
 
+	stable_node = page_stable_node(page);
+	if (stable_node) {			/* ksm page forked */
+		get_page(page);
+		return stable_node;
+	}
+
 	while (node) {
-		struct hlist_node *hlist, *hnext;
-		struct rmap_item *tree_rmap_item;
-		struct page *tree_page;
 		int ret;
 
+		cond_resched();
 		stable_node = rb_entry(node, struct stable_node, node);
-		hlist_for_each_entry_safe(tree_rmap_item, hlist, hnext,
-					&stable_node->hlist, hlist) {
-			BUG_ON(!in_stable_tree(tree_rmap_item));
-			cond_resched();
-			tree_page = get_ksm_page(tree_rmap_item);
-			if (tree_page)
-				break;
-			remove_rmap_item_from_tree(tree_rmap_item);
-		}
-		if (!hlist)
-			return NULL;
 
-		ret = memcmp_pages(page, tree_page);
+		ret = memcmp_pages(page, stable_node->page);
 
-		if (ret < 0) {
-			put_page(tree_page);
+		if (ret < 0)
 			node = node->rb_left;
-		} else if (ret > 0) {
-			put_page(tree_page);
+		else if (ret > 0)
 			node = node->rb_right;
-		} else {
-			*tree_pagep = tree_page;
+		else {
+			get_page(stable_node->page);
 			return stable_node;
 		}
 	}
@@ -932,26 +915,12 @@ static struct stable_node *stable_tree_i
 	struct stable_node *stable_node;
 
 	while (*new) {
-		struct hlist_node *hlist, *hnext;
-		struct rmap_item *tree_rmap_item;
-		struct page *tree_page;
 		int ret;
 
+		cond_resched();
 		stable_node = rb_entry(*new, struct stable_node, node);
-		hlist_for_each_entry_safe(tree_rmap_item, hlist, hnext,
-					&stable_node->hlist, hlist) {
-			BUG_ON(!in_stable_tree(tree_rmap_item));
-			cond_resched();
-			tree_page = get_ksm_page(tree_rmap_item);
-			if (tree_page)
-				break;
-			remove_rmap_item_from_tree(tree_rmap_item);
-		}
-		if (!hlist)
-			return NULL;
 
-		ret = memcmp_pages(kpage, tree_page);
-		put_page(tree_page);
+		ret = memcmp_pages(kpage, stable_node->page);
 
 		parent = *new;
 		if (ret < 0)
@@ -977,6 +946,10 @@ static struct stable_node *stable_tree_i
 
 	INIT_HLIST_HEAD(&stable_node->hlist);
 
+	get_page(kpage);
+	stable_node->page = kpage;
+	set_page_stable_node(kpage, stable_node);
+
 	return stable_node;
 }
 
@@ -1085,14 +1058,10 @@ static void cmp_and_merge_page(struct pa
 	remove_rmap_item_from_tree(rmap_item);
 
 	/* We first start with searching the page inside the stable tree */
-	stable_node = stable_tree_search(page, &tree_page);
+	stable_node = stable_tree_search(page);
 	if (stable_node) {
-		kpage = tree_page;
-		if (page == kpage)			/* forked */
-			err = 0;
-		else
-			err = try_to_merge_with_ksm_page(rmap_item,
-							 page, kpage);
+		kpage = stable_node->page;
+		err = try_to_merge_with_ksm_page(rmap_item, page, kpage);
 		if (!err) {
 			/*
 			 * The page was successfully merged:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
