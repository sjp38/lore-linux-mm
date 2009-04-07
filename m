Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9FF255F0008
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 11:10:23 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
References: <20090407509.382219156@firstfloor.org>
In-Reply-To: <20090407509.382219156@firstfloor.org>
Subject: [PATCH] [15/16] x86: MCE: Support action-optional machine checks
Message-Id: <20090407151013.17B2B1D046F@basil.firstfloor.org>
Date: Tue,  7 Apr 2009 17:10:13 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>


Newer Intel CPUs support a new class of machine checks called recoverable
action optional.

Action Optional means that the CPU detected some form of corruption in
the background and tells the OS about using a machine check
exception. The OS can then take appropiate action, like killing the
process with the corrupted data or logging the event properly to disk.

This is done by the new generic high level memory failure handler added in a
earlier patch. The high level handler takes the address with the failed
memory and does the appropiate action, like killing the process.

The high level handler cannot be directly called from the machine check 
exception though, because it has to run in a defined process context to be able
to sleep when taking VM locks (it is not expected to sleep for a long time,
just do so in some exceptional cases like lock contention) 

Thus the MCE handler has to queue a work item for process context,
trigger process context and then call the high level handler from there.

This patch adds two path to process context: through a per thread kernel exit
notify_user() callback or through a high priority work item.  The first
runs when the process exits back to user space, the other when it goes
to sleep and there is no higher priority process. 

The machine check handler will schedule both, and whoever runs first
will grab the event. This is done because quick reaction to this 
event is critical to avoid a potential more fatal machine check
when the corruption is consumed.

There is a simple lock less ring buffer to queue the corrupted
addresses between the exception handler and the process context handler.
Then in process context it just calls the high level VM code with 
the corrupted PFNs.

The code adds the required code to extract the failed address from
the CPU's machine check registers. It doesn't try to handle all 
possible cases -- the specification has 6 different ways to specify
memory address -- but only the linear address.

Most of the required checking has been already done earlier in the
mce_severity rule checking engine.  Following the Intel
recommendations Action Optional errors are only enabled for known
situations (encoded in MCACODs). The errors are ignored otherwise,
because they are action optional.

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 arch/x86/Kconfig                          |    1 
 arch/x86/include/asm/irq_vectors.h        |    1 
 arch/x86/include/asm/mce.h                |    1 
 arch/x86/kernel/cpu/mcheck/mce-severity.c |    8 +-
 arch/x86/kernel/cpu/mcheck/mce_64.c       |  114 ++++++++++++++++++++++++++++++
 arch/x86/kernel/signal.c                  |    2 
 6 files changed, 125 insertions(+), 2 deletions(-)

Index: linux/arch/x86/kernel/cpu/mcheck/mce_64.c
===================================================================
--- linux.orig/arch/x86/kernel/cpu/mcheck/mce_64.c	2009-04-07 16:39:39.000000000 +0200
+++ linux/arch/x86/kernel/cpu/mcheck/mce_64.c	2009-04-07 16:39:39.000000000 +0200
@@ -14,6 +14,7 @@
 #include <linux/sched.h>
 #include <linux/string.h>
 #include <linux/rcupdate.h>
+#include <linux/mm.h>
 #include <linux/kallsyms.h>
 #include <linux/sysdev.h>
 #include <linux/miscdevice.h>
@@ -79,6 +80,8 @@
 	[0 ... BITS_TO_LONGS(MAX_NR_BANKS)-1] = ~0UL
 };
 
+static DEFINE_PER_CPU(struct work_struct, mce_work);
+
 /* Do initial initialization of a struct mce */
 void mce_setup(struct mce *m)
 {
@@ -273,6 +276,52 @@
 	wrmsrl(msr, v);
 }
 
+/*
+ * Simple lockless ring to communicate PFNs from the exception handler with the
+ * process context work function. This is vastly simplified because there's
+ * only a single reader and a single writer.
+ */
+#define MCE_RING_SIZE 16	/* we use one entry less */
+
+struct mce_ring {
+	unsigned short start;
+	unsigned short end;
+	unsigned long ring[MCE_RING_SIZE];
+};
+static DEFINE_PER_CPU(struct mce_ring, mce_ring);
+
+static int mce_ring_empty(void)
+{
+	struct mce_ring *r = &__get_cpu_var(mce_ring);
+
+	return r->start == r->end;
+}
+
+static int mce_ring_get(unsigned long *pfn)
+{
+	struct mce_ring *r = &__get_cpu_var(mce_ring);
+
+	if (r->start == r->end)
+		return 0;
+	*pfn = r->ring[r->start];
+	r->start = (r->start + 1) % MCE_RING_SIZE;
+	return 1;
+}
+
+static int mce_ring_add(unsigned long pfn)
+{
+	struct mce_ring *r = &__get_cpu_var(mce_ring);
+	unsigned next;
+
+	next = (r->end + 1) % MCE_RING_SIZE;
+	if (next == r->start)
+		return -1;
+	r->ring[r->end] = pfn;
+	wmb();
+	r->end = next;
+	return 0;
+}
+
 int mce_available(struct cpuinfo_x86 *c)
 {
 	if (mce_dont_init)
@@ -293,6 +342,15 @@
 		m->ip = mce_rdmsrl(rip_msr);
 }
 
+static void mce_schedule_work(void)
+{
+	if (!mce_ring_empty()) {
+		struct work_struct *work = &__get_cpu_var(mce_work);
+		if (!work_pending(work))
+			schedule_work(work);
+	}
+}
+
 /*
  * Called after interrupts have been reenabled again
  * when a MCE happened during an interrupts off region
@@ -304,6 +362,7 @@
 	exit_idle();
 	irq_enter();
 	mce_notify_irq();
+	mce_schedule_work();
 	irq_exit();
 }
 
@@ -311,6 +370,13 @@
 {
 	if (regs->flags & (X86_VM_MASK|X86_EFLAGS_IF)) {
 		mce_notify_irq();
+		/*
+		 * Triggering the work queue here is just an insurance
+		 * policy in case the syscall exit notify handler
+		 * doesn't run soon enough or ends up running on the
+		 * wrong CPU (can happen when audit sleeps)
+		 */
+		mce_schedule_work();
 		return;
 	}
 
@@ -669,6 +735,23 @@
 	return ret;
 }
 
+/*
+ * Check if the address reported by the CPU is in a format we can parse.
+ * It would be possible to add code for most other cases, but all would
+ * be somewhat complicated (e.g. segment offset would require an instruction
+ * parser). So only support physical addresses upto page granuality for now.
+ */
+static int mce_usable_address(struct mce *m)
+{
+	if (!(m->status & MCI_STATUS_MISCV) || !(m->status & MCI_STATUS_ADDRV))
+		return 0;
+	if ((m->misc & 0x3f) > PAGE_SHIFT)
+		return 0;
+	if (((m->misc >> 6) & 7) != MCM_ADDR_PHYS)
+		return 0;
+	return 1;
+}
+
 static void mce_clear_state(unsigned long *toclear)
 {
 	int i;
@@ -802,6 +885,16 @@
 		if (m.status & MCI_STATUS_ADDRV)
 			m.addr = mce_rdmsrl(MSR_IA32_MC0_ADDR + i*4);
 
+		/*
+		 * Action optional error. Queue address for later processing.
+		 * When the ring overflows we just ignore the AO error.
+		 * RED-PEN add some logging mechanism when
+		 * usable_address or mce_add_ring fails.
+		 * RED-PEN don't ignore overflow for tolerant == 0
+		 */
+		if (severity == MCE_AO_SEVERITY && mce_usable_address(&m))
+			mce_ring_add(m.addr >> PAGE_SHIFT);
+
 		mce_get_rip(&m, regs);
 		mce_log(&m);
 
@@ -852,6 +945,26 @@
 }
 EXPORT_SYMBOL_GPL(do_machine_check);
 
+/*
+ * Called after mce notification in process context. This code
+ * is allowed to sleep. Call the high level VM handler to process
+ * any corrupted pages.
+ * Assume that the work queue code only calls this one at a time
+ * per CPU.
+ */
+void mce_notify_process(void)
+{
+	unsigned long pfn;
+	mce_notify_irq();
+	while (mce_ring_get(&pfn))
+		memory_failure(pfn, MCE_VECTOR);
+}
+
+static void mce_process_work(struct work_struct *dummy)
+{
+	mce_notify_process();
+}
+
 #ifdef CONFIG_X86_MCE_INTEL
 /***
  * mce_log_therm_throt_event - Logs the thermal throttling event to mcelog
@@ -1088,6 +1201,7 @@
 	mce_init();
 	mce_cpu_features(c);
 	mce_init_timer();
+	INIT_WORK(&__get_cpu_var(mce_work), mce_process_work);
 }
 
 /*
Index: linux/arch/x86/include/asm/mce.h
===================================================================
--- linux.orig/arch/x86/include/asm/mce.h	2009-04-07 16:39:39.000000000 +0200
+++ linux/arch/x86/include/asm/mce.h	2009-04-07 16:39:39.000000000 +0200
@@ -163,6 +163,7 @@
 extern void machine_check_poll(enum mcp_flags flags, mce_banks_t *b);
 
 extern int mce_notify_irq(void);
+extern void mce_notify_process(void);
 
 #endif /* !CONFIG_X86_32 */
 
Index: linux/arch/x86/kernel/signal.c
===================================================================
--- linux.orig/arch/x86/kernel/signal.c	2009-04-07 16:39:39.000000000 +0200
+++ linux/arch/x86/kernel/signal.c	2009-04-07 16:39:39.000000000 +0200
@@ -860,7 +860,7 @@
 #if defined(CONFIG_X86_64) && defined(CONFIG_X86_MCE)
 	/* notify userspace of pending MCEs */
 	if (thread_info_flags & _TIF_MCE_NOTIFY)
-		mce_notify_irq();
+		mce_notify_process();
 #endif /* CONFIG_X86_64 && CONFIG_X86_MCE */
 
 	/* deal with pending signal delivery */
Index: linux/arch/x86/kernel/cpu/mcheck/mce-severity.c
===================================================================
--- linux.orig/arch/x86/kernel/cpu/mcheck/mce-severity.c	2009-04-07 16:39:00.000000000 +0200
+++ linux/arch/x86/kernel/cpu/mcheck/mce-severity.c	2009-04-07 16:39:39.000000000 +0200
@@ -67,7 +67,13 @@
 	     "Action required; unknown MCACOD", SER),
 	MASK(MCI_STATUS_OVER|MCI_UC_SAR, MCI_STATUS_OVER|MCI_UC_SAR, PANIC,
 	     "Action required with lost events", SER),
-	/* AO add known MCACODs here */
+
+	/* known AO MCACODs: handle by calling high level handler */
+	MASK(MCI_UC_SAR|0xfff0, MCI_UC_S|0xc0, AO,
+	     "Action optional: memory scrubbing error", SER),
+	MASK(MCI_UC_SAR|MCACOD, MCI_UC_S|0x17a, AO,
+	     "Action optional: last level cache writeback error", SER),
+
 	MASK(MCI_STATUS_OVER|MCI_UC_SAR, MCI_UC_S, SOME,
 	     "Action optional unknown MCACOD", SER),
 	MASK(MCI_STATUS_OVER|MCI_UC_SAR, MCI_UC_S|MCI_STATUS_OVER, SOME,
Index: linux/arch/x86/include/asm/irq_vectors.h
===================================================================
--- linux.orig/arch/x86/include/asm/irq_vectors.h	2009-04-07 16:39:00.000000000 +0200
+++ linux/arch/x86/include/asm/irq_vectors.h	2009-04-07 16:39:39.000000000 +0200
@@ -25,6 +25,7 @@
  */
 
 #define NMI_VECTOR			0x02
+#define MCE_VECTOR			0x12
 
 /*
  * IDT vectors usable for external interrupt sources start
Index: linux/arch/x86/Kconfig
===================================================================
--- linux.orig/arch/x86/Kconfig	2009-04-07 16:39:00.000000000 +0200
+++ linux/arch/x86/Kconfig	2009-04-07 16:39:39.000000000 +0200
@@ -760,6 +760,7 @@
 
 config X86_MCE
 	bool "Machine Check Exception"
+	select MEMORY_FAILURE
 	---help---
 	  Machine Check Exception support allows the processor to notify the
 	  kernel if it detects a problem (e.g. overheating, component failure).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
