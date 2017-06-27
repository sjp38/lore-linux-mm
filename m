Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 831316B0338
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 06:12:42 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id g2so10455075qta.14
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 03:12:42 -0700 (PDT)
Received: from mail-qt0-x242.google.com (mail-qt0-x242.google.com. [2607:f8b0:400d:c0d::242])
        by mx.google.com with ESMTPS id o33si2383950qtb.100.2017.06.27.03.12.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 03:12:41 -0700 (PDT)
Received: by mail-qt0-x242.google.com with SMTP id c20so3171799qte.0
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 03:12:41 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v4 12/17] powerpc: Deliver SEGV signal on pkey violation
Date: Tue, 27 Jun 2017 03:11:54 -0700
Message-Id: <1498558319-32466-13-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1498558319-32466-1-git-send-email-linuxram@us.ibm.com>
References: <1498558319-32466-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

The value of the AMR register at the time of exception
is made available in gp_regs[PT_AMR] of the siginfo.

The value of the pkey, whose protection got violated,
is made available in si_pkey field of the siginfo structure.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/paca.h        |  1 +
 arch/powerpc/include/uapi/asm/ptrace.h |  3 ++-
 arch/powerpc/kernel/asm-offsets.c      |  5 ++++
 arch/powerpc/kernel/exceptions-64s.S   | 16 +++++++++--
 arch/powerpc/kernel/signal_32.c        |  5 ++++
 arch/powerpc/kernel/signal_64.c        |  4 +++
 arch/powerpc/kernel/traps.c            | 49 ++++++++++++++++++++++++++++++++++
 arch/powerpc/mm/fault.c                |  2 ++
 8 files changed, 82 insertions(+), 3 deletions(-)

diff --git a/arch/powerpc/include/asm/paca.h b/arch/powerpc/include/asm/paca.h
index 1c09f8f..a41afd3 100644
--- a/arch/powerpc/include/asm/paca.h
+++ b/arch/powerpc/include/asm/paca.h
@@ -92,6 +92,7 @@ struct paca_struct {
 	struct dtl_entry *dispatch_log_end;
 #endif /* CONFIG_PPC_STD_MMU_64 */
 	u64 dscr_default;		/* per-CPU default DSCR */
+	u64 paca_amr;			/* value of amr at exception */
 
 #ifdef CONFIG_PPC_STD_MMU_64
 	/*
diff --git a/arch/powerpc/include/uapi/asm/ptrace.h b/arch/powerpc/include/uapi/asm/ptrace.h
index 8036b38..7ec2428 100644
--- a/arch/powerpc/include/uapi/asm/ptrace.h
+++ b/arch/powerpc/include/uapi/asm/ptrace.h
@@ -108,8 +108,9 @@ struct pt_regs {
 #define PT_DAR	41
 #define PT_DSISR 42
 #define PT_RESULT 43
-#define PT_DSCR 44
 #define PT_REGS_COUNT 44
+#define PT_DSCR 44
+#define PT_AMR	45
 
 #define PT_FPR0	48	/* each FP reg occupies 2 slots in this space */
 
diff --git a/arch/powerpc/kernel/asm-offsets.c b/arch/powerpc/kernel/asm-offsets.c
index 709e234..17f5d8a 100644
--- a/arch/powerpc/kernel/asm-offsets.c
+++ b/arch/powerpc/kernel/asm-offsets.c
@@ -241,6 +241,11 @@ int main(void)
 	OFFSET(PACAHWCPUID, paca_struct, hw_cpu_id);
 	OFFSET(PACAKEXECSTATE, paca_struct, kexec_state);
 	OFFSET(PACA_DSCR_DEFAULT, paca_struct, dscr_default);
+
+#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
+	OFFSET(PACA_AMR, paca_struct, paca_amr);
+#endif /* CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
+
 	OFFSET(ACCOUNT_STARTTIME, paca_struct, accounting.starttime);
 	OFFSET(ACCOUNT_STARTTIME_USER, paca_struct, accounting.starttime_user);
 	OFFSET(ACCOUNT_USER_TIME, paca_struct, accounting.utime);
diff --git a/arch/powerpc/kernel/exceptions-64s.S b/arch/powerpc/kernel/exceptions-64s.S
index 3fd0528..a4de1b4 100644
--- a/arch/powerpc/kernel/exceptions-64s.S
+++ b/arch/powerpc/kernel/exceptions-64s.S
@@ -493,9 +493,15 @@ EXC_COMMON_BEGIN(data_access_common)
 	ld	r12,_MSR(r1)
 	ld	r3,PACA_EXGEN+EX_DAR(r13)
 	lwz	r4,PACA_EXGEN+EX_DSISR(r13)
-	li	r5,0x300
 	std	r3,_DAR(r1)
 	std	r4,_DSISR(r1)
+#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
+	andis.  r0,r4,DSISR_KEYFAULT@h /* save AMR only if its a key fault */
+	beq+	1f
+	mfspr	r5,SPRN_AMR
+	std	r5,PACA_AMR(r13)
+#endif /*  CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
+1:	li	r5,0x300
 BEGIN_MMU_FTR_SECTION
 	b	do_hash_page		/* Try to handle as hpte fault */
 MMU_FTR_SECTION_ELSE
@@ -561,9 +567,15 @@ EXC_COMMON_BEGIN(instruction_access_common)
 	ld	r12,_MSR(r1)
 	ld	r3,_NIP(r1)
 	andis.	r4,r12,0x5820
-	li	r5,0x400
 	std	r3,_DAR(r1)
 	std	r4,_DSISR(r1)
+#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
+	andis.  r0,r4,DSISR_KEYFAULT@h /* save AMR only if its a key fault */
+	beq+	1f
+	mfspr	r5,SPRN_AMR
+	std	r5,PACA_AMR(r13)
+#endif /*  CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
+1:	li	r5,0x400
 BEGIN_MMU_FTR_SECTION
 	b	do_hash_page		/* Try to handle as hpte fault */
 MMU_FTR_SECTION_ELSE
diff --git a/arch/powerpc/kernel/signal_32.c b/arch/powerpc/kernel/signal_32.c
index 97bb138..9c4a7f3 100644
--- a/arch/powerpc/kernel/signal_32.c
+++ b/arch/powerpc/kernel/signal_32.c
@@ -500,6 +500,11 @@ static int save_user_regs(struct pt_regs *regs, struct mcontext __user *frame,
 				   (unsigned long) &frame->tramp[2]);
 	}
 
+#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
+	if (__put_user(get_paca()->paca_amr, &frame->mc_gregs[PT_AMR]))
+		return 1;
+#endif /*  CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
+
 	return 0;
 }
 
diff --git a/arch/powerpc/kernel/signal_64.c b/arch/powerpc/kernel/signal_64.c
index c83c115..86a4262 100644
--- a/arch/powerpc/kernel/signal_64.c
+++ b/arch/powerpc/kernel/signal_64.c
@@ -174,6 +174,10 @@ static long setup_sigcontext(struct sigcontext __user *sc,
 	if (set != NULL)
 		err |=  __put_user(set->sig[0], &sc->oldmask);
 
+#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
+	err |= __put_user(get_paca()->paca_amr, &sc->gp_regs[PT_AMR]);
+#endif /*  CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
+
 	return err;
 }
 
diff --git a/arch/powerpc/kernel/traps.c b/arch/powerpc/kernel/traps.c
index d4e545d..cc4bde8b 100644
--- a/arch/powerpc/kernel/traps.c
+++ b/arch/powerpc/kernel/traps.c
@@ -20,6 +20,7 @@
 #include <linux/sched/debug.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
+#include <linux/pkeys.h>
 #include <linux/stddef.h>
 #include <linux/unistd.h>
 #include <linux/ptrace.h>
@@ -247,6 +248,49 @@ void user_single_step_siginfo(struct task_struct *tsk,
 	info->si_addr = (void __user *)regs->nip;
 }
 
+#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
+static void fill_sig_info_pkey(int si_code, siginfo_t *info, unsigned long addr)
+{
+	struct vm_area_struct *vma;
+
+	/* Fault not from Protection Keys: nothing to do */
+	if (si_code != SEGV_PKUERR)
+		return;
+
+	down_read(&current->mm->mmap_sem);
+	/*
+	 * we could be racing with pkey_mprotect().
+	 * If pkey_mprotect() wins the key value could
+	 * get modified...xxx
+	 */
+	vma = find_vma(current->mm, addr);
+	up_read(&current->mm->mmap_sem);
+
+	/*
+	 * force_sig_info_fault() is called from a number of
+	 * contexts, some of which have a VMA and some of which
+	 * do not.  The Pkey-fault handing happens after we have a
+	 * valid VMA, so we should never reach this without a
+	 * valid VMA.
+	 */
+	if (!vma) {
+		WARN_ONCE(1, "Pkey fault with no VMA passed in");
+		info->si_pkey = 0;
+		return;
+	}
+
+	/*
+	 * We could report the incorrect key because of the reason
+	 * explained above.
+	 *
+	 * si_pkey should be thought off as a strong hint, but not
+	 * an absolutely guarantee because of the race explained
+	 * above.
+	 */
+	info->si_pkey = vma_pkey(vma);
+}
+#endif /* CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
+
 void _exception(int signr, struct pt_regs *regs, int code, unsigned long addr)
 {
 	siginfo_t info;
@@ -274,6 +318,11 @@ void _exception(int signr, struct pt_regs *regs, int code, unsigned long addr)
 	info.si_signo = signr;
 	info.si_code = code;
 	info.si_addr = (void __user *) addr;
+
+#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
+	fill_sig_info_pkey(code, &info, addr);
+#endif /* CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
+
 	force_sig_info(signr, &info, current);
 }
 
diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index 3d71984..0780a53 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -451,6 +451,8 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 #ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
 	if (!arch_vma_access_permitted(vma, flags & FAULT_FLAG_WRITE,
 					is_exec, 0)) {
+		/* our caller may not have saved the amr. Lets save it */
+		get_paca()->paca_amr = read_amr();
 		code = SEGV_PKUERR;
 		goto bad_area;
 	}
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
