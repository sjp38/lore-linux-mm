Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C3C656B0095
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 14:06:03 -0500 (EST)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Thu, 10 Nov 2011 20:00:05 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAAJ1xXo2060374
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 06:01:59 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAAJ50bB013639
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 06:05:01 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 11 Nov 2011 00:10:01 +0530
Message-Id: <20111110184001.11361.52020.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20111110183725.11361.57827.sendpatchset@srdronam.in.ibm.com>
References: <20111110183725.11361.57827.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v6 3.2-rc1 13/28]   x86: define a x86 specific exception notifier.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>


Uprobes uses notifier mechanism to get in control when an application
encounters a breakpoint or a singlestep exception.

Signed-off-by: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---

Changelog (since v5)
- No more do a i386 specific enable interrupts. (Its now part of another
  patchset posted separately)

 arch/x86/include/asm/uprobes.h |    4 ++++
 arch/x86/kernel/signal.c       |    6 ++++++
 arch/x86/kernel/uprobes.c      |   29 +++++++++++++++++++++++++++++
 3 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/uprobes.h b/arch/x86/include/asm/uprobes.h
index 509c023..19a5949 100644
--- a/arch/x86/include/asm/uprobes.h
+++ b/arch/x86/include/asm/uprobes.h
@@ -23,6 +23,8 @@
  *	Jim Keniston
  */
 
+#include <linux/notifier.h>
+
 typedef u8 uprobe_opcode_t;
 #define MAX_UINSN_BYTES 16
 #define UPROBES_XOL_SLOT_BYTES	128	/* to keep it cache aligned */
@@ -40,4 +42,6 @@ struct uprobe_arch_info {};
 struct uprobe;
 extern int analyze_insn(struct mm_struct *mm, struct uprobe *uprobe);
 extern void set_instruction_pointer(struct pt_regs *regs, unsigned long vaddr);
+extern int uprobe_exception_notify(struct notifier_block *self,
+				       unsigned long val, void *data);
 #endif	/* _ASM_UPROBES_H */
diff --git a/arch/x86/kernel/signal.c b/arch/x86/kernel/signal.c
index 54ddaeb..4fdf470 100644
--- a/arch/x86/kernel/signal.c
+++ b/arch/x86/kernel/signal.c
@@ -20,6 +20,7 @@
 #include <linux/personality.h>
 #include <linux/uaccess.h>
 #include <linux/user-return-notifier.h>
+#include <linux/uprobes.h>
 
 #include <asm/processor.h>
 #include <asm/ucontext.h>
@@ -820,6 +821,11 @@ do_notify_resume(struct pt_regs *regs, void *unused, __u32 thread_info_flags)
 		mce_notify_process();
 #endif /* CONFIG_X86_64 && CONFIG_X86_MCE */
 
+	if (thread_info_flags & _TIF_UPROBE) {
+		clear_thread_flag(TIF_UPROBE);
+		uprobe_notify_resume(regs);
+	}
+
 	/* deal with pending signal delivery */
 	if (thread_info_flags & _TIF_SIGPENDING)
 		do_signal(regs);
diff --git a/arch/x86/kernel/uprobes.c b/arch/x86/kernel/uprobes.c
index 67b926f..2ee5ddc 100644
--- a/arch/x86/kernel/uprobes.c
+++ b/arch/x86/kernel/uprobes.c
@@ -407,3 +407,32 @@ void set_instruction_pointer(struct pt_regs *regs, unsigned long vaddr)
 {
 	regs->ip = vaddr;
 }
+
+/*
+ * Wrapper routine for handling exceptions.
+ */
+int uprobe_exception_notify(struct notifier_block *self,
+				       unsigned long val, void *data)
+{
+	struct die_args *args = data;
+	struct pt_regs *regs = args->regs;
+	int ret = NOTIFY_DONE;
+
+	/* We are only interested in userspace traps */
+	if (regs && !user_mode_vm(regs))
+		return NOTIFY_DONE;
+
+	switch (val) {
+	case DIE_INT3:
+		/* Run your handler here */
+		if (uprobe_bkpt_notifier(regs))
+			ret = NOTIFY_STOP;
+		break;
+	case DIE_DEBUG:
+		if (uprobe_post_notifier(regs))
+			ret = NOTIFY_STOP;
+	default:
+		break;
+	}
+	return ret;
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
