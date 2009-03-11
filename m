Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 77BCD6B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 06:01:10 -0400 (EDT)
Received: by yx-out-1718.google.com with SMTP id 4so1162637yxp.26
        for <linux-mm@kvack.org>; Wed, 11 Mar 2009 03:01:09 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 11 Mar 2009 12:01:09 +0200
Message-ID: <8c5a844a0903110301w57c1d3e7k5e76d371ae33147d@mail.gmail.com>
Subject: [PATCH 2/2] mm: use list.h for vma list
From: Daniel Lowengrub <lowdanie@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

Now that the vmas are stored as a doubly linked list the find_vma
function can be optimized by using the cache
more efficiently.

Signed-off-by: Daniel Lowengrub
---
diff -uNr linux-2.6.28.7.vanilla/mm/mmap.c linux-2.6.28.7/mm/mmap.c
--- linux-2.6.28.7.vanilla/mm/mmap.c	2009-03-11 11:32:02.000000000 +0200
+++ linux-2.6.28.7/mm/mmap.c	2009-03-11 11:37:35.000000000 +0200
@@ -1461,37 +1461,52 @@

 EXPORT_SYMBOL(get_unmapped_area);

+/* Checks if this is the first VMA which satisfies addr < vm_end */
+static inline int after_addr(struct vm_area_struct *vma, unsigned long addr)
+{
+	if (!vma)
+		return 0;
+	if (vma->vm_end > addr) {
+		if (!vma_prev(vma))
+			return 1;
+		if (vma_prev(vma)->vm_end <= addr)
+			return 1;
+	}
+	return 0;
+}
+
 /* Look up the first VMA which satisfies  addr < vm_end,  NULL if none. */
 struct vm_area_struct * find_vma(struct mm_struct * mm, unsigned long addr)
 {
 	struct vm_area_struct *vma = NULL;
-
+	struct rb_node * rb_node;
 	if (mm) {
 		/* Check the cache first. */
 		/* (Cache hit rate is typically around 35%.) */
 		vma = mm->mmap_cache;
-		if (!(vma && vma->vm_end > addr && vma->vm_start <= addr)) {
-			struct rb_node * rb_node;
-
-			rb_node = mm->mm_rb.rb_node;
-			vma = NULL;
-
-			while (rb_node) {
-				struct vm_area_struct * vma_tmp;
-
-				vma_tmp = rb_entry(rb_node,
-						struct vm_area_struct, vm_rb);
-
-				if (vma_tmp->vm_end > addr) {
-					vma = vma_tmp;
-					if (vma_tmp->vm_start <= addr)
-						break;
-					rb_node = rb_node->rb_left;
-				} else
-					rb_node = rb_node->rb_right;
-			}
-			if (vma)
-				mm->mmap_cache = vma;
+		
+		if (after_addr(vma, addr))
+			return vma;
+
+		rb_node = mm->mm_rb.rb_node;
+		vma = NULL;
+
+		while (rb_node) {
+			struct vm_area_struct * vma_tmp;
+
+			vma_tmp = rb_entry(rb_node,
+					struct vm_area_struct, vm_rb);
+
+			if (vma_tmp->vm_end > addr) {
+				vma = vma_tmp;
+				if (vma_tmp->vm_start <= addr)
+					break;
+				rb_node = rb_node->rb_left;
+			} else
+				rb_node = rb_node->rb_right;
+		}
+		if (vma)
+			mm->mmap_cache = vma;
 		}
 	}
 	return vma;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
