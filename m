Message-Id: <200405222207.i4MM7jr13150@mail.osdl.org>
Subject: [patch 24/57] numa api: Add VMA hooks for policy
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:07:14 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

From: Andi Kleen <ak@suse.de>

NUMA API adds a policy to each VMA.  During VMA creattion, merging and
splitting these policies must be handled properly.  This patch adds the calls
to this.  

It is a nop when CONFIG_NUMA is not defined.


---

 25-akpm/arch/ia64/ia32/binfmt_elf32.c  |    2 ++
 25-akpm/arch/ia64/kernel/perfmon.c     |    1 +
 25-akpm/arch/ia64/mm/init.c            |    2 ++
 25-akpm/arch/m68k/atari/stram.c        |    2 +-
 25-akpm/arch/s390/kernel/compat_exec.c |    1 +
 25-akpm/arch/x86_64/ia32/ia32_binfmt.c |    1 +
 25-akpm/fs/exec.c                      |    1 +
 25-akpm/kernel/exit.c                  |    1 +
 25-akpm/kernel/fork.c                  |   18 +++++++++++++++++-
 25-akpm/mm/mmap.c                      |   31 ++++++++++++++++++++++++++-----
 25-akpm/mm/mprotect.c                  |    5 +++++
 11 files changed, 58 insertions(+), 7 deletions(-)

diff -puN arch/ia64/ia32/binfmt_elf32.c~numa-api-vma-policy-hooks arch/ia64/ia32/binfmt_elf32.c
--- 25/arch/ia64/ia32/binfmt_elf32.c~numa-api-vma-policy-hooks	2004-05-22 14:56:25.208259288 -0700
+++ 25-akpm/arch/ia64/ia32/binfmt_elf32.c	2004-05-22 14:59:40.414583416 -0700
@@ -104,6 +104,7 @@ ia64_elf32_init (struct pt_regs *regs)
 		vma->vm_pgoff = 0;
 		vma->vm_file = NULL;
 		vma->vm_private_data = NULL;
+		mpol_set_vma_default(vma);
 		down_write(&current->mm->mmap_sem);
 		{
 			insert_vm_struct(current->mm, vma);
@@ -190,6 +191,7 @@ ia32_setup_arg_pages (struct linux_binpr
 		mpnt->vm_pgoff = 0;
 		mpnt->vm_file = NULL;
 		mpnt->vm_private_data = 0;
+		mpol_set_vma_default(mpnt);
 		insert_vm_struct(current->mm, mpnt);
 		current->mm->total_vm = (mpnt->vm_end - mpnt->vm_start) >> PAGE_SHIFT;
 	}
diff -puN arch/ia64/kernel/perfmon.c~numa-api-vma-policy-hooks arch/ia64/kernel/perfmon.c
--- 25/arch/ia64/kernel/perfmon.c~numa-api-vma-policy-hooks	2004-05-22 14:56:25.210258984 -0700
+++ 25-akpm/arch/ia64/kernel/perfmon.c	2004-05-22 14:59:40.418582808 -0700
@@ -2321,6 +2321,7 @@ pfm_smpl_buffer_alloc(struct task_struct
 	vma->vm_ops	     = NULL;
 	vma->vm_pgoff	     = 0;
 	vma->vm_file	     = NULL;
+	mpol_set_vma_default(vma);
 	vma->vm_private_data = NULL; 
 
 	/*
diff -puN arch/ia64/mm/init.c~numa-api-vma-policy-hooks arch/ia64/mm/init.c
--- 25/arch/ia64/mm/init.c~numa-api-vma-policy-hooks	2004-05-22 14:56:25.212258680 -0700
+++ 25-akpm/arch/ia64/mm/init.c	2004-05-22 14:59:40.419582656 -0700
@@ -132,6 +132,7 @@ ia64_init_addr_space (void)
 		vma->vm_pgoff = 0;
 		vma->vm_file = NULL;
 		vma->vm_private_data = NULL;
+		mpol_set_vma_default(vma);
 		insert_vm_struct(current->mm, vma);
 	}
 
@@ -144,6 +145,7 @@ ia64_init_addr_space (void)
 			vma->vm_end = PAGE_SIZE;
 			vma->vm_page_prot = __pgprot(pgprot_val(PAGE_READONLY) | _PAGE_MA_NAT);
 			vma->vm_flags = VM_READ | VM_MAYREAD | VM_IO | VM_RESERVED;
+			mpol_set_vma_default(vma);
 			insert_vm_struct(current->mm, vma);
 		}
 	}
diff -puN arch/m68k/atari/stram.c~numa-api-vma-policy-hooks arch/m68k/atari/stram.c
--- 25/arch/m68k/atari/stram.c~numa-api-vma-policy-hooks	2004-05-22 14:56:25.213258528 -0700
+++ 25-akpm/arch/m68k/atari/stram.c	2004-05-22 14:56:25.233255488 -0700
@@ -752,7 +752,7 @@ static int unswap_by_read(unsigned short
 			/* Get a page for the entry, using the existing
 			   swap cache page if there is one.  Otherwise,
 			   get a clean page and read the swap into it. */
-			page = read_swap_cache_async(entry);
+			page = read_swap_cache_async(entry, NULL, 0);
 			if (!page) {
 				swap_free(entry);
 				return -ENOMEM;
diff -puN arch/s390/kernel/compat_exec.c~numa-api-vma-policy-hooks arch/s390/kernel/compat_exec.c
--- 25/arch/s390/kernel/compat_exec.c~numa-api-vma-policy-hooks	2004-05-22 14:56:25.215258224 -0700
+++ 25-akpm/arch/s390/kernel/compat_exec.c	2004-05-22 14:59:38.740837864 -0700
@@ -69,6 +69,7 @@ int setup_arg_pages32(struct linux_binpr
 		mpnt->vm_ops = NULL;
 		mpnt->vm_pgoff = 0;
 		mpnt->vm_file = NULL;
+		mpol_set_vma_default(mpnt);
 		INIT_LIST_HEAD(&mpnt->shared);
 		mpnt->vm_private_data = (void *) 0;
 		insert_vm_struct(mm, mpnt);
diff -puN arch/x86_64/ia32/ia32_binfmt.c~numa-api-vma-policy-hooks arch/x86_64/ia32/ia32_binfmt.c
--- 25/arch/x86_64/ia32/ia32_binfmt.c~numa-api-vma-policy-hooks	2004-05-22 14:56:25.216258072 -0700
+++ 25-akpm/arch/x86_64/ia32/ia32_binfmt.c	2004-05-22 14:59:40.420582504 -0700
@@ -365,6 +365,7 @@ int setup_arg_pages(struct linux_binprm 
 		mpnt->vm_ops = NULL;
 		mpnt->vm_pgoff = 0;
 		mpnt->vm_file = NULL;
+		mpol_set_vma_default(mpnt);
 		INIT_LIST_HEAD(&mpnt->shared);
 		mpnt->vm_private_data = (void *) 0;
 		insert_vm_struct(mm, mpnt);
diff -puN fs/exec.c~numa-api-vma-policy-hooks fs/exec.c
--- 25/fs/exec.c~numa-api-vma-policy-hooks	2004-05-22 14:56:25.217257920 -0700
+++ 25-akpm/fs/exec.c	2004-05-22 14:59:40.405584784 -0700
@@ -427,6 +427,7 @@ int setup_arg_pages(struct linux_binprm 
 		mpnt->vm_ops = NULL;
 		mpnt->vm_pgoff = 0;
 		mpnt->vm_file = NULL;
+		mpol_set_vma_default(mpnt);
 		INIT_LIST_HEAD(&mpnt->shared);
 		mpnt->vm_private_data = (void *) 0;
 		insert_vm_struct(mm, mpnt);
diff -puN kernel/exit.c~numa-api-vma-policy-hooks kernel/exit.c
--- 25/kernel/exit.c~numa-api-vma-policy-hooks	2004-05-22 14:56:25.219257616 -0700
+++ 25-akpm/kernel/exit.c	2004-05-22 14:59:40.408584328 -0700
@@ -791,6 +791,7 @@ asmlinkage NORET_TYPE void do_exit(long 
 	__exit_fs(tsk);
 	exit_namespace(tsk);
 	exit_thread();
+	mpol_free(tsk->mempolicy);
 
 	if (tsk->signal->leader)
 		disassociate_ctty(1);
diff -puN kernel/fork.c~numa-api-vma-policy-hooks kernel/fork.c
--- 25/kernel/fork.c~numa-api-vma-policy-hooks	2004-05-22 14:56:25.220257464 -0700
+++ 25-akpm/kernel/fork.c	2004-05-22 14:59:40.410584024 -0700
@@ -271,6 +271,7 @@ static inline int dup_mmap(struct mm_str
 	struct rb_node **rb_link, *rb_parent;
 	int retval;
 	unsigned long charge = 0;
+	struct mempolicy *pol;
 
 	down_write(&oldmm->mmap_sem);
 	flush_cache_mm(current->mm);
@@ -312,6 +313,11 @@ static inline int dup_mmap(struct mm_str
 		if (!tmp)
 			goto fail_nomem;
 		*tmp = *mpnt;
+		pol = mpol_copy(vma_policy(mpnt));
+		retval = PTR_ERR(pol);
+		if (IS_ERR(pol))
+			goto fail_nomem_policy;
+		vma_set_policy(tmp, pol);
 		tmp->vm_flags &= ~VM_LOCKED;
 		tmp->vm_mm = mm;
 		tmp->vm_next = NULL;
@@ -358,6 +364,8 @@ out:
 	flush_tlb_mm(current->mm);
 	up_write(&oldmm->mmap_sem);
 	return retval;
+fail_nomem_policy:
+	kmem_cache_free(vm_area_cachep, tmp);
 fail_nomem:
 	retval = -ENOMEM;
 fail:
@@ -964,10 +972,16 @@ struct task_struct *copy_process(unsigne
 	p->security = NULL;
 	p->io_context = NULL;
 	p->audit_context = NULL;
+ 	p->mempolicy = mpol_copy(p->mempolicy);
+ 	if (IS_ERR(p->mempolicy)) {
+ 		retval = PTR_ERR(p->mempolicy);
+ 		p->mempolicy = NULL;
+ 		goto bad_fork_cleanup;
+ 	}
 
 	retval = -ENOMEM;
 	if ((retval = security_task_alloc(p)))
-		goto bad_fork_cleanup;
+		goto bad_fork_cleanup_policy;
 	if ((retval = audit_alloc(p)))
 		goto bad_fork_cleanup_security;
 	/* copy all the process information */
@@ -1113,6 +1127,8 @@ bad_fork_cleanup_audit:
 	audit_free(p);
 bad_fork_cleanup_security:
 	security_task_free(p);
+bad_fork_cleanup_policy:
+	mpol_free(p->mempolicy);
 bad_fork_cleanup:
 	if (p->pid > 0)
 		free_pidmap(p->pid);
diff -puN mm/mmap.c~numa-api-vma-policy-hooks mm/mmap.c
--- 25/mm/mmap.c~numa-api-vma-policy-hooks	2004-05-22 14:56:25.222257160 -0700
+++ 25-akpm/mm/mmap.c	2004-05-22 14:59:40.412583720 -0700
@@ -387,7 +387,8 @@ static struct vm_area_struct *vma_merge(
 			struct vm_area_struct *prev,
 			struct rb_node *rb_parent, unsigned long addr, 
 			unsigned long end, unsigned long vm_flags,
-			struct file *file, unsigned long pgoff)
+		     	struct file *file, unsigned long pgoff,
+		        struct mempolicy *policy)
 {
 	spinlock_t *lock = &mm->page_table_lock;
 	struct inode *inode = file ? file->f_dentry->d_inode : NULL;
@@ -411,6 +412,7 @@ static struct vm_area_struct *vma_merge(
 	 * Can it merge with the predecessor?
 	 */
 	if (prev->vm_end == addr &&
+  		        mpol_equal(vma_policy(prev), policy) &&
 			can_vma_merge_after(prev, vm_flags, file, pgoff)) {
 		struct vm_area_struct *next;
 		int need_up = 0;
@@ -428,6 +430,7 @@ static struct vm_area_struct *vma_merge(
 		 */
 		next = prev->vm_next;
 		if (next && prev->vm_end == next->vm_start &&
+		    		vma_mpol_equal(prev, next) &&
 				can_vma_merge_before(next, vm_flags, file,
 					pgoff, (end - addr) >> PAGE_SHIFT)) {
 			prev->vm_end = next->vm_end;
@@ -440,6 +443,7 @@ static struct vm_area_struct *vma_merge(
 				fput(file);
 
 			mm->map_count--;
+			mpol_free(vma_policy(next));
 			kmem_cache_free(vm_area_cachep, next);
 			return prev;
 		}
@@ -455,6 +459,8 @@ static struct vm_area_struct *vma_merge(
 	prev = prev->vm_next;
 	if (prev) {
  merge_next:
+ 		if (!mpol_equal(policy, vma_policy(prev)))
+  			return 0;
 		if (!can_vma_merge_before(prev, vm_flags, file,
 				pgoff, (end - addr) >> PAGE_SHIFT))
 			return NULL;
@@ -631,7 +637,7 @@ munmap_back:
 	/* Can we just expand an old anonymous mapping? */
 	if (!file && !(vm_flags & VM_SHARED) && rb_parent)
 		if (vma_merge(mm, prev, rb_parent, addr, addr + len,
-					vm_flags, NULL, 0))
+					vm_flags, NULL, pgoff, NULL))
 			goto out;
 
 	/*
@@ -654,6 +660,7 @@ munmap_back:
 	vma->vm_file = NULL;
 	vma->vm_private_data = NULL;
 	vma->vm_next = NULL;
+	mpol_set_vma_default(vma);
 	INIT_LIST_HEAD(&vma->shared);
 
 	if (file) {
@@ -693,7 +700,9 @@ munmap_back:
 	addr = vma->vm_start;
 
 	if (!file || !rb_parent || !vma_merge(mm, prev, rb_parent, addr,
-				addr + len, vma->vm_flags, file, pgoff)) {
+					      vma->vm_end,
+					      vma->vm_flags, file, pgoff,
+					      vma_policy(vma))) {
 		vma_link(mm, vma, prev, rb_link, rb_parent);
 		if (correct_wcount)
 			atomic_inc(&inode->i_writecount);
@@ -703,6 +712,7 @@ munmap_back:
 				atomic_inc(&inode->i_writecount);
 			fput(file);
 		}
+		mpol_free(vma_policy(vma));
 		kmem_cache_free(vm_area_cachep, vma);
 	}
 out:	
@@ -1118,6 +1128,7 @@ static void unmap_vma(struct mm_struct *
 
 	remove_shared_vm_struct(area);
 
+	mpol_free(vma_policy(area));
 	if (area->vm_ops && area->vm_ops->close)
 		area->vm_ops->close(area);
 	if (area->vm_file)
@@ -1200,6 +1211,7 @@ detach_vmas_to_be_unmapped(struct mm_str
 int split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
 	      unsigned long addr, int new_below)
 {
+	struct mempolicy *pol;
 	struct vm_area_struct *new;
 	struct address_space *mapping = NULL;
 
@@ -1222,6 +1234,13 @@ int split_vma(struct mm_struct * mm, str
 		new->vm_pgoff += ((addr - vma->vm_start) >> PAGE_SHIFT);
 	}
 
+	pol = mpol_copy(vma_policy(vma));
+	if (IS_ERR(pol)) {
+		kmem_cache_free(vm_area_cachep, new);
+		return PTR_ERR(pol);
+	}
+	vma_set_policy(new, pol);
+
 	if (new->vm_file)
 		get_file(new->vm_file);
 
@@ -1391,7 +1410,7 @@ unsigned long do_brk(unsigned long addr,
 
 	/* Can we just expand an old anonymous mapping? */
 	if (rb_parent && vma_merge(mm, prev, rb_parent, addr, addr + len,
-					flags, NULL, 0))
+					flags, NULL, 0, NULL))
 		goto out;
 
 	/*
@@ -1412,6 +1431,7 @@ unsigned long do_brk(unsigned long addr,
 	vma->vm_pgoff = 0;
 	vma->vm_file = NULL;
 	vma->vm_private_data = NULL;
+	mpol_set_vma_default(vma);
 	INIT_LIST_HEAD(&vma->shared);
 
 	vma_link(mm, vma, prev, rb_link, rb_parent);
@@ -1472,6 +1492,7 @@ void exit_mmap(struct mm_struct *mm)
 		}
 		if (vma->vm_file)
 			fput(vma->vm_file);
+		mpol_free(vma_policy(vma));
 		kmem_cache_free(vm_area_cachep, vma);
 		vma = next;
 	}
@@ -1508,7 +1529,7 @@ struct vm_area_struct *copy_vma(struct v
 
 	find_vma_prepare(mm, addr, &prev, &rb_link, &rb_parent);
 	new_vma = vma_merge(mm, prev, rb_parent, addr, addr + len,
-			vma->vm_flags, vma->vm_file, pgoff);
+			vma->vm_flags, vma->vm_file, pgoff, vma_policy(vma));
 	if (new_vma) {
 		/*
 		 * Source vma may have been merged into new_vma
diff -puN mm/mprotect.c~numa-api-vma-policy-hooks mm/mprotect.c
--- 25/mm/mprotect.c~numa-api-vma-policy-hooks	2004-05-22 14:56:25.223257008 -0700
+++ 25-akpm/mm/mprotect.c	2004-05-22 14:59:40.412583720 -0700
@@ -125,6 +125,8 @@ mprotect_attempt_merge(struct vm_area_st
 		return 0;
 	if (vma->vm_file || (vma->vm_flags & VM_SHARED))
 		return 0;
+	if (!vma_mpol_equal(vma, prev))
+		return 0;
 
 	/*
 	 * If the whole area changes to the protection of the previous one
@@ -136,6 +138,7 @@ mprotect_attempt_merge(struct vm_area_st
 		__vma_unlink(mm, vma, prev);
 		spin_unlock(&mm->page_table_lock);
 
+		mpol_free(vma_policy(vma));
 		kmem_cache_free(vm_area_cachep, vma);
 		mm->map_count--;
 		return 1;
@@ -317,12 +320,14 @@ sys_mprotect(unsigned long start, size_t
 
 	if (next && prev->vm_end == next->vm_start &&
 			can_vma_merge(next, prev->vm_flags) &&
+	    	vma_mpol_equal(prev, next) &&
 			!prev->vm_file && !(prev->vm_flags & VM_SHARED)) {
 		spin_lock(&prev->vm_mm->page_table_lock);
 		prev->vm_end = next->vm_end;
 		__vma_unlink(prev->vm_mm, next, prev);
 		spin_unlock(&prev->vm_mm->page_table_lock);
 
+		mpol_free(vma_policy(next));
 		kmem_cache_free(vm_area_cachep, next);
 		prev->vm_mm->map_count--;
 	}

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
