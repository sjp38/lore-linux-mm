Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id EE8E26B005D
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 06:51:49 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so574764pbc.14
        for <linux-mm@kvack.org>; Mon, 12 Nov 2012 03:51:49 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 3/3] mm: debug code to verify rb_subtree_gap updates are safe
Date: Mon, 12 Nov 2012 03:51:31 -0800
Message-Id: <1352721091-27022-4-git-send-email-walken@google.com>
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

This change: introduce validate_mm_rb() to verify that the rbtree does
not include any stale rb_subtree_gap values before node insertion or
erase, so as to avoid the issue where a subsequent vma_gap_update() would
fail to propagate the rb_subtree_gap updates as high up as necessary.

Signed-off-by: Michel Lespinasse <walken@google.com>

---
 mm/mmap.c |   88 ++++++++++++++++++++++++++++++++++++++-----------------------
 1 files changed, 55 insertions(+), 33 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index c60ac9fe2d7e..408d330aca6c 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -319,39 +319,6 @@ static long vma_compute_subtree_gap(struct vm_area_struct *vma)
 	return max;
 }
 
-RB_DECLARE_CALLBACKS(static, vma_gap_callbacks, struct vm_area_struct, vm_rb,
-		     unsigned long, rb_subtree_gap, vma_compute_subtree_gap)
-
-/*
- * Update augmented rbtree rb_subtree_gap values after vma->vm_start or
- * vma->vm_prev->vm_end values changed, without modifying the vma's position
- * in the rbtree.
- */
-static void vma_gap_update(struct vm_area_struct *vma)
-{
-	/*
-	 * As it turns out, RB_DECLARE_CALLBACKS() already created a callback
-	 * function that does exacltly what we want.
-	 */
-	vma_gap_callbacks_propagate(&vma->vm_rb, NULL);
-}
-
-static inline void vma_rb_insert(struct vm_area_struct *vma,
-				 struct rb_root *root)
-{
-	rb_insert_augmented(&vma->vm_rb, root, &vma_gap_callbacks);
-}
-
-static void vma_rb_erase(struct vm_area_struct *vma, struct rb_root *root)
-{
-	/*
-	 * Note rb_erase_augmented is a fairly large inline function,
-	 * so make sure we instantiate it only once with our desired
-	 * augmented rbtree callbacks.
-	 */
-	rb_erase_augmented(&vma->vm_rb, root, &vma_gap_callbacks);
-}
-
 #ifdef CONFIG_DEBUG_VM_RB
 static int browse_rb(struct rb_root *root)
 {
@@ -385,6 +352,18 @@ static int browse_rb(struct rb_root *root)
 	return bug ? -1 : i;
 }
 
+static void validate_mm_rb(struct rb_root *root, struct vm_area_struct *ignore)
+{
+	struct rb_node *nd;
+
+	for (nd = rb_first(root); nd; nd = rb_next(nd)) {
+		struct vm_area_struct *vma;
+		vma = rb_entry(nd, struct vm_area_struct, vm_rb);
+		BUG_ON(vma != ignore &&
+		       vma->rb_subtree_gap != vma_compute_subtree_gap(vma));
+	}
+}
+
 void validate_mm(struct mm_struct *mm)
 {
 	int bug = 0;
@@ -412,9 +391,52 @@ void validate_mm(struct mm_struct *mm)
 	BUG_ON(bug);
 }
 #else
+#define validate_mm_rb(root, ignore) do { } while (0)
 #define validate_mm(mm) do { } while (0)
 #endif
 
+RB_DECLARE_CALLBACKS(static, vma_gap_callbacks, struct vm_area_struct, vm_rb,
+		     unsigned long, rb_subtree_gap, vma_compute_subtree_gap)
+
+/*
+ * Update augmented rbtree rb_subtree_gap values after vma->vm_start or
+ * vma->vm_prev->vm_end values changed, without modifying the vma's position
+ * in the rbtree.
+ */
+static void vma_gap_update(struct vm_area_struct *vma)
+{
+	/*
+	 * As it turns out, RB_DECLARE_CALLBACKS() already created a callback
+	 * function that does exacltly what we want.
+	 */
+	vma_gap_callbacks_propagate(&vma->vm_rb, NULL);
+}
+
+static inline void vma_rb_insert(struct vm_area_struct *vma,
+				 struct rb_root *root)
+{
+	/* All rb_subtree_gap values must be consistent prior to insertion */
+	validate_mm_rb(root, NULL);
+
+	rb_insert_augmented(&vma->vm_rb, root, &vma_gap_callbacks);
+}
+
+static void vma_rb_erase(struct vm_area_struct *vma, struct rb_root *root)
+{
+	/*
+	 * All rb_subtree_gap values must be consistent prior to erase,
+	 * with the possible exception of the vma being erased.
+	 */
+	validate_mm_rb(root, vma);
+
+	/*
+	 * Note rb_erase_augmented is a fairly large inline function,
+	 * so make sure we instantiate it only once with our desired
+	 * augmented rbtree callbacks.
+	 */
+	rb_erase_augmented(&vma->vm_rb, root, &vma_gap_callbacks);
+}
+
 /*
  * vma has some anon_vma assigned, and is already inserted on that
  * anon_vma's interval trees.
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
