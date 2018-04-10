Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D3BFD6B0006
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 11:26:09 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id z83so6084499wmc.2
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 08:26:09 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g29si2001730edb.506.2018.04.10.08.26.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Apr 2018 08:26:08 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3AFMV1G114484
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 11:26:06 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2h8wtd75pc-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 11:26:06 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 10 Apr 2018 16:26:03 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v2 1/2] mm: introduce ARCH_HAS_PTE_SPECIAL
Date: Tue, 10 Apr 2018 17:25:50 +0200
In-Reply-To: <1523373951-10981-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1523373951-10981-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1523373951-10981-2-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Jerome Glisse <jglisse@redhat.com>, mhocko@kernel.org, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Vineet Gupta <vgupta@synopsys.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <albert@sifive.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, David Rientjes <rientjes@google.com>

Currently the PTE special supports is turned on in per architecture header
files. Most of the time, it is defined in arch/*/include/asm/pgtable.h
depending or not on some other per architecture static definition.

This patch introduce a new configuration variable to manage this directly
in the Kconfig files. It would later replace __HAVE_ARCH_PTE_SPECIAL.

Here notes for some architecture where the definition of
__HAVE_ARCH_PTE_SPECIAL is not obvious:

arm
 __HAVE_ARCH_PTE_SPECIAL which is currently defined in
arch/arm/include/asm/pgtable-3level.h which is included by
arch/arm/include/asm/pgtable.h when CONFIG_ARM_LPAE is set.
So select ARCH_HAS_PTE_SPECIAL if ARM_LPAE.

powerpc
__HAVE_ARCH_PTE_SPECIAL is defined in 2 files:
 - arch/powerpc/include/asm/book3s/64/pgtable.h
 - arch/powerpc/include/asm/pte-common.h
The first one is included if (PPC_BOOK3S & PPC64) while the second is
included in all the other cases.
So select ARCH_HAS_PTE_SPECIAL all the time.

sparc:
__HAVE_ARCH_PTE_SPECIAL is defined if defined(__sparc__) &&
defined(__arch64__) which are defined through the compiler in
sparc/Makefile if !SPARC32 which I assume to be if SPARC64.
So select ARCH_HAS_PTE_SPECIAL if SPARC64

There is no functional change introduced by this patch.

Suggested-by: Jerome Glisse <jglisse@redhat>
Reviewed-by: Jerome Glisse <jglisse@redhat>
Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 Documentation/features/vm/pte_special/arch-support.txt | 2 +-
 arch/arc/Kconfig                                       | 1 +
 arch/arc/include/asm/pgtable.h                         | 2 --
 arch/arm/Kconfig                                       | 1 +
 arch/arm/include/asm/pgtable-3level.h                  | 1 -
 arch/arm64/Kconfig                                     | 1 +
 arch/arm64/include/asm/pgtable.h                       | 2 --
 arch/powerpc/Kconfig                                   | 1 +
 arch/powerpc/include/asm/book3s/64/pgtable.h           | 3 ---
 arch/powerpc/include/asm/pte-common.h                  | 3 ---
 arch/riscv/Kconfig                                     | 1 +
 arch/s390/Kconfig                                      | 1 +
 arch/s390/include/asm/pgtable.h                        | 1 -
 arch/sh/Kconfig                                        | 1 +
 arch/sh/include/asm/pgtable.h                          | 2 --
 arch/sparc/Kconfig                                     | 1 +
 arch/sparc/include/asm/pgtable_64.h                    | 3 ---
 arch/x86/Kconfig                                       | 1 +
 arch/x86/include/asm/pgtable_types.h                   | 1 -
 include/linux/pfn_t.h                                  | 4 ++--
 mm/Kconfig                                             | 3 +++
 mm/gup.c                                               | 4 ++--
 mm/memory.c                                            | 2 +-
 23 files changed, 18 insertions(+), 24 deletions(-)

diff --git a/Documentation/features/vm/pte_special/arch-support.txt b/Documentation/features/vm/pte_special/arch-support.txt
index 055004f467d2..cd05924ea875 100644
--- a/Documentation/features/vm/pte_special/arch-support.txt
+++ b/Documentation/features/vm/pte_special/arch-support.txt
@@ -1,6 +1,6 @@
 #
 # Feature name:          pte_special
-#         Kconfig:       __HAVE_ARCH_PTE_SPECIAL
+#         Kconfig:       ARCH_HAS_PTE_SPECIAL
 #         description:   arch supports the pte_special()/pte_mkspecial() VM APIs
 #
     -----------------------
diff --git a/arch/arc/Kconfig b/arch/arc/Kconfig
index d76bf4a83740..8516e2b0239a 100644
--- a/arch/arc/Kconfig
+++ b/arch/arc/Kconfig
@@ -44,6 +44,7 @@ config ARC
 	select HAVE_GENERIC_DMA_COHERENT
 	select HAVE_KERNEL_GZIP
 	select HAVE_KERNEL_LZMA
+	select ARCH_HAS_PTE_SPECIAL
 
 config MIGHT_HAVE_PCI
 	bool
diff --git a/arch/arc/include/asm/pgtable.h b/arch/arc/include/asm/pgtable.h
index 08fe33830d4b..8ec5599a0957 100644
--- a/arch/arc/include/asm/pgtable.h
+++ b/arch/arc/include/asm/pgtable.h
@@ -320,8 +320,6 @@ PTE_BIT_FUNC(mkexec,	|= (_PAGE_EXECUTE));
 PTE_BIT_FUNC(mkspecial,	|= (_PAGE_SPECIAL));
 PTE_BIT_FUNC(mkhuge,	|= (_PAGE_HW_SZ));
 
-#define __HAVE_ARCH_PTE_SPECIAL
-
 static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
 {
 	return __pte((pte_val(pte) & _PAGE_CHG_MASK) | pgprot_val(newprot));
diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index a7f8e7f4b88f..c088c851b235 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -8,6 +8,7 @@ config ARM
 	select ARCH_HAS_DEVMEM_IS_ALLOWED
 	select ARCH_HAS_ELF_RANDOMIZE
 	select ARCH_HAS_FORTIFY_SOURCE
+	select ARCH_HAS_PTE_SPECIAL if ARM_LPAE
 	select ARCH_HAS_SET_MEMORY
 	select ARCH_HAS_PHYS_TO_DMA
 	select ARCH_HAS_STRICT_KERNEL_RWX if MMU && !XIP_KERNEL
diff --git a/arch/arm/include/asm/pgtable-3level.h b/arch/arm/include/asm/pgtable-3level.h
index 2a4836087358..6d50a11d7793 100644
--- a/arch/arm/include/asm/pgtable-3level.h
+++ b/arch/arm/include/asm/pgtable-3level.h
@@ -219,7 +219,6 @@ static inline pte_t pte_mkspecial(pte_t pte)
 	pte_val(pte) |= L_PTE_SPECIAL;
 	return pte;
 }
-#define	__HAVE_ARCH_PTE_SPECIAL
 
 #define pmd_write(pmd)		(pmd_isclear((pmd), L_PMD_SECT_RDONLY))
 #define pmd_dirty(pmd)		(pmd_isset((pmd), L_PMD_SECT_DIRTY))
diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index eb2cf4938f6d..9a3f1b1ab50c 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -17,6 +17,7 @@ config ARM64
 	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
 	select ARCH_HAS_KCOV
 	select ARCH_HAS_MEMBARRIER_SYNC_CORE
+	select ARCH_HAS_PTE_SPECIAL
 	select ARCH_HAS_SET_MEMORY
 	select ARCH_HAS_SG_CHAIN
 	select ARCH_HAS_STRICT_KERNEL_RWX
diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index 7e2c27e63cd8..b96c8a186908 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -306,8 +306,6 @@ static inline int pte_same(pte_t pte_a, pte_t pte_b)
 #define HPAGE_MASK		(~(HPAGE_SIZE - 1))
 #define HUGETLB_PAGE_ORDER	(HPAGE_SHIFT - PAGE_SHIFT)
 
-#define __HAVE_ARCH_PTE_SPECIAL
-
 static inline pte_t pgd_pte(pgd_t pgd)
 {
 	return __pte(pgd_val(pgd));
diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index c32a181a7cbb..f7415fe25c07 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -141,6 +141,7 @@ config PPC
 	select ARCH_HAS_GCOV_PROFILE_ALL
 	select ARCH_HAS_PHYS_TO_DMA
 	select ARCH_HAS_PMEM_API                if PPC64
+	select ARCH_HAS_PTE_SPECIAL
 	select ARCH_HAS_MEMBARRIER_CALLBACKS
 	select ARCH_HAS_SCALED_CPUTIME		if VIRT_CPU_ACCOUNTING_NATIVE
 	select ARCH_HAS_SG_CHAIN
diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index 47b5ffc8715d..b3ac8948b257 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -319,9 +319,6 @@ extern unsigned long pci_io_base;
 /* Advertise special mapping type for AGP */
 #define HAVE_PAGE_AGP
 
-/* Advertise support for _PAGE_SPECIAL */
-#define __HAVE_ARCH_PTE_SPECIAL
-
 #ifndef __ASSEMBLY__
 
 /*
diff --git a/arch/powerpc/include/asm/pte-common.h b/arch/powerpc/include/asm/pte-common.h
index c4a72c7a8c83..03dfddb1f49a 100644
--- a/arch/powerpc/include/asm/pte-common.h
+++ b/arch/powerpc/include/asm/pte-common.h
@@ -216,9 +216,6 @@ static inline bool pte_user(pte_t pte)
 #define PAGE_AGP		(PAGE_KERNEL_NC)
 #define HAVE_PAGE_AGP
 
-/* Advertise support for _PAGE_SPECIAL */
-#define __HAVE_ARCH_PTE_SPECIAL
-
 #ifndef _PAGE_READ
 /* if not defined, we should not find _PAGE_WRITE too */
 #define _PAGE_READ 0
diff --git a/arch/riscv/Kconfig b/arch/riscv/Kconfig
index 5287c1441d66..b01c183836e5 100644
--- a/arch/riscv/Kconfig
+++ b/arch/riscv/Kconfig
@@ -34,6 +34,7 @@ config RISCV
 	select THREAD_INFO_IN_TASK
 	select RISCV_TIMER
 	select GENERIC_IRQ_MULTI_HANDLER
+	select ARCH_HAS_PTE_SPECIAL
 
 config MMU
 	def_bool y
diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index 32a0d5b958bf..5f1f4997e7e9 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -72,6 +72,7 @@ config S390
 	select ARCH_HAS_GCOV_PROFILE_ALL
 	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
 	select ARCH_HAS_KCOV
+	select ARCH_HAS_PTE_SPECIAL
 	select ARCH_HAS_SET_MEMORY
 	select ARCH_HAS_SG_CHAIN
 	select ARCH_HAS_STRICT_KERNEL_RWX
diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index 2d24d33bf188..9809694e1389 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -171,7 +171,6 @@ static inline int is_module_addr(void *addr)
 #define _PAGE_WRITE	0x020		/* SW pte write bit */
 #define _PAGE_SPECIAL	0x040		/* SW associated with special page */
 #define _PAGE_UNUSED	0x080		/* SW bit for pgste usage state */
-#define __HAVE_ARCH_PTE_SPECIAL
 
 #ifdef CONFIG_MEM_SOFT_DIRTY
 #define _PAGE_SOFT_DIRTY 0x002		/* SW pte soft dirty bit */
diff --git a/arch/sh/Kconfig b/arch/sh/Kconfig
index 97fe29316476..a6c75b6806d2 100644
--- a/arch/sh/Kconfig
+++ b/arch/sh/Kconfig
@@ -50,6 +50,7 @@ config SUPERH
 	select HAVE_ARCH_AUDITSYSCALL
 	select HAVE_FUTEX_CMPXCHG if FUTEX
 	select HAVE_NMI
+	select ARCH_HAS_PTE_SPECIAL
 	help
 	  The SuperH is a RISC processor targeted for use in embedded systems
 	  and consumer electronics; it was also used in the Sega Dreamcast
diff --git a/arch/sh/include/asm/pgtable.h b/arch/sh/include/asm/pgtable.h
index 89c513a982fc..f6abfe2bca93 100644
--- a/arch/sh/include/asm/pgtable.h
+++ b/arch/sh/include/asm/pgtable.h
@@ -156,8 +156,6 @@ extern void page_table_range_init(unsigned long start, unsigned long end,
 #define HAVE_ARCH_UNMAPPED_AREA
 #define HAVE_ARCH_UNMAPPED_AREA_TOPDOWN
 
-#define __HAVE_ARCH_PTE_SPECIAL
-
 #include <asm-generic/pgtable.h>
 
 #endif /* __ASM_SH_PGTABLE_H */
diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index 8767e45f1b2b..6b5a4f05dcb2 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -86,6 +86,7 @@ config SPARC64
 	select ARCH_USE_QUEUED_SPINLOCKS
 	select GENERIC_TIME_VSYSCALL
 	select ARCH_CLOCKSOURCE_DATA
+	select ARCH_HAS_PTE_SPECIAL
 
 config ARCH_DEFCONFIG
 	string
diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index 44d6ac47e035..1393a8ac596b 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -117,9 +117,6 @@ bool kern_addr_valid(unsigned long addr);
 #define _PAGE_PMD_HUGE    _AC(0x0100000000000000,UL) /* Huge page            */
 #define _PAGE_PUD_HUGE    _PAGE_PMD_HUGE
 
-/* Advertise support for _PAGE_SPECIAL */
-#define __HAVE_ARCH_PTE_SPECIAL
-
 /* SUN4U pte bits... */
 #define _PAGE_SZ4MB_4U	  _AC(0x6000000000000000,UL) /* 4MB Page             */
 #define _PAGE_SZ512K_4U	  _AC(0x4000000000000000,UL) /* 512K Page            */
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index bf4ddea48e61..3f5fb25486bf 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -56,6 +56,7 @@ config X86
 	select ARCH_HAS_KCOV			if X86_64
 	select ARCH_HAS_MEMBARRIER_SYNC_CORE
 	select ARCH_HAS_PMEM_API		if X86_64
+	select ARCH_HAS_PTE_SPECIAL
 	select ARCH_HAS_REFCOUNT
 	select ARCH_HAS_UACCESS_FLUSHCACHE	if X86_64
 	select ARCH_HAS_SET_MEMORY
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index acfe755562a6..3e195728d7d1 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -65,7 +65,6 @@
 #define _PAGE_PKEY_BIT2	(_AT(pteval_t, 0))
 #define _PAGE_PKEY_BIT3	(_AT(pteval_t, 0))
 #endif
-#define __HAVE_ARCH_PTE_SPECIAL
 
 #define _PAGE_PKEY_MASK (_PAGE_PKEY_BIT0 | \
 			 _PAGE_PKEY_BIT1 | \
diff --git a/include/linux/pfn_t.h b/include/linux/pfn_t.h
index a03c2642a87c..21713dc14ce2 100644
--- a/include/linux/pfn_t.h
+++ b/include/linux/pfn_t.h
@@ -122,7 +122,7 @@ pud_t pud_mkdevmap(pud_t pud);
 #endif
 #endif /* __HAVE_ARCH_PTE_DEVMAP */
 
-#ifdef __HAVE_ARCH_PTE_SPECIAL
+#ifdef CONFIG_ARCH_HAS_PTE_SPECIAL
 static inline bool pfn_t_special(pfn_t pfn)
 {
 	return (pfn.val & PFN_SPECIAL) == PFN_SPECIAL;
@@ -132,5 +132,5 @@ static inline bool pfn_t_special(pfn_t pfn)
 {
 	return false;
 }
-#endif /* __HAVE_ARCH_PTE_SPECIAL */
+#endif /* CONFIG_ARCH_HAS_PTE_SPECIAL */
 #endif /* _LINUX_PFN_T_H_ */
diff --git a/mm/Kconfig b/mm/Kconfig
index d5004d82a1d6..1ea3e4a6a123 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -752,3 +752,6 @@ config GUP_BENCHMARK
 	  performance of get_user_pages_fast().
 
 	  See tools/testing/selftests/vm/gup_benchmark.c
+
+config ARCH_HAS_PTE_SPECIAL
+	bool
diff --git a/mm/gup.c b/mm/gup.c
index f296df6cf666..b044a3d14dc5 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1351,7 +1351,7 @@ static void undo_dev_pagemap(int *nr, int nr_start, struct page **pages)
 	}
 }
 
-#ifdef __HAVE_ARCH_PTE_SPECIAL
+#ifdef CONFIG_ARCH_HAS_PTE_SPECIAL
 static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 			 int write, struct page **pages, int *nr)
 {
@@ -1427,7 +1427,7 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 {
 	return 0;
 }
-#endif /* __HAVE_ARCH_PTE_SPECIAL */
+#endif /* CONFIG_ARCH_HAS_PTE_SPECIAL */
 
 #if defined(__HAVE_ARCH_PTE_DEVMAP) && defined(CONFIG_TRANSPARENT_HUGEPAGE)
 static int __gup_device_huge(unsigned long pfn, unsigned long addr,
diff --git a/mm/memory.c b/mm/memory.c
index a1f990e33e38..96910c625daa 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -817,7 +817,7 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
  * PFNMAP mappings in order to support COWable mappings.
  *
  */
-#ifdef __HAVE_ARCH_PTE_SPECIAL
+#ifdef CONFIG_ARCH_HAS_PTE_SPECIAL
 # define HAVE_PTE_SPECIAL 1
 #else
 # define HAVE_PTE_SPECIAL 0
-- 
2.7.4
