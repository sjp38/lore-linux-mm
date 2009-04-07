Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7B89F5F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 11:10:19 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
References: <20090407509.382219156@firstfloor.org>
In-Reply-To: <20090407509.382219156@firstfloor.org>
Subject: [PATCH] [14/16] x86: MCE: Rename mce_notify_user to mce_notify_irq
Message-Id: <20090407151012.120C51D046E@basil.firstfloor.org>
Date: Tue,  7 Apr 2009 17:10:11 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>


Impact: cleanup

Rename the mce_notify_user function to mce_notify_irq. The next
patch will split the wakeup handling of interrupt context 
and of process context and it's better to give it a clearer
name for this.

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 arch/x86/include/asm/mce.h                |    2 +-
 arch/x86/kernel/cpu/mcheck/mce-inject.c   |    2 +-
 arch/x86/kernel/cpu/mcheck/mce_64.c       |   10 +++++-----
 arch/x86/kernel/cpu/mcheck/mce_intel_64.c |    2 +-
 arch/x86/kernel/signal.c                  |    2 +-
 5 files changed, 9 insertions(+), 9 deletions(-)

Index: linux/arch/x86/kernel/cpu/mcheck/mce_64.c
===================================================================
--- linux.orig/arch/x86/kernel/cpu/mcheck/mce_64.c	2009-04-07 16:39:21.000000000 +0200
+++ linux/arch/x86/kernel/cpu/mcheck/mce_64.c	2009-04-07 16:43:04.000000000 +0200
@@ -303,14 +303,14 @@
 	ack_APIC_irq();
 	exit_idle();
 	irq_enter();
-	mce_notify_user();
+	mce_notify_irq();
 	irq_exit();
 }
 
 static void mce_report_event(struct pt_regs *regs)
 {
 	if (regs->flags & (X86_VM_MASK|X86_EFLAGS_IF)) {
-		mce_notify_user();
+		mce_notify_irq();
 		return;
 	}
 
@@ -904,7 +904,7 @@
 	 * polling interval, otherwise increase the polling interval.
 	 */
 	n = &__get_cpu_var(next_interval);
-	if (mce_notify_user()) {
+	if (mce_notify_irq()) {
 		*n = max(*n/2, HZ/100);
 	} else {
 		*n = min(*n*2, (int)round_jiffies_relative(check_interval*HZ));
@@ -926,7 +926,7 @@
  * Can be called from interrupt context, but not from machine check/NMI
  * context.
  */
-int mce_notify_user(void)
+int mce_notify_irq(void)
 {
 	/* Not more than two messages every minute */
 	static DEFINE_RATELIMIT_STATE(ratelimit, 60*HZ, 2);
@@ -950,7 +950,7 @@
 	}
 	return 0;
 }
-EXPORT_SYMBOL_GPL(mce_notify_user);
+EXPORT_SYMBOL_GPL(mce_notify_irq);
 
 /*
  * Initialize Machine Checks for a CPU.
Index: linux/arch/x86/include/asm/mce.h
===================================================================
--- linux.orig/arch/x86/include/asm/mce.h	2009-04-07 16:39:21.000000000 +0200
+++ linux/arch/x86/include/asm/mce.h	2009-04-07 16:43:04.000000000 +0200
@@ -162,7 +162,7 @@
 };
 extern void machine_check_poll(enum mcp_flags flags, mce_banks_t *b);
 
-extern int mce_notify_user(void);
+extern int mce_notify_irq(void);
 
 #endif /* !CONFIG_X86_32 */
 
Index: linux/arch/x86/kernel/cpu/mcheck/mce-inject.c
===================================================================
--- linux.orig/arch/x86/kernel/cpu/mcheck/mce-inject.c	2009-04-07 16:39:21.000000000 +0200
+++ linux/arch/x86/kernel/cpu/mcheck/mce-inject.c	2009-04-07 16:39:39.000000000 +0200
@@ -65,7 +65,7 @@
 		memset(&b, 0xff, sizeof(mce_banks_t));
 		printk(KERN_INFO "Starting machine check poll CPU %d\n", cpu);
 		machine_check_poll(0, &b);
-		mce_notify_user();
+		mce_notify_irq();
 		printk(KERN_INFO "Finished machine check poll on CPU %d\n",
 		       cpu);
 	}
Index: linux/arch/x86/kernel/signal.c
===================================================================
--- linux.orig/arch/x86/kernel/signal.c	2009-04-07 16:39:21.000000000 +0200
+++ linux/arch/x86/kernel/signal.c	2009-04-07 16:43:04.000000000 +0200
@@ -860,7 +860,7 @@
 #if defined(CONFIG_X86_64) && defined(CONFIG_X86_MCE)
 	/* notify userspace of pending MCEs */
 	if (thread_info_flags & _TIF_MCE_NOTIFY)
-		mce_notify_user();
+		mce_notify_irq();
 #endif /* CONFIG_X86_64 && CONFIG_X86_MCE */
 
 	/* deal with pending signal delivery */
Index: linux/arch/x86/kernel/cpu/mcheck/mce_intel_64.c
===================================================================
--- linux.orig/arch/x86/kernel/cpu/mcheck/mce_intel_64.c	2009-04-07 16:39:21.000000000 +0200
+++ linux/arch/x86/kernel/cpu/mcheck/mce_intel_64.c	2009-04-07 16:39:39.000000000 +0200
@@ -132,7 +132,7 @@
 static void intel_threshold_interrupt(void)
 {
 	machine_check_poll(MCP_TIMESTAMP, &__get_cpu_var(mce_banks_owned));
-	mce_notify_user();
+	mce_notify_irq();
 }
 
 static void print_update(char *type, int *hdr, int num)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
