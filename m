Date: Tue, 2 Jul 2002 18:36:49 +0100
From: Matthew Wilcox <willy@debian.org>
Subject: [PATCH] rewrite find_vma_prev
Message-ID: <20020702183649.B27706@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

For PA-RISC, we need find_vma_prev to return `prev', even if vma is NULL.
Our stack is at the top of memory, growing upwards, so when we page fault
we need to see prev.  For added bonus points, the code becomes simpler,
less indented, shorter and (for me, anyway) easier to understand.  The
code is well-tested, even on x86.  For PA and ia64 this code is called in
the page fault handler path so it is exercised frequently.

diff -urNX dontdiff linux-2.5.24/mm/mmap.c linux-2.5.24-mm/mm/mmap.c
--- linux-2.5.24/mm/mmap.c	Thu Jun 20 16:53:43 2002
+++ linux-2.5.24-mm/mm/mmap.c	Thu Jun 27 07:35:55 2002
@@ -669,49 +669,53 @@
 struct vm_area_struct * find_vma_prev(struct mm_struct * mm, unsigned long addr,
 				      struct vm_area_struct **pprev)
 {
-	if (mm) {
-		/* Go through the RB tree quickly. */
-		struct vm_area_struct * vma;
-		rb_node_t * rb_node, * rb_last_right, * rb_prev;
-		
-		rb_node = mm->mm_rb.rb_node;
-		rb_last_right = rb_prev = NULL;
-		vma = NULL;
-
-		while (rb_node) {
-			struct vm_area_struct * vma_tmp;
-
-			vma_tmp = rb_entry(rb_node, struct vm_area_struct, vm_rb);
-
-			if (vma_tmp->vm_end > addr) {
-				vma = vma_tmp;
-				rb_prev = rb_last_right;
-				if (vma_tmp->vm_start <= addr)
-					break;
-				rb_node = rb_node->rb_left;
-			} else {
-				rb_last_right = rb_node;
-				rb_node = rb_node->rb_right;
-			}
-		}
-		if (vma) {
-			if (vma->vm_rb.rb_left) {
-				rb_prev = vma->vm_rb.rb_left;
-				while (rb_prev->rb_right)
-					rb_prev = rb_prev->rb_right;
-			}
-			*pprev = NULL;
-			if (rb_prev)
-				*pprev = rb_entry(rb_prev, struct vm_area_struct, vm_rb);
-			if ((rb_prev ? (*pprev)->vm_next : mm->mmap) != vma)
-				BUG();
-			return vma;
+	struct vm_area_struct *vma = NULL, *prev = NULL;
+	rb_node_t * rb_node;
+	if (!mm)
+		goto out;
+
+	/* Guard against addr being lower than the first VMA */
+	vma = mm->mmap;
+
+	/* Go through the RB tree quickly. */
+	rb_node = mm->mm_rb.rb_node;
+
+	while (rb_node) {
+		struct vm_area_struct *vma_tmp;
+		vma_tmp = rb_entry(rb_node, struct vm_area_struct, vm_rb);
+
+		if (addr < vma_tmp->vm_end) {
+			rb_node = rb_node->rb_left;
+		} else {
+			prev = vma_tmp;
+			if (!prev->vm_next || (addr < prev->vm_next->vm_end))
+				break;
+			rb_node = rb_node->rb_right;
 		}
 	}
-	*pprev = NULL;
-	return NULL;
+
+ out:
+	*pprev = prev;
+	return prev ? prev->vm_next : vma;
 }
 
+#ifdef ARCH_STACK_GROWSUP
+struct vm_area_struct * find_extend_vma(struct mm_struct * mm, unsigned long addr)
+{
+	struct vm_area_struct *vma, *prev;
+
+	addr &= PAGE_MASK;
+	vma = find_vma_prev(mm, addr, &prev);
+	if (vma && (vma->vm_start <= addr))
+		return vma;
+	if (!prev || expand_stack(prev, addr))
+		return NULL;
+	if (prev->vm_flags & VM_LOCKED) {
+		make_pages_present(addr, prev->vm_end);
+	}
+	return prev;
+}
+#else
 struct vm_area_struct * find_extend_vma(struct mm_struct * mm, unsigned long addr)
 {
 	struct vm_area_struct * vma;
@@ -733,6 +737,7 @@
 	}
 	return vma;
 }
+#endif
 
 /*
  * Try to free as many page directory entries as we can,

-- 
Revolutions do not require corporate support.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
