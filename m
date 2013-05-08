Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id D65056B00AF
	for <linux-mm@kvack.org>; Wed,  8 May 2013 05:53:23 -0400 (EDT)
Received: by mail-wg0-f42.google.com with SMTP id j13so4914430wgh.1
        for <linux-mm@kvack.org>; Wed, 08 May 2013 02:53:22 -0700 (PDT)
From: Steve Capper <steve.capper@linaro.org>
Subject: [RFC PATCH v2 09/11] ARM64: mm: HugeTLB support.
Date: Wed,  8 May 2013 10:52:41 +0100
Message-Id: <1368006763-30774-10-git-send-email-steve.capper@linaro.org>
In-Reply-To: <1368006763-30774-1-git-send-email-steve.capper@linaro.org>
References: <1368006763-30774-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Cc: Michal Hocko <mhocko@suse.cz>, Ken Chen <kenchen@google.com>, Mel Gorman <mgorman@suse.de>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, patches@linaro.org, Steve Capper <steve.capper@linaro.org>

Add huge page support to ARM64, different huge page sizes are
supported depending on the size of normal pages:

PAGE_SIZE is 4KB:
   2MB - (pmds) these can be allocated at any time.
1024MB - (puds) usually allocated on bootup with the command line
         with something like: hugepagesz=1G hugepages=6

PAGE_SIZE is 64KB:
 512MB - (pmds) usually allocated on bootup via command line.

Signed-off-by: Steve Capper <steve.capper@linaro.org>
---
 arch/arm64/Kconfig                     |   9 +++
 arch/arm64/include/asm/hugetlb.h       | 121 +++++++++++++++++++++++++++++++++
 arch/arm64/include/asm/pgtable-hwdef.h |   8 +++
 arch/arm64/include/asm/pgtable.h       |  13 +++-
 arch/arm64/mm/Makefile                 |   1 +
 arch/arm64/mm/fault.c                  |  19 ++----
 arch/arm64/mm/hugetlbpage.c            |  70 +++++++++++++++++++
 7 files changed, 224 insertions(+), 17 deletions(-)
 create mode 100644 arch/arm64/include/asm/hugetlb.h
 create mode 100644 arch/arm64/mm/hugetlbpage.c

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 43b0e9f..053533b 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -185,6 +185,15 @@ config HW_PERF_EVENTS
 	  Enable hardware performance counter support for perf events. If
 	  disabled, perf events will use software events only.
 
+config SYS_SUPPORTS_HUGETLBFS
+	def_bool y
+
+config ARCH_WANT_GENERAL_HUGETLB
+	def_bool y
+
+config ARCH_WANT_HUGE_PMD_SHARE
+	def_bool y if !ARM64_64K_PAGES
+
 source "mm/Kconfig"
 
 endmenu
diff --git a/arch/arm64/include/asm/hugetlb.h b/arch/arm64/include/asm/hugetlb.h
new file mode 100644
index 0000000..fb08fbb
--- /dev/null
+++ b/arch/arm64/include/asm/hugetlb.h
@@ -0,0 +1,121 @@
+/*
+ * arch/arm64/include/asm/hugetlb.h
+ *
+ * Copyright (C) 2013 Linaro Ltd.
+ *
+ * Based on arch/x86/include/asm/hugetlb.h
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ */
+
+#ifndef __ASM_HUGETLB_H
+#define __ASM_HUGETLB_H
+
+#include <asm/page.h>
+
+static inline pte_t huge_ptep_get(pte_t *ptep)
+{
+	return *ptep;
+}
+
+static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
+				   pte_t *ptep, pte_t pte)
+{
+	set_pte_at(mm, addr, ptep, pte);
+}
+
+static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
+					 unsigned long addr, pte_t *ptep)
+{
+	ptep_clear_flush(vma, addr, ptep);
+}
+
+static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
+					   unsigned long addr, pte_t *ptep)
+{
+	ptep_set_wrprotect(mm, addr, ptep);
+}
+
+static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
+					    unsigned long addr, pte_t *ptep)
+{
+	return ptep_get_and_clear(mm, addr, ptep);
+}
+
+static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
+					     unsigned long addr, pte_t *ptep,
+					     pte_t pte, int dirty)
+{
+	return ptep_set_access_flags(vma, addr, ptep, pte, dirty);
+}
+
+static inline void hugetlb_free_pgd_range(struct mmu_gather *tlb,
+					  unsigned long addr, unsigned long end,
+					  unsigned long floor,
+					  unsigned long ceiling)
+{
+	free_pgd_range(tlb, addr, end, floor, ceiling);
+}
+
+static inline int is_hugepage_only_range(struct mm_struct *mm,
+					 unsigned long addr, unsigned long len)
+{
+	return 0;
+}
+
+static inline int prepare_hugepage_range(struct file *file,
+					 unsigned long addr, unsigned long len)
+{
+	struct hstate *h = hstate_file(file);
+	if (len & ~huge_page_mask(h))
+		return -EINVAL;
+	if (addr & ~huge_page_mask(h))
+		return -EINVAL;
+	return 0;
+}
+
+static inline void hugetlb_prefault_arch_hook(struct mm_struct *mm)
+{
+}
+
+static inline int huge_pte_none(pte_t pte)
+{
+	return pte_none(pte);
+}
+
+static inline pte_t huge_pte_wrprotect(pte_t pte)
+{
+	return pte_wrprotect(pte);
+}
+
+static inline int arch_prepare_hugepage(struct page *page)
+{
+	return 0;
+}
+
+static inline void arch_release_hugepage(struct page *page)
+{
+}
+
+static inline void arch_clear_hugepage_flags(struct page *page)
+{
+	clear_bit(PG_dcache_clean, &page->flags);
+}
+
+static inline int pud_large(pud_t pud)
+{
+	return !(pud_val(pud) & PUD_TABLE_BIT);
+}
+
+#endif /* __ASM_HUGETLB_H */
diff --git a/arch/arm64/include/asm/pgtable-hwdef.h b/arch/arm64/include/asm/pgtable-hwdef.h
index 75fd13d..e6e0a0d 100644
--- a/arch/arm64/include/asm/pgtable-hwdef.h
+++ b/arch/arm64/include/asm/pgtable-hwdef.h
@@ -25,12 +25,19 @@
 /*
  * Hardware page table definitions.
  *
+ * Level 1 descriptor (PUD).
+ */
+
+#define PUD_TABLE_BIT		(_AT(pgdval_t, 1) << 1)
+
+/*
  * Level 2 descriptor (PMD).
  */
 #define PMD_TYPE_MASK		(_AT(pmdval_t, 3) << 0)
 #define PMD_TYPE_FAULT		(_AT(pmdval_t, 0) << 0)
 #define PMD_TYPE_TABLE		(_AT(pmdval_t, 3) << 0)
 #define PMD_TYPE_SECT		(_AT(pmdval_t, 1) << 0)
+#define PMD_TABLE_BIT		(_AT(pmdval_t, 1) << 1)
 
 /*
  * Section
@@ -53,6 +60,7 @@
 #define PTE_TYPE_MASK		(_AT(pteval_t, 3) << 0)
 #define PTE_TYPE_FAULT		(_AT(pteval_t, 0) << 0)
 #define PTE_TYPE_PAGE		(_AT(pteval_t, 3) << 0)
+#define PTE_TABLE_BIT		(_AT(pteval_t, 1) << 1)
 #define PTE_USER		(_AT(pteval_t, 1) << 6)		/* AP[1] */
 #define PTE_RDONLY		(_AT(pteval_t, 1) << 7)		/* AP[2] */
 #define PTE_SHARED		(_AT(pteval_t, 3) << 8)		/* SH[1:0], inner shareable */
diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index e245260..6bcbcfd 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -173,8 +173,17 @@ static inline void set_pte_at(struct mm_struct *mm, unsigned long addr,
 /*
  * Huge pte definitions.
  */
-#define pte_huge(pte)		((pte_val(pte) & PTE_TYPE_MASK) == PTE_TYPE_HUGEPAGE)
-#define pte_mkhuge(pte)		(__pte((pte_val(pte) & ~PTE_TYPE_MASK) | PTE_TYPE_HUGEPAGE))
+#define pte_huge(pte)		(!(pte_val(pte) & PTE_TABLE_BIT))
+#define pte_mkhuge(pte)		(__pte(pte_val(pte) & ~PTE_TABLE_BIT))
+
+/*
+ * Hugetlb definitions.
+ */
+#define HUGE_MAX_HSTATE		2
+#define HPAGE_SHIFT		PMD_SHIFT
+#define HPAGE_SIZE		(_AC(1, UL) << HPAGE_SHIFT)
+#define HPAGE_MASK		(~(HPAGE_SIZE - 1))
+#define HUGETLB_PAGE_ORDER	(HPAGE_SHIFT - PAGE_SHIFT)
 
 #define __HAVE_ARCH_PTE_SPECIAL
 
diff --git a/arch/arm64/mm/Makefile b/arch/arm64/mm/Makefile
index 3140a2a..b51d364 100644
--- a/arch/arm64/mm/Makefile
+++ b/arch/arm64/mm/Makefile
@@ -2,3 +2,4 @@ obj-y				:= dma-mapping.o extable.o fault.o init.o \
 				   cache.o copypage.o flush.o \
 				   ioremap.o mmap.o pgd.o mmu.o \
 				   context.o tlb.o proc.o
+obj-$(CONFIG_HUGETLB_PAGE)	+= hugetlbpage.o
diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
index 5263817..36e3080 100644
--- a/arch/arm64/mm/fault.c
+++ b/arch/arm64/mm/fault.c
@@ -363,17 +363,6 @@ static int __kprobes do_translation_fault(unsigned long addr,
 }
 
 /*
- * Some section permission faults need to be handled gracefully.  They can
- * happen due to a __{get,put}_user during an oops.
- */
-static int do_sect_fault(unsigned long addr, unsigned int esr,
-			 struct pt_regs *regs)
-{
-	do_bad_area(addr, esr, regs);
-	return 0;
-}
-
-/*
  * This abort handler always returns "fault".
  */
 static int do_bad(unsigned long addr, unsigned int esr, struct pt_regs *regs)
@@ -396,12 +385,12 @@ static struct fault_info {
 	{ do_translation_fault,	SIGSEGV, SEGV_MAPERR,	"level 2 translation fault"	},
 	{ do_page_fault,	SIGSEGV, SEGV_MAPERR,	"level 3 translation fault"	},
 	{ do_bad,		SIGBUS,  0,		"reserved access flag fault"	},
-	{ do_bad,		SIGSEGV, SEGV_ACCERR,	"level 1 access flag fault"	},
-	{ do_bad,		SIGSEGV, SEGV_ACCERR,	"level 2 access flag fault"	},
+	{ do_page_fault,	SIGSEGV, SEGV_ACCERR,	"level 1 access flag fault"	},
+	{ do_page_fault,	SIGSEGV, SEGV_ACCERR,	"level 2 access flag fault"	},
 	{ do_page_fault,	SIGSEGV, SEGV_ACCERR,	"level 3 access flag fault"	},
 	{ do_bad,		SIGBUS,  0,		"reserved permission fault"	},
-	{ do_bad,		SIGSEGV, SEGV_ACCERR,	"level 1 permission fault"	},
-	{ do_sect_fault,	SIGSEGV, SEGV_ACCERR,	"level 2 permission fault"	},
+	{ do_page_fault,	SIGSEGV, SEGV_ACCERR,	"level 1 permission fault"	},
+	{ do_page_fault,	SIGSEGV, SEGV_ACCERR,	"level 2 permission fault"	},
 	{ do_page_fault,	SIGSEGV, SEGV_ACCERR,	"level 3 permission fault"	},
 	{ do_bad,		SIGBUS,  0,		"synchronous external abort"	},
 	{ do_bad,		SIGBUS,  0,		"asynchronous external abort"	},
diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
new file mode 100644
index 0000000..2fc8258
--- /dev/null
+++ b/arch/arm64/mm/hugetlbpage.c
@@ -0,0 +1,70 @@
+/*
+ * arch/arm64/mm/hugetlbpage.c
+ *
+ * Copyright (C) 2013 Linaro Ltd.
+ *
+ * Based on arch/x86/mm/hugetlbpage.c.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ */
+
+#include <linux/init.h>
+#include <linux/fs.h>
+#include <linux/mm.h>
+#include <linux/hugetlb.h>
+#include <linux/pagemap.h>
+#include <linux/err.h>
+#include <linux/sysctl.h>
+#include <asm/mman.h>
+#include <asm/tlb.h>
+#include <asm/tlbflush.h>
+#include <asm/pgalloc.h>
+
+#ifndef CONFIG_ARCH_WANT_HUGE_PMD_SHARE
+int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
+{
+	return 0;
+}
+#endif
+
+struct page *follow_huge_addr(struct mm_struct *mm, unsigned long address,
+			      int write)
+{
+	return ERR_PTR(-EINVAL);
+}
+
+int pmd_huge(pmd_t pmd)
+{
+	return !(pmd_val(pmd) & PMD_TABLE_BIT);
+}
+
+int pud_huge(pud_t pud)
+{
+	return !(pud_val(pud) & PUD_TABLE_BIT);
+}
+
+static __init int setup_hugepagesz(char *opt)
+{
+	unsigned long ps = memparse(opt, &opt);
+	if (ps == PMD_SIZE) {
+		hugetlb_add_hstate(PMD_SHIFT - PAGE_SHIFT);
+	} else if (ps == PUD_SIZE) {
+		hugetlb_add_hstate(PUD_SHIFT - PAGE_SHIFT);
+	} else {
+		pr_err("hugepagesz: Unsupported page size %lu M\n", ps >> 20);
+		return 0;
+	}
+	return 1;
+}
+__setup("hugepagesz=", setup_hugepagesz);
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
