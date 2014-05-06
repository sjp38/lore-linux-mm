Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 7FB7E82963
	for <linux-mm@kvack.org>; Tue,  6 May 2014 10:37:43 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kp14so6687691pab.26
        for <linux-mm@kvack.org>; Tue, 06 May 2014 07:37:42 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id yb4si12138493pab.103.2014.05.06.07.37.42
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 07:37:42 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 5/8] mm, rmap: kill vma->shared.nonlinear
Date: Tue,  6 May 2014 17:37:29 +0300
Message-Id: <1399387052-31660-6-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1399387052-31660-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1399387052-31660-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, peterz@infradead.org, mingo@kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Nobody creates nonlinear VMAs. No need to support them.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h       |  6 ------
 include/linux/mm_types.h | 12 +++---------
 kernel/fork.c            |  8 ++------
 mm/interval_tree.c       | 34 +++++++++++++++++-----------------
 mm/mmap.c                | 10 ++--------
 5 files changed, 24 insertions(+), 46 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 156ca8025cec..d8dc4cd58704 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1721,12 +1721,6 @@ struct vm_area_struct *vma_interval_tree_iter_next(struct vm_area_struct *node,
 	for (vma = vma_interval_tree_iter_first(root, start, last);	\
 	     vma; vma = vma_interval_tree_iter_next(vma, start, last))
 
-static inline void vma_nonlinear_insert(struct vm_area_struct *vma,
-					struct list_head *list)
-{
-	list_add_tail(&vma->shared.nonlinear, list);
-}
-
 void anon_vma_interval_tree_insert(struct anon_vma_chain *node,
 				   struct rb_root *root);
 void anon_vma_interval_tree_remove(struct anon_vma_chain *node,
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 8967e20cbe57..4a586fa37720 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -272,16 +272,10 @@ struct vm_area_struct {
 
 	/*
 	 * For areas with an address space and backing store,
-	 * linkage into the address_space->i_mmap interval tree, or
-	 * linkage of vma in the address_space->i_mmap_nonlinear list.
+	 * linkage into the address_space->i_mmap interval tree.
 	 */
-	union {
-		struct {
-			struct rb_node rb;
-			unsigned long rb_subtree_last;
-		} linear;
-		struct list_head nonlinear;
-	} shared;
+	struct rb_node shared_rb;
+	unsigned long shared_rb_subtree_last;
 
 	/*
 	 * A file's MAP_PRIVATE vma can be in both i_mmap tree and anon_vma
diff --git a/kernel/fork.c b/kernel/fork.c
index 54a8d26f612f..b4fc21e42688 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -424,12 +424,8 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 				mapping->i_mmap_writable++;
 			flush_dcache_mmap_lock(mapping);
 			/* insert tmp into the share list, just after mpnt */
-			if (unlikely(tmp->vm_flags & VM_NONLINEAR))
-				vma_nonlinear_insert(tmp,
-						&mapping->i_mmap_nonlinear);
-			else
-				vma_interval_tree_insert_after(tmp, mpnt,
-							&mapping->i_mmap);
+			vma_interval_tree_insert_after(tmp, mpnt,
+					&mapping->i_mmap);
 			flush_dcache_mmap_unlock(mapping);
 			mutex_unlock(&mapping->i_mmap_mutex);
 		}
diff --git a/mm/interval_tree.c b/mm/interval_tree.c
index 4a5822a586e6..06d75a9ba00c 100644
--- a/mm/interval_tree.c
+++ b/mm/interval_tree.c
@@ -21,8 +21,8 @@ static inline unsigned long vma_last_pgoff(struct vm_area_struct *v)
 	return v->vm_pgoff + ((v->vm_end - v->vm_start) >> PAGE_SHIFT) - 1;
 }
 
-INTERVAL_TREE_DEFINE(struct vm_area_struct, shared.linear.rb,
-		     unsigned long, shared.linear.rb_subtree_last,
+INTERVAL_TREE_DEFINE(struct vm_area_struct, shared_rb,
+		     unsigned long, shared_rb_subtree_last,
 		     vma_start_pgoff, vma_last_pgoff,, vma_interval_tree)
 
 /* Insert node immediately after prev in the interval tree */
@@ -36,26 +36,26 @@ void vma_interval_tree_insert_after(struct vm_area_struct *node,
 
 	VM_BUG_ON(vma_start_pgoff(node) != vma_start_pgoff(prev));
 
-	if (!prev->shared.linear.rb.rb_right) {
+	if (!prev->shared_rb.rb_right) {
 		parent = prev;
-		link = &prev->shared.linear.rb.rb_right;
+		link = &prev->shared_rb.rb_right;
 	} else {
-		parent = rb_entry(prev->shared.linear.rb.rb_right,
-				  struct vm_area_struct, shared.linear.rb);
-		if (parent->shared.linear.rb_subtree_last < last)
-			parent->shared.linear.rb_subtree_last = last;
-		while (parent->shared.linear.rb.rb_left) {
-			parent = rb_entry(parent->shared.linear.rb.rb_left,
-				struct vm_area_struct, shared.linear.rb);
-			if (parent->shared.linear.rb_subtree_last < last)
-				parent->shared.linear.rb_subtree_last = last;
+		parent = rb_entry(prev->shared_rb.rb_right,
+				  struct vm_area_struct, shared_rb);
+		if (parent->shared_rb_subtree_last < last)
+			parent->shared_rb_subtree_last = last;
+		while (parent->shared_rb.rb_left) {
+			parent = rb_entry(parent->shared_rb.rb_left,
+				struct vm_area_struct, shared_rb);
+			if (parent->shared_rb_subtree_last < last)
+				parent->shared_rb_subtree_last = last;
 		}
-		link = &parent->shared.linear.rb.rb_left;
+		link = &parent->shared_rb.rb_left;
 	}
 
-	node->shared.linear.rb_subtree_last = last;
-	rb_link_node(&node->shared.linear.rb, &parent->shared.linear.rb, link);
-	rb_insert_augmented(&node->shared.linear.rb, root,
+	node->shared_rb_subtree_last = last;
+	rb_link_node(&node->shared_rb, &parent->shared_rb, link);
+	rb_insert_augmented(&node->shared_rb, root,
 			    &vma_interval_tree_augment);
 }
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 4106fc833f56..8be242f07439 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -216,10 +216,7 @@ static void __remove_shared_vm_struct(struct vm_area_struct *vma,
 		mapping->i_mmap_writable--;
 
 	flush_dcache_mmap_lock(mapping);
-	if (unlikely(vma->vm_flags & VM_NONLINEAR))
-		list_del_init(&vma->shared.nonlinear);
-	else
-		vma_interval_tree_remove(vma, &mapping->i_mmap);
+	vma_interval_tree_remove(vma, &mapping->i_mmap);
 	flush_dcache_mmap_unlock(mapping);
 }
 
@@ -617,10 +614,7 @@ static void __vma_link_file(struct vm_area_struct *vma)
 			mapping->i_mmap_writable++;
 
 		flush_dcache_mmap_lock(mapping);
-		if (unlikely(vma->vm_flags & VM_NONLINEAR))
-			vma_nonlinear_insert(vma, &mapping->i_mmap_nonlinear);
-		else
-			vma_interval_tree_insert(vma, &mapping->i_mmap);
+		vma_interval_tree_insert(vma, &mapping->i_mmap);
 		flush_dcache_mmap_unlock(mapping);
 	}
 }
-- 
2.0.0.rc0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
