Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id EB0156B0267
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 14:06:19 -0500 (EST)
Received: by pfbo64 with SMTP id o64so31304984pfb.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 11:06:19 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id rk9si10538124pab.31.2015.12.14.11.06.13
        for <linux-mm@kvack.org>;
        Mon, 14 Dec 2015 11:06:13 -0800 (PST)
Subject: [PATCH 17/32] x86, pkeys: check VMAs and PTEs for protection keys
From: Dave Hansen <dave@sr71.net>
Date: Mon, 14 Dec 2015 11:06:12 -0800
References: <20151214190542.39C4886D@viggo.jf.intel.com>
In-Reply-To: <20151214190542.39C4886D@viggo.jf.intel.com>
Message-Id: <20151214190612.32A72AD2@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


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

	arch_pte_access_permitted(pte_flags, write)
	arch_vma_access_permitted(vma, write)

These are, of course, backed up in x86 arch code with checks
against the PTE or VMA's protection key.

But, there are also cases where we do not want to respect
protection keys.  When we ptrace(), for instance, we do not want
to apply the tracer's PKRU permissions to the PTEs from the
process being traced.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
---

 b/arch/powerpc/include/asm/mmu_context.h   |   11 ++++++
 b/arch/s390/include/asm/mmu_context.h      |   11 ++++++
 b/arch/unicore32/include/asm/mmu_context.h |   11 ++++++
 b/arch/x86/include/asm/mmu_context.h       |   49 +++++++++++++++++++++++++++++
 b/arch/x86/include/asm/pgtable.h           |   29 +++++++++++++++++
 b/arch/x86/mm/fault.c                      |   21 +++++++++++-
 b/arch/x86/mm/gup.c                        |    5 ++
 b/include/asm-generic/mm_hooks.h           |   11 ++++++
 b/mm/gup.c                                 |   18 ++++++++--
 b/mm/memory.c                              |    4 ++
 10 files changed, 166 insertions(+), 4 deletions(-)

diff -puN arch/powerpc/include/asm/mmu_context.h~pkeys-13-pte-fault arch/powerpc/include/asm/mmu_context.h
--- a/arch/powerpc/include/asm/mmu_context.h~pkeys-13-pte-fault	2015-12-14 10:42:46.096950632 -0800
+++ b/arch/powerpc/include/asm/mmu_context.h	2015-12-14 10:42:46.114951438 -0800
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
diff -puN arch/s390/include/asm/mmu_context.h~pkeys-13-pte-fault arch/s390/include/asm/mmu_context.h
--- a/arch/s390/include/asm/mmu_context.h~pkeys-13-pte-fault	2015-12-14 10:42:46.098950721 -0800
+++ b/arch/s390/include/asm/mmu_context.h	2015-12-14 10:42:46.114951438 -0800
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
diff -puN arch/unicore32/include/asm/mmu_context.h~pkeys-13-pte-fault arch/unicore32/include/asm/mmu_context.h
--- a/arch/unicore32/include/asm/mmu_context.h~pkeys-13-pte-fault	2015-12-14 10:42:46.099950766 -0800
+++ b/arch/unicore32/include/asm/mmu_context.h	2015-12-14 10:42:46.114951438 -0800
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
diff -puN arch/x86/include/asm/mmu_context.h~pkeys-13-pte-fault arch/x86/include/asm/mmu_context.h
--- a/arch/x86/include/asm/mmu_context.h~pkeys-13-pte-fault	2015-12-14 10:42:46.101950856 -0800
+++ b/arch/x86/include/asm/mmu_context.h	2015-12-14 10:42:46.115951483 -0800
@@ -254,4 +254,53 @@ static inline int vma_pkey(struct vm_are
 	return pkey;
 }
 
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
+	return __pkru_allows_pkey(pte_flags_pkey(pte_flags(pte)), write);
+}
+
 #endif /* _ASM_X86_MMU_CONTEXT_H */
diff -puN arch/x86/include/asm/pgtable.h~pkeys-13-pte-fault arch/x86/include/asm/pgtable.h
--- a/arch/x86/include/asm/pgtable.h~pkeys-13-pte-fault	2015-12-14 10:42:46.103950945 -0800
+++ b/arch/x86/include/asm/pgtable.h	2015-12-14 10:42:46.115951483 -0800
@@ -910,6 +910,35 @@ static inline pte_t pte_swp_clear_soft_d
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
+static inline u16 pte_flags_pkey(unsigned long pte_flags)
+{
+#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
+	/* ifdef to avoid doing 59-bit shift on 32-bit values */
+	return (pte_flags & _PAGE_PKEY_MASK) >> _PAGE_BIT_PKEY_BIT0;
+#else
+	return 0;
+#endif
+}
+
 #include <asm-generic/pgtable.h>
 #endif	/* __ASSEMBLY__ */
 
diff -puN arch/x86/mm/fault.c~pkeys-13-pte-fault arch/x86/mm/fault.c
--- a/arch/x86/mm/fault.c~pkeys-13-pte-fault	2015-12-14 10:42:46.104950990 -0800
+++ b/arch/x86/mm/fault.c	2015-12-14 10:42:46.116951528 -0800
@@ -897,6 +897,16 @@ bad_area(struct pt_regs *regs, unsigned
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
@@ -906,7 +916,7 @@ bad_area_access_error(struct pt_regs *re
 	 * But, doing it this way allows compiler optimizations
 	 * if pkeys are compiled out.
 	 */
-	if (boot_cpu_has(X86_FEATURE_OSPKE) && (error_code & PF_PK))
+	if (bad_area_access_from_pkeys(error_code, vma))
 		__bad_area(regs, error_code, address, vma, SEGV_PKUERR);
 	else
 		__bad_area(regs, error_code, address, vma, SEGV_ACCERR);
@@ -1081,6 +1091,15 @@ int show_unhandled_signals = 1;
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
diff -puN arch/x86/mm/gup.c~pkeys-13-pte-fault arch/x86/mm/gup.c
--- a/arch/x86/mm/gup.c~pkeys-13-pte-fault	2015-12-14 10:42:46.106951080 -0800
+++ b/arch/x86/mm/gup.c	2015-12-14 10:42:46.116951528 -0800
@@ -10,6 +10,7 @@
 #include <linux/highmem.h>
 #include <linux/swap.h>
 
+#include <asm/mmu_context.h>
 #include <asm/pgtable.h>
 
 static inline pte_t gup_get_pte(pte_t *ptep)
@@ -78,6 +79,10 @@ static inline int pte_allows_gup(unsigne
 	if ((pteval & need_pte_bits) != need_pte_bits)
 		return 0;
 
+	/* Check memory protection keys permissions. */
+	if (!__pkru_allows_pkey(pte_flags_pkey(pteval), write))
+		return 0;
+
 	return 1;
 }
 
diff -puN include/asm-generic/mm_hooks.h~pkeys-13-pte-fault include/asm-generic/mm_hooks.h
--- a/include/asm-generic/mm_hooks.h~pkeys-13-pte-fault	2015-12-14 10:42:46.107951125 -0800
+++ b/include/asm-generic/mm_hooks.h	2015-12-14 10:42:46.116951528 -0800
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
diff -puN mm/gup.c~pkeys-13-pte-fault mm/gup.c
--- a/mm/gup.c~pkeys-13-pte-fault	2015-12-14 10:42:46.109951214 -0800
+++ b/mm/gup.c	2015-12-14 10:42:46.117951573 -0800
@@ -13,6 +13,7 @@
 #include <linux/rwsem.h>
 #include <linux/hugetlb.h>
 
+#include <asm/mmu_context.h>
 #include <asm/pgtable.h>
 #include <asm/tlbflush.h>
 
@@ -391,6 +392,8 @@ static int check_vma_flags(struct vm_are
 		if (!(vm_flags & VM_MAYREAD))
 			return -EFAULT;
 	}
+	if (!arch_vma_access_permitted(vma, (gup_flags & FOLL_WRITE)))
+		return -EFAULT;
 	return 0;
 }
 
@@ -559,13 +562,19 @@ EXPORT_SYMBOL(__get_user_pages);
 
 bool vma_permits_fault(struct vm_area_struct *vma, unsigned int fault_flags)
 {
-	vm_flags_t vm_flags;
-
-	vm_flags = (fault_flags & FAULT_FLAG_WRITE) ? VM_WRITE : VM_READ;
+	bool write = !!(fault_flags & FAULT_FLAG_WRITE);
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
 
@@ -1102,6 +1111,9 @@ static int gup_pte_range(pmd_t pmd, unsi
 			pte_protnone(pte) || (write && !pte_write(pte)))
 			goto pte_unmap;
 
+		if (!arch_pte_access_permitted(pte, write))
+			goto pte_unmap;
+
 		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
 		page = pte_page(pte);
 
diff -puN mm/memory.c~pkeys-13-pte-fault mm/memory.c
--- a/mm/memory.c~pkeys-13-pte-fault	2015-12-14 10:42:46.111951304 -0800
+++ b/mm/memory.c	2015-12-14 10:42:46.118951618 -0800
@@ -64,6 +64,7 @@
 #include <linux/userfaultfd_k.h>
 
 #include <asm/io.h>
+#include <asm/mmu_context.h>
 #include <asm/pgalloc.h>
 #include <asm/uaccess.h>
 #include <asm/tlb.h>
@@ -3344,6 +3345,9 @@ static int __handle_mm_fault(struct mm_s
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
