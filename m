Message-Id: <200405222212.i4MMCBr14242@mail.osdl.org>
Subject: [patch 44/57] rmap 28 remove_vm_struct
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:11:41 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

From: Hugh Dickins <hugh@veritas.com>

The callers of remove_shared_vm_struct then proceed to do several more
identical things: gather them together in remove_vm_struct.


---

 25-akpm/mm/mmap.c |   31 +++++++++++--------------------
 1 files changed, 11 insertions(+), 20 deletions(-)

diff -puN mm/mmap.c~rmap-28-remove_vm_struct mm/mmap.c
--- 25/mm/mmap.c~rmap-28-remove_vm_struct	2004-05-22 14:56:28.576747200 -0700
+++ 25-akpm/mm/mmap.c	2004-05-22 14:59:36.269213608 -0700
@@ -67,7 +67,7 @@ EXPORT_SYMBOL(vm_committed_space);
 /*
  * Requires inode->i_mapping->i_mmap_lock
  */
-static inline void __remove_shared_vm_struct(struct vm_area_struct *vma,
+static void __remove_shared_vm_struct(struct vm_area_struct *vma,
 		struct file *file, struct address_space *mapping)
 {
 	if (vma->vm_flags & VM_DENYWRITE)
@@ -84,9 +84,9 @@ static inline void __remove_shared_vm_st
 }
 
 /*
- * Remove one vm structure from the inode's i_mapping address space.
+ * Remove one vm structure and free it.
  */
-static void remove_shared_vm_struct(struct vm_area_struct *vma)
+static void remove_vm_struct(struct vm_area_struct *vma)
 {
 	struct file *file = vma->vm_file;
 
@@ -96,6 +96,12 @@ static void remove_shared_vm_struct(stru
 		__remove_shared_vm_struct(vma, file, mapping);
 		spin_unlock(&mapping->i_mmap_lock);
 	}
+	if (vma->vm_ops && vma->vm_ops->close)
+		vma->vm_ops->close(vma);
+	if (file)
+		fput(file);
+	mpol_free(vma_policy(vma));
+	kmem_cache_free(vm_area_cachep, vma);
 }
 
 /*
@@ -1165,14 +1171,7 @@ static void unmap_vma(struct mm_struct *
 				area->vm_start < area->vm_mm->free_area_cache)
 	      area->vm_mm->free_area_cache = area->vm_start;
 
-	remove_shared_vm_struct(area);
-
-	mpol_free(vma_policy(area));
-	if (area->vm_ops && area->vm_ops->close)
-		area->vm_ops->close(area);
-	if (area->vm_file)
-		fput(area->vm_file);
-	kmem_cache_free(vm_area_cachep, area);
+	remove_vm_struct(area);
 }
 
 /*
@@ -1501,15 +1500,7 @@ void exit_mmap(struct mm_struct *mm)
 	 */
 	while (vma) {
 		struct vm_area_struct *next = vma->vm_next;
-		remove_shared_vm_struct(vma);
-		if (vma->vm_ops) {
-			if (vma->vm_ops->close)
-				vma->vm_ops->close(vma);
-		}
-		if (vma->vm_file)
-			fput(vma->vm_file);
-		mpol_free(vma_policy(vma));
-		kmem_cache_free(vm_area_cachep, vma);
+		remove_vm_struct(vma);
 		vma = next;
 	}
 }

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
