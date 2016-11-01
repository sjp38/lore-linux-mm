Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7BCF26B02AE
	for <linux-mm@kvack.org>; Tue,  1 Nov 2016 13:11:21 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id l66so38290777pfl.7
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 10:11:21 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id q85si31434330pfk.282.2016.11.01.10.11.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Nov 2016 10:11:20 -0700 (PDT)
From: Christopher Covington <cov@codeaurora.org>
Subject: [RFC v2 6/7] mm/powerpc: Use generic VDSO remap and unmap functions
Date: Tue,  1 Nov 2016 11:11:00 -0600
Message-Id: <20161101171101.24704-6-cov@codeaurora.org>
In-Reply-To: <20161101171101.24704-1-cov@codeaurora.org>
References: <20161101171101.24704-1-cov@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: criu@openvz.org, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Christopher Covington <cov@codeaurora.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

The PowerPC VDSO remap and unmap code was copied to a generic location,
only modifying the variable name expected in mm->context (vdso instead of
vdso_base) to match most other architectures. Having adopted this generic
naming, drop the code in arch/powerpc and use the generic version.

Signed-off-by: Christopher Covington <cov@codeaurora.org>
---
 arch/powerpc/Kconfig                     |  1 +
 arch/powerpc/include/asm/Kbuild          |  1 +
 arch/powerpc/include/asm/mm-arch-hooks.h | 28 -------------------------
 arch/powerpc/include/asm/mmu_context.h   | 35 +-------------------------------
 4 files changed, 3 insertions(+), 62 deletions(-)
 delete mode 100644 arch/powerpc/include/asm/mm-arch-hooks.h

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 65fba4c..f4a1cb9 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -134,6 +134,7 @@ config PPC
 	select ARCH_HAS_TICK_BROADCAST if GENERIC_CLOCKEVENTS_BROADCAST
 	select GENERIC_STRNCPY_FROM_USER
 	select GENERIC_STRNLEN_USER
+	select GENERIC_VDSO
 	select HAVE_MOD_ARCH_SPECIFIC
 	select MODULES_USE_ELF_RELA
 	select CLONE_BACKWARDS
diff --git a/arch/powerpc/include/asm/Kbuild b/arch/powerpc/include/asm/Kbuild
index 5c4fbc8..4d89ec6 100644
--- a/arch/powerpc/include/asm/Kbuild
+++ b/arch/powerpc/include/asm/Kbuild
@@ -8,3 +8,4 @@ generic-y += mcs_spinlock.h
 generic-y += preempt.h
 generic-y += rwsem.h
 generic-y += vtime.h
+generic-y += mm-arch-hooks.h
diff --git a/arch/powerpc/include/asm/mm-arch-hooks.h b/arch/powerpc/include/asm/mm-arch-hooks.h
deleted file mode 100644
index ea6da89..0000000
--- a/arch/powerpc/include/asm/mm-arch-hooks.h
+++ /dev/null
@@ -1,28 +0,0 @@
-/*
- * Architecture specific mm hooks
- *
- * Copyright (C) 2015, IBM Corporation
- * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef _ASM_POWERPC_MM_ARCH_HOOKS_H
-#define _ASM_POWERPC_MM_ARCH_HOOKS_H
-
-static inline void arch_remap(struct mm_struct *mm,
-			      unsigned long old_start, unsigned long old_end,
-			      unsigned long new_start, unsigned long new_end)
-{
-	/*
-	 * mremap() doesn't allow moving multiple vmas so we can limit the
-	 * check to old_start == vdso.
-	 */
-	if (old_start == mm->context.vdso)
-		mm->context.vdso = new_start;
-}
-#define arch_remap arch_remap
-
-#endif /* _ASM_POWERPC_MM_ARCH_HOOKS_H */
diff --git a/arch/powerpc/include/asm/mmu_context.h b/arch/powerpc/include/asm/mmu_context.h
index c907478..d8dcf45 100644
--- a/arch/powerpc/include/asm/mmu_context.h
+++ b/arch/powerpc/include/asm/mmu_context.h
@@ -8,6 +8,7 @@
 #include <linux/spinlock.h>
 #include <asm/mmu.h>	
 #include <asm/cputable.h>
+#include <asm-generic/mm_hooks.h>
 #include <asm/cputhreads.h>
 
 /*
@@ -133,39 +134,5 @@ static inline void enter_lazy_tlb(struct mm_struct *mm,
 #endif
 }
 
-static inline void arch_dup_mmap(struct mm_struct *oldmm,
-				 struct mm_struct *mm)
-{
-}
-
-static inline void arch_exit_mmap(struct mm_struct *mm)
-{
-}
-
-static inline void arch_unmap(struct mm_struct *mm,
-			      struct vm_area_struct *vma,
-			      unsigned long start, unsigned long end)
-{
-	if (start <= mm->context.vdso && mm->context.vdso < end)
-		mm->context.vdso = 0;
-}
-
-static inline void arch_bprm_mm_init(struct mm_struct *mm,
-				     struct vm_area_struct *vma)
-{
-}
-
-static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
-		bool write, bool execute, bool foreign)
-{
-	/* by default, allow everything */
-	return true;
-}
-
-static inline bool arch_pte_access_permitted(pte_t pte, bool write)
-{
-	/* by default, allow everything */
-	return true;
-}
 #endif /* __KERNEL__ */
 #endif /* __ASM_POWERPC_MMU_CONTEXT_H */
-- 
Qualcomm Datacenter Technologies as an affiliate of Qualcomm Technologies, Inc.
Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
