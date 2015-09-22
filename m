Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 3BA8B6B0258
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 02:24:14 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so176871578wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 23:24:13 -0700 (PDT)
Received: from mail-wi0-x233.google.com (mail-wi0-x233.google.com. [2a00:1450:400c:c05::233])
        by mx.google.com with ESMTPS id b13si36305061wjz.156.2015.09.21.23.24.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 23:24:13 -0700 (PDT)
Received: by wicgb1 with SMTP id gb1so144252244wic.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 23:24:13 -0700 (PDT)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 05/11] mm: Introduce arch_pgd_init_late()
Date: Tue, 22 Sep 2015 08:23:35 +0200
Message-Id: <1442903021-3893-6-git-send-email-mingo@kernel.org>
In-Reply-To: <1442903021-3893-1-git-send-email-mingo@kernel.org>
References: <1442903021-3893-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Waiman Long <waiman.long@hp.com>, Thomas Gleixner <tglx@linutronix.de>

Add a late PGD init callback to places that allocate a new MM
with a new PGD: copy_process() and exec().

The purpose of this callback is to allow architectures to implement
lockless initialization of task PGDs, to remove the scalability
limit of pgd_list/pgd_lock.

Architectures can opt in to this callback via the ARCH_HAS_PGD_INIT_LATE
Kconfig flag. There's zero overhead on architectures that are not using it.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Waiman Long <Waiman.Long@hp.com>
Cc: linux-arch@vger.kernel.org
Cc: linux-mm@kvack.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/Kconfig          |  9 ++++++++
 arch/x86/Kconfig      |  1 +
 arch/x86/mm/init_64.c | 12 +++++++++++
 arch/x86/mm/pgtable.c | 59 +++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/exec.c             |  3 +++
 include/linux/mm.h    |  6 ++++++
 kernel/fork.c         | 16 ++++++++++++++
 7 files changed, 106 insertions(+)

diff --git a/arch/Kconfig b/arch/Kconfig
index 4e949e58b192..671810ce6fe0 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -503,6 +503,15 @@ config PGTABLE_LEVELS
 	int
 	default 2
 
+config ARCH_HAS_PGD_INIT_LATE
+	bool
+	help
+	  Architectures that want a late PGD initialization can define
+	  the arch_pgd_init_late() callback and it will be called
+	  by the generic new task (fork()) code after a new task has
+	  been made visible on the task list, but before it has been
+	  first scheduled.
+
 config ARCH_HAS_ELF_RANDOMIZE
 	bool
 	help
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 328c8352480c..3e97b6cfdb60 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -27,6 +27,7 @@ config X86
 	select ARCH_HAS_ELF_RANDOMIZE
 	select ARCH_HAS_FAST_MULTIPLIER
 	select ARCH_HAS_GCOV_PROFILE_ALL
+	select ARCH_HAS_PGD_INIT_LATE
 	select ARCH_HAS_PMEM_API		if X86_64
 	select ARCH_HAS_MMIO_FLUSH
 	select ARCH_HAS_SG_CHAIN
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 467c4f66ded9..429362f8d6ca 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -177,6 +177,18 @@ void sync_global_pgds(unsigned long start, unsigned long end)
 			continue;
 
 		rcu_read_lock(); /* Task list walk */
+
+		/*
+		 * Since this is x86, this spin_lock() is also a full memory barrier that
+		 * is required for correct operation of the lockless reading of PGDs
+		 * in arch_pgd_init_late(). If you ever move this code to another
+		 * architecture or to generic code you need to make sure this is
+		 * an:
+		 *
+		 *	smp_mb();
+		 *
+		 * before looking at PGDs in the loop below.
+		 */
 		spin_lock(&pgd_lock);
 
 		for_each_process(g) {
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index fb0a9dd1d6e4..c7038b6e51bf 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -391,6 +391,65 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
 	return NULL;
 }
 
+/*
+ * Initialize the kernel portion of the PGD.
+ *
+ * This is done separately, because pgd_alloc() happens when
+ * the task is not on the task list yet - and PGD updates
+ * happen by walking the task list.
+ *
+ * No locking is needed here, as we just copy over the reference
+ * PGD. The reference PGD (pgtable_init) is only ever expanded
+ * at the highest, PGD level. Thus any other task extending it
+ * will first update the reference PGD, then modify the task PGDs.
+ */
+void arch_pgd_init_late(struct mm_struct *mm)
+{
+	/*
+	 * This function is called after a new MM has been made visible
+	 * in fork() or exec() via:
+	 *
+	 *   tsk->mm = mm;
+	 *
+	 * This barrier makes sure the MM is visible to new RCU
+	 * walkers before we read and initialize the pagetables below,
+	 * so that we don't miss updates:
+	 */
+	smp_mb();
+
+	/*
+	 * If the pgd points to a shared pagetable level (either the
+	 * ptes in non-PAE, or shared PMD in PAE), then just copy the
+	 * references from swapper_pg_dir:
+	 */
+	if ( CONFIG_PGTABLE_LEVELS == 2 ||
+	    (CONFIG_PGTABLE_LEVELS == 3 && SHARED_KERNEL_PMD) ||
+	     CONFIG_PGTABLE_LEVELS == 4) {
+
+		pgd_t *pgd_src = swapper_pg_dir + KERNEL_PGD_BOUNDARY;
+		pgd_t *pgd_dst =        mm->pgd + KERNEL_PGD_BOUNDARY;
+		int i;
+
+		for (i = 0; i < KERNEL_PGD_PTRS; i++, pgd_src++, pgd_dst++) {
+			/*
+			 * This is lock-less, so it can race with PGD updates
+			 * coming from vmalloc() or CPA methods, but it's safe,
+			 * because:
+			 *
+			 * 1) this PGD is not in use yet, we have still not
+			 *    scheduled this task.
+			 * 2) we only ever extend PGD entries
+			 *
+			 * So if we observe a non-zero PGD entry we can copy it,
+			 * it won't change from under us. Parallel updates (new
+			 * allocations) will modify our (already visible) PGD:
+			 */
+			if (!pgd_none(*pgd_src))
+				set_pgd(pgd_dst, *pgd_src);
+		}
+	}
+}
+
 void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 	pgd_mop_up_pmds(mm, pgd);
diff --git a/fs/exec.c b/fs/exec.c
index b06623a9347f..0a77a6991d0e 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -866,7 +866,10 @@ static int exec_mmap(struct mm_struct *mm)
 	}
 	task_lock(tsk);
 	active_mm = tsk->active_mm;
+
 	tsk->mm = mm;
+	arch_pgd_init_late(mm);
+
 	tsk->active_mm = mm;
 	activate_mm(active_mm, mm);
 	tsk->mm->vmacache_seqnum = 0;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 91c08f6f0dc9..8d008dfa9d73 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1152,6 +1152,12 @@ int follow_phys(struct vm_area_struct *vma, unsigned long address,
 int generic_access_phys(struct vm_area_struct *vma, unsigned long addr,
 			void *buf, int len, int write);
 
+#ifdef CONFIG_ARCH_HAS_PGD_INIT_LATE
+void arch_pgd_init_late(struct mm_struct *mm);
+#else
+static inline void arch_pgd_init_late(struct mm_struct *mm) { }
+#endif
+
 static inline void unmap_shared_mapping_range(struct address_space *mapping,
 		loff_t const holebegin, loff_t const holelen)
 {
diff --git a/kernel/fork.c b/kernel/fork.c
index 7d5f0f118a63..4668f8902b19 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1606,6 +1606,22 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	syscall_tracepoint_update(p);
 	write_unlock_irq(&tasklist_lock);
 
+	/*
+	 * If we have a new PGD then initialize it:
+	 *
+	 * This method is called after a task has been made visible
+	 * on the task list already.
+	 *
+	 * Architectures that manage per task kernel pagetables
+	 * might use this callback to initialize them after they
+	 * are already visible to new updates.
+	 *
+	 * NOTE: any user-space parts of the PGD are already initialized
+	 *       and must not be clobbered.
+	 */
+	if (!(clone_flags & CLONE_VM))
+		arch_pgd_init_late(p->mm);
+
 	proc_fork_connector(p);
 	cgroup_post_fork(p, cgrp_ss_priv);
 	if (clone_flags & CLONE_THREAD)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
