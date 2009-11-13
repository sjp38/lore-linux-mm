Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2CF266B0062
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 02:41:26 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAD7fNES002277
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 13 Nov 2009 16:41:23 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EA82C45DE51
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 16:41:22 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id ABA9C45DE4E
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 16:41:22 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 64B04EF8003
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 16:41:22 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D6872E38006
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 16:41:21 +0900 (JST)
Date: Fri, 13 Nov 2009 16:38:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC MM 2/4] refcnt for vm_area_struct
Message-Id: <20091113163845.13f8dc52.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091113163544.d92561c7.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091113163544.d92561c7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: cl@linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

For relaxing the restriction that we have to take mmap_sem to
access vm_area_struct, add reference count.

Of course, this vm_arear_struct can be invalid while someone have
refcnt, another method is necessary to check vma is invalidated or not.

This patch just adds vma_get()/vma_put() functions as first step.

Note: this patch doesn't modify nommu.c

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 fs/exec.c                |    1 +
 include/linux/mm.h       |    3 +++
 include/linux/mm_types.h |    1 +
 kernel/fork.c            |    1 +
 mm/mmap.c                |   41 ++++++++++++++++++++++++++++++-----------
 5 files changed, 36 insertions(+), 11 deletions(-)

Index: mmotm-2.6.32-Nov2/include/linux/mm.h
===================================================================
--- mmotm-2.6.32-Nov2.orig/include/linux/mm.h
+++ mmotm-2.6.32-Nov2/include/linux/mm.h
@@ -1207,6 +1207,9 @@ extern struct vm_area_struct * find_vma(
 extern struct vm_area_struct * find_vma_prev(struct mm_struct * mm, unsigned long addr,
 					     struct vm_area_struct **pprev);
 
+extern void vma_get(struct vm_area_struct *vma);
+extern void vma_put(struct vm_area_struct *vma);
+
 /* Look up the first VMA which intersects the interval start_addr..end_addr-1,
    NULL if none.  Assume start_addr < end_addr. */
 static inline struct vm_area_struct * find_vma_intersection(struct mm_struct * mm, unsigned long start_addr, unsigned long end_addr)
Index: mmotm-2.6.32-Nov2/include/linux/mm_types.h
===================================================================
--- mmotm-2.6.32-Nov2.orig/include/linux/mm_types.h
+++ mmotm-2.6.32-Nov2/include/linux/mm_types.h
@@ -139,6 +139,7 @@ struct vm_area_struct {
 
 	/* linked list of VM areas per task, sorted by address */
 	struct vm_area_struct *vm_next;
+	atomic_t refcnt;		/* reference count for caching */
 
 	pgprot_t vm_page_prot;		/* Access permissions of this VMA. */
 	unsigned long vm_flags;		/* Flags, see mm.h. */
Index: mmotm-2.6.32-Nov2/mm/mmap.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/mm/mmap.c
+++ mmotm-2.6.32-Nov2/mm/mmap.c
@@ -225,12 +225,14 @@ void unlink_file_vma(struct vm_area_stru
 /*
  * Close a vm structure and free it, returning the next.
  */
-static struct vm_area_struct *remove_vma(struct vm_area_struct *vma)
+static struct vm_area_struct *remove_vma(struct vm_area_struct *vma, int close)
 {
 	struct vm_area_struct *next = vma->vm_next;
 
 	might_sleep();
-	if (vma->vm_ops && vma->vm_ops->close)
+	if (!atomic_dec_and_test(&vma->refcnt))
+		return next;
+	if (close && vma->vm_ops && vma->vm_ops->close)
 		vma->vm_ops->close(vma);
 	if (vma->vm_file) {
 		fput(vma->vm_file);
@@ -242,6 +244,23 @@ static struct vm_area_struct *remove_vma
 	return next;
 }
 
+/*
+ * must be called under mm->mmap_sem.
+ */
+void vma_get(struct vm_area_struct *vma)
+{
+	atomic_inc(&vma->refcnt);
+}
+
+/*
+ * Can be called without mmap_sem.
+ */
+void vma_put(struct vm_area_struct *vma)
+{
+	remove_vma(vma, 1);
+}
+
+
 SYSCALL_DEFINE1(brk, unsigned long, brk)
 {
 	unsigned long rlim, retval;
@@ -633,14 +652,9 @@ again:			remove_next = 1 + (end > next->
 		spin_unlock(&mapping->i_mmap_lock);
 
 	if (remove_next) {
-		if (file) {
-			fput(file);
-			if (next->vm_flags & VM_EXECUTABLE)
-				removed_exe_file_vma(mm);
-		}
+		/* don't need to call close operation */
 		mm->map_count--;
-		mpol_put(vma_policy(next));
-		kmem_cache_free(vm_area_cachep, next);
+		remove_vma(next, 0);
 		/*
 		 * In mprotect's case 6 (see comments on vma_merge),
 		 * we must remove another next too. It would clutter
@@ -1187,6 +1201,7 @@ munmap_back:
 	vma->vm_flags = vm_flags;
 	vma->vm_page_prot = vm_get_page_prot(vm_flags);
 	vma->vm_pgoff = pgoff;
+	atomic_set(&vma->refcnt, 1);
 
 	if (file) {
 		error = -EINVAL;
@@ -1767,7 +1782,7 @@ static void remove_vma_list(struct mm_st
 
 		mm->total_vm -= nrpages;
 		vm_stat_account(mm, vma->vm_flags, vma->vm_file, -nrpages);
-		vma = remove_vma(vma);
+		vma = remove_vma(vma, 1);
 	} while (vma);
 	validate_mm(mm);
 }
@@ -1844,6 +1859,7 @@ static int __split_vma(struct mm_struct 
 
 	/* most fields are the same, copy all, and then fixup */
 	*new = *vma;
+	atomic_set(&new->refcnt, 1);
 
 	if (new_below)
 		new->vm_end = addr;
@@ -2096,6 +2112,7 @@ unsigned long do_brk(unsigned long addr,
 	vma->vm_pgoff = pgoff;
 	vma->vm_flags = flags;
 	vma->vm_page_prot = vm_get_page_prot(flags);
+	atomic_set(&vma->refcnt, 1);
 	vma_link(mm, vma, prev, rb_link, rb_parent);
 out:
 	mm->total_vm += len >> PAGE_SHIFT;
@@ -2150,7 +2167,7 @@ void exit_mmap(struct mm_struct *mm)
 	 * with preemption enabled, without holding any MM locks.
 	 */
 	while (vma)
-		vma = remove_vma(vma);
+		vma = remove_vma(vma, 1);
 
 	BUG_ON(mm->nr_ptes > (FIRST_USER_ADDRESS+PMD_SIZE-1)>>PMD_SHIFT);
 }
@@ -2234,6 +2251,7 @@ struct vm_area_struct *copy_vma(struct v
 			new_vma->vm_start = addr;
 			new_vma->vm_end = addr + len;
 			new_vma->vm_pgoff = pgoff;
+			atomic_set(&new_vma->refcnt, 1);
 			if (new_vma->vm_file) {
 				get_file(new_vma->vm_file);
 				if (vma->vm_flags & VM_EXECUTABLE)
@@ -2331,6 +2349,7 @@ int install_special_mapping(struct mm_st
 
 	vma->vm_ops = &special_mapping_vmops;
 	vma->vm_private_data = pages;
+	atomic_set(&vma->refcnt, 1);
 
 	if (unlikely(insert_vm_struct(mm, vma))) {
 		kmem_cache_free(vm_area_cachep, vma);
Index: mmotm-2.6.32-Nov2/kernel/fork.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/kernel/fork.c
+++ mmotm-2.6.32-Nov2/kernel/fork.c
@@ -334,6 +334,7 @@ static int dup_mmap(struct mm_struct *mm
 		tmp->vm_flags &= ~VM_LOCKED;
 		tmp->vm_mm = mm;
 		tmp->vm_next = NULL;
+		atomic_set(&tmp->refcnt, 1);
 		anon_vma_link(tmp);
 		file = tmp->vm_file;
 		if (file) {
Index: mmotm-2.6.32-Nov2/fs/exec.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/fs/exec.c
+++ mmotm-2.6.32-Nov2/fs/exec.c
@@ -246,6 +246,7 @@ static int __bprm_mm_init(struct linux_b
 	vma->vm_start = vma->vm_end - PAGE_SIZE;
 	vma->vm_flags = VM_STACK_FLAGS;
 	vma->vm_page_prot = vm_get_page_prot(vma->vm_flags);
+	atomic_set(&vma->refcnt, 1);
 	err = insert_vm_struct(mm, vma);
 	if (err)
 		goto err;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
