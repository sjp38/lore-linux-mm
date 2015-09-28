Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1229782F64
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 15:18:44 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so85261581pab.3
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 12:18:43 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id qo8si14118536pac.117.2015.09.28.12.18.23
        for <linux-mm@kvack.org>;
        Mon, 28 Sep 2015 12:18:24 -0700 (PDT)
Subject: [PATCH 15/25] x86, pkeys: check VMAs and PTEs for protection keys
From: Dave Hansen <dave@sr71.net>
Date: Mon, 28 Sep 2015 12:18:23 -0700
References: <20150928191817.035A64E2@viggo.jf.intel.com>
In-Reply-To: <20150928191817.035A64E2@viggo.jf.intel.com>
Message-Id: <20150928191823.CAE64CF3@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: borntraeger@de.ibm.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

Today, for normal faults and page table walks, we check the VMA
and/or PTE to ensure that it is compatible with the action.  For
instance, if we get a write fault on a non-writeable VMA, we
SIGSEGV.

We try to do the same thing for protection keys.  Basically, we
try to make sure that if a user does this:

	mprotect(ptr, size, PROT_NONE);
	*ptr = foo;

they see the same effects with protection keys when they do this:

	mprotect(ptr, size, PROT_READ|PROT_WRITE);
	set_pkey(ptr, size, 4);
	wrpkru(0xffffff3f); // access disable pkey 4
	*ptr = foo;

The state to do that checking is in the VMA, but we also
sometimes have to do it on the page tables only, like when doing
a get_user_pages_fast() where we have no VMA.

We add two functions and expose them to generic code:

	arch_pte_access_permitted(pte, write)
	arch_vma_access_permitted(vma, write)

These are, of course, backed up in x86 arch code with checks
against the PTE or VMA's protection key.

But, there are also cases where we do not want to respect
protection keys.  When we ptrace(), for instance, we do not want
to apply the tracer's PKRU permissions to the PTEs from the
process being traced.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/arch/powerpc/include/asm/mmu_context.h   |   11 ++++++
 b/arch/s390/include/asm/mmu_context.h      |   11 ++++++
 b/arch/unicore32/include/asm/mmu_context.h |   11 ++++++
 b/arch/x86/include/asm/mmu_context.h       |   51 ++++++++++++++++++++++++++++-
 b/arch/x86/include/asm/pgtable.h           |   29 ++++++++++++++++
 b/arch/x86/mm/fault.c                      |   21 +++++++++++
 b/arch/x86/mm/gup.c                        |    3 +
 b/include/asm-generic/mm_hooks.h           |   11 ++++++
 b/mm/gup.c                                 |   17 ++++++++-
 b/mm/memory.c                              |    4 ++
 10 files changed, 165 insertions(+), 4 deletions(-)

diff -puN arch/powerpc/include/asm/mmu_context.h~pkeys-11-pte-fault arch/powerpc/include/asm/mmu_context.h
--- a/arch/powerpc/include/asm/mmu_context.h~pkeys-11-pte-fault	2015-09-28 11:39:47.619258875 -0700
+++ b/arch/powerpc/include/asm/mmu_context.h	2015-09-28 11:39:47.637259694 -0700
@@ -148,5 +148,16 @@ static inline void arch_bprm_mm_init(str
 {
 }
 
+static inline bool arch_vma_access_permitted(struct vm_area_struct *vma, bool write)
+{
+	/* by default, allow everything */
+	return true;
+}
+
+static inline bool arch_pte_access_permitted(pte_t pte, bool write)
+{
+	/* by default, allow everything */
+	return true;
+}
 #endif /* __KERNEL__ */
 #endif /* __ASM_POWERPC_MMU_CONTEXT_H */
diff -puN arch/s390/include/asm/mmu_context.h~pkeys-11-pte-fault arch/s390/include/asm/mmu_context.h
--- a/arch/s390/include/asm/mmu_context.h~pkeys-11-pte-fault	2015-09-28 11:39:47.621258967 -0700
+++ b/arch/s390/include/asm/mmu_context.h	2015-09-28 11:39:47.638259740 -0700
@@ -130,4 +130,15 @@ static inline void arch_bprm_mm_init(str
 {
 }
 
+static inline bool arch_vma_access_permitted(struct vm_area_struct *vma, bool write)
+{
+	/* by default, allow everything */
+	return true;
+}
+
+static inline bool arch_pte_access_permitted(pte_t pte, bool write)
+{
+	/* by default, allow everything */
+	return true;
+}
 #endif /* __S390_MMU_CONTEXT_H */
diff -puN arch/unicore32/include/asm/mmu_context.h~pkeys-11-pte-fault arch/unicore32/include/asm/mmu_context.h
--- a/arch/unicore32/include/asm/mmu_context.h~pkeys-11-pte-fault	2015-09-28 11:39:47.622259012 -0700
+++ b/arch/unicore32/include/asm/mmu_context.h	2015-09-28 11:39:47.638259740 -0700
@@ -97,4 +97,15 @@ static inline void arch_bprm_mm_init(str
 {
 }
 
+static inline bool arch_vma_access_permitted(struct vm_area_struct *vma, bool write)
+{
+	/* by default, allow everything */
+	return true;
+}
+
+static inline bool arch_pte_access_permitted(pte_t pte, bool write)
+{
+	/* by default, allow everything */
+	return true;
+}
 #endif
diff -puN arch/x86/include/asm/mmu_context.h~pkeys-11-pte-fault arch/x86/include/asm/mmu_context.h
--- a/arch/x86/include/asm/mmu_context.h~pkeys-11-pte-fault	2015-09-28 11:39:47.624259103 -0700
+++ b/arch/x86/include/asm/mmu_context.h	2015-09-28 11:39:47.638259740 -0700
@@ -263,4 +263,53 @@ static inline u16 vma_pkey(struct vm_are
 	return pkey;
 }
 
-#endif /* _ASM_X86_MMU_CONTEXT_H */
+static inline bool __pkru_allows_pkey(u16 pkey, bool write)
+{
+	u32 pkru = read_pkru();
+
+	if (!__pkru_allows_read(pkru, pkey))
+		return false;
+	if (write && !__pkru_allows_write(pkru, pkey))
+		return false;
+
+	return true;
+}
+
+/*
+ * We only want to enforce protection keys on the current process
+ * because we effectively have no access to PKRU for other
+ * processes or any way to tell *which * PKRU in a threaded
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
+	 * Should PKRU be enforced on the access to this VMA?  If
+	 * the VMA is from another process, then PKRU has no
+	 * relevance and should not be enforced.
+	 */
+	if (current->mm != vma->vm_mm)
+		return true;
+
+	return false;
+}
+
+static inline bool arch_vma_access_permitted(struct vm_area_struct *vma, bool write)
+{
+	/* allow access if the VMA is not one from this process */
+	if (vma_is_foreign(vma))
+		return true;
+	return __pkru_allows_pkey(vma_pkey(vma), write);
+}
+
+static inline bool arch_pte_access_permitted(pte_t pte, bool write)
+{
+	return __pkru_allows_pkey(pte_pkey(pte), write);
+}
+
+#endif /* _ASM_X86_MMUeCONTEXT_H */
diff -puN arch/x86/include/asm/pgtable.h~pkeys-11-pte-fault arch/x86/include/asm/pgtable.h
--- a/arch/x86/include/asm/pgtable.h~pkeys-11-pte-fault	2015-09-28 11:39:47.626259194 -0700
+++ b/arch/x86/include/asm/pgtable.h	2015-09-28 11:39:47.639259785 -0700
@@ -889,6 +889,35 @@ static inline pte_t pte_swp_clear_soft_d
 }
 #endif
 
+#define PKRU_AD_BIT 0x1
+#define PKRU_WD_BIT 0x2
+
+static inline bool __pkru_allows_read(u32 pkru, u16 pkey)
+{
+	int pkru_pkey_bits = pkey * 2;
+	return !(pkru & (PKRU_AD_BIT << pkru_pkey_bits));
+}
+
+static inline bool __pkru_allows_write(u32 pkru, u16 pkey)
+{
+	int pkru_pkey_bits = pkey * 2;
+	/*
+	 * Access-disable disables writes too so we need to check
+	 * both bits here.
+	 */
+	return !(pkru & ((PKRU_AD_BIT|PKRU_WD_BIT) << pkru_pkey_bits));
+}
+
+static inline u16 pte_pkey(pte_t pte)
+{
+#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
+	/* ifdef to avoid doing 59-bit shift on 32-bit values */
+	return (pte_flags(pte) & _PAGE_PKEY_MASK) >> _PAGE_BIT_PKEY_BIT0;
+#else
+	return 0;
+#endif
+}
+
 #include <asm-generic/pgtable.h>
 #endif	/* __ASSEMBLY__ */
 
diff -puN arch/x86/mm/fault.c~pkeys-11-pte-fault arch/x86/mm/fault.c
--- a/arch/x86/mm/fault.c~pkeys-11-pte-fault	2015-09-28 11:39:47.627259240 -0700
+++ b/arch/x86/mm/fault.c	2015-09-28 11:39:47.639259785 -0700
@@ -897,11 +897,21 @@ bad_area(struct pt_regs *regs, unsigned
 	__bad_area(regs, error_code, address, NULL, SEGV_MAPERR);
 }
 
+static inline bool bad_area_access_from_pkeys(unsigned long error_code,
+		struct vm_area_struct *vma)
+{
+	if (!boot_cpu_has(X86_FEATURE_OSPKE))
+		return false;
+	if (error_code & PF_PK)
+		return true;
+	return false;
+}
+
 static noinline void
 bad_area_access_error(struct pt_regs *regs, unsigned long error_code,
 		      unsigned long address, struct vm_area_struct *vma)
 {
-	if (boot_cpu_has(X86_FEATURE_OSPKE) && (error_code & PF_PK))
+	if (bad_area_access_from_pkeys(error_code, vma))
 		__bad_area(regs, error_code, address, vma, SEGV_PKUERR);
 	else
 		__bad_area(regs, error_code, address, vma, SEGV_ACCERR);
@@ -1073,6 +1083,15 @@ int show_unhandled_signals = 1;
 static inline int
 access_error(unsigned long error_code, struct vm_area_struct *vma)
 {
+	/*
+	 * Access or read was blocked by protection keys. We do
+	 * this check before any others because we do not want
+	 * to, for instance, confuse a protection-key-denied
+	 * write with one for which we should do a COW.
+	 */
+	if (error_code & PF_PK)
+		return 1;
+
 	if (error_code & PF_WRITE) {
 		/* write, present and write, not present: */
 		if (unlikely(!(vma->vm_flags & VM_WRITE)))
diff -puN arch/x86/mm/gup.c~pkeys-11-pte-fault arch/x86/mm/gup.c
--- a/arch/x86/mm/gup.c~pkeys-11-pte-fault	2015-09-28 11:39:47.629259330 -0700
+++ b/arch/x86/mm/gup.c	2015-09-28 11:39:47.640259831 -0700
@@ -10,6 +10,7 @@
 #include <linux/highmem.h>
 #include <linux/swap.h>
 
+#include <asm/mmu_context.h>
 #include <asm/pgtable.h>
 
 static inline pte_t gup_get_pte(pte_t *ptep)
@@ -73,6 +74,8 @@ static inline int pte_allows_gup(pte_t p
 		return 0;
 	if (write && !pte_write(pte))
 		return 0;
+	if (!arch_pte_access_permitted(pte, write))
+		return 0;
 	return 1;
 }
 
diff -puN include/asm-generic/mm_hooks.h~pkeys-11-pte-fault include/asm-generic/mm_hooks.h
--- a/include/asm-generic/mm_hooks.h~pkeys-11-pte-fault	2015-09-28 11:39:47.631259421 -0700
+++ b/include/asm-generic/mm_hooks.h	2015-09-28 11:39:47.640259831 -0700
@@ -26,4 +26,15 @@ static inline void arch_bprm_mm_init(str
 {
 }
 
+static inline bool arch_vma_access_permitted(struct vm_area_struct *vma, bool write)
+{
+	/* by default, allow everything */
+	return true;
+}
+
+static inline bool arch_pte_access_permitted(pte_t pte, bool write)
+{
+	/* by default, allow everything */
+	return true;
+}
 #endif	/* _ASM_GENERIC_MM_HOOKS_H */
diff -puN mm/gup.c~pkeys-11-pte-fault mm/gup.c
--- a/mm/gup.c~pkeys-11-pte-fault	2015-09-28 11:39:47.632259467 -0700
+++ b/mm/gup.c	2015-09-28 11:39:47.641259876 -0700
@@ -13,6 +13,7 @@
 #include <linux/rwsem.h>
 #include <linux/hugetlb.h>
 
+#include <asm/mmu_context.h>
 #include <asm/pgtable.h>
 #include <asm/tlbflush.h>
 
@@ -388,6 +389,8 @@ static int check_vma_flags(struct vm_are
 		if (!(vm_flags & VM_MAYREAD))
 			return -EFAULT;
 	}
+	if (!arch_vma_access_permitted(vma, (gup_flags & FOLL_WRITE)))
+		return -EFAULT;
 	return 0;
 }
 
@@ -556,12 +559,19 @@ EXPORT_SYMBOL(__get_user_pages);
 
 bool vma_permits_fault(struct vm_area_struct *vma, unsigned int fault_flags)
 {
-        vm_flags_t vm_flags =
-		(fault_flags & FAULT_FLAG_WRITE) ? VM_WRITE : VM_READ;
+	int write = (fault_flags & FAULT_FLAG_WRITE);
+	vm_flags_t vm_flags = write ? VM_WRITE : VM_READ;
 
 	if (!(vm_flags & vma->vm_flags))
 		return false;
 
+	/*
+	 * The architecture might have a hardware protection
+	 * mechanism other than read/write that can deny access
+	 */
+	if (!arch_vma_access_permitted(vma, write))
+		return false;
+
 	return true;
 }
 
@@ -1079,6 +1089,9 @@ static int gup_pte_range(pmd_t pmd, unsi
 			pte_protnone(pte) || (write && !pte_write(pte)))
 			goto pte_unmap;
 
+		if (!arch_pte_access_permitted(pte, write))
+			goto pte_unmap;
+
 		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
 		page = pte_page(pte);
 
diff -puN mm/memory.c~pkeys-11-pte-fault mm/memory.c
--- a/mm/memory.c~pkeys-11-pte-fault	2015-09-28 11:39:47.634259558 -0700
+++ b/mm/memory.c	2015-09-28 11:39:47.642259922 -0700
@@ -64,6 +64,7 @@
 #include <linux/userfaultfd_k.h>
 
 #include <asm/io.h>
+#include <asm/mmu_context.h>
 #include <asm/pgalloc.h>
 #include <asm/uaccess.h>
 #include <asm/tlb.h>
@@ -3342,6 +3343,9 @@ static int __handle_mm_fault(struct mm_s
 	pmd_t *pmd;
 	pte_t *pte;
 
+	if (!arch_vma_access_permitted(vma, flags & FAULT_FLAG_WRITE))
+		return VM_FAULT_SIGSEGV;
+
 	if (unlikely(is_vm_hugetlb_page(vma)))
 		return hugetlb_fault(mm, vma, address, flags);
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
