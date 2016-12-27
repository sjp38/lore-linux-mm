Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 68E106B0290
	for <linux-mm@kvack.org>; Mon, 26 Dec 2016 20:55:23 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 17so501216030pfy.2
        for <linux-mm@kvack.org>; Mon, 26 Dec 2016 17:55:23 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id b187si44760232pgc.0.2016.12.26.17.55.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Dec 2016 17:55:21 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 06/29] mm: convert generic code to 5-level paging
Date: Tue, 27 Dec 2016 04:53:50 +0300
Message-Id: <20161227015413.187403-7-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
References: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Convers all non-architecture-specific code to 5-level paging.

It's mosly mechanical adding handling one more page table level in
places where we deal with pud_t.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 drivers/misc/sgi-gru/grufault.c |   9 +-
 fs/userfaultfd.c                |   6 +-
 include/asm-generic/pgtable.h   |  48 +++++++++-
 include/linux/hugetlb.h         |   5 +-
 include/linux/kasan.h           |   1 +
 include/linux/mm.h              |  31 ++++--
 lib/ioremap.c                   |  39 +++++++-
 mm/gup.c                        |  46 +++++++--
 mm/huge_memory.c                |   7 +-
 mm/hugetlb.c                    |  29 +++---
 mm/kasan/kasan_init.c           |  35 ++++++-
 mm/memory.c                     | 207 +++++++++++++++++++++++++++++++++-------
 mm/mlock.c                      |   1 +
 mm/mprotect.c                   |  26 ++++-
 mm/mremap.c                     |  13 ++-
 mm/pagewalk.c                   |  32 ++++++-
 mm/pgtable-generic.c            |   6 ++
 mm/rmap.c                       |  13 ++-
 mm/sparse-vmemmap.c             |  22 ++++-
 mm/swapfile.c                   |  26 ++++-
 mm/userfaultfd.c                |  23 +++--
 mm/vmalloc.c                    |  81 ++++++++++++----
 22 files changed, 586 insertions(+), 120 deletions(-)

diff --git a/drivers/misc/sgi-gru/grufault.c b/drivers/misc/sgi-gru/grufault.c
index 6fb773dbcd0c..93be82fc338a 100644
--- a/drivers/misc/sgi-gru/grufault.c
+++ b/drivers/misc/sgi-gru/grufault.c
@@ -219,15 +219,20 @@ static int atomic_pte_lookup(struct vm_area_struct *vma, unsigned long vaddr,
 	int write, unsigned long *paddr, int *pageshift)
 {
 	pgd_t *pgdp;
-	pmd_t *pmdp;
+	p4d_t *p4dp;
 	pud_t *pudp;
+	pmd_t *pmdp;
 	pte_t pte;
 
 	pgdp = pgd_offset(vma->vm_mm, vaddr);
 	if (unlikely(pgd_none(*pgdp)))
 		goto err;
 
-	pudp = pud_offset(pgdp, vaddr);
+	p4dp = p4d_offset(pgdp, vaddr);
+	if (unlikely(p4d_none(*p4dp)))
+		goto err;
+
+	pudp = pud_offset(p4dp, vaddr);
 	if (unlikely(pud_none(*pudp)))
 		goto err;
 
diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index d96e2f30084b..20e04bd11654 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -195,6 +195,7 @@ static inline bool userfaultfd_must_wait(struct userfaultfd_ctx *ctx,
 {
 	struct mm_struct *mm = ctx->mm;
 	pgd_t *pgd;
+	p4d_t *p4d;
 	pud_t *pud;
 	pmd_t *pmd, _pmd;
 	pte_t *pte;
@@ -205,7 +206,10 @@ static inline bool userfaultfd_must_wait(struct userfaultfd_ctx *ctx,
 	pgd = pgd_offset(mm, address);
 	if (!pgd_present(*pgd))
 		goto out;
-	pud = pud_offset(pgd, address);
+	p4d = p4d_offset(pgd, address);
+	if (!p4d_present(*p4d))
+		goto out;
+	pud = pud_offset(p4d, address);
 	if (!pud_present(*pud))
 		goto out;
 	pmd = pmd_offset(pud, address);
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 18af2bcefe6a..dc6a54318cf5 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -10,9 +10,9 @@
 #include <linux/bug.h>
 #include <linux/errno.h>
 
-#if 4 - defined(__PAGETABLE_PUD_FOLDED) - defined(__PAGETABLE_PMD_FOLDED) != \
-	CONFIG_PGTABLE_LEVELS
-#error CONFIG_PGTABLE_LEVELS is not consistent with __PAGETABLE_{PUD,PMD}_FOLDED
+#if 5 - defined(__PAGETABLE_P4D_FOLDED) - defined(__PAGETABLE_PUD_FOLDED) - \
+	defined(__PAGETABLE_PMD_FOLDED) != CONFIG_PGTABLE_LEVELS
+#error CONFIG_PGTABLE_LEVELS is not consistent with __PAGETABLE_{P4D,PUD,PMD}_FOLDED
 #endif
 
 /*
@@ -339,6 +339,13 @@ static inline pgprot_t pgprot_modify(pgprot_t oldprot, pgprot_t newprot)
 	(__boundary - 1 < (end) - 1)? __boundary: (end);		\
 })
 
+#ifndef p4d_addr_end
+#define p4d_addr_end(addr, end)						\
+({	unsigned long __boundary = ((addr) + P4D_SIZE) & P4D_MASK;	\
+	(__boundary - 1 < (end) - 1)? __boundary: (end);		\
+})
+#endif
+
 #ifndef pud_addr_end
 #define pud_addr_end(addr, end)						\
 ({	unsigned long __boundary = ((addr) + PUD_SIZE) & PUD_MASK;	\
@@ -359,6 +366,7 @@ static inline pgprot_t pgprot_modify(pgprot_t oldprot, pgprot_t newprot)
  * Do the tests inline, but report and clear the bad entry in mm/memory.c.
  */
 void pgd_clear_bad(pgd_t *);
+void p4d_clear_bad(p4d_t *);
 void pud_clear_bad(pud_t *);
 void pmd_clear_bad(pmd_t *);
 
@@ -373,6 +381,17 @@ static inline int pgd_none_or_clear_bad(pgd_t *pgd)
 	return 0;
 }
 
+static inline int p4d_none_or_clear_bad(p4d_t *p4d)
+{
+	if (p4d_none(*p4d))
+		return 1;
+	if (unlikely(p4d_bad(*p4d))) {
+		p4d_clear_bad(p4d);
+		return 1;
+	}
+	return 0;
+}
+
 static inline int pud_none_or_clear_bad(pud_t *pud)
 {
 	if (pud_none(*pud))
@@ -750,11 +769,30 @@ static inline int pmd_protnone(pmd_t pmd)
 #endif /* CONFIG_MMU */
 
 #ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
+
+#ifndef __PAGETABLE_P4D_FOLDED
+int p4d_set_huge(p4d_t *p4d, phys_addr_t addr, pgprot_t prot);
+int p4d_clear_huge(p4d_t *p4d);
+#else
+static inline int p4d_set_huge(p4d_t *p4d, phys_addr_t addr, pgprot_t prot)
+{
+	return 0;
+}
+static inline int p4d_clear_huge(p4d_t *p4d)
+{
+	return 0;
+}
+#endif /* !__PAGETABLE_P4D_FOLDED */
+
 int pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot);
 int pmd_set_huge(pmd_t *pmd, phys_addr_t addr, pgprot_t prot);
 int pud_clear_huge(pud_t *pud);
 int pmd_clear_huge(pmd_t *pmd);
 #else	/* !CONFIG_HAVE_ARCH_HUGE_VMAP */
+static inline int p4d_set_huge(p4d_t *p4d, phys_addr_t addr, pgprot_t prot)
+{
+	return 0;
+}
 static inline int pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot)
 {
 	return 0;
@@ -763,6 +801,10 @@ static inline int pmd_set_huge(pmd_t *pmd, phys_addr_t addr, pgprot_t prot)
 {
 	return 0;
 }
+static inline int p4d_clear_huge(p4d_t *p4d)
+{
+	return 0;
+}
 static inline int pud_clear_huge(pud_t *pud)
 {
 	return 0;
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 48c76d612d40..1b45ac594b54 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -116,7 +116,7 @@ struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 struct page *follow_huge_pud(struct mm_struct *mm, unsigned long address,
 				pud_t *pud, int flags);
 int pmd_huge(pmd_t pmd);
-int pud_huge(pud_t pmd);
+int pud_huge(pud_t pud);
 unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 		unsigned long address, unsigned long end, pgprot_t newprot);
 
@@ -189,6 +189,9 @@ static inline void __unmap_hugepage_range(struct mmu_gather *tlb,
 #ifndef pgd_huge
 #define pgd_huge(x)	0
 #endif
+#ifndef p4d_huge
+#define p4d_huge(x)	0
+#endif
 
 #ifndef pgd_write
 static inline int pgd_write(pgd_t pgd)
diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index 820c0ad54a01..8e52fe609220 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -19,6 +19,7 @@ extern unsigned char kasan_zero_page[PAGE_SIZE];
 extern pte_t kasan_zero_pte[PTRS_PER_PTE];
 extern pmd_t kasan_zero_pmd[PTRS_PER_PMD];
 extern pud_t kasan_zero_pud[PTRS_PER_PUD];
+extern p4d_t kasan_zero_p4d[PTRS_PER_P4D];
 
 void kasan_populate_zero_shadow(const void *shadow_start,
 				const void *shadow_end);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 58fab8917bbe..9c0ef57e5f56 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1515,14 +1515,24 @@ static inline pte_t *get_locked_pte(struct mm_struct *mm, unsigned long addr,
 	return ptep;
 }
 
+#ifdef __PAGETABLE_P4D_FOLDED
+static inline int __p4d_alloc(struct mm_struct *mm, pgd_t *pgd,
+						unsigned long address)
+{
+	return 0;
+}
+#else
+int __p4d_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address);
+#endif
+
 #ifdef __PAGETABLE_PUD_FOLDED
-static inline int __pud_alloc(struct mm_struct *mm, pgd_t *pgd,
+static inline int __pud_alloc(struct mm_struct *mm, p4d_t *p4d,
 						unsigned long address)
 {
 	return 0;
 }
 #else
-int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address);
+int __pud_alloc(struct mm_struct *mm, p4d_t *p4d, unsigned long address);
 #endif
 
 #if defined(__PAGETABLE_PMD_FOLDED) || !defined(CONFIG_MMU)
@@ -1576,10 +1586,18 @@ int __pte_alloc_kernel(pmd_t *pmd, unsigned long address);
 #if defined(CONFIG_MMU) && !defined(__ARCH_HAS_4LEVEL_HACK)
 
 #ifndef __ARCH_HAS_5LEVEL_HACK
-static inline pud_t *pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
+static inline p4d_t *p4d_alloc(struct mm_struct *mm, pgd_t *pgd,
+		unsigned long address)
+{
+	return (unlikely(pgd_none(*pgd)) && __p4d_alloc(mm, pgd, address)) ?
+		NULL : p4d_offset(pgd, address);
+}
+
+static inline pud_t *pud_alloc(struct mm_struct *mm, p4d_t *p4d,
+		unsigned long address)
 {
-	return (unlikely(pgd_none(*pgd)) && __pud_alloc(mm, pgd, address))?
-		NULL: pud_offset(pgd, address);
+	return (unlikely(p4d_none(*p4d)) && __pud_alloc(mm, p4d, address)) ?
+		NULL : pud_offset(p4d, address);
 }
 #endif /* !__ARCH_HAS_5LEVEL_HACK */
 
@@ -2318,7 +2336,8 @@ void sparse_mem_maps_populate_node(struct page **map_map,
 
 struct page *sparse_mem_map_populate(unsigned long pnum, int nid);
 pgd_t *vmemmap_pgd_populate(unsigned long addr, int node);
-pud_t *vmemmap_pud_populate(pgd_t *pgd, unsigned long addr, int node);
+p4d_t *vmemmap_p4d_populate(pgd_t *pgd, unsigned long addr, int node);
+pud_t *vmemmap_pud_populate(p4d_t *p4d, unsigned long addr, int node);
 pmd_t *vmemmap_pmd_populate(pud_t *pud, unsigned long addr, int node);
 pte_t *vmemmap_pte_populate(pmd_t *pmd, unsigned long addr, int node);
 void *vmemmap_alloc_block(unsigned long size, int node);
diff --git a/lib/ioremap.c b/lib/ioremap.c
index 86c8911b0e3a..5629eeaba5ae 100644
--- a/lib/ioremap.c
+++ b/lib/ioremap.c
@@ -14,6 +14,7 @@
 #include <asm/pgtable.h>
 
 #ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
+static int __read_mostly ioremap_p4d_capable;
 static int __read_mostly ioremap_pud_capable;
 static int __read_mostly ioremap_pmd_capable;
 static int __read_mostly ioremap_huge_disabled;
@@ -35,6 +36,11 @@ void __init ioremap_huge_init(void)
 	}
 }
 
+static inline int ioremap_p4d_enabled(void)
+{
+	return ioremap_p4d_capable;
+}
+
 static inline int ioremap_pud_enabled(void)
 {
 	return ioremap_pud_capable;
@@ -46,6 +52,7 @@ static inline int ioremap_pmd_enabled(void)
 }
 
 #else	/* !CONFIG_HAVE_ARCH_HUGE_VMAP */
+static inline int ioremap_p4d_enabled(void) { return 0; }
 static inline int ioremap_pud_enabled(void) { return 0; }
 static inline int ioremap_pmd_enabled(void) { return 0; }
 #endif	/* CONFIG_HAVE_ARCH_HUGE_VMAP */
@@ -94,14 +101,14 @@ static inline int ioremap_pmd_range(pud_t *pud, unsigned long addr,
 	return 0;
 }
 
-static inline int ioremap_pud_range(pgd_t *pgd, unsigned long addr,
+static inline int ioremap_pud_range(p4d_t *p4d, unsigned long addr,
 		unsigned long end, phys_addr_t phys_addr, pgprot_t prot)
 {
 	pud_t *pud;
 	unsigned long next;
 
 	phys_addr -= addr;
-	pud = pud_alloc(&init_mm, pgd, addr);
+	pud = pud_alloc(&init_mm, p4d, addr);
 	if (!pud)
 		return -ENOMEM;
 	do {
@@ -120,6 +127,32 @@ static inline int ioremap_pud_range(pgd_t *pgd, unsigned long addr,
 	return 0;
 }
 
+static inline int ioremap_p4d_range(pgd_t *pgd, unsigned long addr,
+		unsigned long end, phys_addr_t phys_addr, pgprot_t prot)
+{
+	p4d_t *p4d;
+	unsigned long next;
+
+	phys_addr -= addr;
+	p4d = p4d_alloc(&init_mm, pgd, addr);
+	if (!p4d)
+		return -ENOMEM;
+	do {
+		next = p4d_addr_end(addr, end);
+
+		if (ioremap_p4d_enabled() &&
+		    ((next - addr) == P4D_SIZE) &&
+		    IS_ALIGNED(phys_addr + addr, P4D_SIZE)) {
+			if (p4d_set_huge(p4d, phys_addr + addr, prot))
+				continue;
+		}
+
+		if (ioremap_pud_range(p4d, addr, next, phys_addr + addr, prot))
+			return -ENOMEM;
+	} while (p4d++, addr = next, addr != end);
+	return 0;
+}
+
 int ioremap_page_range(unsigned long addr,
 		       unsigned long end, phys_addr_t phys_addr, pgprot_t prot)
 {
@@ -135,7 +168,7 @@ int ioremap_page_range(unsigned long addr,
 	pgd = pgd_offset_k(addr);
 	do {
 		next = pgd_addr_end(addr, end);
-		err = ioremap_pud_range(pgd, addr, next, phys_addr+addr, prot);
+		err = ioremap_p4d_range(pgd, addr, next, phys_addr+addr, prot);
 		if (err)
 			break;
 	} while (pgd++, addr = next, addr != end);
diff --git a/mm/gup.c b/mm/gup.c
index 55315555489d..4660b7ee2088 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -226,6 +226,7 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 			      unsigned int *page_mask)
 {
 	pgd_t *pgd;
+	p4d_t *p4d;
 	pud_t *pud;
 	pmd_t *pmd;
 	spinlock_t *ptl;
@@ -243,8 +244,13 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 	pgd = pgd_offset(mm, address);
 	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
 		return no_page_table(vma, flags);
-
-	pud = pud_offset(pgd, address);
+	p4d = p4d_offset(pgd, address);
+	if (p4d_none(*p4d))
+		return no_page_table(vma, flags);
+	BUILD_BUG_ON(p4d_huge(*p4d));
+	if (unlikely(p4d_bad(*p4d)))
+		return no_page_table(vma, flags);
+	pud = pud_offset(p4d, address);
 	if (pud_none(*pud))
 		return no_page_table(vma, flags);
 	if (pud_huge(*pud) && vma->vm_flags & VM_HUGETLB) {
@@ -317,6 +323,7 @@ static int get_gate_page(struct mm_struct *mm, unsigned long address,
 		struct page **page)
 {
 	pgd_t *pgd;
+	p4d_t *p4d;
 	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
@@ -330,7 +337,9 @@ static int get_gate_page(struct mm_struct *mm, unsigned long address,
 	else
 		pgd = pgd_offset_gate(mm, address);
 	BUG_ON(pgd_none(*pgd));
-	pud = pud_offset(pgd, address);
+	p4d = p4d_offset(pgd, address);
+	BUG_ON(p4d_none(*p4d));
+	pud = pud_offset(p4d, address);
 	BUG_ON(pud_none(*pud));
 	pmd = pmd_offset(pud, address);
 	if (pmd_none(*pmd))
@@ -1392,13 +1401,13 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 	return 1;
 }
 
-static int gup_pud_range(pgd_t pgd, unsigned long addr, unsigned long end,
+static int gup_pud_range(p4d_t p4d, unsigned long addr, unsigned long end,
 			 int write, struct page **pages, int *nr)
 {
 	unsigned long next;
 	pud_t *pudp;
 
-	pudp = pud_offset(&pgd, addr);
+	pudp = pud_offset(&p4d, addr);
 	do {
 		pud_t pud = READ_ONCE(*pudp);
 
@@ -1420,6 +1429,31 @@ static int gup_pud_range(pgd_t pgd, unsigned long addr, unsigned long end,
 	return 1;
 }
 
+static int gup_p4d_range(pgd_t pgd, unsigned long addr, unsigned long end,
+			 int write, struct page **pages, int *nr)
+{
+	unsigned long next;
+	p4d_t *p4dp;
+
+	p4dp = p4d_offset(&pgd, addr);
+	do {
+		p4d_t p4d = READ_ONCE(*p4dp);
+
+		next = p4d_addr_end(addr, end);
+		if (p4d_none(p4d))
+			return 0;
+		BUILD_BUG_ON(p4d_huge(p4d));
+		if (unlikely(is_hugepd(__hugepd(p4d_val(p4d))))) {
+			if (!gup_huge_pd(__hugepd(p4d_val(p4d)), addr,
+					 P4D_SHIFT, next, write, pages, nr))
+				return 0;
+		} else if (!gup_p4d_range(p4d, addr, next, write, pages, nr))
+			return 0;
+	} while (p4dp++, addr = next, addr != end);
+
+	return 1;
+}
+
 /*
  * Like get_user_pages_fast() except it's IRQ-safe in that it won't fall back to
  * the regular GUP. It will only return non-negative values.
@@ -1470,7 +1504,7 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			if (!gup_huge_pd(__hugepd(pgd_val(pgd)), addr,
 					 PGDIR_SHIFT, next, write, pages, &nr))
 				break;
-		} else if (!gup_pud_range(pgd, addr, next, write, pages, &nr))
+		} else if (!gup_p4d_range(pgd, addr, next, write, pages, &nr))
 			break;
 	} while (pgdp++, addr = next, addr != end);
 	local_irq_restore(flags);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 10eedbf14421..37778ab8de40 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1778,6 +1778,7 @@ void split_huge_pmd_address(struct vm_area_struct *vma, unsigned long address,
 		bool freeze, struct page *page)
 {
 	pgd_t *pgd;
+	p4d_t *p4d;
 	pud_t *pud;
 	pmd_t *pmd;
 
@@ -1785,7 +1786,11 @@ void split_huge_pmd_address(struct vm_area_struct *vma, unsigned long address,
 	if (!pgd_present(*pgd))
 		return;
 
-	pud = pud_offset(pgd, address);
+	p4d = p4d_offset(pgd, address);
+	if (!p4d_present(*p4d))
+		return;
+
+	pud = pud_offset(p4d, address);
 	if (!pud_present(*pud))
 		return;
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3edb759c5c7d..2359da2264e7 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4366,7 +4366,8 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
 {
 	pgd_t *pgd = pgd_offset(mm, *addr);
-	pud_t *pud = pud_offset(pgd, *addr);
+	p4d_t *p4d = p4d_offset(pgd, *addr);
+	pud_t *pud = pud_offset(p4d, *addr);
 
 	BUG_ON(page_count(virt_to_page(ptep)) == 0);
 	if (page_count(virt_to_page(ptep)) == 1)
@@ -4397,11 +4398,13 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
 			unsigned long addr, unsigned long sz)
 {
 	pgd_t *pgd;
+	p4d_t *p4d;
 	pud_t *pud;
 	pte_t *pte = NULL;
 
 	pgd = pgd_offset(mm, addr);
-	pud = pud_alloc(mm, pgd, addr);
+	p4d = p4d_offset(pgd, addr);
+	pud = pud_alloc(mm, p4d, addr);
 	if (pud) {
 		if (sz == PUD_SIZE) {
 			pte = (pte_t *)pud;
@@ -4421,18 +4424,22 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
 pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
 {
 	pgd_t *pgd;
+	p4d_t *p4d;
 	pud_t *pud;
-	pmd_t *pmd = NULL;
+	pmd_t *pmd;
 
 	pgd = pgd_offset(mm, addr);
-	if (pgd_present(*pgd)) {
-		pud = pud_offset(pgd, addr);
-		if (pud_present(*pud)) {
-			if (pud_huge(*pud))
-				return (pte_t *)pud;
-			pmd = pmd_offset(pud, addr);
-		}
-	}
+	if (!pgd_present(*pgd))
+		return NULL;
+	p4d = p4d_offset(pgd, addr);
+	if (!p4d_present(*p4d))
+		return NULL;
+	pud = pud_offset(p4d, addr);
+	if (!pud_present(*pud))
+		return NULL;
+	if (pud_huge(*pud))
+		return (pte_t *)pud;
+	pmd = pmd_offset(pud, addr);
 	return (pte_t *) pmd;
 }
 
diff --git a/mm/kasan/kasan_init.c b/mm/kasan/kasan_init.c
index 3f9a41cf0ac6..0d4ee78796fc 100644
--- a/mm/kasan/kasan_init.c
+++ b/mm/kasan/kasan_init.c
@@ -29,6 +29,9 @@
  */
 unsigned char kasan_zero_page[PAGE_SIZE] __page_aligned_bss;
 
+#if CONFIG_PGTABLE_LEVELS > 4
+p4d_t kasan_zero_p4d[PTRS_PER_P4D] __page_aligned_bss;
+#endif
 #if CONFIG_PGTABLE_LEVELS > 3
 pud_t kasan_zero_pud[PTRS_PER_PUD] __page_aligned_bss;
 #endif
@@ -81,10 +84,10 @@ static void __init zero_pmd_populate(pud_t *pud, unsigned long addr,
 	} while (pmd++, addr = next, addr != end);
 }
 
-static void __init zero_pud_populate(pgd_t *pgd, unsigned long addr,
+static void __init zero_pud_populate(p4d_t *p4d, unsigned long addr,
 				unsigned long end)
 {
-	pud_t *pud = pud_offset(pgd, addr);
+	pud_t *pud = pud_offset(p4d, addr);
 	unsigned long next;
 
 	do {
@@ -106,6 +109,23 @@ static void __init zero_pud_populate(pgd_t *pgd, unsigned long addr,
 	} while (pud++, addr = next, addr != end);
 }
 
+static void __init zero_p4d_populate(pgd_t *pgd, unsigned long addr,
+				unsigned long end)
+{
+	p4d_t *p4d = p4d_offset(pgd, addr);
+	unsigned long next;
+
+	do {
+		next = p4d_addr_end(addr, end);
+
+		if (p4d_none(*p4d)) {
+			p4d_populate(&init_mm, p4d,
+				early_alloc(PAGE_SIZE, NUMA_NO_NODE));
+		}
+		zero_pud_populate(p4d, addr, next);
+	} while (p4d++, addr = next, addr != end);
+}
+
 /**
  * kasan_populate_zero_shadow - populate shadow memory region with
  *                               kasan_zero_page
@@ -124,6 +144,7 @@ void __init kasan_populate_zero_shadow(const void *shadow_start,
 		next = pgd_addr_end(addr, end);
 
 		if (IS_ALIGNED(addr, PGDIR_SIZE) && end - addr >= PGDIR_SIZE) {
+			p4d_t *p4d;
 			pud_t *pud;
 			pmd_t *pmd;
 
@@ -135,8 +156,12 @@ void __init kasan_populate_zero_shadow(const void *shadow_start,
 			 * puds,pmds, so pgd_populate(), pud_populate()
 			 * is noops.
 			 */
-			pgd_populate(&init_mm, pgd, kasan_zero_pud);
-			pud = pud_offset(pgd, addr);
+#ifndef __ARCH_HAS_5LEVEL_HACK
+			pgd_populate(&init_mm, pgd, kasan_zero_p4d);
+#endif
+			p4d = p4d_offset(pgd, addr);
+			p4d_populate(&init_mm, p4d, kasan_zero_pud);
+			pud = pud_offset(p4d, addr);
 			pud_populate(&init_mm, pud, kasan_zero_pmd);
 			pmd = pmd_offset(pud, addr);
 			pmd_populate_kernel(&init_mm, pmd, kasan_zero_pte);
@@ -147,6 +172,6 @@ void __init kasan_populate_zero_shadow(const void *shadow_start,
 			pgd_populate(&init_mm, pgd,
 				early_alloc(PAGE_SIZE, NUMA_NO_NODE));
 		}
-		zero_pud_populate(pgd, addr, next);
+		zero_p4d_populate(pgd, addr, next);
 	} while (pgd++, addr = next, addr != end);
 }
diff --git a/mm/memory.c b/mm/memory.c
index 7d23b5050248..267cee723aa1 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -442,7 +442,7 @@ static inline void free_pmd_range(struct mmu_gather *tlb, pud_t *pud,
 	mm_dec_nr_pmds(tlb->mm);
 }
 
-static inline void free_pud_range(struct mmu_gather *tlb, pgd_t *pgd,
+static inline void free_pud_range(struct mmu_gather *tlb, p4d_t *p4d,
 				unsigned long addr, unsigned long end,
 				unsigned long floor, unsigned long ceiling)
 {
@@ -451,7 +451,7 @@ static inline void free_pud_range(struct mmu_gather *tlb, pgd_t *pgd,
 	unsigned long start;
 
 	start = addr;
-	pud = pud_offset(pgd, addr);
+	pud = pud_offset(p4d, addr);
 	do {
 		next = pud_addr_end(addr, end);
 		if (pud_none_or_clear_bad(pud))
@@ -459,6 +459,39 @@ static inline void free_pud_range(struct mmu_gather *tlb, pgd_t *pgd,
 		free_pmd_range(tlb, pud, addr, next, floor, ceiling);
 	} while (pud++, addr = next, addr != end);
 
+	start &= P4D_MASK;
+	if (start < floor)
+		return;
+	if (ceiling) {
+		ceiling &= P4D_MASK;
+		if (!ceiling)
+			return;
+	}
+	if (end - 1 > ceiling - 1)
+		return;
+
+	pud = pud_offset(p4d, start);
+	p4d_clear(p4d);
+	pud_free_tlb(tlb, pud, start);
+}
+
+static inline void free_p4d_range(struct mmu_gather *tlb, pgd_t *pgd,
+				unsigned long addr, unsigned long end,
+				unsigned long floor, unsigned long ceiling)
+{
+	p4d_t *p4d;
+	unsigned long next;
+	unsigned long start;
+
+	start = addr;
+	p4d = p4d_offset(pgd, addr);
+	do {
+		next = p4d_addr_end(addr, end);
+		if (p4d_none_or_clear_bad(p4d))
+			continue;
+		free_pud_range(tlb, p4d, addr, next, floor, ceiling);
+	} while (p4d++, addr = next, addr != end);
+
 	start &= PGDIR_MASK;
 	if (start < floor)
 		return;
@@ -470,9 +503,9 @@ static inline void free_pud_range(struct mmu_gather *tlb, pgd_t *pgd,
 	if (end - 1 > ceiling - 1)
 		return;
 
-	pud = pud_offset(pgd, start);
+	p4d = p4d_offset(pgd, start);
 	pgd_clear(pgd);
-	pud_free_tlb(tlb, pud, start);
+	p4d_free_tlb(tlb, p4d, start);
 }
 
 /*
@@ -536,7 +569,7 @@ void free_pgd_range(struct mmu_gather *tlb,
 		next = pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(pgd))
 			continue;
-		free_pud_range(tlb, pgd, addr, next, floor, ceiling);
+		free_p4d_range(tlb, pgd, addr, next, floor, ceiling);
 	} while (pgd++, addr = next, addr != end);
 }
 
@@ -655,7 +688,8 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
 			  pte_t pte, struct page *page)
 {
 	pgd_t *pgd = pgd_offset(vma->vm_mm, addr);
-	pud_t *pud = pud_offset(pgd, addr);
+	p4d_t *p4d = p4d_offset(pgd, addr);
+	pud_t *pud = pud_offset(p4d, addr);
 	pmd_t *pmd = pmd_offset(pud, addr);
 	struct address_space *mapping;
 	pgoff_t index;
@@ -1020,16 +1054,16 @@ static inline int copy_pmd_range(struct mm_struct *dst_mm, struct mm_struct *src
 }
 
 static inline int copy_pud_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
-		pgd_t *dst_pgd, pgd_t *src_pgd, struct vm_area_struct *vma,
+		p4d_t *dst_p4d, p4d_t *src_p4d, struct vm_area_struct *vma,
 		unsigned long addr, unsigned long end)
 {
 	pud_t *src_pud, *dst_pud;
 	unsigned long next;
 
-	dst_pud = pud_alloc(dst_mm, dst_pgd, addr);
+	dst_pud = pud_alloc(dst_mm, dst_p4d, addr);
 	if (!dst_pud)
 		return -ENOMEM;
-	src_pud = pud_offset(src_pgd, addr);
+	src_pud = pud_offset(src_p4d, addr);
 	do {
 		next = pud_addr_end(addr, end);
 		if (pud_none_or_clear_bad(src_pud))
@@ -1041,6 +1075,28 @@ static inline int copy_pud_range(struct mm_struct *dst_mm, struct mm_struct *src
 	return 0;
 }
 
+static inline int copy_p4d_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
+		pgd_t *dst_pgd, pgd_t *src_pgd, struct vm_area_struct *vma,
+		unsigned long addr, unsigned long end)
+{
+	p4d_t *src_p4d, *dst_p4d;
+	unsigned long next;
+
+	dst_p4d = p4d_alloc(dst_mm, dst_pgd, addr);
+	if (!dst_p4d)
+		return -ENOMEM;
+	src_p4d = p4d_offset(src_pgd, addr);
+	do {
+		next = p4d_addr_end(addr, end);
+		if (p4d_none_or_clear_bad(src_p4d))
+			continue;
+		if (copy_pud_range(dst_mm, src_mm, dst_p4d, src_p4d,
+						vma, addr, next))
+			return -ENOMEM;
+	} while (dst_p4d++, src_p4d++, addr = next, addr != end);
+	return 0;
+}
+
 int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		struct vm_area_struct *vma)
 {
@@ -1096,7 +1152,7 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		next = pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(src_pgd))
 			continue;
-		if (unlikely(copy_pud_range(dst_mm, src_mm, dst_pgd, src_pgd,
+		if (unlikely(copy_p4d_range(dst_mm, src_mm, dst_pgd, src_pgd,
 					    vma, addr, next))) {
 			ret = -ENOMEM;
 			break;
@@ -1259,14 +1315,14 @@ static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
 }
 
 static inline unsigned long zap_pud_range(struct mmu_gather *tlb,
-				struct vm_area_struct *vma, pgd_t *pgd,
+				struct vm_area_struct *vma, p4d_t *p4d,
 				unsigned long addr, unsigned long end,
 				struct zap_details *details)
 {
 	pud_t *pud;
 	unsigned long next;
 
-	pud = pud_offset(pgd, addr);
+	pud = pud_offset(p4d, addr);
 	do {
 		next = pud_addr_end(addr, end);
 		if (pud_none_or_clear_bad(pud))
@@ -1277,6 +1333,25 @@ static inline unsigned long zap_pud_range(struct mmu_gather *tlb,
 	return addr;
 }
 
+static inline unsigned long zap_p4d_range(struct mmu_gather *tlb,
+				struct vm_area_struct *vma, pgd_t *pgd,
+				unsigned long addr, unsigned long end,
+				struct zap_details *details)
+{
+	p4d_t *p4d;
+	unsigned long next;
+
+	p4d = p4d_offset(pgd, addr);
+	do {
+		next = p4d_addr_end(addr, end);
+		if (p4d_none_or_clear_bad(p4d))
+			continue;
+		next = zap_pud_range(tlb, vma, p4d, addr, next, details);
+	} while (p4d++, addr = next, addr != end);
+
+	return addr;
+}
+
 void unmap_page_range(struct mmu_gather *tlb,
 			     struct vm_area_struct *vma,
 			     unsigned long addr, unsigned long end,
@@ -1292,7 +1367,7 @@ void unmap_page_range(struct mmu_gather *tlb,
 		next = pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(pgd))
 			continue;
-		next = zap_pud_range(tlb, vma, pgd, addr, next, details);
+		next = zap_p4d_range(tlb, vma, pgd, addr, next, details);
 	} while (pgd++, addr = next, addr != end);
 	tlb_end_vma(tlb, vma);
 }
@@ -1448,16 +1523,24 @@ EXPORT_SYMBOL_GPL(zap_vma_ptes);
 pte_t *__get_locked_pte(struct mm_struct *mm, unsigned long addr,
 			spinlock_t **ptl)
 {
-	pgd_t * pgd = pgd_offset(mm, addr);
-	pud_t * pud = pud_alloc(mm, pgd, addr);
-	if (pud) {
-		pmd_t * pmd = pmd_alloc(mm, pud, addr);
-		if (pmd) {
-			VM_BUG_ON(pmd_trans_huge(*pmd));
-			return pte_alloc_map_lock(mm, pmd, addr, ptl);
-		}
-	}
-	return NULL;
+	pgd_t *pgd;
+	p4d_t *p4d;
+	pud_t *pud;
+	pmd_t *pmd;
+
+	pgd = pgd_offset(mm, addr);
+	p4d = p4d_alloc(mm, pgd, addr);
+	if (!p4d)
+		return NULL;
+	pud = pud_alloc(mm, p4d, addr);
+	if (!pud)
+		return NULL;
+	pmd = pmd_alloc(mm, pud, addr);
+	if (!pmd)
+		return NULL;
+
+	VM_BUG_ON(pmd_trans_huge(*pmd));
+	return pte_alloc_map_lock(mm, pmd, addr, ptl);
 }
 
 /*
@@ -1723,7 +1806,7 @@ static inline int remap_pmd_range(struct mm_struct *mm, pud_t *pud,
 	return 0;
 }
 
-static inline int remap_pud_range(struct mm_struct *mm, pgd_t *pgd,
+static inline int remap_pud_range(struct mm_struct *mm, p4d_t *p4d,
 			unsigned long addr, unsigned long end,
 			unsigned long pfn, pgprot_t prot)
 {
@@ -1731,7 +1814,7 @@ static inline int remap_pud_range(struct mm_struct *mm, pgd_t *pgd,
 	unsigned long next;
 
 	pfn -= addr >> PAGE_SHIFT;
-	pud = pud_alloc(mm, pgd, addr);
+	pud = pud_alloc(mm, p4d, addr);
 	if (!pud)
 		return -ENOMEM;
 	do {
@@ -1743,6 +1826,26 @@ static inline int remap_pud_range(struct mm_struct *mm, pgd_t *pgd,
 	return 0;
 }
 
+static inline int remap_p4d_range(struct mm_struct *mm, pgd_t *pgd,
+			unsigned long addr, unsigned long end,
+			unsigned long pfn, pgprot_t prot)
+{
+	p4d_t *p4d;
+	unsigned long next;
+
+	pfn -= addr >> PAGE_SHIFT;
+	p4d = p4d_alloc(mm, pgd, addr);
+	if (!p4d)
+		return -ENOMEM;
+	do {
+		next = p4d_addr_end(addr, end);
+		if (remap_pud_range(mm, p4d, addr, next,
+				pfn + (addr >> PAGE_SHIFT), prot))
+			return -ENOMEM;
+	} while (p4d++, addr = next, addr != end);
+	return 0;
+}
+
 /**
  * remap_pfn_range - remap kernel memory to userspace
  * @vma: user vma to map to
@@ -1799,7 +1902,7 @@ int remap_pfn_range(struct vm_area_struct *vma, unsigned long addr,
 	flush_cache_range(vma, addr, end);
 	do {
 		next = pgd_addr_end(addr, end);
-		err = remap_pud_range(mm, pgd, addr, next,
+		err = remap_p4d_range(mm, pgd, addr, next,
 				pfn + (addr >> PAGE_SHIFT), prot);
 		if (err)
 			break;
@@ -1915,7 +2018,7 @@ static int apply_to_pmd_range(struct mm_struct *mm, pud_t *pud,
 	return err;
 }
 
-static int apply_to_pud_range(struct mm_struct *mm, pgd_t *pgd,
+static int apply_to_pud_range(struct mm_struct *mm, p4d_t *p4d,
 				     unsigned long addr, unsigned long end,
 				     pte_fn_t fn, void *data)
 {
@@ -1923,7 +2026,7 @@ static int apply_to_pud_range(struct mm_struct *mm, pgd_t *pgd,
 	unsigned long next;
 	int err;
 
-	pud = pud_alloc(mm, pgd, addr);
+	pud = pud_alloc(mm, p4d, addr);
 	if (!pud)
 		return -ENOMEM;
 	do {
@@ -1935,6 +2038,26 @@ static int apply_to_pud_range(struct mm_struct *mm, pgd_t *pgd,
 	return err;
 }
 
+static int apply_to_p4d_range(struct mm_struct *mm, pgd_t *pgd,
+				     unsigned long addr, unsigned long end,
+				     pte_fn_t fn, void *data)
+{
+	p4d_t *p4d;
+	unsigned long next;
+	int err;
+
+	p4d = p4d_alloc(mm, pgd, addr);
+	if (!p4d)
+		return -ENOMEM;
+	do {
+		next = p4d_addr_end(addr, end);
+		err = apply_to_pud_range(mm, p4d, addr, next, fn, data);
+		if (err)
+			break;
+	} while (p4d++, addr = next, addr != end);
+	return err;
+}
+
 /*
  * Scan a region of virtual memory, filling in page tables as necessary
  * and calling a provided function on each leaf page table.
@@ -1953,7 +2076,7 @@ int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
 	pgd = pgd_offset(mm, addr);
 	do {
 		next = pgd_addr_end(addr, end);
-		err = apply_to_pud_range(mm, pgd, addr, next, fn, data);
+		err = apply_to_p4d_range(mm, pgd, addr, next, fn, data);
 		if (err)
 			break;
 	} while (pgd++, addr = next, addr != end);
@@ -3622,10 +3745,14 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 	};
 	struct mm_struct *mm = vma->vm_mm;
 	pgd_t *pgd;
+	p4d_t *p4d;
 	pud_t *pud;
 
 	pgd = pgd_offset(mm, address);
-	pud = pud_alloc(mm, pgd, address);
+	p4d = p4d_alloc(mm, pgd, address);
+	if (!p4d)
+		return VM_FAULT_OOM;
+	pud = pud_alloc(mm, p4d, address);
 	if (!pud)
 		return VM_FAULT_OOM;
 	vmf.pmd = pmd_alloc(mm, pud, address);
@@ -3729,7 +3856,7 @@ EXPORT_SYMBOL_GPL(handle_mm_fault);
  * Allocate page upper directory.
  * We've already handled the fast-path in-line.
  */
-int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
+int __pud_alloc(struct mm_struct *mm, p4d_t *p4d, unsigned long address)
 {
 	pud_t *new = pud_alloc_one(mm, address);
 	if (!new)
@@ -3738,10 +3865,17 @@ int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
 	smp_wmb(); /* See comment in __pte_alloc */
 
 	spin_lock(&mm->page_table_lock);
-	if (pgd_present(*pgd))		/* Another has populated it */
+#ifndef __ARCH_HAS_5LEVEL_HACK
+	if (p4d_present(*p4d))		/* Another has populated it */
+		pud_free(mm, new);
+	else
+		p4d_populate(mm, p4d, new);
+#else
+	if (pgd_present(*p4d))		/* Another has populated it */
 		pud_free(mm, new);
 	else
-		pgd_populate(mm, pgd, new);
+		pgd_populate(mm, p4d, new);
+#endif /* __ARCH_HAS_5LEVEL_HACK */
 	spin_unlock(&mm->page_table_lock);
 	return 0;
 }
@@ -3783,6 +3917,7 @@ static int __follow_pte(struct mm_struct *mm, unsigned long address,
 		pte_t **ptepp, spinlock_t **ptlp)
 {
 	pgd_t *pgd;
+	p4d_t *p4d;
 	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *ptep;
@@ -3791,7 +3926,11 @@ static int __follow_pte(struct mm_struct *mm, unsigned long address,
 	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
 		goto out;
 
-	pud = pud_offset(pgd, address);
+	p4d = p4d_offset(pgd, address);
+	if (p4d_none(*p4d) || unlikely(p4d_bad(*p4d)))
+		goto out;
+
+	pud = pud_offset(p4d, address);
 	if (pud_none(*pud) || unlikely(pud_bad(*pud)))
 		goto out;
 
diff --git a/mm/mlock.c b/mm/mlock.c
index cdbed8aaa426..81fe0c18e29d 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -379,6 +379,7 @@ static unsigned long __munlock_pagevec_fill(struct pagevec *pvec,
 	pte = get_locked_pte(vma->vm_mm, start,	&ptl);
 	/* Make sure we do not cross the page table boundary */
 	end = pgd_addr_end(start, end);
+	end = p4d_addr_end(start, end);
 	end = pud_addr_end(start, end);
 	end = pmd_addr_end(start, end);
 
diff --git a/mm/mprotect.c b/mm/mprotect.c
index f9c07f54dd62..af677fe954bc 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -209,14 +209,14 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 }
 
 static inline unsigned long change_pud_range(struct vm_area_struct *vma,
-		pgd_t *pgd, unsigned long addr, unsigned long end,
+		p4d_t *p4d, unsigned long addr, unsigned long end,
 		pgprot_t newprot, int dirty_accountable, int prot_numa)
 {
 	pud_t *pud;
 	unsigned long next;
 	unsigned long pages = 0;
 
-	pud = pud_offset(pgd, addr);
+	pud = pud_offset(p4d, addr);
 	do {
 		next = pud_addr_end(addr, end);
 		if (pud_none_or_clear_bad(pud))
@@ -228,6 +228,26 @@ static inline unsigned long change_pud_range(struct vm_area_struct *vma,
 	return pages;
 }
 
+static inline unsigned long change_p4d_range(struct vm_area_struct *vma,
+		pgd_t *pgd, unsigned long addr, unsigned long end,
+		pgprot_t newprot, int dirty_accountable, int prot_numa)
+{
+	p4d_t *p4d;
+	unsigned long next;
+	unsigned long pages = 0;
+
+	p4d = p4d_offset(pgd, addr);
+	do {
+		next = p4d_addr_end(addr, end);
+		if (p4d_none_or_clear_bad(p4d))
+			continue;
+		pages += change_pud_range(vma, p4d, addr, next, newprot,
+				 dirty_accountable, prot_numa);
+	} while (p4d++, addr = next, addr != end);
+
+	return pages;
+}
+
 static unsigned long change_protection_range(struct vm_area_struct *vma,
 		unsigned long addr, unsigned long end, pgprot_t newprot,
 		int dirty_accountable, int prot_numa)
@@ -246,7 +266,7 @@ static unsigned long change_protection_range(struct vm_area_struct *vma,
 		next = pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(pgd))
 			continue;
-		pages += change_pud_range(vma, pgd, addr, next, newprot,
+		pages += change_p4d_range(vma, pgd, addr, next, newprot,
 				 dirty_accountable, prot_numa);
 	} while (pgd++, addr = next, addr != end);
 
diff --git a/mm/mremap.c b/mm/mremap.c
index 30d7d2482eea..2b3bfcd51c75 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -31,6 +31,7 @@
 static pmd_t *get_old_pmd(struct mm_struct *mm, unsigned long addr)
 {
 	pgd_t *pgd;
+	p4d_t *p4d;
 	pud_t *pud;
 	pmd_t *pmd;
 
@@ -38,7 +39,11 @@ static pmd_t *get_old_pmd(struct mm_struct *mm, unsigned long addr)
 	if (pgd_none_or_clear_bad(pgd))
 		return NULL;
 
-	pud = pud_offset(pgd, addr);
+	p4d = p4d_offset(pgd, addr);
+	if (p4d_none_or_clear_bad(p4d))
+		return NULL;
+
+	pud = pud_offset(p4d, addr);
 	if (pud_none_or_clear_bad(pud))
 		return NULL;
 
@@ -53,11 +58,15 @@ static pmd_t *alloc_new_pmd(struct mm_struct *mm, struct vm_area_struct *vma,
 			    unsigned long addr)
 {
 	pgd_t *pgd;
+	p4d_t *p4d;
 	pud_t *pud;
 	pmd_t *pmd;
 
 	pgd = pgd_offset(mm, addr);
-	pud = pud_alloc(mm, pgd, addr);
+	p4d = p4d_alloc(mm, pgd, addr);
+	if (!p4d)
+		return NULL;
+	pud = pud_alloc(mm, p4d, addr);
 	if (!pud)
 		return NULL;
 
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index 207244489a68..0020f340abfd 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -69,14 +69,14 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
 	return err;
 }
 
-static int walk_pud_range(pgd_t *pgd, unsigned long addr, unsigned long end,
+static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
 			  struct mm_walk *walk)
 {
 	pud_t *pud;
 	unsigned long next;
 	int err = 0;
 
-	pud = pud_offset(pgd, addr);
+	pud = pud_offset(p4d, addr);
 	do {
 		next = pud_addr_end(addr, end);
 		if (pud_none_or_clear_bad(pud)) {
@@ -95,6 +95,32 @@ static int walk_pud_range(pgd_t *pgd, unsigned long addr, unsigned long end,
 	return err;
 }
 
+static int walk_p4d_range(pgd_t *pgd, unsigned long addr, unsigned long end,
+			  struct mm_walk *walk)
+{
+	p4d_t *p4d;
+	unsigned long next;
+	int err = 0;
+
+	p4d = p4d_offset(pgd, addr);
+	do {
+		next = p4d_addr_end(addr, end);
+		if (p4d_none_or_clear_bad(p4d)) {
+			if (walk->pte_hole)
+				err = walk->pte_hole(addr, next, walk);
+			if (err)
+				break;
+			continue;
+		}
+		if (walk->pmd_entry || walk->pte_entry)
+			err = walk_pud_range(p4d, addr, next, walk);
+		if (err)
+			break;
+	} while (p4d++, addr = next, addr != end);
+
+	return err;
+}
+
 static int walk_pgd_range(unsigned long addr, unsigned long end,
 			  struct mm_walk *walk)
 {
@@ -113,7 +139,7 @@ static int walk_pgd_range(unsigned long addr, unsigned long end,
 			continue;
 		}
 		if (walk->pmd_entry || walk->pte_entry)
-			err = walk_pud_range(pgd, addr, next, walk);
+			err = walk_p4d_range(pgd, addr, next, walk);
 		if (err)
 			break;
 	} while (pgd++, addr = next, addr != end);
diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index 71c5f9109f2a..738e278b48c1 100644
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -22,6 +22,12 @@ void pgd_clear_bad(pgd_t *pgd)
 	pgd_clear(pgd);
 }
 
+void p4d_clear_bad(p4d_t *p4d)
+{
+	p4d_ERROR(*p4d);
+	p4d_clear(p4d);
+}
+
 void pud_clear_bad(pud_t *pud)
 {
 	pud_ERROR(*pud);
diff --git a/mm/rmap.c b/mm/rmap.c
index 91619fd70939..257cb67892ee 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -684,6 +684,7 @@ unsigned long page_address_in_vma(struct page *page, struct vm_area_struct *vma)
 pmd_t *mm_find_pmd(struct mm_struct *mm, unsigned long address)
 {
 	pgd_t *pgd;
+	p4d_t *p4d;
 	pud_t *pud;
 	pmd_t *pmd = NULL;
 	pmd_t pmde;
@@ -692,7 +693,11 @@ pmd_t *mm_find_pmd(struct mm_struct *mm, unsigned long address)
 	if (!pgd_present(*pgd))
 		goto out;
 
-	pud = pud_offset(pgd, address);
+	p4d = p4d_offset(pgd, address);
+	if (!p4d_present(*p4d))
+		goto out;
+
+	pud = pud_offset(p4d, address);
 	if (!pud_present(*pud))
 		goto out;
 
@@ -797,6 +802,7 @@ bool page_check_address_transhuge(struct page *page, struct mm_struct *mm,
 				  pte_t **ptep, spinlock_t **ptlp)
 {
 	pgd_t *pgd;
+	p4d_t *p4d;
 	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
@@ -816,7 +822,10 @@ bool page_check_address_transhuge(struct page *page, struct mm_struct *mm,
 	pgd = pgd_offset(mm, address);
 	if (!pgd_present(*pgd))
 		return false;
-	pud = pud_offset(pgd, address);
+	p4d = p4d_offset(pgd, address);
+	if (!p4d_present(*p4d))
+		return false;
+	pud = pud_offset(p4d, address);
 	if (!pud_present(*pud))
 		return false;
 	pmd = pmd_offset(pud, address);
diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index 574c67b663fe..a56c3989f773 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -196,9 +196,9 @@ pmd_t * __meminit vmemmap_pmd_populate(pud_t *pud, unsigned long addr, int node)
 	return pmd;
 }
 
-pud_t * __meminit vmemmap_pud_populate(pgd_t *pgd, unsigned long addr, int node)
+pud_t * __meminit vmemmap_pud_populate(p4d_t *p4d, unsigned long addr, int node)
 {
-	pud_t *pud = pud_offset(pgd, addr);
+	pud_t *pud = pud_offset(p4d, addr);
 	if (pud_none(*pud)) {
 		void *p = vmemmap_alloc_block(PAGE_SIZE, node);
 		if (!p)
@@ -208,6 +208,18 @@ pud_t * __meminit vmemmap_pud_populate(pgd_t *pgd, unsigned long addr, int node)
 	return pud;
 }
 
+p4d_t * __meminit vmemmap_p4d_populate(pgd_t *pgd, unsigned long addr, int node)
+{
+	p4d_t *p4d = p4d_offset(pgd, addr);
+	if (p4d_none(*p4d)) {
+		void *p = vmemmap_alloc_block(PAGE_SIZE, node);
+		if (!p)
+			return NULL;
+		p4d_populate(&init_mm, p4d, p);
+	}
+	return p4d;
+}
+
 pgd_t * __meminit vmemmap_pgd_populate(unsigned long addr, int node)
 {
 	pgd_t *pgd = pgd_offset_k(addr);
@@ -225,6 +237,7 @@ int __meminit vmemmap_populate_basepages(unsigned long start,
 {
 	unsigned long addr = start;
 	pgd_t *pgd;
+	p4d_t *p4d;
 	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
@@ -233,7 +246,10 @@ int __meminit vmemmap_populate_basepages(unsigned long start,
 		pgd = vmemmap_pgd_populate(addr, node);
 		if (!pgd)
 			return -ENOMEM;
-		pud = vmemmap_pud_populate(pgd, addr, node);
+		p4d = vmemmap_p4d_populate(pgd, addr, node);
+		if (!p4d)
+			return -ENOMEM;
+		pud = vmemmap_pud_populate(p4d, addr, node);
 		if (!pud)
 			return -ENOMEM;
 		pmd = vmemmap_pmd_populate(pud, addr, node);
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 1c6e0321205d..0d3bd27dba69 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1245,7 +1245,7 @@ static inline int unuse_pmd_range(struct vm_area_struct *vma, pud_t *pud,
 	return 0;
 }
 
-static inline int unuse_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
+static inline int unuse_pud_range(struct vm_area_struct *vma, p4d_t *p4d,
 				unsigned long addr, unsigned long end,
 				swp_entry_t entry, struct page *page)
 {
@@ -1253,7 +1253,7 @@ static inline int unuse_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
 	unsigned long next;
 	int ret;
 
-	pud = pud_offset(pgd, addr);
+	pud = pud_offset(p4d, addr);
 	do {
 		next = pud_addr_end(addr, end);
 		if (pud_none_or_clear_bad(pud))
@@ -1265,6 +1265,26 @@ static inline int unuse_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
 	return 0;
 }
 
+static inline int unuse_p4d_range(struct vm_area_struct *vma, pgd_t *pgd,
+				unsigned long addr, unsigned long end,
+				swp_entry_t entry, struct page *page)
+{
+	p4d_t *p4d;
+	unsigned long next;
+	int ret;
+
+	p4d = p4d_offset(pgd, addr);
+	do {
+		next = p4d_addr_end(addr, end);
+		if (p4d_none_or_clear_bad(p4d))
+			continue;
+		ret = unuse_pud_range(vma, p4d, addr, next, entry, page);
+		if (ret)
+			return ret;
+	} while (p4d++, addr = next, addr != end);
+	return 0;
+}
+
 static int unuse_vma(struct vm_area_struct *vma,
 				swp_entry_t entry, struct page *page)
 {
@@ -1288,7 +1308,7 @@ static int unuse_vma(struct vm_area_struct *vma,
 		next = pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(pgd))
 			continue;
-		ret = unuse_pud_range(vma, pgd, addr, next, entry, page);
+		ret = unuse_p4d_range(vma, pgd, addr, next, entry, page);
 		if (ret)
 			return ret;
 	} while (pgd++, addr = next, addr != end);
diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index af817e5060fb..721681deba9f 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -124,19 +124,22 @@ static int mfill_zeropage_pte(struct mm_struct *dst_mm,
 static pmd_t *mm_alloc_pmd(struct mm_struct *mm, unsigned long address)
 {
 	pgd_t *pgd;
+	p4d_t *p4d;
 	pud_t *pud;
-	pmd_t *pmd = NULL;
 
 	pgd = pgd_offset(mm, address);
-	pud = pud_alloc(mm, pgd, address);
-	if (pud)
-		/*
-		 * Note that we didn't run this because the pmd was
-		 * missing, the *pmd may be already established and in
-		 * turn it may also be a trans_huge_pmd.
-		 */
-		pmd = pmd_alloc(mm, pud, address);
-	return pmd;
+	p4d = p4d_alloc(mm, pgd, address);
+	if (!p4d)
+		return NULL;
+	pud = pud_alloc(mm, p4d, address);
+	if (!pud)
+		return NULL;
+	/*
+	 * Note that we didn't run this because the pmd was
+	 * missing, the *pmd may be already established and in
+	 * turn it may also be a trans_huge_pmd.
+	 */
+	return pmd_alloc(mm, pud, address);
 }
 
 static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 3ca82d44edd3..35ff0d0e6400 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -86,12 +86,12 @@ static void vunmap_pmd_range(pud_t *pud, unsigned long addr, unsigned long end)
 	} while (pmd++, addr = next, addr != end);
 }
 
-static void vunmap_pud_range(pgd_t *pgd, unsigned long addr, unsigned long end)
+static void vunmap_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end)
 {
 	pud_t *pud;
 	unsigned long next;
 
-	pud = pud_offset(pgd, addr);
+	pud = pud_offset(p4d, addr);
 	do {
 		next = pud_addr_end(addr, end);
 		if (pud_clear_huge(pud))
@@ -102,6 +102,22 @@ static void vunmap_pud_range(pgd_t *pgd, unsigned long addr, unsigned long end)
 	} while (pud++, addr = next, addr != end);
 }
 
+static void vunmap_p4d_range(pgd_t *pgd, unsigned long addr, unsigned long end)
+{
+	p4d_t *p4d;
+	unsigned long next;
+
+	p4d = p4d_offset(pgd, addr);
+	do {
+		next = p4d_addr_end(addr, end);
+		if (p4d_clear_huge(p4d))
+			continue;
+		if (p4d_none_or_clear_bad(p4d))
+			continue;
+		vunmap_pud_range(p4d, addr, next);
+	} while (p4d++, addr = next, addr != end);
+}
+
 static void vunmap_page_range(unsigned long addr, unsigned long end)
 {
 	pgd_t *pgd;
@@ -113,7 +129,7 @@ static void vunmap_page_range(unsigned long addr, unsigned long end)
 		next = pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(pgd))
 			continue;
-		vunmap_pud_range(pgd, addr, next);
+		vunmap_p4d_range(pgd, addr, next);
 	} while (pgd++, addr = next, addr != end);
 }
 
@@ -160,13 +176,13 @@ static int vmap_pmd_range(pud_t *pud, unsigned long addr,
 	return 0;
 }
 
-static int vmap_pud_range(pgd_t *pgd, unsigned long addr,
+static int vmap_pud_range(p4d_t *p4d, unsigned long addr,
 		unsigned long end, pgprot_t prot, struct page **pages, int *nr)
 {
 	pud_t *pud;
 	unsigned long next;
 
-	pud = pud_alloc(&init_mm, pgd, addr);
+	pud = pud_alloc(&init_mm, p4d, addr);
 	if (!pud)
 		return -ENOMEM;
 	do {
@@ -177,6 +193,23 @@ static int vmap_pud_range(pgd_t *pgd, unsigned long addr,
 	return 0;
 }
 
+static int vmap_p4d_range(pgd_t *pgd, unsigned long addr,
+		unsigned long end, pgprot_t prot, struct page **pages, int *nr)
+{
+	p4d_t *p4d;
+	unsigned long next;
+
+	p4d = p4d_alloc(&init_mm, pgd, addr);
+	if (!p4d)
+		return -ENOMEM;
+	do {
+		next = p4d_addr_end(addr, end);
+		if (vmap_pud_range(p4d, addr, next, prot, pages, nr))
+			return -ENOMEM;
+	} while (p4d++, addr = next, addr != end);
+	return 0;
+}
+
 /*
  * Set up page tables in kva (addr, end). The ptes shall have prot "prot", and
  * will have pfns corresponding to the "pages" array.
@@ -196,7 +229,7 @@ static int vmap_page_range_noflush(unsigned long start, unsigned long end,
 	pgd = pgd_offset_k(addr);
 	do {
 		next = pgd_addr_end(addr, end);
-		err = vmap_pud_range(pgd, addr, next, prot, pages, &nr);
+		err = vmap_p4d_range(pgd, addr, next, prot, pages, &nr);
 		if (err)
 			return err;
 	} while (pgd++, addr = next, addr != end);
@@ -237,6 +270,10 @@ struct page *vmalloc_to_page(const void *vmalloc_addr)
 	unsigned long addr = (unsigned long) vmalloc_addr;
 	struct page *page = NULL;
 	pgd_t *pgd = pgd_offset_k(addr);
+	p4d_t *p4d;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *ptep, pte;
 
 	/*
 	 * XXX we might need to change this if we add VIRTUAL_BUG_ON for
@@ -244,21 +281,23 @@ struct page *vmalloc_to_page(const void *vmalloc_addr)
 	 */
 	VIRTUAL_BUG_ON(!is_vmalloc_or_module_addr(vmalloc_addr));
 
-	if (!pgd_none(*pgd)) {
-		pud_t *pud = pud_offset(pgd, addr);
-		if (!pud_none(*pud)) {
-			pmd_t *pmd = pmd_offset(pud, addr);
-			if (!pmd_none(*pmd)) {
-				pte_t *ptep, pte;
-
-				ptep = pte_offset_map(pmd, addr);
-				pte = *ptep;
-				if (pte_present(pte))
-					page = pte_page(pte);
-				pte_unmap(ptep);
-			}
-		}
-	}
+	if (pgd_none(*pgd))
+		return NULL;
+	p4d = p4d_offset(pgd, addr);
+	if (p4d_none(*p4d))
+		return NULL;
+	pud = pud_offset(p4d, addr);
+	if (pud_none(*pud))
+		return NULL;
+	pmd = pmd_offset(pud, addr);
+	if (pmd_none(*pmd))
+		return NULL;
+
+	ptep = pte_offset_map(pmd, addr);
+	pte = *ptep;
+	if (pte_present(pte))
+		page = pte_page(pte);
+	pte_unmap(ptep);
 	return page;
 }
 EXPORT_SYMBOL(vmalloc_to_page);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
