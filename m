Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 38CB09000C4
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 08:16:05 -0400 (EDT)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp05.au.ibm.com (8.14.4/8.13.1) with ESMTP id p8KC9E1e001504
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 22:09:14 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8KCE62Y958562
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 22:14:06 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8KCFxff011866
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 22:16:00 +1000
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Tue, 20 Sep 2011 17:32:21 +0530
Message-Id: <20110920120221.25326.74714.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v5 3.1.0-rc4-tip 12/26]   Uprobes: Handle breakpoint and Singlestep
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>


Provides routines to create/manage and free the task specific
information.

Adds a hook in uprobe_notify_resume to handle breakpoint and singlestep
exception.

Uprobes needs to maintain some task specific information including if a
task has hit a probepoint, uprobe corresponding to the probehit,
the slot where the original instruction is copied to before
single-stepping.

Signed-off-by: Jim Keniston <jkenisto@us.ibm.com>
Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 include/linux/sched.h   |    3 +
 include/linux/uprobes.h |   35 ++++++++
 kernel/fork.c           |    4 +
 kernel/uprobes.c        |  205 +++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 247 insertions(+), 0 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index bc6f5f2..4f84980 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1569,6 +1569,9 @@ struct task_struct {
 #ifdef CONFIG_HAVE_HW_BREAKPOINT
 	atomic_t ptrace_bp_refcnt;
 #endif
+#ifdef CONFIG_UPROBES
+	struct uprobe_task *utask;
+#endif
 };
 
 /* Future-safe accessor for struct task_struct's cpus_allowed. */
diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index 2c139f3..fa7eaba 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -70,6 +70,26 @@ struct uprobe {
 	u8			insn[MAX_UINSN_BYTES];
 };
 
+enum uprobe_task_state {
+	UTASK_RUNNING,
+	UTASK_BP_HIT,
+	UTASK_SSTEP
+};
+
+/*
+ * uprobe_utask -- not a user-visible struct.
+ * Corresponds to a thread in a probed process.
+ * Guarded by uproc->mutex.
+ */
+struct uprobe_task {
+	unsigned long xol_vaddr;
+	unsigned long vaddr;
+
+	enum uprobe_task_state state;
+
+	struct uprobe *active_uprobe;
+};
+
 #ifdef CONFIG_UPROBES
 extern int __weak set_bkpt(struct task_struct *tsk, struct uprobe *uprobe,
 							unsigned long vaddr);
@@ -82,8 +102,13 @@ extern int register_uprobe(struct inode *inode, loff_t offset,
 				struct uprobe_consumer *consumer);
 extern void unregister_uprobe(struct inode *inode, loff_t offset,
 				struct uprobe_consumer *consumer);
+extern void free_uprobe_utask(struct task_struct *tsk);
 extern int mmap_uprobe(struct vm_area_struct *vma);
 extern void munmap_uprobe(struct vm_area_struct *vma);
+extern unsigned long __weak get_uprobe_bkpt_addr(struct pt_regs *regs);
+extern int uprobe_post_notifier(struct pt_regs *regs);
+extern int uprobe_bkpt_notifier(struct pt_regs *regs);
+extern void uprobe_notify_resume(struct pt_regs *regs);
 #else /* CONFIG_UPROBES is not defined */
 static inline int register_uprobe(struct inode *inode, loff_t offset,
 				struct uprobe_consumer *consumer)
@@ -101,5 +126,15 @@ static inline int mmap_uprobe(struct vm_area_struct *vma)
 static inline void munmap_uprobe(struct vm_area_struct *vma)
 {
 }
+static inline void uprobe_notify_resume(struct pt_regs *regs)
+{
+}
+static inline unsigned long get_uprobe_bkpt_addr(struct pt_regs *regs)
+{
+	return 0;
+}
+static inline void free_uprobe_utask(struct task_struct *tsk)
+{
+}
 #endif /* CONFIG_UPROBES */
 #endif	/* _LINUX_UPROBES_H */
diff --git a/kernel/fork.c b/kernel/fork.c
index 7cc0b51..5914bc1 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -195,6 +195,7 @@ void __put_task_struct(struct task_struct *tsk)
 	delayacct_tsk_free(tsk);
 	put_signal_struct(tsk->signal);
 
+	free_uprobe_utask(tsk);
 	if (!profile_handoff_task(tsk))
 		free_task(tsk);
 }
@@ -1285,6 +1286,9 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	INIT_LIST_HEAD(&p->pi_state_list);
 	p->pi_state_cache = NULL;
 #endif
+#ifdef CONFIG_UPROBES
+	p->utask = NULL;
+#endif
 	/*
 	 * sigaltstack should be cleared when sharing the same VM
 	 */
diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index 9adc3aa..8b6654e 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -29,6 +29,7 @@
 #include <linux/rmap.h>		/* anon_vma_prepare */
 #include <linux/mmu_notifier.h>	/* set_pte_at_notify */
 #include <linux/swap.h>		/* try_to_free_swap */
+#include <linux/ptrace.h>	/* user_enable_single_step */
 #include <linux/uprobes.h>
 
 static struct rb_root uprobes_tree = RB_ROOT;
@@ -473,6 +474,21 @@ static struct uprobe *alloc_uprobe(struct inode *inode, loff_t offset)
 	return uprobe;
 }
 
+static void handler_chain(struct uprobe *uprobe, struct pt_regs *regs)
+{
+	struct uprobe_consumer *consumer;
+
+	down_read(&uprobe->consumer_rwsem);
+	consumer = uprobe->consumers;
+	for (consumer = uprobe->consumers; consumer;
+			consumer = consumer->next) {
+		if (!consumer->filter ||
+				consumer->filter(consumer, current))
+			consumer->handler(consumer, regs);
+	}
+	up_read(&uprobe->consumer_rwsem);
+}
+
 /* Returns the previous consumer */
 static struct uprobe_consumer *add_consumer(struct uprobe *uprobe,
 				struct uprobe_consumer *consumer)
@@ -640,10 +656,22 @@ static void remove_breakpoint(struct mm_struct *mm, struct uprobe *uprobe,
 	put_task_struct(tsk);
 }
 
+/*
+ * There could be threads that have hit the breakpoint and are entering the
+ * notifier code and trying to acquire the uprobes_treelock. The thread
+ * calling delete_uprobe() that is removing the uprobe from the rb_tree can
+ * race with these threads and might acquire the uprobes_treelock compared
+ * to some of the breakpoint hit threads. In such a case, the breakpoint hit
+ * threads will not find the uprobe. Finding if a "trap" instruction was
+ * present at the interrupting address is racy. Hence provide some extra
+ * time (by way of synchronize_sched() for breakpoint hit threads to acquire
+ * the uprobes_treelock before the uprobe is removed from the rbtree.
+ */
 static void delete_uprobe(struct uprobe *uprobe)
 {
 	unsigned long flags;
 
+	synchronize_sched();
 	spin_lock_irqsave(&uprobes_treelock, flags);
 	rb_erase(&uprobe->rb_node, &uprobes_tree);
 	spin_unlock_irqrestore(&uprobes_treelock, flags);
@@ -1004,3 +1032,180 @@ void munmap_uprobe(struct vm_area_struct *vma)
 	iput(inode);
 	return;
 }
+
+/**
+ * get_uprobe_bkpt_addr - compute address of bkpt given post-bkpt regs
+ * @regs: Reflects the saved state of the task after it has hit a breakpoint
+ * instruction.
+ * Return the address of the breakpoint instruction.
+ */
+unsigned long __weak get_uprobe_bkpt_addr(struct pt_regs *regs)
+{
+	return instruction_pointer(regs) - UPROBES_BKPT_INSN_SIZE;
+}
+
+/*
+ * Called with no locks held.
+ * Called in context of a exiting or a exec-ing thread.
+ */
+void free_uprobe_utask(struct task_struct *tsk)
+{
+	struct uprobe_task *utask = tsk->utask;
+
+	if (!utask)
+		return;
+
+	if (utask->active_uprobe)
+		put_uprobe(utask->active_uprobe);
+
+	kfree(utask);
+	tsk->utask = NULL;
+}
+
+/*
+ * Allocate a uprobe_task object for the task.
+ * Called when the thread hits a breakpoint for the first time.
+ *
+ * Returns:
+ * - pointer to new uprobe_task on success
+ * - negative errno otherwise
+ */
+static struct uprobe_task *add_utask(void)
+{
+	struct uprobe_task *utask;
+
+	utask = kzalloc(sizeof *utask, GFP_KERNEL);
+	if (unlikely(utask == NULL))
+		return ERR_PTR(-ENOMEM);
+
+	utask->active_uprobe = NULL;
+	current->utask = utask;
+	return utask;
+}
+
+/* Prepare to single-step probed instruction out of line. */
+static int pre_ssout(struct uprobe *uprobe, struct pt_regs *regs,
+				unsigned long vaddr)
+{
+	/* TODO: Yet to be implemented */
+	return -EFAULT;
+}
+
+/*
+ * Verify from Instruction Pointer if singlestep has indeed occurred.
+ * If Singlestep has occurred, then do post singlestep fix-ups.
+ */
+static bool sstep_complete(struct uprobe *uprobe, struct pt_regs *regs)
+{
+	/* TODO: Yet to be implemented */
+	return false;
+}
+
+/*
+ * uprobe_notify_resume gets called in task context just before returning
+ * to userspace.
+ *
+ *  If its the first time the probepoint is hit, slot gets allocated here.
+ *  If its the first time the thread hit a breakpoint, utask gets
+ *  allocated here.
+ */
+void uprobe_notify_resume(struct pt_regs *regs)
+{
+	struct vm_area_struct *vma;
+	struct uprobe_task *utask;
+	struct mm_struct *mm;
+	struct uprobe *u = NULL;
+	unsigned long probept;
+
+	utask = current->utask;
+	mm = current->mm;
+	if (!utask || utask->state == UTASK_BP_HIT) {
+		probept = get_uprobe_bkpt_addr(regs);
+		down_read(&mm->mmap_sem);
+		vma = find_vma(mm, probept);
+		if (vma && valid_vma(vma))
+			u = find_uprobe(vma->vm_file->f_mapping->host,
+					probept - vma->vm_start +
+					(vma->vm_pgoff << PAGE_SHIFT));
+		up_read(&mm->mmap_sem);
+		if (!u)
+			/* No matching uprobe; signal SIGTRAP. */
+			goto cleanup_ret;
+		if (!utask) {
+			utask = add_utask();
+			/* Cannot Allocate; re-execute the instruction. */
+			if (!utask)
+				goto cleanup_ret;
+		}
+		/* TODO Start queueing signals. */
+		utask->active_uprobe = u;
+		handler_chain(u, regs);
+		utask->state = UTASK_SSTEP;
+		if (!pre_ssout(u, regs, probept))
+			user_enable_single_step(current);
+		else
+			/* Cannot Singlestep; re-execute the instruction. */
+			goto cleanup_ret;
+	} else if (utask->state == UTASK_SSTEP) {
+		u = utask->active_uprobe;
+		if (sstep_complete(u, regs)) {
+			put_uprobe(u);
+			utask->active_uprobe = NULL;
+			utask->state = UTASK_RUNNING;
+			user_disable_single_step(current);
+
+			/* TODO Stop queueing signals. */
+		}
+	}
+	return;
+
+cleanup_ret:
+	if (utask) {
+		utask->active_uprobe = NULL;
+		utask->state = UTASK_RUNNING;
+	}
+	if (u) {
+		put_uprobe(u);
+		set_instruction_pointer(regs, probept);
+	} else {
+		/*TODO Return SIGTRAP signal */
+	}
+}
+
+/*
+ * uprobe_bkpt_notifier gets called from interrupt context
+ * it gets a reference to the ppt and sets TIF_UPROBE flag,
+ */
+int uprobe_bkpt_notifier(struct pt_regs *regs)
+{
+	struct uprobe_task *utask;
+
+	if (!current->mm || !atomic_read(&current->mm->mm_uprobes_count))
+		/* task is currently not uprobed */
+		return 0;
+
+	utask = current->utask;
+	if (utask)
+		utask->state = UTASK_BP_HIT;
+	set_thread_flag(TIF_UPROBE);
+	return 1;
+}
+
+/*
+ * uprobe_post_notifier gets called in interrupt context.
+ * It completes the single step operation.
+ */
+int uprobe_post_notifier(struct pt_regs *regs)
+{
+	struct uprobe *uprobe;
+	struct uprobe_task *utask;
+
+	if (!current->mm || !current->utask || !current->utask->active_uprobe)
+		/* task is currently not uprobed */
+		return 0;
+
+	utask = current->utask;
+	uprobe = utask->active_uprobe;
+	set_thread_flag(TIF_UPROBE);
+	return 1;
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
