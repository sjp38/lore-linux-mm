Message-Id: <200405222208.i4MM8wr13448@mail.osdl.org>
Subject: [patch 30/57] rmap 15: vma_adjust
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:08:26 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

From: Hugh Dickins <hugh@veritas.com>

If file-based vmas are to be kept in a tree, according to the file offsets
they map, then adjusting the vma's start pgoff or its end involves
repositioning in the tree, while holding i_shared_lock (and page_table_lock). 
We used to avoid that if possible, e.g.  when just moving end; but if we're
heading that way, let's now tidy up vma_merge and split_vma, and do all the
locking and adjustment in a new helper vma_adjust.  And please, let's call the
next vma in vma_merge "next" rather than "prev".

Since these patches are diffed over 2.6.6-rc2-mm2, they include the NUMA
mpolicy mods which you'll have to remove to go earlier in the series, sorry
for that nuisance.  I have intentionally changed the one vma_mpol_equal to
mpol_equal, to make the merge cases more alike.


---

 25-akpm/include/linux/mm.h |    2 
 25-akpm/mm/mmap.c          |  161 ++++++++++++++++++++++-----------------------
 25-akpm/mm/mremap.c        |    7 +
 3 files changed, 87 insertions(+), 83 deletions(-)

diff -puN include/linux/mm.h~rmap-15-vma_adjust include/linux/mm.h
--- 25/include/linux/mm.h~rmap-15-vma_adjust	2004-05-22 14:56:26.314091176 -0700
+++ 25-akpm/include/linux/mm.h	2004-05-22 14:59:39.595707904 -0700
@@ -588,6 +588,8 @@ extern void si_meminfo(struct sysinfo * 
 extern void si_meminfo_node(struct sysinfo *val, int nid);
 
 /* mmap.c */
+extern void vma_adjust(struct vm_area_struct *vma, unsigned long start,
+	unsigned long end, pgoff_t pgoff, struct vm_area_struct *next);
 extern void insert_vm_struct(struct mm_struct *, struct vm_area_struct *);
 extern void __vma_link_rb(struct mm_struct *, struct vm_area_struct *,
 	struct rb_node **, struct rb_node *);
diff -puN mm/mmap.c~rmap-15-vma_adjust mm/mmap.c
--- 25/mm/mmap.c~rmap-15-vma_adjust	2004-05-22 14:56:26.315091024 -0700
+++ 25-akpm/mm/mmap.c	2004-05-22 14:59:39.626703192 -0700
@@ -67,13 +67,11 @@ EXPORT_SYMBOL(vm_committed_space);
  * Requires inode->i_mapping->i_mmap_lock
  */
 static inline void
-__remove_shared_vm_struct(struct vm_area_struct *vma, struct inode *inode)
+__remove_shared_vm_struct(struct vm_area_struct *vma, struct file *file)
 {
-	if (inode) {
-		if (vma->vm_flags & VM_DENYWRITE)
-			atomic_inc(&inode->i_writecount);
-		list_del_init(&vma->shared);
-	}
+	if (vma->vm_flags & VM_DENYWRITE)
+		atomic_inc(&file->f_dentry->d_inode->i_writecount);
+	list_del_init(&vma->shared);
 }
 
 /*
@@ -86,7 +84,7 @@ static void remove_shared_vm_struct(stru
 	if (file) {
 		struct address_space *mapping = file->f_mapping;
 		spin_lock(&mapping->i_mmap_lock);
-		__remove_shared_vm_struct(vma, file->f_dentry->d_inode);
+		__remove_shared_vm_struct(vma, file);
 		spin_unlock(&mapping->i_mmap_lock);
 	}
 }
@@ -320,6 +318,54 @@ __insert_vm_struct(struct mm_struct * mm
 }
 
 /*
+ * We cannot adjust vm_start, vm_end, vm_pgoff fields of a vma that is
+ * already present in an i_mmap{_shared} tree without adjusting the tree.
+ * The following helper function should be used when such adjustments
+ * are necessary.  The "next" vma (if any) is to be removed or inserted
+ * before we drop the necessary locks.
+ */
+void vma_adjust(struct vm_area_struct *vma, unsigned long start,
+	unsigned long end, pgoff_t pgoff, struct vm_area_struct *next)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	struct address_space *mapping = NULL;
+	struct file *file = vma->vm_file;
+
+	if (file) {
+		mapping = file->f_mapping;
+		spin_lock(&mapping->i_mmap_lock);
+	}
+	spin_lock(&mm->page_table_lock);
+
+	vma->vm_start = start;
+	vma->vm_end = end;
+	vma->vm_pgoff = pgoff;
+
+	if (next) {
+		if (next == vma->vm_next) {
+			/*
+			 * vma_merge has merged next into vma, and needs
+			 * us to remove next before dropping the locks.
+			 */
+			__vma_unlink(mm, next, vma);
+			if (file)
+				__remove_shared_vm_struct(next, file);
+		} else {
+			/*
+			 * split_vma has split next from vma, and needs
+			 * us to insert next before dropping the locks
+			 * (next may either follow vma or precede it).
+			 */
+			__insert_vm_struct(mm, next);
+		}
+	}
+
+	spin_unlock(&mm->page_table_lock);
+	if (mapping)
+		spin_unlock(&mapping->i_mmap_lock);
+}
+
+/*
  * If the vma has a ->close operation then the driver probably needs to release
  * per-vma resources, so we don't attempt to merge those.
  */
@@ -391,90 +437,59 @@ static struct vm_area_struct *vma_merge(
 		     	struct file *file, unsigned long pgoff,
 		        struct mempolicy *policy)
 {
-	spinlock_t *lock = &mm->page_table_lock;
-	struct inode *inode = file ? file->f_dentry->d_inode : NULL;
-	spinlock_t *i_mmap_lock;
+	struct vm_area_struct *next;
 
 	/*
-	 * We later require that vma->vm_flags == vm_flags, so this tests
-	 * vma->vm_flags & VM_SPECIAL, too.
+	 * We later require that vma->vm_flags == vm_flags,
+	 * so this tests vma->vm_flags & VM_SPECIAL, too.
 	 */
 	if (vm_flags & VM_SPECIAL)
 		return NULL;
 
-	i_mmap_lock = file ? &file->f_mapping->i_mmap_lock : NULL;
-
 	if (!prev) {
-		prev = rb_entry(rb_parent, struct vm_area_struct, vm_rb);
+		next = rb_entry(rb_parent, struct vm_area_struct, vm_rb);
 		goto merge_next;
 	}
+	next = prev->vm_next;
 
 	/*
 	 * Can it merge with the predecessor?
 	 */
 	if (prev->vm_end == addr &&
-  		        mpol_equal(vma_policy(prev), policy) &&
+  			mpol_equal(vma_policy(prev), policy) &&
 			can_vma_merge_after(prev, vm_flags, file, pgoff)) {
-		struct vm_area_struct *next;
-		int need_up = 0;
-
-		if (unlikely(file && prev->vm_next &&
-				prev->vm_next->vm_file == file)) {
-			spin_lock(i_mmap_lock);
-			need_up = 1;
-		}
-		spin_lock(lock);
-		prev->vm_end = end;
-
 		/*
-		 * OK, it did.  Can we now merge in the successor as well?
+		 * OK, it can.  Can we now merge in the successor as well?
 		 */
-		next = prev->vm_next;
-		if (next && prev->vm_end == next->vm_start &&
-		    		vma_mpol_equal(prev, next) &&
+		if (next && end == next->vm_start &&
+				mpol_equal(policy, vma_policy(next)) &&
 				can_vma_merge_before(next, vm_flags, file,
 					pgoff, (end - addr) >> PAGE_SHIFT)) {
-			prev->vm_end = next->vm_end;
-			__vma_unlink(mm, next, prev);
-			__remove_shared_vm_struct(next, inode);
-			spin_unlock(lock);
-			if (need_up)
-				spin_unlock(i_mmap_lock);
+			vma_adjust(prev, prev->vm_start,
+				next->vm_end, prev->vm_pgoff, next);
 			if (file)
 				fput(file);
-
 			mm->map_count--;
 			mpol_free(vma_policy(next));
 			kmem_cache_free(vm_area_cachep, next);
-			return prev;
-		}
-		spin_unlock(lock);
-		if (need_up)
-			spin_unlock(i_mmap_lock);
+		} else
+			vma_adjust(prev, prev->vm_start,
+				end, prev->vm_pgoff, NULL);
 		return prev;
 	}
 
 	/*
-	 * Can this new request be merged in front of prev->vm_next?
+	 * Can this new request be merged in front of next?
 	 */
-	prev = prev->vm_next;
-	if (prev) {
+	if (next) {
  merge_next:
- 		if (!mpol_equal(policy, vma_policy(prev)))
-  			return 0;
-		if (!can_vma_merge_before(prev, vm_flags, file,
-				pgoff, (end - addr) >> PAGE_SHIFT))
-			return NULL;
-		if (end == prev->vm_start) {
-			if (file)
-				spin_lock(i_mmap_lock);
-			spin_lock(lock);
-			prev->vm_start = addr;
-			prev->vm_pgoff -= (end - addr) >> PAGE_SHIFT;
-			spin_unlock(lock);
-			if (file)
-				spin_unlock(i_mmap_lock);
-			return prev;
+		if (end == next->vm_start &&
+ 				mpol_equal(policy, vma_policy(next)) &&
+				can_vma_merge_before(next, vm_flags, file,
+					pgoff, (end - addr) >> PAGE_SHIFT)) {
+			vma_adjust(next, addr,
+				next->vm_end, pgoff, NULL);
+			return next;
 		}
 	}
 
@@ -1214,7 +1229,6 @@ int split_vma(struct mm_struct * mm, str
 {
 	struct mempolicy *pol;
 	struct vm_area_struct *new;
-	struct address_space *mapping = NULL;
 
 	if (mm->map_count >= sysctl_max_map_count)
 		return -ENOMEM;
@@ -1248,24 +1262,11 @@ int split_vma(struct mm_struct * mm, str
 	if (new->vm_ops && new->vm_ops->open)
 		new->vm_ops->open(new);
 
-	if (vma->vm_file)
-		 mapping = vma->vm_file->f_mapping;
-
-	if (mapping)
-		spin_lock(&mapping->i_mmap_lock);
-	spin_lock(&mm->page_table_lock);
-
-	if (new_below) {
-		vma->vm_start = addr;
-		vma->vm_pgoff += ((addr - new->vm_start) >> PAGE_SHIFT);
-	} else
-		vma->vm_end = addr;
-
-	__insert_vm_struct(mm, new);
-
-	spin_unlock(&mm->page_table_lock);
-	if (mapping)
-		spin_unlock(&mapping->i_mmap_lock);
+	if (new_below)
+		vma_adjust(vma, addr, vma->vm_end, vma->vm_pgoff +
+			((addr - new->vm_start) >> PAGE_SHIFT), new);
+	else
+		vma_adjust(vma, vma->vm_start, addr, vma->vm_pgoff, new);
 
 	return 0;
 }
diff -puN mm/mremap.c~rmap-15-vma_adjust mm/mremap.c
--- 25/mm/mremap.c~rmap-15-vma_adjust	2004-05-22 14:56:26.316090872 -0700
+++ 25-akpm/mm/mremap.c	2004-05-22 14:59:35.808283680 -0700
@@ -391,9 +391,10 @@ unsigned long do_mremap(unsigned long ad
 		/* can we just expand the current mapping? */
 		if (max_addr - addr >= new_len) {
 			int pages = (new_len - old_len) >> PAGE_SHIFT;
-			spin_lock(&vma->vm_mm->page_table_lock);
-			vma->vm_end = addr + new_len;
-			spin_unlock(&vma->vm_mm->page_table_lock);
+
+			vma_adjust(vma, vma->vm_start,
+				addr + new_len, vma->vm_pgoff, NULL);
+
 			current->mm->total_vm += pages;
 			if (vma->vm_flags & VM_LOCKED) {
 				current->mm->locked_vm += pages;

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
