Received: from willy by www.linux.org.uk with local (Exim 3.33 #5)
	id 17NasH-0003fU-00
	for linux-mm@kvack.org; Thu, 27 Jun 2002 16:07:57 +0100
Date: Thu, 27 Jun 2002 16:07:57 +0100
From: Matthew Wilcox <willy@debian.org>
Subject: [PATCH] find_vma_prev rewrite
Message-ID: <20020627160757.A13056@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I've been sending patches like this for over 18 months now with
no comments.  I'm sending it to Linus early next week.  It benefits
ia64's fault handler path and is required for PA-RISC's fault handler.
It works, it's tested.  I realise this puts it in a very different class
from the kind of VM patches which are allowed in a stable kernel tree.

There's also a chunk after find_vma_prev which adds an implementation
of find_extend_vma for machines with stacks which grow up.  I couldn't
be bothered to split it out, since it won't affect any other architecture.

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
