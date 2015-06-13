Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 5FA556B006E
	for <linux-mm@kvack.org>; Sat, 13 Jun 2015 05:49:42 -0400 (EDT)
Received: by wiga1 with SMTP id a1so34789171wig.0
        for <linux-mm@kvack.org>; Sat, 13 Jun 2015 02:49:42 -0700 (PDT)
Received: from mail-wi0-x22a.google.com (mail-wi0-x22a.google.com. [2a00:1450:400c:c05::22a])
        by mx.google.com with ESMTPS id fl20si11571249wjc.185.2015.06.13.02.49.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 13 Jun 2015 02:49:41 -0700 (PDT)
Received: by wifx6 with SMTP id x6so34978467wif.0
        for <linux-mm@kvack.org>; Sat, 13 Jun 2015 02:49:40 -0700 (PDT)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 05/12] mm: Introduce arch_pgd_init_late()
Date: Sat, 13 Jun 2015 11:49:08 +0200
Message-Id: <1434188955-31397-6-git-send-email-mingo@kernel.org>
In-Reply-To: <1434188955-31397-1-git-send-email-mingo@kernel.org>
References: <1434188955-31397-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Waiman Long <Waiman.Long@hp.com>

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
 arch/Kconfig       |  9 +++++++++
 fs/exec.c          |  3 +++
 include/linux/mm.h |  6 ++++++
 kernel/fork.c      | 16 ++++++++++++++++
 4 files changed, 34 insertions(+)

diff --git a/arch/Kconfig b/arch/Kconfig
index a65eafb24997..a8e866cd4247 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -491,6 +491,15 @@ config PGTABLE_LEVELS
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
diff --git a/fs/exec.c b/fs/exec.c
index 1977c2a553ac..4ce1383d5bba 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -860,7 +860,10 @@ static int exec_mmap(struct mm_struct *mm)
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
index 0755b9fd03a7..a3edc839e431 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1134,6 +1134,12 @@ int follow_phys(struct vm_area_struct *vma, unsigned long address,
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
index 03c1eaaa6ef5..cfa84971fb52 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1592,6 +1592,22 @@ static struct task_struct *copy_process(unsigned long clone_flags,
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
 	cgroup_post_fork(p);
 	if (clone_flags & CLONE_THREAD)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
