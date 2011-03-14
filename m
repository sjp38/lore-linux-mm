Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A69C18D003E
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 09:42:28 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp06.au.ibm.com (8.14.4/8.13.1) with ESMTP id p2EDgJ1a006742
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 00:42:19 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2EDgNLl2551988
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 00:42:23 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2EDgMLX002764
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 00:42:23 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Mon, 14 Mar 2011 19:06:40 +0530
Message-Id: <20110314133640.27435.95105.sendpatchset@localhost6.localdomain6>
In-Reply-To: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
Subject: [PATCH v2 2.6.38-rc8-tip 14/20] 14: uprobes: Handing int3 and singlestep exception.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>


On int3, set the TIF_UPROBE flag and if a task specific info is
available, indicate the task state as breakpoint hit.  Setting the
TIF_UPROBE flag results in uprobe_notify_resume being called.
uprobe_notify_resume walks thro the list of vmas and then matches the
inode and offset corresponding to the instruction pointer to enteries in
rbtree. Once a matcing uprobes is found, run the handlers for all the
consumers that have registered.

On singlestep exception, perform the necessary fixups and allow the
process to continue. The necessary fixups are determined at instruction
analysis time.

TODO: If there is no matching uprobe, signal a trap to the process.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 include/linux/uprobes.h |    4 +
 kernel/uprobes.c        |  146 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 150 insertions(+), 0 deletions(-)

diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index aef55de..b7fd925 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -149,6 +149,9 @@ extern void uprobe_mmap(struct vm_area_struct *vma);
 extern unsigned long uprobes_get_bkpt_addr(struct pt_regs *regs);
 extern void uprobe_dup_mmap(struct mm_struct *old_mm, struct mm_struct *mm);
 extern void uprobes_free_xol_area(struct mm_struct *mm);
+extern int uprobe_post_notifier(struct pt_regs *regs);
+extern int uprobe_bkpt_notifier(struct pt_regs *regs);
+extern void uprobe_notify_resume(struct pt_regs *regs);
 #else /* CONFIG_UPROBES is not defined */
 static inline int register_uprobe(struct inode *inode, loff_t offset,
 				struct uprobe_consumer *consumer)
@@ -166,6 +169,7 @@ static inline void uprobe_dup_mmap(struct mm_struct *old_mm,
 static inline void uprobe_free_utask(struct task_struct *tsk) {}
 static inline void uprobe_mmap(struct vm_area_struct *vma) { }
 static inline void uprobes_free_xol_area(struct mm_struct *mm) {}
+static inline void uprobe_notify_resume(struct pt_regs *regs) {}
 static inline unsigned long uprobes_get_bkpt_addr(struct pt_regs *regs)
 {
 	return 0;
diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index 307f0cd..d8d4574 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -1096,3 +1096,149 @@ static struct uprobe_task *add_utask(void)
 	current->utask = utask;
 	return utask;
 }
+
+/* Prepare to single-step probed instruction out of line. */
+static int pre_ssout(struct uprobe *uprobe, struct pt_regs *regs,
+				unsigned long vaddr)
+{
+	xol_get_insn_slot(uprobe, vaddr);
+	BUG_ON(!current->utask->xol_vaddr);
+	if (!pre_xol(uprobe, regs)) {
+		set_ip(regs, current->utask->xol_vaddr);
+		return 0;
+	}
+	return -EFAULT;
+}
+
+/*
+ * Verify from Instruction Pointer if singlestep has indeed occurred.
+ * If Singlestep has occurred, then do post singlestep fix-ups.
+ */
+static bool sstep_complete(struct uprobe *uprobe, struct pt_regs *regs)
+{
+	unsigned long vaddr = instruction_pointer(regs);
+
+	/*
+	 * If we have executed out of line, Instruction pointer
+	 * cannot be same as virtual address of XOL slot.
+	 */
+	if (vaddr == current->utask->xol_vaddr)
+		return false;
+	post_xol(uprobe, regs);
+	return true;
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
+	if (unlikely(!utask)) {
+		utask = add_utask();
+
+		/* Failed to allocate utask for the current task. */
+		BUG_ON(!utask);
+		utask->state = UTASK_BP_HIT;
+	}
+	if (utask->state == UTASK_BP_HIT) {
+		probept = uprobes_get_bkpt_addr(regs);
+		down_read(&mm->mmap_sem);
+		for (vma = mm->mmap; vma; vma = vma->vm_next) {
+			if (!valid_vma(vma))
+				continue;
+			if (probept < vma->vm_start || probept > vma->vm_end)
+				continue;
+			u = find_uprobe(vma->vm_file->f_mapping->host,
+					probept - vma->vm_start);
+			if (u)
+				break;
+		}
+		up_read(&mm->mmap_sem);
+		/*TODO Return SIGTRAP signal */
+		if (!u) {
+			set_ip(regs, probept);
+			utask->state = UTASK_RUNNING;
+			return;
+		}
+		/* TODO Start queueing signals. */
+		utask->active_uprobe = u;
+		handler_chain(u, regs);
+		utask->state = UTASK_SSTEP;
+		if (!pre_ssout(u, regs, probept))
+			arch_uprobe_enable_sstep(regs);
+	} else if (utask->state == UTASK_SSTEP) {
+		u = utask->active_uprobe;
+		if (sstep_complete(u, regs)) {
+			put_uprobe(u);
+			utask->active_uprobe = NULL;
+			utask->state = UTASK_RUNNING;
+		/* TODO Stop queueing signals. */
+			arch_uprobe_disable_sstep(regs);
+		}
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
+	if (!current->mm || !atomic_read(&current->mm->uprobes_count))
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
+	if (!uprobe)
+		return 0;
+
+	if (uprobes_resume_can_sleep(uprobe)) {
+		set_thread_flag(TIF_UPROBE);
+		return 1;
+	}
+	if (sstep_complete(uprobe, regs)) {
+		put_uprobe(uprobe);
+		utask->active_uprobe = NULL;
+		utask->state = UTASK_RUNNING;
+		/* TODO Stop queueing signals. */
+		arch_uprobe_disable_sstep(regs);
+		return 1;
+	}
+	return 0;
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
