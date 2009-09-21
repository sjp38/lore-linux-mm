Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7006C6B0154
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 08:43:14 -0400 (EDT)
Date: Mon, 21 Sep 2009 13:43:15 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH] ksm: fix rare page leak
Message-ID: <Pine.LNX.4.64.0909211336300.4809@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

In the rare case when stable_tree_insert() finds a match when the prior
stable_tree_search() did not, it forgot to free the page reference (the
omission looks intentional, but I think that's because something else
used to be done there).

Fix that by one put_page() for all three cases, call it tree_page
rather than page2[0], clarify the comment on this exceptional case,
and remove the comment in stable_tree_search() which contradicts it!

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 mm/ksm.c |   29 +++++++++++------------------
 1 file changed, 11 insertions(+), 18 deletions(-)

--- mmotm/mm/ksm.c	2009-09-14 16:34:37.000000000 +0100
+++ linux/mm/ksm.c	2009-09-21 13:12:07.000000000 +0100
@@ -904,10 +904,6 @@ static struct rmap_item *stable_tree_sea
 		if (!tree_rmap_item)
 			return NULL;
 
-		/*
-		 * We can trust the value of the memcmp as we know the pages
-		 * are write protected.
-		 */
 		ret = memcmp_pages(page, page2[0]);
 
 		if (ret < 0) {
@@ -939,18 +935,18 @@ static struct rmap_item *stable_tree_ins
 {
 	struct rb_node **new = &root_stable_tree.rb_node;
 	struct rb_node *parent = NULL;
-	struct page *page2[1];
 
 	while (*new) {
 		struct rmap_item *tree_rmap_item, *next_rmap_item;
+		struct page *tree_page;
 		int ret;
 
 		tree_rmap_item = rb_entry(*new, struct rmap_item, node);
 		while (tree_rmap_item) {
 			BUG_ON(!in_stable_tree(tree_rmap_item));
 			cond_resched();
-			page2[0] = get_ksm_page(tree_rmap_item);
-			if (page2[0])
+			tree_page = get_ksm_page(tree_rmap_item);
+			if (tree_page)
 				break;
 			next_rmap_item = tree_rmap_item->next;
 			remove_rmap_item_from_tree(tree_rmap_item);
@@ -959,22 +955,19 @@ static struct rmap_item *stable_tree_ins
 		if (!tree_rmap_item)
 			return NULL;
 
-		ret = memcmp_pages(page, page2[0]);
+		ret = memcmp_pages(page, tree_page);
+		put_page(tree_page);
 
 		parent = *new;
-		if (ret < 0) {
-			put_page(page2[0]);
+		if (ret < 0)
 			new = &parent->rb_left;
-		} else if (ret > 0) {
-			put_page(page2[0]);
+		else if (ret > 0)
 			new = &parent->rb_right;
-		} else {
+		else {
 			/*
-			 * It is not a bug when we come here (the fact that
-			 * we didn't find the page inside the stable tree):
-			 * because when we searched for the page inside the
-			 * stable tree it was still not write-protected,
-			 * so therefore it could have changed later.
+			 * It is not a bug that stable_tree_search() didn't
+			 * find this node: because at that time our page was
+			 * not yet write-protected, so may have changed since.
 			 */
 			return NULL;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
