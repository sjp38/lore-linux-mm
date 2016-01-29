Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id C1C42828DF
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 13:17:10 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id o185so41174897pfb.1
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 10:17:10 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id f2si3531060pas.32.2016.01.29.10.16.57
        for <linux-mm@kvack.org>;
        Fri, 29 Jan 2016 10:16:57 -0800 (PST)
Subject: [PATCH 10/31] x86, pkeys: arch-specific protection bits
From: Dave Hansen <dave@sr71.net>
Date: Fri, 29 Jan 2016 10:16:56 -0800
References: <20160129181642.98E7D468@viggo.jf.intel.com>
In-Reply-To: <20160129181642.98E7D468@viggo.jf.intel.com>
Message-Id: <20160129181656.46AB33CC@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

Lots of things seem to do:

        vma->vm_page_prot = vm_get_page_prot(flags);

and the ptes get created right from things we pull out
of ->vm_page_prot.  So it is very convenient if we can
store the protection key in flags and vm_page_prot, just
like the existing permission bits (_PAGE_RW/PRESENT).  It
greatly reduces the amount of plumbing and arch-specific
hacking we have to do in generic code.

This also takes the new PROT_PKEY{0,1,2,3} flags and
turns *those* in to VM_ flags for vma->vm_flags.

The protection key values are stored in 4 places:
	1. "prot" argument to system calls
	2. vma->vm_flags, filled from the mmap "prot"
	3. vma->vm_page prot, filled from vma->vm_flags
	4. the PTE itself.

The pseudocode for these for steps are as follows:

	mmap(PROT_PKEY*)
	vma->vm_flags 	  = ... | arch_calc_vm_prot_bits(mmap_prot);
	vma->vm_page_prot = ... | arch_vm_get_page_prot(vma->vm_flags);
	pte = pfn | vma->vm_page_prot

Note that this provides a new definitions for x86:

	arch_vm_get_page_prot()

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
---

 b/arch/x86/include/asm/mmu_context.h   |   11 +++++++++++
 b/arch/x86/include/asm/pgtable_types.h |   12 ++++++++++--
 b/arch/x86/include/uapi/asm/mman.h     |   16 ++++++++++++++++
 b/include/linux/mm.h                   |    7 +++++++
 4 files changed, 44 insertions(+), 2 deletions(-)

diff -puN arch/x86/include/asm/mmu_context.h~pkeys-07-store-pkey-in-vma arch/x86/include/asm/mmu_context.h
--- a/arch/x86/include/asm/mmu_context.h~pkeys-07-store-pkey-in-vma	2016-01-28 15:52:20.646417036 -0800
+++ b/arch/x86/include/asm/mmu_context.h	2016-01-28 15:52:20.654417403 -0800
@@ -275,4 +275,15 @@ static inline void arch_unmap(struct mm_
 		mpx_notify_unmap(mm, vma, start, end);
 }
 
+static inline int vma_pkey(struct vm_area_struct *vma)
+{
+	u16 pkey = 0;
+#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
+	unsigned long vma_pkey_mask = VM_PKEY_BIT0 | VM_PKEY_BIT1 |
+				      VM_PKEY_BIT2 | VM_PKEY_BIT3;
+	pkey = (vma->vm_flags & vma_pkey_mask) >> VM_PKEY_SHIFT;
+#endif
+	return pkey;
+}
+
 #endif /* _ASM_X86_MMU_CONTEXT_H */
diff -puN arch/x86/include/asm/pgtable_types.h~pkeys-07-store-pkey-in-vma arch/x86/include/asm/pgtable_types.h
--- a/arch/x86/include/asm/pgtable_types.h~pkeys-07-store-pkey-in-vma	2016-01-28 15:52:20.648417128 -0800
+++ b/arch/x86/include/asm/pgtable_types.h	2016-01-28 15:52:20.655417449 -0800
@@ -115,7 +115,12 @@
 #define _KERNPG_TABLE	(_PAGE_PRESENT | _PAGE_RW | _PAGE_ACCESSED |	\
 			 _PAGE_DIRTY)
 
-/* Set of bits not changed in pte_modify */
+/*
+ * Set of bits not changed in pte_modify.  The pte's
+ * protection key is treated like _PAGE_RW, for
+ * instance, and is *not* included in this mask since
+ * pte_modify() does modify it.
+ */
 #define _PAGE_CHG_MASK	(PTE_PFN_MASK | _PAGE_PCD | _PAGE_PWT |		\
 			 _PAGE_SPECIAL | _PAGE_ACCESSED | _PAGE_DIRTY |	\
 			 _PAGE_SOFT_DIRTY)
@@ -231,7 +236,10 @@ enum page_cache_mode {
 /* Extracts the PFN from a (pte|pmd|pud|pgd)val_t of a 4KB page */
 #define PTE_PFN_MASK		((pteval_t)PHYSICAL_PAGE_MASK)
 
-/* Extracts the flags from a (pte|pmd|pud|pgd)val_t of a 4KB page */
+/*
+ *  Extracts the flags from a (pte|pmd|pud|pgd)val_t
+ *  This includes the protection key value.
+ */
 #define PTE_FLAGS_MASK		(~PTE_PFN_MASK)
 
 typedef struct pgprot { pgprotval_t pgprot; } pgprot_t;
diff -puN arch/x86/include/uapi/asm/mman.h~pkeys-07-store-pkey-in-vma arch/x86/include/uapi/asm/mman.h
--- a/arch/x86/include/uapi/asm/mman.h~pkeys-07-store-pkey-in-vma	2016-01-28 15:52:20.649417174 -0800
+++ b/arch/x86/include/uapi/asm/mman.h	2016-01-28 15:52:20.655417449 -0800
@@ -6,6 +6,22 @@
 #define MAP_HUGE_2MB    (21 << MAP_HUGE_SHIFT)
 #define MAP_HUGE_1GB    (30 << MAP_HUGE_SHIFT)
 
+#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
+/*
+ * Take the 4 protection key bits out of the vma->vm_flags
+ * value and turn them in to the bits that we can put in
+ * to a pte.
+ *
+ * Only override these if Protection Keys are available
+ * (which is only on 64-bit).
+ */
+#define arch_vm_get_page_prot(vm_flags)	__pgprot(	\
+		((vm_flags) & VM_PKEY_BIT0 ? _PAGE_PKEY_BIT0 : 0) |	\
+		((vm_flags) & VM_PKEY_BIT1 ? _PAGE_PKEY_BIT1 : 0) |	\
+		((vm_flags) & VM_PKEY_BIT2 ? _PAGE_PKEY_BIT2 : 0) |	\
+		((vm_flags) & VM_PKEY_BIT3 ? _PAGE_PKEY_BIT3 : 0))
+#endif
+
 #include <asm-generic/mman.h>
 
 #endif /* _ASM_X86_MMAN_H */
diff -puN include/linux/mm.h~pkeys-07-store-pkey-in-vma include/linux/mm.h
--- a/include/linux/mm.h~pkeys-07-store-pkey-in-vma	2016-01-28 15:52:20.651417266 -0800
+++ b/include/linux/mm.h	2016-01-28 15:52:20.656417495 -0800
@@ -183,6 +183,13 @@ extern unsigned int kobjsize(const void
 
 #if defined(CONFIG_X86)
 # define VM_PAT		VM_ARCH_1	/* PAT reserves whole VMA at once (x86) */
+#if defined (CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS)
+# define VM_PKEY_SHIFT	VM_HIGH_ARCH_BIT_0
+# define VM_PKEY_BIT0	VM_HIGH_ARCH_0	/* A protection key is a 4-bit value */
+# define VM_PKEY_BIT1	VM_HIGH_ARCH_1
+# define VM_PKEY_BIT2	VM_HIGH_ARCH_2
+# define VM_PKEY_BIT3	VM_HIGH_ARCH_3
+#endif
 #elif defined(CONFIG_PPC)
 # define VM_SAO		VM_ARCH_1	/* Strong Access Ordering (powerpc) */
 #elif defined(CONFIG_PARISC)
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
