Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D27126B00AD
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 06:38:41 -0500 (EST)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 18 Nov 2011 17:08:37 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAIBcWKW3043482
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 17:08:32 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAIBcVIm012097
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 22:38:32 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 18 Nov 2011 16:42:29 +0530
Message-Id: <20111118111229.10512.51316.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v7 3.2-rc2 29/30] uprobes: Introduce uprobe flags
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>


While registering a probe, there is a timelag between the time the register
request is given all probes are inserted in different processes. If the probe
register fails after inserting  a probe in couple of processes; the installed
probes are reverted. However the probes could have hit and triggered handler
before the probes are reverted.

Avoids running the handler until the register is complete or as soon as the
last unregister kicks in.

Also this patch
- enables skipping singlestep where possible.
- uses a flag to denote if a copy of instruction is made.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 include/linux/uprobes.h |   11 ++++++++++-
 kernel/uprobes.c        |   32 ++++++++++++++++++++++++++------
 2 files changed, 36 insertions(+), 7 deletions(-)

diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index 6a84332..20bdd0a 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -46,6 +46,14 @@ struct uprobe_task_arch_info {};	/* arch specific task info */
 /* Adjust the return address of a call insn */
 #define UPROBES_FIX_CALL	0x2
 
+/* flags that denote/change uprobes behaviour */
+/* Have a copy of original instruction */
+#define UPROBES_COPY_INSN	0x1
+/* Dont run handlers when first register/ last unregister in progress*/
+#define UPROBES_RUN_HANDLER	0x2
+/* Can skip singlestep */
+#define UPROBES_SKIP_SSTEP	0x4
+
 struct uprobe_consumer {
 	int (*handler)(struct uprobe_consumer *self, struct pt_regs *regs);
 	/*
@@ -66,7 +74,7 @@ struct uprobe {
 	struct uprobe_consumer	*consumers;
 	struct inode		*inode;		/* Also hold a ref to inode */
 	loff_t			offset;
-	int			copy;
+	int			flags;
 	u16			fixups;
 	u8			insn[MAX_UINSN_BYTES];
 };
@@ -131,6 +139,7 @@ extern int uprobe_post_notifier(struct pt_regs *regs);
 extern int uprobe_bkpt_notifier(struct pt_regs *regs);
 extern void uprobe_notify_resume(struct pt_regs *regs);
 extern bool uprobe_deny_signal(void);
+extern bool __weak can_skip_xol(struct pt_regs *regs, struct uprobe *u);
 #else /* CONFIG_UPROBES is not defined */
 static inline int register_uprobe(struct inode *inode, loff_t offset,
 				struct uprobe_consumer *consumer)
diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index f8c0f7c..2493191 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -436,6 +436,9 @@ static struct uprobe *insert_uprobe(struct uprobe *uprobe)
 	spin_lock_irqsave(&uprobes_treelock, flags);
 	u = __insert_uprobe(uprobe);
 	spin_unlock_irqrestore(&uprobes_treelock, flags);
+
+	/* For now assume that the instruction need not be single-stepped */
+	uprobe->flags |= UPROBES_SKIP_SSTEP;
 	return u;
 }
 
@@ -475,6 +478,9 @@ static void handler_chain(struct uprobe *uprobe, struct pt_regs *regs)
 {
 	struct uprobe_consumer *consumer;
 
+	if (!(uprobe->flags & UPROBES_RUN_HANDLER))
+		return;
+
 	down_read(&uprobe->consumer_rwsem);
 	consumer = uprobe->consumers;
 	for (consumer = uprobe->consumers; consumer;
@@ -594,7 +600,7 @@ static int install_breakpoint(struct mm_struct *mm, struct uprobe *uprobe,
 		return -EEXIST;
 
 	addr = (unsigned long)vaddr;
-	if (!uprobe->copy) {
+	if (!(uprobe->flags & UPROBES_COPY_INSN)) {
 		ret = copy_insn(uprobe, vma, addr);
 		if (ret)
 			return ret;
@@ -606,7 +612,7 @@ static int install_breakpoint(struct mm_struct *mm, struct uprobe *uprobe,
 		if (ret)
 			return ret;
 
-		uprobe->copy = 1;
+		uprobe->flags |= UPROBES_COPY_INSN;
 	}
 	ret = set_bkpt(mm, uprobe, addr);
 	if (!ret)
@@ -850,7 +856,8 @@ int register_uprobe(struct inode *inode, loff_t offset,
 		if (ret) {
 			uprobe->consumers = NULL;
 			__unregister_uprobe(inode, offset, uprobe);
-		}
+		} else
+			uprobe->flags |= UPROBES_RUN_HANDLER;
 	}
 
 	mutex_unlock(uprobes_hash(inode));
@@ -886,9 +893,10 @@ void unregister_uprobe(struct inode *inode, loff_t offset,
 		goto unreg_out;
 	}
 
-	if (!uprobe->consumers)
+	if (!uprobe->consumers) {
 		__unregister_uprobe(inode, offset, uprobe);
-
+		uprobe->flags &= ~UPROBES_RUN_HANDLER;
+	}
 	mutex_unlock(uprobes_hash(inode));
 
 unreg_out:
@@ -1337,6 +1345,12 @@ bool uprobe_deny_signal(void)
 	return true;
 }
 
+bool __weak can_skip_xol(struct pt_regs *regs, struct uprobe *u)
+{
+	u->flags &= ~UPROBES_SKIP_SSTEP;
+	return false;
+}
+
 /*
  * uprobe_notify_resume gets called in task context just before returning
  * to userspace.
@@ -1378,6 +1392,10 @@ void uprobe_notify_resume(struct pt_regs *regs)
 		}
 		utask->active_uprobe = u;
 		handler_chain(u, regs);
+
+		if (u->flags & UPROBES_SKIP_SSTEP && can_skip_xol(regs, u))
+			goto cleanup_ret;
+
 		utask->state = UTASK_SSTEP;
 		if (!pre_ssout(u, regs, probept))
 			user_enable_single_step(current);
@@ -1411,8 +1429,10 @@ void uprobe_notify_resume(struct pt_regs *regs)
 		utask->state = UTASK_RUNNING;
 	}
 	if (u) {
+		if (!(u->flags & UPROBES_SKIP_SSTEP))
+			set_instruction_pointer(regs, probept);
+
 		put_uprobe(u);
-		set_instruction_pointer(regs, probept);
 	} else
 		send_sig(SIGTRAP, current, 0);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
