Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E45D56B038C
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 17:39:21 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id x127so112813810pgb.4
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 14:39:21 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id o4si4575222pfi.298.2017.03.16.14.39.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 14:39:20 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 7/7] x86/mm: Switch to generic get_user_page_fast() implementation
Date: Fri, 17 Mar 2017 00:39:06 +0300
Message-Id: <20170316213906.89528-1-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170316152655.37789-8-kirill.shutemov@linux.intel.com>
References: <20170316152655.37789-8-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Dave Hansen <dave.hansen@intel.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Steve Capper <steve.capper@linaro.org>, Dann Frazier <dann.frazier@canonical.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The patch provides all required hooks to match generic
get_user_pages_fast() behaviour to x86 and switch x86 over.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 v2:
    - Fix build on non-PAE 32-bit x86;
    - Rename HAVE_GENERIC_RCU_GUP to HAVE_GENERIC_GUP and update comment;
---
 arch/arm/Kconfig                      |   2 +-
 arch/arm64/Kconfig                    |   2 +-
 arch/powerpc/Kconfig                  |   2 +-
 arch/x86/Kconfig                      |   3 +
 arch/x86/include/asm/mmu_context.h    |  12 -
 arch/x86/include/asm/pgtable-3level.h |  45 +++
 arch/x86/include/asm/pgtable.h        |  53 ++++
 arch/x86/include/asm/pgtable_64.h     |  16 +-
 arch/x86/mm/Makefile                  |   2 +-
 arch/x86/mm/gup.c                     | 496 ----------------------------------
 mm/Kconfig                            |   2 +-
 mm/gup.c                              |  10 +-
 12 files changed, 126 insertions(+), 519 deletions(-)
 delete mode 100644 arch/x86/mm/gup.c

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 0d4e71b42c77..454fadd077ad 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -1666,7 +1666,7 @@ config ARCH_SELECT_MEMORY_MODEL
 config HAVE_ARCH_PFN_VALID
 	def_bool ARCH_HAS_HOLES_MEMORYMODEL || !SPARSEMEM
 
-config HAVE_GENERIC_RCU_GUP
+config HAVE_GENERIC_GUP
 	def_bool y
 	depends on ARM_LPAE
 
diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 8c7c244247b6..e0306e4b6cc8 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -205,7 +205,7 @@ config GENERIC_CALIBRATE_DELAY
 config ZONE_DMA
 	def_bool y
 
-config HAVE_GENERIC_RCU_GUP
+config HAVE_GENERIC_GUP
 	def_bool y
 
 config ARCH_DMA_ADDR_T_64BIT
diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 97a8bc8a095c..3a716b2dcde9 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -135,7 +135,7 @@ config PPC
 	select HAVE_FUNCTION_GRAPH_TRACER
 	select HAVE_FUNCTION_TRACER
 	select HAVE_GCC_PLUGINS
-	select HAVE_GENERIC_RCU_GUP
+	select HAVE_GENERIC_GUP
 	select HAVE_HW_BREAKPOINT		if PERF_EVENTS && (PPC_BOOK3S || PPC_8xx)
 	select HAVE_IDE
 	select HAVE_IOREMAP_PROT
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 2bab9d093b51..8977d9c77373 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -2788,6 +2788,9 @@ config X86_DMA_REMAP
 	bool
 	depends on STA2X11
 
+config HAVE_GENERIC_GUP
+	def_bool y
+
 source "net/Kconfig"
 
 source "drivers/Kconfig"
diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index 68b329d77b3a..6e933d2d88d9 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -220,18 +220,6 @@ static inline int vma_pkey(struct vm_area_struct *vma)
 }
 #endif
 
-static inline bool __pkru_allows_pkey(u16 pkey, bool write)
-{
-	u32 pkru = read_pkru();
-
-	if (!__pkru_allows_read(pkru, pkey))
-		return false;
-	if (write && !__pkru_allows_write(pkru, pkey))
-		return false;
-
-	return true;
-}
-
 /*
  * We only want to enforce protection keys on the current process
  * because we effectively have no access to PKRU for other
diff --git a/arch/x86/include/asm/pgtable-3level.h b/arch/x86/include/asm/pgtable-3level.h
index 72277b1028a5..698060a0dfb6 100644
--- a/arch/x86/include/asm/pgtable-3level.h
+++ b/arch/x86/include/asm/pgtable-3level.h
@@ -215,4 +215,49 @@ static inline pud_t native_pudp_get_and_clear(pud_t *pudp)
 #define __pte_to_swp_entry(pte)		((swp_entry_t){ (pte).pte_high })
 #define __swp_entry_to_pte(x)		((pte_t){ { .pte_high = (x).val } })
 
+#define gup_get_pte gup_get_pte
+/*
+ * WARNING: only to be used in get_user_pages_fast() implementation.
+ *
+ * With get_user_pages_fast, we walk down the pagetables without taking
+ * any locks.  For this we would like to load the pointers atomically,
+ * but that is not possible (without expensive cmpxchg8b) on PAE.  What
+ * we do have is the guarantee that a pte will only either go from not
+ * present to present, or present to not present or both -- it will not
+ * switch to a completely different present page without a TLB flush in
+ * between; something that we are blocking by holding interrupts off.
+ *
+ * Setting ptes from not present to present goes:
+ * ptep->pte_high = h;
+ * smp_wmb();
+ * ptep->pte_low = l;
+ *
+ * And present to not present goes:
+ * ptep->pte_low = 0;
+ * smp_wmb();
+ * ptep->pte_high = 0;
+ *
+ * We must ensure here that the load of pte_low sees l iff pte_high
+ * sees h. We load pte_high *after* loading pte_low, which ensures we
+ * don't see an older value of pte_high.  *Then* we recheck pte_low,
+ * which ensures that we haven't picked up a changed pte high. We might
+ * have got rubbish values from pte_low and pte_high, but we are
+ * guaranteed that pte_low will not have the present bit set *unless*
+ * it is 'l'. And get_user_pages_fast only operates on present ptes, so
+ * we're safe.
+ */
+static inline pte_t gup_get_pte(pte_t *ptep)
+{
+	pte_t pte;
+
+	do {
+		pte.pte_low = ptep->pte_low;
+		smp_rmb();
+		pte.pte_high = ptep->pte_high;
+		smp_rmb();
+	} while (unlikely(pte.pte_low != ptep->pte_low));
+
+	return pte;
+}
+
 #endif /* _ASM_X86_PGTABLE_3LEVEL_H */
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 83f17218e66a..e55fe9475979 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -230,6 +230,11 @@ static inline int pud_devmap(pud_t pud)
 {
 	return 0;
 }
+
+static inline int pgd_devmap(pgd_t pgd)
+{
+	return 0;
+}
 #endif
 #endif
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
@@ -1135,6 +1140,54 @@ static inline u16 pte_flags_pkey(unsigned long pte_flags)
 #endif
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
+ * 'pteval' can come from a pte, pmd or pud.  We only check
+ * _PAGE_PRESENT, _PAGE_USER, and _PAGE_RW in here which are the
+ * same value on all 3 types.
+ */
+static inline bool __pte_access_permitted(unsigned long pteval, bool write)
+{
+	unsigned long need_pte_bits = _PAGE_PRESENT|_PAGE_USER;
+
+	if (write)
+		need_pte_bits |= _PAGE_RW;
+
+	if ((pteval & need_pte_bits) != need_pte_bits)
+		return 0;
+
+	return __pkru_allows_pkey(pte_flags_pkey(pteval), write);
+}
+
+#define pte_access_permitted pte_access_permitted
+static inline bool pte_access_permitted(pte_t pte, bool write)
+{
+	return __pte_access_permitted(pte_val(pte), write);
+}
+
+#define pmd_access_permitted pmd_access_permitted
+static inline bool pmd_access_permitted(pmd_t pmd, bool write)
+{
+	return __pte_access_permitted(pmd_val(pmd), write);
+}
+
+#define pud_access_permitted pud_access_permitted
+static inline bool pud_access_permitted(pud_t pud, bool write)
+{
+	return __pte_access_permitted(pud_val(pud), write);
+}
+
 #include <asm-generic/pgtable.h>
 #endif	/* __ASSEMBLY__ */
 
diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index 73c7ccc38912..1a4bc71534d4 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -206,6 +206,20 @@ extern void cleanup_highmap(void);
 extern void init_extra_mapping_uc(unsigned long phys, unsigned long size);
 extern void init_extra_mapping_wb(unsigned long phys, unsigned long size);
 
-#endif /* !__ASSEMBLY__ */
+#define gup_fast_permitted gup_fast_permitted
+static inline bool gup_fast_permitted(unsigned long start, int nr_pages,
+		int write)
+{
+	unsigned long len, end;
+
+	len = (unsigned long)nr_pages << PAGE_SHIFT;
+	end = start + len;
+	if (end < start)
+		return false;
+	if (end >> __VIRTUAL_MASK_SHIFT)
+		return false;
+	return true;
+}
 
+#endif /* !__ASSEMBLY__ */
 #endif /* _ASM_X86_PGTABLE_64_H */
diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
index 96d2b847e09e..0fbdcb64f9f8 100644
--- a/arch/x86/mm/Makefile
+++ b/arch/x86/mm/Makefile
@@ -2,7 +2,7 @@
 KCOV_INSTRUMENT_tlb.o	:= n
 
 obj-y	:=  init.o init_$(BITS).o fault.o ioremap.o extable.o pageattr.o mmap.o \
-	    pat.o pgtable.o physaddr.o gup.o setup_nx.o tlb.o
+	    pat.o pgtable.o physaddr.o setup_nx.o tlb.o
 
 # Make sure __phys_addr has no stackprotector
 nostackp := $(call cc-option, -fno-stack-protector)
diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
deleted file mode 100644
index 456dfdfd2249..000000000000
--- a/arch/x86/mm/gup.c
+++ /dev/null
@@ -1,496 +0,0 @@
-/*
- * Lockless get_user_pages_fast for x86
- *
- * Copyright (C) 2008 Nick Piggin
- * Copyright (C) 2008 Novell Inc.
- */
-#include <linux/sched.h>
-#include <linux/mm.h>
-#include <linux/vmstat.h>
-#include <linux/highmem.h>
-#include <linux/swap.h>
-#include <linux/memremap.h>
-
-#include <asm/mmu_context.h>
-#include <asm/pgtable.h>
-
-static inline pte_t gup_get_pte(pte_t *ptep)
-{
-#ifndef CONFIG_X86_PAE
-	return READ_ONCE(*ptep);
-#else
-	/*
-	 * With get_user_pages_fast, we walk down the pagetables without taking
-	 * any locks.  For this we would like to load the pointers atomically,
-	 * but that is not possible (without expensive cmpxchg8b) on PAE.  What
-	 * we do have is the guarantee that a pte will only either go from not
-	 * present to present, or present to not present or both -- it will not
-	 * switch to a completely different present page without a TLB flush in
-	 * between; something that we are blocking by holding interrupts off.
-	 *
-	 * Setting ptes from not present to present goes:
-	 * ptep->pte_high = h;
-	 * smp_wmb();
-	 * ptep->pte_low = l;
-	 *
-	 * And present to not present goes:
-	 * ptep->pte_low = 0;
-	 * smp_wmb();
-	 * ptep->pte_high = 0;
-	 *
-	 * We must ensure here that the load of pte_low sees l iff pte_high
-	 * sees h. We load pte_high *after* loading pte_low, which ensures we
-	 * don't see an older value of pte_high.  *Then* we recheck pte_low,
-	 * which ensures that we haven't picked up a changed pte high. We might
-	 * have got rubbish values from pte_low and pte_high, but we are
-	 * guaranteed that pte_low will not have the present bit set *unless*
-	 * it is 'l'. And get_user_pages_fast only operates on present ptes, so
-	 * we're safe.
-	 *
-	 * gup_get_pte should not be used or copied outside gup.c without being
-	 * very careful -- it does not atomically load the pte or anything that
-	 * is likely to be useful for you.
-	 */
-	pte_t pte;
-
-retry:
-	pte.pte_low = ptep->pte_low;
-	smp_rmb();
-	pte.pte_high = ptep->pte_high;
-	smp_rmb();
-	if (unlikely(pte.pte_low != ptep->pte_low))
-		goto retry;
-
-	return pte;
-#endif
-}
-
-static void undo_dev_pagemap(int *nr, int nr_start, struct page **pages)
-{
-	while ((*nr) - nr_start) {
-		struct page *page = pages[--(*nr)];
-
-		ClearPageReferenced(page);
-		put_page(page);
-	}
-}
-
-/*
- * 'pteval' can come from a pte, pmd, pud or p4d.  We only check
- * _PAGE_PRESENT, _PAGE_USER, and _PAGE_RW in here which are the
- * same value on all 4 types.
- */
-static inline int pte_allows_gup(unsigned long pteval, int write)
-{
-	unsigned long need_pte_bits = _PAGE_PRESENT|_PAGE_USER;
-
-	if (write)
-		need_pte_bits |= _PAGE_RW;
-
-	if ((pteval & need_pte_bits) != need_pte_bits)
-		return 0;
-
-	/* Check memory protection keys permissions. */
-	if (!__pkru_allows_pkey(pte_flags_pkey(pteval), write))
-		return 0;
-
-	return 1;
-}
-
-/*
- * The performance critical leaf functions are made noinline otherwise gcc
- * inlines everything into a single function which results in too much
- * register pressure.
- */
-static noinline int gup_pte_range(pmd_t pmd, unsigned long addr,
-		unsigned long end, int write, struct page **pages, int *nr)
-{
-	struct dev_pagemap *pgmap = NULL;
-	int nr_start = *nr, ret = 0;
-	pte_t *ptep, *ptem;
-
-	/*
-	 * Keep the original mapped PTE value (ptem) around since we
-	 * might increment ptep off the end of the page when finishing
-	 * our loop iteration.
-	 */
-	ptem = ptep = pte_offset_map(&pmd, addr);
-	do {
-		pte_t pte = gup_get_pte(ptep);
-		struct page *page;
-
-		/* Similar to the PMD case, NUMA hinting must take slow path */
-		if (pte_protnone(pte))
-			break;
-
-		if (!pte_allows_gup(pte_val(pte), write))
-			break;
-
-		if (pte_devmap(pte)) {
-			pgmap = get_dev_pagemap(pte_pfn(pte), pgmap);
-			if (unlikely(!pgmap)) {
-				undo_dev_pagemap(nr, nr_start, pages);
-				break;
-			}
-		} else if (pte_special(pte))
-			break;
-
-		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
-		page = pte_page(pte);
-		get_page(page);
-		put_dev_pagemap(pgmap);
-		SetPageReferenced(page);
-		pages[*nr] = page;
-		(*nr)++;
-
-	} while (ptep++, addr += PAGE_SIZE, addr != end);
-	if (addr == end)
-		ret = 1;
-	pte_unmap(ptem);
-
-	return ret;
-}
-
-static inline void get_head_page_multiple(struct page *page, int nr)
-{
-	VM_BUG_ON_PAGE(page != compound_head(page), page);
-	VM_BUG_ON_PAGE(page_count(page) == 0, page);
-	page_ref_add(page, nr);
-	SetPageReferenced(page);
-}
-
-static int __gup_device_huge(unsigned long pfn, unsigned long addr,
-		unsigned long end, struct page **pages, int *nr)
-{
-	int nr_start = *nr;
-	struct dev_pagemap *pgmap = NULL;
-
-	do {
-		struct page *page = pfn_to_page(pfn);
-
-		pgmap = get_dev_pagemap(pfn, pgmap);
-		if (unlikely(!pgmap)) {
-			undo_dev_pagemap(nr, nr_start, pages);
-			return 0;
-		}
-		SetPageReferenced(page);
-		pages[*nr] = page;
-		get_page(page);
-		put_dev_pagemap(pgmap);
-		(*nr)++;
-		pfn++;
-	} while (addr += PAGE_SIZE, addr != end);
-	return 1;
-}
-
-static int __gup_device_huge_pmd(pmd_t pmd, unsigned long addr,
-		unsigned long end, struct page **pages, int *nr)
-{
-	unsigned long fault_pfn;
-
-	fault_pfn = pmd_pfn(pmd) + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
-	return __gup_device_huge(fault_pfn, addr, end, pages, nr);
-}
-
-static int __gup_device_huge_pud(pud_t pud, unsigned long addr,
-		unsigned long end, struct page **pages, int *nr)
-{
-	unsigned long fault_pfn;
-
-	fault_pfn = pud_pfn(pud) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
-	return __gup_device_huge(fault_pfn, addr, end, pages, nr);
-}
-
-static noinline int gup_huge_pmd(pmd_t pmd, unsigned long addr,
-		unsigned long end, int write, struct page **pages, int *nr)
-{
-	struct page *head, *page;
-	int refs;
-
-	if (!pte_allows_gup(pmd_val(pmd), write))
-		return 0;
-
-	VM_BUG_ON(!pfn_valid(pmd_pfn(pmd)));
-	if (pmd_devmap(pmd))
-		return __gup_device_huge_pmd(pmd, addr, end, pages, nr);
-
-	/* hugepages are never "special" */
-	VM_BUG_ON(pmd_flags(pmd) & _PAGE_SPECIAL);
-
-	refs = 0;
-	head = pmd_page(pmd);
-	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
-	do {
-		VM_BUG_ON_PAGE(compound_head(page) != head, page);
-		pages[*nr] = page;
-		(*nr)++;
-		page++;
-		refs++;
-	} while (addr += PAGE_SIZE, addr != end);
-	get_head_page_multiple(head, refs);
-
-	return 1;
-}
-
-static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
-		int write, struct page **pages, int *nr)
-{
-	unsigned long next;
-	pmd_t *pmdp;
-
-	pmdp = pmd_offset(&pud, addr);
-	do {
-		pmd_t pmd = *pmdp;
-
-		next = pmd_addr_end(addr, end);
-		if (pmd_none(pmd))
-			return 0;
-		if (unlikely(pmd_large(pmd) || !pmd_present(pmd))) {
-			/*
-			 * NUMA hinting faults need to be handled in the GUP
-			 * slowpath for accounting purposes and so that they
-			 * can be serialised against THP migration.
-			 */
-			if (pmd_protnone(pmd))
-				return 0;
-			if (!gup_huge_pmd(pmd, addr, next, write, pages, nr))
-				return 0;
-		} else {
-			if (!gup_pte_range(pmd, addr, next, write, pages, nr))
-				return 0;
-		}
-	} while (pmdp++, addr = next, addr != end);
-
-	return 1;
-}
-
-static noinline int gup_huge_pud(pud_t pud, unsigned long addr,
-		unsigned long end, int write, struct page **pages, int *nr)
-{
-	struct page *head, *page;
-	int refs;
-
-	if (!pte_allows_gup(pud_val(pud), write))
-		return 0;
-
-	VM_BUG_ON(!pfn_valid(pud_pfn(pud)));
-	if (pud_devmap(pud))
-		return __gup_device_huge_pud(pud, addr, end, pages, nr);
-
-	/* hugepages are never "special" */
-	VM_BUG_ON(pud_flags(pud) & _PAGE_SPECIAL);
-
-	refs = 0;
-	head = pud_page(pud);
-	page = head + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
-	do {
-		VM_BUG_ON_PAGE(compound_head(page) != head, page);
-		pages[*nr] = page;
-		(*nr)++;
-		page++;
-		refs++;
-	} while (addr += PAGE_SIZE, addr != end);
-	get_head_page_multiple(head, refs);
-
-	return 1;
-}
-
-static int gup_pud_range(p4d_t p4d, unsigned long addr, unsigned long end,
-			int write, struct page **pages, int *nr)
-{
-	unsigned long next;
-	pud_t *pudp;
-
-	pudp = pud_offset(&p4d, addr);
-	do {
-		pud_t pud = *pudp;
-
-		next = pud_addr_end(addr, end);
-		if (pud_none(pud))
-			return 0;
-		if (unlikely(pud_large(pud))) {
-			if (!gup_huge_pud(pud, addr, next, write, pages, nr))
-				return 0;
-		} else {
-			if (!gup_pmd_range(pud, addr, next, write, pages, nr))
-				return 0;
-		}
-	} while (pudp++, addr = next, addr != end);
-
-	return 1;
-}
-
-static int gup_p4d_range(pgd_t pgd, unsigned long addr, unsigned long end,
-			int write, struct page **pages, int *nr)
-{
-	unsigned long next;
-	p4d_t *p4dp;
-
-	p4dp = p4d_offset(&pgd, addr);
-	do {
-		p4d_t p4d = *p4dp;
-
-		next = p4d_addr_end(addr, end);
-		if (p4d_none(p4d))
-			return 0;
-		BUILD_BUG_ON(p4d_large(p4d));
-		if (!gup_pud_range(p4d, addr, next, write, pages, nr))
-			return 0;
-	} while (p4dp++, addr = next, addr != end);
-
-	return 1;
-}
-
-/*
- * Like get_user_pages_fast() except its IRQ-safe in that it won't fall
- * back to the regular GUP.
- */
-int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
-			  struct page **pages)
-{
-	struct mm_struct *mm = current->mm;
-	unsigned long addr, len, end;
-	unsigned long next;
-	unsigned long flags;
-	pgd_t *pgdp;
-	int nr = 0;
-
-	start &= PAGE_MASK;
-	addr = start;
-	len = (unsigned long) nr_pages << PAGE_SHIFT;
-	end = start + len;
-	if (unlikely(!access_ok(write ? VERIFY_WRITE : VERIFY_READ,
-					(void __user *)start, len)))
-		return 0;
-
-	/*
-	 * XXX: batch / limit 'nr', to avoid large irq off latency
-	 * needs some instrumenting to determine the common sizes used by
-	 * important workloads (eg. DB2), and whether limiting the batch size
-	 * will decrease performance.
-	 *
-	 * It seems like we're in the clear for the moment. Direct-IO is
-	 * the main guy that batches up lots of get_user_pages, and even
-	 * they are limited to 64-at-a-time which is not so many.
-	 */
-	/*
-	 * This doesn't prevent pagetable teardown, but does prevent
-	 * the pagetables and pages from being freed on x86.
-	 *
-	 * So long as we atomically load page table pointers versus teardown
-	 * (which we do on x86, with the above PAE exception), we can follow the
-	 * address down to the the page and take a ref on it.
-	 */
-	local_irq_save(flags);
-	pgdp = pgd_offset(mm, addr);
-	do {
-		pgd_t pgd = *pgdp;
-
-		next = pgd_addr_end(addr, end);
-		if (pgd_none(pgd))
-			break;
-		if (!gup_p4d_range(pgd, addr, next, write, pages, &nr))
-			break;
-	} while (pgdp++, addr = next, addr != end);
-	local_irq_restore(flags);
-
-	return nr;
-}
-
-/**
- * get_user_pages_fast() - pin user pages in memory
- * @start:	starting user address
- * @nr_pages:	number of pages from start to pin
- * @write:	whether pages will be written to
- * @pages:	array that receives pointers to the pages pinned.
- * 		Should be at least nr_pages long.
- *
- * Attempt to pin user pages in memory without taking mm->mmap_sem.
- * If not successful, it will fall back to taking the lock and
- * calling get_user_pages().
- *
- * Returns number of pages pinned. This may be fewer than the number
- * requested. If nr_pages is 0 or negative, returns 0. If no pages
- * were pinned, returns -errno.
- */
-int get_user_pages_fast(unsigned long start, int nr_pages, int write,
-			struct page **pages)
-{
-	struct mm_struct *mm = current->mm;
-	unsigned long addr, len, end;
-	unsigned long next;
-	pgd_t *pgdp;
-	int nr = 0;
-
-	start &= PAGE_MASK;
-	addr = start;
-	len = (unsigned long) nr_pages << PAGE_SHIFT;
-
-	end = start + len;
-	if (end < start)
-		goto slow_irqon;
-
-#ifdef CONFIG_X86_64
-	if (end >> __VIRTUAL_MASK_SHIFT)
-		goto slow_irqon;
-#endif
-
-	/*
-	 * XXX: batch / limit 'nr', to avoid large irq off latency
-	 * needs some instrumenting to determine the common sizes used by
-	 * important workloads (eg. DB2), and whether limiting the batch size
-	 * will decrease performance.
-	 *
-	 * It seems like we're in the clear for the moment. Direct-IO is
-	 * the main guy that batches up lots of get_user_pages, and even
-	 * they are limited to 64-at-a-time which is not so many.
-	 */
-	/*
-	 * This doesn't prevent pagetable teardown, but does prevent
-	 * the pagetables and pages from being freed on x86.
-	 *
-	 * So long as we atomically load page table pointers versus teardown
-	 * (which we do on x86, with the above PAE exception), we can follow the
-	 * address down to the the page and take a ref on it.
-	 */
-	local_irq_disable();
-	pgdp = pgd_offset(mm, addr);
-	do {
-		pgd_t pgd = *pgdp;
-
-		next = pgd_addr_end(addr, end);
-		if (pgd_none(pgd))
-			goto slow;
-		if (!gup_p4d_range(pgd, addr, next, write, pages, &nr))
-			goto slow;
-	} while (pgdp++, addr = next, addr != end);
-	local_irq_enable();
-
-	VM_BUG_ON(nr != (end - start) >> PAGE_SHIFT);
-	return nr;
-
-	{
-		int ret;
-
-slow:
-		local_irq_enable();
-slow_irqon:
-		/* Try to get the remaining pages with get_user_pages */
-		start += nr << PAGE_SHIFT;
-		pages += nr;
-
-		ret = get_user_pages_unlocked(start,
-					      (end - start) >> PAGE_SHIFT,
-					      pages, write ? FOLL_WRITE : 0);
-
-		/* Have to be a bit careful with return values */
-		if (nr > 0) {
-			if (ret < 0)
-				ret = nr;
-			else
-				ret += nr;
-		}
-
-		return ret;
-	}
-}
diff --git a/mm/Kconfig b/mm/Kconfig
index 9b8fccb969dc..c89f472b658c 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -137,7 +137,7 @@ config HAVE_MEMBLOCK_NODE_MAP
 config HAVE_MEMBLOCK_PHYS_MAP
 	bool
 
-config HAVE_GENERIC_RCU_GUP
+config HAVE_GENERIC_GUP
 	bool
 
 config ARCH_DISCARD_MEMBLOCK
diff --git a/mm/gup.c b/mm/gup.c
index a6e21380c8b0..5cc489d98562 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1155,7 +1155,7 @@ struct page *get_dump_page(unsigned long addr)
 #endif /* CONFIG_ELF_CORE */
 
 /*
- * Generic RCU Fast GUP
+ * Generic Fast GUP
  *
  * get_user_pages_fast attempts to pin user pages by walking the page
  * tables directly and avoids taking locks. Thus the walker needs to be
@@ -1176,8 +1176,8 @@ struct page *get_dump_page(unsigned long addr)
  * Before activating this code, please be aware that the following assumptions
  * are currently made:
  *
- *  *) HAVE_RCU_TABLE_FREE is enabled, and tlb_remove_table is used to free
- *      pages containing page tables.
+ *  *) Either HAVE_RCU_TABLE_FREE is enabled, and tlb_remove_table is used to
+ *  free pages containing page tables or TLB flushing requires IPI broadcast.
  *
  *  *) ptes can be read atomically by the architecture.
  *
@@ -1187,7 +1187,7 @@ struct page *get_dump_page(unsigned long addr)
  *
  * This code is based heavily on the PowerPC implementation by Nick Piggin.
  */
-#ifdef CONFIG_HAVE_GENERIC_RCU_GUP
+#ifdef CONFIG_HAVE_GENERIC_GUP
 
 #ifndef gup_get_pte
 /*
@@ -1663,4 +1663,4 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	return ret;
 }
 
-#endif /* CONFIG_HAVE_GENERIC_RCU_GUP */
+#endif /* CONFIG_HAVE_GENERIC_GUP */
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
