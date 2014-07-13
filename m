Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id CC51F6B0035
	for <linux-mm@kvack.org>; Sun, 13 Jul 2014 16:33:36 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id w10so4106591pde.10
        for <linux-mm@kvack.org>; Sun, 13 Jul 2014 13:33:36 -0700 (PDT)
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
        by mx.google.com with ESMTPS id j1si7515779pbw.214.2014.07.13.13.02.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 13 Jul 2014 13:02:01 -0700 (PDT)
Received: by mail-pa0-f43.google.com with SMTP id lf10so3819137pab.30
        for <linux-mm@kvack.org>; Sun, 13 Jul 2014 13:02:01 -0700 (PDT)
From: Andy Lutomirski <luto@amacapital.net>
Subject: [PATCH v3] arm64,ia64,ppc,s390,sh,tile,um,x86,mm: Remove default gate area
Date: Sun, 13 Jul 2014 13:01:52 -0700
Message-Id: <70f331f59e620dc4e66bd3fa095e6f6b744b532b.1405281639.git.luto@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, Chris Metcalf <cmetcalf@tilera.com>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Nathan Lynch <Nathan_Lynch@mentor.com>, x86@kernel.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, linux-mm@kvack.org

The core mm code will provide a default gate area based on
FIXADDR_USER_START and FIXADDR_USER_END if
!defined(__HAVE_ARCH_GATE_AREA) && defined(AT_SYSINFO_EHDR).

This default is only useful for ia64.  arm64, ppc, s390, sh, tile,
64-bit UML, and x86_32 have their own code just to disable it.  arm,
32-bit UML, and x86_64 have gate areas, but they have their own
implementations.

This gets rid of the default and moves the code into ia64.

This should save some code on architectures without a gate area: it's
now possible to inline the gate_area functions in the default case.

Acked-by: Will Deacon <will.deacon@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux390@de.ibm.com
Cc: Chris Metcalf <cmetcalf@tilera.com>
Cc: Jeff Dike <jdike@addtoit.com>
Cc: Richard Weinberger <richard@nod.at>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Nathan Lynch <Nathan_Lynch@mentor.com>
Cc: x86@kernel.org
Cc: linux-arch@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-ia64@vger.kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-s390@vger.kernel.org
Cc: linux-sh@vger.kernel.org
Cc: user-mode-linux-devel@lists.sourceforge.net
Cc: linux-mm@kvack.org
Signed-off-by: Andy Lutomirski <luto@amacapital.net>
---

It would be nice to get this into some tree that's in -next and that
people can base on.

Changes from v1 and v2: Nothing except Will Deacon's ack and splitting
this out from the larger series.

 arch/arm64/include/asm/page.h      |  3 ---
 arch/arm64/kernel/vdso.c           | 19 -------------------
 arch/ia64/include/asm/page.h       |  2 ++
 arch/ia64/mm/init.c                | 26 ++++++++++++++++++++++++++
 arch/powerpc/include/asm/page.h    |  3 ---
 arch/powerpc/kernel/vdso.c         | 16 ----------------
 arch/s390/include/asm/page.h       |  2 --
 arch/s390/kernel/vdso.c            | 15 ---------------
 arch/sh/include/asm/page.h         |  5 -----
 arch/sh/kernel/vsyscall/vsyscall.c | 15 ---------------
 arch/tile/include/asm/page.h       |  6 ------
 arch/tile/kernel/vdso.c            | 15 ---------------
 arch/um/include/asm/page.h         |  5 +++++
 arch/x86/include/asm/page.h        |  1 -
 arch/x86/include/asm/page_64.h     |  2 ++
 arch/x86/um/asm/elf.h              |  1 -
 arch/x86/um/mem_64.c               | 15 ---------------
 arch/x86/vdso/vdso32-setup.c       | 19 +------------------
 include/linux/mm.h                 | 17 ++++++++++++-----
 mm/memory.c                        | 38 --------------------------------------
 mm/nommu.c                         |  5 -----
 21 files changed, 48 insertions(+), 182 deletions(-)

diff --git a/arch/arm64/include/asm/page.h b/arch/arm64/include/asm/page.h
index 46bf666..992710f 100644
--- a/arch/arm64/include/asm/page.h
+++ b/arch/arm64/include/asm/page.h
@@ -28,9 +28,6 @@
 #define PAGE_SIZE		(_AC(1,UL) << PAGE_SHIFT)
 #define PAGE_MASK		(~(PAGE_SIZE-1))
 
-/* We do define AT_SYSINFO_EHDR but don't use the gate mechanism */
-#define __HAVE_ARCH_GATE_AREA		1
-
 #ifndef __ASSEMBLY__
 
 #ifdef CONFIG_ARM64_64K_PAGES
diff --git a/arch/arm64/kernel/vdso.c b/arch/arm64/kernel/vdso.c
index 50384fe..f630626 100644
--- a/arch/arm64/kernel/vdso.c
+++ b/arch/arm64/kernel/vdso.c
@@ -187,25 +187,6 @@ const char *arch_vma_name(struct vm_area_struct *vma)
 }
 
 /*
- * We define AT_SYSINFO_EHDR, so we need these function stubs to keep
- * Linux happy.
- */
-int in_gate_area_no_mm(unsigned long addr)
-{
-	return 0;
-}
-
-int in_gate_area(struct mm_struct *mm, unsigned long addr)
-{
-	return 0;
-}
-
-struct vm_area_struct *get_gate_vma(struct mm_struct *mm)
-{
-	return NULL;
-}
-
-/*
  * Update the vDSO data page to keep in sync with kernel timekeeping.
  */
 void update_vsyscall(struct timekeeper *tk)
diff --git a/arch/ia64/include/asm/page.h b/arch/ia64/include/asm/page.h
index f1e1b2e..1f1bf14 100644
--- a/arch/ia64/include/asm/page.h
+++ b/arch/ia64/include/asm/page.h
@@ -231,4 +231,6 @@ get_order (unsigned long size)
 #define PERCPU_ADDR		(-PERCPU_PAGE_SIZE)
 #define LOAD_OFFSET		(KERNEL_START - KERNEL_TR_PAGE_SIZE)
 
+#define __HAVE_ARCH_GATE_AREA	1
+
 #endif /* _ASM_IA64_PAGE_H */
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 25c3502..35efaa3 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -278,6 +278,32 @@ setup_gate (void)
 	ia64_patch_gate();
 }
 
+static struct vm_area_struct gate_vma;
+
+static int __init gate_vma_init(void)
+{
+	gate_vma.vm_mm = NULL;
+	gate_vma.vm_start = FIXADDR_USER_START;
+	gate_vma.vm_end = FIXADDR_USER_END;
+	gate_vma.vm_flags = VM_READ | VM_MAYREAD | VM_EXEC | VM_MAYEXEC;
+	gate_vma.vm_page_prot = __P101;
+
+	return 0;
+}
+__initcall(gate_vma_init);
+
+struct vm_area_struct *get_gate_vma(struct mm_struct *mm)
+{
+	return &gate_vma;
+}
+
+int in_gate_area_no_mm(unsigned long addr)
+{
+	if ((addr >= FIXADDR_USER_START) && (addr < FIXADDR_USER_END))
+		return 1;
+	return 0;
+}
+
 void ia64_mmu_init(void *my_cpu_data)
 {
 	unsigned long pta, impl_va_bits;
diff --git a/arch/powerpc/include/asm/page.h b/arch/powerpc/include/asm/page.h
index 32e4e21..26fe1ae 100644
--- a/arch/powerpc/include/asm/page.h
+++ b/arch/powerpc/include/asm/page.h
@@ -48,9 +48,6 @@ extern unsigned int HPAGE_SHIFT;
 #define HUGE_MAX_HSTATE		(MMU_PAGE_COUNT-1)
 #endif
 
-/* We do define AT_SYSINFO_EHDR but don't use the gate mechanism */
-#define __HAVE_ARCH_GATE_AREA		1
-
 /*
  * Subtle: (1 << PAGE_SHIFT) is an int, not an unsigned long. So if we
  * assign PAGE_MASK to a larger type it gets extended the way we want
diff --git a/arch/powerpc/kernel/vdso.c b/arch/powerpc/kernel/vdso.c
index ce74c33..f174351 100644
--- a/arch/powerpc/kernel/vdso.c
+++ b/arch/powerpc/kernel/vdso.c
@@ -840,19 +840,3 @@ static int __init vdso_init(void)
 	return 0;
 }
 arch_initcall(vdso_init);
-
-int in_gate_area_no_mm(unsigned long addr)
-{
-	return 0;
-}
-
-int in_gate_area(struct mm_struct *mm, unsigned long addr)
-{
-	return 0;
-}
-
-struct vm_area_struct *get_gate_vma(struct mm_struct *mm)
-{
-	return NULL;
-}
-
diff --git a/arch/s390/include/asm/page.h b/arch/s390/include/asm/page.h
index 114258e..7b2ac6e 100644
--- a/arch/s390/include/asm/page.h
+++ b/arch/s390/include/asm/page.h
@@ -162,6 +162,4 @@ static inline int devmem_is_allowed(unsigned long pfn)
 #include <asm-generic/memory_model.h>
 #include <asm-generic/getorder.h>
 
-#define __HAVE_ARCH_GATE_AREA 1
-
 #endif /* _S390_PAGE_H */
diff --git a/arch/s390/kernel/vdso.c b/arch/s390/kernel/vdso.c
index 6136490..0bbb7e0 100644
--- a/arch/s390/kernel/vdso.c
+++ b/arch/s390/kernel/vdso.c
@@ -316,18 +316,3 @@ static int __init vdso_init(void)
 	return 0;
 }
 early_initcall(vdso_init);
-
-int in_gate_area_no_mm(unsigned long addr)
-{
-	return 0;
-}
-
-int in_gate_area(struct mm_struct *mm, unsigned long addr)
-{
-	return 0;
-}
-
-struct vm_area_struct *get_gate_vma(struct mm_struct *mm)
-{
-	return NULL;
-}
diff --git a/arch/sh/include/asm/page.h b/arch/sh/include/asm/page.h
index 15d9703..fe20d14 100644
--- a/arch/sh/include/asm/page.h
+++ b/arch/sh/include/asm/page.h
@@ -186,11 +186,6 @@ typedef struct page *pgtable_t;
 #include <asm-generic/memory_model.h>
 #include <asm-generic/getorder.h>
 
-/* vDSO support */
-#ifdef CONFIG_VSYSCALL
-#define __HAVE_ARCH_GATE_AREA
-#endif
-
 /*
  * Some drivers need to perform DMA into kmalloc'ed buffers
  * and so we have to increase the kmalloc minalign for this.
diff --git a/arch/sh/kernel/vsyscall/vsyscall.c b/arch/sh/kernel/vsyscall/vsyscall.c
index 5ca5797..ea2aa13 100644
--- a/arch/sh/kernel/vsyscall/vsyscall.c
+++ b/arch/sh/kernel/vsyscall/vsyscall.c
@@ -92,18 +92,3 @@ const char *arch_vma_name(struct vm_area_struct *vma)
 
 	return NULL;
 }
-
-struct vm_area_struct *get_gate_vma(struct mm_struct *mm)
-{
-	return NULL;
-}
-
-int in_gate_area(struct mm_struct *mm, unsigned long address)
-{
-	return 0;
-}
-
-int in_gate_area_no_mm(unsigned long address)
-{
-	return 0;
-}
diff --git a/arch/tile/include/asm/page.h b/arch/tile/include/asm/page.h
index 6727680..a213a8d 100644
--- a/arch/tile/include/asm/page.h
+++ b/arch/tile/include/asm/page.h
@@ -39,12 +39,6 @@
 #define HPAGE_MASK	(~(HPAGE_SIZE - 1))
 
 /*
- * We do define AT_SYSINFO_EHDR to support vDSO,
- * but don't use the gate mechanism.
- */
-#define __HAVE_ARCH_GATE_AREA		1
-
-/*
  * If the Kconfig doesn't specify, set a maximum zone order that
  * is enough so that we can create huge pages from small pages given
  * the respective sizes of the two page types.  See <linux/mmzone.h>.
diff --git a/arch/tile/kernel/vdso.c b/arch/tile/kernel/vdso.c
index 1533af2..5bc51d7 100644
--- a/arch/tile/kernel/vdso.c
+++ b/arch/tile/kernel/vdso.c
@@ -121,21 +121,6 @@ const char *arch_vma_name(struct vm_area_struct *vma)
 	return NULL;
 }
 
-struct vm_area_struct *get_gate_vma(struct mm_struct *mm)
-{
-	return NULL;
-}
-
-int in_gate_area(struct mm_struct *mm, unsigned long address)
-{
-	return 0;
-}
-
-int in_gate_area_no_mm(unsigned long address)
-{
-	return 0;
-}
-
 int setup_vdso_pages(void)
 {
 	struct page **pagelist;
diff --git a/arch/um/include/asm/page.h b/arch/um/include/asm/page.h
index 5ff53d9..71c5d13 100644
--- a/arch/um/include/asm/page.h
+++ b/arch/um/include/asm/page.h
@@ -119,4 +119,9 @@ extern unsigned long uml_physmem;
 #include <asm-generic/getorder.h>
 
 #endif	/* __ASSEMBLY__ */
+
+#ifdef CONFIG_X86_32
+#define __HAVE_ARCH_GATE_AREA 1
+#endif
+
 #endif	/* __UM_PAGE_H */
diff --git a/arch/x86/include/asm/page.h b/arch/x86/include/asm/page.h
index 775873d..802dde3 100644
--- a/arch/x86/include/asm/page.h
+++ b/arch/x86/include/asm/page.h
@@ -70,7 +70,6 @@ extern bool __virt_addr_valid(unsigned long kaddr);
 #include <asm-generic/memory_model.h>
 #include <asm-generic/getorder.h>
 
-#define __HAVE_ARCH_GATE_AREA 1
 #define HAVE_ARCH_HUGETLB_UNMAPPED_AREA
 
 #endif	/* __KERNEL__ */
diff --git a/arch/x86/include/asm/page_64.h b/arch/x86/include/asm/page_64.h
index 0f1ddee..f408caf 100644
--- a/arch/x86/include/asm/page_64.h
+++ b/arch/x86/include/asm/page_64.h
@@ -39,4 +39,6 @@ void copy_page(void *to, void *from);
 
 #endif	/* !__ASSEMBLY__ */
 
+#define __HAVE_ARCH_GATE_AREA 1
+
 #endif /* _ASM_X86_PAGE_64_H */
diff --git a/arch/x86/um/asm/elf.h b/arch/x86/um/asm/elf.h
index 0feee2f..25a1022 100644
--- a/arch/x86/um/asm/elf.h
+++ b/arch/x86/um/asm/elf.h
@@ -216,6 +216,5 @@ extern long elf_aux_hwcap;
 #define ELF_HWCAP (elf_aux_hwcap)
 
 #define SET_PERSONALITY(ex) do ; while(0)
-#define __HAVE_ARCH_GATE_AREA 1
 
 #endif
diff --git a/arch/x86/um/mem_64.c b/arch/x86/um/mem_64.c
index c6492e7..f8fecad 100644
--- a/arch/x86/um/mem_64.c
+++ b/arch/x86/um/mem_64.c
@@ -9,18 +9,3 @@ const char *arch_vma_name(struct vm_area_struct *vma)
 
 	return NULL;
 }
-
-struct vm_area_struct *get_gate_vma(struct mm_struct *mm)
-{
-	return NULL;
-}
-
-int in_gate_area(struct mm_struct *mm, unsigned long addr)
-{
-	return 0;
-}
-
-int in_gate_area_no_mm(unsigned long addr)
-{
-	return 0;
-}
diff --git a/arch/x86/vdso/vdso32-setup.c b/arch/x86/vdso/vdso32-setup.c
index e4f7781..e904c27 100644
--- a/arch/x86/vdso/vdso32-setup.c
+++ b/arch/x86/vdso/vdso32-setup.c
@@ -115,23 +115,6 @@ static __init int ia32_binfmt_init(void)
 	return 0;
 }
 __initcall(ia32_binfmt_init);
-#endif
-
-#else  /* CONFIG_X86_32 */
-
-struct vm_area_struct *get_gate_vma(struct mm_struct *mm)
-{
-	return NULL;
-}
-
-int in_gate_area(struct mm_struct *mm, unsigned long addr)
-{
-	return 0;
-}
-
-int in_gate_area_no_mm(unsigned long addr)
-{
-	return 0;
-}
+#endif /* CONFIG_SYSCTL */
 
 #endif	/* CONFIG_X86_64 */
diff --git a/include/linux/mm.h b/include/linux/mm.h
index e03dd29..8981cc8 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2014,13 +2014,20 @@ static inline bool kernel_page_present(struct page *page) { return true; }
 #endif /* CONFIG_HIBERNATION */
 #endif
 
+#ifdef __HAVE_ARCH_GATE_AREA
 extern struct vm_area_struct *get_gate_vma(struct mm_struct *mm);
-#ifdef	__HAVE_ARCH_GATE_AREA
-int in_gate_area_no_mm(unsigned long addr);
-int in_gate_area(struct mm_struct *mm, unsigned long addr);
+extern int in_gate_area_no_mm(unsigned long addr);
+extern int in_gate_area(struct mm_struct *mm, unsigned long addr);
 #else
-int in_gate_area_no_mm(unsigned long addr);
-#define in_gate_area(mm, addr) ({(void)mm; in_gate_area_no_mm(addr);})
+static inline struct vm_area_struct *get_gate_vma(struct mm_struct *mm)
+{
+	return NULL;
+}
+static inline int in_gate_area_no_mm(unsigned long addr) { return 0; }
+static inline int in_gate_area(struct mm_struct *mm, unsigned long addr)
+{
+	return 0;
+}
 #endif	/* __HAVE_ARCH_GATE_AREA */
 
 #ifdef CONFIG_SYSCTL
diff --git a/mm/memory.c b/mm/memory.c
index d67fd9f..099d234 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3399,44 +3399,6 @@ int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
 }
 #endif /* __PAGETABLE_PMD_FOLDED */
 
-#if !defined(__HAVE_ARCH_GATE_AREA)
-
-#if defined(AT_SYSINFO_EHDR)
-static struct vm_area_struct gate_vma;
-
-static int __init gate_vma_init(void)
-{
-	gate_vma.vm_mm = NULL;
-	gate_vma.vm_start = FIXADDR_USER_START;
-	gate_vma.vm_end = FIXADDR_USER_END;
-	gate_vma.vm_flags = VM_READ | VM_MAYREAD | VM_EXEC | VM_MAYEXEC;
-	gate_vma.vm_page_prot = __P101;
-
-	return 0;
-}
-__initcall(gate_vma_init);
-#endif
-
-struct vm_area_struct *get_gate_vma(struct mm_struct *mm)
-{
-#ifdef AT_SYSINFO_EHDR
-	return &gate_vma;
-#else
-	return NULL;
-#endif
-}
-
-int in_gate_area_no_mm(unsigned long addr)
-{
-#ifdef AT_SYSINFO_EHDR
-	if ((addr >= FIXADDR_USER_START) && (addr < FIXADDR_USER_END))
-		return 1;
-#endif
-	return 0;
-}
-
-#endif	/* __HAVE_ARCH_GATE_AREA */
-
 static int __follow_pte(struct mm_struct *mm, unsigned long address,
 		pte_t **ptepp, spinlock_t **ptlp)
 {
diff --git a/mm/nommu.c b/mm/nommu.c
index 4a852f6..a881d96 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1981,11 +1981,6 @@ error:
 	return -ENOMEM;
 }
 
-int in_gate_area_no_mm(unsigned long addr)
-{
-	return 0;
-}
-
 int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	BUG();
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
