From: Christoph Lameter <cl@linux.com>
Subject: [thisops uV3 15/18] Xen: Use this_cpu_ops
Date: Tue, 30 Nov 2010 13:07:22 -0600
Message-ID: <20101130190850.002148257@linux.com>
References: <20101130190707.457099608@linux.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PNVZn-0000Xb-Da
	for glkm-linux-mm-2@m.gmane.org; Tue, 30 Nov 2010 20:09:19 +0100
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4377B6B0099
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 14:08:53 -0500 (EST)
Content-Disposition: inline; filename=this_ops_xen
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>, linux-kernel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Use this_cpu_ops to reduce code size and simplify things in various places.

Cc: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
Cc: 
Signed-off-by: Christoph Lameter <cl@linux.com>

---
 arch/x86/xen/enlighten.c  |    4 ++--
 arch/x86/xen/multicalls.h |    2 +-
 arch/x86/xen/spinlock.c   |    8 ++++----
 arch/x86/xen/time.c       |   13 ++++++-------
 drivers/xen/events.c      |   10 +++++-----
 5 files changed, 18 insertions(+), 19 deletions(-)

Index: linux-2.6/arch/x86/xen/enlighten.c
===================================================================
--- linux-2.6.orig/arch/x86/xen/enlighten.c	2010-11-30 12:31:39.000000000 -0600
+++ linux-2.6/arch/x86/xen/enlighten.c	2010-11-30 12:31:42.000000000 -0600
@@ -574,8 +574,8 @@ static void xen_write_idt_entry(gate_des
 
 	preempt_disable();
 
-	start = __get_cpu_var(idt_desc).address;
-	end = start + __get_cpu_var(idt_desc).size + 1;
+	start = __this_cpu_read(idt_desc.address);
+	end = start + __this_cpu_read(idt_desc.size) + 1;
 
 	xen_mc_flush();
 
Index: linux-2.6/arch/x86/xen/multicalls.h
===================================================================
--- linux-2.6.orig/arch/x86/xen/multicalls.h	2010-11-30 12:31:39.000000000 -0600
+++ linux-2.6/arch/x86/xen/multicalls.h	2010-11-30 12:31:42.000000000 -0600
@@ -22,7 +22,7 @@ static inline void xen_mc_batch(void)
 	unsigned long flags;
 	/* need to disable interrupts until this entry is complete */
 	local_irq_save(flags);
-	__get_cpu_var(xen_mc_irq_flags) = flags;
+	__this_cpu_write(xen_mc_irq_flags, flags);
 }
 
 static inline struct multicall_space xen_mc_entry(size_t args)
Index: linux-2.6/arch/x86/xen/spinlock.c
===================================================================
--- linux-2.6.orig/arch/x86/xen/spinlock.c	2010-11-30 12:31:39.000000000 -0600
+++ linux-2.6/arch/x86/xen/spinlock.c	2010-11-30 12:31:42.000000000 -0600
@@ -159,8 +159,8 @@ static inline struct xen_spinlock *spinn
 {
 	struct xen_spinlock *prev;
 
-	prev = __get_cpu_var(lock_spinners);
-	__get_cpu_var(lock_spinners) = xl;
+	prev = __this_cpu_read(lock_spinners);
+	__this_cpu_write(lock_spinners, xl);
 
 	wmb();			/* set lock of interest before count */
 
@@ -179,14 +179,14 @@ static inline void unspinning_lock(struc
 	asm(LOCK_PREFIX " decw %0"
 	    : "+m" (xl->spinners) : : "memory");
 	wmb();			/* decrement count before restoring lock */
-	__get_cpu_var(lock_spinners) = prev;
+	__this_cpu_write(lock_spinners, prev);
 }
 
 static noinline int xen_spin_lock_slow(struct arch_spinlock *lock, bool irq_enable)
 {
 	struct xen_spinlock *xl = (struct xen_spinlock *)lock;
 	struct xen_spinlock *prev;
-	int irq = __get_cpu_var(lock_kicker_irq);
+	int irq = __this_cpu_read(lock_kicker_irq);
 	int ret;
 	u64 start;
 
Index: linux-2.6/arch/x86/xen/time.c
===================================================================
--- linux-2.6.orig/arch/x86/xen/time.c	2010-11-30 12:31:39.000000000 -0600
+++ linux-2.6/arch/x86/xen/time.c	2010-11-30 12:31:42.000000000 -0600
@@ -135,24 +135,24 @@ static void do_stolen_accounting(void)
 
 	/* Add the appropriate number of ticks of stolen time,
 	   including any left-overs from last time. */
-	stolen = runnable + offline + __get_cpu_var(xen_residual_stolen);
+	stolen = runnable + offline + __this_cpu_read(xen_residual_stolen);
 
 	if (stolen < 0)
 		stolen = 0;
 
 	ticks = iter_div_u64_rem(stolen, NS_PER_TICK, &stolen);
-	__get_cpu_var(xen_residual_stolen) = stolen;
+	__this_cpu_write(xen_residual_stolen, stolen);
 	account_steal_ticks(ticks);
 
 	/* Add the appropriate number of ticks of blocked time,
 	   including any left-overs from last time. */
-	blocked += __get_cpu_var(xen_residual_blocked);
+	blocked += __this_cpu_read(xen_residual_blocked);
 
 	if (blocked < 0)
 		blocked = 0;
 
 	ticks = iter_div_u64_rem(blocked, NS_PER_TICK, &blocked);
-	__get_cpu_var(xen_residual_blocked) = blocked;
+	__this_cpu_write(xen_residual_blocked, blocked);
 	account_idle_ticks(ticks);
 }
 
@@ -370,12 +370,11 @@ static DEFINE_PER_CPU(struct clock_event
 
 static irqreturn_t xen_timer_interrupt(int irq, void *dev_id)
 {
-	struct clock_event_device *evt = &__get_cpu_var(xen_clock_events);
 	irqreturn_t ret;
 
 	ret = IRQ_NONE;
-	if (evt->event_handler) {
-		evt->event_handler(evt);
+	if (__this_cpu_read(xen_clock_events.event_handler)) {
+		__this_cpu_read(xen_clock_events.event_handler)(evt);
 		ret = IRQ_HANDLED;
 	}
 
Index: linux-2.6/drivers/xen/events.c
===================================================================
--- linux-2.6.orig/drivers/xen/events.c	2010-11-30 12:31:39.000000000 -0600
+++ linux-2.6/drivers/xen/events.c	2010-11-30 12:31:42.000000000 -0600
@@ -356,7 +356,7 @@ static void unmask_evtchn(int port)
 		struct evtchn_unmask unmask = { .port = port };
 		(void)HYPERVISOR_event_channel_op(EVTCHNOP_unmask, &unmask);
 	} else {
-		struct vcpu_info *vcpu_info = __get_cpu_var(xen_vcpu);
+		struct vcpu_info *vcpu_info = __this_cpu_read(xen_vcpu);
 
 		sync_clear_bit(port, &s->evtchn_mask[0]);
 
@@ -1087,7 +1087,7 @@ static void __xen_evtchn_do_upcall(void)
 {
 	int cpu = get_cpu();
 	struct shared_info *s = HYPERVISOR_shared_info;
-	struct vcpu_info *vcpu_info = __get_cpu_var(xen_vcpu);
+	struct vcpu_info *vcpu_info = __this_cpu_read(xen_vcpu);
  	unsigned count;
 
 	do {
@@ -1095,7 +1095,7 @@ static void __xen_evtchn_do_upcall(void)
 
 		vcpu_info->evtchn_upcall_pending = 0;
 
-		if (__get_cpu_var(xed_nesting_count)++)
+		if (__this_cpu_inc_return(xed_nesting_count))
 			goto out;
 
 #ifndef CONFIG_X86 /* No need for a barrier -- XCHG is a barrier on x86. */
@@ -1127,8 +1127,8 @@ static void __xen_evtchn_do_upcall(void)
 
 		BUG_ON(!irqs_disabled());
 
-		count = __get_cpu_var(xed_nesting_count);
-		__get_cpu_var(xed_nesting_count) = 0;
+		count = __this_cpu_read(xed_nesting_count);
+		__this_cpu_write(xed_nesting_count, 0);
 	} while (count != 1 || vcpu_info->evtchn_upcall_pending);
 
 out:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
