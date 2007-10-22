Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id l9MAhhNR014583
	for <linux-mm@kvack.org>; Mon, 22 Oct 2007 20:43:43 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9MAlKtD190064
	for <linux-mm@kvack.org>; Mon, 22 Oct 2007 20:47:20 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9MAhj6J017091
	for <linux-mm@kvack.org>; Mon, 22 Oct 2007 20:43:45 +1000
Message-Id: <20071022104531.716194505@linux.vnet.ibm.com>>
References: <20071022104518.985992030@linux.vnet.ibm.com>>
Date: Mon, 22 Oct 2007 16:15:28 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
Subject: [PATCH/RFC 9/9] mm: nr_ptes needs to be atomic
Content-Disposition: inline; filename=9_nr_ptes.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Alexis Bruemmer <alexisb@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

---
 arch/powerpc/mm/fault.c   |    6 ++++++
 arch/sh/mm/cache-sh4.c    |    2 +-
 arch/um/kernel/skas/mmu.c |    2 +-
 fs/proc/task_mmu.c        |    2 +-
 include/linux/sched.h     |    4 +++-
 kernel/fork.c             |    2 +-
 mm/memory.c               |    4 ++--
 7 files changed, 15 insertions(+), 7 deletions(-)

--- linux-2.6.23-rc8.orig/arch/powerpc/mm/fault.c
+++ linux-2.6.23-rc8/arch/powerpc/mm/fault.c
@@ -235,6 +235,12 @@ again:
 	if (!(vma->vm_flags & VM_GROWSDOWN))
 		goto bad_area;
 
+	if (!locked) {
+		put_vma(vma);
+		locked = 1;
+		goto again;
+	}
+
 	/*
 	 * N.B. The POWER/Open ABI allows programs to access up to
 	 * 288 bytes below the stack pointer.
--- linux-2.6.23-rc8.orig/arch/sh/mm/cache-sh4.c
+++ linux-2.6.23-rc8/arch/sh/mm/cache-sh4.c
@@ -373,7 +373,7 @@ void flush_cache_mm(struct mm_struct *mm
 	 * Don't bother groveling around the dcache for the VMA ranges
 	 * if there are too many PTEs to make it worthwhile.
 	 */
-	if (mm->nr_ptes >= MAX_DCACHE_PAGES)
+	if (atomic_long_read(&mm->nr_ptes) >= MAX_DCACHE_PAGES)
 		flush_dcache_all();
 	else {
 		struct vm_area_struct *vma;
--- linux-2.6.23-rc8.orig/arch/um/kernel/skas/mmu.c
+++ linux-2.6.23-rc8/arch/um/kernel/skas/mmu.c
@@ -98,7 +98,7 @@ int init_new_context_skas(struct task_st
 		if(ret)
 			goto out_free;
 
-		mm->nr_ptes--;
+		atomic_long_dec(&mm->nr_ptes);
 	}
 
 	to_mm->id.stack = stack;
--- linux-2.6.23-rc8.orig/fs/proc/task_mmu.c
+++ linux-2.6.23-rc8/fs/proc/task_mmu.c
@@ -52,7 +52,7 @@ char *task_mem(struct mm_struct *mm, cha
 		total_rss << (PAGE_SHIFT-10),
 		data << (PAGE_SHIFT-10),
 		mm->stack_vm << (PAGE_SHIFT-10), text, lib,
-		(PTRS_PER_PTE*sizeof(pte_t)*mm->nr_ptes) >> 10);
+		(PTRS_PER_PTE*sizeof(pte_t)*atomic_long_read(&mm->nr_ptes)) >> 10);
 	return buffer;
 }
 
--- linux-2.6.23-rc8.orig/include/linux/sched.h
+++ linux-2.6.23-rc8/include/linux/sched.h
@@ -400,11 +400,13 @@ struct mm_struct {
 	unsigned long hiwater_vm;	/* High-water virtual memory usage */
 
 	unsigned long total_vm, locked_vm, shared_vm, exec_vm;
-	unsigned long stack_vm, reserved_vm, def_flags, nr_ptes;
+	unsigned long stack_vm, reserved_vm, def_flags;
 	unsigned long start_code, end_code, start_data, end_data;
 	unsigned long start_brk, brk, start_stack;
 	unsigned long arg_start, arg_end, env_start, env_end;
 
+	atomic_long_t nr_ptes;
+
 	unsigned long saved_auxv[AT_VECTOR_SIZE]; /* for /proc/PID/auxv */
 
 	cpumask_t cpu_vm_mask;
--- linux-2.6.23-rc8.orig/kernel/fork.c
+++ linux-2.6.23-rc8/kernel/fork.c
@@ -335,7 +335,7 @@ static struct mm_struct * mm_init(struct
 	mm->flags = (current->mm) ? current->mm->flags
 				  : MMF_DUMP_FILTER_DEFAULT;
 	mm->core_waiters = 0;
-	mm->nr_ptes = 0;
+	atomic_long_set(&mm->nr_ptes, 0);
 	set_mm_counter(mm, file_rss, 0);
 	set_mm_counter(mm, anon_rss, 0);
 	spin_lock_init(&mm->page_table_lock);
--- linux-2.6.23-rc8.orig/mm/memory.c
+++ linux-2.6.23-rc8/mm/memory.c
@@ -127,7 +127,7 @@ static void free_pte_range(struct mmu_ga
 	pte_lock_deinit(page);
 	pte_free_tlb(tlb, page);
 	dec_zone_page_state(page, NR_PAGETABLE);
-	tlb->mm->nr_ptes--;
+	atomic_long_dec(&tlb->mm->nr_ptes);
 }
 
 static inline void free_pmd_range(struct mmu_gather *tlb, pud_t *pud,
@@ -310,7 +310,7 @@ int __pte_alloc(struct mm_struct *mm, pm
 		pte_lock_deinit(new);
 		pte_free(new);
 	} else {
-		mm->nr_ptes++;
+		atomic_long_inc(&mm->nr_ptes);
 		inc_zone_page_state(new, NR_PAGETABLE);
 		pmd_populate(mm, pmd, new);
 	}

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
