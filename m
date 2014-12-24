Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 133BE6B0071
	for <linux-mm@kvack.org>; Wed, 24 Dec 2014 07:23:11 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id kx10so10027137pab.30
        for <linux-mm@kvack.org>; Wed, 24 Dec 2014 04:23:10 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id j2si34277738pdo.128.2014.12.24.04.23.03
        for <linux-mm@kvack.org>;
        Wed, 24 Dec 2014 04:23:04 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 06/38] mm: replace vma->sharead.linear with vma->shared
Date: Wed, 24 Dec 2014 14:22:14 +0200
Message-Id: <1419423766-114457-7-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, hughd@google.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

After removing vma->shared.nonlinear we have only one member of
vma->shared union, which doesn't make much sense.

This patch drops the union and move struct vma->shared.linear to
vma->shared.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm_types.h |  8 +++-----
 mm/interval_tree.c       | 34 +++++++++++++++++-----------------
 2 files changed, 20 insertions(+), 22 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 3b1d20fb0848..07c8bd3f7b48 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -275,11 +275,9 @@ struct vm_area_struct {
 	 * For areas with an address space and backing store,
 	 * linkage into the address_space->i_mmap interval tree.
 	 */
-	union {
-		struct {
-			struct rb_node rb;
-			unsigned long rb_subtree_last;
-		} linear;
+	struct {
+		struct rb_node rb;
+		unsigned long rb_subtree_last;
 	} shared;
 
 	/*
diff --git a/mm/interval_tree.c b/mm/interval_tree.c
index 8da581fa9060..f2c2492681bf 100644
--- a/mm/interval_tree.c
+++ b/mm/interval_tree.c
@@ -21,8 +21,8 @@ static inline unsigned long vma_last_pgoff(struct vm_area_struct *v)
 	return v->vm_pgoff + ((v->vm_end - v->vm_start) >> PAGE_SHIFT) - 1;
 }
 
-INTERVAL_TREE_DEFINE(struct vm_area_struct, shared.linear.rb,
-		     unsigned long, shared.linear.rb_subtree_last,
+INTERVAL_TREE_DEFINE(struct vm_area_struct, shared.rb,
+		     unsigned long, shared.rb_subtree_last,
 		     vma_start_pgoff, vma_last_pgoff,, vma_interval_tree)
 
 /* Insert node immediately after prev in the interval tree */
@@ -36,26 +36,26 @@ void vma_interval_tree_insert_after(struct vm_area_struct *node,
 
 	VM_BUG_ON_VMA(vma_start_pgoff(node) != vma_start_pgoff(prev), node);
 
-	if (!prev->shared.linear.rb.rb_right) {
+	if (!prev->shared.rb.rb_right) {
 		parent = prev;
-		link = &prev->shared.linear.rb.rb_right;
+		link = &prev->shared.rb.rb_right;
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
+		parent = rb_entry(prev->shared.rb.rb_right,
+				  struct vm_area_struct, shared.rb);
+		if (parent->shared.rb_subtree_last < last)
+			parent->shared.rb_subtree_last = last;
+		while (parent->shared.rb.rb_left) {
+			parent = rb_entry(parent->shared.rb.rb_left,
+				struct vm_area_struct, shared.rb);
+			if (parent->shared.rb_subtree_last < last)
+				parent->shared.rb_subtree_last = last;
 		}
-		link = &parent->shared.linear.rb.rb_left;
+		link = &parent->shared.rb.rb_left;
 	}
 
-	node->shared.linear.rb_subtree_last = last;
-	rb_link_node(&node->shared.linear.rb, &parent->shared.linear.rb, link);
-	rb_insert_augmented(&node->shared.linear.rb, root,
+	node->shared.rb_subtree_last = last;
+	rb_link_node(&node->shared.rb, &parent->shared.rb, link);
+	rb_insert_augmented(&node->shared.rb, root,
 			    &vma_interval_tree_augment);
 }
 
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
