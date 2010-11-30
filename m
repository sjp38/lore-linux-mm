From: Christoph Lameter <cl@linux.com>
Subject: [thisops uV3 16/18] kprobes: Use this_cpu_ops
Date: Tue, 30 Nov 2010 13:07:23 -0600
Message-ID: <20101130190850.575279761@linux.com>
References: <20101130190707.457099608@linux.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PNVZr-0000b9-15
	for glkm-linux-mm-2@m.gmane.org; Tue, 30 Nov 2010 20:09:23 +0100
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 89BE06B0098
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 14:08:53 -0500 (EST)
Content-Disposition: inline; filename=this_ops_kprobes
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Jason Baron <jbaron@redhat.com>, Namhyung Kim <namhyung@gmail.com>, linux-kernel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Use this_cpu ops in various places to optimize per cpu data access.

Cc: Jason Baron <jbaron@redhat.com>
Cc: Namhyung Kim <namhyung@gmail.com>
Signed-off-by: Christoph Lameter <cl@linux.com>

---
 arch/x86/kernel/kprobes.c |   14 +++++++-------
 include/linux/kprobes.h   |    4 ++--
 kernel/kprobes.c          |    8 ++++----
 3 files changed, 13 insertions(+), 13 deletions(-)

Index: linux-2.6/arch/x86/kernel/kprobes.c
===================================================================
--- linux-2.6.orig/arch/x86/kernel/kprobes.c	2010-11-30 12:31:51.000000000 -0600
+++ linux-2.6/arch/x86/kernel/kprobes.c	2010-11-30 12:32:15.000000000 -0600
@@ -403,7 +403,7 @@ static void __kprobes save_previous_kpro
 
 static void __kprobes restore_previous_kprobe(struct kprobe_ctlblk *kcb)
 {
-	__get_cpu_var(current_kprobe) = kcb->prev_kprobe.kp;
+	__this_cpu_write(current_kprobe, kcb->prev_kprobe.kp);
 	kcb->kprobe_status = kcb->prev_kprobe.status;
 	kcb->kprobe_old_flags = kcb->prev_kprobe.old_flags;
 	kcb->kprobe_saved_flags = kcb->prev_kprobe.saved_flags;
@@ -412,7 +412,7 @@ static void __kprobes restore_previous_k
 static void __kprobes set_current_kprobe(struct kprobe *p, struct pt_regs *regs,
 				struct kprobe_ctlblk *kcb)
 {
-	__get_cpu_var(current_kprobe) = p;
+	__this_cpu_write(current_kprobe, p);
 	kcb->kprobe_saved_flags = kcb->kprobe_old_flags
 		= (regs->flags & (X86_EFLAGS_TF | X86_EFLAGS_IF));
 	if (is_IF_modifier(p->ainsn.insn))
@@ -586,7 +586,7 @@ static int __kprobes kprobe_handler(stru
 		preempt_enable_no_resched();
 		return 1;
 	} else if (kprobe_running()) {
-		p = __get_cpu_var(current_kprobe);
+		p = __this_cpu_read(current_kprobe);
 		if (p->break_handler && p->break_handler(p, regs)) {
 			setup_singlestep(p, regs, kcb, 0);
 			return 1;
@@ -759,11 +759,11 @@ static __used __kprobes void *trampoline
 
 		orig_ret_address = (unsigned long)ri->ret_addr;
 		if (ri->rp && ri->rp->handler) {
-			__get_cpu_var(current_kprobe) = &ri->rp->kp;
+			__this_cpu_write(current_kprobe, &ri->rp->kp);
 			get_kprobe_ctlblk()->kprobe_status = KPROBE_HIT_ACTIVE;
 			ri->ret_addr = correct_ret_addr;
 			ri->rp->handler(ri, regs);
-			__get_cpu_var(current_kprobe) = NULL;
+			__this_cpu_write(current_kprobe, NULL);
 		}
 
 		recycle_rp_inst(ri, &empty_rp);
@@ -1198,10 +1198,10 @@ static void __kprobes optimized_callback
 		regs->ip = (unsigned long)op->kp.addr + INT3_SIZE;
 		regs->orig_ax = ~0UL;
 
-		__get_cpu_var(current_kprobe) = &op->kp;
+		__this_cpu_write(current_kprobe, &op->kp);
 		kcb->kprobe_status = KPROBE_HIT_ACTIVE;
 		opt_pre_handler(&op->kp, regs);
-		__get_cpu_var(current_kprobe) = NULL;
+		__this_cpu_write(current_kprobe, NULL);
 	}
 	preempt_enable_no_resched();
 }
Index: linux-2.6/include/linux/kprobes.h
===================================================================
--- linux-2.6.orig/include/linux/kprobes.h	2010-11-30 12:31:51.000000000 -0600
+++ linux-2.6/include/linux/kprobes.h	2010-11-30 12:32:15.000000000 -0600
@@ -303,12 +303,12 @@ struct hlist_head * kretprobe_inst_table
 /* kprobe_running() will just return the current_kprobe on this CPU */
 static inline struct kprobe *kprobe_running(void)
 {
-	return (__get_cpu_var(current_kprobe));
+	return (__this_cpu_read(current_kprobe));
 }
 
 static inline void reset_current_kprobe(void)
 {
-	__get_cpu_var(current_kprobe) = NULL;
+	__this_cpu_write(current_kprobe, NULL);
 }
 
 static inline struct kprobe_ctlblk *get_kprobe_ctlblk(void)
Index: linux-2.6/kernel/kprobes.c
===================================================================
--- linux-2.6.orig/kernel/kprobes.c	2010-11-30 12:31:51.000000000 -0600
+++ linux-2.6/kernel/kprobes.c	2010-11-30 12:32:15.000000000 -0600
@@ -317,12 +317,12 @@ void __kprobes free_optinsn_slot(kprobe_
 /* We have preemption disabled.. so it is safe to use __ versions */
 static inline void set_kprobe_instance(struct kprobe *kp)
 {
-	__get_cpu_var(kprobe_instance) = kp;
+	__this_cpu_write(kprobe_instance, kp);
 }
 
 static inline void reset_kprobe_instance(void)
 {
-	__get_cpu_var(kprobe_instance) = NULL;
+	__this_cpu_write(kprobe_instance, NULL);
 }
 
 /*
@@ -775,7 +775,7 @@ static void __kprobes aggr_post_handler(
 static int __kprobes aggr_fault_handler(struct kprobe *p, struct pt_regs *regs,
 					int trapnr)
 {
-	struct kprobe *cur = __get_cpu_var(kprobe_instance);
+	struct kprobe *cur = __this_cpu_read(kprobe_instance);
 
 	/*
 	 * if we faulted "during" the execution of a user specified
@@ -790,7 +790,7 @@ static int __kprobes aggr_fault_handler(
 
 static int __kprobes aggr_break_handler(struct kprobe *p, struct pt_regs *regs)
 {
-	struct kprobe *cur = __get_cpu_var(kprobe_instance);
+	struct kprobe *cur = __this_cpu_read(kprobe_instance);
 	int ret = 0;
 
 	if (cur && cur->break_handler) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
