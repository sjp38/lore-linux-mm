Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0EA046B00A3
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 11:10:11 -0400 (EDT)
Date: Wed, 3 Jun 2009 16:45:52 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH] ksm: fix rmap_item use after free
Message-ID: <20090603144552.GB30426@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: hugh@veritas.com, linux-kernel@vger.kernel.org, Izik Eidus <ieidus@redhat.com>, nickpiggin@yahoo.com.au, chrisw@redhat.com, linux-mm@kvack.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

This avoid crashing with slab debugging enabled by removing a window
for memory corruption if freed slab entries are reused before we read
the next pointer. Against mmotm.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/ksm.c b/mm/ksm.c
index 74d921b..f060e87 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -892,7 +892,7 @@ static struct rmap_item *stable_tree_search(struct page *page,
 {
 	struct rb_node *node = root_stable_tree.rb_node;
 	struct tree_item *tree_item;
-	struct rmap_item *found_rmap_item;
+	struct rmap_item *found_rmap_item, *next_rmap_item;
 
 	while (node) {
 		int ret;
@@ -907,9 +907,11 @@ static struct rmap_item *stable_tree_search(struct page *page,
 			      found_rmap_item->address == rmap_item->address)) {
 				if (!is_zapped_item(found_rmap_item, page2))
 					break;
+				next_rmap_item = found_rmap_item->next;
 				remove_rmap_item_from_tree(found_rmap_item);
-			}
-			found_rmap_item = found_rmap_item->next;
+				found_rmap_item = next_rmap_item;
+			} else
+				found_rmap_item = found_rmap_item->next;
 		}
 		if (!found_rmap_item)
 			goto out_didnt_find;
@@ -959,7 +961,7 @@ static int stable_tree_insert(struct page *page,
 
 	while (*new) {
 		int ret;
-		struct rmap_item *insert_rmap_item;
+		struct rmap_item *insert_rmap_item, *next_rmap_item;
 
 		tree_item = rb_entry(*new, struct tree_item, node);
 		BUG_ON(!tree_item);
@@ -973,9 +975,11 @@ static int stable_tree_insert(struct page *page,
 			     insert_rmap_item->address == rmap_item->address)) {
 				if (!is_zapped_item(insert_rmap_item, page2))
 					break;
+				next_rmap_item = insert_rmap_item->next;
 				remove_rmap_item_from_tree(insert_rmap_item);
-			}
-			insert_rmap_item = insert_rmap_item->next;
+				insert_rmap_item = next_rmap_item;
+			} else
+				insert_rmap_item = insert_rmap_item->next;
 		}
 		if (!insert_rmap_item)
 			return 1;



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
