Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3EEE18D0040
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 10:44:45 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp06.au.ibm.com (8.14.4/8.13.1) with ESMTP id p31EiEj3027553
	for <linux-mm@kvack.org>; Sat, 2 Apr 2011 01:44:14 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p31EiOZ52527396
	for <linux-mm@kvack.org>; Sat, 2 Apr 2011 01:44:24 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p31EiN4p021088
	for <linux-mm@kvack.org>; Sat, 2 Apr 2011 01:44:24 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 01 Apr 2011 20:04:42 +0530
Message-Id: <20110401143442.15455.10508.sendpatchset@localhost6.localdomain6>
In-Reply-To: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
References: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
Subject: [PATCH v3 2.6.39-rc1-tip 11/26] 11: uprobes: task specific information.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, Andrew Morton <akpm@linux-foundation.org>


Uprobes needs to maintain some task specific information include if a
task is currently uprobed, the currently handing uprobe, any arch
specific information (for example to handle rip relative instructions),
the per-task slot where the original instruction is copied to before
single-stepping.

Provides routines to create/manage and free the task specific
information.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 include/linux/sched.h   |    3 +++
 include/linux/uprobes.h |   25 +++++++++++++++++++++++++
 kernel/fork.c           |    4 ++++
 kernel/uprobes.c        |   38 ++++++++++++++++++++++++++++++++++++++
 4 files changed, 70 insertions(+), 0 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 83bd2e2..d4dcd23 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1534,6 +1534,9 @@ struct task_struct {
 		unsigned long memsw_nr_pages; /* uncharged mem+swap usage */
 	} memcg_batch;
 #endif
+#ifdef CONFIG_UPROBES
+	struct uprobe_task *utask;
+#endif
 };
 
 /* Future-safe accessor for struct task_struct's cpus_allowed. */
diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index 27496c6..8da993c 100644
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
+extern void uprobe_free_utask(struct task_struct *tsk);
 
 struct vm_area_struct;
 extern int uprobe_mmap(struct vm_area_struct *vma);
@@ -133,5 +157,6 @@ static inline int uprobe_mmap(struct vm_area_struct *vma)
 {
 	return 0;
 }
+static inline void uprobe_free_utask(struct task_struct *tsk) {}
 #endif /* CONFIG_UPROBES */
 #endif	/* _LINUX_UPROBES_H */
diff --git a/kernel/fork.c b/kernel/fork.c
index 2f1a16d..e25c29e 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -197,6 +197,7 @@ void __put_task_struct(struct task_struct *tsk)
 	delayacct_tsk_free(tsk);
 	put_signal_struct(tsk->signal);
 
+	uprobe_free_utask(tsk);
 	if (!profile_handoff_task(tsk))
 		free_task(tsk);
 }
@@ -1218,6 +1219,9 @@ static struct task_struct *copy_process(unsigned long clone_flags,
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
index 8cf38d6..f9fb7c2 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -955,3 +955,41 @@ mmap_out:
 	down_write(&mm->mmap_sem);
 	return ret;
 }
+
+/*
+ * Called with no locks held.
+ * Called in context of a exiting or a exec-ing thread.
+ */
+void uprobe_free_utask(struct task_struct *tsk)
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
