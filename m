Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id l9MAhi8S025401
	for <linux-mm@kvack.org>; Mon, 22 Oct 2007 20:43:44 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9MAhj38884764
	for <linux-mm@kvack.org>; Mon, 22 Oct 2007 20:43:45 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9MAhj9s017103
	for <linux-mm@kvack.org>; Mon, 22 Oct 2007 20:43:45 +1000
Message-Id: <20071022104530.436750453@linux.vnet.ibm.com>>
References: <20071022104518.985992030@linux.vnet.ibm.com>>
Date: Mon, 22 Oct 2007 16:15:20 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
Subject: [PATCH/RFC 1/9] Data structure changes
Content-Disposition: inline; filename=1_mm_vmas.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Alexis Bruemmer <alexisb@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

* Replace vm_next with list_head in mm_struct
* Change all instance of mm->vm_next and mm->mmap
* TBD: Not all architectures covered


Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
---
 arch/alpha/kernel/osf_sys.c     |    2 
 arch/arm/mm/mmap.c              |    2 
 arch/frv/mm/elf-fdpic.c         |    4 -
 arch/i386/mm/hugetlbpage.c      |    2 
 arch/ia64/kernel/sys_ia64.c     |    2 
 arch/ia64/mm/hugetlbpage.c      |    2 
 arch/mips/kernel/irixelf.c      |   19 +++---
 arch/mips/kernel/syscall.c      |    2 
 arch/parisc/kernel/sys_parisc.c |    4 -
 arch/powerpc/mm/tlb_32.c        |    2 
 arch/ppc/mm/tlb.c               |    2 
 arch/x86_64/ia32/ia32_aout.c    |    2 
 arch/x86_64/kernel/sys_x86_64.c |    2 
 drivers/char/mem.c              |    2 
 drivers/oprofile/buffer_sync.c  |    4 -
 fs/binfmt_aout.c                |    2 
 fs/binfmt_elf.c                 |    4 -
 fs/binfmt_elf_fdpic.c           |    5 +
 fs/exec.c                       |    4 -
 fs/hugetlbfs/inode.c            |    2 
 fs/proc/task_mmu.c              |   18 +++---
 include/linux/init_task.h       |    1 
 include/linux/mm.h              |   44 ++++++++++++++-
 include/linux/sched.h           |    2 
 ipc/shm.c                       |    4 -
 kernel/acct.c                   |    5 -
 kernel/auditsc.c                |    4 -
 kernel/fork.c                   |   11 +--
 mm/madvise.c                    |    2 
 mm/memory.c                     |   21 +++----
 mm/mempolicy.c                  |   10 +--
 mm/migrate.c                    |    2 
 mm/mlock.c                      |    5 +
 mm/mmap.c                       |  114 +++++++++++++++++++---------------------
 mm/mprotect.c                   |    2 
 mm/mremap.c                     |    7 +-
 mm/msync.c                      |    2 
 mm/swapfile.c                   |    2 
 38 files changed, 180 insertions(+), 146 deletions(-)

--- linux-2.6.23-rc9.orig/arch/alpha/kernel/osf_sys.c
+++ linux-2.6.23-rc9/arch/alpha/kernel/osf_sys.c
@@ -1255,7 +1255,7 @@ arch_get_unmapped_area_1(unsigned long a
 		if (!vma || addr + len <= vma->vm_start)
 			return addr;
 		addr = vma->vm_end;
-		vma = vma->vm_next;
+		vma = vma_next(vma);
 	}
 }
 
--- linux-2.6.23-rc9.orig/arch/arm/mm/mmap.c
+++ linux-2.6.23-rc9/arch/arm/mm/mmap.c
@@ -84,7 +84,7 @@ full_search:
 	else
 		addr = PAGE_ALIGN(addr);
 
-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (TASK_SIZE - len < addr) {
 			/*
--- linux-2.6.23-rc9.orig/arch/frv/mm/elf-fdpic.c
+++ linux-2.6.23-rc9/arch/frv/mm/elf-fdpic.c
@@ -86,7 +86,7 @@ unsigned long arch_get_unmapped_area(str
 
 		if (addr <= limit) {
 			vma = find_vma(current->mm, PAGE_SIZE);
-			for (; vma; vma = vma->vm_next) {
+			for (; vma; vma = vma_next(vma)) {
 				if (addr > limit)
 					break;
 				if (addr + len <= vma->vm_start)
@@ -101,7 +101,7 @@ unsigned long arch_get_unmapped_area(str
 	limit = TASK_SIZE - len;
 	if (addr <= limit) {
 		vma = find_vma(current->mm, addr);
-		for (; vma; vma = vma->vm_next) {
+		for (; vma; vma = vma_next(vma)) {
 			if (addr > limit)
 				break;
 			if (addr + len <= vma->vm_start)
--- linux-2.6.23-rc9.orig/arch/i386/mm/hugetlbpage.c
+++ linux-2.6.23-rc9/arch/i386/mm/hugetlbpage.c
@@ -241,7 +241,7 @@ static unsigned long hugetlb_get_unmappe
 full_search:
 	addr = ALIGN(start_addr, HPAGE_SIZE);
 
-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (TASK_SIZE - len < addr) {
 			/*
--- linux-2.6.23-rc9.orig/arch/ia64/kernel/sys_ia64.c
+++ linux-2.6.23-rc9/arch/ia64/kernel/sys_ia64.c
@@ -58,7 +58,7 @@ arch_get_unmapped_area (struct file *fil
   full_search:
 	start_addr = addr = (addr + align_mask) & ~align_mask;
 
-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (TASK_SIZE - len < addr || RGN_MAP_LIMIT - len < REGION_OFFSET(addr)) {
 			if (start_addr != TASK_UNMAPPED_BASE) {
--- linux-2.6.23-rc9.orig/arch/ia64/mm/hugetlbpage.c
+++ linux-2.6.23-rc9/arch/ia64/mm/hugetlbpage.c
@@ -159,7 +159,7 @@ unsigned long hugetlb_get_unmapped_area(
 		addr = HPAGE_REGION_BASE;
 	else
 		addr = ALIGN(addr, HPAGE_SIZE);
-	for (vmm = find_vma(current->mm, addr); ; vmm = vmm->vm_next) {
+	for (vmm = find_vma(current->mm, addr); ; vmm = vmm_next(vma)) {
 		/* At this point:  (!vmm || addr < vmm->vm_end). */
 		if (REGION_OFFSET(addr) + len > RGN_MAP_LIMIT)
 			return -ENOMEM;
--- linux-2.6.23-rc9.orig/arch/mips/kernel/irixelf.c
+++ linux-2.6.23-rc9/arch/mips/kernel/irixelf.c
@@ -718,7 +718,7 @@ static int load_irix_binary(struct linux
 	/* OK, This is the point of no return */
 	current->mm->end_data = 0;
 	current->mm->end_code = 0;
-	current->mm->mmap = NULL;
+	INIT_LIST_HEAD(&current->mm->mm_vmas);
 	current->flags &= ~PF_FORKNOEXEC;
 	elf_entry = (unsigned int) elf_ex.e_entry;
 
@@ -1108,7 +1108,7 @@ static int irix_core_dump(long signr, st
 	/* Count what's needed to dump, up to the limit of coredump size. */
 	segs = 0;
 	size = 0;
-	for (vma = current->mm->mmap; vma != NULL; vma = vma->vm_next) {
+	for (vma = current->mm->mmap; vma != NULL; vma = vma_next(vma)) {
 		if (maydump(vma))
 		{
 			int sz = vma->vm_end-vma->vm_start;
@@ -1267,12 +1267,13 @@ static int irix_core_dump(long signr, st
 	dataoff = offset = roundup(offset, PAGE_SIZE);
 
 	/* Write program headers for segments dump. */
-	for (vma = current->mm->mmap, i = 0;
-		i < segs && vma != NULL; vma = vma->vm_next) {
+	i = 0
+	list_for_each_entry(vma, &current->mm->mm_vmas, vm_list) {
 		struct elf_phdr phdr;
 		size_t sz;
 
-		i++;
+		if (i++ == seg)
+			break;
 
 		sz = vma->vm_end - vma->vm_start;
 
@@ -1301,15 +1302,15 @@ static int irix_core_dump(long signr, st
 
 	DUMP_SEEK(dataoff);
 
-	for (i = 0, vma = current->mm->mmap;
-	    i < segs && vma != NULL;
-	    vma = vma->vm_next) {
+	i = 0
+	list_for_each_entry(vma, &current->mm->mm_vmas, vm_list) {
 		unsigned long addr = vma->vm_start;
 		unsigned long len = vma->vm_end - vma->vm_start;
 
 		if (!maydump(vma))
 			continue;
-		i++;
+		if (i++ == seg)
+			break;
 		pr_debug("elf_core_dump: writing %08lx %lx\n", addr, len);
 		DUMP_WRITE((void __user *)addr, len);
 	}
--- linux-2.6.23-rc9.orig/arch/mips/kernel/syscall.c
+++ linux-2.6.23-rc9/arch/mips/kernel/syscall.c
@@ -104,7 +104,7 @@ unsigned long arch_get_unmapped_area(str
 	else
 		addr = PAGE_ALIGN(addr);
 
-	for (vmm = find_vma(current->mm, addr); ; vmm = vmm->vm_next) {
+	for (vmm = find_vma(current->mm, addr); ; vmm = vmm_next(vmm)) {
 		/* At this point:  (!vmm || addr < vmm->vm_end). */
 		if (task_size - len < addr)
 			return -ENOMEM;
--- linux-2.6.23-rc9.orig/arch/parisc/kernel/sys_parisc.c
+++ linux-2.6.23-rc9/arch/parisc/kernel/sys_parisc.c
@@ -52,7 +52,7 @@ static unsigned long get_unshared_area(u
 
 	addr = PAGE_ALIGN(addr);
 
-	for (vma = find_vma(current->mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(current->mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (TASK_SIZE - len < addr)
 			return -ENOMEM;
@@ -88,7 +88,7 @@ static unsigned long get_shared_area(str
 
 	addr = DCACHE_ALIGN(addr - offset) + offset;
 
-	for (vma = find_vma(current->mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(current->mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (TASK_SIZE - len < addr)
 			return -ENOMEM;
--- linux-2.6.23-rc9.orig/arch/powerpc/mm/tlb_32.c
+++ linux-2.6.23-rc9/arch/powerpc/mm/tlb_32.c
@@ -155,7 +155,7 @@ void flush_tlb_mm(struct mm_struct *mm)
 	 * unmap_region or exit_mmap, but not from vmtruncate on SMP -
 	 * but it seems dup_mmap is the only SMP case which gets here.
 	 */
-	for (mp = mm->mmap; mp != NULL; mp = mp->vm_next)
+	list_for_each_entry(mp, &mm->mm_vmas, vm_list)
 		flush_range(mp->vm_mm, mp->vm_start, mp->vm_end);
 	FINISH_FLUSH;
 }
--- linux-2.6.23-rc9.orig/arch/ppc/mm/tlb.c
+++ linux-2.6.23-rc9/arch/ppc/mm/tlb.c
@@ -149,7 +149,7 @@ void flush_tlb_mm(struct mm_struct *mm)
 		return;
 	}
 
-	for (mp = mm->mmap; mp != NULL; mp = mp->vm_next)
+	list_for_each_entry(mp, &mm->mm_vmas, vm_list)
 		flush_range(mp->vm_mm, mp->vm_start, mp->vm_end);
 	FINISH_FLUSH;
 }
--- linux-2.6.23-rc9.orig/arch/x86_64/ia32/ia32_aout.c
+++ linux-2.6.23-rc9/arch/x86_64/ia32/ia32_aout.c
@@ -311,7 +311,7 @@ static int load_aout_binary(struct linux
 	current->mm->free_area_cache = TASK_UNMAPPED_BASE;
 	current->mm->cached_hole_size = 0;
 
-	current->mm->mmap = NULL;
+	INIT_LIST_HEAD(&current->mm->mm_vmas);
 	compute_creds(bprm);
  	current->flags &= ~PF_FORKNOEXEC;
 
--- linux-2.6.23-rc9.orig/arch/x86_64/kernel/sys_x86_64.c
+++ linux-2.6.23-rc9/arch/x86_64/kernel/sys_x86_64.c
@@ -119,7 +119,7 @@ arch_get_unmapped_area(struct file *filp
 	start_addr = addr;
 
 full_search:
-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (end - len < addr) {
 			/*
--- linux-2.6.23-rc9.orig/drivers/char/mem.c
+++ linux-2.6.23-rc9/drivers/char/mem.c
@@ -640,7 +640,7 @@ static inline size_t read_zero_pagealign
 	down_read(&mm->mmap_sem);
 
 	/* For private mappings, just map in zero pages. */
-	for (vma = find_vma(mm, addr); vma; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); vma; vma = vma_next(vma)) {
 		unsigned long count;
 
 		if (vma->vm_start > addr || (vma->vm_flags & VM_WRITE) == 0)
--- linux-2.6.23-rc9.orig/drivers/oprofile/buffer_sync.c
+++ linux-2.6.23-rc9/drivers/oprofile/buffer_sync.c
@@ -217,7 +217,7 @@ static unsigned long get_exec_dcookie(st
 	if (!mm)
 		goto out;
  
-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+	list_for_each_entry(vma, &mm->mm_vmas, vm_list) {
 		if (!vma->vm_file)
 			continue;
 		if (!(vma->vm_flags & VM_EXECUTABLE))
@@ -242,7 +242,7 @@ static unsigned long lookup_dcookie(stru
 	unsigned long cookie = NO_COOKIE;
 	struct vm_area_struct * vma;
 
-	for (vma = find_vma(mm, addr); vma; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); vma; vma = vma_next(vma)) {
  
 		if (addr < vma->vm_start || addr >= vma->vm_end)
 			continue;
--- linux-2.6.23-rc9.orig/fs/binfmt_aout.c
+++ linux-2.6.23-rc9/fs/binfmt_aout.c
@@ -323,7 +323,7 @@ static int load_aout_binary(struct linux
 	current->mm->free_area_cache = current->mm->mmap_base;
 	current->mm->cached_hole_size = 0;
 
-	current->mm->mmap = NULL;
+	INIT_LIST_HEAD(&current->mm->mm_vmas);
 	compute_creds(bprm);
  	current->flags &= ~PF_FORKNOEXEC;
 #ifdef __sparc__
--- linux-2.6.23-rc9.orig/fs/binfmt_elf.c
+++ linux-2.6.23-rc9/fs/binfmt_elf.c
@@ -1458,7 +1458,7 @@ static int elf_dump_thread_status(long s
 static struct vm_area_struct *first_vma(struct task_struct *tsk,
 					struct vm_area_struct *gate_vma)
 {
-	struct vm_area_struct *ret = tsk->mm->mmap;
+	struct vm_area_struct *ret = __vma_next(&tsk->mm->mm_vmas, NULL);
 
 	if (ret)
 		return ret;
@@ -1473,7 +1473,7 @@ static struct vm_area_struct *next_vma(s
 {
 	struct vm_area_struct *ret;
 
-	ret = this_vma->vm_next;
+	ret = vma_next(this_vma);
 	if (ret)
 		return ret;
 	if (this_vma == gate_vma)
--- linux-2.6.23-rc9.orig/fs/binfmt_elf_fdpic.c
+++ linux-2.6.23-rc9/fs/binfmt_elf_fdpic.c
@@ -1471,7 +1471,8 @@ static int elf_fdpic_dump_segments(struc
 {
 	struct vm_area_struct *vma;
 
-	for (vma = current->mm->mmap; vma; vma = vma->vm_next) {
+	list_for_each_entry(vma, &current->mm->mm_vmas, vm_list) {
+
 		unsigned long addr;
 
 		if (!maydump(vma, mm_flags))
@@ -1728,7 +1729,7 @@ static int elf_fdpic_core_dump(long sign
 	/* write program headers for segments dump */
 	for (
 #ifdef CONFIG_MMU
-		vma = current->mm->mmap; vma; vma = vma->vm_next
+		vma = __vma_next(&current->mm->mm_vmas, NULL); vma; vma = vma_next(vma)
 #else
 			vml = current->mm->context.vmlist; vml; vml = vml->next
 #endif
--- linux-2.6.23-rc9.orig/fs/exec.c
+++ linux-2.6.23-rc9/fs/exec.c
@@ -555,7 +555,7 @@ static int shift_arg_pages(struct vm_are
 		 * when the old and new regions overlap clear from new_end.
 		 */
 		free_pgd_range(&tlb, new_end, old_end, new_end,
-			vma->vm_next ? vma->vm_next->vm_start : 0);
+			vma_next(vma) ? vma_next(vma)->vm_start : 0);
 	} else {
 		/*
 		 * otherwise, clean from old_start; this is done to not touch
@@ -564,7 +564,7 @@ static int shift_arg_pages(struct vm_are
 		 * for the others its just a little faster.
 		 */
 		free_pgd_range(&tlb, old_start, old_end, new_end,
-			vma->vm_next ? vma->vm_next->vm_start : 0);
+			vma_next(vma) ? vma_next(vma)->vm_start : 0);
 	}
 	tlb_finish_mmu(tlb, new_end, old_end);
 
--- linux-2.6.23-rc9.orig/fs/hugetlbfs/inode.c
+++ linux-2.6.23-rc9/fs/hugetlbfs/inode.c
@@ -158,7 +158,7 @@ hugetlb_get_unmapped_area(struct file *f
 full_search:
 	addr = ALIGN(start_addr, HPAGE_SIZE);
 
-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (TASK_SIZE - len < addr) {
 			/*
--- linux-2.6.23-rc9.orig/fs/proc/task_mmu.c
+++ linux-2.6.23-rc9/fs/proc/task_mmu.c
@@ -87,11 +87,11 @@ int proc_exe_link(struct inode *inode, s
 		goto out;
 	down_read(&mm->mmap_sem);
 
-	vma = mm->mmap;
+	vma = __vma_next(&mm->mm_vmas, NULL);
 	while (vma) {
 		if ((vma->vm_flags & VM_EXECUTABLE) && vma->vm_file)
 			break;
-		vma = vma->vm_next;
+		vma = vma_next(vma);
 	}
 
 	if (vma) {
@@ -364,7 +364,7 @@ void clear_refs_smap(struct mm_struct *m
 	struct vm_area_struct *vma;
 
 	down_read(&mm->mmap_sem);
-	for (vma = mm->mmap; vma; vma = vma->vm_next)
+	list_for_each_entry(vma, &mm->mm_vmas, vm_list)
 		if (vma->vm_mm && !is_vm_hugetlb_page(vma))
 			walk_page_range(vma, clear_refs_pte_range, NULL);
 	flush_tlb_mm(mm);
@@ -406,7 +406,7 @@ static void *m_start(struct seq_file *m,
 
 	/* Start with last addr hint */
 	if (last_addr && (vma = find_vma(mm, last_addr))) {
-		vma = vma->vm_next;
+		vma = vma_next(vma);
 		goto out;
 	}
 
@@ -416,9 +416,9 @@ static void *m_start(struct seq_file *m,
 	 */
 	vma = NULL;
 	if ((unsigned long)l < mm->map_count) {
-		vma = mm->mmap;
+		vma = __vma_next(&mm->mm_vmas, NULL);
 		while (l-- && vma)
-			vma = vma->vm_next;
+			vma = vma_next(vma);
 		goto out;
 	}
 
@@ -448,12 +448,12 @@ static void vma_stop(struct proc_maps_pr
 static void *m_next(struct seq_file *m, void *v, loff_t *pos)
 {
 	struct proc_maps_private *priv = m->private;
-	struct vm_area_struct *vma = v;
+	struct vm_area_struct *vma = v, *next;
 	struct vm_area_struct *tail_vma = priv->tail_vma;
 
 	(*pos)++;
-	if (vma && (vma != tail_vma) && vma->vm_next)
-		return vma->vm_next;
+	if (vma && (vma != tail_vma) && (next = vma_next(vma)))
+		return next;
 	vma_stop(priv, vma);
 	return (vma != tail_vma)? tail_vma: NULL;
 }
--- linux-2.6.23-rc9.orig/include/linux/init_task.h
+++ linux-2.6.23-rc9/include/linux/init_task.h
@@ -47,6 +47,7 @@
 
 #define INIT_MM(name) \
 {			 					\
+	.mm_vmas	= LIST_HEAD_INIT(name.mm_vmas),		\
 	.mm_rb		= RB_ROOT,				\
 	.pgd		= swapper_pg_dir, 			\
 	.mm_users	= ATOMIC_INIT(2), 			\
--- linux-2.6.23-rc9.orig/include/linux/mm.h
+++ linux-2.6.23-rc9/include/linux/mm.h
@@ -35,6 +35,7 @@ extern int sysctl_legacy_va_layout;
 #define sysctl_legacy_va_layout 0
 #endif
 
+#include <linux/sched.h>
 #include <asm/page.h>
 #include <asm/pgtable.h>
 #include <asm/processor.h>
@@ -63,7 +64,7 @@ struct vm_area_struct {
 					   within vm_mm. */
 
 	/* linked list of VM areas per task, sorted by address */
-	struct vm_area_struct *vm_next;
+	struct list_head vm_list;
 
 	pgprot_t vm_page_prot;		/* Access permissions of this VMA. */
 	unsigned long vm_flags;		/* Flags, listed below. */
@@ -113,6 +114,42 @@ struct vm_area_struct {
 #endif
 };
 
+static inline struct vm_area_struct *
+__vma_next(struct list_head *head, struct vm_area_struct *vma)
+{
+	if (unlikely(!vma))
+		vma = container_of(head, struct vm_area_struct, vm_list);
+
+	if (vma->vm_list.next == head)
+		return NULL;
+
+	return list_entry(vma->vm_list.next, struct vm_area_struct, vm_list);
+}
+
+static inline struct vm_area_struct *
+vma_next(struct vm_area_struct *vma)
+{
+	return __vma_next(&vma->vm_mm->mm_vmas, vma);
+}
+
+static inline struct vm_area_struct *
+__vma_prev(struct list_head *head, struct vm_area_struct *vma)
+{
+	if (unlikely(!vma))
+		vma = container_of(head, struct vm_area_struct, vm_list);
+
+	if (vma->vm_list.prev == head)
+		return NULL;
+
+	return list_entry(vma->vm_list.prev, struct vm_area_struct, vm_list);
+}
+
+static inline struct vm_area_struct *
+vma_prev(struct vm_area_struct *vma)
+{
+	return __vma_prev(&vma->vm_mm->mm_vmas, vma);
+}
+
 extern struct kmem_cache *vm_area_cachep;
 
 /*
@@ -769,13 +806,14 @@ struct zap_details {
 struct page *vm_normal_page(struct vm_area_struct *, unsigned long, pte_t);
 unsigned long zap_page_range(struct vm_area_struct *vma, unsigned long address,
 		unsigned long size, struct zap_details *);
-unsigned long unmap_vmas(struct mmu_gather **tlb,
+unsigned long unmap_vmas(struct mmu_gather **tlb, struct list_head *vmas,
 		struct vm_area_struct *start_vma, unsigned long start_addr,
 		unsigned long end_addr, unsigned long *nr_accounted,
 		struct zap_details *);
 void free_pgd_range(struct mmu_gather **tlb, unsigned long addr,
 		unsigned long end, unsigned long floor, unsigned long ceiling);
-void free_pgtables(struct mmu_gather **tlb, struct vm_area_struct *start_vma,
+void free_pgtables(struct mmu_gather **tlb, struct list_head *vmas,
+		struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
 int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
 			struct vm_area_struct *vma);
--- linux-2.6.23-rc9.orig/include/linux/sched.h
+++ linux-2.6.23-rc9/include/linux/sched.h
@@ -367,7 +367,7 @@ extern int get_dumpable(struct mm_struct
 	((1 << MMF_DUMP_ANON_PRIVATE) |	(1 << MMF_DUMP_ANON_SHARED))
 
 struct mm_struct {
-	struct vm_area_struct * mmap;		/* list of VMAs */
+	struct list_head mm_vmas;
 	struct rb_root mm_rb;
 	struct vm_area_struct * mmap_cache;	/* last find_vma result */
 	unsigned long (*get_unmapped_area) (struct file *filp,
--- linux-2.6.23-rc9.orig/ipc/shm.c
+++ linux-2.6.23-rc9/ipc/shm.c
@@ -1034,7 +1034,7 @@ asmlinkage long sys_shmdt(char __user *s
 	vma = find_vma(mm, addr);
 
 	while (vma) {
-		next = vma->vm_next;
+		next = vma_next(vma);
 
 		/*
 		 * Check if the starting address would match, i.e. it's
@@ -1067,7 +1067,7 @@ asmlinkage long sys_shmdt(char __user *s
 	 */
 	size = PAGE_ALIGN(size);
 	while (vma && (loff_t)(vma->vm_end - addr) <= size) {
-		next = vma->vm_next;
+		next = vma_next(vma);
 
 		/* finding a matching vma now does not alter retval */
 		if ((vma->vm_ops == &shm_vm_ops) &&
--- linux-2.6.23-rc9.orig/kernel/acct.c
+++ linux-2.6.23-rc9/kernel/acct.c
@@ -540,11 +540,8 @@ void acct_collect(long exitcode, int gro
 	if (group_dead && current->mm) {
 		struct vm_area_struct *vma;
 		down_read(&current->mm->mmap_sem);
-		vma = current->mm->mmap;
-		while (vma) {
+		list_for_each_entry(vma, &current->mm->mm_vmas, vm_list)
 			vsize += vma->vm_end - vma->vm_start;
-			vma = vma->vm_next;
-		}
 		up_read(&current->mm->mmap_sem);
 	}
 
--- linux-2.6.23-rc9.orig/kernel/auditsc.c
+++ linux-2.6.23-rc9/kernel/auditsc.c
@@ -780,8 +780,7 @@ static void audit_log_task_info(struct a
 
 	if (mm) {
 		down_read(&mm->mmap_sem);
-		vma = mm->mmap;
-		while (vma) {
+		list_for_each_entry(vma, &mm->mm_vmas, vm_list) {
 			if ((vma->vm_flags & VM_EXECUTABLE) &&
 			    vma->vm_file) {
 				audit_log_d_path(ab, "exe=",
@@ -789,7 +788,6 @@ static void audit_log_task_info(struct a
 						 vma->vm_file->f_path.mnt);
 				break;
 			}
-			vma = vma->vm_next;
 		}
 		up_read(&mm->mmap_sem);
 	}
--- linux-2.6.23-rc9.orig/kernel/fork.c
+++ linux-2.6.23-rc9/kernel/fork.c
@@ -197,7 +197,7 @@ static struct task_struct *dup_task_stru
 #ifdef CONFIG_MMU
 static inline int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 {
-	struct vm_area_struct *mpnt, *tmp, **pprev;
+	struct vm_area_struct *mpnt, *tmp;
 	struct rb_node **rb_link, *rb_parent;
 	int retval;
 	unsigned long charge;
@@ -211,7 +211,6 @@ static inline int dup_mmap(struct mm_str
 	down_write_nested(&mm->mmap_sem, SINGLE_DEPTH_NESTING);
 
 	mm->locked_vm = 0;
-	mm->mmap = NULL;
 	mm->mmap_cache = NULL;
 	mm->free_area_cache = oldmm->mmap_base;
 	mm->cached_hole_size = ~0UL;
@@ -220,9 +219,8 @@ static inline int dup_mmap(struct mm_str
 	mm->mm_rb = RB_ROOT;
 	rb_link = &mm->mm_rb.rb_node;
 	rb_parent = NULL;
-	pprev = &mm->mmap;
 
-	for (mpnt = oldmm->mmap; mpnt; mpnt = mpnt->vm_next) {
+	list_for_each_entry(mpnt, &oldmm->mm_vmas, vm_list) {
 		struct file *file;
 
 		if (mpnt->vm_flags & VM_DONTCOPY) {
@@ -250,7 +248,6 @@ static inline int dup_mmap(struct mm_str
 		vma_set_policy(tmp, pol);
 		tmp->vm_flags &= ~VM_LOCKED;
 		tmp->vm_mm = mm;
-		tmp->vm_next = NULL;
 		anon_vma_link(tmp);
 		file = tmp->vm_file;
 		if (file) {
@@ -271,9 +268,8 @@ static inline int dup_mmap(struct mm_str
 		/*
 		 * Link in the new vma and copy the page table entries.
 		 */
-		*pprev = tmp;
-		pprev = &tmp->vm_next;
 
+		list_add_tail(&tmp->vm_list, &mm->mm_vmas);
 		__vma_link_rb(mm, tmp, rb_link, rb_parent);
 		rb_link = &tmp->vm_rb.rb_right;
 		rb_parent = &tmp->vm_rb;
@@ -330,6 +326,7 @@ static inline void mm_free_pgd(struct mm
 
 static struct mm_struct * mm_init(struct mm_struct * mm)
 {
+	INIT_LIST_HEAD(&mm->mm_vmas);
 	atomic_set(&mm->mm_users, 1);
 	atomic_set(&mm->mm_count, 1);
 	init_rwsem(&mm->mmap_sem);
--- linux-2.6.23-rc9.orig/mm/madvise.c
+++ linux-2.6.23-rc9/mm/madvise.c
@@ -351,7 +351,7 @@ asmlinkage long sys_madvise(unsigned lon
 		if (start >= end)
 			goto out;
 		if (prev)
-			vma = prev->vm_next;
+			vma = vma_next(prev);
 		else	/* madvise_remove dropped mmap_sem */
 			vma = find_vma(current->mm, start);
 	}
--- linux-2.6.23-rc9.orig/mm/memory.c
+++ linux-2.6.23-rc9/mm/memory.c
@@ -264,11 +264,11 @@ void free_pgd_range(struct mmu_gather **
 		flush_tlb_pgtables((*tlb)->mm, start, end);
 }
 
-void free_pgtables(struct mmu_gather **tlb, struct vm_area_struct *vma,
-		unsigned long floor, unsigned long ceiling)
+void free_pgtables(struct mmu_gather **tlb, struct list_head *vmas,
+		struct vm_area_struct *vma, unsigned long floor, unsigned long ceiling)
 {
 	while (vma) {
-		struct vm_area_struct *next = vma->vm_next;
+		struct vm_area_struct *next = __vma_next(vmas, vma);
 		unsigned long addr = vma->vm_start;
 
 		/*
@@ -287,7 +287,7 @@ void free_pgtables(struct mmu_gather **t
 			while (next && next->vm_start <= vma->vm_end + PMD_SIZE
 			       && !is_vm_hugetlb_page(next)) {
 				vma = next;
-				next = vma->vm_next;
+				next = __vma_next(vmas, vma);
 				anon_vma_unlink(vma);
 				unlink_file_vma(vma);
 			}
@@ -806,7 +806,7 @@ static unsigned long unmap_page_range(st
  * ensure that any thus-far unmapped pages are flushed before unmap_vmas()
  * drops the lock and schedules.
  */
-unsigned long unmap_vmas(struct mmu_gather **tlbp,
+unsigned long unmap_vmas(struct mmu_gather **tlbp, struct list_head *vmas,
 		struct vm_area_struct *vma, unsigned long start_addr,
 		unsigned long end_addr, unsigned long *nr_accounted,
 		struct zap_details *details)
@@ -818,7 +818,7 @@ unsigned long unmap_vmas(struct mmu_gath
 	spinlock_t *i_mmap_lock = details? details->i_mmap_lock: NULL;
 	int fullmm = (*tlbp)->fullmm;
 
-	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next) {
+	for ( ; vma && vma->vm_start < end_addr; vma = __vma_next(vmas, vma)) {
 		unsigned long end;
 
 		start = max(vma->vm_start, start_addr);
@@ -889,7 +889,8 @@ unsigned long zap_page_range(struct vm_a
 	lru_add_drain();
 	tlb = tlb_gather_mmu(mm, 0);
 	update_hiwater_rss(mm);
-	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted, details);
+	end = unmap_vmas(&tlb, &vma->vm_mm->mm_vmas, vma,
+			address, end, &nr_accounted, details);
 	if (tlb)
 		tlb_finish_mmu(tlb, address, end);
 	return end;
@@ -2093,7 +2094,7 @@ int vmtruncate_range(struct inode *inode
 void swapin_readahead(swp_entry_t entry, unsigned long addr,struct vm_area_struct *vma)
 {
 #ifdef CONFIG_NUMA
-	struct vm_area_struct *next_vma = vma ? vma->vm_next : NULL;
+	struct vm_area_struct *next_vma = vma ? vma_next(vma) : NULL;
 #endif
 	int i, num;
 	struct page *new_page;
@@ -2120,14 +2121,14 @@ void swapin_readahead(swp_entry_t entry,
 		if (vma) {
 			if (addr >= vma->vm_end) {
 				vma = next_vma;
-				next_vma = vma ? vma->vm_next : NULL;
+				next_vma = vma ? vma_next(vma) : NULL;
 			}
 			if (vma && addr < vma->vm_start)
 				vma = NULL;
 		} else {
 			if (next_vma && addr >= next_vma->vm_start) {
 				vma = next_vma;
-				next_vma = vma->vm_next;
+				next_vma = vma_next(vma);
 			}
 		}
 #endif
--- linux-2.6.23-rc9.orig/mm/mempolicy.c
+++ linux-2.6.23-rc9/mm/mempolicy.c
@@ -344,9 +344,9 @@ check_range(struct mm_struct *mm, unsign
 	if (!first)
 		return ERR_PTR(-EFAULT);
 	prev = NULL;
-	for (vma = first; vma && vma->vm_start < end; vma = vma->vm_next) {
+	for (vma = first; vma && vma->vm_start < end; vma = vma_next(vma)) {
 		if (!(flags & MPOL_MF_DISCONTIG_OK)) {
-			if (!vma->vm_next && vma->vm_end < end)
+			if (!vma_next(vma) && vma->vm_end < end)
 				return ERR_PTR(-EFAULT);
 			if (prev && prev->vm_end < vma->vm_start)
 				return ERR_PTR(-EFAULT);
@@ -403,7 +403,7 @@ static int mbind_range(struct vm_area_st
 
 	err = 0;
 	for (; vma && vma->vm_start < end; vma = next) {
-		next = vma->vm_next;
+		next = vma_next(vma);
 		if (vma->vm_start < start)
 			err = split_vma(vma->vm_mm, vma, start, 1);
 		if (!err && vma->vm_end > end)
@@ -610,7 +610,7 @@ int migrate_to_node(struct mm_struct *mm
 	nodes_clear(nmask);
 	node_set(source, nmask);
 
-	check_range(mm, mm->mmap->vm_start, TASK_SIZE, &nmask,
+	check_range(mm, __vma_next(&mm->mm_vmas, NULL)->vm_start, TASK_SIZE, &nmask,
 			flags | MPOL_MF_DISCONTIG_OK, &pagelist);
 
 	if (!list_empty(&pagelist))
@@ -1785,7 +1785,7 @@ void mpol_rebind_mm(struct mm_struct *mm
 	struct vm_area_struct *vma;
 
 	down_write(&mm->mmap_sem);
-	for (vma = mm->mmap; vma; vma = vma->vm_next)
+	list_for_each_entry(vma, &mm->mm_vmas, vm_list)
 		mpol_rebind_policy(vma->vm_policy, new);
 	up_write(&mm->mmap_sem);
 }
--- linux-2.6.23-rc9.orig/mm/migrate.c
+++ linux-2.6.23-rc9/mm/migrate.c
@@ -1030,7 +1030,7 @@ int migrate_vmas(struct mm_struct *mm, c
  	struct vm_area_struct *vma;
  	int err = 0;
 
- 	for(vma = mm->mmap; vma->vm_next && !err; vma = vma->vm_next) {
+	list_for_each_entry(vma, &mm->mm_vmas, vm_list) {
  		if (vma->vm_ops && vma->vm_ops->migrate) {
  			err = vma->vm_ops->migrate(vma, to, from, flags);
  			if (err)
--- linux-2.6.23-rc9.orig/mm/mlock.c
+++ linux-2.6.23-rc9/mm/mlock.c
@@ -123,7 +123,7 @@ static int do_mlock(unsigned long start,
 		if (nstart >= end)
 			break;
 
-		vma = prev->vm_next;
+		vma = vma_next(prev);
 		if (!vma || vma->vm_start != nstart) {
 			error = -ENOMEM;
 			break;
@@ -181,7 +181,7 @@ static int do_mlockall(int flags)
 	if (flags == MCL_FUTURE)
 		goto out;
 
-	for (vma = current->mm->mmap; vma ; vma = prev->vm_next) {
+	list_for_each_entry(vma, &current->mm->mm_vmas, vm_list) {
 		unsigned int newflags;
 
 		newflags = vma->vm_flags | VM_LOCKED;
@@ -190,6 +190,7 @@ static int do_mlockall(int flags)
 
 		/* Ignore errors */
 		mlock_fixup(vma, &prev, vma->vm_start, vma->vm_end, newflags);
+		vma = prev;
 	}
 out:
 	return 0;
--- linux-2.6.23-rc9.orig/mm/mmap.c
+++ linux-2.6.23-rc9/mm/mmap.c
@@ -35,7 +35,7 @@
 #define arch_mmap_check(addr, len, flags)	(0)
 #endif
 
-static void unmap_region(struct mm_struct *mm,
+static void unmap_region(struct mm_struct *mm, struct list_head *vmas,
 		struct vm_area_struct *vma, struct vm_area_struct *prev,
 		unsigned long start, unsigned long end);
 
@@ -220,18 +220,17 @@ void unlink_file_vma(struct vm_area_stru
 /*
  * Close a vm structure and free it, returning the next.
  */
-static struct vm_area_struct *remove_vma(struct vm_area_struct *vma)
+static void remove_vma(struct vm_area_struct *vma)
 {
-	struct vm_area_struct *next = vma->vm_next;
-
 	might_sleep();
+	list_del(&vma->vm_list);
 	if (vma->vm_ops && vma->vm_ops->close)
 		vma->vm_ops->close(vma);
 	if (vma->vm_file)
 		fput(vma->vm_file);
 	mpol_free(vma_policy(vma));
 	kmem_cache_free(vm_area_cachep, vma);
-	return next;
+	return;
 }
 
 asmlinkage unsigned long sys_brk(unsigned long brk)
@@ -316,11 +315,9 @@ void validate_mm(struct mm_struct *mm)
 {
 	int bug = 0;
 	int i = 0;
-	struct vm_area_struct *tmp = mm->mmap;
-	while (tmp) {
-		tmp = tmp->vm_next;
+	struct vm_area_struct *vma;
+	list_for_each_entry(vma, &mm->mm_vmas, vm_list)
 		i++;
-	}
 	if (i != mm->map_count)
 		printk("map_count %d vm_next %d\n", mm->map_count, i), bug = 1;
 	i = browse_rb(&mm->mm_rb);
@@ -374,15 +371,14 @@ __vma_link_list(struct mm_struct *mm, st
 		struct vm_area_struct *prev, struct rb_node *rb_parent)
 {
 	if (prev) {
-		vma->vm_next = prev->vm_next;
-		prev->vm_next = vma;
+		list_add(&vma->vm_list, &prev->vm_list);
 	} else {
-		mm->mmap = vma;
-		if (rb_parent)
-			vma->vm_next = rb_entry(rb_parent,
+		if (rb_parent) {
+			struct vm_area_struct *next = rb_entry(rb_parent,
 					struct vm_area_struct, vm_rb);
-		else
-			vma->vm_next = NULL;
+			list_add_tail(&vma->vm_list, &next->vm_list);
+		} else
+			list_add(&vma->vm_list, &mm->mm_vmas);
 	}
 }
 
@@ -472,7 +468,7 @@ static inline void
 __vma_unlink(struct mm_struct *mm, struct vm_area_struct *vma,
 		struct vm_area_struct *prev)
 {
-	prev->vm_next = vma->vm_next;
+	list_del(&vma->vm_list);
 	rb_erase(&vma->vm_rb, &mm->mm_rb);
 	if (mm->mmap_cache == vma)
 		mm->mmap_cache = prev;
@@ -489,7 +485,7 @@ void vma_adjust(struct vm_area_struct *v
 	unsigned long end, pgoff_t pgoff, struct vm_area_struct *insert)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	struct vm_area_struct *next = vma->vm_next;
+	struct vm_area_struct *next = vma_next(vma);
 	struct vm_area_struct *importer = NULL;
 	struct address_space *mapping = NULL;
 	struct prio_tree_root *root = NULL;
@@ -630,7 +626,7 @@ again:			remove_next = 1 + (end > next->
 		 * up the code too much to do both in one go.
 		 */
 		if (remove_next == 2) {
-			next = vma->vm_next;
+			next = vma_next(vma);
 			goto again;
 		}
 	}
@@ -751,13 +747,10 @@ struct vm_area_struct *vma_merge(struct 
 	if (vm_flags & VM_SPECIAL)
 		return NULL;
 
-	if (prev)
-		next = prev->vm_next;
-	else
-		next = mm->mmap;
+	next = __vma_next(&mm->mm_vmas, prev);
 	area = next;
 	if (next && next->vm_end == end)		/* cases 6, 7, 8 */
-		next = next->vm_next;
+		next = vma_next(next);
 
 	/*
 	 * Can it merge with the predecessor?
@@ -816,7 +809,7 @@ struct anon_vma *find_mergeable_anon_vma
 	struct vm_area_struct *near;
 	unsigned long vm_flags;
 
-	near = vma->vm_next;
+	near = vma_next(vma);
 	if (!near)
 		goto try_prev;
 
@@ -899,6 +892,7 @@ unsigned long do_mmap_pgoff(struct file 
 	int error;
 	int accountable = 1;
 	unsigned long reqprot = prot;
+	LIST_HEAD(vmas);
 
 	/*
 	 * Does the application expect PROT_READ to imply PROT_EXEC?
@@ -1075,6 +1069,7 @@ unsigned long mmap_region(struct file *f
 	struct rb_node **rb_link, *rb_parent;
 	unsigned long charged = 0;
 	struct inode *inode =  file ? file->f_path.dentry->d_inode : NULL;
+	LIST_HEAD(vmas);
 
 	/* Clear old maps */
 	error = -ENOMEM;
@@ -1210,7 +1205,8 @@ unmap_and_free_vma:
 	fput(file);
 
 	/* Undo any partial mapping done by a device driver. */
-	unmap_region(mm, vma, prev, vma->vm_start, vma->vm_end);
+	list_add(&vma->vm_list, &vmas);
+	unmap_region(mm, &vmas, vma, prev, vma->vm_start, vma->vm_end);
 	charged = 0;
 free_vma:
 	kmem_cache_free(vm_area_cachep, vma);
@@ -1261,7 +1257,7 @@ arch_get_unmapped_area(struct file *filp
 	}
 
 full_search:
-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (TASK_SIZE - len < addr) {
 			/*
@@ -1472,14 +1468,11 @@ struct vm_area_struct *
 find_vma_prev(struct mm_struct *mm, unsigned long addr,
 			struct vm_area_struct **pprev)
 {
-	struct vm_area_struct *vma = NULL, *prev = NULL;
+	struct vm_area_struct *prev = NULL, *next;
 	struct rb_node * rb_node;
 	if (!mm)
 		goto out;
 
-	/* Guard against addr being lower than the first VMA */
-	vma = mm->mmap;
-
 	/* Go through the RB tree quickly. */
 	rb_node = mm->mm_rb.rb_node;
 
@@ -1491,7 +1484,8 @@ find_vma_prev(struct mm_struct *mm, unsi
 			rb_node = rb_node->rb_left;
 		} else {
 			prev = vma_tmp;
-			if (!prev->vm_next || (addr < prev->vm_next->vm_end))
+			next = __vma_next(&mm->mm_vmas, prev);
+			if (!next || (addr < next->vm_end))
 				break;
 			rb_node = rb_node->rb_right;
 		}
@@ -1499,7 +1493,7 @@ find_vma_prev(struct mm_struct *mm, unsi
 
 out:
 	*pprev = prev;
-	return prev ? prev->vm_next : vma;
+	return __vma_next(&mm->mm_vmas, prev);
 }
 
 /*
@@ -1707,18 +1701,21 @@ find_extend_vma(struct mm_struct * mm, u
  *
  * Called with the mm semaphore held.
  */
-static void remove_vma_list(struct mm_struct *mm, struct vm_area_struct *vma)
+static void remove_vma_list(struct mm_struct *mm, struct list_head *vmas,
+		struct vm_area_struct *vma)
 {
 	/* Update high watermark before we lower total_vm */
 	update_hiwater_vm(mm);
 	do {
+		struct vm_area_struct *next = __vma_next(vmas, vma);
 		long nrpages = vma_pages(vma);
 
 		mm->total_vm -= nrpages;
 		if (vma->vm_flags & VM_LOCKED)
 			mm->locked_vm -= nrpages;
 		vm_stat_account(mm, vma->vm_flags, vma->vm_file, -nrpages);
-		vma = remove_vma(vma);
+		remove_vma(vma);
+		vma = next;
 	} while (vma);
 	validate_mm(mm);
 }
@@ -1728,21 +1725,22 @@ static void remove_vma_list(struct mm_st
  *
  * Called with the mm semaphore held.
  */
-static void unmap_region(struct mm_struct *mm,
+static void unmap_region(struct mm_struct *mm, struct list_head *vmas,
 		struct vm_area_struct *vma, struct vm_area_struct *prev,
 		unsigned long start, unsigned long end)
 {
-	struct vm_area_struct *next = prev? prev->vm_next: mm->mmap;
+	struct vm_area_struct *next = __vma_next(&mm->mm_vmas, prev);
 	struct mmu_gather *tlb;
 	unsigned long nr_accounted = 0;
 
 	lru_add_drain();
 	tlb = tlb_gather_mmu(mm, 0);
 	update_hiwater_rss(mm);
-	unmap_vmas(&tlb, vma, start, end, &nr_accounted, NULL);
+	unmap_vmas(&tlb, vmas, vma, start, end, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
-	free_pgtables(&tlb, vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
-				 next? next->vm_start: 0);
+	free_pgtables(&tlb, vmas, vma,
+			prev ? prev->vm_end : FIRST_USER_ADDRESS,
+			next ? next->vm_start : 0);
 	tlb_finish_mmu(tlb, start, end);
 }
 
@@ -1752,21 +1750,17 @@ static void unmap_region(struct mm_struc
  */
 static void
 detach_vmas_to_be_unmapped(struct mm_struct *mm, struct vm_area_struct *vma,
-	struct vm_area_struct *prev, unsigned long end)
+	struct vm_area_struct *prev, unsigned long end, struct list_head *vmas)
 {
-	struct vm_area_struct **insertion_point;
-	struct vm_area_struct *tail_vma = NULL;
 	unsigned long addr;
 
-	insertion_point = (prev ? &prev->vm_next : &mm->mmap);
 	do {
+		struct vm_area_struct *next = vma_next(vma);
 		rb_erase(&vma->vm_rb, &mm->mm_rb);
 		mm->map_count--;
-		tail_vma = vma;
-		vma = vma->vm_next;
+		list_move_tail(&vma->vm_list, vmas);
+		vma = next;
 	} while (vma && vma->vm_start < end);
-	*insertion_point = vma;
-	tail_vma->vm_next = NULL;
 	if (mm->unmap_area == arch_unmap_area)
 		addr = prev ? prev->vm_end : mm->mmap_base;
 	else
@@ -1836,6 +1830,7 @@ int do_munmap(struct mm_struct *mm, unsi
 {
 	unsigned long end;
 	struct vm_area_struct *vma, *prev, *last;
+	LIST_HEAD(vmas);
 
 	if ((start & ~PAGE_MASK) || start > TASK_SIZE || len > TASK_SIZE-start)
 		return -EINVAL;
@@ -1875,16 +1870,16 @@ int do_munmap(struct mm_struct *mm, unsi
 		if (error)
 			return error;
 	}
-	vma = prev? prev->vm_next: mm->mmap;
+	vma = __vma_next(&mm->mm_vmas, prev);
 
 	/*
 	 * Remove the vma's, and unmap the actual pages
 	 */
-	detach_vmas_to_be_unmapped(mm, vma, prev, end);
-	unmap_region(mm, vma, prev, start, end);
+	detach_vmas_to_be_unmapped(mm, vma, prev, end, &vmas);
+	unmap_region(mm, &vmas, vma, prev, start, end);
 
 	/* Fix up all other VM information */
-	remove_vma_list(mm, vma);
+	remove_vma_list(mm, &vmas, vma);
 
 	return 0;
 }
@@ -2021,7 +2016,9 @@ EXPORT_SYMBOL(do_brk);
 void exit_mmap(struct mm_struct *mm)
 {
 	struct mmu_gather *tlb;
-	struct vm_area_struct *vma = mm->mmap;
+	LIST_HEAD(vmas);
+	struct vm_area_struct *vma = __vma_next(&mm->mm_vmas, NULL);
+	struct vm_area_struct *next;
 	unsigned long nr_accounted = 0;
 	unsigned long end;
 
@@ -2030,22 +2027,23 @@ void exit_mmap(struct mm_struct *mm)
 
 	lru_add_drain();
 	flush_cache_mm(mm);
+	detach_vmas_to_be_unmapped(mm, vma, NULL, -1, &vmas);
 	tlb = tlb_gather_mmu(mm, 1);
 	/* Don't update_hiwater_rss(mm) here, do_exit already did */
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
-	end = unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL);
+	end = unmap_vmas(&tlb, &vmas, vma, 0, -1, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
-	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, 0);
+	free_pgtables(&tlb, &vmas, vma, FIRST_USER_ADDRESS, 0);
 	tlb_finish_mmu(tlb, 0, end);
 
 	/*
 	 * Walk the list again, actually closing and freeing it,
 	 * with preemption enabled, without holding any MM locks.
 	 */
-	while (vma)
-		vma = remove_vma(vma);
+	list_for_each_entry_safe(vma, next, &vmas, vm_list)
+		remove_vma(vma);
 
-	BUG_ON(mm->nr_ptes > (FIRST_USER_ADDRESS+PMD_SIZE-1)>>PMD_SHIFT);
+	/* BUG_ON(mm->nr_ptes > (FIRST_USER_ADDRESS+PMD_SIZE-1)>>PMD_SHIFT); */
 }
 
 /* Insert vm structure into process list sorted by address
--- linux-2.6.23-rc9.orig/mm/mprotect.c
+++ linux-2.6.23-rc9/mm/mprotect.c
@@ -302,7 +302,7 @@ sys_mprotect(unsigned long start, size_t
 		if (nstart >= end)
 			goto out;
 
-		vma = prev->vm_next;
+		vma = vma_next(prev);
 		if (!vma || vma->vm_start != nstart) {
 			error = -ENOMEM;
 			goto out;
--- linux-2.6.23-rc9.orig/mm/mremap.c
+++ linux-2.6.23-rc9/mm/mremap.c
@@ -226,7 +226,7 @@ static unsigned long move_vma(struct vm_
 	if (excess) {
 		vma->vm_flags |= VM_ACCOUNT;
 		if (split)
-			vma->vm_next->vm_flags |= VM_ACCOUNT;
+			vma_next(vma)->vm_flags |= VM_ACCOUNT;
 	}
 
 	if (vm_flags & VM_LOCKED) {
@@ -360,8 +360,9 @@ unsigned long do_mremap(unsigned long ad
 	    !((flags & MREMAP_FIXED) && (addr != new_addr)) &&
 	    (old_len != new_len || !(flags & MREMAP_MAYMOVE))) {
 		unsigned long max_addr = TASK_SIZE;
-		if (vma->vm_next)
-			max_addr = vma->vm_next->vm_start;
+		struct vm_area_struct *next = vma_next(vma);
+		if (next)
+			max_addr = next->vm_start;
 		/* can we just expand the current mapping? */
 		if (max_addr - addr >= new_len) {
 			int pages = (new_len - old_len) >> PAGE_SHIFT;
--- linux-2.6.23-rc9.orig/mm/msync.c
+++ linux-2.6.23-rc9/mm/msync.c
@@ -93,7 +93,7 @@ asmlinkage long sys_msync(unsigned long 
 				error = 0;
 				goto out_unlock;
 			}
-			vma = vma->vm_next;
+			vma = vma_next(vma);
 		}
 	}
 out_unlock:
--- linux-2.6.23-rc9.orig/mm/swapfile.c
+++ linux-2.6.23-rc9/mm/swapfile.c
@@ -626,7 +626,7 @@ static int unuse_mm(struct mm_struct *mm
 		down_read(&mm->mmap_sem);
 		lock_page(page);
 	}
-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+	list_for_each_entry(vma, &mm->mm_vmas, vm_list) {
 		if (vma->anon_vma && unuse_vma(vma, entry, page))
 			break;
 	}

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
