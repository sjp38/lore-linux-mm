Received: by fk-out-0910.google.com with SMTP id z22so923475fkz.6
        for <linux-mm@kvack.org>; Sat, 05 Jul 2008 09:37:30 -0700 (PDT)
From: Denys Vlasenko <vda.linux@googlemail.com>
Subject: [PATCH] Deinline a few functions in mmap.c
Date: Sat, 5 Jul 2008 18:37:30 +0200
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200807051837.30219.vda.linux@googlemail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

__vma_link_file and expand_downwards functions are not small,
yeat they are marked inline. They probably had one callsite
sometime in the past, but now they have more.
In order to prevent similar thing, I also deinlined
expand_upwards, despite it having only pne callsite.
Nowadays gcc auto-inlines such static functions anyway.
In find_extend_vma, I removed one extra level of indirection.

Patch is deliberately generated with -U $BIGNUM to make
it easier to see that functions are big.

Result:

# size */*/mmap.o */vmlinux
   text    data     bss     dec     hex filename
   9514     188      16    9718    25f6 0.org/mm/mmap.o
   9237     188      16    9441    24e1 deinline/mm/mmap.o
6124402  858996  389480 7372878  70804e 0.org/vmlinux
6124113  858996  389480 7372589  707f2d deinline/vmlinux

Signed-off-by: Denys Vlasenko <vda.linux@googlemail.com>
--
vda

--- 0.org/mm/mmap.c	Wed Jul  2 00:40:52 2008
+++ deinline/mm/mmap.c	Sat Jul  5 16:19:30 2008
@@ -389,41 +389,41 @@
 	if (prev) {
 		vma->vm_next = prev->vm_next;
 		prev->vm_next = vma;
 	} else {
 		mm->mmap = vma;
 		if (rb_parent)
 			vma->vm_next = rb_entry(rb_parent,
 					struct vm_area_struct, vm_rb);
 		else
 			vma->vm_next = NULL;
 	}
 }
 
 void __vma_link_rb(struct mm_struct *mm, struct vm_area_struct *vma,
 		struct rb_node **rb_link, struct rb_node *rb_parent)
 {
 	rb_link_node(&vma->vm_rb, rb_parent, rb_link);
 	rb_insert_color(&vma->vm_rb, &mm->mm_rb);
 }
 
-static inline void __vma_link_file(struct vm_area_struct *vma)
+static void __vma_link_file(struct vm_area_struct *vma)
 {
 	struct file * file;
 
 	file = vma->vm_file;
 	if (file) {
 		struct address_space *mapping = file->f_mapping;
 
 		if (vma->vm_flags & VM_DENYWRITE)
 			atomic_dec(&file->f_path.dentry->d_inode->i_writecount);
 		if (vma->vm_flags & VM_SHARED)
 			mapping->i_mmap_writable++;
 
 		flush_dcache_mmap_lock(mapping);
 		if (unlikely(vma->vm_flags & VM_NONLINEAR))
 			vma_nonlinear_insert(vma, &mapping->i_mmap_nonlinear);
 		else
 			vma_prio_tree_insert(vma, &mapping->i_mmap);
 		flush_dcache_mmap_unlock(mapping);
 	}
 }
@@ -1558,41 +1558,41 @@
 	 * Overcommit..  This must be the final test, as it will
 	 * update security statistics.
 	 */
 	if (security_vm_enough_memory(grow))
 		return -ENOMEM;
 
 	/* Ok, everything looks good - let it rip */
 	mm->total_vm += grow;
 	if (vma->vm_flags & VM_LOCKED)
 		mm->locked_vm += grow;
 	vm_stat_account(mm, vma->vm_flags, vma->vm_file, grow);
 	return 0;
 }
 
 #if defined(CONFIG_STACK_GROWSUP) || defined(CONFIG_IA64)
 /*
  * PA-RISC uses this for its stack; IA64 for its Register Backing Store.
  * vma is the last one with address > vma->vm_end.  Have to extend vma.
  */
 #ifndef CONFIG_IA64
-static inline
+static
 #endif
 int expand_upwards(struct vm_area_struct *vma, unsigned long address)
 {
 	int error;
 
 	if (!(vma->vm_flags & VM_GROWSUP))
 		return -EFAULT;
 
 	/*
 	 * We must make sure the anon_vma is allocated
 	 * so that the anon_vma locking is not a noop.
 	 */
 	if (unlikely(anon_vma_prepare(vma)))
 		return -ENOMEM;
 	anon_vma_lock(vma);
 
 	/*
 	 * vma->vm_start/vm_end cannot change under us because the caller
 	 * is required to hold the mmap_sem in read mode.  We need the
 	 * anon_vma lock to serialize against concurrent expand_stacks.
@@ -1608,41 +1608,41 @@
 
 	/* Somebody else might have raced and expanded it already */
 	if (address > vma->vm_end) {
 		unsigned long size, grow;
 
 		size = address - vma->vm_start;
 		grow = (address - vma->vm_end) >> PAGE_SHIFT;
 
 		error = acct_stack_growth(vma, size, grow);
 		if (!error)
 			vma->vm_end = address;
 	}
 	anon_vma_unlock(vma);
 	return error;
 }
 #endif /* CONFIG_STACK_GROWSUP || CONFIG_IA64 */
 
 /*
  * vma is the first one with address < vma->vm_start.  Have to extend vma.
  */
-static inline int expand_downwards(struct vm_area_struct *vma,
+static int expand_downwards(struct vm_area_struct *vma,
 				   unsigned long address)
 {
 	int error;
 
 	/*
 	 * We must make sure the anon_vma is allocated
 	 * so that the anon_vma locking is not a noop.
 	 */
 	if (unlikely(anon_vma_prepare(vma)))
 		return -ENOMEM;
 
 	address &= PAGE_MASK;
 	error = security_file_mmap(NULL, 0, 0, 0, address, 1);
 	if (error)
 		return error;
 
 	anon_vma_lock(vma);
 
 	/*
 	 * vma->vm_start/vm_end cannot change under us because the caller
@@ -1670,68 +1670,68 @@
 int expand_stack_downwards(struct vm_area_struct *vma, unsigned long address)
 {
 	return expand_downwards(vma, address);
 }
 
 #ifdef CONFIG_STACK_GROWSUP
 int expand_stack(struct vm_area_struct *vma, unsigned long address)
 {
 	return expand_upwards(vma, address);
 }
 
 struct vm_area_struct *
 find_extend_vma(struct mm_struct *mm, unsigned long addr)
 {
 	struct vm_area_struct *vma, *prev;
 
 	addr &= PAGE_MASK;
 	vma = find_vma_prev(mm, addr, &prev);
 	if (vma && (vma->vm_start <= addr))
 		return vma;
-	if (!prev || expand_stack(prev, addr))
+	if (!prev || expand_upwards(prev, addr))
 		return NULL;
 	if (prev->vm_flags & VM_LOCKED)
 		make_pages_present(addr, prev->vm_end);
 	return prev;
 }
 #else
 int expand_stack(struct vm_area_struct *vma, unsigned long address)
 {
 	return expand_downwards(vma, address);
 }
 
 struct vm_area_struct *
 find_extend_vma(struct mm_struct * mm, unsigned long addr)
 {
 	struct vm_area_struct * vma;
 	unsigned long start;
 
 	addr &= PAGE_MASK;
 	vma = find_vma(mm,addr);
 	if (!vma)
 		return NULL;
 	if (vma->vm_start <= addr)
 		return vma;
 	if (!(vma->vm_flags & VM_GROWSDOWN))
 		return NULL;
 	start = vma->vm_start;
-	if (expand_stack(vma, addr))
+	if (expand_downwards(vma, addr))
 		return NULL;
 	if (vma->vm_flags & VM_LOCKED)
 		make_pages_present(addr, start);
 	return vma;
 }
 #endif
 
 /*
  * Ok - we have the memory areas we should free on the vma list,
  * so release them, and do the vma updates.
  *
  * Called with the mm semaphore held.
  */
 static void remove_vma_list(struct mm_struct *mm, struct vm_area_struct *vma)
 {
 	/* Update high watermark before we lower total_vm */
 	update_hiwater_vm(mm);
 	do {
 		long nrpages = vma_pages(vma);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
