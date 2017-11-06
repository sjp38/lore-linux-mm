Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id E410B280246
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 03:58:48 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id q83so6735821qke.16
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 00:58:48 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l64sor6492149qte.92.2017.11.06.00.58.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Nov 2017 00:58:48 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v9 10/51] powerpc: store and restore the pkey state across context switches
Date: Mon,  6 Nov 2017 00:57:02 -0800
Message-Id: <1509958663-18737-11-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
References: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com

Store and restore the AMR, IAMR and UAMOR register state of the task
before scheduling out and after scheduling in, respectively.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/mmu_context.h |    3 ++
 arch/powerpc/include/asm/pkeys.h       |    4 ++
 arch/powerpc/include/asm/processor.h   |    5 +++
 arch/powerpc/kernel/process.c          |    7 ++++
 arch/powerpc/mm/pkeys.c                |   49 +++++++++++++++++++++++++++++++-
 5 files changed, 67 insertions(+), 1 deletions(-)

diff --git a/arch/powerpc/include/asm/mmu_context.h b/arch/powerpc/include/asm/mmu_context.h
index 6d7c4f1..4eccc2f 100644
--- a/arch/powerpc/include/asm/mmu_context.h
+++ b/arch/powerpc/include/asm/mmu_context.h
@@ -146,6 +146,9 @@ static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
 #ifndef CONFIG_PPC_MEM_KEYS
 #define pkey_initialize()
 #define pkey_mm_init(mm)
+#define thread_pkey_regs_save(thread)
+#define thread_pkey_regs_restore(new_thread, old_thread)
+#define thread_pkey_regs_init(thread)
 #endif /* CONFIG_PPC_MEM_KEYS */
 
 #endif /* __KERNEL__ */
diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
index 652c750..0b2d9f0 100644
--- a/arch/powerpc/include/asm/pkeys.h
+++ b/arch/powerpc/include/asm/pkeys.h
@@ -156,5 +156,9 @@ static inline void pkey_mm_init(struct mm_struct *mm)
 	mm_pkey_allocation_map(mm) = initial_allocation_mask;
 }
 
+extern void thread_pkey_regs_save(struct thread_struct *thread);
+extern void thread_pkey_regs_restore(struct thread_struct *new_thread,
+				     struct thread_struct *old_thread);
+extern void thread_pkey_regs_init(struct thread_struct *thread);
 extern void pkey_initialize(void);
 #endif /*_ASM_POWERPC_KEYS_H */
diff --git a/arch/powerpc/include/asm/processor.h b/arch/powerpc/include/asm/processor.h
index fab7ff8..e3c417c 100644
--- a/arch/powerpc/include/asm/processor.h
+++ b/arch/powerpc/include/asm/processor.h
@@ -309,6 +309,11 @@ struct thread_struct {
 	struct thread_vr_state ckvr_state; /* Checkpointed VR state */
 	unsigned long	ckvrsave; /* Checkpointed VRSAVE */
 #endif /* CONFIG_PPC_TRANSACTIONAL_MEM */
+#ifdef CONFIG_PPC_MEM_KEYS
+	unsigned long	amr;
+	unsigned long	iamr;
+	unsigned long	uamor;
+#endif
 #ifdef CONFIG_KVM_BOOK3S_32_HANDLER
 	void*		kvm_shadow_vcpu; /* KVM internal data */
 #endif /* CONFIG_KVM_BOOK3S_32_HANDLER */
diff --git a/arch/powerpc/kernel/process.c b/arch/powerpc/kernel/process.c
index a0c74bb..148b934 100644
--- a/arch/powerpc/kernel/process.c
+++ b/arch/powerpc/kernel/process.c
@@ -42,6 +42,7 @@
 #include <linux/hw_breakpoint.h>
 #include <linux/uaccess.h>
 #include <linux/elf-randomize.h>
+#include <linux/pkeys.h>
 
 #include <asm/pgtable.h>
 #include <asm/io.h>
@@ -1085,6 +1086,8 @@ static inline void save_sprs(struct thread_struct *t)
 		t->tar = mfspr(SPRN_TAR);
 	}
 #endif
+
+	thread_pkey_regs_save(t);
 }
 
 static inline void restore_sprs(struct thread_struct *old_thread,
@@ -1120,6 +1123,8 @@ static inline void restore_sprs(struct thread_struct *old_thread,
 			mtspr(SPRN_TAR, new_thread->tar);
 	}
 #endif
+
+	thread_pkey_regs_restore(new_thread, old_thread);
 }
 
 #ifdef CONFIG_PPC_BOOK3S_64
@@ -1705,6 +1710,8 @@ void start_thread(struct pt_regs *regs, unsigned long start, unsigned long sp)
 	current->thread.tm_tfiar = 0;
 	current->thread.load_tm = 0;
 #endif /* CONFIG_PPC_TRANSACTIONAL_MEM */
+
+	thread_pkey_regs_init(&current->thread);
 }
 EXPORT_SYMBOL(start_thread);
 
diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
index 3ddc13a..469f370 100644
--- a/arch/powerpc/mm/pkeys.c
+++ b/arch/powerpc/mm/pkeys.c
@@ -16,6 +16,8 @@
 bool pkey_execute_disable_supported;
 int  pkeys_total;		/* Total pkeys as per device tree */
 u32  initial_allocation_mask;	/* Bits set for reserved keys */
+u64  pkey_amr_uamor_mask;	/* Bits in AMR/UMOR not to be touched */
+u64  pkey_iamr_mask;		/* Bits in AMR not to be touched */
 
 #define AMR_BITS_PER_PKEY 2
 #define AMR_RD_BIT 0x1UL
@@ -74,8 +76,16 @@ void __init pkey_initialize(void)
 	 * 	programming note.
 	 */
 	initial_allocation_mask = ~0x0;
-	for (i = 2; i < (pkeys_total - os_reserved); i++)
+
+	/* register mask is in BE format */
+	pkey_amr_uamor_mask = ~0x0ul;
+	pkey_iamr_mask = ~0x0ul;
+
+	for (i = 2; i < (pkeys_total - os_reserved); i++) {
 		initial_allocation_mask &= ~(0x1 << i);
+		pkey_amr_uamor_mask &= ~(0x3ul << pkeyshift(i));
+		pkey_iamr_mask &= ~(0x1ul << pkeyshift(i));
+	}
 }
 
 static inline u64 read_amr(void)
@@ -200,3 +210,40 @@ int __arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 	init_amr(pkey, new_amr_bits);
 	return 0;
 }
+
+void thread_pkey_regs_save(struct thread_struct *thread)
+{
+	if (static_branch_likely(&pkey_disabled))
+		return;
+
+	/*
+	 * TODO: Skip saving registers if @thread hasn't used any keys yet.
+	 */
+	thread->amr = read_amr();
+	thread->iamr = read_iamr();
+	thread->uamor = read_uamor();
+}
+
+void thread_pkey_regs_restore(struct thread_struct *new_thread,
+			      struct thread_struct *old_thread)
+{
+	if (static_branch_likely(&pkey_disabled))
+		return;
+
+	/*
+	 * TODO: Just set UAMOR to zero if @new_thread hasn't used any keys yet.
+	 */
+	if (old_thread->amr != new_thread->amr)
+		write_amr(new_thread->amr);
+	if (old_thread->iamr != new_thread->iamr)
+		write_iamr(new_thread->iamr);
+	if (old_thread->uamor != new_thread->uamor)
+		write_uamor(new_thread->uamor);
+}
+
+void thread_pkey_regs_init(struct thread_struct *thread)
+{
+	write_amr(read_amr() & pkey_amr_uamor_mask);
+	write_iamr(read_iamr() & pkey_iamr_mask);
+	write_uamor(read_uamor() & pkey_amr_uamor_mask);
+}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
