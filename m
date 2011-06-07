Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id F3F4A6B00EB
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 09:07:43 -0400 (EDT)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp02.in.ibm.com (8.14.4/8.13.1) with ESMTP id p57D7bI7005132
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 18:37:37 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p57D7bn7954608
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 18:37:37 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p57D7aPh026189
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 23:07:37 +1000
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Tue, 07 Jun 2011 18:30:51 +0530
Message-Id: <20110607130051.28590.68088.sendpatchset@localhost6.localdomain6>
In-Reply-To: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
Subject: [PATCH v4 3.0-rc2-tip 13/22] 13: uprobes: Handing int3 and singlestep exception.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>


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
 kernel/uprobes.c        |  143 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 147 insertions(+), 0 deletions(-)

diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index 838fbaa..8581723 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -162,6 +162,9 @@ extern int mmap_uprobe(struct vm_area_struct *vma);
 extern void dup_mmap_uprobe(struct mm_struct *old_mm, struct mm_struct *mm);
 extern void free_uprobes_xol_area(struct mm_struct *mm);
 extern unsigned long __weak get_uprobe_bkpt_addr(struct pt_regs *regs);
+extern int uprobe_post_notifier(struct pt_regs *regs);
+extern int uprobe_bkpt_notifier(struct pt_regs *regs);
+extern void uprobe_notify_resume(struct pt_regs *regs);
 #else /* CONFIG_UPROBES is not defined */
 static inline int register_uprobe(struct inode *inode, loff_t offset,
 				struct uprobe_consumer *consumer)
@@ -182,6 +185,7 @@ static inline int mmap_uprobe(struct vm_area_struct *vma)
 }
 static inline void free_uprobe_utask(struct task_struct *tsk) {}
 static inline void free_uprobes_xol_area(struct mm_struct *mm) {}
+static inline void uprobe_notify_resume(struct pt_regs *regs) {}
 static inline unsigned long get_uprobe_bkpt_addr(struct pt_regs *regs)
 {
 	return 0;
diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index fa9e9ba..1e88d64 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -1313,3 +1313,146 @@ static struct uprobe_task *add_utask(void)
 	current->utask = utask;
 	return utask;
 }
+
+/* Prepare to single-step probed instruction out of line. */
+static int pre_ssout(struct uprobe *uprobe, struct pt_regs *regs,
+				unsigned long vaddr)
+{
+	if (xol_get_insn_slot(uprobe, vaddr) && !pre_xol(uprobe, regs)) {
+		set_instruction_pointer(regs, current->utask->xol_vaddr);
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
+			goto cleanup_ret;
+		if (!utask) {
+			utask = add_utask();
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
+			goto cleanup_ret;
+	} else if (utask->state == UTASK_SSTEP) {
+		u = utask->active_uprobe;
+		if (sstep_complete(u, regs)) {
+			put_uprobe(u);
+			utask->active_uprobe = NULL;
+			utask->state = UTASK_RUNNING;
+			user_disable_single_step(current);
+			xol_free_insn_slot(current);
+
+			/* TODO Stop queueing signals. */
+		}
+	}
+	return;
+
+cleanup_ret:
+	if (u) {
+		down_read(&mm->mmap_sem);
+		if (!set_orig_insn(current, u, probept, true))
+			atomic_dec(&mm->uprobes_count);
+		up_read(&mm->mmap_sem);
+		put_uprobe(u);
+	} else {
+	/*TODO Return SIGTRAP signal */
+	}
+	if (utask) {
+		utask->active_uprobe = NULL;
+		utask->state = UTASK_RUNNING;
+	}
+	set_instruction_pointer(regs, probept);
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
+	set_thread_flag(TIF_UPROBE);
+	return 1;
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
