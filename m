Message-Id: <200405222214.i4MMEYr14565@mail.osdl.org>
Subject: [patch 51/57] rmap 35 mmap.c cleanups
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:14:04 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

From: Hugh Dickins <hugh@veritas.com>

Before some real vma_merge work in mmap.c in the next patch, a patch of
miscellaneous cleanups to cut down the noise:

- remove rb_parent arg from vma_merge: mm->mmap can do that case
- scatter pgoff_t around to ingratiate myself with the boss
- reorder is_mergeable_vma tests, vm_ops->close is least likely
- can_vma_merge_before take combined pgoff+pglen arg (from Andrea)
- rearrange do_mmap_pgoff's ever-confusing anonymous flags switch
- comment do_mmap_pgoff's mysterious (vm_flags & VM_SHARED) test
- fix ISO C90 warning on browse_rb if building with DEBUG_MM_RB
- stop that long MNT_NOEXEC line wrapping

Yes, buried in amidst these is indeed one pgoff replaced by "next->vm_pgoff -
pglen" (reverting a mod of mine which took pgoff supplied by user too
seriously in the anon case), and another pgoff replaced by 0 (reverting
anon_vma mod which crept in with NUMA API): neither of them really matters,
except perhaps in /proc/pid/maps.


---

 25-akpm/include/linux/mm.h |    2 -
 25-akpm/mm/mmap.c          |   90 +++++++++++++++++++++++----------------------
 2 files changed, 47 insertions(+), 45 deletions(-)

diff -puN include/linux/mm.h~rmap-35-mmapc-cleanups include/linux/mm.h
--- 25/include/linux/mm.h~rmap-35-mmapc-cleanups	2004-05-22 14:56:29.521603560 -0700
+++ 25-akpm/include/linux/mm.h	2004-05-22 14:59:36.123235800 -0700
@@ -612,7 +612,7 @@ extern void insert_vm_struct(struct mm_s
 extern void __vma_link_rb(struct mm_struct *, struct vm_area_struct *,
 	struct rb_node **, struct rb_node *);
 extern struct vm_area_struct *copy_vma(struct vm_area_struct **,
-	unsigned long addr, unsigned long len, unsigned long pgoff);
+	unsigned long addr, unsigned long len, pgoff_t pgoff);
 extern void exit_mmap(struct mm_struct *);
 
 extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
diff -puN mm/mmap.c~rmap-35-mmapc-cleanups mm/mmap.c
--- 25/mm/mmap.c~rmap-35-mmapc-cleanups	2004-05-22 14:56:29.523603256 -0700
+++ 25-akpm/mm/mmap.c	2004-05-22 14:59:36.125235496 -0700
@@ -154,10 +154,10 @@ out:
 }
 
 #ifdef DEBUG_MM_RB
-static int browse_rb(struct rb_root *root) {
-	int i, j;
+static int browse_rb(struct rb_root *root)
+{
+	int i = 0, j;
 	struct rb_node *nd, *pn = NULL;
-	i = 0;
 	unsigned long prev = 0, pend = 0;
 
 	for (nd = rb_first(root); nd; nd = rb_next(nd)) {
@@ -181,10 +181,11 @@ static int browse_rb(struct rb_root *roo
 	return i;
 }
 
-void validate_mm(struct mm_struct * mm) {
+void validate_mm(struct mm_struct *mm)
+{
 	int bug = 0;
 	int i = 0;
-	struct vm_area_struct * tmp = mm->mmap;
+	struct vm_area_struct *tmp = mm->mmap;
 	while (tmp) {
 		tmp = tmp->vm_next;
 		i++;
@@ -407,17 +408,17 @@ void vma_adjust(struct vm_area_struct *v
 static inline int is_mergeable_vma(struct vm_area_struct *vma,
 			struct file *file, unsigned long vm_flags)
 {
-	if (vma->vm_ops && vma->vm_ops->close)
+	if (vma->vm_flags != vm_flags)
 		return 0;
 	if (vma->vm_file != file)
 		return 0;
-	if (vma->vm_flags != vm_flags)
+	if (vma->vm_ops && vma->vm_ops->close)
 		return 0;
 	return 1;
 }
 
 /*
- * Return true if we can merge this (vm_flags,file,vm_pgoff,size)
+ * Return true if we can merge this (vm_flags,file,vm_pgoff)
  * in front of (at a lower virtual address and file offset than) the vma.
  *
  * We don't check here for the merged mmap wrapping around the end of pagecache
@@ -426,12 +427,12 @@ static inline int is_mergeable_vma(struc
  */
 static int
 can_vma_merge_before(struct vm_area_struct *vma, unsigned long vm_flags,
-	struct file *file, unsigned long vm_pgoff, unsigned long size)
+	struct file *file, pgoff_t vm_pgoff)
 {
 	if (is_mergeable_vma(vma, file, vm_flags)) {
 		if (!file)
 			return 1;	/* anon mapping */
-		if (vma->vm_pgoff == vm_pgoff + size)
+		if (vma->vm_pgoff == vm_pgoff)
 			return 1;
 	}
 	return 0;
@@ -443,16 +444,16 @@ can_vma_merge_before(struct vm_area_stru
  */
 static int
 can_vma_merge_after(struct vm_area_struct *vma, unsigned long vm_flags,
-	struct file *file, unsigned long vm_pgoff)
+	struct file *file, pgoff_t vm_pgoff)
 {
 	if (is_mergeable_vma(vma, file, vm_flags)) {
-		unsigned long vma_size;
+		pgoff_t vm_pglen;
 
 		if (!file)
 			return 1;	/* anon mapping */
 
-		vma_size = (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
-		if (vma->vm_pgoff + vma_size == vm_pgoff)
+		vm_pglen = (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
+		if (vma->vm_pgoff + vm_pglen == vm_pgoff)
 			return 1;
 	}
 	return 0;
@@ -464,12 +465,12 @@ can_vma_merge_after(struct vm_area_struc
  * both (it neatly fills a hole).
  */
 static struct vm_area_struct *vma_merge(struct mm_struct *mm,
-			struct vm_area_struct *prev,
-			struct rb_node *rb_parent, unsigned long addr, 
+			struct vm_area_struct *prev, unsigned long addr,
 			unsigned long end, unsigned long vm_flags,
-		     	struct file *file, unsigned long pgoff,
+		     	struct file *file, pgoff_t pgoff,
 		        struct mempolicy *policy)
 {
+	pgoff_t pglen = (end - addr) >> PAGE_SHIFT;
 	struct vm_area_struct *next;
 
 	/*
@@ -480,7 +481,7 @@ static struct vm_area_struct *vma_merge(
 		return NULL;
 
 	if (!prev) {
-		next = rb_entry(rb_parent, struct vm_area_struct, vm_rb);
+		next = mm->mmap;
 		goto merge_next;
 	}
 	next = prev->vm_next;
@@ -497,7 +498,7 @@ static struct vm_area_struct *vma_merge(
 		if (next && end == next->vm_start &&
 				mpol_equal(policy, vma_policy(next)) &&
 				can_vma_merge_before(next, vm_flags, file,
-					pgoff, (end - addr) >> PAGE_SHIFT)) {
+							pgoff+pglen)) {
 			vma_adjust(prev, prev->vm_start,
 				next->vm_end, prev->vm_pgoff, next);
 			if (file)
@@ -511,17 +512,18 @@ static struct vm_area_struct *vma_merge(
 		return prev;
 	}
 
+merge_next:
+
 	/*
 	 * Can this new request be merged in front of next?
 	 */
 	if (next) {
- merge_next:
 		if (end == next->vm_start &&
  				mpol_equal(policy, vma_policy(next)) &&
 				can_vma_merge_before(next, vm_flags, file,
-					pgoff, (end - addr) >> PAGE_SHIFT)) {
-			vma_adjust(next, addr,
-				next->vm_end, pgoff, NULL);
+							pgoff+pglen)) {
+			vma_adjust(next, addr, next->vm_end,
+				next->vm_pgoff - pglen, NULL);
 			return next;
 		}
 	}
@@ -554,7 +556,8 @@ unsigned long do_mmap_pgoff(struct file 
 		if (!file->f_op || !file->f_op->mmap)
 			return -ENODEV;
 
-		if ((prot & PROT_EXEC) && (file->f_vfsmnt->mnt_flags & MNT_NOEXEC))
+		if ((prot & PROT_EXEC) &&
+		    (file->f_vfsmnt->mnt_flags & MNT_NOEXEC))
 			return -EPERM;
 	}
 
@@ -636,15 +639,14 @@ unsigned long do_mmap_pgoff(struct file 
 			return -EINVAL;
 		}
 	} else {
-		vm_flags |= VM_SHARED | VM_MAYSHARE;
 		switch (flags & MAP_TYPE) {
-		default:
-			return -EINVAL;
-		case MAP_PRIVATE:
-			vm_flags &= ~(VM_SHARED | VM_MAYSHARE);
-			/* fall through */
 		case MAP_SHARED:
+			vm_flags |= VM_SHARED | VM_MAYSHARE;
+			break;
+		case MAP_PRIVATE:
 			break;
+		default:
+			return -EINVAL;
 		}
 	}
 
@@ -683,11 +685,14 @@ munmap_back:
 		}
 	}
 
-	/* Can we just expand an old anonymous mapping? */
-	if (!file && !(vm_flags & VM_SHARED) && rb_parent)
-		if (vma_merge(mm, prev, rb_parent, addr, addr + len,
-					vm_flags, NULL, pgoff, NULL))
-			goto out;
+	/*
+	 * Can we just expand an old private anonymous mapping?
+	 * The VM_SHARED test is necessary because shmem_zero_setup
+	 * will create the file object for a shared anonymous map below.
+	 */
+	if (!file && !(vm_flags & VM_SHARED) &&
+	    vma_merge(mm, prev, addr, addr + len, vm_flags, NULL, 0, NULL))
+		goto out;
 
 	/*
 	 * Determine the object being mapped and call the appropriate
@@ -744,10 +749,8 @@ munmap_back:
 	 */
 	addr = vma->vm_start;
 
-	if (!file || !rb_parent || !vma_merge(mm, prev, rb_parent, addr,
-					      vma->vm_end,
-					      vma->vm_flags, file, pgoff,
-					      vma_policy(vma))) {
+	if (!file || !vma_merge(mm, prev, addr, vma->vm_end,
+			vma->vm_flags, file, pgoff, vma_policy(vma))) {
 		vma_link(mm, vma, prev, rb_link, rb_parent);
 		if (correct_wcount)
 			atomic_inc(&inode->i_writecount);
@@ -1430,9 +1433,8 @@ unsigned long do_brk(unsigned long addr,
 
 	flags = VM_DATA_DEFAULT_FLAGS | VM_ACCOUNT | mm->def_flags;
 
-	/* Can we just expand an old anonymous mapping? */
-	if (rb_parent && vma_merge(mm, prev, rb_parent, addr, addr + len,
-					flags, NULL, 0, NULL))
+	/* Can we just expand an old private anonymous mapping? */
+	if (vma_merge(mm, prev, addr, addr + len, flags, NULL, 0, NULL))
 		goto out;
 
 	/*
@@ -1525,7 +1527,7 @@ void insert_vm_struct(struct mm_struct *
  * prior to moving page table entries, to effect an mremap move.
  */
 struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
-	unsigned long addr, unsigned long len, unsigned long pgoff)
+	unsigned long addr, unsigned long len, pgoff_t pgoff)
 {
 	struct vm_area_struct *vma = *vmap;
 	unsigned long vma_start = vma->vm_start;
@@ -1535,7 +1537,7 @@ struct vm_area_struct *copy_vma(struct v
 	struct mempolicy *pol;
 
 	find_vma_prepare(mm, addr, &prev, &rb_link, &rb_parent);
-	new_vma = vma_merge(mm, prev, rb_parent, addr, addr + len,
+	new_vma = vma_merge(mm, prev, addr, addr + len,
 			vma->vm_flags, vma->vm_file, pgoff, vma_policy(vma));
 	if (new_vma) {
 		/*

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
