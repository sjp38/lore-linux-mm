Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 67FB36B0069
	for <linux-mm@kvack.org>; Sun, 18 Dec 2016 07:33:12 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id n21so9045455qka.4
        for <linux-mm@kvack.org>; Sun, 18 Dec 2016 04:33:12 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id w20si476503qkw.312.2016.12.18.04.33.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Dec 2016 04:33:10 -0800 (PST)
From: Vegard Nossum <vegard.nossum@oracle.com>
Subject: [PATCH 1/4] mm: add new mmgrab() helper
Date: Sun, 18 Dec 2016 13:32:26 +0100
Message-Id: <20161218123229.22952-1-vegard.nossum@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org
Cc: Peter Zijlstra <peterz@infradead.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, Vegard Nossum <vegard.nossum@oracle.com>

Apart from adding the helper function itself, the rest of the kernel is
converted mechanically using:

  git grep -l 'atomic_inc.*mm_count' | xargs sed -i 's/atomic_inc(&\(.*\)->mm_count);/mmgrab\(\1\);/'
  git grep -l 'atomic_inc.*mm_count' | xargs sed -i 's/atomic_inc(&\(.*\)\.mm_count);/mmgrab\(\&\1\);/'

This is needed for a later patch that hooks into the helper, but might be
a worthwhile cleanup on its own.

(Michal Hocko provided most of the kerneldoc comment.)

Cc: Andrew Morton <akpm@linux-foundation.org>
Acked-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
---
 arch/alpha/kernel/smp.c                  |  2 +-
 arch/arc/kernel/smp.c                    |  2 +-
 arch/arm/kernel/smp.c                    |  2 +-
 arch/arm64/kernel/smp.c                  |  2 +-
 arch/blackfin/mach-common/smp.c          |  2 +-
 arch/hexagon/kernel/smp.c                |  2 +-
 arch/ia64/kernel/setup.c                 |  2 +-
 arch/m32r/kernel/setup.c                 |  2 +-
 arch/metag/kernel/smp.c                  |  2 +-
 arch/mips/kernel/traps.c                 |  2 +-
 arch/mn10300/kernel/smp.c                |  2 +-
 arch/parisc/kernel/smp.c                 |  2 +-
 arch/powerpc/kernel/smp.c                |  2 +-
 arch/s390/kernel/processor.c             |  2 +-
 arch/score/kernel/traps.c                |  2 +-
 arch/sh/kernel/smp.c                     |  2 +-
 arch/sparc/kernel/leon_smp.c             |  2 +-
 arch/sparc/kernel/smp_64.c               |  2 +-
 arch/sparc/kernel/sun4d_smp.c            |  2 +-
 arch/sparc/kernel/sun4m_smp.c            |  2 +-
 arch/sparc/kernel/traps_32.c             |  2 +-
 arch/sparc/kernel/traps_64.c             |  2 +-
 arch/tile/kernel/smpboot.c               |  2 +-
 arch/x86/kernel/cpu/common.c             |  4 ++--
 arch/xtensa/kernel/smp.c                 |  2 +-
 drivers/gpu/drm/amd/amdkfd/kfd_process.c |  2 +-
 drivers/gpu/drm/i915/i915_gem_userptr.c  |  2 +-
 drivers/infiniband/hw/hfi1/file_ops.c    |  2 +-
 fs/proc/base.c                           |  4 ++--
 fs/userfaultfd.c                         |  2 +-
 include/linux/sched.h                    | 22 ++++++++++++++++++++++
 kernel/exit.c                            |  2 +-
 kernel/futex.c                           |  2 +-
 kernel/sched/core.c                      |  4 ++--
 mm/khugepaged.c                          |  2 +-
 mm/ksm.c                                 |  2 +-
 mm/mmu_context.c                         |  2 +-
 mm/mmu_notifier.c                        |  2 +-
 mm/oom_kill.c                            |  4 ++--
 virt/kvm/kvm_main.c                      |  2 +-
 40 files changed, 65 insertions(+), 43 deletions(-)

diff --git a/arch/alpha/kernel/smp.c b/arch/alpha/kernel/smp.c
index 46bf263c3153..acb4b146a607 100644
--- a/arch/alpha/kernel/smp.c
+++ b/arch/alpha/kernel/smp.c
@@ -144,7 +144,7 @@ smp_callin(void)
 		alpha_mv.smp_callin();
 
 	/* All kernel threads share the same mm context.  */
-	atomic_inc(&init_mm.mm_count);
+	mmgrab(&init_mm);
 	current->active_mm = &init_mm;
 
 	/* inform the notifiers about the new cpu */
diff --git a/arch/arc/kernel/smp.c b/arch/arc/kernel/smp.c
index 88674d972c9d..9cbc7aba3ede 100644
--- a/arch/arc/kernel/smp.c
+++ b/arch/arc/kernel/smp.c
@@ -125,7 +125,7 @@ void start_kernel_secondary(void)
 	setup_processor();
 
 	atomic_inc(&mm->mm_users);
-	atomic_inc(&mm->mm_count);
+	mmgrab(mm);
 	current->active_mm = mm;
 	cpumask_set_cpu(cpu, mm_cpumask(mm));
 
diff --git a/arch/arm/kernel/smp.c b/arch/arm/kernel/smp.c
index 7dd14e8395e6..c6514ce0fcbc 100644
--- a/arch/arm/kernel/smp.c
+++ b/arch/arm/kernel/smp.c
@@ -371,7 +371,7 @@ asmlinkage void secondary_start_kernel(void)
 	 * reference and switch to it.
 	 */
 	cpu = smp_processor_id();
-	atomic_inc(&mm->mm_count);
+	mmgrab(mm);
 	current->active_mm = mm;
 	cpumask_set_cpu(cpu, mm_cpumask(mm));
 
diff --git a/arch/arm64/kernel/smp.c b/arch/arm64/kernel/smp.c
index cb87234cfcf2..959e41196cba 100644
--- a/arch/arm64/kernel/smp.c
+++ b/arch/arm64/kernel/smp.c
@@ -222,7 +222,7 @@ asmlinkage void secondary_start_kernel(void)
 	 * All kernel threads share the same mm context; grab a
 	 * reference and switch to it.
 	 */
-	atomic_inc(&mm->mm_count);
+	mmgrab(mm);
 	current->active_mm = mm;
 
 	/*
diff --git a/arch/blackfin/mach-common/smp.c b/arch/blackfin/mach-common/smp.c
index 23c4ef5f8bdc..bc5617ef7128 100644
--- a/arch/blackfin/mach-common/smp.c
+++ b/arch/blackfin/mach-common/smp.c
@@ -308,7 +308,7 @@ void secondary_start_kernel(void)
 
 	/* Attach the new idle task to the global mm. */
 	atomic_inc(&mm->mm_users);
-	atomic_inc(&mm->mm_count);
+	mmgrab(mm);
 	current->active_mm = mm;
 
 	preempt_disable();
diff --git a/arch/hexagon/kernel/smp.c b/arch/hexagon/kernel/smp.c
index 983bae7d2665..c02a6455839e 100644
--- a/arch/hexagon/kernel/smp.c
+++ b/arch/hexagon/kernel/smp.c
@@ -162,7 +162,7 @@ void start_secondary(void)
 	);
 
 	/*  Set the memory struct  */
-	atomic_inc(&init_mm.mm_count);
+	mmgrab(&init_mm);
 	current->active_mm = &init_mm;
 
 	cpu = smp_processor_id();
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 7ec7acc844c2..ecbff47b01f1 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -992,7 +992,7 @@ cpu_init (void)
 	 */
 	ia64_setreg(_IA64_REG_CR_DCR,  (  IA64_DCR_DP | IA64_DCR_DK | IA64_DCR_DX | IA64_DCR_DR
 					| IA64_DCR_DA | IA64_DCR_DD | IA64_DCR_LC));
-	atomic_inc(&init_mm.mm_count);
+	mmgrab(&init_mm);
 	current->active_mm = &init_mm;
 	BUG_ON(current->mm);
 
diff --git a/arch/m32r/kernel/setup.c b/arch/m32r/kernel/setup.c
index 136c69f1fb8a..b18bc0bd6544 100644
--- a/arch/m32r/kernel/setup.c
+++ b/arch/m32r/kernel/setup.c
@@ -403,7 +403,7 @@ void __init cpu_init (void)
 	printk(KERN_INFO "Initializing CPU#%d\n", cpu_id);
 
 	/* Set up and load the per-CPU TSS and LDT */
-	atomic_inc(&init_mm.mm_count);
+	mmgrab(&init_mm);
 	current->active_mm = &init_mm;
 	if (current->mm)
 		BUG();
diff --git a/arch/metag/kernel/smp.c b/arch/metag/kernel/smp.c
index bad13232de51..af9cff547a19 100644
--- a/arch/metag/kernel/smp.c
+++ b/arch/metag/kernel/smp.c
@@ -345,7 +345,7 @@ asmlinkage void secondary_start_kernel(void)
 	 * reference and switch to it.
 	 */
 	atomic_inc(&mm->mm_users);
-	atomic_inc(&mm->mm_count);
+	mmgrab(mm);
 	current->active_mm = mm;
 	cpumask_set_cpu(cpu, mm_cpumask(mm));
 	enter_lazy_tlb(mm, current);
diff --git a/arch/mips/kernel/traps.c b/arch/mips/kernel/traps.c
index 3905003dfe2b..e50b0e0ca44c 100644
--- a/arch/mips/kernel/traps.c
+++ b/arch/mips/kernel/traps.c
@@ -2177,7 +2177,7 @@ void per_cpu_trap_init(bool is_boot_cpu)
 	if (!cpu_data[cpu].asid_cache)
 		cpu_data[cpu].asid_cache = asid_first_version(cpu);
 
-	atomic_inc(&init_mm.mm_count);
+	mmgrab(&init_mm);
 	current->active_mm = &init_mm;
 	BUG_ON(current->mm);
 	enter_lazy_tlb(&init_mm, current);
diff --git a/arch/mn10300/kernel/smp.c b/arch/mn10300/kernel/smp.c
index 426173c4b0b9..e65b5cc2fa67 100644
--- a/arch/mn10300/kernel/smp.c
+++ b/arch/mn10300/kernel/smp.c
@@ -589,7 +589,7 @@ static void __init smp_cpu_init(void)
 	}
 	printk(KERN_INFO "Initializing CPU#%d\n", cpu_id);
 
-	atomic_inc(&init_mm.mm_count);
+	mmgrab(&init_mm);
 	current->active_mm = &init_mm;
 	BUG_ON(current->mm);
 
diff --git a/arch/parisc/kernel/smp.c b/arch/parisc/kernel/smp.c
index 75dab2871346..67b452b41ff6 100644
--- a/arch/parisc/kernel/smp.c
+++ b/arch/parisc/kernel/smp.c
@@ -279,7 +279,7 @@ smp_cpu_init(int cpunum)
 	set_cpu_online(cpunum, true);
 
 	/* Initialise the idle task for this CPU */
-	atomic_inc(&init_mm.mm_count);
+	mmgrab(&init_mm);
 	current->active_mm = &init_mm;
 	BUG_ON(current->mm);
 	enter_lazy_tlb(&init_mm, current);
diff --git a/arch/powerpc/kernel/smp.c b/arch/powerpc/kernel/smp.c
index 9c6f3fd58059..42b82364c782 100644
--- a/arch/powerpc/kernel/smp.c
+++ b/arch/powerpc/kernel/smp.c
@@ -707,7 +707,7 @@ void start_secondary(void *unused)
 	unsigned int cpu = smp_processor_id();
 	int i, base;
 
-	atomic_inc(&init_mm.mm_count);
+	mmgrab(&init_mm);
 	current->active_mm = &init_mm;
 
 	smp_store_cpu_info(cpu);
diff --git a/arch/s390/kernel/processor.c b/arch/s390/kernel/processor.c
index 9e60ef144d03..b8fc689c9e2a 100644
--- a/arch/s390/kernel/processor.c
+++ b/arch/s390/kernel/processor.c
@@ -73,7 +73,7 @@ void cpu_init(void)
 	get_cpu_id(id);
 	if (machine_has_cpu_mhz)
 		update_cpu_mhz(NULL);
-	atomic_inc(&init_mm.mm_count);
+	mmgrab(&init_mm);
 	current->active_mm = &init_mm;
 	BUG_ON(current->mm);
 	enter_lazy_tlb(&init_mm, current);
diff --git a/arch/score/kernel/traps.c b/arch/score/kernel/traps.c
index 5cea1e750cec..6f6e5a39d147 100644
--- a/arch/score/kernel/traps.c
+++ b/arch/score/kernel/traps.c
@@ -336,7 +336,7 @@ void __init trap_init(void)
 	set_except_vector(18, handle_dbe);
 	flush_icache_range(DEBUG_VECTOR_BASE_ADDR, IRQ_VECTOR_BASE_ADDR);
 
-	atomic_inc(&init_mm.mm_count);
+	mmgrab(&init_mm);
 	current->active_mm = &init_mm;
 	cpu_cache_init();
 }
diff --git a/arch/sh/kernel/smp.c b/arch/sh/kernel/smp.c
index 38e7860845db..ee379c699c08 100644
--- a/arch/sh/kernel/smp.c
+++ b/arch/sh/kernel/smp.c
@@ -178,7 +178,7 @@ asmlinkage void start_secondary(void)
 	struct mm_struct *mm = &init_mm;
 
 	enable_mmu();
-	atomic_inc(&mm->mm_count);
+	mmgrab(mm);
 	atomic_inc(&mm->mm_users);
 	current->active_mm = mm;
 #ifdef CONFIG_MMU
diff --git a/arch/sparc/kernel/leon_smp.c b/arch/sparc/kernel/leon_smp.c
index 71e16f2241c2..b99d33797e1d 100644
--- a/arch/sparc/kernel/leon_smp.c
+++ b/arch/sparc/kernel/leon_smp.c
@@ -93,7 +93,7 @@ void leon_cpu_pre_online(void *arg)
 			     : "memory" /* paranoid */);
 
 	/* Attach to the address space of init_task. */
-	atomic_inc(&init_mm.mm_count);
+	mmgrab(&init_mm);
 	current->active_mm = &init_mm;
 
 	while (!cpumask_test_cpu(cpuid, &smp_commenced_mask))
diff --git a/arch/sparc/kernel/smp_64.c b/arch/sparc/kernel/smp_64.c
index 8182f7caf5b1..c1d2bed22961 100644
--- a/arch/sparc/kernel/smp_64.c
+++ b/arch/sparc/kernel/smp_64.c
@@ -122,7 +122,7 @@ void smp_callin(void)
 	current_thread_info()->new_child = 0;
 
 	/* Attach to the address space of init_task. */
-	atomic_inc(&init_mm.mm_count);
+	mmgrab(&init_mm);
 	current->active_mm = &init_mm;
 
 	/* inform the notifiers about the new cpu */
diff --git a/arch/sparc/kernel/sun4d_smp.c b/arch/sparc/kernel/sun4d_smp.c
index 9d98e5002a09..7b55c50eabe5 100644
--- a/arch/sparc/kernel/sun4d_smp.c
+++ b/arch/sparc/kernel/sun4d_smp.c
@@ -93,7 +93,7 @@ void sun4d_cpu_pre_online(void *arg)
 	show_leds(cpuid);
 
 	/* Attach to the address space of init_task. */
-	atomic_inc(&init_mm.mm_count);
+	mmgrab(&init_mm);
 	current->active_mm = &init_mm;
 
 	local_ops->cache_all();
diff --git a/arch/sparc/kernel/sun4m_smp.c b/arch/sparc/kernel/sun4m_smp.c
index 278c40abce82..633c4cf6fdb0 100644
--- a/arch/sparc/kernel/sun4m_smp.c
+++ b/arch/sparc/kernel/sun4m_smp.c
@@ -59,7 +59,7 @@ void sun4m_cpu_pre_online(void *arg)
 			     : "memory" /* paranoid */);
 
 	/* Attach to the address space of init_task. */
-	atomic_inc(&init_mm.mm_count);
+	mmgrab(&init_mm);
 	current->active_mm = &init_mm;
 
 	while (!cpumask_test_cpu(cpuid, &smp_commenced_mask))
diff --git a/arch/sparc/kernel/traps_32.c b/arch/sparc/kernel/traps_32.c
index 4f21df7d4f13..ecddac5a4c96 100644
--- a/arch/sparc/kernel/traps_32.c
+++ b/arch/sparc/kernel/traps_32.c
@@ -448,7 +448,7 @@ void trap_init(void)
 		thread_info_offsets_are_bolixed_pete();
 
 	/* Attach to the address space of init_task. */
-	atomic_inc(&init_mm.mm_count);
+	mmgrab(&init_mm);
 	current->active_mm = &init_mm;
 
 	/* NOTE: Other cpus have this done as they are started
diff --git a/arch/sparc/kernel/traps_64.c b/arch/sparc/kernel/traps_64.c
index 496fa926e1e0..83dd1331a30e 100644
--- a/arch/sparc/kernel/traps_64.c
+++ b/arch/sparc/kernel/traps_64.c
@@ -2764,6 +2764,6 @@ void __init trap_init(void)
 	/* Attach to the address space of init_task.  On SMP we
 	 * do this in smp.c:smp_callin for other cpus.
 	 */
-	atomic_inc(&init_mm.mm_count);
+	mmgrab(&init_mm);
 	current->active_mm = &init_mm;
 }
diff --git a/arch/tile/kernel/smpboot.c b/arch/tile/kernel/smpboot.c
index 6c0abaacec33..53ce940a5016 100644
--- a/arch/tile/kernel/smpboot.c
+++ b/arch/tile/kernel/smpboot.c
@@ -160,7 +160,7 @@ static void start_secondary(void)
 	__this_cpu_write(current_asid, min_asid);
 
 	/* Set up this thread as another owner of the init_mm */
-	atomic_inc(&init_mm.mm_count);
+	mmgrab(&init_mm);
 	current->active_mm = &init_mm;
 	if (current->mm)
 		BUG();
diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
index 729f92ba8224..5b88f78c40f5 100644
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -1498,7 +1498,7 @@ void cpu_init(void)
 	for (i = 0; i <= IO_BITMAP_LONGS; i++)
 		t->io_bitmap[i] = ~0UL;
 
-	atomic_inc(&init_mm.mm_count);
+	mmgrab(&init_mm);
 	me->active_mm = &init_mm;
 	BUG_ON(me->mm);
 	enter_lazy_tlb(&init_mm, me);
@@ -1549,7 +1549,7 @@ void cpu_init(void)
 	/*
 	 * Set up and load the per-CPU TSS and LDT
 	 */
-	atomic_inc(&init_mm.mm_count);
+	mmgrab(&init_mm);
 	curr->active_mm = &init_mm;
 	BUG_ON(curr->mm);
 	enter_lazy_tlb(&init_mm, curr);
diff --git a/arch/xtensa/kernel/smp.c b/arch/xtensa/kernel/smp.c
index fc4ad21a5ed4..9bf5cea3bae4 100644
--- a/arch/xtensa/kernel/smp.c
+++ b/arch/xtensa/kernel/smp.c
@@ -136,7 +136,7 @@ void secondary_start_kernel(void)
 	/* All kernel threads share the same mm context. */
 
 	atomic_inc(&mm->mm_users);
-	atomic_inc(&mm->mm_count);
+	mmgrab(mm);
 	current->active_mm = mm;
 	cpumask_set_cpu(cpu, mm_cpumask(mm));
 	enter_lazy_tlb(mm, current);
diff --git a/drivers/gpu/drm/amd/amdkfd/kfd_process.c b/drivers/gpu/drm/amd/amdkfd/kfd_process.c
index ef7c8de7060e..ca5f2aa7232d 100644
--- a/drivers/gpu/drm/amd/amdkfd/kfd_process.c
+++ b/drivers/gpu/drm/amd/amdkfd/kfd_process.c
@@ -262,7 +262,7 @@ static void kfd_process_notifier_release(struct mmu_notifier *mn,
 	 * and because the mmu_notifier_unregister function also drop
 	 * mm_count we need to take an extra count here.
 	 */
-	atomic_inc(&p->mm->mm_count);
+	mmgrab(p->mm);
 	mmu_notifier_unregister_no_release(&p->mmu_notifier, p->mm);
 	mmu_notifier_call_srcu(&p->rcu, &kfd_process_destroy_delayed);
 }
diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
index d068af2ec3a3..1f27529cb48e 100644
--- a/drivers/gpu/drm/i915/i915_gem_userptr.c
+++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
@@ -334,7 +334,7 @@ i915_gem_userptr_init__mm_struct(struct drm_i915_gem_object *obj)
 		mm->i915 = to_i915(obj->base.dev);
 
 		mm->mm = current->mm;
-		atomic_inc(&current->mm->mm_count);
+		mmgrab(current->mm);
 
 		mm->mn = NULL;
 
diff --git a/drivers/infiniband/hw/hfi1/file_ops.c b/drivers/infiniband/hw/hfi1/file_ops.c
index bd786b7bd30b..2e1a6643a910 100644
--- a/drivers/infiniband/hw/hfi1/file_ops.c
+++ b/drivers/infiniband/hw/hfi1/file_ops.c
@@ -185,7 +185,7 @@ static int hfi1_file_open(struct inode *inode, struct file *fp)
 	if (fd) {
 		fd->rec_cpu_num = -1; /* no cpu affinity by default */
 		fd->mm = current->mm;
-		atomic_inc(&fd->mm->mm_count);
+		mmgrab(fd->mm);
 		fp->private_data = fd;
 	} else {
 		fp->private_data = NULL;
diff --git a/fs/proc/base.c b/fs/proc/base.c
index 5ea836362870..32f04999d930 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -798,7 +798,7 @@ struct mm_struct *proc_mem_open(struct inode *inode, unsigned int mode)
 
 		if (!IS_ERR_OR_NULL(mm)) {
 			/* ensure this mm_struct can't be freed */
-			atomic_inc(&mm->mm_count);
+			mmgrab(mm);
 			/* but do not pin its memory */
 			mmput(mm);
 		}
@@ -1096,7 +1096,7 @@ static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
 		if (p) {
 			if (atomic_read(&p->mm->mm_users) > 1) {
 				mm = p->mm;
-				atomic_inc(&mm->mm_count);
+				mmgrab(mm);
 			}
 			task_unlock(p);
 		}
diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index d96e2f30084b..a02bbf5897e6 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -1306,7 +1306,7 @@ static struct file *userfaultfd_file_create(int flags)
 	ctx->released = false;
 	ctx->mm = current->mm;
 	/* prevent the mm struct to be freed */
-	atomic_inc(&ctx->mm->mm_count);
+	mmgrab(ctx->mm);
 
 	file = anon_inode_getfile("[userfaultfd]", &userfaultfd_fops, ctx,
 				  O_RDWR | (flags & UFFD_SHARED_FCNTL_FLAGS));
diff --git a/include/linux/sched.h b/include/linux/sched.h
index a440cf178191..6ce46220bda2 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2911,6 +2911,28 @@ static inline unsigned long sigsp(unsigned long sp, struct ksignal *ksig)
  */
 extern struct mm_struct * mm_alloc(void);
 
+/**
+ * mmgrab() - Pin a &struct mm_struct.
+ * @mm: The &struct mm_struct to pin.
+ *
+ * Make sure that @mm will not get freed even after the owning task
+ * exits. This doesn't guarantee that the associated address space
+ * will still exist later on and mmget_not_zero() has to be used before
+ * accessing it.
+ *
+ * This is a preferred way to to pin @mm for a longer/unbounded amount
+ * of time.
+ *
+ * Use mmdrop() to release the reference acquired by mmgrab().
+ *
+ * See also <Documentation/vm/active_mm.txt> for an in-depth explanation
+ * of &mm_struct.mm_count vs &mm_struct.mm_users.
+ */
+static inline void mmgrab(struct mm_struct *mm)
+{
+	atomic_inc(&mm->mm_count);
+}
+
 /* mmdrop drops the mm and the page tables */
 extern void __mmdrop(struct mm_struct *);
 static inline void mmdrop(struct mm_struct *mm)
diff --git a/kernel/exit.c b/kernel/exit.c
index aacff8e2aec0..a0bfdace6a07 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -509,7 +509,7 @@ static void exit_mm(struct task_struct *tsk)
 		__set_task_state(tsk, TASK_RUNNING);
 		down_read(&mm->mmap_sem);
 	}
-	atomic_inc(&mm->mm_count);
+	mmgrab(mm);
 	BUG_ON(mm != tsk->active_mm);
 	/* more a memory barrier than a real lock */
 	task_lock(tsk);
diff --git a/kernel/futex.c b/kernel/futex.c
index 9246d9f593d1..cc84e6bd6a4d 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -338,7 +338,7 @@ static inline bool should_fail_futex(bool fshared)
 
 static inline void futex_get_mm(union futex_key *key)
 {
-	atomic_inc(&key->private.mm->mm_count);
+	mmgrab(key->private.mm);
 	/*
 	 * Ensure futex_get_mm() implies a full barrier such that
 	 * get_futex_key() implies a full barrier. This is relied upon
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 966556ebdbb3..49d7076d93c3 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -2878,7 +2878,7 @@ context_switch(struct rq *rq, struct task_struct *prev,
 
 	if (!mm) {
 		next->active_mm = oldmm;
-		atomic_inc(&oldmm->mm_count);
+		mmgrab(oldmm);
 		enter_lazy_tlb(oldmm, next);
 	} else
 		switch_mm_irqs_off(oldmm, mm, next);
@@ -7686,7 +7686,7 @@ void __init sched_init(void)
 	/*
 	 * The boot idle thread does lazy MMU switching as well:
 	 */
-	atomic_inc(&init_mm.mm_count);
+	mmgrab(&init_mm);
 	enter_lazy_tlb(&init_mm, current);
 
 	/*
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index e32389a97030..4cf3b3af6313 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -420,7 +420,7 @@ int __khugepaged_enter(struct mm_struct *mm)
 	list_add_tail(&mm_slot->mm_node, &khugepaged_scan.mm_head);
 	spin_unlock(&khugepaged_mm_lock);
 
-	atomic_inc(&mm->mm_count);
+	mmgrab(mm);
 	if (wakeup)
 		wake_up_interruptible(&khugepaged_wait);
 
diff --git a/mm/ksm.c b/mm/ksm.c
index 9ae6011a41f8..5a49aad9d87b 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1813,7 +1813,7 @@ int __ksm_enter(struct mm_struct *mm)
 	spin_unlock(&ksm_mmlist_lock);
 
 	set_bit(MMF_VM_MERGEABLE, &mm->flags);
-	atomic_inc(&mm->mm_count);
+	mmgrab(mm);
 
 	if (needs_wakeup)
 		wake_up_interruptible(&ksm_thread_wait);
diff --git a/mm/mmu_context.c b/mm/mmu_context.c
index 6f4d27c5bb32..daf67bb02b4a 100644
--- a/mm/mmu_context.c
+++ b/mm/mmu_context.c
@@ -25,7 +25,7 @@ void use_mm(struct mm_struct *mm)
 	task_lock(tsk);
 	active_mm = tsk->active_mm;
 	if (active_mm != mm) {
-		atomic_inc(&mm->mm_count);
+		mmgrab(mm);
 		tsk->active_mm = mm;
 	}
 	tsk->mm = mm;
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index f4259e496f83..32bc9f2ff7eb 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -275,7 +275,7 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
 		mm->mmu_notifier_mm = mmu_notifier_mm;
 		mmu_notifier_mm = NULL;
 	}
-	atomic_inc(&mm->mm_count);
+	mmgrab(mm);
 
 	/*
 	 * Serialize the update against mmu_notifier_unregister. A
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index ec9f11d4f094..ead093c6f2a6 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -660,7 +660,7 @@ static void mark_oom_victim(struct task_struct *tsk)
 
 	/* oom_mm is bound to the signal struct life time. */
 	if (!cmpxchg(&tsk->signal->oom_mm, NULL, mm))
-		atomic_inc(&tsk->signal->oom_mm->mm_count);
+		mmgrab(tsk->signal->oom_mm);
 
 	/*
 	 * Make sure that the task is woken up from uninterruptible sleep
@@ -877,7 +877,7 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 
 	/* Get a reference to safely compare mm after task_unlock(victim) */
 	mm = victim->mm;
-	atomic_inc(&mm->mm_count);
+	mmgrab(mm);
 	/*
 	 * We should send SIGKILL before setting TIF_MEMDIE in order to prevent
 	 * the OOM victim from depleting the memory reserves from the user
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index de102cae7125..3a61b572fa2c 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -616,7 +616,7 @@ static struct kvm *kvm_create_vm(unsigned long type)
 		return ERR_PTR(-ENOMEM);
 
 	spin_lock_init(&kvm->mmu_lock);
-	atomic_inc(&current->mm->mm_count);
+	mmgrab(current->mm);
 	kvm->mm = current->mm;
 	kvm_eventfd_init(kvm);
 	mutex_init(&kvm->lock);
-- 
2.11.0.1.gaa10c3f

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
