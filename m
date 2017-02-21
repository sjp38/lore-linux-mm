Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7F0006B0391
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 04:59:08 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id v63so62734178pgv.0
        for <linux-mm@kvack.org>; Tue, 21 Feb 2017 01:59:08 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id q83si21472712pfa.19.2017.02.21.01.59.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Feb 2017 01:59:06 -0800 (PST)
From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 4/5] mm: convert mm_struct.mm_users from atomic_t to refcount_t
Date: Tue, 21 Feb 2017 11:58:43 +0200
Message-Id: <1487671124-11188-5-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1487671124-11188-1-git-send-email-elena.reshetova@intel.com>
References: <1487671124-11188-1-git-send-email-elena.reshetova@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, peterz@infradead.org, gregkh@linuxfoundation.org, viro@zeniv.linux.org.uk, catalin.marinas@arm.com, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, luto@kernel.org, Elena Reshetova <elena.reshetova@intel.com>, Hans Liljestrand <ishkamiel@gmail.com>, Kees Cook <keescook@chromium.org>, David Windsor <dwindsor@gmail.com>

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 arch/alpha/kernel/smp.c               |  6 +++---
 arch/arc/mm/tlb.c                     |  2 +-
 arch/blackfin/mach-common/smp.c       |  2 +-
 arch/ia64/include/asm/tlbflush.h      |  2 +-
 arch/ia64/kernel/smp.c                |  2 +-
 arch/ia64/sn/kernel/sn2/sn2_smp.c     |  4 ++--
 arch/mips/kernel/process.c            |  2 +-
 arch/mips/kernel/smp.c                |  6 +++---
 arch/parisc/include/asm/mmu_context.h |  2 +-
 arch/powerpc/mm/hugetlbpage.c         |  2 +-
 arch/powerpc/mm/icswx.c               |  4 ++--
 arch/sh/kernel/smp.c                  |  6 +++---
 arch/sparc/kernel/smp_64.c            |  6 +++---
 arch/sparc/mm/srmmu.c                 |  2 +-
 arch/um/kernel/tlb.c                  |  2 +-
 arch/x86/kernel/tboot.c               |  2 +-
 drivers/firmware/efi/arm-runtime.c    |  2 +-
 fs/coredump.c                         |  2 +-
 fs/proc/base.c                        |  2 +-
 include/linux/mm_types.h              |  3 ++-
 include/linux/sched.h                 |  4 ++--
 kernel/events/uprobes.c               |  2 +-
 kernel/exit.c                         |  2 +-
 kernel/fork.c                         | 10 +++++-----
 kernel/sched/core.c                   |  2 +-
 lib/is_single_threaded.c              |  2 +-
 mm/debug.c                            |  2 +-
 mm/init-mm.c                          |  2 +-
 mm/khugepaged.c                       |  2 +-
 mm/ksm.c                              |  2 +-
 mm/memory.c                           |  2 +-
 mm/mmu_notifier.c                     |  4 ++--
 mm/mprotect.c                         |  2 +-
 mm/oom_kill.c                         |  2 +-
 mm/swapfile.c                         |  2 +-
 mm/vmacache.c                         |  2 +-
 36 files changed, 53 insertions(+), 52 deletions(-)

diff --git a/arch/alpha/kernel/smp.c b/arch/alpha/kernel/smp.c
index acb4b14..c4a82f0 100644
--- a/arch/alpha/kernel/smp.c
+++ b/arch/alpha/kernel/smp.c
@@ -653,7 +653,7 @@ flush_tlb_mm(struct mm_struct *mm)
 
 	if (mm == current->active_mm) {
 		flush_tlb_current(mm);
-		if (atomic_read(&mm->mm_users) <= 1) {
+		if (refcount_read(&mm->mm_users) <= 1) {
 			int cpu, this_cpu = smp_processor_id();
 			for (cpu = 0; cpu < NR_CPUS; cpu++) {
 				if (!cpu_online(cpu) || cpu == this_cpu)
@@ -702,7 +702,7 @@ flush_tlb_page(struct vm_area_struct *vma, unsigned long addr)
 
 	if (mm == current->active_mm) {
 		flush_tlb_current_page(mm, vma, addr);
-		if (atomic_read(&mm->mm_users) <= 1) {
+		if (refcount_read(&mm->mm_users) <= 1) {
 			int cpu, this_cpu = smp_processor_id();
 			for (cpu = 0; cpu < NR_CPUS; cpu++) {
 				if (!cpu_online(cpu) || cpu == this_cpu)
@@ -758,7 +758,7 @@ flush_icache_user_range(struct vm_area_struct *vma, struct page *page,
 
 	if (mm == current->active_mm) {
 		__load_new_mm_context(mm);
-		if (atomic_read(&mm->mm_users) <= 1) {
+		if (refcount_read(&mm->mm_users) <= 1) {
 			int cpu, this_cpu = smp_processor_id();
 			for (cpu = 0; cpu < NR_CPUS; cpu++) {
 				if (!cpu_online(cpu) || cpu == this_cpu)
diff --git a/arch/arc/mm/tlb.c b/arch/arc/mm/tlb.c
index bdb295e..6dbdfe7 100644
--- a/arch/arc/mm/tlb.c
+++ b/arch/arc/mm/tlb.c
@@ -297,7 +297,7 @@ noinline void local_flush_tlb_mm(struct mm_struct *mm)
 	 * Only for fork( ) do we need to move parent to a new MMU ctxt,
 	 * all other cases are NOPs, hence this check.
 	 */
-	if (atomic_read(&mm->mm_users) == 0)
+	if (refcount_read(&mm->mm_users) == 0)
 		return;
 
 	/*
diff --git a/arch/blackfin/mach-common/smp.c b/arch/blackfin/mach-common/smp.c
index a2e6db2..bab73d2b 100644
--- a/arch/blackfin/mach-common/smp.c
+++ b/arch/blackfin/mach-common/smp.c
@@ -422,7 +422,7 @@ void cpu_die(void)
 {
 	(void)cpu_report_death();
 
-	atomic_dec(&init_mm.mm_users);
+	refcount_dec(&init_mm.mm_users);
 	atomic_dec(&init_mm.mm_count);
 
 	local_irq_disable();
diff --git a/arch/ia64/include/asm/tlbflush.h b/arch/ia64/include/asm/tlbflush.h
index 3be25df..650708a 100644
--- a/arch/ia64/include/asm/tlbflush.h
+++ b/arch/ia64/include/asm/tlbflush.h
@@ -56,7 +56,7 @@ flush_tlb_mm (struct mm_struct *mm)
 	set_bit(mm->context, ia64_ctx.flushmap);
 	mm->context = 0;
 
-	if (atomic_read(&mm->mm_users) == 0)
+	if (refcount_read(&mm->mm_users) == 0)
 		return;		/* happens as a result of exit_mmap() */
 
 #ifdef CONFIG_SMP
diff --git a/arch/ia64/kernel/smp.c b/arch/ia64/kernel/smp.c
index 7f706d4..dd7b680 100644
--- a/arch/ia64/kernel/smp.c
+++ b/arch/ia64/kernel/smp.c
@@ -295,7 +295,7 @@ smp_flush_tlb_mm (struct mm_struct *mm)
 	cpumask_var_t cpus;
 	preempt_disable();
 	/* this happens for the common case of a single-threaded fork():  */
-	if (likely(mm == current->active_mm && atomic_read(&mm->mm_users) == 1))
+	if (likely(mm == current->active_mm && refcount_read(&mm->mm_users) == 1))
 	{
 		local_finish_flush_tlb_mm(mm);
 		preempt_enable();
diff --git a/arch/ia64/sn/kernel/sn2/sn2_smp.c b/arch/ia64/sn/kernel/sn2/sn2_smp.c
index c98dc96..1c801b3 100644
--- a/arch/ia64/sn/kernel/sn2/sn2_smp.c
+++ b/arch/ia64/sn/kernel/sn2/sn2_smp.c
@@ -122,7 +122,7 @@ void sn_migrate(struct task_struct *task)
 void sn_tlb_migrate_finish(struct mm_struct *mm)
 {
 	/* flush_tlb_mm is inefficient if more than 1 users of mm */
-	if (mm == current->mm && mm && atomic_read(&mm->mm_users) == 1)
+	if (mm == current->mm && mm && refcount_read(&mm->mm_users) == 1)
 		flush_tlb_mm(mm);
 }
 
@@ -204,7 +204,7 @@ sn2_global_tlb_purge(struct mm_struct *mm, unsigned long start,
 		return;
 	}
 
-	if (atomic_read(&mm->mm_users) == 1 && mymm) {
+	if (refcount_read(&mm->mm_users) == 1 && mymm) {
 		flush_tlb_mm(mm);
 		__this_cpu_inc(ptcstats.change_rid);
 		preempt_enable();
diff --git a/arch/mips/kernel/process.c b/arch/mips/kernel/process.c
index 803e255..33fa000 100644
--- a/arch/mips/kernel/process.c
+++ b/arch/mips/kernel/process.c
@@ -698,7 +698,7 @@ int mips_set_process_fp_mode(struct task_struct *task, unsigned int value)
 		/* No need to send an IPI for the local CPU */
 		max_users = (task->mm == current->mm) ? 1 : 0;
 
-		if (atomic_read(&current->mm->mm_users) > max_users)
+		if (refcount_read(&current->mm->mm_users) > max_users)
 			smp_call_function(prepare_for_fp_mode_switch,
 					  (void *)current->mm, 1);
 	}
diff --git a/arch/mips/kernel/smp.c b/arch/mips/kernel/smp.c
index 8c60a29..e62aa56 100644
--- a/arch/mips/kernel/smp.c
+++ b/arch/mips/kernel/smp.c
@@ -511,7 +511,7 @@ void flush_tlb_mm(struct mm_struct *mm)
 {
 	preempt_disable();
 
-	if ((atomic_read(&mm->mm_users) != 1) || (current->mm != mm)) {
+	if ((refcount_read(&mm->mm_users) != 1) || (current->mm != mm)) {
 		smp_on_other_tlbs(flush_tlb_mm_ipi, mm);
 	} else {
 		unsigned int cpu;
@@ -544,7 +544,7 @@ void flush_tlb_range(struct vm_area_struct *vma, unsigned long start, unsigned l
 	struct mm_struct *mm = vma->vm_mm;
 
 	preempt_disable();
-	if ((atomic_read(&mm->mm_users) != 1) || (current->mm != mm)) {
+	if ((refcount_read(&mm->mm_users) != 1) || (current->mm != mm)) {
 		struct flush_tlb_data fd = {
 			.vma = vma,
 			.addr1 = start,
@@ -598,7 +598,7 @@ static void flush_tlb_page_ipi(void *info)
 void flush_tlb_page(struct vm_area_struct *vma, unsigned long page)
 {
 	preempt_disable();
-	if ((atomic_read(&vma->vm_mm->mm_users) != 1) || (current->mm != vma->vm_mm)) {
+	if ((refcount_read(&vma->vm_mm->mm_users) != 1) || (current->mm != vma->vm_mm)) {
 		struct flush_tlb_data fd = {
 			.vma = vma,
 			.addr1 = page,
diff --git a/arch/parisc/include/asm/mmu_context.h b/arch/parisc/include/asm/mmu_context.h
index 59be257..e64f398 100644
--- a/arch/parisc/include/asm/mmu_context.h
+++ b/arch/parisc/include/asm/mmu_context.h
@@ -21,7 +21,7 @@ extern void free_sid(unsigned long);
 static inline int
 init_new_context(struct task_struct *tsk, struct mm_struct *mm)
 {
-	BUG_ON(atomic_read(&mm->mm_users) != 1);
+	BUG_ON(refcount_read(&mm->mm_users) != 1);
 
 	mm->context = alloc_sid();
 	return 0;
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index 8c3389c..26aef24 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -403,7 +403,7 @@ static void hugepd_free(struct mmu_gather *tlb, void *hugepte)
 
 	batchp = &get_cpu_var(hugepd_freelist_cur);
 
-	if (atomic_read(&tlb->mm->mm_users) < 2 ||
+	if (refcount_read(&tlb->mm->mm_users) < 2 ||
 	    cpumask_equal(mm_cpumask(tlb->mm),
 			  cpumask_of(smp_processor_id()))) {
 		kmem_cache_free(hugepte_cache, hugepte);
diff --git a/arch/powerpc/mm/icswx.c b/arch/powerpc/mm/icswx.c
index 915412e..2406ff8 100644
--- a/arch/powerpc/mm/icswx.c
+++ b/arch/powerpc/mm/icswx.c
@@ -110,7 +110,7 @@ int use_cop(unsigned long acop, struct mm_struct *mm)
 	 * running. We need to send an IPI to force them to pick up any
 	 * change in PID and ACOP.
 	 */
-	if (atomic_read(&mm->mm_users) > 1)
+	if (refcount_read(&mm->mm_users) > 1)
 		smp_call_function(sync_cop, mm, 1);
 
 out:
@@ -150,7 +150,7 @@ void drop_cop(unsigned long acop, struct mm_struct *mm)
 	 * running. We need to send an IPI to force them to pick up any
 	 * change in PID and ACOP.
 	 */
-	if (atomic_read(&mm->mm_users) > 1)
+	if (refcount_read(&mm->mm_users) > 1)
 		smp_call_function(sync_cop, mm, 1);
 
 	if (free_pid != COP_PID_NONE)
diff --git a/arch/sh/kernel/smp.c b/arch/sh/kernel/smp.c
index edc4769..9d678bb 100644
--- a/arch/sh/kernel/smp.c
+++ b/arch/sh/kernel/smp.c
@@ -363,7 +363,7 @@ void flush_tlb_mm(struct mm_struct *mm)
 {
 	preempt_disable();
 
-	if ((atomic_read(&mm->mm_users) != 1) || (current->mm != mm)) {
+	if ((refcount_read(&mm->mm_users) != 1) || (current->mm != mm)) {
 		smp_call_function(flush_tlb_mm_ipi, (void *)mm, 1);
 	} else {
 		int i;
@@ -395,7 +395,7 @@ void flush_tlb_range(struct vm_area_struct *vma,
 	struct mm_struct *mm = vma->vm_mm;
 
 	preempt_disable();
-	if ((atomic_read(&mm->mm_users) != 1) || (current->mm != mm)) {
+	if ((refcount_read(&mm->mm_users) != 1) || (current->mm != mm)) {
 		struct flush_tlb_data fd;
 
 		fd.vma = vma;
@@ -438,7 +438,7 @@ static void flush_tlb_page_ipi(void *info)
 void flush_tlb_page(struct vm_area_struct *vma, unsigned long page)
 {
 	preempt_disable();
-	if ((atomic_read(&vma->vm_mm->mm_users) != 1) ||
+	if ((refcount_read(&vma->vm_mm->mm_users) != 1) ||
 	    (current->mm != vma->vm_mm)) {
 		struct flush_tlb_data fd;
 
diff --git a/arch/sparc/kernel/smp_64.c b/arch/sparc/kernel/smp_64.c
index dcb12d9..bd5e56c 100644
--- a/arch/sparc/kernel/smp_64.c
+++ b/arch/sparc/kernel/smp_64.c
@@ -1063,7 +1063,7 @@ void smp_flush_tlb_mm(struct mm_struct *mm)
 	u32 ctx = CTX_HWBITS(mm->context);
 	int cpu = get_cpu();
 
-	if (atomic_read(&mm->mm_users) == 1) {
+	if (refcount_read(&mm->mm_users) == 1) {
 		cpumask_copy(mm_cpumask(mm), cpumask_of(cpu));
 		goto local_flush_and_out;
 	}
@@ -1101,7 +1101,7 @@ void smp_flush_tlb_pending(struct mm_struct *mm, unsigned long nr, unsigned long
 	info.nr = nr;
 	info.vaddrs = vaddrs;
 
-	if (mm == current->mm && atomic_read(&mm->mm_users) == 1)
+	if (mm == current->mm && refcount_read(&mm->mm_users) == 1)
 		cpumask_copy(mm_cpumask(mm), cpumask_of(cpu));
 	else
 		smp_call_function_many(mm_cpumask(mm), tlb_pending_func,
@@ -1117,7 +1117,7 @@ void smp_flush_tlb_page(struct mm_struct *mm, unsigned long vaddr)
 	unsigned long context = CTX_HWBITS(mm->context);
 	int cpu = get_cpu();
 
-	if (mm == current->mm && atomic_read(&mm->mm_users) == 1)
+	if (mm == current->mm && refcount_read(&mm->mm_users) == 1)
 		cpumask_copy(mm_cpumask(mm), cpumask_of(cpu));
 	else
 		smp_cross_call_masked(&xcall_flush_tlb_page,
diff --git a/arch/sparc/mm/srmmu.c b/arch/sparc/mm/srmmu.c
index c7f2a52..17941a8 100644
--- a/arch/sparc/mm/srmmu.c
+++ b/arch/sparc/mm/srmmu.c
@@ -1662,7 +1662,7 @@ static void smp_flush_tlb_mm(struct mm_struct *mm)
 		cpumask_clear_cpu(smp_processor_id(), &cpu_mask);
 		if (!cpumask_empty(&cpu_mask)) {
 			xc1((smpfunc_t) local_ops->tlb_mm, (unsigned long) mm);
-			if (atomic_read(&mm->mm_users) == 1 && current->active_mm == mm)
+			if (refcount_read(&mm->mm_users) == 1 && current->active_mm == mm)
 				cpumask_copy(mm_cpumask(mm),
 					     cpumask_of(smp_processor_id()));
 		}
diff --git a/arch/um/kernel/tlb.c b/arch/um/kernel/tlb.c
index 3777b82..1da0463 100644
--- a/arch/um/kernel/tlb.c
+++ b/arch/um/kernel/tlb.c
@@ -530,7 +530,7 @@ void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 	 * Don't bother flushing if this address space is about to be
 	 * destroyed.
 	 */
-	if (atomic_read(&mm->mm_users) == 0)
+	if (refcount_read(&mm->mm_users) == 0)
 		return;
 
 	fix_range(mm, start, end, 0);
diff --git a/arch/x86/kernel/tboot.c b/arch/x86/kernel/tboot.c
index b868fa1..39aaca5 100644
--- a/arch/x86/kernel/tboot.c
+++ b/arch/x86/kernel/tboot.c
@@ -102,7 +102,7 @@ static pgd_t *tboot_pg_dir;
 static struct mm_struct tboot_mm = {
 	.mm_rb          = RB_ROOT,
 	.pgd            = swapper_pg_dir,
-	.mm_users       = ATOMIC_INIT(2),
+	.mm_users       = REFCOUNT_INIT(2),
 	.mm_count       = ATOMIC_INIT(1),
 	.mmap_sem       = __RWSEM_INITIALIZER(init_mm.mmap_sem),
 	.page_table_lock =  __SPIN_LOCK_UNLOCKED(init_mm.page_table_lock),
diff --git a/drivers/firmware/efi/arm-runtime.c b/drivers/firmware/efi/arm-runtime.c
index 349dc3e..23e41f9 100644
--- a/drivers/firmware/efi/arm-runtime.c
+++ b/drivers/firmware/efi/arm-runtime.c
@@ -32,7 +32,7 @@ extern u64 efi_system_table;
 
 static struct mm_struct efi_mm = {
 	.mm_rb			= RB_ROOT,
-	.mm_users		= ATOMIC_INIT(2),
+	.mm_users		= REFCOUNT_INIT(2),
 	.mm_count		= ATOMIC_INIT(1),
 	.mmap_sem		= __RWSEM_INITIALIZER(efi_mm.mmap_sem),
 	.page_table_lock	= __SPIN_LOCK_UNLOCKED(efi_mm.page_table_lock),
diff --git a/fs/coredump.c b/fs/coredump.c
index ae6b056..05e43f1 100644
--- a/fs/coredump.c
+++ b/fs/coredump.c
@@ -347,7 +347,7 @@ static int zap_threads(struct task_struct *tsk, struct mm_struct *mm,
 		return nr;
 
 	tsk->flags |= PF_DUMPCORE;
-	if (atomic_read(&mm->mm_users) == nr + 1)
+	if (refcount_read(&mm->mm_users) == nr + 1)
 		goto done;
 	/*
 	 * We should find and kill all tasks which use this mm, and we should
diff --git a/fs/proc/base.c b/fs/proc/base.c
index 6e86558..445b259 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1062,7 +1062,7 @@ static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
 		struct task_struct *p = find_lock_task_mm(task);
 
 		if (p) {
-			if (atomic_read(&p->mm->mm_users) > 1) {
+			if (refcount_read(&p->mm->mm_users) > 1) {
 				mm = p->mm;
 				mmgrab(mm);
 			}
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 4f6d440..af260d6 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -7,6 +7,7 @@
 #include <linux/list.h>
 #include <linux/spinlock.h>
 #include <linux/rbtree.h>
+#include <linux/refcount.h>
 #include <linux/rwsem.h>
 #include <linux/completion.h>
 #include <linux/cpumask.h>
@@ -417,7 +418,7 @@ struct mm_struct {
 	 * (which may then free the &struct mm_struct if @mm_count also
 	 * drops to 0).
 	 */
-	atomic_t mm_users;
+	refcount_t mm_users;
 
 	/**
 	 * @mm_count: The number of references to &struct mm_struct
diff --git a/include/linux/sched.h b/include/linux/sched.h
index affcd93..c21682c 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2967,12 +2967,12 @@ static inline void mmdrop_async(struct mm_struct *mm)
  */
 static inline void mmget(struct mm_struct *mm)
 {
-	atomic_inc(&mm->mm_users);
+	refcount_inc(&mm->mm_users);
 }
 
 static inline bool mmget_not_zero(struct mm_struct *mm)
 {
-	return atomic_inc_not_zero(&mm->mm_users);
+	return refcount_inc_not_zero(&mm->mm_users);
 }
 
 /* mmput gets rid of the mappings and all user-space */
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 95e42f0..a4b33f8 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -1121,7 +1121,7 @@ void uprobe_munmap(struct vm_area_struct *vma, unsigned long start, unsigned lon
 	if (no_uprobe_events() || !valid_vma(vma, false))
 		return;
 
-	if (!atomic_read(&vma->vm_mm->mm_users)) /* called by mmput() ? */
+	if (!refcount_read(&vma->vm_mm->mm_users)) /* called by mmput() ? */
 		return;
 
 	if (!test_bit(MMF_HAS_UPROBES, &vma->vm_mm->flags) ||
diff --git a/kernel/exit.c b/kernel/exit.c
index 8a768a3..261305d 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -426,7 +426,7 @@ void mm_update_next_owner(struct mm_struct *mm)
 	 * candidates.  Do not leave the mm pointing to a possibly
 	 * freed task structure.
 	 */
-	if (atomic_read(&mm->mm_users) <= 1) {
+	if (refcount_read(&mm->mm_users) <= 1) {
 		mm->owner = NULL;
 		return;
 	}
diff --git a/kernel/fork.c b/kernel/fork.c
index 0e096fc..60ff801 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -759,7 +759,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
 	mm->mmap = NULL;
 	mm->mm_rb = RB_ROOT;
 	mm->vmacache_seqnum = 0;
-	atomic_set(&mm->mm_users, 1);
+	refcount_set(&mm->mm_users, 1);
 	atomic_set(&mm->mm_count, 1);
 	init_rwsem(&mm->mmap_sem);
 	INIT_LIST_HEAD(&mm->mmlist);
@@ -862,7 +862,7 @@ EXPORT_SYMBOL_GPL(__mmdrop);
 
 static inline void __mmput(struct mm_struct *mm)
 {
-	VM_BUG_ON(atomic_read(&mm->mm_users));
+	VM_BUG_ON(refcount_read(&mm->mm_users));
 
 	uprobe_clear_state(mm);
 	exit_aio(mm);
@@ -889,7 +889,7 @@ void mmput(struct mm_struct *mm)
 {
 	might_sleep();
 
-	if (atomic_dec_and_test(&mm->mm_users))
+	if (refcount_dec_and_test(&mm->mm_users))
 		__mmput(mm);
 }
 EXPORT_SYMBOL_GPL(mmput);
@@ -903,7 +903,7 @@ static void mmput_async_fn(struct work_struct *work)
 
 void mmput_async(struct mm_struct *mm)
 {
-	if (atomic_dec_and_test(&mm->mm_users)) {
+	if (refcount_dec_and_test(&mm->mm_users)) {
 		INIT_WORK(&mm->async_put_work, mmput_async_fn);
 		schedule_work(&mm->async_put_work);
 	}
@@ -1102,7 +1102,7 @@ void mm_release(struct task_struct *tsk, struct mm_struct *mm)
 	 */
 	if (tsk->clear_child_tid) {
 		if (!(tsk->signal->flags & SIGNAL_GROUP_COREDUMP) &&
-		    atomic_read(&mm->mm_users) > 1) {
+		    refcount_read(&mm->mm_users) > 1) {
 			/*
 			 * We don't check the error code - if userspace has
 			 * not set up a proper pointer then tough luck.
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index c7ded33..324ea09 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -2196,7 +2196,7 @@ static void __sched_fork(unsigned long clone_flags, struct task_struct *p)
 #endif
 
 #ifdef CONFIG_NUMA_BALANCING
-	if (p->mm && atomic_read(&p->mm->mm_users) == 1) {
+	if (p->mm && refcount_read(&p->mm->mm_users) == 1) {
 		p->mm->numa_next_scan = jiffies + msecs_to_jiffies(sysctl_numa_balancing_scan_delay);
 		p->mm->numa_scan_seq = 0;
 	}
diff --git a/lib/is_single_threaded.c b/lib/is_single_threaded.c
index 391fd23..295ddcf 100644
--- a/lib/is_single_threaded.c
+++ b/lib/is_single_threaded.c
@@ -25,7 +25,7 @@ bool current_is_single_threaded(void)
 	if (atomic_read(&task->signal->live) != 1)
 		return false;
 
-	if (atomic_read(&mm->mm_users) == 1)
+	if (refcount_read(&mm->mm_users) == 1)
 		return true;
 
 	ret = false;
diff --git a/mm/debug.c b/mm/debug.c
index db1cd26..0866505 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -134,7 +134,7 @@ void dump_mm(const struct mm_struct *mm)
 		mm->get_unmapped_area,
 #endif
 		mm->mmap_base, mm->mmap_legacy_base, mm->highest_vm_end,
-		mm->pgd, atomic_read(&mm->mm_users),
+		mm->pgd, refcount_read(&mm->mm_users),
 		atomic_read(&mm->mm_count),
 		atomic_long_read((atomic_long_t *)&mm->nr_ptes),
 		mm_nr_pmds((struct mm_struct *)mm),
diff --git a/mm/init-mm.c b/mm/init-mm.c
index 975e49f..6927a72 100644
--- a/mm/init-mm.c
+++ b/mm/init-mm.c
@@ -17,7 +17,7 @@
 struct mm_struct init_mm = {
 	.mm_rb		= RB_ROOT,
 	.pgd		= swapper_pg_dir,
-	.mm_users	= ATOMIC_INIT(2),
+	.mm_users	= REFCOUNT_INIT(2),
 	.mm_count	= ATOMIC_INIT(1),
 	.mmap_sem	= __RWSEM_INITIALIZER(init_mm.mmap_sem),
 	.page_table_lock =  __SPIN_LOCK_UNLOCKED(init_mm.page_table_lock),
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 34bce5c..e7c11a6 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -391,7 +391,7 @@ static void insert_to_mm_slots_hash(struct mm_struct *mm,
 
 static inline int khugepaged_test_exit(struct mm_struct *mm)
 {
-	return atomic_read(&mm->mm_users) == 0;
+	return refcount_read(&mm->mm_users) == 0;
 }
 
 int __khugepaged_enter(struct mm_struct *mm)
diff --git a/mm/ksm.c b/mm/ksm.c
index 2e129f0..6152465 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -358,7 +358,7 @@ static void insert_to_mm_slots_hash(struct mm_struct *mm,
  */
 static inline bool ksm_test_exit(struct mm_struct *mm)
 {
-	return atomic_read(&mm->mm_users) == 0;
+	return refcount_read(&mm->mm_users) == 0;
 }
 
 /*
diff --git a/mm/memory.c b/mm/memory.c
index 0c759ba..cc93a22 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -374,7 +374,7 @@ void tlb_remove_table(struct mmu_gather *tlb, void *table)
 	 * When there's less then two users of this mm there cannot be a
 	 * concurrent page-table walk.
 	 */
-	if (atomic_read(&tlb->mm->mm_users) < 2) {
+	if (refcount_read(&tlb->mm->mm_users) < 2) {
 		__tlb_remove_table(table);
 		return;
 	}
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 32bc9f2..7a2aa2d 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -249,7 +249,7 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
 	struct mmu_notifier_mm *mmu_notifier_mm;
 	int ret;
 
-	BUG_ON(atomic_read(&mm->mm_users) <= 0);
+	BUG_ON(refcount_read(&mm->mm_users) == 0);
 
 	/*
 	 * Verify that mmu_notifier_init() already run and the global srcu is
@@ -295,7 +295,7 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
 		up_write(&mm->mmap_sem);
 	kfree(mmu_notifier_mm);
 out:
-	BUG_ON(atomic_read(&mm->mm_users) <= 0);
+	BUG_ON(refcount_read(&mm->mm_users) == 0);
 	return ret;
 }
 
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 77115bb..f482ce9 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -63,7 +63,7 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 
 	/* Get target node for single threaded private VMAs */
 	if (prot_numa && !(vma->vm_flags & VM_SHARED) &&
-	    atomic_read(&vma->vm_mm->mm_users) == 1)
+	    refcount_read(&vma->vm_mm->mm_users) == 1)
 		target_node = numa_node_id();
 
 	arch_enter_lazy_mmu_mode();
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 51c0918..cc0348d 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -774,7 +774,7 @@ static bool task_will_free_mem(struct task_struct *task)
 	if (test_bit(MMF_OOM_SKIP, &mm->flags))
 		return false;
 
-	if (atomic_read(&mm->mm_users) <= 1)
+	if (refcount_read(&mm->mm_users) <= 1)
 		return true;
 
 	/*
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 5ac2cb4..be949e4 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1722,7 +1722,7 @@ int try_to_unuse(unsigned int type, bool frontswap,
 		/*
 		 * Don't hold on to start_mm if it looks like exiting.
 		 */
-		if (atomic_read(&start_mm->mm_users) == 1) {
+		if (refcount_read(&start_mm->mm_users) == 1) {
 			mmput(start_mm);
 			start_mm = &init_mm;
 			mmget(&init_mm);
diff --git a/mm/vmacache.c b/mm/vmacache.c
index 035fdeb..4747ee6 100644
--- a/mm/vmacache.c
+++ b/mm/vmacache.c
@@ -26,7 +26,7 @@ void vmacache_flush_all(struct mm_struct *mm)
 	 * to worry about other threads' seqnum. Current's
 	 * flush will occur upon the next lookup.
 	 */
-	if (atomic_read(&mm->mm_users) == 1)
+	if (refcount_read(&mm->mm_users) == 1)
 		return;
 
 	rcu_read_lock();
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
