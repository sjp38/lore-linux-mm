Received: from willy by www.linux.org.uk with local (Exim 3.13 #1)
	id 14I1gh-0004pS-00
	for linux-mm@kvack.org; Mon, 15 Jan 2001 04:56:11 +0000
Date: Mon, 15 Jan 2001 04:56:11 +0000
From: Matthew Wilcox <matthew@wil.cx>
Subject: find_vma_prev rewrite
Message-ID: <20010115045611.E8375@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On PA-RISC and IA-64, we have vm areas which can grow up as well as down, o
we have to use find_vma_prev in our fault handlers.  on pa-risc, the upwards
growing vma can be the last vma in the address space, so we need `prev' to
be returned even if there's no `vma' for this address.  Plus the current
find_vma_prev code is ugly, and I had a hard time proving to mysel it was
right.

So here's a rewrite, which has been tested on pa-risc.  if it's wrong,
it won't get to a login prompt.

Index: mm/mmap.c
===================================================================
RCS file: /var/cvs/linux/mm/mmap.c,v
retrieving revision 1.1.1.4
diff -u -p -r1.1.1.4 mmap.c
--- mm/mmap.c	2001/01/01 10:33:08	1.1.1.4
+++ mm/mmap.c	2001/01/15 04:20:29
@@ -443,52 +443,46 @@ struct vm_area_struct * find_vma(struct 
 struct vm_area_struct * find_vma_prev(struct mm_struct * mm, unsigned long addr,
 				      struct vm_area_struct **pprev)
 {
-	if (mm) {
-		if (!mm->mmap_avl) {
-			/* Go through the linear list. */
-			struct vm_area_struct * prev = NULL;
-			struct vm_area_struct * vma = mm->mmap;
-			while (vma && vma->vm_end <= addr) {
-				prev = vma;
-				vma = vma->vm_next;
-			}
-			*pprev = prev;
-			return vma;
-		} else {
-			/* Go through the AVL tree quickly. */
-			struct vm_area_struct * vma = NULL;
-			struct vm_area_struct * last_turn_right = NULL;
-			struct vm_area_struct * prev = NULL;
-			struct vm_area_struct * tree = mm->mmap_avl;
-			for (;;) {
-				if (tree == vm_avl_empty)
+	struct vm_area_struct *vma = NULL;
+	struct vm_area_struct *prev = NULL;
+	if (!mm)
+		goto out;
+	prev = mm->mmap_cache;
+	if (prev) {
+		vma = prev->vm_next;
+		if (prev->vm_end < addr &&
+				((vma == NULL) || (addr < vma->vm_end)))
+			goto out;
+		prev = NULL;
+	}
+	vma = mm->mmap; /* guard against there being no prev */
+	if (!mm->mmap_avl) {
+		/* Go through the linear list. */
+		while (vma && vma->vm_end <= addr) {
+			prev = vma;
+			vma = vma->vm_next;
+		}
+	} else {
+		/* Go through the AVL tree quickly. */
+		struct vm_area_struct * tree = mm->mmap_avl;
+		while (tree != vm_avl_empty) {
+			if (addr < tree->vm_end) {
+				tree = tree->vm_avl_left;
+			} else {
+				prev = tree;
+				if (tree->vm_next == NULL)
 					break;
-				if (tree->vm_end > addr) {
-					vma = tree;
-					prev = last_turn_right;
-					if (tree->vm_start <= addr)
-						break;
-					tree = tree->vm_avl_left;
-				} else {
-					last_turn_right = tree;
-					tree = tree->vm_avl_right;
-				}
-			}
-			if (vma) {
-				if (vma->vm_avl_left != vm_avl_empty) {
-					prev = vma->vm_avl_left;
-					while (prev->vm_avl_right != vm_avl_empty)
-						prev = prev->vm_avl_right;
-				}
-				if ((prev ? prev->vm_next : mm->mmap) != vma)
-					printk("find_vma_prev: tree inconsistent with list\n");
-				*pprev = prev;
-				return vma;
+				if (addr < tree->vm_next->vm_end)
+					break;
+				tree = tree->vm_avl_right;
 			}
 		}
 	}
-	*pprev = NULL;
-	return NULL;
+	if (prev)
+		mm->mmap_cache = prev;
+out:
+	*pprev = prev;
+	return prev ? prev->vm_next : vma;
 }
 
 struct vm_area_struct * find_extend_vma(struct mm_struct * mm, unsigned long addr)

-- 
Revolutions do not require corporate support.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
