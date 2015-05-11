Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 96B446B0073
	for <linux-mm@kvack.org>; Mon, 11 May 2015 11:53:01 -0400 (EDT)
Received: by wgiu9 with SMTP id u9so132651917wgi.3
        for <linux-mm@kvack.org>; Mon, 11 May 2015 08:53:00 -0700 (PDT)
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com. [195.75.94.107])
        by mx.google.com with ESMTPS id q7si453962wix.4.2015.05.11.08.52.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Mon, 11 May 2015 08:52:52 -0700 (PDT)
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dahi@linux.vnet.ibm.com>;
	Mon, 11 May 2015 16:52:51 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id BE8D817D805D
	for <linux-mm@kvack.org>; Mon, 11 May 2015 16:53:35 +0100 (BST)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t4BFqmF81114376
	for <linux-mm@kvack.org>; Mon, 11 May 2015 15:52:48 GMT
Received: from d06av05.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t4BFqk4U014838
	for <linux-mm@kvack.org>; Mon, 11 May 2015 09:52:48 -0600
From: David Hildenbrand <dahi@linux.vnet.ibm.com>
Subject: [PATCH v1 06/15] mm: use pagefault_disable() to check for disabled pagefaults in the handler
Date: Mon, 11 May 2015 17:52:11 +0200
Message-Id: <1431359540-32227-7-git-send-email-dahi@linux.vnet.ibm.com>
In-Reply-To: <1431359540-32227-1-git-send-email-dahi@linux.vnet.ibm.com>
References: <1431359540-32227-1-git-send-email-dahi@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: mingo@redhat.com, yang.shi@windriver.com, bigeasy@linutronix.de, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, borntraeger@de.ibm.com, mst@redhat.com, tglx@linutronix.de, David.Laight@ACULAB.COM, hughd@google.com, hocko@suse.cz, ralf@linux-mips.org, herbert@gondor.apana.org.au, linux@arm.linux.org.uk, airlied@linux.ie, daniel.vetter@intel.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, peterz@infradead.org, dahi@linux.vnet.ibm.com

Introduce faulthandler_disabled() and use it to check for irq context and
disabled pagefaults (via pagefault_disable()) in the pagefault handlers.

Please note that we keep the in_atomic() checks in place - to detect
whether in irq context (in which case preemption is always properly
disabled).

In contrast, preempt_disable() should never be used to disable pagefaults.
With !CONFIG_PREEMPT_COUNT, preempt_disable() doesn't modify the preempt
counter, and therefore the result of in_atomic() differs.
We validate that condition by using might_fault() checks when calling
might_sleep().

Therefore, add a comment to faulthandler_disabled(), describing why this
is needed.

faulthandler_disabled() and pagefault_disable() are defined in
linux/uaccess.h, so let's properly add that include to all relevant files.

This patch is based on a patch from Thomas Gleixner.

Signed-off-by: David Hildenbrand <dahi@linux.vnet.ibm.com>
---
 arch/alpha/mm/fault.c      |  5 ++---
 arch/arc/mm/fault.c        |  2 +-
 arch/arm/mm/fault.c        |  2 +-
 arch/arm64/mm/fault.c      |  2 +-
 arch/avr32/mm/fault.c      |  4 ++--
 arch/cris/mm/fault.c       |  6 +++---
 arch/frv/mm/fault.c        |  4 ++--
 arch/ia64/mm/fault.c       |  4 ++--
 arch/m32r/mm/fault.c       |  8 ++++----
 arch/m68k/mm/fault.c       |  4 ++--
 arch/metag/mm/fault.c      |  2 +-
 arch/microblaze/mm/fault.c |  8 ++++----
 arch/mips/mm/fault.c       |  4 ++--
 arch/mn10300/mm/fault.c    |  4 ++--
 arch/nios2/mm/fault.c      |  2 +-
 arch/parisc/kernel/traps.c |  4 ++--
 arch/parisc/mm/fault.c     |  4 ++--
 arch/powerpc/mm/fault.c    |  9 +++++----
 arch/s390/mm/fault.c       |  2 +-
 arch/score/mm/fault.c      |  3 ++-
 arch/sh/mm/fault.c         |  5 +++--
 arch/sparc/mm/fault_32.c   |  4 ++--
 arch/sparc/mm/fault_64.c   |  4 ++--
 arch/sparc/mm/init_64.c    |  2 +-
 arch/tile/mm/fault.c       |  4 ++--
 arch/um/kernel/trap.c      |  4 ++--
 arch/unicore32/mm/fault.c  |  2 +-
 arch/x86/mm/fault.c        |  5 +++--
 arch/xtensa/mm/fault.c     |  4 ++--
 include/linux/uaccess.h    | 12 ++++++++++++
 30 files changed, 72 insertions(+), 57 deletions(-)

diff --git a/arch/alpha/mm/fault.c b/arch/alpha/mm/fault.c
index 9d0ac09..4a905bd 100644
--- a/arch/alpha/mm/fault.c
+++ b/arch/alpha/mm/fault.c
@@ -23,8 +23,7 @@
 #include <linux/smp.h>
 #include <linux/interrupt.h>
 #include <linux/module.h>
-
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 
 extern void die_if_kernel(char *,struct pt_regs *,long, unsigned long *);
 
@@ -107,7 +106,7 @@ do_page_fault(unsigned long address, unsigned long mmcsr,
 
 	/* If we're in an interrupt context, or have no user context,
 	   we must not take the fault.  */
-	if (!mm || in_atomic())
+	if (!mm || faulthandler_disabled())
 		goto no_context;
 
 #ifdef CONFIG_ALPHA_LARGE_VMALLOC
diff --git a/arch/arc/mm/fault.c b/arch/arc/mm/fault.c
index 6a2e006..d948e4e 100644
--- a/arch/arc/mm/fault.c
+++ b/arch/arc/mm/fault.c
@@ -86,7 +86,7 @@ void do_page_fault(unsigned long address, struct pt_regs *regs)
 	 * If we're in an interrupt or have no user
 	 * context, we must not take the fault..
 	 */
-	if (in_atomic() || !mm)
+	if (faulthandler_disabled() || !mm)
 		goto no_context;
 
 	if (user_mode(regs))
diff --git a/arch/arm/mm/fault.c b/arch/arm/mm/fault.c
index 6333d9c..0d629b8 100644
--- a/arch/arm/mm/fault.c
+++ b/arch/arm/mm/fault.c
@@ -276,7 +276,7 @@ do_page_fault(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 	 * If we're in an interrupt or have no user
 	 * context, we must not take the fault..
 	 */
-	if (in_atomic() || !mm)
+	if (faulthandler_disabled() || !mm)
 		goto no_context;
 
 	if (user_mode(regs))
diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
index 96da131..0948d32 100644
--- a/arch/arm64/mm/fault.c
+++ b/arch/arm64/mm/fault.c
@@ -211,7 +211,7 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
 	 * If we're in an interrupt or have no user context, we must not take
 	 * the fault.
 	 */
-	if (in_atomic() || !mm)
+	if (faulthandler_disabled() || !mm)
 		goto no_context;
 
 	if (user_mode(regs))
diff --git a/arch/avr32/mm/fault.c b/arch/avr32/mm/fault.c
index d223a8b..c035339 100644
--- a/arch/avr32/mm/fault.c
+++ b/arch/avr32/mm/fault.c
@@ -14,11 +14,11 @@
 #include <linux/pagemap.h>
 #include <linux/kdebug.h>
 #include <linux/kprobes.h>
+#include <linux/uaccess.h>
 
 #include <asm/mmu_context.h>
 #include <asm/sysreg.h>
 #include <asm/tlb.h>
-#include <asm/uaccess.h>
 
 #ifdef CONFIG_KPROBES
 static inline int notify_page_fault(struct pt_regs *regs, int trap)
@@ -81,7 +81,7 @@ asmlinkage void do_page_fault(unsigned long ecr, struct pt_regs *regs)
 	 * If we're in an interrupt or have no user context, we must
 	 * not take the fault...
 	 */
-	if (in_atomic() || !mm || regs->sr & SYSREG_BIT(GM))
+	if (faulthandler_disabled() || !mm || regs->sr & SYSREG_BIT(GM))
 		goto no_context;
 
 	local_irq_enable();
diff --git a/arch/cris/mm/fault.c b/arch/cris/mm/fault.c
index 83f12f2..3066d40 100644
--- a/arch/cris/mm/fault.c
+++ b/arch/cris/mm/fault.c
@@ -8,7 +8,7 @@
 #include <linux/interrupt.h>
 #include <linux/module.h>
 #include <linux/wait.h>
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 #include <arch/system.h>
 
 extern int find_fixup_code(struct pt_regs *);
@@ -109,11 +109,11 @@ do_page_fault(unsigned long address, struct pt_regs *regs,
 	info.si_code = SEGV_MAPERR;
 
 	/*
-	 * If we're in an interrupt or "atomic" operation or have no
+	 * If we're in an interrupt, have pagefaults disabled or have no
 	 * user context, we must not take the fault.
 	 */
 
-	if (in_atomic() || !mm)
+	if (faulthandler_disabled() || !mm)
 		goto no_context;
 
 	if (user_mode(regs))
diff --git a/arch/frv/mm/fault.c b/arch/frv/mm/fault.c
index ec4917d..61d9976 100644
--- a/arch/frv/mm/fault.c
+++ b/arch/frv/mm/fault.c
@@ -19,9 +19,9 @@
 #include <linux/kernel.h>
 #include <linux/ptrace.h>
 #include <linux/hardirq.h>
+#include <linux/uaccess.h>
 
 #include <asm/pgtable.h>
-#include <asm/uaccess.h>
 #include <asm/gdb-stub.h>
 
 /*****************************************************************************/
@@ -78,7 +78,7 @@ asmlinkage void do_page_fault(int datammu, unsigned long esr0, unsigned long ear
 	 * If we're in an interrupt or have no user
 	 * context, we must not take the fault..
 	 */
-	if (in_atomic() || !mm)
+	if (faulthandler_disabled() || !mm)
 		goto no_context;
 
 	if (user_mode(__frame))
diff --git a/arch/ia64/mm/fault.c b/arch/ia64/mm/fault.c
index ba5ba7a..70b40d1 100644
--- a/arch/ia64/mm/fault.c
+++ b/arch/ia64/mm/fault.c
@@ -11,10 +11,10 @@
 #include <linux/kprobes.h>
 #include <linux/kdebug.h>
 #include <linux/prefetch.h>
+#include <linux/uaccess.h>
 
 #include <asm/pgtable.h>
 #include <asm/processor.h>
-#include <asm/uaccess.h>
 
 extern int die(char *, struct pt_regs *, long);
 
@@ -96,7 +96,7 @@ ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *re
 	/*
 	 * If we're in an interrupt or have no user context, we must not take the fault..
 	 */
-	if (in_atomic() || !mm)
+	if (faulthandler_disabled() || !mm)
 		goto no_context;
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
diff --git a/arch/m32r/mm/fault.c b/arch/m32r/mm/fault.c
index e3d4d48901..8f9875b 100644
--- a/arch/m32r/mm/fault.c
+++ b/arch/m32r/mm/fault.c
@@ -24,9 +24,9 @@
 #include <linux/vt_kern.h>		/* For unblank_screen() */
 #include <linux/highmem.h>
 #include <linux/module.h>
+#include <linux/uaccess.h>
 
 #include <asm/m32r.h>
-#include <asm/uaccess.h>
 #include <asm/hardirq.h>
 #include <asm/mmu_context.h>
 #include <asm/tlbflush.h>
@@ -111,10 +111,10 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long error_code,
 	mm = tsk->mm;
 
 	/*
-	 * If we're in an interrupt or have no user context or are running in an
-	 * atomic region then we must not take the fault..
+	 * If we're in an interrupt or have no user context or have pagefaults
+	 * disabled then we must not take the fault.
 	 */
-	if (in_atomic() || !mm)
+	if (faulthandler_disabled() || !mm)
 		goto bad_area_nosemaphore;
 
 	if (error_code & ACE_USERMODE)
diff --git a/arch/m68k/mm/fault.c b/arch/m68k/mm/fault.c
index b2f04ae..6a94cdd 100644
--- a/arch/m68k/mm/fault.c
+++ b/arch/m68k/mm/fault.c
@@ -10,10 +10,10 @@
 #include <linux/ptrace.h>
 #include <linux/interrupt.h>
 #include <linux/module.h>
+#include <linux/uaccess.h>
 
 #include <asm/setup.h>
 #include <asm/traps.h>
-#include <asm/uaccess.h>
 #include <asm/pgalloc.h>
 
 extern void die_if_kernel(char *, struct pt_regs *, long);
@@ -81,7 +81,7 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 	 * If we're in an interrupt or have no user
 	 * context, we must not take the fault..
 	 */
-	if (in_atomic() || !mm)
+	if (faulthandler_disabled() || !mm)
 		goto no_context;
 
 	if (user_mode(regs))
diff --git a/arch/metag/mm/fault.c b/arch/metag/mm/fault.c
index 2de5dc6..f57edca 100644
--- a/arch/metag/mm/fault.c
+++ b/arch/metag/mm/fault.c
@@ -105,7 +105,7 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 
 	mm = tsk->mm;
 
-	if (in_atomic() || !mm)
+	if (faulthandler_disabled() || !mm)
 		goto no_context;
 
 	if (user_mode(regs))
diff --git a/arch/microblaze/mm/fault.c b/arch/microblaze/mm/fault.c
index d46a5eb..177dfc0 100644
--- a/arch/microblaze/mm/fault.c
+++ b/arch/microblaze/mm/fault.c
@@ -107,14 +107,14 @@ void do_page_fault(struct pt_regs *regs, unsigned long address,
 	if ((error_code & 0x13) == 0x13 || (error_code & 0x11) == 0x11)
 		is_write = 0;
 
-	if (unlikely(in_atomic() || !mm)) {
+	if (unlikely(faulthandler_disabled() || !mm)) {
 		if (kernel_mode(regs))
 			goto bad_area_nosemaphore;
 
-		/* in_atomic() in user mode is really bad,
+		/* faulthandler_disabled() in user mode is really bad,
 		   as is current->mm == NULL. */
-		pr_emerg("Page fault in user mode with in_atomic(), mm = %p\n",
-									mm);
+		pr_emerg("Page fault in user mode with faulthandler_disabled(), mm = %p\n",
+			 mm);
 		pr_emerg("r15 = %lx  MSR = %lx\n",
 		       regs->r15, regs->msr);
 		die("Weird page fault", regs, SIGSEGV);
diff --git a/arch/mips/mm/fault.c b/arch/mips/mm/fault.c
index 7ff8637..36c0f26 100644
--- a/arch/mips/mm/fault.c
+++ b/arch/mips/mm/fault.c
@@ -21,10 +21,10 @@
 #include <linux/module.h>
 #include <linux/kprobes.h>
 #include <linux/perf_event.h>
+#include <linux/uaccess.h>
 
 #include <asm/branch.h>
 #include <asm/mmu_context.h>
-#include <asm/uaccess.h>
 #include <asm/ptrace.h>
 #include <asm/highmem.h>		/* For VMALLOC_END */
 #include <linux/kdebug.h>
@@ -94,7 +94,7 @@ static void __kprobes __do_page_fault(struct pt_regs *regs, unsigned long write,
 	 * If we're in an interrupt or have no user
 	 * context, we must not take the fault..
 	 */
-	if (in_atomic() || !mm)
+	if (faulthandler_disabled() || !mm)
 		goto bad_area_nosemaphore;
 
 	if (user_mode(regs))
diff --git a/arch/mn10300/mm/fault.c b/arch/mn10300/mm/fault.c
index 0c2cc5d..4a1d181 100644
--- a/arch/mn10300/mm/fault.c
+++ b/arch/mn10300/mm/fault.c
@@ -23,8 +23,8 @@
 #include <linux/interrupt.h>
 #include <linux/init.h>
 #include <linux/vt_kern.h>		/* For unblank_screen() */
+#include <linux/uaccess.h>
 
-#include <asm/uaccess.h>
 #include <asm/pgalloc.h>
 #include <asm/hardirq.h>
 #include <asm/cpu-regs.h>
@@ -168,7 +168,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long fault_code,
 	 * If we're in an interrupt or have no user
 	 * context, we must not take the fault..
 	 */
-	if (in_atomic() || !mm)
+	if (faulthandler_disabled() || !mm)
 		goto no_context;
 
 	if ((fault_code & MMUFCR_xFC_ACCESS) == MMUFCR_xFC_ACCESS_USR)
diff --git a/arch/nios2/mm/fault.c b/arch/nios2/mm/fault.c
index 0c9b6af..b51878b 100644
--- a/arch/nios2/mm/fault.c
+++ b/arch/nios2/mm/fault.c
@@ -77,7 +77,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long cause,
 	 * If we're in an interrupt or have no user
 	 * context, we must not take the fault..
 	 */
-	if (in_atomic() || !mm)
+	if (faulthandler_disabled() || !mm)
 		goto bad_area_nosemaphore;
 
 	if (user_mode(regs))
diff --git a/arch/parisc/kernel/traps.c b/arch/parisc/kernel/traps.c
index 47ee620..6548fd1 100644
--- a/arch/parisc/kernel/traps.c
+++ b/arch/parisc/kernel/traps.c
@@ -26,9 +26,9 @@
 #include <linux/console.h>
 #include <linux/bug.h>
 #include <linux/ratelimit.h>
+#include <linux/uaccess.h>
 
 #include <asm/assembly.h>
-#include <asm/uaccess.h>
 #include <asm/io.h>
 #include <asm/irq.h>
 #include <asm/traps.h>
@@ -800,7 +800,7 @@ void notrace handle_interruption(int code, struct pt_regs *regs)
 	     * unless pagefault_disable() was called before.
 	     */
 
-	    if (fault_space == 0 && !in_atomic())
+	    if (fault_space == 0 && !faulthandler_disabled())
 	    {
 		pdc_chassis_send_status(PDC_CHASSIS_DIRECT_PANIC);
 		parisc_terminate("Kernel Fault", regs, code, fault_address);
diff --git a/arch/parisc/mm/fault.c b/arch/parisc/mm/fault.c
index e5120e6..15503ad 100644
--- a/arch/parisc/mm/fault.c
+++ b/arch/parisc/mm/fault.c
@@ -15,8 +15,8 @@
 #include <linux/sched.h>
 #include <linux/interrupt.h>
 #include <linux/module.h>
+#include <linux/uaccess.h>
 
-#include <asm/uaccess.h>
 #include <asm/traps.h>
 
 /* Various important other fields */
@@ -207,7 +207,7 @@ void do_page_fault(struct pt_regs *regs, unsigned long code,
 	int fault;
 	unsigned int flags;
 
-	if (in_atomic())
+	if (pagefault_disabled())
 		goto no_context;
 
 	tsk = current;
diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index b396868..6d53597 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -33,13 +33,13 @@
 #include <linux/ratelimit.h>
 #include <linux/context_tracking.h>
 #include <linux/hugetlb.h>
+#include <linux/uaccess.h>
 
 #include <asm/firmware.h>
 #include <asm/page.h>
 #include <asm/pgtable.h>
 #include <asm/mmu.h>
 #include <asm/mmu_context.h>
-#include <asm/uaccess.h>
 #include <asm/tlbflush.h>
 #include <asm/siginfo.h>
 #include <asm/debug.h>
@@ -272,15 +272,16 @@ int __kprobes do_page_fault(struct pt_regs *regs, unsigned long address,
 	if (!arch_irq_disabled_regs(regs))
 		local_irq_enable();
 
-	if (in_atomic() || mm == NULL) {
+	if (faulthandler_disabled() || mm == NULL) {
 		if (!user_mode(regs)) {
 			rc = SIGSEGV;
 			goto bail;
 		}
-		/* in_atomic() in user mode is really bad,
+		/* faulthandler_disabled() in user mode is really bad,
 		   as is current->mm == NULL. */
 		printk(KERN_EMERG "Page fault in user mode with "
-		       "in_atomic() = %d mm = %p\n", in_atomic(), mm);
+		       "faulthandler_disabled() = %d mm = %p\n",
+		       faulthandler_disabled(), mm);
 		printk(KERN_EMERG "NIP = %lx  MSR = %lx\n",
 		       regs->nip, regs->msr);
 		die("Weird page fault", regs, SIGSEGV);
diff --git a/arch/s390/mm/fault.c b/arch/s390/mm/fault.c
index 76515bc..4c8f5d7 100644
--- a/arch/s390/mm/fault.c
+++ b/arch/s390/mm/fault.c
@@ -399,7 +399,7 @@ static inline int do_exception(struct pt_regs *regs, int access)
 	 * user context.
 	 */
 	fault = VM_FAULT_BADCONTEXT;
-	if (unlikely(!user_space_fault(regs) || in_atomic() || !mm))
+	if (unlikely(!user_space_fault(regs) || faulthandler_disabled() || !mm))
 		goto out;
 
 	address = trans_exc_code & __FAIL_ADDR_MASK;
diff --git a/arch/score/mm/fault.c b/arch/score/mm/fault.c
index 6860beb..37a6c2e 100644
--- a/arch/score/mm/fault.c
+++ b/arch/score/mm/fault.c
@@ -34,6 +34,7 @@
 #include <linux/string.h>
 #include <linux/types.h>
 #include <linux/ptrace.h>
+#include <linux/uaccess.h>
 
 /*
  * This routine handles page faults.  It determines the address,
@@ -73,7 +74,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long write,
 	* If we're in an interrupt or have no user
 	* context, we must not take the fault..
 	*/
-	if (in_atomic() || !mm)
+	if (pagefault_disabled() || !mm)
 		goto bad_area_nosemaphore;
 
 	if (user_mode(regs))
diff --git a/arch/sh/mm/fault.c b/arch/sh/mm/fault.c
index a58fec9..79d8276 100644
--- a/arch/sh/mm/fault.c
+++ b/arch/sh/mm/fault.c
@@ -17,6 +17,7 @@
 #include <linux/kprobes.h>
 #include <linux/perf_event.h>
 #include <linux/kdebug.h>
+#include <linux/uaccess.h>
 #include <asm/io_trapped.h>
 #include <asm/mmu_context.h>
 #include <asm/tlbflush.h>
@@ -438,9 +439,9 @@ asmlinkage void __kprobes do_page_fault(struct pt_regs *regs,
 
 	/*
 	 * If we're in an interrupt, have no user context or are running
-	 * in an atomic region then we must not take the fault:
+	 * with pagefaults disabled then we must not take the fault:
 	 */
-	if (unlikely(in_atomic() || !mm)) {
+	if (unlikely(faulthandler_disabled() || !mm)) {
 		bad_area_nosemaphore(regs, error_code, address);
 		return;
 	}
diff --git a/arch/sparc/mm/fault_32.c b/arch/sparc/mm/fault_32.c
index 70d8171..c399e7b 100644
--- a/arch/sparc/mm/fault_32.c
+++ b/arch/sparc/mm/fault_32.c
@@ -21,6 +21,7 @@
 #include <linux/perf_event.h>
 #include <linux/interrupt.h>
 #include <linux/kdebug.h>
+#include <linux/uaccess.h>
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
@@ -29,7 +30,6 @@
 #include <asm/setup.h>
 #include <asm/smp.h>
 #include <asm/traps.h>
-#include <asm/uaccess.h>
 
 #include "mm_32.h"
 
@@ -196,7 +196,7 @@ asmlinkage void do_sparc_fault(struct pt_regs *regs, int text_fault, int write,
 	 * If we're in an interrupt or have no user
 	 * context, we must not take the fault..
 	 */
-	if (in_atomic() || !mm)
+	if (pagefault_disabled() || !mm)
 		goto no_context;
 
 	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, address);
diff --git a/arch/sparc/mm/fault_64.c b/arch/sparc/mm/fault_64.c
index 4798232..e9268ea 100644
--- a/arch/sparc/mm/fault_64.c
+++ b/arch/sparc/mm/fault_64.c
@@ -22,12 +22,12 @@
 #include <linux/kdebug.h>
 #include <linux/percpu.h>
 #include <linux/context_tracking.h>
+#include <linux/uaccess.h>
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
 #include <asm/openprom.h>
 #include <asm/oplib.h>
-#include <asm/uaccess.h>
 #include <asm/asi.h>
 #include <asm/lsu.h>
 #include <asm/sections.h>
@@ -330,7 +330,7 @@ asmlinkage void __kprobes do_sparc64_fault(struct pt_regs *regs)
 	 * If we're in an interrupt or have no user
 	 * context, we must not take the fault..
 	 */
-	if (in_atomic() || !mm)
+	if (faulthandler_disabled() || !mm)
 		goto intr_or_no_mm;
 
 	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, address);
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index 4ca0d6b..cee9b77 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -2706,7 +2706,7 @@ void hugetlb_setup(struct pt_regs *regs)
 	struct mm_struct *mm = current->mm;
 	struct tsb_config *tp;
 
-	if (in_atomic() || !mm) {
+	if (faulthandler_disabled() || !mm) {
 		const struct exception_table_entry *entry;
 
 		entry = search_exception_tables(regs->tpc);
diff --git a/arch/tile/mm/fault.c b/arch/tile/mm/fault.c
index e83cc99..3f4f58d 100644
--- a/arch/tile/mm/fault.c
+++ b/arch/tile/mm/fault.c
@@ -354,9 +354,9 @@ static int handle_page_fault(struct pt_regs *regs,
 
 	/*
 	 * If we're in an interrupt, have no user context or are running in an
-	 * atomic region then we must not take the fault.
+	 * region with pagefaults disabled then we must not take the fault.
 	 */
-	if (in_atomic() || !mm) {
+	if (pagefault_disabled() || !mm) {
 		vma = NULL;  /* happy compiler */
 		goto bad_area_nosemaphore;
 	}
diff --git a/arch/um/kernel/trap.c b/arch/um/kernel/trap.c
index 8e4daf4..f9c9e5a 100644
--- a/arch/um/kernel/trap.c
+++ b/arch/um/kernel/trap.c
@@ -35,10 +35,10 @@ int handle_page_fault(unsigned long address, unsigned long ip,
 	*code_out = SEGV_MAPERR;
 
 	/*
-	 * If the fault was during atomic operation, don't take the fault, just
+	 * If the fault was with pagefaults disabled, don't take the fault, just
 	 * fail.
 	 */
-	if (in_atomic())
+	if (faulthandler_disabled())
 		goto out_nosemaphore;
 
 	if (is_user)
diff --git a/arch/unicore32/mm/fault.c b/arch/unicore32/mm/fault.c
index 0dc922d..afccef552 100644
--- a/arch/unicore32/mm/fault.c
+++ b/arch/unicore32/mm/fault.c
@@ -218,7 +218,7 @@ static int do_pf(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 	 * If we're in an interrupt or have no user
 	 * context, we must not take the fault..
 	 */
-	if (in_atomic() || !mm)
+	if (faulthandler_disabled() || !mm)
 		goto no_context;
 
 	if (user_mode(regs))
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 181c53b..9dc9098 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -13,6 +13,7 @@
 #include <linux/hugetlb.h>		/* hstate_index_to_shift	*/
 #include <linux/prefetch.h>		/* prefetchw			*/
 #include <linux/context_tracking.h>	/* exception_enter(), ...	*/
+#include <linux/uaccess.h>		/* faulthandler_disabled()	*/
 
 #include <asm/traps.h>			/* dotraplinkage, ...		*/
 #include <asm/pgalloc.h>		/* pgd_*(), ...			*/
@@ -1126,9 +1127,9 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 
 	/*
 	 * If we're in an interrupt, have no user context or are running
-	 * in an atomic region then we must not take the fault:
+	 * in a region with pagefaults disabled then we must not take the fault
 	 */
-	if (unlikely(in_atomic() || !mm)) {
+	if (unlikely(faulthandler_disabled() || !mm)) {
 		bad_area_nosemaphore(regs, error_code, address);
 		return;
 	}
diff --git a/arch/xtensa/mm/fault.c b/arch/xtensa/mm/fault.c
index 9e3571a..83a44a3 100644
--- a/arch/xtensa/mm/fault.c
+++ b/arch/xtensa/mm/fault.c
@@ -15,10 +15,10 @@
 #include <linux/mm.h>
 #include <linux/module.h>
 #include <linux/hardirq.h>
+#include <linux/uaccess.h>
 #include <asm/mmu_context.h>
 #include <asm/cacheflush.h>
 #include <asm/hardirq.h>
-#include <asm/uaccess.h>
 #include <asm/pgalloc.h>
 
 DEFINE_PER_CPU(unsigned long, asid_cache) = ASID_USER_FIRST;
@@ -57,7 +57,7 @@ void do_page_fault(struct pt_regs *regs)
 	/* If we're in an interrupt or have no user
 	 * context, we must not take the fault..
 	 */
-	if (in_atomic() || !mm) {
+	if (faulthandler_disabled() || !mm) {
 		bad_page_fault(regs, address, SIGSEGV);
 		return;
 	}
diff --git a/include/linux/uaccess.h b/include/linux/uaccess.h
index 23290cc..90786d2 100644
--- a/include/linux/uaccess.h
+++ b/include/linux/uaccess.h
@@ -59,6 +59,18 @@ static inline void pagefault_enable(void)
  */
 #define pagefault_disabled() (current->pagefault_disabled != 0)
 
+/*
+ * The pagefault handler is in general disabled by pagefault_disable() or
+ * when in irq context (via in_atomic()).
+ *
+ * This function should only be used by the fault handlers. Other users should
+ * stick to pagefault_disabled().
+ * Please NEVER use preempt_disable() to disable the fault handler. With
+ * !CONFIG_PREEMPT_COUNT, this is like a NOP. So the handler won't be disabled.
+ * in_atomic() will report different values based on !CONFIG_PREEMPT_COUNT.
+ */
+#define faulthandler_disabled() (pagefault_disabled() || in_atomic())
+
 #ifndef ARCH_HAS_NOCACHE_UACCESS
 
 static inline unsigned long __copy_from_user_inatomic_nocache(void *to,
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
