Date: Fri, 3 Oct 2003 23:58:04 -0400 (EDT)
From: "V. Rajesh" <vrajesh@eecs.umich.edu>
Subject: [PATCH] fix split_vma vs. invalidate_mmap_range_list race
Message-ID: <Pine.LNX.4.44.0310032353070.26794-100000@cello.eecs.umich.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: davem@redhat.com, hch@lst.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

If a vma is already present in an i_mmap list of a mapping,
then it is racy to update the vm_start, vm_end, and vm_pgoff 
members of the vma without holding the mapping's i_shared_sem. 
This is because the updates can race with invalidate_mmap_range_list.

I audited all the places that assign vm_start, vm_end, and vm_pgoff.
AFAIK, the following is the list of questionable places:

1) This patch fixes the racy split_vma. Kernel 2.4 does the
   right thing, but the following changesets introduced a race.

   http://linux.bkbits.net:8080/linux-2.5/patch@1.536.34.4
   http://linux.bkbits.net:8080/linux-2.5/patch@1.536.34.5

   You can use the patch and programs in the following URL to 
   trigger the race.

  http://www-personal.engin.umich.edu/~vrajesh/linux/truncate-race/

2) This patch also locks a small racy window in vma_merge.

3) In few cases vma_merge and do_mremap expand a vma by adding 
   extra length to vm_end without holding i_shared_sem. I think 
   that's fine.

4) In arch/sparc64, vm_end is updated without holding i_shared_sem.
   Check make_hugetlb_page_present.  I hope that is fine, but 
   I am not sure. 

Please teach me if I am wrong.

Thanks,
Rajesh


 mm/mmap.c |   54 +++++++++++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 47 insertions(+), 7 deletions(-)

diff -puN mm/mmap.c~truncate_race mm/mmap.c
--- dev-2.6/mm/mmap.c~truncate_race	2003-10-03 16:01:29.000000000 -0400
+++ dev-2.6-jaya/mm/mmap.c	2003-10-03 21:01:28.000000000 -0400
@@ -277,6 +277,26 @@ static void vma_link(struct mm_struct *m
 	validate_mm(mm);
 }
 
+/* Insert vm structure into process list sorted by address
+ * and into the inode's i_mmap ring. The caller should
+ * hold mm->page_table_lock and ->f_mappping->i_shared_sem
+ * if vm_file is non-NULL. 
+ */
+static void 
+__insert_vm_struct(struct mm_struct * mm, struct vm_area_struct * vma)
+{
+	struct vm_area_struct * __vma, * prev;
+	struct rb_node ** rb_link, * rb_parent;
+
+	__vma = find_vma_prepare(mm,vma->vm_start,&prev,&rb_link,&rb_parent);
+	if (__vma && __vma->vm_start < vma->vm_end)
+		BUG();
+	__vma_link(mm, vma, prev, rb_link, rb_parent);
+	mark_mm_hugetlb(mm, vma);
+	mm->map_count++;
+	validate_mm(mm);
+}
+
 /*
  * If the vma has a ->close operation then the driver probably needs to release
  * per-vma resources, so we don't attempt to merge those.
@@ -417,10 +437,14 @@ static int vma_merge(struct mm_struct *m
 				pgoff, (end - addr) >> PAGE_SHIFT))
 			return 0;
 		if (end == prev->vm_start) {
+			if (file)
+				down(&file->f_mapping->i_shared_sem);
 			spin_lock(lock);
 			prev->vm_start = addr;
 			prev->vm_pgoff -= (end - addr) >> PAGE_SHIFT;
 			spin_unlock(lock);
+			if (file)
+				up(&file->f_mapping->i_shared_sem);
 			return 1;
 		}
 	}
@@ -1134,6 +1158,7 @@ int split_vma(struct mm_struct * mm, str
 	      unsigned long addr, int new_below)
 {
 	struct vm_area_struct *new;
+	struct address_space *mapping = NULL;
 
 	if (mm->map_count >= MAX_MAP_COUNT)
 		return -ENOMEM;
@@ -1147,12 +1172,9 @@ int split_vma(struct mm_struct * mm, str
 
 	INIT_LIST_HEAD(&new->shared);
 
-	if (new_below) {
+	if (new_below) 
 		new->vm_end = addr;
-		vma->vm_start = addr;
-		vma->vm_pgoff += ((addr - new->vm_start) >> PAGE_SHIFT);
-	} else {
-		vma->vm_end = addr;
+	else {
 		new->vm_start = addr;
 		new->vm_pgoff += ((addr - vma->vm_start) >> PAGE_SHIFT);
 	}
@@ -1163,7 +1185,25 @@ int split_vma(struct mm_struct * mm, str
 	if (new->vm_ops && new->vm_ops->open)
 		new->vm_ops->open(new);
 
-	insert_vm_struct(mm, new);
+	if (vma->vm_file)
+		 mapping = vma->vm_file->f_mapping;
+
+	if (mapping)
+		down(&mapping->i_shared_sem);
+	spin_lock(&mm->page_table_lock);
+
+	if (new_below) {
+		vma->vm_start = addr;
+		vma->vm_pgoff += ((addr - new->vm_start) >> PAGE_SHIFT);
+	} else
+		vma->vm_end = addr;
+
+	__insert_vm_struct(mm, new);
+
+	spin_unlock(&mm->page_table_lock);
+	if (mapping)
+		up(&mapping->i_shared_sem);
+
 	return 0;
 }
 
@@ -1408,7 +1448,7 @@ void exit_mmap(struct mm_struct *mm)
 
 /* Insert vm structure into process list sorted by address
  * and into the inode's i_mmap ring.  If vm_file is non-NULL
- * then i_shared_sem is taken here.
+ * then i_shared_sem is taken here. 
  */
 void insert_vm_struct(struct mm_struct * mm, struct vm_area_struct * vma)
 {

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
