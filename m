Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2BB5E6B0295
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:29:37 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 188so6237295pgg.2
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:29:37 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s7-v6si1458511plp.57.2018.02.04.17.28.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:06 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 30/64] arch/tile: use mm locking wrappers
Date: Mon,  5 Feb 2018 02:27:20 +0100
Message-Id: <20180205012754.23615-31-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

This becomes quite straightforward with the mmrange in place.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 arch/tile/kernel/stack.c |  5 +++--
 arch/tile/mm/elf.c       | 12 +++++++-----
 arch/tile/mm/fault.c     | 12 ++++++------
 arch/tile/mm/pgtable.c   |  6 ++++--
 4 files changed, 20 insertions(+), 15 deletions(-)

diff --git a/arch/tile/kernel/stack.c b/arch/tile/kernel/stack.c
index 94ecbc6676e5..acd4a1ee8df1 100644
--- a/arch/tile/kernel/stack.c
+++ b/arch/tile/kernel/stack.c
@@ -378,6 +378,7 @@ void tile_show_stack(struct KBacktraceIterator *kbt)
 {
 	int i;
 	int have_mmap_sem = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (!start_backtrace())
 		return;
@@ -398,7 +399,7 @@ void tile_show_stack(struct KBacktraceIterator *kbt)
 		if (kbt->task == current && address < PAGE_OFFSET &&
 		    !have_mmap_sem && kbt->task->mm && !in_interrupt()) {
 			have_mmap_sem =
-				down_read_trylock(&kbt->task->mm->mmap_sem);
+				mm_read_trylock(kbt->task->mm, &mmrange);
 		}
 
 		describe_addr(kbt, address, have_mmap_sem,
@@ -415,7 +416,7 @@ void tile_show_stack(struct KBacktraceIterator *kbt)
 	if (kbt->end == KBT_LOOP)
 		pr_err("Stack dump stopped; next frame identical to this one\n");
 	if (have_mmap_sem)
-		up_read(&kbt->task->mm->mmap_sem);
+		mm_read_unlock(kbt->task->mm, &mmrange);
 	end_backtrace();
 }
 EXPORT_SYMBOL(tile_show_stack);
diff --git a/arch/tile/mm/elf.c b/arch/tile/mm/elf.c
index 889901824400..9aba9813cdb8 100644
--- a/arch/tile/mm/elf.c
+++ b/arch/tile/mm/elf.c
@@ -44,6 +44,7 @@ static int notify_exec(struct mm_struct *mm)
 	char *buf, *path;
 	struct vm_area_struct *vma;
 	struct file *exe_file;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (!sim_is_simulator())
 		return 1;
@@ -60,10 +61,10 @@ static int notify_exec(struct mm_struct *mm)
 	if (IS_ERR(path))
 		goto done_put;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	for (vma = current->mm->mmap; ; vma = vma->vm_next) {
 		if (vma == NULL) {
-			up_read(&mm->mmap_sem);
+			mm_read_unlock(mm, &mmrange);
 			goto done_put;
 		}
 		if (vma->vm_file == exe_file)
@@ -91,7 +92,7 @@ static int notify_exec(struct mm_struct *mm)
 			}
 		}
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	sim_notify_exec(path);
 done_put:
@@ -119,6 +120,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm,
 {
 	struct mm_struct *mm = current->mm;
 	int retval = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/*
 	 * Notify the simulator that an exec just occurred.
@@ -128,7 +130,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm,
 	if (!notify_exec(mm))
 		sim_notify_exec(bprm->filename);
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 
 	retval = setup_vdso_pages();
 
@@ -149,7 +151,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm,
 	}
 #endif
 
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 
 	return retval;
 }
diff --git a/arch/tile/mm/fault.c b/arch/tile/mm/fault.c
index 09f053eb146f..f4ce0806653a 100644
--- a/arch/tile/mm/fault.c
+++ b/arch/tile/mm/fault.c
@@ -383,7 +383,7 @@ static int handle_page_fault(struct pt_regs *regs,
 	 * source.  If this is invalid we can skip the address space check,
 	 * thus avoiding the deadlock.
 	 */
-	if (!down_read_trylock(&mm->mmap_sem)) {
+	if (!mm_read_trylock(mm, &mmrange)) {
 		if (is_kernel_mode &&
 		    !search_exception_tables(regs->pc)) {
 			vma = NULL;  /* happy compiler */
@@ -391,7 +391,7 @@ static int handle_page_fault(struct pt_regs *regs,
 		}
 
 retry:
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &mmrange);
 	}
 
 	vma = find_vma(mm, address);
@@ -482,7 +482,7 @@ static int handle_page_fault(struct pt_regs *regs,
 	}
 #endif
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	return 1;
 
 /*
@@ -490,7 +490,7 @@ static int handle_page_fault(struct pt_regs *regs,
  * Fix it, but check if it's kernel or user first..
  */
 bad_area:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 bad_area_nosemaphore:
 	/* User mode accesses just cause a SIGSEGV */
@@ -557,14 +557,14 @@ static int handle_page_fault(struct pt_regs *regs,
  * us unable to handle the page fault gracefully.
  */
 out_of_memory:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	if (is_kernel_mode)
 		goto no_context;
 	pagefault_out_of_memory();
 	return 0;
 
 do_sigbus:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	/* Kernel mode? Handle exceptions or die */
 	if (is_kernel_mode)
diff --git a/arch/tile/mm/pgtable.c b/arch/tile/mm/pgtable.c
index ec5576fd3a86..2aab41fe69cf 100644
--- a/arch/tile/mm/pgtable.c
+++ b/arch/tile/mm/pgtable.c
@@ -430,7 +430,9 @@ void start_mm_caching(struct mm_struct *mm)
  */
 static unsigned long update_priority_cached(struct mm_struct *mm)
 {
-	if (mm->context.priority_cached && down_write_trylock(&mm->mmap_sem)) {
+	DEFINE_RANGE_LOCK_FULL(mmrange);
+
+	if (mm->context.priority_cached && mm_write_trylock(mm, &mmrange)) {
 		struct vm_area_struct *vm;
 		for (vm = mm->mmap; vm; vm = vm->vm_next) {
 			if (hv_pte_get_cached_priority(vm->vm_page_prot))
@@ -438,7 +440,7 @@ static unsigned long update_priority_cached(struct mm_struct *mm)
 		}
 		if (vm == NULL)
 			mm->context.priority_cached = 0;
-		up_write(&mm->mmap_sem);
+		mm_write_unlock(mm, &mmrange);
 	}
 	return mm->context.priority_cached;
 }
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
