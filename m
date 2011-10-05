Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id A9590900149
	for <linux-mm@kvack.org>; Wed,  5 Oct 2011 09:09:35 -0400 (EDT)
Subject: [PATCH] mm, arch: Complete pagefault_disable abstraction
From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 05 Oct 2011 15:09:29 +0200
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1317820169.6766.20.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>

Subject: mm, arch: Complete pagefault_disable abstraction
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed Oct 05 14:22:37 CEST 2011

Currently we already have pagefault_{disable,enable}() but they're
nothing more than a glorified preempt_{disable,enable}().

For -rt we want to make pagefault_disable() regions preemptible and
for that we need to complete the abstraction, replace the current
in_atomic() tests that are relevant to pagefault_disable() usage with
pagefault_disabled().

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/alpha/mm/fault.c      |    2 +-
 arch/arm/mm/fault.c        |    2 +-
 arch/avr32/mm/fault.c      |    2 +-
 arch/cris/mm/fault.c       |    2 +-
 arch/frv/mm/fault.c        |    2 +-
 arch/ia64/mm/fault.c       |    2 +-
 arch/m32r/mm/fault.c       |    2 +-
 arch/m68k/mm/fault.c       |    2 +-
 arch/microblaze/mm/fault.c |    2 +-
 arch/mips/mm/fault.c       |    2 +-
 arch/mn10300/mm/fault.c    |    2 +-
 arch/parisc/mm/fault.c     |    2 +-
 arch/powerpc/mm/fault.c    |    2 +-
 arch/s390/mm/fault.c       |    6 ++++--
 arch/score/mm/fault.c      |    2 +-
 arch/sh/mm/fault_32.c      |    2 +-
 arch/sparc/mm/fault_32.c   |    4 ++--
 arch/sparc/mm/fault_64.c   |    2 +-
 arch/tile/mm/fault.c       |    2 +-
 arch/um/kernel/trap.c      |    2 +-
 arch/unicore32/mm/fault.c  |    2 +-
 arch/x86/mm/fault.c        |    2 +-
 arch/xtensa/mm/fault.c     |    2 +-
 include/linux/sched.h      |    6 ++++++
 mm/filemap.c               |    2 +-
 25 files changed, 34 insertions(+), 26 deletions(-)

Index: linux-2.6/arch/alpha/mm/fault.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/alpha/mm/fault.c
+++ linux-2.6/arch/alpha/mm/fault.c
@@ -107,7 +107,7 @@ do_page_fault(unsigned long address, uns
=20
 	/* If we're in an interrupt context, or have no user context,
 	   we must not take the fault.  */
-	if (!mm || in_atomic())
+	if (!mm || pagefault_disabled())
 		goto no_context;
=20
 #ifdef CONFIG_ALPHA_LARGE_VMALLOC
Index: linux-2.6/arch/arm/mm/fault.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/arm/mm/fault.c
+++ linux-2.6/arch/arm/mm/fault.c
@@ -293,7 +293,7 @@ do_page_fault(unsigned long addr, unsign
 	 * If we're in an interrupt or have no user
 	 * context, we must not take the fault..
 	 */
-	if (in_atomic() || !mm)
+	if (!mm || pagefault_disabled())
 		goto no_context;
=20
 	/*
Index: linux-2.6/arch/avr32/mm/fault.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/avr32/mm/fault.c
+++ linux-2.6/arch/avr32/mm/fault.c
@@ -81,7 +81,7 @@ asmlinkage void do_page_fault(unsigned l
 	 * If we're in an interrupt or have no user context, we must
 	 * not take the fault...
 	 */
-	if (in_atomic() || !mm || regs->sr & SYSREG_BIT(GM))
+	if (!mm || regs->sr & SYSREG_BIT(GM) || pagefault_disabled())
 		goto no_context;
=20
 	local_irq_enable();
Index: linux-2.6/arch/cris/mm/fault.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/cris/mm/fault.c
+++ linux-2.6/arch/cris/mm/fault.c
@@ -111,7 +111,7 @@ do_page_fault(unsigned long address, str
 	 * user context, we must not take the fault.
 	 */
=20
-	if (in_atomic() || !mm)
+	if (!mm || pagefault_disabled())
 		goto no_context;
=20
 	down_read(&mm->mmap_sem);
Index: linux-2.6/arch/frv/mm/fault.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/frv/mm/fault.c
+++ linux-2.6/arch/frv/mm/fault.c
@@ -79,7 +79,7 @@ asmlinkage void do_page_fault(int datamm
 	 * If we're in an interrupt or have no user
 	 * context, we must not take the fault..
 	 */
-	if (in_atomic() || !mm)
+	if (!mm || pagefault_disabled())
 		goto no_context;
=20
 	down_read(&mm->mmap_sem);
Index: linux-2.6/arch/ia64/mm/fault.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/ia64/mm/fault.c
+++ linux-2.6/arch/ia64/mm/fault.c
@@ -89,7 +89,7 @@ ia64_do_page_fault (unsigned long addres
 	/*
 	 * If we're in an interrupt or have no user context, we must not take the=
 fault..
 	 */
-	if (in_atomic() || !mm)
+	if (!mm || pagefault_disabled())
 		goto no_context;
=20
 #ifdef CONFIG_VIRTUAL_MEM_MAP
Index: linux-2.6/arch/m32r/mm/fault.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/m32r/mm/fault.c
+++ linux-2.6/arch/m32r/mm/fault.c
@@ -115,7 +115,7 @@ asmlinkage void do_page_fault(struct pt_
 	 * If we're in an interrupt or have no user context or are running in an
 	 * atomic region then we must not take the fault..
 	 */
-	if (in_atomic() || !mm)
+	if (!mm || pagefault_disabled())
 		goto bad_area_nosemaphore;
=20
 	/* When running in the kernel we expect faults to occur only to
Index: linux-2.6/arch/m68k/mm/fault.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/m68k/mm/fault.c
+++ linux-2.6/arch/m68k/mm/fault.c
@@ -85,7 +85,7 @@ int do_page_fault(struct pt_regs *regs,
 	 * If we're in an interrupt or have no user
 	 * context, we must not take the fault..
 	 */
-	if (in_atomic() || !mm)
+	if (!mm || pagefault_disabled())
 		goto no_context;
=20
 	down_read(&mm->mmap_sem);
Index: linux-2.6/arch/microblaze/mm/fault.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/microblaze/mm/fault.c
+++ linux-2.6/arch/microblaze/mm/fault.c
@@ -107,7 +107,7 @@ void do_page_fault(struct pt_regs *regs,
 	if ((error_code & 0x13) =3D=3D 0x13 || (error_code & 0x11) =3D=3D 0x11)
 		is_write =3D 0;
=20
-	if (unlikely(in_atomic() || !mm)) {
+	if (unlikely(!mm || pagefault_disabled())) {
 		if (kernel_mode(regs))
 			goto bad_area_nosemaphore;
=20
Index: linux-2.6/arch/mips/mm/fault.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/mips/mm/fault.c
+++ linux-2.6/arch/mips/mm/fault.c
@@ -88,7 +88,7 @@ asmlinkage void __kprobes do_page_fault(
 	 * If we're in an interrupt or have no user
 	 * context, we must not take the fault..
 	 */
-	if (in_atomic() || !mm)
+	if (!mm || pagefault_disabled())
 		goto bad_area_nosemaphore;
=20
 	down_read(&mm->mmap_sem);
Index: linux-2.6/arch/mn10300/mm/fault.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/mn10300/mm/fault.c
+++ linux-2.6/arch/mn10300/mm/fault.c
@@ -168,7 +168,7 @@ asmlinkage void do_page_fault(struct pt_
 	 * If we're in an interrupt or have no user
 	 * context, we must not take the fault..
 	 */
-	if (in_atomic() || !mm)
+	if (!mm || pagefault_disabled())
 		goto no_context;
=20
 	down_read(&mm->mmap_sem);
Index: linux-2.6/arch/parisc/mm/fault.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/parisc/mm/fault.c
+++ linux-2.6/arch/parisc/mm/fault.c
@@ -176,7 +176,7 @@ void do_page_fault(struct pt_regs *regs,
 	unsigned long acc_type;
 	int fault;
=20
-	if (in_atomic() || !mm)
+	if (!mm || pagefault_disabled())
 		goto no_context;
=20
 	down_read(&mm->mmap_sem);
Index: linux-2.6/arch/powerpc/mm/fault.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/powerpc/mm/fault.c
+++ linux-2.6/arch/powerpc/mm/fault.c
@@ -162,7 +162,7 @@ int __kprobes do_page_fault(struct pt_re
 	}
 #endif
=20
-	if (in_atomic() || mm =3D=3D NULL) {
+	if (!mm || pagefault_disabled()) {
 		if (!user_mode(regs))
 			return SIGSEGV;
 		/* in_atomic() in user mode is really bad,
Index: linux-2.6/arch/s390/mm/fault.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/s390/mm/fault.c
+++ linux-2.6/arch/s390/mm/fault.c
@@ -295,7 +295,8 @@ static inline int do_exception(struct pt
 	 * user context.
 	 */
 	fault =3D VM_FAULT_BADCONTEXT;
-	if (unlikely(!user_space_fault(trans_exc_code) || in_atomic() || !mm))
+	if (unlikely(!user_space_fault(trans_exc_code) ||
+		     !mm || pagefault_disabled()))
 		goto out;
=20
 	address =3D trans_exc_code & __FAIL_ADDR_MASK;
@@ -426,7 +427,8 @@ void __kprobes do_asce_exception(struct
 	struct mm_struct *mm =3D current->mm;
 	struct vm_area_struct *vma;
=20
-	if (unlikely(!user_space_fault(trans_exc_code) || in_atomic() || !mm))
+	if (unlikely(!user_space_fault(trans_exc_code) ||
+		     !mm || pagefault_disabled()))
 		goto no_context;
=20
 	down_read(&mm->mmap_sem);
Index: linux-2.6/arch/score/mm/fault.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/score/mm/fault.c
+++ linux-2.6/arch/score/mm/fault.c
@@ -72,7 +72,7 @@ asmlinkage void do_page_fault(struct pt_
 	* If we're in an interrupt or have no user
 	* context, we must not take the fault..
 	*/
-	if (in_atomic() || !mm)
+	if (!mm || pagefault_disabled())
 		goto bad_area_nosemaphore;
=20
 	down_read(&mm->mmap_sem);
Index: linux-2.6/arch/sh/mm/fault_32.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/sh/mm/fault_32.c
+++ linux-2.6/arch/sh/mm/fault_32.c
@@ -166,7 +166,7 @@ asmlinkage void __kprobes do_page_fault(
 	 * If we're in an interrupt, have no user context or are running
 	 * in an atomic region then we must not take the fault:
 	 */
-	if (in_atomic() || !mm)
+	if (!mm || pagefault_disabled())
 		goto no_context;
=20
 	down_read(&mm->mmap_sem);
Index: linux-2.6/arch/sparc/mm/fault_32.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/sparc/mm/fault_32.c
+++ linux-2.6/arch/sparc/mm/fault_32.c
@@ -248,8 +248,8 @@ asmlinkage void do_sparc_fault(struct pt
 	 * If we're in an interrupt or have no user
 	 * context, we must not take the fault..
 	 */
-        if (in_atomic() || !mm)
-                goto no_context;
+	if (!mm || pagefault_disabled())
+		goto no_context;
=20
 	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, address);
=20
Index: linux-2.6/arch/sparc/mm/fault_64.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/sparc/mm/fault_64.c
+++ linux-2.6/arch/sparc/mm/fault_64.c
@@ -322,7 +322,7 @@ asmlinkage void __kprobes do_sparc64_fau
 	 * If we're in an interrupt or have no user
 	 * context, we must not take the fault..
 	 */
-	if (in_atomic() || !mm)
+	if (!mm || pagefault_disabled())
 		goto intr_or_no_mm;
=20
 	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, address);
Index: linux-2.6/arch/tile/mm/fault.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/tile/mm/fault.c
+++ linux-2.6/arch/tile/mm/fault.c
@@ -346,7 +346,7 @@ static int handle_page_fault(struct pt_r
 	 * If we're in an interrupt, have no user context or are running in an
 	 * atomic region then we must not take the fault.
 	 */
-	if (in_atomic() || !mm) {
+	if (!mm || pagefault_disabled()) {
 		vma =3D NULL;  /* happy compiler */
 		goto bad_area_nosemaphore;
 	}
Index: linux-2.6/arch/um/kernel/trap.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/um/kernel/trap.c
+++ linux-2.6/arch/um/kernel/trap.c
@@ -37,7 +37,7 @@ int handle_page_fault(unsigned long addr
 	 * If the fault was during atomic operation, don't take the fault, just
 	 * fail.
 	 */
-	if (in_atomic())
+	if (!mm || pagefault_disabled())
 		goto out_nosemaphore;
=20
 	down_read(&mm->mmap_sem);
Index: linux-2.6/arch/unicore32/mm/fault.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/unicore32/mm/fault.c
+++ linux-2.6/arch/unicore32/mm/fault.c
@@ -225,7 +225,7 @@ static int do_pf(unsigned long addr, uns
 	 * If we're in an interrupt or have no user
 	 * context, we must not take the fault..
 	 */
-	if (in_atomic() || !mm)
+	if (!mm || pagefault_disabled())
 		goto no_context;
=20
 	/*
Index: linux-2.6/arch/x86/mm/fault.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/x86/mm/fault.c
+++ linux-2.6/arch/x86/mm/fault.c
@@ -1084,7 +1084,7 @@ do_page_fault(struct pt_regs *regs, unsi
 	 * If we're in an interrupt, have no user context or are running
 	 * in an atomic region then we must not take the fault:
 	 */
-	if (unlikely(in_atomic() || !mm)) {
+	if (unlikely(!mm || pagefault_disabled())) {
 		bad_area_nosemaphore(regs, error_code, address);
 		return;
 	}
Index: linux-2.6/arch/xtensa/mm/fault.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/xtensa/mm/fault.c
+++ linux-2.6/arch/xtensa/mm/fault.c
@@ -57,7 +57,7 @@ void do_page_fault(struct pt_regs *regs)
 	/* If we're in an interrupt or have no user
 	 * context, we must not take the fault..
 	 */
-	if (in_atomic() || !mm) {
+	if (!mm || pagefault_disabled()) {
 		bad_page_fault(regs, address, SIGSEGV);
 		return;
 	}
Index: linux-2.6/include/linux/sched.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/include/linux/sched.h
+++ linux-2.6/include/linux/sched.h
@@ -91,6 +91,7 @@ struct sched_param {
 #include <linux/latencytop.h>
 #include <linux/cred.h>
 #include <linux/llist.h>
+#include <linux/hardirq.h>
=20
 #include <asm/processor.h>
=20
@@ -1575,6 +1576,11 @@ struct task_struct {
 /* Future-safe accessor for struct task_struct's cpus_allowed. */
 #define tsk_cpus_allowed(tsk) (&(tsk)->cpus_allowed)
=20
+static inline bool pagefault_disabled(void)
+{
+	return in_atomic();
+}
+
 /*
  * Priority of a process goes from 0..MAX_PRIO-1, valid RT
  * priority is 0..MAX_RT_PRIO-1, and SCHED_NORMAL/SCHED_BATCH
Index: linux-2.6/mm/filemap.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -2061,7 +2061,7 @@ size_t iov_iter_copy_from_user_atomic(st
 	char *kaddr;
 	size_t copied;
=20
-	BUG_ON(!in_atomic());
+	BUG_ON(!pagefault_disabled());
 	kaddr =3D kmap_atomic(page, KM_USER0);
 	if (likely(i->nr_segs =3D=3D 1)) {
 		int left;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
