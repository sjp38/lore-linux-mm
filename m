Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id B926E6B0269
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 14:06:26 -0500 (EST)
Received: by pfnn128 with SMTP id n128so110000226pfn.0
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 11:06:26 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id mi6si8224405pab.95.2015.12.14.11.06.17
        for <linux-mm@kvack.org>;
        Mon, 14 Dec 2015 11:06:17 -0800 (PST)
Subject: [PATCH 20/32] x86, pkeys: differentiate instruction fetches
From: Dave Hansen <dave@sr71.net>
Date: Mon, 14 Dec 2015 11:06:16 -0800
References: <20151214190542.39C4886D@viggo.jf.intel.com>
In-Reply-To: <20151214190542.39C4886D@viggo.jf.intel.com>
Message-Id: <20151214190616.A3CB5832@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

As discussed earlier, we attempt to enforce protection keys in
software.

However, the code checks all faults to ensure that they are not
violating protection key permissions.  It was assumed that all
faults are either write faults where we check PKRU[key].WD (write
disable) or read faults where we check the AD (access disable)
bit.

But, there is a third category of faults for protection keys:
instruction faults.  Instruction faults never run afoul of
protection keys because they do not affect instruction fetches.

So, plumb the PF_INSTR bit down in to the
arch_vma_access_permitted() function where we do the protection
key checks.

We also add a new FAULT_FLAG_INSTRUCTION.  This is because
handle_mm_fault() is not passed the architecture-specific
error_code where we keep PF_INSTR, so we need to encode the
instruction fetch information in to the arch-generic fault
flags.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

---

 b/arch/powerpc/include/asm/mmu_context.h |    2 +-
 b/arch/s390/include/asm/mmu_context.h    |    2 +-
 b/arch/x86/include/asm/mmu_context.h     |    5 ++++-
 b/arch/x86/mm/fault.c                    |    8 ++++++--
 b/include/asm-generic/mm_hooks.h         |    2 +-
 b/include/linux/mm.h                     |    1 +
 b/mm/gup.c                               |   11 +++++++++--
 b/mm/memory.c                            |    1 +
 8 files changed, 24 insertions(+), 8 deletions(-)

diff -puN arch/powerpc/include/asm/mmu_context.h~pkeys-16-allow-execute-on-unreadable arch/powerpc/include/asm/mmu_context.h
--- a/arch/powerpc/include/asm/mmu_context.h~pkeys-16-allow-execute-on-unreadable	2015-12-14 10:42:47.794026685 -0800
+++ b/arch/powerpc/include/asm/mmu_context.h	2015-12-14 10:42:47.809027357 -0800
@@ -149,7 +149,7 @@ static inline void arch_bprm_mm_init(str
 }
 
 static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
-		bool write, bool foreign)
+		bool write, bool execute, bool foreign)
 {
 	/* by default, allow everything */
 	return true;
diff -puN arch/s390/include/asm/mmu_context.h~pkeys-16-allow-execute-on-unreadable arch/s390/include/asm/mmu_context.h
--- a/arch/s390/include/asm/mmu_context.h~pkeys-16-allow-execute-on-unreadable	2015-12-14 10:42:47.796026774 -0800
+++ b/arch/s390/include/asm/mmu_context.h	2015-12-14 10:42:47.809027357 -0800
@@ -131,7 +131,7 @@ static inline void arch_bprm_mm_init(str
 }
 
 static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
-		bool write, bool foreign)
+		bool write, bool execute, bool foreign)
 {
 	/* by default, allow everything */
 	return true;
diff -puN arch/x86/include/asm/mmu_context.h~pkeys-16-allow-execute-on-unreadable arch/x86/include/asm/mmu_context.h
--- a/arch/x86/include/asm/mmu_context.h~pkeys-16-allow-execute-on-unreadable	2015-12-14 10:42:47.797026819 -0800
+++ b/arch/x86/include/asm/mmu_context.h	2015-12-14 10:42:47.809027357 -0800
@@ -291,8 +291,11 @@ static inline bool vma_is_foreign(struct
 }
 
 static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
-		bool write, bool foreign)
+		bool write, bool execute, bool foreign)
 {
+	/* pkeys never affect instruction fetches */
+	if (execute)
+		return true;
 	/* allow access if the VMA is not one from this process */
 	if (foreign || vma_is_foreign(vma))
 		return true;
diff -puN arch/x86/mm/fault.c~pkeys-16-allow-execute-on-unreadable arch/x86/mm/fault.c
--- a/arch/x86/mm/fault.c~pkeys-16-allow-execute-on-unreadable	2015-12-14 10:42:47.799026909 -0800
+++ b/arch/x86/mm/fault.c	2015-12-14 10:42:47.810027402 -0800
@@ -908,7 +908,8 @@ static inline bool bad_area_access_from_
 	if (error_code & PF_PK)
 		return true;
 	/* this checks permission keys on the VMA: */
-	if (!arch_vma_access_permitted(vma, (error_code & PF_WRITE), foreign))
+	if (!arch_vma_access_permitted(vma, (error_code & PF_WRITE),
+				(error_code & PF_INSTR), foreign))
 		return true;
 	return false;
 }
@@ -1112,7 +1113,8 @@ access_error(unsigned long error_code, s
 	 * faults just to hit a PF_PK as soon as we fill in a
 	 * page.
 	 */
-	if (!arch_vma_access_permitted(vma, (error_code & PF_WRITE), foreign))
+	if (!arch_vma_access_permitted(vma, (error_code & PF_WRITE),
+				(error_code & PF_INSTR), foreign))
 		return 1;
 
 	if (error_code & PF_WRITE) {
@@ -1267,6 +1269,8 @@ __do_page_fault(struct pt_regs *regs, un
 
 	if (error_code & PF_WRITE)
 		flags |= FAULT_FLAG_WRITE;
+	if (error_code & PF_INSTR)
+		flags |= FAULT_FLAG_INSTRUCTION;
 
 	/*
 	 * When running in the kernel we expect faults to occur only to
diff -puN include/asm-generic/mm_hooks.h~pkeys-16-allow-execute-on-unreadable include/asm-generic/mm_hooks.h
--- a/include/asm-generic/mm_hooks.h~pkeys-16-allow-execute-on-unreadable	2015-12-14 10:42:47.801026998 -0800
+++ b/include/asm-generic/mm_hooks.h	2015-12-14 10:42:47.810027402 -0800
@@ -27,7 +27,7 @@ static inline void arch_bprm_mm_init(str
 }
 
 static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
-		bool write, bool foreign)
+		bool write, bool execute, bool foreign)
 {
 	/* by default, allow everything */
 	return true;
diff -puN include/linux/mm.h~pkeys-16-allow-execute-on-unreadable include/linux/mm.h
--- a/include/linux/mm.h~pkeys-16-allow-execute-on-unreadable	2015-12-14 10:42:47.802027043 -0800
+++ b/include/linux/mm.h	2015-12-14 10:42:47.811027447 -0800
@@ -238,6 +238,7 @@ extern pgprot_t protection_map[16];
 #define FAULT_FLAG_TRIED	0x20	/* Second try */
 #define FAULT_FLAG_USER		0x40	/* The fault originated in userspace */
 #define FAULT_FLAG_FOREIGN	0x80	/* faulting for non current tsk/mm */
+#define FAULT_FLAG_INSTRUCTION  0x100	/* The fault was during an instruction fetch */
 
 /*
  * vm_fault is filled by the the pagefault handler and passed to the vma's
diff -puN mm/gup.c~pkeys-16-allow-execute-on-unreadable mm/gup.c
--- a/mm/gup.c~pkeys-16-allow-execute-on-unreadable	2015-12-14 10:42:47.804027133 -0800
+++ b/mm/gup.c	2015-12-14 10:42:47.812027491 -0800
@@ -396,7 +396,11 @@ static int check_vma_flags(struct vm_are
 		if (!(vm_flags & VM_MAYREAD))
 			return -EFAULT;
 	}
-	if (!arch_vma_access_permitted(vma, write, foreign))
+	/*
+	 * gups are always data accesses, not instruction
+	 * fetches, so execute=false here
+	 */
+	if (!arch_vma_access_permitted(vma, write, false, foreign))
 		return -EFAULT;
 	return 0;
 }
@@ -576,8 +580,11 @@ bool vma_permits_fault(struct vm_area_st
 	/*
 	 * The architecture might have a hardware protection
 	 * mechanism other than read/write that can deny access.
+	 *
+	 * gup always represents data access, not instruction
+	 * fetches, so execute=false here:
 	 */
-	if (!arch_vma_access_permitted(vma, write, foreign))
+	if (!arch_vma_access_permitted(vma, write, false, foreign))
 		return false;
 
 	return true;
diff -puN mm/memory.c~pkeys-16-allow-execute-on-unreadable mm/memory.c
--- a/mm/memory.c~pkeys-16-allow-execute-on-unreadable	2015-12-14 10:42:47.806027223 -0800
+++ b/mm/memory.c	2015-12-14 10:42:47.813027536 -0800
@@ -3346,6 +3346,7 @@ static int __handle_mm_fault(struct mm_s
 	pte_t *pte;
 
 	if (!arch_vma_access_permitted(vma, flags & FAULT_FLAG_WRITE,
+					    flags & FAULT_FLAG_INSTRUCTION,
 					    flags & FAULT_FLAG_FOREIGN))
 		return VM_FAULT_SIGSEGV;
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
