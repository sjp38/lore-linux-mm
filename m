Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B57C06B0062
	for <linux-mm@kvack.org>; Thu, 12 Nov 2009 18:14:04 -0500 (EST)
Date: Thu, 12 Nov 2009 23:13:59 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 1/6] ksm: three remove_rmap_item_from_tree cleanups
In-Reply-To: <Pine.LNX.4.64.0911122303450.3378@sister.anvils>
Message-ID: <Pine.LNX.4.64.0911122312360.4050@sister.anvils>
References: <Pine.LNX.4.64.0911122303450.3378@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

1. remove_rmap_item_from_tree() is called as a precaution from
   various places: don't dirty the rmap_item cacheline unnecessarily,
   just mask the flags out of the address when they have been set.

2. First get_next_rmap_item() removes an unstable rmap_item from its tree,
   then shortly afterwards cmp_and_merge_page() removes a stable rmap_item
   from its tree: it's easier just to do both at once (but definitely keep
   the BUG_ON(age > 1) which guards against a future omission).

3. When cmp_and_merge_page() moves an rmap_item from unstable to stable
   tree, it does its own rb_erase() and accounting: that's better
   expressed by remove_rmap_item_from_tree().

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 mm/ksm.c |   17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

--- ksm0/mm/ksm.c	2009-11-10 09:06:23.000000000 +0000
+++ ksm1/mm/ksm.c	2009-11-12 15:28:36.000000000 +0000
@@ -453,6 +453,7 @@ static void remove_rmap_item_from_tree(s
 		}
 
 		rmap_item->next = NULL;
+		rmap_item->address &= PAGE_MASK;
 
 	} else if (rmap_item->address & NODE_FLAG) {
 		unsigned char age;
@@ -467,11 +468,11 @@ static void remove_rmap_item_from_tree(s
 		BUG_ON(age > 1);
 		if (!age)
 			rb_erase(&rmap_item->node, &root_unstable_tree);
+
 		ksm_pages_unshared--;
+		rmap_item->address &= PAGE_MASK;
 	}
 
-	rmap_item->address &= PAGE_MASK;
-
 	cond_resched();		/* we're called from many long loops */
 }
 
@@ -1086,8 +1087,7 @@ static void cmp_and_merge_page(struct pa
 	unsigned int checksum;
 	int err;
 
-	if (in_stable_tree(rmap_item))
-		remove_rmap_item_from_tree(rmap_item);
+	remove_rmap_item_from_tree(rmap_item);
 
 	/* We first start with searching the page inside the stable tree */
 	tree_rmap_item = stable_tree_search(page, page2, rmap_item);
@@ -1143,9 +1143,7 @@ static void cmp_and_merge_page(struct pa
 		 * tree, and insert it instead as new node in the stable tree.
 		 */
 		if (!err) {
-			rb_erase(&tree_rmap_item->node, &root_unstable_tree);
-			tree_rmap_item->address &= ~NODE_FLAG;
-			ksm_pages_unshared--;
+			remove_rmap_item_from_tree(tree_rmap_item);
 
 			/*
 			 * If we fail to insert the page into the stable tree,
@@ -1174,11 +1172,8 @@ static struct rmap_item *get_next_rmap_i
 
 	while (cur != &mm_slot->rmap_list) {
 		rmap_item = list_entry(cur, struct rmap_item, link);
-		if ((rmap_item->address & PAGE_MASK) == addr) {
-			if (!in_stable_tree(rmap_item))
-				remove_rmap_item_from_tree(rmap_item);
+		if ((rmap_item->address & PAGE_MASK) == addr)
 			return rmap_item;
-		}
 		if (rmap_item->address > addr)
 			break;
 		cur = cur->next;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
