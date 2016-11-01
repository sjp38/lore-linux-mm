Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 24D046B02AD
	for <linux-mm@kvack.org>; Tue,  1 Nov 2016 13:11:20 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id yt9so92028296pac.0
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 10:11:20 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id j17si31545640pgg.104.2016.11.01.10.11.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Nov 2016 10:11:19 -0700 (PDT)
From: Christopher Covington <cov@codeaurora.org>
Subject: [RFC v2 5/7] powerpc: Rename context.vdso_base to context.vdso
Date: Tue,  1 Nov 2016 11:10:59 -0600
Message-Id: <20161101171101.24704-5-cov@codeaurora.org>
In-Reply-To: <20161101171101.24704-1-cov@codeaurora.org>
References: <20161101171101.24704-1-cov@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: criu@openvz.org, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Christopher Covington <cov@codeaurora.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

Checkpoint/Restore In Userspace (CRIU) needs to be able to unmap and remap
the VDSO to successfully checkpoint and restore applications in the face of
changing VDSO addresses due to Address Space Layout Randomization (ASLR,
randmaps). x86 and PowerPC have had architecture-specific code to support
this. In order to expand the architectures that support this without
unnecessary duplication of code, a generic version based on the PowerPC code
was created. It differs slightly, based on the results of an informal
survey of all architectures that indicated

	unsigned long vdso;

is popular (and it's also concise). Therefore, change the variable name in
powerpc from mm->context.vdso_base to mm->context.vdso.

Signed-off-by: Christopher Covington <cov@codeaurora.org>
---
 arch/powerpc/include/asm/book3s/32/mmu-hash.h |  2 +-
 arch/powerpc/include/asm/book3s/64/mmu.h      |  2 +-
 arch/powerpc/include/asm/mm-arch-hooks.h      |  6 +++---
 arch/powerpc/include/asm/mmu-40x.h            |  2 +-
 arch/powerpc/include/asm/mmu-44x.h            |  2 +-
 arch/powerpc/include/asm/mmu-8xx.h            |  2 +-
 arch/powerpc/include/asm/mmu-book3e.h         |  2 +-
 arch/powerpc/include/asm/mmu_context.h        |  4 ++--
 arch/powerpc/include/asm/vdso.h               |  2 +-
 arch/powerpc/include/uapi/asm/elf.h           |  2 +-
 arch/powerpc/kernel/signal_32.c               |  8 ++++----
 arch/powerpc/kernel/signal_64.c               |  4 ++--
 arch/powerpc/kernel/vdso.c                    |  8 ++++----
 arch/powerpc/perf/callchain.c                 | 12 ++++++------
 14 files changed, 29 insertions(+), 29 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/32/mmu-hash.h b/arch/powerpc/include/asm/book3s/32/mmu-hash.h
index b82e063..75738bb 100644
--- a/arch/powerpc/include/asm/book3s/32/mmu-hash.h
+++ b/arch/powerpc/include/asm/book3s/32/mmu-hash.h
@@ -79,7 +79,7 @@ struct hash_pte {
 
 typedef struct {
 	unsigned long id;
-	unsigned long vdso_base;
+	unsigned long vdso;
 } mm_context_t;
 
 #endif /* !__ASSEMBLY__ */
diff --git a/arch/powerpc/include/asm/book3s/64/mmu.h b/arch/powerpc/include/asm/book3s/64/mmu.h
index 8afb0e0..8486a10 100644
--- a/arch/powerpc/include/asm/book3s/64/mmu.h
+++ b/arch/powerpc/include/asm/book3s/64/mmu.h
@@ -72,7 +72,7 @@ typedef struct {
 #else
 	u16 sllp;		/* SLB page size encoding */
 #endif
-	unsigned long vdso_base;
+	unsigned long vdso;
 #ifdef CONFIG_PPC_SUBPAGE_PROT
 	struct subpage_prot_table spt;
 #endif /* CONFIG_PPC_SUBPAGE_PROT */
diff --git a/arch/powerpc/include/asm/mm-arch-hooks.h b/arch/powerpc/include/asm/mm-arch-hooks.h
index f2a2da8..ea6da89 100644
--- a/arch/powerpc/include/asm/mm-arch-hooks.h
+++ b/arch/powerpc/include/asm/mm-arch-hooks.h
@@ -18,10 +18,10 @@ static inline void arch_remap(struct mm_struct *mm,
 {
 	/*
 	 * mremap() doesn't allow moving multiple vmas so we can limit the
-	 * check to old_start == vdso_base.
+	 * check to old_start == vdso.
 	 */
-	if (old_start == mm->context.vdso_base)
-		mm->context.vdso_base = new_start;
+	if (old_start == mm->context.vdso)
+		mm->context.vdso = new_start;
 }
 #define arch_remap arch_remap
 
diff --git a/arch/powerpc/include/asm/mmu-40x.h b/arch/powerpc/include/asm/mmu-40x.h
index 3491686..e8e57b7 100644
--- a/arch/powerpc/include/asm/mmu-40x.h
+++ b/arch/powerpc/include/asm/mmu-40x.h
@@ -56,7 +56,7 @@
 typedef struct {
 	unsigned int	id;
 	unsigned int	active;
-	unsigned long	vdso_base;
+	unsigned long	vdso;
 } mm_context_t;
 
 #endif /* !__ASSEMBLY__ */
diff --git a/arch/powerpc/include/asm/mmu-44x.h b/arch/powerpc/include/asm/mmu-44x.h
index bf52d70..471891c 100644
--- a/arch/powerpc/include/asm/mmu-44x.h
+++ b/arch/powerpc/include/asm/mmu-44x.h
@@ -107,7 +107,7 @@ extern unsigned int tlb_44x_index;
 typedef struct {
 	unsigned int	id;
 	unsigned int	active;
-	unsigned long	vdso_base;
+	unsigned long	vdso;
 } mm_context_t;
 
 #endif /* !__ASSEMBLY__ */
diff --git a/arch/powerpc/include/asm/mmu-8xx.h b/arch/powerpc/include/asm/mmu-8xx.h
index 3e0e492..2834af0 100644
--- a/arch/powerpc/include/asm/mmu-8xx.h
+++ b/arch/powerpc/include/asm/mmu-8xx.h
@@ -167,7 +167,7 @@
 typedef struct {
 	unsigned int id;
 	unsigned int active;
-	unsigned long vdso_base;
+	unsigned long vdso;
 } mm_context_t;
 
 #define PHYS_IMMR_BASE (mfspr(SPRN_IMMR) & 0xfff80000)
diff --git a/arch/powerpc/include/asm/mmu-book3e.h b/arch/powerpc/include/asm/mmu-book3e.h
index b62a8d4..28dc4e0 100644
--- a/arch/powerpc/include/asm/mmu-book3e.h
+++ b/arch/powerpc/include/asm/mmu-book3e.h
@@ -228,7 +228,7 @@ extern unsigned int tlbcam_index;
 typedef struct {
 	unsigned int	id;
 	unsigned int	active;
-	unsigned long	vdso_base;
+	unsigned long	vdso;
 #ifdef CONFIG_PPC_MM_SLICES
 	u64 low_slices_psize;   /* SLB page size encodings */
 	u64 high_slices_psize;  /* 4 bits per slice for now */
diff --git a/arch/powerpc/include/asm/mmu_context.h b/arch/powerpc/include/asm/mmu_context.h
index 5c45114..c907478 100644
--- a/arch/powerpc/include/asm/mmu_context.h
+++ b/arch/powerpc/include/asm/mmu_context.h
@@ -146,8 +146,8 @@ static inline void arch_unmap(struct mm_struct *mm,
 			      struct vm_area_struct *vma,
 			      unsigned long start, unsigned long end)
 {
-	if (start <= mm->context.vdso_base && mm->context.vdso_base < end)
-		mm->context.vdso_base = 0;
+	if (start <= mm->context.vdso && mm->context.vdso < end)
+		mm->context.vdso = 0;
 }
 
 static inline void arch_bprm_mm_init(struct mm_struct *mm,
diff --git a/arch/powerpc/include/asm/vdso.h b/arch/powerpc/include/asm/vdso.h
index c53f5f6..fc90971 100644
--- a/arch/powerpc/include/asm/vdso.h
+++ b/arch/powerpc/include/asm/vdso.h
@@ -17,7 +17,7 @@
 
 #ifndef __ASSEMBLY__
 
-/* Offsets relative to thread->vdso_base */
+/* Offsets relative to mm->context.vdso */
 extern unsigned long vdso64_rt_sigtramp;
 extern unsigned long vdso32_sigtramp;
 extern unsigned long vdso32_rt_sigtramp;
diff --git a/arch/powerpc/include/uapi/asm/elf.h b/arch/powerpc/include/uapi/asm/elf.h
index 3a9e44c..d7c81ae 100644
--- a/arch/powerpc/include/uapi/asm/elf.h
+++ b/arch/powerpc/include/uapi/asm/elf.h
@@ -182,7 +182,7 @@ do {									\
 	NEW_AUX_ENT(AT_DCACHEBSIZE, dcache_bsize);			\
 	NEW_AUX_ENT(AT_ICACHEBSIZE, icache_bsize);			\
 	NEW_AUX_ENT(AT_UCACHEBSIZE, ucache_bsize);			\
-	VDSO_AUX_ENT(AT_SYSINFO_EHDR, current->mm->context.vdso_base);	\
+	VDSO_AUX_ENT(AT_SYSINFO_EHDR, current->mm->context.vdso);	\
 } while (0)
 
 /* PowerPC64 relocations defined by the ABIs */
diff --git a/arch/powerpc/kernel/signal_32.c b/arch/powerpc/kernel/signal_32.c
index 27aa913..7bb0882 100644
--- a/arch/powerpc/kernel/signal_32.c
+++ b/arch/powerpc/kernel/signal_32.c
@@ -1006,9 +1006,9 @@ int handle_rt_signal32(struct ksignal *ksig, sigset_t *oldset,
 	/* Save user registers on the stack */
 	frame = &rt_sf->uc.uc_mcontext;
 	addr = frame;
-	if (vdso32_rt_sigtramp && tsk->mm->context.vdso_base) {
+	if (vdso32_rt_sigtramp && tsk->mm->context.vdso) {
 		sigret = 0;
-		tramp = tsk->mm->context.vdso_base + vdso32_rt_sigtramp;
+		tramp = tsk->mm->context.vdso + vdso32_rt_sigtramp;
 	} else {
 		sigret = __NR_rt_sigreturn;
 		tramp = (unsigned long) frame->tramp;
@@ -1449,9 +1449,9 @@ int handle_signal32(struct ksignal *ksig, sigset_t *oldset,
 	    || __put_user(ksig->sig, &sc->signal))
 		goto badframe;
 
-	if (vdso32_sigtramp && tsk->mm->context.vdso_base) {
+	if (vdso32_sigtramp && tsk->mm->context.vdso) {
 		sigret = 0;
-		tramp = tsk->mm->context.vdso_base + vdso32_sigtramp;
+		tramp = tsk->mm->context.vdso + vdso32_sigtramp;
 	} else {
 		sigret = __NR_sigreturn;
 		tramp = (unsigned long) frame->mctx.tramp;
diff --git a/arch/powerpc/kernel/signal_64.c b/arch/powerpc/kernel/signal_64.c
index 96698fd..608a919 100644
--- a/arch/powerpc/kernel/signal_64.c
+++ b/arch/powerpc/kernel/signal_64.c
@@ -791,8 +791,8 @@ int handle_rt_signal64(struct ksignal *ksig, sigset_t *set,
 	tsk->thread.fp_state.fpscr = 0;
 
 	/* Set up to return from userspace. */
-	if (vdso64_rt_sigtramp && tsk->mm->context.vdso_base) {
-		regs->link = tsk->mm->context.vdso_base + vdso64_rt_sigtramp;
+	if (vdso64_rt_sigtramp && tsk->mm->context.vdso) {
+		regs->link = tsk->mm->context.vdso + vdso64_rt_sigtramp;
 	} else {
 		err |= setup_trampoline(__NR_rt_sigreturn, &frame->tramp[0]);
 		if (err)
diff --git a/arch/powerpc/kernel/vdso.c b/arch/powerpc/kernel/vdso.c
index 4111d30..33ea0f8 100644
--- a/arch/powerpc/kernel/vdso.c
+++ b/arch/powerpc/kernel/vdso.c
@@ -180,7 +180,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	vdso_base = VDSO32_MBASE;
 #endif
 
-	current->mm->context.vdso_base = 0;
+	current->mm->context.vdso = 0;
 
 	/* vDSO has a problem and was disabled, just don't "enable" it for the
 	 * process
@@ -215,7 +215,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	 * install_special_mapping or the perf counter mmap tracking code
 	 * will fail to recognise it as a vDSO (since arch_vma_name fails).
 	 */
-	current->mm->context.vdso_base = vdso_base;
+	current->mm->context.vdso = vdso_base;
 
 	/*
 	 * our vma flags don't have VM_WRITE so by default, the process isn't
@@ -232,7 +232,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 				     VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
 				     vdso_pagelist);
 	if (rc) {
-		current->mm->context.vdso_base = 0;
+		current->mm->context.vdso = 0;
 		goto fail_mmapsem;
 	}
 
@@ -246,7 +246,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 
 const char *arch_vma_name(struct vm_area_struct *vma)
 {
-	if (vma->vm_mm && vma->vm_start == vma->vm_mm->context.vdso_base)
+	if (vma->vm_mm && vma->vm_start == vma->vm_mm->context.vdso)
 		return "[vdso]";
 	return NULL;
 }
diff --git a/arch/powerpc/perf/callchain.c b/arch/powerpc/perf/callchain.c
index 0fc2671..5c893a2 100644
--- a/arch/powerpc/perf/callchain.c
+++ b/arch/powerpc/perf/callchain.c
@@ -209,8 +209,8 @@ static int is_sigreturn_64_address(unsigned long nip, unsigned long fp)
 {
 	if (nip == fp + offsetof(struct signal_frame_64, tramp))
 		return 1;
-	if (vdso64_rt_sigtramp && current->mm->context.vdso_base &&
-	    nip == current->mm->context.vdso_base + vdso64_rt_sigtramp)
+	if (vdso64_rt_sigtramp && current->mm->context.vdso &&
+	    nip == current->mm->context.vdso + vdso64_rt_sigtramp)
 		return 1;
 	return 0;
 }
@@ -368,8 +368,8 @@ static int is_sigreturn_32_address(unsigned int nip, unsigned int fp)
 {
 	if (nip == fp + offsetof(struct signal_frame_32, mctx.mc_pad))
 		return 1;
-	if (vdso32_sigtramp && current->mm->context.vdso_base &&
-	    nip == current->mm->context.vdso_base + vdso32_sigtramp)
+	if (vdso32_sigtramp && current->mm->context.vdso &&
+	    nip == current->mm->context.vdso + vdso32_sigtramp)
 		return 1;
 	return 0;
 }
@@ -379,8 +379,8 @@ static int is_rt_sigreturn_32_address(unsigned int nip, unsigned int fp)
 	if (nip == fp + offsetof(struct rt_signal_frame_32,
 				 uc.uc_mcontext.mc_pad))
 		return 1;
-	if (vdso32_rt_sigtramp && current->mm->context.vdso_base &&
-	    nip == current->mm->context.vdso_base + vdso32_rt_sigtramp)
+	if (vdso32_rt_sigtramp && current->mm->context.vdso &&
+	    nip == current->mm->context.vdso + vdso32_rt_sigtramp)
 		return 1;
 	return 0;
 }
-- 
Qualcomm Datacenter Technologies as an affiliate of Qualcomm Technologies, Inc.
Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
