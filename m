Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 9B65A6B0087
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 06:35:24 -0500 (EST)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 18 Nov 2011 17:05:14 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAIBZ6c94521996
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 17:05:06 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAIBZ4ax020162
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 22:35:06 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 18 Nov 2011 16:39:03 +0530
Message-Id: <20111118110903.10512.88532.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v7 3.2-rc2 12/30] uprobes: Handle breakpoint and Singlestep
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>


Provides routines to create/manage and free the task specific
information. Uses bulkref interface.
Adds a hook in uprobe_notify_resume to handle breakpoint and singlestep
exception.

Uprobes needs to maintain some task specific information including if a
task has hit a probepoint, uprobe corresponding to the probehit,
the slot where the original instruction is copied to before
single-stepping.

Signed-off-by: Jim Keniston <jkenisto@us.ibm.com>
Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---

Changelog (since v5)
- Use bulkref instead of synchronize_sched
- Introduce per task bulkref_id to store the bulkref_id
- Modified comments.

 include/linux/sched.h   |    4 +
 include/linux/uprobes.h |   33 +++++++
 kernel/fork.c           |    6 +
 kernel/uprobes.c        |  208 +++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 251 insertions(+), 0 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 68daf4f..bb274de 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1573,6 +1573,10 @@ struct task_struct {
 #ifdef CONFIG_HAVE_HW_BREAKPOINT
 	atomic_t ptrace_bp_refcnt;
 #endif
+#ifdef CONFIG_UPROBES
+	struct uprobe_task *utask;
+	int uprobes_bulkref_id;
+#endif
 };
 
 /* Future-safe accessor for struct task_struct's cpus_allowed. */
diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index bc1f190..0882223 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -70,6 +70,24 @@ struct uprobe {
 	u8			insn[MAX_UINSN_BYTES];
 };
 
+enum uprobe_task_state {
+	UTASK_RUNNING,
+	UTASK_BP_HIT,
+	UTASK_SSTEP
+};
+
+/*
+ * uprobe_task: Metadata of a task while it singlesteps.
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
 extern int __weak set_bkpt(struct mm_struct *mm, struct uprobe *uprobe,
 							unsigned long vaddr);
@@ -80,8 +98,13 @@ extern int register_uprobe(struct inode *inode, loff_t offset,
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
@@ -99,5 +122,15 @@ static inline int mmap_uprobe(struct vm_area_struct *vma)
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
index c8c287a..a03f436 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -686,6 +686,8 @@ void mm_release(struct task_struct *tsk, struct mm_struct *mm)
 		exit_pi_state_list(tsk);
 #endif
 
+	free_uprobe_utask(tsk);
+
 	/* Get rid of any cached register state */
 	deactivate_mm(tsk, mm);
 
@@ -1284,6 +1286,10 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	INIT_LIST_HEAD(&p->pi_state_list);
 	p->pi_state_cache = NULL;
 #endif
+#ifdef CONFIG_UPROBES
+	p->utask = NULL;
+	p->uprobes_bulkref_id = -1;
+#endif
 	/*
 	 * sigaltstack should be cleared when sharing the same VM
 	 */
diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index 1acf020..9789b65 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -29,8 +29,10 @@
 #include <linux/rmap.h>		/* anon_vma_prepare */
 #include <linux/mmu_notifier.h>	/* set_pte_at_notify */
 #include <linux/swap.h>		/* try_to_free_swap */
+#include <linux/ptrace.h>	/* user_enable_single_step */
 #include <linux/uprobes.h>
 
+static bulkref_t uprobes_srcu;
 static struct rb_root uprobes_tree = RB_ROOT;
 static DEFINE_SPINLOCK(uprobes_treelock);	/* serialize rbtree access */
 
@@ -465,6 +467,21 @@ static struct uprobe *alloc_uprobe(struct inode *inode, loff_t offset)
 	return uprobe;
 }
 
+static void handler_chain(struct uprobe *uprobe, struct pt_regs *regs)
+{
+	struct uprobe_consumer *consumer;
+
+	down_read(&uprobe->consumer_rwsem);
+	consumer = uprobe->consumers;
+	for (consumer = uprobe->consumers; consumer;
+					consumer = consumer->next) {
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
@@ -601,10 +618,21 @@ static void remove_breakpoint(struct mm_struct *mm, struct uprobe *uprobe,
 		atomic_dec(&mm->mm_uprobes_count);
 }
 
+/*
+ * There could be threads that have hit the breakpoint and are entering the
+ * notifier code and trying to acquire the uprobes_treelock. The thread
+ * calling delete_uprobe() that is removing the uprobe from the rb_tree can
+ * race with these threads and might acquire the uprobes_treelock compared
+ * to some of the breakpoint hit threads. In such a case, the breakpoint hit
+ * threads will not find the uprobe. Hence wait till the current breakpoint
+ * hit threads acquire the uprobes_treelock before the uprobe is removed
+ * from the rbtree.
+ */
 static void delete_uprobe(struct uprobe *uprobe)
 {
 	unsigned long flags;
 
+	bulkref_wait_old(&uprobes_srcu);
 	spin_lock_irqsave(&uprobes_treelock, flags);
 	rb_erase(&uprobe->rb_node, &uprobes_tree);
 	spin_unlock_irqrestore(&uprobes_treelock, flags);
@@ -1022,6 +1050,185 @@ void munmap_uprobe(struct vm_area_struct *vma)
 	return;
 }
 
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
+	if (tsk->uprobes_bulkref_id != -1)
+		bulkref_put(&uprobes_srcu, tsk->uprobes_bulkref_id);
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
+		if (vma && valid_vma(vma, false))
+			u = find_uprobe(vma->vm_file->f_mapping->host,
+					probept - vma->vm_start +
+					(vma->vm_pgoff << PAGE_SHIFT));
+
+		bulkref_put(&uprobes_srcu, current->uprobes_bulkref_id);
+		current->uprobes_bulkref_id = -1;
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
+
+	set_thread_flag(TIF_UPROBE);
+	current->uprobes_bulkref_id = bulkref_get(&uprobes_srcu);
+	return 1;
+}
+
+/*
+ * uprobe_post_notifier gets called in interrupt context.
+ * It completes the single step operation.
+ */
+int uprobe_post_notifier(struct pt_regs *regs)
+{
+	struct uprobe_task *utask = current->utask;
+
+	if (!current->mm || !utask || !utask->active_uprobe)
+		/* task is currently not uprobed */
+		return 0;
+
+	set_thread_flag(TIF_UPROBE);
+	return 1;
+}
+
 static int __init init_uprobes(void)
 {
 	int i;
@@ -1030,6 +1237,7 @@ static int __init init_uprobes(void)
 		mutex_init(&uprobes_mutex[i]);
 		mutex_init(&uprobes_mmap_mutex[i]);
 	}
+	init_bulkref(&uprobes_srcu);
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
