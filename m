Message-Id: <200405222217.i4MMHTr15192@mail.osdl.org>
Subject: [patch 57/57] partial prefetch for vma_prio_tree_next
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:16:44 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org, vrajesh@umich.edu
List-ID: <linux-mm.kvack.org>

From: Rajesh Venkatasubramanian <vrajesh@umich.edu>

This patch adds prefetches for walking a vm_set.list.  Adding prefetches
for prio tree traversals is tricky and may lead to cache trashing.  So this
patch just adds prefetches only when walking a vm_set.list.

I haven't done any benchmarks to show that this patch improves performance.
 However, this patch should help to improve performance when vm_set.lists
are long, e.g., libc.  Since we only prefetch vmas that are guaranteed to
be used in the near future, this patch should not result in cache trashing,
theoretically.

I didn't add any NULL checks before prefetching because prefetch.h clearly
says prefetch(0) is okay.


---

 25-akpm/mm/prio_tree.c |   27 ++++++++++++++++++---------
 1 files changed, 18 insertions(+), 9 deletions(-)

diff -puN mm/prio_tree.c~partial-prefetch-for-vma_prio_tree_next mm/prio_tree.c
--- 25/mm/prio_tree.c~partial-prefetch-for-vma_prio_tree_next	2004-05-22 14:56:30.621436360 -0700
+++ 25-akpm/mm/prio_tree.c	2004-05-22 14:56:30.624435904 -0700
@@ -628,28 +628,37 @@ struct vm_area_struct *vma_prio_tree_nex
 		 * First call is with NULL vma
 		 */
 		ptr = prio_tree_first(root, iter, begin, end);
-		if (ptr)
-			return prio_tree_entry(ptr, struct vm_area_struct,
+		if (ptr) {
+			next = prio_tree_entry(ptr, struct vm_area_struct,
 						shared.prio_tree_node);
-		else
+			prefetch(next->shared.vm_set.head);
+			return next;
+		} else
 			return NULL;
 	}
 
 	if (vma->shared.vm_set.parent) {
-		if (vma->shared.vm_set.head)
-			return vma->shared.vm_set.head;
+		if (vma->shared.vm_set.head) {
+			next = vma->shared.vm_set.head;
+			prefetch(next->shared.vm_set.list.next);
+			return next;
+		}
 	} else {
 		next = list_entry(vma->shared.vm_set.list.next,
 				struct vm_area_struct, shared.vm_set.list);
-		if (!next->shared.vm_set.head)
+		if (!next->shared.vm_set.head) {
+			prefetch(next->shared.vm_set.list.next);
 			return next;
+		}
 	}
 
 	ptr = prio_tree_next(root, iter, begin, end);
-	if (ptr)
-		return prio_tree_entry(ptr, struct vm_area_struct,
+	if (ptr) {
+		next = prio_tree_entry(ptr, struct vm_area_struct,
 					shared.prio_tree_node);
-	else
+		prefetch(next->shared.vm_set.head);
+		return next;
+	} else
 		return NULL;
 }
 EXPORT_SYMBOL(vma_prio_tree_next);

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
