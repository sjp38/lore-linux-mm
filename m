Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 31BD66B010D
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 17:57:51 -0400 (EDT)
From: Rik van Riel <riel@surriel.com>
Subject: [PATCH -mm v2 01/11] mm: track free size between VMAs in VMA rbtree
Date: Thu, 21 Jun 2012 17:57:05 -0400
Message-Id: <1340315835-28571-2-git-send-email-riel@surriel.com>
In-Reply-To: <1340315835-28571-1-git-send-email-riel@surriel.com>
References: <1340315835-28571-1-git-send-email-riel@surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, aarcange@redhat.com, peterz@infradead.org, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org, Rik van Riel <riel@surriel.com>, Rik van Riel <riel@redhat.com>

Track the size of free areas between VMAs in the VMA rbtree.

This will allow get_unmapped_area_* to find a free area of the
right size in O(log(N)) time, instead of potentially having to
do a linear walk across all the VMAs.

This does have the potential to make unmapping VMAs more expensive,
especially for processes with very large numbers of VMAs, where the
VMA rbtree can grow quite deep.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
 include/linux/mm_types.h |    8 ++++
 include/linux/rbtree.h   |    8 ++++
 mm/internal.h            |    5 +++
 mm/mmap.c                |   84 ++++++++++++++++++++++++++++++++++++++++++++--
 4 files changed, 102 insertions(+), 3 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index dad95bd..9fc0291 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -213,6 +213,14 @@ struct vm_area_struct {
 	struct rb_node vm_rb;
 
 	/*
+	 * Largest free memory gap in bytes to the left of this VMA.
+	 * Either between this VMA and vma->vm_prev, or between one of the
+	 * VMAs below us in the VMA rbtree and its ->vm_prev. This helps
+	 * get_unmapped_area find a free area of the right size.
+	 */
+	unsigned long free_gap;
+
+	/*
 	 * For areas with an address space and backing store,
 	 * linkage into the address_space->i_mmap prio tree, or
 	 * linkage to the list of like vmas hanging off its node, or
diff --git a/include/linux/rbtree.h b/include/linux/rbtree.h
index 033b507..661288d 100644
--- a/include/linux/rbtree.h
+++ b/include/linux/rbtree.h
@@ -155,6 +155,14 @@ extern struct rb_node *rb_augment_erase_begin(struct rb_node *node);
 extern void rb_augment_erase_end(struct rb_node *node,
 				 rb_augment_f func, void *data);
 
+static inline void rb_augment_erase(struct rb_node *node, struct rb_root *root,
+				    rb_augment_f func, void *data)
+{
+	struct rb_node *deepest = rb_augment_erase_begin(node);
+	rb_erase(node, root);
+	rb_augment_erase_end(deepest, func, data);
+}
+
 /* Find logical next and previous nodes in a tree */
 extern struct rb_node *rb_next(const struct rb_node *);
 extern struct rb_node *rb_prev(const struct rb_node *);
diff --git a/mm/internal.h b/mm/internal.h
index 2ba87fb..f59f97a 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -159,6 +159,11 @@ static inline void munlock_vma_pages_all(struct vm_area_struct *vma)
 	munlock_vma_pages_range(vma, vma->vm_start, vma->vm_end);
 }
 
+static inline struct vm_area_struct *rb_to_vma(struct rb_node *node)
+{
+	return container_of(node, struct vm_area_struct, vm_rb);
+}
+
 /*
  * Called only in fault path via page_evictable() for a new page
  * to determine if it's being mapped into a LOCKED vma.
diff --git a/mm/mmap.c b/mm/mmap.c
index 3edfcdf..dd6edcd 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -206,6 +206,60 @@ static void __remove_shared_vm_struct(struct vm_area_struct *vma,
 }
 
 /*
+ * largest_free_gap - returns the largest free gap "nearby"
+ *
+ * This function is called when propagating information on the
+ * free spaces between VMAs "up" the VMA rbtree. It returns the
+ * largest of:
+ *
+ * 1. The gap between this VMA and vma->vm_prev.
+ * 2. The largest gap below us and to our left in the rbtree.
+ * 3. The largest gap below us and to our right in the rbtree.
+ */
+static unsigned long largest_free_gap(struct rb_node *node)
+{
+	struct vm_area_struct *vma, *prev, *left = NULL, *right = NULL;
+	unsigned long largest = 0;
+
+	if (node->rb_left)
+		left = rb_to_vma(node->rb_left);
+	if (node->rb_right)
+		right = rb_to_vma(node->rb_right);
+
+	/* Calculate the free gap size between us and the VMA to our left. */
+	vma = rb_to_vma(node);
+	prev = vma->vm_prev;
+
+	if (prev)
+		largest = vma->vm_start - prev->vm_end;
+	else
+		largest = vma->vm_start;
+
+	/* We propagate the largest of our own, or our children's free gaps. */
+	if (left)
+		largest = max(largest, left->free_gap);
+	if (right)
+		largest = max(largest, right->free_gap);
+
+	return largest;
+}
+
+static void vma_rb_augment_cb(struct rb_node *node, void *__unused)
+{
+	struct vm_area_struct *vma = rb_to_vma(node);
+	vma->free_gap = largest_free_gap(node);
+}
+
+/*
+ * Use the augmented rbtree code to propagate info on the largest
+ * free gap between VMAs up the VMA rbtree.
+ */
+static void adjust_free_gap(struct vm_area_struct *vma)
+{
+	rb_augment_erase_end(&vma->vm_rb, vma_rb_augment_cb, NULL);
+}
+
+/*
  * Unlink a file-based vm structure from its prio_tree, to hide
  * vma from rmap and vmtruncate before freeing its page tables.
  */
@@ -342,6 +396,8 @@ void validate_mm(struct mm_struct *mm)
 	int i = 0;
 	struct vm_area_struct *tmp = mm->mmap;
 	while (tmp) {
+		if (tmp->free_gap != largest_free_gap(&tmp->vm_rb))
+			printk("free space %lx, correct %lx\n", tmp->free_gap, largest_free_gap(&tmp->vm_rb)), bug = 1;
 		tmp = tmp->vm_next;
 		i++;
 	}
@@ -398,6 +454,10 @@ void __vma_link_rb(struct mm_struct *mm, struct vm_area_struct *vma,
 {
 	rb_link_node(&vma->vm_rb, rb_parent, rb_link);
 	rb_insert_color(&vma->vm_rb, &mm->mm_rb);
+	adjust_free_gap(vma);
+	/* Propagate the new free gap between next and us up the tree. */
+	if (vma->vm_next)
+		adjust_free_gap(vma->vm_next);
 }
 
 static void __vma_link_file(struct vm_area_struct *vma)
@@ -475,9 +535,12 @@ __vma_unlink(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct vm_area_struct *next = vma->vm_next;
 
 	prev->vm_next = next;
-	if (next)
+	if (next) {
 		next->vm_prev = prev;
-	rb_erase(&vma->vm_rb, &mm->mm_rb);
+		adjust_free_gap(next);
+	}
+	rb_augment_erase(&vma->vm_rb, &mm->mm_rb, vma_rb_augment_cb, NULL);
+
 	if (mm->mmap_cache == vma)
 		mm->mmap_cache = prev;
 }
@@ -657,6 +720,15 @@ again:			remove_next = 1 + (end > next->vm_end);
 	if (insert && file)
 		uprobe_mmap(insert);
 
+	/* Adjust the rb tree for changes in the free gaps between VMAs. */
+	adjust_free_gap(vma);
+	if (insert)
+		adjust_free_gap(insert);
+	if (vma->vm_next && vma->vm_next != insert)
+		adjust_free_gap(vma->vm_next);
+	if (insert && insert->vm_next && insert->vm_next != vma)
+		adjust_free_gap(insert->vm_next);
+
 	validate_mm(mm);
 
 	return 0;
@@ -1760,6 +1832,8 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
 			error = acct_stack_growth(vma, size, grow);
 			if (!error) {
 				vma->vm_end = address;
+				if (vma->vm_next)
+					adjust_free_gap(vma->vm_next);
 				perf_event_mmap(vma);
 			}
 		}
@@ -1811,6 +1885,7 @@ int expand_downwards(struct vm_area_struct *vma,
 			if (!error) {
 				vma->vm_start = address;
 				vma->vm_pgoff -= grow;
+				adjust_free_gap(vma);
 				perf_event_mmap(vma);
 			}
 		}
@@ -1933,7 +2008,8 @@ detach_vmas_to_be_unmapped(struct mm_struct *mm, struct vm_area_struct *vma,
 	insertion_point = (prev ? &prev->vm_next : &mm->mmap);
 	vma->vm_prev = NULL;
 	do {
-		rb_erase(&vma->vm_rb, &mm->mm_rb);
+		rb_augment_erase(&vma->vm_rb, &mm->mm_rb,
+				 vma_rb_augment_cb, NULL);
 		mm->map_count--;
 		tail_vma = vma;
 		vma = vma->vm_next;
@@ -1941,6 +2017,8 @@ detach_vmas_to_be_unmapped(struct mm_struct *mm, struct vm_area_struct *vma,
 	*insertion_point = vma;
 	if (vma)
 		vma->vm_prev = prev;
+	if (vma)
+		rb_augment_erase_end(&vma->vm_rb, vma_rb_augment_cb, NULL);
 	tail_vma->vm_next = NULL;
 	if (mm->unmap_area == arch_unmap_area)
 		addr = prev ? prev->vm_end : mm->mmap_base;
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
