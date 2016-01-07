Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 6FB6F828DE
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 19:08:08 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id do7so5957480pab.2
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 16:08:08 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id dz4si51415275pab.235.2016.01.06.16.01.33
        for <linux-mm@kvack.org>;
        Wed, 06 Jan 2016 16:01:34 -0800 (PST)
Subject: [PATCH 20/31] x86, pkeys: differentiate instruction fetches
From: Dave Hansen <dave@sr71.net>
Date: Wed, 06 Jan 2016 16:01:33 -0800
References: <20160107000104.1A105322@viggo.jf.intel.com>
In-Reply-To: <20160107000104.1A105322@viggo.jf.intel.com>
Message-Id: <20160107000133.45294541@viggo.jf.intel.com>
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
--- a/arch/powerpc/include/asm/mmu_context.h~pkeys-16-allow-execute-on-unreadable	2016-01-06 15:50:11.677429524 -0800
+++ b/arch/powerpc/include/asm/mmu_context.h	2016-01-06 15:50:11.692430200 -0800
@@ -149,7 +149,7 @@ static inline void arch_bprm_mm_init(str
 }
 
 static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
-		bool write, bool foreign)
+		bool write, bool execute, bool foreign)
 {
 	/* by default, allow everything */
 	return true;
diff -puN arch/s390/include/asm/mmu_context.h~pkeys-16-allow-execute-on-unreadable arch/s390/include/asm/mmu_context.h
--- a/arch/s390/include/asm/mmu_context.h~pkeys-16-allow-execute-on-unreadable	2016-01-06 15:50:11.679429614 -0800
+++ b/arch/s390/include/asm/mmu_context.h	2016-01-06 15:50:11.692430200 -0800
@@ -131,7 +131,7 @@ static inline void arch_bprm_mm_init(str
 }
 
 static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
-		bool write, bool foreign)
+		bool write, bool execute, bool foreign)
 {
 	/* by default, allow everything */
 	return true;
diff -puN arch/x86/include/asm/mmu_context.h~pkeys-16-allow-execute-on-unreadable arch/x86/include/asm/mmu_context.h
--- a/arch/x86/include/asm/mmu_context.h~pkeys-16-allow-execute-on-unreadable	2016-01-06 15:50:11.681429704 -0800
+++ b/arch/x86/include/asm/mmu_context.h	2016-01-06 15:50:11.693430245 -0800
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
--- a/arch/x86/mm/fault.c~pkeys-16-allow-execute-on-unreadable	2016-01-06 15:50:11.682429749 -0800
+++ b/arch/x86/mm/fault.c	2016-01-06 15:50:11.693430245 -0800
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
--- a/include/asm-generic/mm_hooks.h~pkeys-16-allow-execute-on-unreadable	2016-01-06 15:50:11.684429839 -0800
+++ b/include/asm-generic/mm_hooks.h	2016-01-06 15:50:11.694430290 -0800
@@ -27,7 +27,7 @@ static inline void arch_bprm_mm_init(str
 }
 
 static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
-		bool write, bool foreign)
+		bool write, bool execute, bool foreign)
 {
 	/* by default, allow everything */
 	return true;
diff -puN include/linux/mm.h~pkeys-16-allow-execute-on-unreadable include/linux/mm.h
--- a/include/linux/mm.h~pkeys-16-allow-execute-on-unreadable	2016-01-06 15:50:11.685429885 -0800
+++ b/include/linux/mm.h	2016-01-06 15:50:11.695430335 -0800
@@ -238,6 +238,7 @@ extern pgprot_t protection_map[16];
 #define FAULT_FLAG_TRIED	0x20	/* Second try */
 #define FAULT_FLAG_USER		0x40	/* The fault originated in userspace */
 #define FAULT_FLAG_FOREIGN	0x80	/* faulting for non current tsk/mm */
+#define FAULT_FLAG_INSTRUCTION  0x100	/* The fault was during an instruction fetch */
 
 /*
  * vm_fault is filled by the the pagefault handler and passed to the vma's
diff -puN mm/gup.c~pkeys-16-allow-execute-on-unreadable mm/gup.c
--- a/mm/gup.c~pkeys-16-allow-execute-on-unreadable	2016-01-06 15:50:11.687429975 -0800
+++ b/mm/gup.c	2016-01-06 15:50:11.695430335 -0800
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
--- a/mm/memory.c~pkeys-16-allow-execute-on-unreadable	2016-01-06 15:50:11.689430065 -0800
+++ b/mm/memory.c	2016-01-06 15:50:11.696430380 -0800
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
