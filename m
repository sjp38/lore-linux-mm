Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 983816B0083
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 09:06:51 -0400 (EDT)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp02.au.ibm.com (8.14.4/8.13.1) with ESMTP id p57D0tdD001483
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 23:00:55 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p57D5vah237724
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 23:05:57 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p57D6kjG028481
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 23:06:47 +1000
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Tue, 07 Jun 2011 18:29:56 +0530
Message-Id: <20110607125956.28590.17518.sendpatchset@localhost6.localdomain6>
In-Reply-To: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
Subject: [PATCH v4 3.0-rc2-tip 9/22]  9: uprobes: task specific information.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>


Uprobes needs to maintain some task specific information include if a
task is currently uprobed, the currently handing uprobe, any arch
specific information (for example to handle rip relative instructions),
the per-task slot where the original instruction is copied to before
single-stepping.

Provides routines to create/manage and free the task specific
information.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 include/linux/sched.h   |    9 ++++++---
 include/linux/uprobes.h |   25 +++++++++++++++++++++++++
 kernel/fork.c           |    4 ++++
 kernel/uprobes.c        |   38 ++++++++++++++++++++++++++++++++++++++
 4 files changed, 73 insertions(+), 3 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index a837b20..9af9c99 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1304,9 +1304,9 @@ struct task_struct {
 	unsigned long stack_canary;
 #endif
 
-	/* 
+	/*
 	 * pointers to (original) parent process, youngest child, younger sibling,
-	 * older sibling, respectively.  (p->father can be replaced with 
+	 * older sibling, respectively.  (p->father can be replaced with
 	 * p->real_parent->pid)
 	 */
 	struct task_struct *real_parent; /* real parent process */
@@ -1561,6 +1561,9 @@ struct task_struct {
 #ifdef CONFIG_HAVE_HW_BREAKPOINT
 	atomic_t ptrace_bp_refcnt;
 #endif
+#ifdef CONFIG_UPROBES
+	struct uprobe_task *utask;
+#endif
 };
 
 /* Future-safe accessor for struct task_struct's cpus_allowed. */
@@ -2127,7 +2130,7 @@ static inline int dequeue_signal_lock(struct task_struct *tsk, sigset_t *mask, s
 	spin_unlock_irqrestore(&tsk->sighand->siglock, flags);
 
 	return ret;
-}	
+}
 
 extern void block_all_signals(int (*notifier)(void *priv), void *priv,
 			      sigset_t *mask);
diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index fc2f9d2..821e000 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -26,12 +26,14 @@
 #include <linux/rbtree.h>
 #ifdef CONFIG_ARCH_SUPPORTS_UPROBES
 #include <asm/uprobes.h>
+struct uprobe_task_arch_info;	/* arch specific task info */
 #else
 /*
  * ARCH_SUPPORTS_UPROBES is not defined.
  */
 typedef u8 uprobe_opcode_t;
 struct uprobe_arch_info	{};		/* arch specific info*/
+struct uprobe_task_arch_info {};	/* arch specific task info */
 #endif /* CONFIG_ARCH_SUPPORTS_UPROBES */
 
 /* Post-execution fixups.  Some architectures may define others. */
@@ -77,6 +79,27 @@ struct uprobe {
 	int			copy;
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
+	struct uprobe_task_arch_info tskinfo;
+
+	struct uprobe *active_uprobe;
+};
+
 /*
  * Most architectures can use the default versions of @read_opcode(),
  * @set_bkpt(), @set_orig_insn(), and @is_bkpt_insn();
@@ -111,6 +134,7 @@ extern int register_uprobe(struct inode *inode, loff_t offset,
 				struct uprobe_consumer *consumer);
 extern void unregister_uprobe(struct inode *inode, loff_t offset,
 				struct uprobe_consumer *consumer);
+extern void free_uprobe_utask(struct task_struct *tsk);
 
 struct vm_area_struct;
 extern int mmap_uprobe(struct vm_area_struct *vma);
@@ -133,5 +157,6 @@ static inline int mmap_uprobe(struct vm_area_struct *vma)
 {
 	return 0;
 }
+static inline void free_uprobe_utask(struct task_struct *tsk) {}
 #endif /* CONFIG_UPROBES */
 #endif	/* _LINUX_UPROBES_H */
diff --git a/kernel/fork.c b/kernel/fork.c
index f6c7cb1..bf5999b 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -196,6 +196,7 @@ void __put_task_struct(struct task_struct *tsk)
 	delayacct_tsk_free(tsk);
 	put_signal_struct(tsk->signal);
 
+	free_uprobe_utask(tsk);
 	if (!profile_handoff_task(tsk))
 		free_task(tsk);
 }
@@ -1268,6 +1269,9 @@ static struct task_struct *copy_process(unsigned long clone_flags,
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
index 93a53c0..2bb2bd7 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -1022,3 +1022,41 @@ mmap_out:
 	down_write(&mm->mmap_sem);
 	return ret;
 }
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
