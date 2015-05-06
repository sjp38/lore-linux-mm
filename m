Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id ECF596B0072
	for <linux-mm@kvack.org>; Wed,  6 May 2015 13:51:00 -0400 (EDT)
Received: by wiun10 with SMTP id n10so31568841wiu.1
        for <linux-mm@kvack.org>; Wed, 06 May 2015 10:51:00 -0700 (PDT)
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com. [195.75.94.108])
        by mx.google.com with ESMTPS id a9si3375469wie.64.2015.05.06.10.50.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Wed, 06 May 2015 10:50:50 -0700 (PDT)
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dahi@linux.vnet.ibm.com>;
	Wed, 6 May 2015 18:50:48 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 85A2B17D8042
	for <linux-mm@kvack.org>; Wed,  6 May 2015 18:51:32 +0100 (BST)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t46HolBR57999586
	for <linux-mm@kvack.org>; Wed, 6 May 2015 17:50:47 GMT
Received: from d06av05.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t46Hoj0b027634
	for <linux-mm@kvack.org>; Wed, 6 May 2015 11:50:47 -0600
From: David Hildenbrand <dahi@linux.vnet.ibm.com>
Subject: [PATCH RFC 06/15] mm: use pagefault_disabled() to check for disabled pagefaults
Date: Wed,  6 May 2015 19:50:30 +0200
Message-Id: <1430934639-2131-7-git-send-email-dahi@linux.vnet.ibm.com>
In-Reply-To: <1430934639-2131-1-git-send-email-dahi@linux.vnet.ibm.com>
References: <1430934639-2131-1-git-send-email-dahi@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: dahi@linux.vnet.ibm.com, mingo@redhat.com, peterz@infradead.org, yang.shi@windriver.com, bigeasy@linutronix.de, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, borntraeger@de.ibm.com, mst@redhat.com, tglx@linutronix.de, David.Laight@ACULAB.COM, hughd@google.com, hocko@suse.cz, ralf@linux-mips.org, herbert@gondor.apana.org.au, linux@arm.linux.org.uk, airlied@linux.ie, daniel.vetter@intel.com, linux-mm@kvack.org, linux-arch@vger.kernel.org

Now that the pagefault disabled counter is in place, we can replace
the in_atomic() checks by pagefault_disabled() checks.

If a fault happens while in_atomic(), it can only be a bug in the code.
Either a pagefault_disable() call is missing or the specific *in_atomic()
variants of uaccess should have been used. That's what might_fault()
checks when calling might_sleep().

pagefault_disable() is defined in linux/uaccess.h, so let's properly
add that include to all relevant files.

This patch is based on a patch from Thomas Gleixner.

Signed-off-by: David Hildenbrand <dahi@linux.vnet.ibm.com>
---
 arch/alpha/mm/fault.c      | 5 ++---
 arch/arc/mm/fault.c        | 2 +-
 arch/arm/mm/fault.c        | 2 +-
 arch/arm64/mm/fault.c      | 2 +-
 arch/avr32/mm/fault.c      | 4 ++--
 arch/cris/mm/fault.c       | 4 ++--
 arch/frv/mm/fault.c        | 4 ++--
 arch/ia64/mm/fault.c       | 4 ++--
 arch/m32r/mm/fault.c       | 4 ++--
 arch/m68k/mm/fault.c       | 4 ++--
 arch/metag/mm/fault.c      | 2 +-
 arch/microblaze/mm/fault.c | 6 +++---
 arch/mips/mm/fault.c       | 4 ++--
 arch/mn10300/mm/fault.c    | 4 ++--
 arch/nios2/mm/fault.c      | 2 +-
 arch/parisc/kernel/traps.c | 4 ++--
 arch/parisc/mm/fault.c     | 4 ++--
 arch/powerpc/mm/fault.c    | 9 +++++----
 arch/s390/mm/fault.c       | 2 +-
 arch/score/mm/fault.c      | 3 ++-
 arch/sh/mm/fault.c         | 3 ++-
 arch/sparc/mm/fault_32.c   | 4 ++--
 arch/sparc/mm/fault_64.c   | 4 ++--
 arch/sparc/mm/init_64.c    | 2 +-
 arch/tile/mm/fault.c       | 4 ++--
 arch/um/kernel/trap.c      | 4 ++--
 arch/unicore32/mm/fault.c  | 2 +-
 arch/x86/mm/fault.c        | 5 +++--
 arch/xtensa/mm/fault.c     | 4 ++--
 29 files changed, 55 insertions(+), 52 deletions(-)

diff --git a/arch/alpha/mm/fault.c b/arch/alpha/mm/fault.c
index 9d0ac09..f702a27 100644
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
+	if (!mm || pagefault_disabled())
 		goto no_context;
 
 #ifdef CONFIG_ALPHA_LARGE_VMALLOC
diff --git a/arch/arc/mm/fault.c b/arch/arc/mm/fault.c
index 6a2e006..2f632a0 100644
--- a/arch/arc/mm/fault.c
+++ b/arch/arc/mm/fault.c
@@ -86,7 +86,7 @@ void do_page_fault(unsigned long address, struct pt_regs *regs)
 	 * If we're in an interrupt or have no user
 	 * context, we must not take the fault..
 	 */
-	if (in_atomic() || !mm)
+	if (pagefault_disabled() || !mm)
 		goto no_context;
 
 	if (user_mode(regs))
diff --git a/arch/arm/mm/fault.c b/arch/arm/mm/fault.c
index 6333d9c..841a1b6 100644
--- a/arch/arm/mm/fault.c
+++ b/arch/arm/mm/fault.c
@@ -276,7 +276,7 @@ do_page_fault(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 	 * If we're in an interrupt or have no user
 	 * context, we must not take the fault..
 	 */
-	if (in_atomic() || !mm)
+	if (pagefault_disabled() || !mm)
 		goto no_context;
 
 	if (user_mode(regs))
diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
index 96da131..d93c129 100644
--- a/arch/arm64/mm/fault.c
+++ b/arch/arm64/mm/fault.c
@@ -211,7 +211,7 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
 	 * If we're in an interrupt or have no user context, we must not take
 	 * the fault.
 	 */
-	if (in_atomic() || !mm)
+	if (pagefault_disabled() || !mm)
 		goto no_context;
 
 	if (user_mode(regs))
diff --git a/arch/avr32/mm/fault.c b/arch/avr32/mm/fault.c
index d223a8b..09f7ced 100644
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
+	if (pagefault_disabled() || !mm || regs->sr & SYSREG_BIT(GM))
 		goto no_context;
 
 	local_irq_enable();
diff --git a/arch/cris/mm/fault.c b/arch/cris/mm/fault.c
index 83f12f2..41f83a7 100644
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
@@ -113,7 +113,7 @@ do_page_fault(unsigned long address, struct pt_regs *regs,
 	 * user context, we must not take the fault.
 	 */
 
-	if (in_atomic() || !mm)
+	if (pagefault_disabled() || !mm)
 		goto no_context;
 
 	if (user_mode(regs))
diff --git a/arch/frv/mm/fault.c b/arch/frv/mm/fault.c
index ec4917d..d1f67d1 100644
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
+	if (pagefault_disabled() || !mm)
 		goto no_context;
 
 	if (user_mode(__frame))
diff --git a/arch/ia64/mm/fault.c b/arch/ia64/mm/fault.c
index ba5ba7a..5a636aa 100644
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
+	if (pagefault_disabled() || !mm)
 		goto no_context;
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
diff --git a/arch/m32r/mm/fault.c b/arch/m32r/mm/fault.c
index e3d4d48901..4e1892e 100644
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
@@ -114,7 +114,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long error_code,
 	 * If we're in an interrupt or have no user context or are running in an
 	 * atomic region then we must not take the fault..
 	 */
-	if (in_atomic() || !mm)
+	if (pagefault_disabled() || !mm)
 		goto bad_area_nosemaphore;
 
 	if (error_code & ACE_USERMODE)
diff --git a/arch/m68k/mm/fault.c b/arch/m68k/mm/fault.c
index b2f04ae..156309b0 100644
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
+	if (pagefault_disabled() || !mm)
 		goto no_context;
 
 	if (user_mode(regs))
diff --git a/arch/metag/mm/fault.c b/arch/metag/mm/fault.c
index 2de5dc6..713700d 100644
--- a/arch/metag/mm/fault.c
+++ b/arch/metag/mm/fault.c
@@ -105,7 +105,7 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 
 	mm = tsk->mm;
 
-	if (in_atomic() || !mm)
+	if (pagefault_disabled() || !mm)
 		goto no_context;
 
 	if (user_mode(regs))
diff --git a/arch/microblaze/mm/fault.c b/arch/microblaze/mm/fault.c
index d46a5eb..6a75a42 100644
--- a/arch/microblaze/mm/fault.c
+++ b/arch/microblaze/mm/fault.c
@@ -107,13 +107,13 @@ void do_page_fault(struct pt_regs *regs, unsigned long address,
 	if ((error_code & 0x13) == 0x13 || (error_code & 0x11) == 0x11)
 		is_write = 0;
 
-	if (unlikely(in_atomic() || !mm)) {
+	if (unlikely(pagefault_disabled() || !mm)) {
 		if (kernel_mode(regs))
 			goto bad_area_nosemaphore;
 
-		/* in_atomic() in user mode is really bad,
+		/* pagefault_disabled() in user mode is really bad,
 		   as is current->mm == NULL. */
-		pr_emerg("Page fault in user mode with in_atomic(), mm = %p\n",
+		pr_emerg("Page fault in user mode with pagefault_disabled(), mm = %p\n",
 									mm);
 		pr_emerg("r15 = %lx  MSR = %lx\n",
 		       regs->r15, regs->msr);
diff --git a/arch/mips/mm/fault.c b/arch/mips/mm/fault.c
index 7ff8637..ccba212 100644
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
+	if (pagefault_disabled() || !mm)
 		goto bad_area_nosemaphore;
 
 	if (user_mode(regs))
diff --git a/arch/mn10300/mm/fault.c b/arch/mn10300/mm/fault.c
index 0c2cc5d..1d441a8 100644
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
+	if (pagefault_disabled() || !mm)
 		goto no_context;
 
 	if ((fault_code & MMUFCR_xFC_ACCESS) == MMUFCR_xFC_ACCESS_USR)
diff --git a/arch/nios2/mm/fault.c b/arch/nios2/mm/fault.c
index 0c9b6af..fdae091 100644
--- a/arch/nios2/mm/fault.c
+++ b/arch/nios2/mm/fault.c
@@ -77,7 +77,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long cause,
 	 * If we're in an interrupt or have no user
 	 * context, we must not take the fault..
 	 */
-	if (in_atomic() || !mm)
+	if (pagefault_disabled() || !mm)
 		goto bad_area_nosemaphore;
 
 	if (user_mode(regs))
diff --git a/arch/parisc/kernel/traps.c b/arch/parisc/kernel/traps.c
index 47ee620..e72483c 100644
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
+	    if (fault_space == 0 && !pagefault_disabled())
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
index b396868..04658b5 100644
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
+	if (pagefault_disabled() || mm == NULL) {
 		if (!user_mode(regs)) {
 			rc = SIGSEGV;
 			goto bail;
 		}
-		/* in_atomic() in user mode is really bad,
+		/* pagefault_disabled() in user mode is really bad,
 		   as is current->mm == NULL. */
 		printk(KERN_EMERG "Page fault in user mode with "
-		       "in_atomic() = %d mm = %p\n", in_atomic(), mm);
+		       "pagefault_disabled() = %d mm = %p\n",
+		       pagefault_disabled(), mm);
 		printk(KERN_EMERG "NIP = %lx  MSR = %lx\n",
 		       regs->nip, regs->msr);
 		die("Weird page fault", regs, SIGSEGV);
diff --git a/arch/s390/mm/fault.c b/arch/s390/mm/fault.c
index 76515bc..a3dcc10 100644
--- a/arch/s390/mm/fault.c
+++ b/arch/s390/mm/fault.c
@@ -399,7 +399,7 @@ static inline int do_exception(struct pt_regs *regs, int access)
 	 * user context.
 	 */
 	fault = VM_FAULT_BADCONTEXT;
-	if (unlikely(!user_space_fault(regs) || in_atomic() || !mm))
+	if (unlikely(!user_space_fault(regs) || pagefault_disabled() || !mm))
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
index a58fec9..f7a83a9 100644
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
@@ -440,7 +441,7 @@ asmlinkage void __kprobes do_page_fault(struct pt_regs *regs,
 	 * If we're in an interrupt, have no user context or are running
 	 * in an atomic region then we must not take the fault:
 	 */
-	if (unlikely(in_atomic() || !mm)) {
+	if (unlikely(pagefault_disabled() || !mm)) {
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
index 4798232..0ff9e50 100644
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
+	if (pagefault_disabled() || !mm)
 		goto intr_or_no_mm;
 
 	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, address);
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index 4ca0d6b..795ea96 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -2706,7 +2706,7 @@ void hugetlb_setup(struct pt_regs *regs)
 	struct mm_struct *mm = current->mm;
 	struct tsb_config *tp;
 
-	if (in_atomic() || !mm) {
+	if (pagefault_disabled() || !mm) {
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
index 8e4daf4..7317c87 100644
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
+	if (pagefault_disabled())
 		goto out_nosemaphore;
 
 	if (is_user)
diff --git a/arch/unicore32/mm/fault.c b/arch/unicore32/mm/fault.c
index 0dc922d..b3cf385 100644
--- a/arch/unicore32/mm/fault.c
+++ b/arch/unicore32/mm/fault.c
@@ -218,7 +218,7 @@ static int do_pf(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 	 * If we're in an interrupt or have no user
 	 * context, we must not take the fault..
 	 */
-	if (in_atomic() || !mm)
+	if (pagefault_disabled() || !mm)
 		goto no_context;
 
 	if (user_mode(regs))
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 181c53b..be394b1 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -13,6 +13,7 @@
 #include <linux/hugetlb.h>		/* hstate_index_to_shift	*/
 #include <linux/prefetch.h>		/* prefetchw			*/
 #include <linux/context_tracking.h>	/* exception_enter(), ...	*/
+#include <linux/uaccess.h>		/* pagefault_disabled()		*/
 
 #include <asm/traps.h>			/* dotraplinkage, ...		*/
 #include <asm/pgalloc.h>		/* pgd_*(), ...			*/
@@ -1126,9 +1127,9 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 
 	/*
 	 * If we're in an interrupt, have no user context or are running
-	 * in an atomic region then we must not take the fault:
+	 * in a region with pagefaults disabled then we must not take the fault
 	 */
-	if (unlikely(in_atomic() || !mm)) {
+	if (unlikely(pagefault_disabled() || !mm)) {
 		bad_area_nosemaphore(regs, error_code, address);
 		return;
 	}
diff --git a/arch/xtensa/mm/fault.c b/arch/xtensa/mm/fault.c
index 9e3571a..99ba449 100644
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
+	if (pagefault_disabled() || !mm) {
 		bad_page_fault(regs, address, SIGSEGV);
 		return;
 	}
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
