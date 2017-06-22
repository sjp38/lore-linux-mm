Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0F4746B036A
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 21:40:34 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id k14so1113941qkl.11
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 18:40:34 -0700 (PDT)
Received: from mail-qk0-x242.google.com (mail-qk0-x242.google.com. [2607:f8b0:400d:c09::242])
        by mx.google.com with ESMTPS id o4si65160qki.187.2017.06.21.18.40.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 18:40:33 -0700 (PDT)
Received: by mail-qk0-x242.google.com with SMTP id 16so364869qkg.2
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 18:40:32 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v3 17/23] powerpc: Handle exceptions caused by violation of pkey protection
Date: Wed, 21 Jun 2017 18:39:33 -0700
Message-Id: <1498095579-6790-18-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1498095579-6790-1-git-send-email-linuxram@us.ibm.com>
References: <1498095579-6790-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

Handle Data and Instruction exceptions caused by memory
protection-key.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/mmu_context.h | 12 +++++
 arch/powerpc/include/asm/pkeys.h       |  9 ++++
 arch/powerpc/include/asm/reg.h         |  2 +-
 arch/powerpc/mm/fault.c                | 20 ++++++++
 arch/powerpc/mm/pkeys.c                | 90 ++++++++++++++++++++++++++++++++++
 5 files changed, 132 insertions(+), 1 deletion(-)

diff --git a/arch/powerpc/include/asm/mmu_context.h b/arch/powerpc/include/asm/mmu_context.h
index da7e943..71fffe0 100644
--- a/arch/powerpc/include/asm/mmu_context.h
+++ b/arch/powerpc/include/asm/mmu_context.h
@@ -175,11 +175,23 @@ static inline void arch_bprm_mm_init(struct mm_struct *mm,
 {
 }
 
+#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
+bool arch_pte_access_permitted(pte_t pte, bool write);
+bool arch_vma_access_permitted(struct vm_area_struct *vma,
+		bool write, bool execute, bool foreign);
+#else /* CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
+static inline bool arch_pte_access_permitted(pte_t pte, bool write)
+{
+	/* by default, allow everything */
+	return true;
+}
 static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
 		bool write, bool execute, bool foreign)
 {
 	/* by default, allow everything */
 	return true;
 }
+#endif /* CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
+
 #endif /* __KERNEL__ */
 #endif /* __ASM_POWERPC_MMU_CONTEXT_H */
diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
index af3882f..a83722e 100644
--- a/arch/powerpc/include/asm/pkeys.h
+++ b/arch/powerpc/include/asm/pkeys.h
@@ -14,6 +14,15 @@
 			VM_PKEY_BIT3 | \
 			VM_PKEY_BIT4)
 
+static inline u16 pte_flags_to_pkey(unsigned long pte_flags)
+{
+	return ((pte_flags & H_PAGE_PKEY_BIT4) ? 0x1 : 0x0) |
+		((pte_flags & H_PAGE_PKEY_BIT3) ? 0x2 : 0x0) |
+		((pte_flags & H_PAGE_PKEY_BIT2) ? 0x4 : 0x0) |
+		((pte_flags & H_PAGE_PKEY_BIT1) ? 0x8 : 0x0) |
+		((pte_flags & H_PAGE_PKEY_BIT0) ? 0x10 : 0x0);
+}
+
 #define pkey_to_vmflag_bits(key) (((key & 0x1UL) ? VM_PKEY_BIT0 : 0x0UL) | \
 			((key & 0x2UL) ? VM_PKEY_BIT1 : 0x0UL) |	\
 			((key & 0x4UL) ? VM_PKEY_BIT2 : 0x0UL) |	\
diff --git a/arch/powerpc/include/asm/reg.h b/arch/powerpc/include/asm/reg.h
index ba110dd..6e2a860 100644
--- a/arch/powerpc/include/asm/reg.h
+++ b/arch/powerpc/include/asm/reg.h
@@ -286,7 +286,7 @@
 #define   DSISR_SET_RC		0x00040000	/* Failed setting of R/C bits */
 #define   DSISR_PGDIRFAULT      0x00020000      /* Fault on page directory */
 #define   DSISR_PAGE_FAULT_MASK (DSISR_BIT32 | DSISR_PAGEATTR_CONFLT | \
-				DSISR_BADACCESS | DSISR_BIT43)
+			DSISR_BADACCESS | DSISR_KEYFAULT | DSISR_BIT43)
 #define SPRN_TBRL	0x10C	/* Time Base Read Lower Register (user, R/O) */
 #define SPRN_TBRU	0x10D	/* Time Base Read Upper Register (user, R/O) */
 #define SPRN_CIR	0x11B	/* Chip Information Register (hyper, R/0) */
diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index 3a7d580..3d71984 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -261,6 +261,13 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 	}
 #endif
 
+#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
+	if (error_code & DSISR_KEYFAULT) {
+		code = SEGV_PKUERR;
+		goto bad_area_nosemaphore;
+	}
+#endif /*  CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
+
 	/* We restore the interrupt state now */
 	if (!arch_irq_disabled_regs(regs))
 		local_irq_enable();
@@ -441,6 +448,19 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 		WARN_ON_ONCE(error_code & DSISR_PROTFAULT);
 #endif /* CONFIG_PPC_STD_MMU */
 
+#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
+	if (!arch_vma_access_permitted(vma, flags & FAULT_FLAG_WRITE,
+					is_exec, 0)) {
+		code = SEGV_PKUERR;
+		goto bad_area;
+	}
+#endif /* CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
+
+	/* handle_mm_fault() needs to know if its a instruction access
+	 * fault.
+	 */
+	if (is_exec)
+		flags |= FAULT_FLAG_INSTRUCTION;
 	/*
 	 * If for any reason at all we couldn't handle the fault,
 	 * make sure we exit gracefully rather than endlessly redo
diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
index 11a32b3..439241a 100644
--- a/arch/powerpc/mm/pkeys.c
+++ b/arch/powerpc/mm/pkeys.c
@@ -27,6 +27,37 @@ static inline bool pkey_allows_readwrite(int pkey)
 	return !(read_amr() & ((AMR_AD_BIT|AMR_WD_BIT) << pkey_shift));
 }
 
+static inline bool pkey_allows_read(int pkey)
+{
+	int pkey_shift = (arch_max_pkey()-pkey-1) * AMR_BITS_PER_PKEY;
+
+	if (!(read_uamor() & (0x3ul << pkey_shift)))
+		return true;
+
+	return !(read_amr() & (AMR_AD_BIT << pkey_shift));
+}
+
+static inline bool pkey_allows_write(int pkey)
+{
+	int pkey_shift = (arch_max_pkey()-pkey-1) * AMR_BITS_PER_PKEY;
+
+	if (!(read_uamor() & (0x3ul << pkey_shift)))
+		return true;
+
+	return !(read_amr() & (AMR_WD_BIT << pkey_shift));
+}
+
+static inline bool pkey_allows_execute(int pkey)
+{
+	int pkey_shift = (arch_max_pkey()-pkey-1) * AMR_BITS_PER_PKEY;
+
+	if (!(read_uamor() & (0x3ul << pkey_shift)))
+		return true;
+
+	return !(read_iamr() & (IAMR_EX_BIT << pkey_shift));
+}
+
+
 /*
  * set the access right in AMR IAMR and UAMOR register
  * for @pkey to that specified in @init_val.
@@ -175,3 +206,62 @@ int __arch_override_mprotect_pkey(struct vm_area_struct *vma, int prot,
 	 */
 	return vma_pkey(vma);
 }
+
+bool arch_pte_access_permitted(pte_t pte, bool write)
+{
+	int pkey = pte_flags_to_pkey(pte_val(pte));
+
+	if (!pkey_allows_read(pkey))
+		return false;
+	if (write && !pkey_allows_write(pkey))
+		return false;
+	return true;
+}
+
+/*
+ * We only want to enforce protection keys on the current process
+ * because we effectively have no access to AMR/IAMR for other
+ * processes or any way to tell *which * AMR/IAMR in a threaded
+ * process we could use.
+ *
+ * So do not enforce things if the VMA is not from the current
+ * mm, or if we are in a kernel thread.
+ */
+static inline bool vma_is_foreign(struct vm_area_struct *vma)
+{
+	if (!current->mm)
+		return true;
+	/*
+	 * if the VMA is from another process, then AMR/IAMR has no
+	 * relevance and should not be enforced.
+	 */
+	if (current->mm != vma->vm_mm)
+		return true;
+
+	return false;
+}
+
+bool arch_vma_access_permitted(struct vm_area_struct *vma,
+		bool write, bool execute, bool foreign)
+{
+	int pkey;
+	/* allow access if the VMA is not one from this process */
+	if (foreign || vma_is_foreign(vma))
+		return true;
+
+	pkey = vma_pkey(vma);
+
+	if (!pkey)
+		return true;
+
+	if (execute)
+		return pkey_allows_execute(pkey);
+
+	if (!pkey_allows_read(pkey))
+		return false;
+
+	if (write)
+		return pkey_allows_write(pkey);
+
+	return true;
+}
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
