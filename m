Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id E0B036B033C
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 21:40:20 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id o41so1162272qtf.8
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 18:40:20 -0700 (PDT)
Received: from mail-qk0-x243.google.com (mail-qk0-x243.google.com. [2607:f8b0:400d:c09::243])
        by mx.google.com with ESMTPS id 33si51940qta.368.2017.06.21.18.40.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 18:40:19 -0700 (PDT)
Received: by mail-qk0-x243.google.com with SMTP id r62so356848qkf.3
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 18:40:19 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v3 12/23] powerpc: Implement sys_pkey_alloc and sys_pkey_free system call
Date: Wed, 21 Jun 2017 18:39:28 -0700
Message-Id: <1498095579-6790-13-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1498095579-6790-1-git-send-email-linuxram@us.ibm.com>
References: <1498095579-6790-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

Sys_pkey_alloc() allocates and returns available pkey
Sys_pkey_free()  frees up the pkey.

Total 32 keys are supported on powerpc. However pkey 0,1 and 31
are reserved. So effectively we have 29 pkeys.

Each key  can  be  initialized  to disable read, write and execute
permissions. On powerpc a key can be initialize to disable execute.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/Kconfig                         |  15 ++++
 arch/powerpc/include/asm/book3s/64/mmu.h     |  10 +++
 arch/powerpc/include/asm/book3s/64/pgtable.h |  62 ++++++++++++++
 arch/powerpc/include/asm/pkeys.h             | 124 +++++++++++++++++++++++++++
 arch/powerpc/include/asm/systbl.h            |   2 +
 arch/powerpc/include/asm/unistd.h            |   4 +-
 arch/powerpc/include/uapi/asm/unistd.h       |   2 +
 arch/powerpc/mm/Makefile                     |   1 +
 arch/powerpc/mm/mmu_context_book3s64.c       |   5 ++
 arch/powerpc/mm/pkeys.c                      |  88 +++++++++++++++++++
 10 files changed, 310 insertions(+), 3 deletions(-)
 create mode 100644 arch/powerpc/include/asm/pkeys.h
 create mode 100644 arch/powerpc/mm/pkeys.c

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index f7c8f99..b6960617 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -871,6 +871,21 @@ config SECCOMP
 
 	  If unsure, say Y. Only embedded should say N here.
 
+config PPC64_MEMORY_PROTECTION_KEYS
+	prompt "PowerPC Memory Protection Keys"
+	def_bool y
+	# Note: only available in 64-bit mode
+	depends on PPC64 && PPC_64K_PAGES
+	select ARCH_USES_HIGH_VMA_FLAGS
+	select ARCH_HAS_PKEYS
+	---help---
+	  Memory Protection Keys provides a mechanism for enforcing
+	  page-based protections, but without requiring modification of the
+	  page tables when an application changes protection domains.
+
+	  For details, see Documentation/powerpc/protection-keys.txt
+
+	  If unsure, say y.
 endmenu
 
 config ISA_DMA_API
diff --git a/arch/powerpc/include/asm/book3s/64/mmu.h b/arch/powerpc/include/asm/book3s/64/mmu.h
index 77529a3..0c0a2a8 100644
--- a/arch/powerpc/include/asm/book3s/64/mmu.h
+++ b/arch/powerpc/include/asm/book3s/64/mmu.h
@@ -108,6 +108,16 @@ struct patb_entry {
 #ifdef CONFIG_SPAPR_TCE_IOMMU
 	struct list_head iommu_group_mem_list;
 #endif
+
+#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
+	/*
+	 * Each bit represents one protection key.
+	 * bit set   -> key allocated
+	 * bit unset -> key available for allocation
+	 */
+	u32 pkey_allocation_map;
+	s16 execute_only_pkey; /* key holding execute-only protection */
+#endif
 } mm_context_t;
 
 /*
diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index 85bc987..87e9a89 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -428,6 +428,68 @@ static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
 		pte_update(mm, addr, ptep, 0, _PAGE_PRIVILEGED, 1);
 }
 
+
+#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
+
+#include <asm/reg.h>
+static inline u64 read_amr(void)
+{
+	return mfspr(SPRN_AMR);
+}
+static inline void write_amr(u64 value)
+{
+	mtspr(SPRN_AMR, value);
+}
+static inline u64 read_iamr(void)
+{
+	return mfspr(SPRN_IAMR);
+}
+static inline void write_iamr(u64 value)
+{
+	mtspr(SPRN_IAMR, value);
+}
+static inline u64 read_uamor(void)
+{
+	return mfspr(SPRN_UAMOR);
+}
+static inline void write_uamor(u64 value)
+{
+	mtspr(SPRN_UAMOR, value);
+}
+
+#else /* CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
+
+static inline u64 read_amr(void)
+{
+	WARN(1, "%s called with MEMORY PROTECTION KEYS disabled\n", __func__);
+	return -1;
+}
+static inline void write_amr(u64 value)
+{
+	WARN(1, "%s called with MEMORY PROTECTION KEYS disabled\n", __func__);
+}
+static inline u64 read_uamor(void)
+{
+	WARN(1, "%s called with MEMORY PROTECTION KEYS disabled\n", __func__);
+	return -1;
+}
+static inline void write_uamor(u64 value)
+{
+	WARN(1, "%s called with MEMORY PROTECTION KEYS disabled\n", __func__);
+}
+static inline u64 read_iamr(void)
+{
+	WARN(1, "%s called with MEMORY PROTECTION KEYS disabled\n", __func__);
+	return -1;
+}
+static inline void write_iamr(u64 value)
+{
+	WARN(1, "%s called with MEMORY PROTECTION KEYS disabled\n", __func__);
+}
+
+#endif /* CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
+
+
 #define __HAVE_ARCH_PTEP_GET_AND_CLEAR
 static inline pte_t ptep_get_and_clear(struct mm_struct *mm,
 				       unsigned long addr, pte_t *ptep)
diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
new file mode 100644
index 0000000..7bc8746
--- /dev/null
+++ b/arch/powerpc/include/asm/pkeys.h
@@ -0,0 +1,124 @@
+#ifndef _ASM_PPC64_PKEYS_H
+#define _ASM_PPC64_PKEYS_H
+
+
+#define arch_max_pkey()  32
+
+#define AMR_AD_BIT 0x1UL
+#define AMR_WD_BIT 0x2UL
+#define IAMR_EX_BIT 0x1UL
+#define AMR_BITS_PER_PKEY 2
+#define ARCH_VM_PKEY_FLAGS (VM_PKEY_BIT0 | \
+			VM_PKEY_BIT1 | \
+			VM_PKEY_BIT2 | \
+			VM_PKEY_BIT3 | \
+			VM_PKEY_BIT4)
+
+/*
+ * Bits are in BE format.
+ * NOTE: key 31, 1, 0 are not used.
+ * key 0 is used by default. It give read/write/execute permission.
+ * key 31 is reserved by the hypervisor.
+ * key 1 is recommended to be not used.
+ * PowerISA(3.0) page 1015, programming note.
+ */
+#define PKEY_INITIAL_ALLOCAION  0xc0000001
+
+#define pkeybit_mask(pkey) (0x1 << (arch_max_pkey() - pkey - 1))
+
+#define mm_pkey_allocation_map(mm)	(mm->context.pkey_allocation_map)
+
+#define mm_set_pkey_allocated(mm, pkey) {	\
+	mm_pkey_allocation_map(mm) |= pkeybit_mask(pkey); \
+}
+
+#define mm_set_pkey_free(mm, pkey) {	\
+	mm_pkey_allocation_map(mm) &= ~pkeybit_mask(pkey);	\
+}
+
+#define mm_set_pkey_is_allocated(mm, pkey)	\
+	(mm_pkey_allocation_map(mm) & pkeybit_mask(pkey))
+
+#define mm_set_pkey_is_reserved(mm, pkey) (PKEY_INITIAL_ALLOCAION & \
+					pkeybit_mask(pkey))
+
+static inline bool mm_pkey_is_allocated(struct mm_struct *mm, int pkey)
+{
+	/* a reserved key is never considered as 'explicitly allocated' */
+	return (!mm_set_pkey_is_reserved(mm, pkey) &&
+		mm_set_pkey_is_allocated(mm, pkey));
+}
+
+/*
+ * Returns a positive, 5-bit key on success, or -1 on failure.
+ */
+static inline int mm_pkey_alloc(struct mm_struct *mm)
+{
+	/*
+	 * Note: this is the one and only place we make sure
+	 * that the pkey is valid as far as the hardware is
+	 * concerned.  The rest of the kernel trusts that
+	 * only good, valid pkeys come out of here.
+	 */
+	u32 all_pkeys_mask = (u32)(~(0x0));
+	int ret;
+
+	/*
+	 * Are we out of pkeys?  We must handle this specially
+	 * because ffz() behavior is undefined if there are no
+	 * zeros.
+	 */
+	if (mm_pkey_allocation_map(mm) == all_pkeys_mask)
+		return -1;
+
+	ret = arch_max_pkey() -
+		ffz((u32)mm_pkey_allocation_map(mm))
+		- 1;
+	mm_set_pkey_allocated(mm, ret);
+	return ret;
+}
+
+static inline int mm_pkey_free(struct mm_struct *mm, int pkey)
+{
+	if (!mm_pkey_is_allocated(mm, pkey))
+		return -EINVAL;
+
+	mm_set_pkey_free(mm, pkey);
+
+	return 0;
+}
+
+/*
+ * Try to dedicate one of the protection keys to be used as an
+ * execute-only protection key.
+ */
+extern int __execute_only_pkey(struct mm_struct *mm);
+static inline int execute_only_pkey(struct mm_struct *mm)
+{
+	return __execute_only_pkey(mm);
+}
+
+extern int __arch_override_mprotect_pkey(struct vm_area_struct *vma,
+		int prot, int pkey);
+static inline int arch_override_mprotect_pkey(struct vm_area_struct *vma,
+		int prot, int pkey)
+{
+	return __arch_override_mprotect_pkey(vma, prot, pkey);
+}
+
+extern int __arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
+		unsigned long init_val);
+static inline int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
+		unsigned long init_val)
+{
+	return __arch_set_user_pkey_access(tsk, pkey, init_val);
+}
+
+static inline pkey_mm_init(struct mm_struct *mm)
+{
+	mm_pkey_allocation_map(mm) = PKEY_INITIAL_ALLOCAION;
+	/* -1 means unallocated or invalid */
+	mm->context.execute_only_pkey = -1;
+}
+
+#endif /*_ASM_PPC64_PKEYS_H */
diff --git a/arch/powerpc/include/asm/systbl.h b/arch/powerpc/include/asm/systbl.h
index 1c94708..22dd776 100644
--- a/arch/powerpc/include/asm/systbl.h
+++ b/arch/powerpc/include/asm/systbl.h
@@ -388,3 +388,5 @@
 COMPAT_SYS_SPU(pwritev2)
 SYSCALL(kexec_file_load)
 SYSCALL(statx)
+SYSCALL(pkey_alloc)
+SYSCALL(pkey_free)
diff --git a/arch/powerpc/include/asm/unistd.h b/arch/powerpc/include/asm/unistd.h
index 9ba11db..e0273bc 100644
--- a/arch/powerpc/include/asm/unistd.h
+++ b/arch/powerpc/include/asm/unistd.h
@@ -12,13 +12,11 @@
 #include <uapi/asm/unistd.h>
 
 
-#define NR_syscalls		384
+#define NR_syscalls		386
 
 #define __NR__exit __NR_exit
 
 #define __IGNORE_pkey_mprotect
-#define __IGNORE_pkey_alloc
-#define __IGNORE_pkey_free
 
 #ifndef __ASSEMBLY__
 
diff --git a/arch/powerpc/include/uapi/asm/unistd.h b/arch/powerpc/include/uapi/asm/unistd.h
index b85f142..7993a07 100644
--- a/arch/powerpc/include/uapi/asm/unistd.h
+++ b/arch/powerpc/include/uapi/asm/unistd.h
@@ -394,5 +394,7 @@
 #define __NR_pwritev2		381
 #define __NR_kexec_file_load	382
 #define __NR_statx		383
+#define __NR_pkey_alloc		384
+#define __NR_pkey_free		385
 
 #endif /* _UAPI_ASM_POWERPC_UNISTD_H_ */
diff --git a/arch/powerpc/mm/Makefile b/arch/powerpc/mm/Makefile
index 7414034..8cc2ff1 100644
--- a/arch/powerpc/mm/Makefile
+++ b/arch/powerpc/mm/Makefile
@@ -45,3 +45,4 @@ obj-$(CONFIG_PPC_COPRO_BASE)	+= copro_fault.o
 obj-$(CONFIG_SPAPR_TCE_IOMMU)	+= mmu_context_iommu.o
 obj-$(CONFIG_PPC_PTDUMP)	+= dump_linuxpagetables.o
 obj-$(CONFIG_PPC_HTDUMP)	+= dump_hashpagetable.o
+obj-$(CONFIG_PPC64_MEMORY_PROTECTION_KEYS)	+= pkeys.o
diff --git a/arch/powerpc/mm/mmu_context_book3s64.c b/arch/powerpc/mm/mmu_context_book3s64.c
index c6dca2a..2da9931 100644
--- a/arch/powerpc/mm/mmu_context_book3s64.c
+++ b/arch/powerpc/mm/mmu_context_book3s64.c
@@ -16,6 +16,7 @@
 #include <linux/string.h>
 #include <linux/types.h>
 #include <linux/mm.h>
+#include <linux/pkeys.h>
 #include <linux/spinlock.h>
 #include <linux/idr.h>
 #include <linux/export.h>
@@ -120,6 +121,10 @@ static int hash__init_new_context(struct mm_struct *mm)
 
 	subpage_prot_init_new_context(mm);
 
+#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
+	pkey_mm_init(mm);
+#endif /* CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
+
 	return index;
 }
 
diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
new file mode 100644
index 0000000..b97366e
--- /dev/null
+++ b/arch/powerpc/mm/pkeys.c
@@ -0,0 +1,88 @@
+/*
+ * PowerPC Memory Protection Keys management
+ * Copyright (c) 2015, Intel Corporation.
+ * Copyright (c) 2017, IBM Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ */
+#include <linux/pkeys.h>                /* PKEY_*                       */
+#include <uapi/asm-generic/mman-common.h>
+
+
+/*
+ * set the access right in AMR IAMR and UAMOR register
+ * for @pkey to that specified in @init_val.
+ */
+int __arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
+		unsigned long init_val)
+{
+	u64 old_amr, old_uamor, old_iamr;
+	int pkey_shift = (arch_max_pkey()-pkey-1) * AMR_BITS_PER_PKEY;
+	u64 new_amr_bits = 0x0ul;
+	u64 new_iamr_bits = 0x0ul;
+	u64 new_uamor_bits = 0x3ul;
+
+	/* Set the bits we need in AMR:  */
+	if (init_val & PKEY_DISABLE_ACCESS)
+		new_amr_bits |= AMR_AD_BIT;
+	if (init_val & PKEY_DISABLE_WRITE)
+		new_amr_bits |= AMR_WD_BIT;
+
+	/*
+	 * By default execute is disabled.
+	 * To enable execute, PKEY_ENABLE_EXECUTE
+	 * needs to be specified.
+	 */
+	if ((init_val & PKEY_DISABLE_EXECUTE))
+		new_iamr_bits |= IAMR_EX_BIT;
+
+	/* Shift the bits in to the correct place in AMR for pkey: */
+	new_amr_bits	<<= pkey_shift;
+	new_iamr_bits	<<= pkey_shift;
+	new_uamor_bits	<<= pkey_shift;
+
+	/* Get old AMR and mask off any old bits in place: */
+	old_amr	= read_amr();
+	old_amr	&= ~((u64)(AMR_AD_BIT|AMR_WD_BIT) << pkey_shift);
+
+	old_iamr = read_iamr();
+	old_iamr &= ~(0x3ul << pkey_shift);
+
+	old_uamor = read_uamor();
+	old_uamor &= ~(0x3ul << pkey_shift);
+
+	/* Write old part along with new part: */
+	write_amr(old_amr | new_amr_bits);
+	write_iamr(old_iamr | new_iamr_bits);
+	write_uamor(old_uamor | new_uamor_bits);
+
+	return 0;
+}
+
+int __execute_only_pkey(struct mm_struct *mm)
+{
+	return -1;
+}
+
+/*
+ * This should only be called for *plain* mprotect calls.
+ */
+int __arch_override_mprotect_pkey(struct vm_area_struct *vma, int prot,
+		int pkey)
+{
+	/*
+	 * Is this an mprotect_pkey() call?  If so, never
+	 * override the value that came from the user.
+	 */
+	if (pkey != -1)
+		return pkey;
+
+	return 0;
+}
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
