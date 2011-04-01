Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3310E8D0040
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 10:45:28 -0400 (EDT)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp01.in.ibm.com (8.14.4/8.13.1) with ESMTP id p31EjGjv024960
	for <linux-mm@kvack.org>; Fri, 1 Apr 2011 20:15:16 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p31EjGDp4546708
	for <linux-mm@kvack.org>; Fri, 1 Apr 2011 20:15:16 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p31EjDc9006413
	for <linux-mm@kvack.org>; Sat, 2 Apr 2011 01:45:15 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 01 Apr 2011 20:05:37 +0530
Message-Id: <20110401143537.15455.82130.sendpatchset@localhost6.localdomain6>
In-Reply-To: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
References: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
Subject: [PATCH v3 2.6.39-rc1-tip 16/26] 16: x86: uprobes exception notifier for x86.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>


Provides a uprobes exception notifier for x86.  This uprobes_exception
notifier gets called in interrupt context and routes int3 and singlestep
exception when a uprobed process encounters a INT3 or a singlestep exception.

Signed-off-by: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 arch/x86/include/asm/uprobes.h |    3 +++
 arch/x86/kernel/signal.c       |   14 ++++++++++++++
 arch/x86/kernel/uprobes.c      |   29 +++++++++++++++++++++++++++++
 3 files changed, 46 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/uprobes.h b/arch/x86/include/asm/uprobes.h
index 0c9c8b6..bb5c03c 100644
--- a/arch/x86/include/asm/uprobes.h
+++ b/arch/x86/include/asm/uprobes.h
@@ -22,6 +22,7 @@
  *	Srikar Dronamraju
  *	Jim Keniston
  */
+#include <linux/notifier.h>
 
 typedef u8 uprobe_opcode_t;
 #define MAX_UINSN_BYTES 16
@@ -49,4 +50,6 @@ extern int pre_xol(struct uprobe *uprobe, struct pt_regs *regs);
 extern int post_xol(struct uprobe *uprobe, struct pt_regs *regs);
 extern void arch_uprobe_enable_sstep(struct pt_regs *regs);
 extern void arch_uprobe_disable_sstep(struct pt_regs *regs);
+extern int uprobes_exception_notify(struct notifier_block *self,
+				       unsigned long val, void *data);
 #endif	/* _ASM_UPROBES_H */
diff --git a/arch/x86/kernel/signal.c b/arch/x86/kernel/signal.c
index 4fd173c..0b06b94 100644
--- a/arch/x86/kernel/signal.c
+++ b/arch/x86/kernel/signal.c
@@ -20,6 +20,7 @@
 #include <linux/personality.h>
 #include <linux/uaccess.h>
 #include <linux/user-return-notifier.h>
+#include <linux/uprobes.h>
 
 #include <asm/processor.h>
 #include <asm/ucontext.h>
@@ -848,6 +849,19 @@ do_notify_resume(struct pt_regs *regs, void *unused, __u32 thread_info_flags)
 	if (thread_info_flags & _TIF_SIGPENDING)
 		do_signal(regs);
 
+	if (thread_info_flags & _TIF_UPROBE) {
+		clear_thread_flag(TIF_UPROBE);
+#ifdef CONFIG_X86_32
+		/*
+		 * On x86_32, do_notify_resume() gets called with
+		 * interrupts disabled. Hence enable interrupts if they
+		 * are still disabled.
+		 */
+		local_irq_enable();
+#endif
+		uprobe_notify_resume(regs);
+	}
+
 	if (thread_info_flags & _TIF_NOTIFY_RESUME) {
 		clear_thread_flag(TIF_NOTIFY_RESUME);
 		tracehook_notify_resume(regs);
diff --git a/arch/x86/kernel/uprobes.c b/arch/x86/kernel/uprobes.c
index bf98841..e0ce207 100644
--- a/arch/x86/kernel/uprobes.c
+++ b/arch/x86/kernel/uprobes.c
@@ -583,3 +583,32 @@ void arch_uprobe_disable_sstep(struct pt_regs *regs)
 	clear_thread_flag(TIF_FORCED_TF);
 	regs->flags &= ~X86_EFLAGS_TF;
 }
+
+/*
+ * Wrapper routine for handling exceptions.
+ */
+int uprobes_exception_notify(struct notifier_block *self,
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
