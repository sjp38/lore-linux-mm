Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 6832B6B005D
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 06:51:47 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so574764pbc.14
        for <linux-mm@kvack.org>; Mon, 12 Nov 2012 03:51:46 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 1/3] mm: ensure safe rb_subtree_gap update when inserting new VMA
Date: Mon, 12 Nov 2012 03:51:29 -0800
Message-Id: <1352721091-27022-2-git-send-email-walken@google.com>
In-Reply-To: <1352721091-27022-1-git-send-email-walken@google.com>
References: <1352721091-27022-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Sasha Levin <levinsasha928@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Using the trinity fuzzer, Sasha Levin uncovered a case where
rb_subtree_gap wasn't correctly updated.

Digging into this, the root cause was that vma insertions and removals
require both an rbtree insert or erase operation (which may trigger
tree rotations), and an update of the next vma's gap (which does not
change the tree topology, but may require iterating on the node's
ancestors to propagate the update). The rbtree rotations caused the
rb_subtree_gap values to be updated in some of the internal nodes, but
without upstream propagation. Then the subsequent update on the next
vma didn't iterate as high up the tree as it should have, as it
stopped as soon as it hit one of the internal nodes that had been
updated as part of a tree rotation.

The fix is to impose that all rb_subtree_gap values must be up to date
before any rbtree insertion or erase, with the possible exception that
the node being erased doesn't need to have an up to date rb_subtree_gap.

This change: during vma insertion, make sure to update the rb_subtree_gap
values for both the current and next vmas prior to rebalancing the rbtree
to account for the just-inserted vma.

(Thanks to Sasha Levin for uncovering the problem and to Hugh Dickins
for coming up with a simpler test case)

Reported-by: Sasha Levin <sasha.levin@oracle.com>
Signed-off-by: Michel Lespinasse <walken@google.com>

---
 mm/mmap.c |   27 +++++++++++++++------------
 1 files changed, 15 insertions(+), 12 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 619b280505fe..14859b999a9f 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -339,17 +339,7 @@ static void vma_gap_update(struct vm_area_struct *vma)
 static inline void vma_rb_insert(struct vm_area_struct *vma,
 				 struct rb_root *root)
 {
-	/*
-	 * vma->vm_prev wasn't known when we followed the rbtree to find the
-	 * correct insertion point for that vma. As a result, we could not
-	 * update the vma vm_rb parents rb_subtree_gap values on the way down.
-	 * So, we first insert the vma with a zero rb_subtree_gap value
-	 * (to be consistent with what we did on the way down), and then
-	 * immediately update the gap to the correct value.
-	 */
-	vma->rb_subtree_gap = 0;
 	rb_insert_augmented(&vma->vm_rb, root, &vma_gap_callbacks);
-	vma_gap_update(vma);
 }
 
 static void vma_rb_erase(struct vm_area_struct *vma, struct rb_root *root)
@@ -494,12 +484,25 @@ static int find_vma_links(struct mm_struct *mm, unsigned long addr,
 void __vma_link_rb(struct mm_struct *mm, struct vm_area_struct *vma,
 		struct rb_node **rb_link, struct rb_node *rb_parent)
 {
-	rb_link_node(&vma->vm_rb, rb_parent, rb_link);
-	vma_rb_insert(vma, &mm->mm_rb);
+	/* Update tracking information for the gap following the new vma. */
 	if (vma->vm_next)
 		vma_gap_update(vma->vm_next);
 	else
 		mm->highest_vm_end = vma->vm_end;
+
+	/*
+	 * vma->vm_prev wasn't known when we followed the rbtree to find the
+	 * correct insertion point for that vma. As a result, we could not
+	 * update the vma vm_rb parents rb_subtree_gap values on the way down.
+	 * So, we first insert the vma with a zero rb_subtree_gap value
+	 * (to be consistent with what we did on the way down), and then
+	 * immediately update the gap to the correct value. Finally we
+	 * rebalance the rbtree after all augmented values have been set.
+	 */
+	rb_link_node(&vma->vm_rb, rb_parent, rb_link);
+	vma->rb_subtree_gap = 0;
+	vma_gap_update(vma);
+	vma_rb_insert(vma, &mm->mm_rb);
 }
 
 static void __vma_link_file(struct vm_area_struct *vma)
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
