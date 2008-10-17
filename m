Date: Fri, 17 Oct 2008 07:01:20 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch][rfc] mm: have expand_stack honour VM_LOCKED
Message-ID: <20081017050120.GA28605@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Is this valid?


It appears that direct callers of expand_stack may not properly lock the newly
expanded stack if they don't call make_pages_present (page fault handlers do
this).

Catch all these cases by moving make_pages_present to expand_stack.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/mm/mmap.c
===================================================================
--- linux-2.6.orig/mm/mmap.c
+++ linux-2.6/mm/mmap.c
@@ -1590,6 +1590,7 @@ static inline
 #endif
 int expand_upwards(struct vm_area_struct *vma, unsigned long address)
 {
+	unsigned long grow = 0;
 	int error;
 
 	if (!(vma->vm_flags & VM_GROWSUP))
@@ -1619,7 +1620,7 @@ int expand_upwards(struct vm_area_struct
 
 	/* Somebody else might have raced and expanded it already */
 	if (address > vma->vm_end) {
-		unsigned long size, grow;
+		unsigned long size;
 
 		size = address - vma->vm_start;
 		grow = (address - vma->vm_end) >> PAGE_SHIFT;
@@ -1629,6 +1630,11 @@ int expand_upwards(struct vm_area_struct
 			vma->vm_end = address;
 	}
 	anon_vma_unlock(vma);
+
+	if (grow && vma->vm_flags & VM_LOCKED)
+		make_pages_present(vma->vm_end - (grow << PAGE_SHIFT),
+								vma->vm_end);
+
 	return error;
 }
 #endif /* CONFIG_STACK_GROWSUP || CONFIG_IA64 */
@@ -1639,6 +1645,7 @@ int expand_upwards(struct vm_area_struct
 static inline int expand_downwards(struct vm_area_struct *vma,
 				   unsigned long address)
 {
+	unsigned long grow = 0;
 	int error;
 
 	/*
@@ -1663,7 +1670,7 @@ static inline int expand_downwards(struc
 
 	/* Somebody else might have raced and expanded it already */
 	if (address < vma->vm_start) {
-		unsigned long size, grow;
+		unsigned long size;
 
 		size = vma->vm_end - address;
 		grow = (vma->vm_start - address) >> PAGE_SHIFT;
@@ -1675,6 +1682,11 @@ static inline int expand_downwards(struc
 		}
 	}
 	anon_vma_unlock(vma);
+
+	if (grow && vma->vm_flags & VM_LOCKED)
+		make_pages_present(vma->vm_start,
+				vma->vm_start + (grow << PAGE_SHIFT));
+
 	return error;
 }
 
@@ -1700,8 +1712,6 @@ find_extend_vma(struct mm_struct *mm, un
 		return vma;
 	if (!prev || expand_stack(prev, addr))
 		return NULL;
-	if (prev->vm_flags & VM_LOCKED)
-		make_pages_present(addr, prev->vm_end);
 	return prev;
 }
 #else
@@ -1727,8 +1737,6 @@ find_extend_vma(struct mm_struct * mm, u
 	start = vma->vm_start;
 	if (expand_stack(vma, addr))
 		return NULL;
-	if (vma->vm_flags & VM_LOCKED)
-		make_pages_present(addr, start);
 	return vma;
 }
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
