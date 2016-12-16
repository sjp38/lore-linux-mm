Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1B1F46B0069
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 03:23:01 -0500 (EST)
Received: by mail-vk0-f71.google.com with SMTP id h67so65169835vkf.4
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 00:23:01 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id x7si2001621uax.148.2016.12.16.00.22.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 00:23:00 -0800 (PST)
From: Vegard Nossum <vegard.nossum@oracle.com>
Subject: [PATCH 2/4] mm: add new mmget() helper
Date: Fri, 16 Dec 2016 09:22:00 +0100
Message-Id: <20161216082202.21044-2-vegard.nossum@oracle.com>
In-Reply-To: <20161216082202.21044-1-vegard.nossum@oracle.com>
References: <20161216082202.21044-1-vegard.nossum@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Rik van Riel <riel@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Al Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Vegard Nossum <vegard.nossum@oracle.com>

Apart from adding the helper function itself, the rest of the kernel is
converted mechanically using:

  git grep -l 'atomic_inc.*mm_users' | xargs sed -i 's/atomic_inc(&\(.*\)->mm_users);/mmget\(\1\);/'
  git grep -l 'atomic_inc.*mm_users' | xargs sed -i 's/atomic_inc(&\(.*\)\.mm_users);/mmget\(\&\1\);/'

This is needed for a later patch that hooks into the helper, but might be
a worthwhile cleanup on its own.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
---
 arch/arc/kernel/smp.c           |  2 +-
 arch/blackfin/mach-common/smp.c |  2 +-
 arch/frv/mm/mmu-context.c       |  2 +-
 arch/metag/kernel/smp.c         |  2 +-
 arch/sh/kernel/smp.c            |  2 +-
 arch/xtensa/kernel/smp.c        |  2 +-
 include/linux/sched.h           |  5 +++++
 kernel/fork.c                   |  4 ++--
 mm/swapfile.c                   | 10 +++++-----
 virt/kvm/async_pf.c             |  2 +-
 10 files changed, 19 insertions(+), 14 deletions(-)

diff --git a/arch/arc/kernel/smp.c b/arch/arc/kernel/smp.c
index 9cbc7aba3ede..eec70cb71db1 100644
--- a/arch/arc/kernel/smp.c
+++ b/arch/arc/kernel/smp.c
@@ -124,7 +124,7 @@ void start_kernel_secondary(void)
 	/* MMU, Caches, Vector Table, Interrupts etc */
 	setup_processor();
 
-	atomic_inc(&mm->mm_users);
+	mmget(mm);
 	mmgrab(mm);
 	current->active_mm = mm;
 	cpumask_set_cpu(cpu, mm_cpumask(mm));
diff --git a/arch/blackfin/mach-common/smp.c b/arch/blackfin/mach-common/smp.c
index bc5617ef7128..a2e6db2ce811 100644
--- a/arch/blackfin/mach-common/smp.c
+++ b/arch/blackfin/mach-common/smp.c
@@ -307,7 +307,7 @@ void secondary_start_kernel(void)
 	local_irq_disable();
 
 	/* Attach the new idle task to the global mm. */
-	atomic_inc(&mm->mm_users);
+	mmget(mm);
 	mmgrab(mm);
 	current->active_mm = mm;
 
diff --git a/arch/frv/mm/mmu-context.c b/arch/frv/mm/mmu-context.c
index 81757d55a5b5..3473bde77f56 100644
--- a/arch/frv/mm/mmu-context.c
+++ b/arch/frv/mm/mmu-context.c
@@ -188,7 +188,7 @@ int cxn_pin_by_pid(pid_t pid)
 		task_lock(tsk);
 		if (tsk->mm) {
 			mm = tsk->mm;
-			atomic_inc(&mm->mm_users);
+			mmget(mm);
 			ret = 0;
 		}
 		task_unlock(tsk);
diff --git a/arch/metag/kernel/smp.c b/arch/metag/kernel/smp.c
index af9cff547a19..c622293254e4 100644
--- a/arch/metag/kernel/smp.c
+++ b/arch/metag/kernel/smp.c
@@ -344,7 +344,7 @@ asmlinkage void secondary_start_kernel(void)
 	 * All kernel threads share the same mm context; grab a
 	 * reference and switch to it.
 	 */
-	atomic_inc(&mm->mm_users);
+	mmget(mm);
 	mmgrab(mm);
 	current->active_mm = mm;
 	cpumask_set_cpu(cpu, mm_cpumask(mm));
diff --git a/arch/sh/kernel/smp.c b/arch/sh/kernel/smp.c
index ee379c699c08..edc4769b047e 100644
--- a/arch/sh/kernel/smp.c
+++ b/arch/sh/kernel/smp.c
@@ -179,7 +179,7 @@ asmlinkage void start_secondary(void)
 
 	enable_mmu();
 	mmgrab(mm);
-	atomic_inc(&mm->mm_users);
+	mmget(mm);
 	current->active_mm = mm;
 #ifdef CONFIG_MMU
 	enter_lazy_tlb(mm, current);
diff --git a/arch/xtensa/kernel/smp.c b/arch/xtensa/kernel/smp.c
index 9bf5cea3bae4..fcea72019df7 100644
--- a/arch/xtensa/kernel/smp.c
+++ b/arch/xtensa/kernel/smp.c
@@ -135,7 +135,7 @@ void secondary_start_kernel(void)
 
 	/* All kernel threads share the same mm context. */
 
-	atomic_inc(&mm->mm_users);
+	mmget(mm);
 	mmgrab(mm);
 	current->active_mm = mm;
 	cpumask_set_cpu(cpu, mm_cpumask(mm));
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 31ae1f49eebb..2ca3e15dad3b 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2899,6 +2899,11 @@ static inline void mmdrop_async(struct mm_struct *mm)
 	}
 }
 
+static inline void mmget(struct mm_struct *mm)
+{
+	atomic_inc(&mm->mm_users);
+}
+
 static inline bool mmget_not_zero(struct mm_struct *mm)
 {
 	return atomic_inc_not_zero(&mm->mm_users);
diff --git a/kernel/fork.c b/kernel/fork.c
index 997ac1d584f7..f9c32dc6ccbc 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -989,7 +989,7 @@ struct mm_struct *get_task_mm(struct task_struct *task)
 		if (task->flags & PF_KTHREAD)
 			mm = NULL;
 		else
-			atomic_inc(&mm->mm_users);
+			mmget(mm);
 	}
 	task_unlock(task);
 	return mm;
@@ -1177,7 +1177,7 @@ static int copy_mm(unsigned long clone_flags, struct task_struct *tsk)
 	vmacache_flush(tsk);
 
 	if (clone_flags & CLONE_VM) {
-		atomic_inc(&oldmm->mm_users);
+		mmget(oldmm);
 		mm = oldmm;
 		goto good_mm;
 	}
diff --git a/mm/swapfile.c b/mm/swapfile.c
index f30438970cd1..cf73169ce153 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1402,7 +1402,7 @@ int try_to_unuse(unsigned int type, bool frontswap,
 	 * that.
 	 */
 	start_mm = &init_mm;
-	atomic_inc(&init_mm.mm_users);
+	mmget(&init_mm);
 
 	/*
 	 * Keep on scanning until all entries have gone.  Usually,
@@ -1451,7 +1451,7 @@ int try_to_unuse(unsigned int type, bool frontswap,
 		if (atomic_read(&start_mm->mm_users) == 1) {
 			mmput(start_mm);
 			start_mm = &init_mm;
-			atomic_inc(&init_mm.mm_users);
+			mmget(&init_mm);
 		}
 
 		/*
@@ -1488,8 +1488,8 @@ int try_to_unuse(unsigned int type, bool frontswap,
 			struct mm_struct *prev_mm = start_mm;
 			struct mm_struct *mm;
 
-			atomic_inc(&new_start_mm->mm_users);
-			atomic_inc(&prev_mm->mm_users);
+			mmget(new_start_mm);
+			mmget(prev_mm);
 			spin_lock(&mmlist_lock);
 			while (swap_count(*swap_map) && !retval &&
 					(p = p->next) != &start_mm->mmlist) {
@@ -1512,7 +1512,7 @@ int try_to_unuse(unsigned int type, bool frontswap,
 
 				if (set_start_mm && *swap_map < swcount) {
 					mmput(new_start_mm);
-					atomic_inc(&mm->mm_users);
+					mmget(mm);
 					new_start_mm = mm;
 					set_start_mm = 0;
 				}
diff --git a/virt/kvm/async_pf.c b/virt/kvm/async_pf.c
index efeceb0a222d..9ec9cef2b207 100644
--- a/virt/kvm/async_pf.c
+++ b/virt/kvm/async_pf.c
@@ -200,7 +200,7 @@ int kvm_setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, unsigned long hva,
 	work->addr = hva;
 	work->arch = *arch;
 	work->mm = current->mm;
-	atomic_inc(&work->mm->mm_users);
+	mmget(work->mm);
 	kvm_get_kvm(work->vcpu->kvm);
 
 	/* this can't really happen otherwise gfn_to_pfn_async
-- 
2.11.0.1.gaa10c3f

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
