Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8C1B74405DB
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 09:14:05 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 204so63164459pfx.1
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 06:14:05 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id y7si10377833pgb.374.2017.02.17.06.14.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 06:14:03 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 19/33] x86: convert the rest of the code to support p4d_t
Date: Fri, 17 Feb 2017 17:13:14 +0300
Message-Id: <20170217141328.164563-20-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170217141328.164563-1-kirill.shutemov@linux.intel.com>
References: <20170217141328.164563-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch converts x86 to use proper folding of new page table level
with <asm-generic/pgtable-nop4d.h>.

That's a bit of kitchen sink, but I don't see how to split it further.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/paravirt.h       |  33 +++++-
 arch/x86/include/asm/paravirt_types.h |  12 ++-
 arch/x86/include/asm/pgalloc.h        |  35 ++++++-
 arch/x86/include/asm/pgtable.h        |  59 ++++++++++-
 arch/x86/include/asm/pgtable_64.h     |  12 ++-
 arch/x86/include/asm/pgtable_types.h  |  10 +-
 arch/x86/include/asm/xen/page.h       |   8 +-
 arch/x86/kernel/paravirt.c            |  10 +-
 arch/x86/mm/init_64.c                 | 183 +++++++++++++++++++++++++++-------
 arch/x86/xen/mmu.c                    | 152 ++++++++++++++++------------
 include/trace/events/xen.h            |  28 +++---
 11 files changed, 401 insertions(+), 141 deletions(-)

diff --git a/arch/x86/include/asm/paravirt.h b/arch/x86/include/asm/paravirt.h
index 1eea6ca40694..432c6e730ed1 100644
--- a/arch/x86/include/asm/paravirt.h
+++ b/arch/x86/include/asm/paravirt.h
@@ -525,7 +525,7 @@ static inline void set_pud(pud_t *pudp, pud_t pud)
 		PVOP_VCALL2(pv_mmu_ops.set_pud, pudp,
 			    val);
 }
-#if CONFIG_PGTABLE_LEVELS == 4
+#if CONFIG_PGTABLE_LEVELS >= 4
 static inline pud_t __pud(pudval_t val)
 {
 	pudval_t ret;
@@ -554,6 +554,32 @@ static inline pudval_t pud_val(pud_t pud)
 	return ret;
 }
 
+static inline void pud_clear(pud_t *pudp)
+{
+	set_pud(pudp, __pud(0));
+}
+
+static inline void set_p4d(p4d_t *p4dp, p4d_t p4d)
+{
+	p4dval_t val = native_p4d_val(p4d);
+
+	if (sizeof(p4dval_t) > sizeof(long))
+		PVOP_VCALL3(pv_mmu_ops.set_p4d, p4dp,
+			    val, (u64)val >> 32);
+	else
+		PVOP_VCALL2(pv_mmu_ops.set_p4d, p4dp,
+			    val);
+}
+
+static inline void p4d_clear(p4d_t *p4dp)
+{
+	set_p4d(p4dp, __p4d(0));
+}
+
+#if CONFIG_PGTABLE_LEVELS >= 5
+
+#error FIXME
+
 static inline void set_pgd(pgd_t *pgdp, pgd_t pgd)
 {
 	pgdval_t val = native_pgd_val(pgd);
@@ -571,10 +597,7 @@ static inline void pgd_clear(pgd_t *pgdp)
 	set_pgd(pgdp, __pgd(0));
 }
 
-static inline void pud_clear(pud_t *pudp)
-{
-	set_pud(pudp, __pud(0));
-}
+#endif  /* CONFIG_PGTABLE_LEVELS == 5 */
 
 #endif	/* CONFIG_PGTABLE_LEVELS == 4 */
 
diff --git a/arch/x86/include/asm/paravirt_types.h b/arch/x86/include/asm/paravirt_types.h
index bb2de45a60f2..3982c200845f 100644
--- a/arch/x86/include/asm/paravirt_types.h
+++ b/arch/x86/include/asm/paravirt_types.h
@@ -277,12 +277,18 @@ struct pv_mmu_ops {
 	struct paravirt_callee_save pmd_val;
 	struct paravirt_callee_save make_pmd;
 
-#if CONFIG_PGTABLE_LEVELS == 4
+#if CONFIG_PGTABLE_LEVELS >= 4
 	struct paravirt_callee_save pud_val;
 	struct paravirt_callee_save make_pud;
 
-	void (*set_pgd)(pgd_t *pudp, pgd_t pgdval);
-#endif	/* CONFIG_PGTABLE_LEVELS == 4 */
+	void (*set_p4d)(p4d_t *p4dp, p4d_t p4dval);
+
+#if CONFIG_PGTABLE_LEVELS >= 5
+#error FIXME
+#endif	/* CONFIG_PGTABLE_LEVELS >= 5 */
+
+#endif	/* CONFIG_PGTABLE_LEVELS >= 4 */
+
 #endif	/* CONFIG_PGTABLE_LEVELS >= 3 */
 
 	struct pv_lazy_ops lazy_mode;
diff --git a/arch/x86/include/asm/pgalloc.h b/arch/x86/include/asm/pgalloc.h
index b6d425999f99..2f585054c63c 100644
--- a/arch/x86/include/asm/pgalloc.h
+++ b/arch/x86/include/asm/pgalloc.h
@@ -121,10 +121,10 @@ static inline void pud_populate(struct mm_struct *mm, pud_t *pud, pmd_t *pmd)
 #endif	/* CONFIG_X86_PAE */
 
 #if CONFIG_PGTABLE_LEVELS > 3
-static inline void pgd_populate(struct mm_struct *mm, pgd_t *pgd, pud_t *pud)
+static inline void p4d_populate(struct mm_struct *mm, p4d_t *p4d, pud_t *pud)
 {
 	paravirt_alloc_pud(mm, __pa(pud) >> PAGE_SHIFT);
-	set_pgd(pgd, __pgd(_PAGE_TABLE | __pa(pud)));
+	set_p4d(p4d, __p4d(_PAGE_TABLE | __pa(pud)));
 }
 
 static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
@@ -150,6 +150,37 @@ static inline void __pud_free_tlb(struct mmu_gather *tlb, pud_t *pud,
 	___pud_free_tlb(tlb, pud);
 }
 
+#if CONFIG_PGTABLE_LEVELS > 4
+static inline void pgd_populate(struct mm_struct *mm, pgd_t *pgd, p4d_t *p4d)
+{
+	paravirt_alloc_p4d(mm, __pa(p4d) >> PAGE_SHIFT);
+	set_pgd(pgd, __pgd(_PAGE_TABLE | __pa(p4d)));
+}
+
+static inline p4d_t *p4d_alloc_one(struct mm_struct *mm, unsigned long addr)
+{
+	gfp_t gfp = GFP_KERNEL_ACCOUNT;
+
+	if (mm == &init_mm)
+		gfp &= ~__GFP_ACCOUNT;
+	return (p4d_t *)get_zeroed_page(gfp);
+}
+
+static inline void p4d_free(struct mm_struct *mm, p4d_t *p4d)
+{
+	BUG_ON((unsigned long)p4d & (PAGE_SIZE-1));
+	free_page((unsigned long)p4d);
+}
+
+extern void ___p4d_free_tlb(struct mmu_gather *tlb, p4d_t *p4d);
+
+static inline void __p4d_free_tlb(struct mmu_gather *tlb, p4d_t *p4d,
+				  unsigned long address)
+{
+	___p4d_free_tlb(tlb, p4d);
+}
+
+#endif	/* CONFIG_PGTABLE_LEVELS > 4 */
 #endif	/* CONFIG_PGTABLE_LEVELS > 3 */
 #endif	/* CONFIG_PGTABLE_LEVELS > 2 */
 
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 8e3435a53a04..0cbc910320f8 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -52,11 +52,19 @@ extern struct mm_struct *pgd_page_get_mm(struct page *page);
 
 #define set_pmd(pmdp, pmd)		native_set_pmd(pmdp, pmd)
 
-#ifndef __PAGETABLE_PUD_FOLDED
+#ifndef __PAGETABLE_P4D_FOLDED
 #define set_pgd(pgdp, pgd)		native_set_pgd(pgdp, pgd)
 #define pgd_clear(pgd)			native_pgd_clear(pgd)
 #endif
 
+#ifndef set_p4d
+# define set_p4d(p4dp, p4d)		native_set_p4d(p4dp, p4d)
+#endif
+
+#ifndef __PAGETABLE_PUD_FOLDED
+#define p4d_clear(p4d)			native_p4d_clear(p4d)
+#endif
+
 #ifndef set_pud
 # define set_pud(pudp, pud)		native_set_pud(pudp, pud)
 #endif
@@ -73,6 +81,11 @@ extern struct mm_struct *pgd_page_get_mm(struct page *page);
 #define pgd_val(x)	native_pgd_val(x)
 #define __pgd(x)	native_make_pgd(x)
 
+#ifndef __PAGETABLE_P4D_FOLDED
+#define p4d_val(x)	native_p4d_val(x)
+#define __p4d(x)	native_make_p4d(x)
+#endif
+
 #ifndef __PAGETABLE_PUD_FOLDED
 #define pud_val(x)	native_pud_val(x)
 #define __pud(x)	native_make_pud(x)
@@ -439,6 +452,7 @@ static inline pgprot_t pgprot_modify(pgprot_t oldprot, pgprot_t newprot)
 #define pte_pgprot(x) __pgprot(pte_flags(x))
 #define pmd_pgprot(x) __pgprot(pmd_flags(x))
 #define pud_pgprot(x) __pgprot(pud_flags(x))
+#define p4d_pgprot(x) __pgprot(p4d_flags(x))
 
 #define canon_pgprot(p) __pgprot(massage_pgprot(p))
 
@@ -676,12 +690,47 @@ static inline unsigned long pud_index(unsigned long address)
 	return (address >> PUD_SHIFT) & (PTRS_PER_PUD - 1);
 }
 
+#if CONFIG_PGTABLE_LEVELS > 3
+static inline int p4d_none(p4d_t p4d)
+{
+	return (native_p4d_val(p4d) & ~(_PAGE_KNL_ERRATUM_MASK)) == 0;
+}
+
+static inline int p4d_present(p4d_t p4d)
+{
+	return p4d_flags(p4d) & _PAGE_PRESENT;
+}
+
+static inline unsigned long p4d_page_vaddr(p4d_t p4d)
+{
+	return (unsigned long)__va(p4d_val(p4d) & p4d_pfn_mask(p4d));
+}
+
+/*
+ * Currently stuck as a macro due to indirect forward reference to
+ * linux/mmzone.h's __section_mem_map_addr() definition:
+ */
+#define p4d_page(p4d)		\
+	pfn_to_page((p4d_val(p4d) & p4d_pfn_mask(p4d)) >> PAGE_SHIFT)
+
+/* Find an entry in the third-level page table.. */
+static inline pud_t *pud_offset(p4d_t *p4d, unsigned long address)
+{
+	return (pud_t *)p4d_page_vaddr(*p4d) + pud_index(address);
+}
+
+static inline int p4d_bad(p4d_t p4d)
+{
+	return (p4d_flags(p4d) & ~(_KERNPG_TABLE | _PAGE_USER)) != 0;
+}
+#endif  /* CONFIG_PGTABLE_LEVELS > 3 */
+
 static inline unsigned long p4d_index(unsigned long address)
 {
 	return (address >> P4D_SHIFT) & (PTRS_PER_P4D - 1);
 }
 
-#if CONFIG_PGTABLE_LEVELS > 3
+#if CONFIG_PGTABLE_LEVELS > 4
 static inline int pgd_present(pgd_t pgd)
 {
 	return pgd_flags(pgd) & _PAGE_PRESENT;
@@ -699,9 +748,9 @@ static inline unsigned long pgd_page_vaddr(pgd_t pgd)
 #define pgd_page(pgd)		pfn_to_page(pgd_val(pgd) >> PAGE_SHIFT)
 
 /* to find an entry in a page-table-directory. */
-static inline pud_t *pud_offset(pgd_t *pgd, unsigned long address)
+static inline p4d_t *p4d_offset(pgd_t *pgd, unsigned long address)
 {
-	return (pud_t *)pgd_page_vaddr(*pgd) + pud_index(address);
+	return (p4d_t *)pgd_page_vaddr(*pgd) + p4d_index(address);
 }
 
 static inline int pgd_bad(pgd_t pgd)
@@ -719,7 +768,7 @@ static inline int pgd_none(pgd_t pgd)
 	 */
 	return !native_pgd_val(pgd);
 }
-#endif	/* CONFIG_PGTABLE_LEVELS > 3 */
+#endif	/* CONFIG_PGTABLE_LEVELS > 4 */
 
 #endif	/* __ASSEMBLY__ */
 
diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index 62b775926045..2dce1f6b301e 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -41,9 +41,9 @@ extern void paging_init(void);
 
 struct mm_struct;
 
+void set_pte_vaddr_p4d(p4d_t *p4d_page, unsigned long vaddr, pte_t new_pte);
 void set_pte_vaddr_pud(pud_t *pud_page, unsigned long vaddr, pte_t new_pte);
 
-
 static inline void native_pte_clear(struct mm_struct *mm, unsigned long addr,
 				    pte_t *ptep)
 {
@@ -106,6 +106,16 @@ static inline void native_pud_clear(pud_t *pud)
 	native_set_pud(pud, native_make_pud(0));
 }
 
+static inline void native_set_p4d(p4d_t *p4dp, p4d_t p4d)
+{
+	*p4dp = p4d;
+}
+
+static inline void native_p4d_clear(p4d_t *p4d)
+{
+	native_set_p4d(p4d, (p4d_t) { .pgd = native_make_pgd(0)});
+}
+
 static inline void native_set_pgd(pgd_t *pgdp, pgd_t pgd)
 {
 	*pgdp = pgd;
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index df08535f774a..4930afe9df0a 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -277,11 +277,11 @@ static inline pgdval_t pgd_flags(pgd_t pgd)
 #error FIXME
 
 #else
-#include <asm-generic/5level-fixup.h>
+#include <asm-generic/pgtable-nop4d.h>
 
 static inline p4dval_t native_p4d_val(p4d_t p4d)
 {
-	return native_pgd_val(p4d);
+	return native_pgd_val(p4d.pgd);
 }
 #endif
 
@@ -298,12 +298,11 @@ static inline pudval_t native_pud_val(pud_t pud)
 	return pud.pud;
 }
 #else
-#define __ARCH_USE_5LEVEL_HACK
 #include <asm-generic/pgtable-nopud.h>
 
 static inline pudval_t native_pud_val(pud_t pud)
 {
-	return native_pgd_val(pud.pgd);
+	return native_pgd_val(pud.p4d.pgd);
 }
 #endif
 
@@ -320,12 +319,11 @@ static inline pmdval_t native_pmd_val(pmd_t pmd)
 	return pmd.pmd;
 }
 #else
-#define __ARCH_USE_5LEVEL_HACK
 #include <asm-generic/pgtable-nopmd.h>
 
 static inline pmdval_t native_pmd_val(pmd_t pmd)
 {
-	return native_pgd_val(pmd.pud.pgd);
+	return native_pgd_val(pmd.pud.p4d.pgd);
 }
 #endif
 
diff --git a/arch/x86/include/asm/xen/page.h b/arch/x86/include/asm/xen/page.h
index 33cbd3db97b9..bf2ca56fba11 100644
--- a/arch/x86/include/asm/xen/page.h
+++ b/arch/x86/include/asm/xen/page.h
@@ -279,13 +279,17 @@ static inline pte_t __pte_ma(pteval_t x)
 
 #define pmd_val_ma(v) ((v).pmd)
 #ifdef __PAGETABLE_PUD_FOLDED
-#define pud_val_ma(v) ((v).pgd.pgd)
+#define pud_val_ma(v) ((v).p4d.pgd.pgd)
 #else
 #define pud_val_ma(v) ((v).pud)
 #endif
 #define __pmd_ma(x)	((pmd_t) { (x) } )
 
-#define pgd_val_ma(x)	((x).pgd)
+#ifdef __PAGETABLE_P4D_FOLDED
+#define p4d_val_ma(x)	((x).pgd.pgd)
+#else
+#define p4d_val_ma(x)	((x).p4d)
+#endif
 
 void xen_set_domain_pte(pte_t *ptep, pte_t pteval, unsigned domid);
 
diff --git a/arch/x86/kernel/paravirt.c b/arch/x86/kernel/paravirt.c
index a1bfba0f7234..f8aedc112d5e 100644
--- a/arch/x86/kernel/paravirt.c
+++ b/arch/x86/kernel/paravirt.c
@@ -429,12 +429,16 @@ struct pv_mmu_ops pv_mmu_ops __ro_after_init = {
 	.pmd_val = PTE_IDENT,
 	.make_pmd = PTE_IDENT,
 
-#if CONFIG_PGTABLE_LEVELS == 4
+#if CONFIG_PGTABLE_LEVELS >= 4
 	.pud_val = PTE_IDENT,
 	.make_pud = PTE_IDENT,
 
-	.set_pgd = native_set_pgd,
-#endif
+	.set_p4d = native_set_p4d,
+
+#if CONFIG_PGTABLE_LEVELS >= 5
+#error FIXME
+#endif /* CONFIG_PGTABLE_LEVELS >= 4 */
+#endif /* CONFIG_PGTABLE_LEVELS >= 4 */
 #endif /* CONFIG_PGTABLE_LEVELS >= 3 */
 
 	.pte_val = PTE_IDENT,
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index af85b686a7b0..07b52f81e9cd 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -97,28 +97,38 @@ void sync_global_pgds(unsigned long start, unsigned long end)
 	unsigned long address;
 
 	for (address = start; address <= end; address += PGDIR_SIZE) {
-		const pgd_t *pgd_ref = pgd_offset_k(address);
+		pgd_t *pgd_ref = pgd_offset_k(address);
+		const p4d_t *p4d_ref;
 		struct page *page;
 
-		if (pgd_none(*pgd_ref))
+		/*
+		 * With folded p4d, pgd_none() is always false, we need to
+		 * handle synchonization on p4d level.
+		 */
+		BUILD_BUG_ON(pgd_none(*pgd_ref));
+		p4d_ref = p4d_offset(pgd_ref, address);
+
+		if (p4d_none(*p4d_ref))
 			continue;
 
 		spin_lock(&pgd_lock);
 		list_for_each_entry(page, &pgd_list, lru) {
 			pgd_t *pgd;
+			p4d_t *p4d;
 			spinlock_t *pgt_lock;
 
 			pgd = (pgd_t *)page_address(page) + pgd_index(address);
+			p4d = p4d_offset(pgd, address);
 			/* the pgt_lock only for Xen */
 			pgt_lock = &pgd_page_get_mm(page)->page_table_lock;
 			spin_lock(pgt_lock);
 
-			if (!pgd_none(*pgd_ref) && !pgd_none(*pgd))
-				BUG_ON(pgd_page_vaddr(*pgd)
-				       != pgd_page_vaddr(*pgd_ref));
+			if (!p4d_none(*p4d_ref) && !p4d_none(*p4d))
+				BUG_ON(p4d_page_vaddr(*p4d)
+				       != p4d_page_vaddr(*p4d_ref));
 
-			if (pgd_none(*pgd))
-				set_pgd(pgd, *pgd_ref);
+			if (p4d_none(*p4d))
+				set_p4d(p4d, *p4d_ref);
 
 			spin_unlock(pgt_lock);
 		}
@@ -149,16 +159,28 @@ static __ref void *spp_getpage(void)
 	return ptr;
 }
 
-static pud_t *fill_pud(pgd_t *pgd, unsigned long vaddr)
+static p4d_t *fill_p4d(pgd_t *pgd, unsigned long vaddr)
 {
 	if (pgd_none(*pgd)) {
-		pud_t *pud = (pud_t *)spp_getpage();
-		pgd_populate(&init_mm, pgd, pud);
-		if (pud != pud_offset(pgd, 0))
+		p4d_t *p4d = (p4d_t *)spp_getpage();
+		pgd_populate(&init_mm, pgd, p4d);
+		if (p4d != p4d_offset(pgd, 0))
 			printk(KERN_ERR "PAGETABLE BUG #00! %p <-> %p\n",
-			       pud, pud_offset(pgd, 0));
+			       p4d, p4d_offset(pgd, 0));
+	}
+	return p4d_offset(pgd, vaddr);
+}
+
+static pud_t *fill_pud(p4d_t *p4d, unsigned long vaddr)
+{
+	if (p4d_none(*p4d)) {
+		pud_t *pud = (pud_t *)spp_getpage();
+		p4d_populate(&init_mm, p4d, pud);
+		if (pud != pud_offset(p4d, 0))
+			printk(KERN_ERR "PAGETABLE BUG #01! %p <-> %p\n",
+			       pud, pud_offset(p4d, 0));
 	}
-	return pud_offset(pgd, vaddr);
+	return pud_offset(p4d, vaddr);
 }
 
 static pmd_t *fill_pmd(pud_t *pud, unsigned long vaddr)
@@ -167,7 +189,7 @@ static pmd_t *fill_pmd(pud_t *pud, unsigned long vaddr)
 		pmd_t *pmd = (pmd_t *) spp_getpage();
 		pud_populate(&init_mm, pud, pmd);
 		if (pmd != pmd_offset(pud, 0))
-			printk(KERN_ERR "PAGETABLE BUG #01! %p <-> %p\n",
+			printk(KERN_ERR "PAGETABLE BUG #02! %p <-> %p\n",
 			       pmd, pmd_offset(pud, 0));
 	}
 	return pmd_offset(pud, vaddr);
@@ -179,20 +201,15 @@ static pte_t *fill_pte(pmd_t *pmd, unsigned long vaddr)
 		pte_t *pte = (pte_t *) spp_getpage();
 		pmd_populate_kernel(&init_mm, pmd, pte);
 		if (pte != pte_offset_kernel(pmd, 0))
-			printk(KERN_ERR "PAGETABLE BUG #02!\n");
+			printk(KERN_ERR "PAGETABLE BUG #03!\n");
 	}
 	return pte_offset_kernel(pmd, vaddr);
 }
 
-void set_pte_vaddr_pud(pud_t *pud_page, unsigned long vaddr, pte_t new_pte)
+static void __set_pte_vaddr(pud_t *pud, unsigned long vaddr, pte_t new_pte)
 {
-	pud_t *pud;
-	pmd_t *pmd;
-	pte_t *pte;
-
-	pud = pud_page + pud_index(vaddr);
-	pmd = fill_pmd(pud, vaddr);
-	pte = fill_pte(pmd, vaddr);
+	pmd_t *pmd = fill_pmd(pud, vaddr);
+	pte_t *pte = fill_pte(pmd, vaddr);
 
 	set_pte(pte, new_pte);
 
@@ -203,10 +220,25 @@ void set_pte_vaddr_pud(pud_t *pud_page, unsigned long vaddr, pte_t new_pte)
 	__flush_tlb_one(vaddr);
 }
 
+void set_pte_vaddr_p4d(p4d_t *p4d_page, unsigned long vaddr, pte_t new_pte)
+{
+	p4d_t *p4d = p4d_page + p4d_index(vaddr);
+	pud_t *pud = fill_pud(p4d, vaddr);
+
+	__set_pte_vaddr(pud, vaddr, new_pte);
+}
+
+void set_pte_vaddr_pud(pud_t *pud_page, unsigned long vaddr, pte_t new_pte)
+{
+	pud_t *pud = pud_page + pud_index(vaddr);
+
+	__set_pte_vaddr(pud, vaddr, new_pte);
+}
+
 void set_pte_vaddr(unsigned long vaddr, pte_t pteval)
 {
 	pgd_t *pgd;
-	pud_t *pud_page;
+	p4d_t *p4d_page;
 
 	pr_debug("set_pte_vaddr %lx to %lx\n", vaddr, native_pte_val(pteval));
 
@@ -216,17 +248,20 @@ void set_pte_vaddr(unsigned long vaddr, pte_t pteval)
 			"PGD FIXMAP MISSING, it should be setup in head.S!\n");
 		return;
 	}
-	pud_page = (pud_t*)pgd_page_vaddr(*pgd);
-	set_pte_vaddr_pud(pud_page, vaddr, pteval);
+
+	p4d_page = p4d_offset(pgd, 0);
+	set_pte_vaddr_p4d(p4d_page, vaddr, pteval);
 }
 
 pmd_t * __init populate_extra_pmd(unsigned long vaddr)
 {
 	pgd_t *pgd;
+	p4d_t *p4d;
 	pud_t *pud;
 
 	pgd = pgd_offset_k(vaddr);
-	pud = fill_pud(pgd, vaddr);
+	p4d = fill_p4d(pgd, vaddr);
+	pud = fill_pud(p4d, vaddr);
 	return fill_pmd(pud, vaddr);
 }
 
@@ -245,6 +280,7 @@ static void __init __init_extra_mapping(unsigned long phys, unsigned long size,
 					enum page_cache_mode cache)
 {
 	pgd_t *pgd;
+	p4d_t *p4d;
 	pud_t *pud;
 	pmd_t *pmd;
 	pgprot_t prot;
@@ -255,11 +291,17 @@ static void __init __init_extra_mapping(unsigned long phys, unsigned long size,
 	for (; size; phys += PMD_SIZE, size -= PMD_SIZE) {
 		pgd = pgd_offset_k((unsigned long)__va(phys));
 		if (pgd_none(*pgd)) {
+			p4d = (p4d_t *) spp_getpage();
+			set_pgd(pgd, __pgd(__pa(p4d) | _KERNPG_TABLE |
+						_PAGE_USER));
+		}
+		p4d = p4d_offset(pgd, (unsigned long)__va(phys));
+		if (p4d_none(*p4d)) {
 			pud = (pud_t *) spp_getpage();
-			set_pgd(pgd, __pgd(__pa(pud) | _KERNPG_TABLE |
+			set_p4d(p4d, __p4d(__pa(pud) | _KERNPG_TABLE |
 						_PAGE_USER));
 		}
-		pud = pud_offset(pgd, (unsigned long)__va(phys));
+		pud = pud_offset(p4d, (unsigned long)__va(phys));
 		if (pud_none(*pud)) {
 			pmd = (pmd_t *) spp_getpage();
 			set_pud(pud, __pud(__pa(pmd) | _KERNPG_TABLE |
@@ -563,12 +605,15 @@ kernel_physical_mapping_init(unsigned long paddr_start,
 
 	for (; vaddr < vaddr_end; vaddr = vaddr_next) {
 		pgd_t *pgd = pgd_offset_k(vaddr);
+		p4d_t *p4d;
 		pud_t *pud;
 
 		vaddr_next = (vaddr & PGDIR_MASK) + PGDIR_SIZE;
 
-		if (pgd_val(*pgd)) {
-			pud = (pud_t *)pgd_page_vaddr(*pgd);
+		BUILD_BUG_ON(pgd_none(*pgd));
+		p4d = p4d_offset(pgd, vaddr);
+		if (p4d_val(*p4d)) {
+			pud = (pud_t *)p4d_page_vaddr(*p4d);
 			paddr_last = phys_pud_init(pud, __pa(vaddr),
 						   __pa(vaddr_end),
 						   page_size_mask);
@@ -580,7 +625,7 @@ kernel_physical_mapping_init(unsigned long paddr_start,
 					   page_size_mask);
 
 		spin_lock(&init_mm.page_table_lock);
-		pgd_populate(&init_mm, pgd, pud);
+		p4d_populate(&init_mm, p4d, pud);
 		spin_unlock(&init_mm.page_table_lock);
 		pgd_changed = true;
 	}
@@ -726,6 +771,24 @@ static void __meminit free_pmd_table(pmd_t *pmd_start, pud_t *pud)
 	spin_unlock(&init_mm.page_table_lock);
 }
 
+static void __meminit free_pud_table(pud_t *pud_start, p4d_t *p4d)
+{
+	pud_t *pud;
+	int i;
+
+	for (i = 0; i < PTRS_PER_PUD; i++) {
+		pud = pud_start + i;
+		if (!pud_none(*pud))
+			return;
+	}
+
+	/* free a pud talbe */
+	free_pagetable(p4d_page(*p4d), 0);
+	spin_lock(&init_mm.page_table_lock);
+	p4d_clear(p4d);
+	spin_unlock(&init_mm.page_table_lock);
+}
+
 static void __meminit
 remove_pte_table(pte_t *pte_start, unsigned long addr, unsigned long end,
 		 bool direct)
@@ -908,6 +971,32 @@ remove_pud_table(pud_t *pud_start, unsigned long addr, unsigned long end,
 		update_page_count(PG_LEVEL_1G, -pages);
 }
 
+static void __meminit
+remove_p4d_table(p4d_t *p4d_start, unsigned long addr, unsigned long end,
+		 bool direct)
+{
+	unsigned long next, pages = 0;
+	pud_t *pud_base;
+	p4d_t *p4d;
+
+	p4d = p4d_start + p4d_index(addr);
+	for (; addr < end; addr = next, p4d++) {
+		next = p4d_addr_end(addr, end);
+
+		if (!p4d_present(*p4d))
+			continue;
+
+		BUILD_BUG_ON(p4d_large(*p4d));
+
+		pud_base = (pud_t *)p4d_page_vaddr(*p4d);
+		remove_pud_table(pud_base, addr, next, direct);
+		free_pud_table(pud_base, p4d);
+	}
+
+	if (direct)
+		update_page_count(PG_LEVEL_512G, -pages);
+}
+
 /* start and end are both virtual address. */
 static void __meminit
 remove_pagetable(unsigned long start, unsigned long end, bool direct)
@@ -915,7 +1004,7 @@ remove_pagetable(unsigned long start, unsigned long end, bool direct)
 	unsigned long next;
 	unsigned long addr;
 	pgd_t *pgd;
-	pud_t *pud;
+	p4d_t *p4d;
 
 	for (addr = start; addr < end; addr = next) {
 		next = pgd_addr_end(addr, end);
@@ -924,8 +1013,8 @@ remove_pagetable(unsigned long start, unsigned long end, bool direct)
 		if (!pgd_present(*pgd))
 			continue;
 
-		pud = (pud_t *)pgd_page_vaddr(*pgd);
-		remove_pud_table(pud, addr, next, direct);
+		p4d = (p4d_t *)pgd_page_vaddr(*pgd);
+		remove_p4d_table(p4d, addr, next, direct);
 	}
 
 	flush_tlb_all();
@@ -1095,6 +1184,7 @@ int kern_addr_valid(unsigned long addr)
 {
 	unsigned long above = ((long)addr) >> __VIRTUAL_MASK_SHIFT;
 	pgd_t *pgd;
+	p4d_t *p4d;
 	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
@@ -1106,7 +1196,11 @@ int kern_addr_valid(unsigned long addr)
 	if (pgd_none(*pgd))
 		return 0;
 
-	pud = pud_offset(pgd, addr);
+	p4d = p4d_offset(pgd, addr);
+	if (p4d_none(*p4d))
+		return 0;
+
+	pud = pud_offset(p4d, addr);
 	if (pud_none(*pud))
 		return 0;
 
@@ -1163,6 +1257,7 @@ static int __meminit vmemmap_populate_hugepages(unsigned long start,
 	unsigned long addr;
 	unsigned long next;
 	pgd_t *pgd;
+	p4d_t *p4d;
 	pud_t *pud;
 	pmd_t *pmd;
 
@@ -1173,7 +1268,11 @@ static int __meminit vmemmap_populate_hugepages(unsigned long start,
 		if (!pgd)
 			return -ENOMEM;
 
-		pud = vmemmap_pud_populate(pgd, addr, node);
+		p4d = vmemmap_p4d_populate(pgd, addr, node);
+		if (!p4d)
+			return -ENOMEM;
+
+		pud = vmemmap_pud_populate(p4d, addr, node);
 		if (!pud)
 			return -ENOMEM;
 
@@ -1241,6 +1340,7 @@ void register_page_bootmem_memmap(unsigned long section_nr,
 	unsigned long end = (unsigned long)(start_page + size);
 	unsigned long next;
 	pgd_t *pgd;
+	p4d_t *p4d;
 	pud_t *pud;
 	pmd_t *pmd;
 	unsigned int nr_pages;
@@ -1256,7 +1356,14 @@ void register_page_bootmem_memmap(unsigned long section_nr,
 		}
 		get_page_bootmem(section_nr, pgd_page(*pgd), MIX_SECTION_INFO);
 
-		pud = pud_offset(pgd, addr);
+		p4d = p4d_offset(pgd, addr);
+		if (p4d_none(*p4d)) {
+			next = (addr + PAGE_SIZE) & PAGE_MASK;
+			continue;
+		}
+		get_page_bootmem(section_nr, p4d_page(*p4d), MIX_SECTION_INFO);
+
+		pud = pud_offset(p4d, addr);
 		if (pud_none(*pud)) {
 			next = (addr + PAGE_SIZE) & PAGE_MASK;
 			continue;
diff --git a/arch/x86/xen/mmu.c b/arch/x86/xen/mmu.c
index 88c704caf2c1..47b3a0f9c59b 100644
--- a/arch/x86/xen/mmu.c
+++ b/arch/x86/xen/mmu.c
@@ -535,40 +535,41 @@ static pgd_t *xen_get_user_pgd(pgd_t *pgd)
 	return user_ptr;
 }
 
-static void __xen_set_pgd_hyper(pgd_t *ptr, pgd_t val)
+static void __xen_set_p4d_hyper(p4d_t *ptr, p4d_t val)
 {
 	struct mmu_update u;
 
 	u.ptr = virt_to_machine(ptr).maddr;
-	u.val = pgd_val_ma(val);
+	u.val = p4d_val_ma(val);
 	xen_extend_mmu_update(&u);
 }
 
 /*
- * Raw hypercall-based set_pgd, intended for in early boot before
+ * Raw hypercall-based set_p4d, intended for in early boot before
  * there's a page structure.  This implies:
  *  1. The only existing pagetable is the kernel's
  *  2. It is always pinned
  *  3. It has no user pagetable attached to it
  */
-static void __init xen_set_pgd_hyper(pgd_t *ptr, pgd_t val)
+static void __init xen_set_p4d_hyper(p4d_t *ptr, p4d_t val)
 {
 	preempt_disable();
 
 	xen_mc_batch();
 
-	__xen_set_pgd_hyper(ptr, val);
+	__xen_set_p4d_hyper(ptr, val);
 
 	xen_mc_issue(PARAVIRT_LAZY_MMU);
 
 	preempt_enable();
 }
 
-static void xen_set_pgd(pgd_t *ptr, pgd_t val)
+static void xen_set_p4d(p4d_t *ptr, p4d_t val)
 {
-	pgd_t *user_ptr = xen_get_user_pgd(ptr);
+	pgd_t *user_ptr = xen_get_user_pgd((pgd_t *)ptr);
+	pgd_t pgd_val;
 
-	trace_xen_mmu_set_pgd(ptr, user_ptr, val);
+	trace_xen_mmu_set_p4d(ptr, (p4d_t *)user_ptr, val);
 
 	/* If page is not pinned, we can just update the entry
 	   directly */
@@ -576,7 +577,8 @@ static void xen_set_pgd(pgd_t *ptr, pgd_t val)
 		*ptr = val;
 		if (user_ptr) {
 			WARN_ON(xen_page_pinned(user_ptr));
-			*user_ptr = val;
+			pgd_val.pgd = p4d_val_ma(val);
+			*user_ptr = pgd_val;
 		}
 		return;
 	}
@@ -585,9 +587,9 @@ static void xen_set_pgd(pgd_t *ptr, pgd_t val)
 	   user updates together. */
 	xen_mc_batch();
 
-	__xen_set_pgd_hyper(ptr, val);
+	__xen_set_p4d_hyper(ptr, val);
 	if (user_ptr)
-		__xen_set_pgd_hyper(user_ptr, val);
+		__xen_set_p4d_hyper((p4d_t *)user_ptr, val);
 
 	xen_mc_issue(PARAVIRT_LAZY_MMU);
 }
@@ -1589,7 +1591,6 @@ static int xen_pgd_alloc(struct mm_struct *mm)
 		BUG_ON(PagePinned(virt_to_page(xen_get_user_pgd(pgd))));
 	}
 #endif
-
 	return ret;
 }
 
@@ -1781,7 +1782,7 @@ static void xen_release_pmd(unsigned long pfn)
 	xen_release_ptpage(pfn, PT_PMD);
 }
 
-#if CONFIG_PGTABLE_LEVELS == 4
+#if CONFIG_PGTABLE_LEVELS >= 4
 static void xen_alloc_pud(struct mm_struct *mm, unsigned long pfn)
 {
 	xen_alloc_ptpage(mm, pfn, PT_PUD);
@@ -2127,21 +2128,27 @@ static phys_addr_t __init xen_early_virt_to_phys(unsigned long vaddr)
  */
 void __init xen_relocate_p2m(void)
 {
-	phys_addr_t size, new_area, pt_phys, pmd_phys, pud_phys;
+	phys_addr_t size, new_area, pt_phys, pmd_phys, pud_phys, p4d_phys;
 	unsigned long p2m_pfn, p2m_pfn_end, n_frames, pfn, pfn_end;
-	int n_pte, n_pt, n_pmd, n_pud, idx_pte, idx_pt, idx_pmd, idx_pud;
+	int n_pte, n_pt, n_pmd, n_pud, n_p4d, idx_pte, idx_pt, idx_pmd, idx_pud, idx_p4d;
 	pte_t *pt;
 	pmd_t *pmd;
 	pud_t *pud;
+	p4d_t *p4d = NULL;
 	pgd_t *pgd;
 	unsigned long *new_p2m;
+	int save_pud;
 
 	size = PAGE_ALIGN(xen_start_info->nr_pages * sizeof(unsigned long));
 	n_pte = roundup(size, PAGE_SIZE) >> PAGE_SHIFT;
 	n_pt = roundup(size, PMD_SIZE) >> PMD_SHIFT;
 	n_pmd = roundup(size, PUD_SIZE) >> PUD_SHIFT;
-	n_pud = roundup(size, PGDIR_SIZE) >> PGDIR_SHIFT;
-	n_frames = n_pte + n_pt + n_pmd + n_pud;
+	n_pud = roundup(size, P4D_SIZE) >> P4D_SHIFT;
+	if (PTRS_PER_P4D > 1)
+		n_p4d = roundup(size, PGDIR_SIZE) >> PGDIR_SHIFT;
+	else
+		n_p4d = 0;
+	n_frames = n_pte + n_pt + n_pmd + n_pud + n_p4d;
 
 	new_area = xen_find_free_area(PFN_PHYS(n_frames));
 	if (!new_area) {
@@ -2157,55 +2164,76 @@ void __init xen_relocate_p2m(void)
 	 * To avoid any possible virtual address collision, just use
 	 * 2 * PUD_SIZE for the new area.
 	 */
-	pud_phys = new_area;
+	p4d_phys = new_area;
+	pud_phys = p4d_phys + PFN_PHYS(n_p4d);
 	pmd_phys = pud_phys + PFN_PHYS(n_pud);
 	pt_phys = pmd_phys + PFN_PHYS(n_pmd);
 	p2m_pfn = PFN_DOWN(pt_phys) + n_pt;
 
 	pgd = __va(read_cr3());
 	new_p2m = (unsigned long *)(2 * PGDIR_SIZE);
-	for (idx_pud = 0; idx_pud < n_pud; idx_pud++) {
-		pud = early_memremap(pud_phys, PAGE_SIZE);
-		clear_page(pud);
-		for (idx_pmd = 0; idx_pmd < min(n_pmd, PTRS_PER_PUD);
-		     idx_pmd++) {
-			pmd = early_memremap(pmd_phys, PAGE_SIZE);
-			clear_page(pmd);
-			for (idx_pt = 0; idx_pt < min(n_pt, PTRS_PER_PMD);
-			     idx_pt++) {
-				pt = early_memremap(pt_phys, PAGE_SIZE);
-				clear_page(pt);
-				for (idx_pte = 0;
-				     idx_pte < min(n_pte, PTRS_PER_PTE);
-				     idx_pte++) {
-					set_pte(pt + idx_pte,
-						pfn_pte(p2m_pfn, PAGE_KERNEL));
-					p2m_pfn++;
+	idx_p4d = 0;
+	save_pud = n_pud;
+	do {
+		if (n_p4d > 0) {
+			p4d = early_memremap(p4d_phys, PAGE_SIZE);
+			clear_page(p4d);
+			n_pud = min(save_pud, PTRS_PER_P4D);
+		}
+		for (idx_pud = 0; idx_pud < n_pud; idx_pud++) {
+			pud = early_memremap(pud_phys, PAGE_SIZE);
+			clear_page(pud);
+			for (idx_pmd = 0; idx_pmd < min(n_pmd, PTRS_PER_PUD);
+				 idx_pmd++) {
+				pmd = early_memremap(pmd_phys, PAGE_SIZE);
+				clear_page(pmd);
+				for (idx_pt = 0; idx_pt < min(n_pt, PTRS_PER_PMD);
+					 idx_pt++) {
+					pt = early_memremap(pt_phys, PAGE_SIZE);
+					clear_page(pt);
+					for (idx_pte = 0;
+						 idx_pte < min(n_pte, PTRS_PER_PTE);
+						 idx_pte++) {
+						set_pte(pt + idx_pte,
+								pfn_pte(p2m_pfn, PAGE_KERNEL));
+						p2m_pfn++;
+					}
+					n_pte -= PTRS_PER_PTE;
+					early_memunmap(pt, PAGE_SIZE);
+					make_lowmem_page_readonly(__va(pt_phys));
+					pin_pagetable_pfn(MMUEXT_PIN_L1_TABLE,
+							PFN_DOWN(pt_phys));
+					set_pmd(pmd + idx_pt,
+							__pmd(_PAGE_TABLE | pt_phys));
+					pt_phys += PAGE_SIZE;
 				}
-				n_pte -= PTRS_PER_PTE;
-				early_memunmap(pt, PAGE_SIZE);
-				make_lowmem_page_readonly(__va(pt_phys));
-				pin_pagetable_pfn(MMUEXT_PIN_L1_TABLE,
-						  PFN_DOWN(pt_phys));
-				set_pmd(pmd + idx_pt,
-					__pmd(_PAGE_TABLE | pt_phys));
-				pt_phys += PAGE_SIZE;
+				n_pt -= PTRS_PER_PMD;
+				early_memunmap(pmd, PAGE_SIZE);
+				make_lowmem_page_readonly(__va(pmd_phys));
+				pin_pagetable_pfn(MMUEXT_PIN_L2_TABLE,
+						PFN_DOWN(pmd_phys));
+				set_pud(pud + idx_pmd, __pud(_PAGE_TABLE | pmd_phys));
+				pmd_phys += PAGE_SIZE;
 			}
-			n_pt -= PTRS_PER_PMD;
-			early_memunmap(pmd, PAGE_SIZE);
-			make_lowmem_page_readonly(__va(pmd_phys));
-			pin_pagetable_pfn(MMUEXT_PIN_L2_TABLE,
-					  PFN_DOWN(pmd_phys));
-			set_pud(pud + idx_pmd, __pud(_PAGE_TABLE | pmd_phys));
-			pmd_phys += PAGE_SIZE;
+			n_pmd -= PTRS_PER_PUD;
+			early_memunmap(pud, PAGE_SIZE);
+			make_lowmem_page_readonly(__va(pud_phys));
+			pin_pagetable_pfn(MMUEXT_PIN_L3_TABLE, PFN_DOWN(pud_phys));
+			if (n_p4d > 0)
+				set_p4d(p4d + idx_pud, __p4d(_PAGE_TABLE | pud_phys));
+			else
+				set_pgd(pgd + 2 + idx_pud, __pgd(_PAGE_TABLE | pud_phys));
+			pud_phys += PAGE_SIZE;
 		}
-		n_pmd -= PTRS_PER_PUD;
-		early_memunmap(pud, PAGE_SIZE);
-		make_lowmem_page_readonly(__va(pud_phys));
-		pin_pagetable_pfn(MMUEXT_PIN_L3_TABLE, PFN_DOWN(pud_phys));
-		set_pgd(pgd + 2 + idx_pud, __pgd(_PAGE_TABLE | pud_phys));
-		pud_phys += PAGE_SIZE;
-	}
+		if (n_p4d > 0) {
+			save_pud -= PTRS_PER_P4D;
+			early_memunmap(p4d, PAGE_SIZE);
+			make_lowmem_page_readonly(__va(p4d_phys));
+			pin_pagetable_pfn(MMUEXT_PIN_L4_TABLE, PFN_DOWN(p4d_phys));
+			set_pgd(pgd + 2 + idx_p4d, __pgd(_PAGE_TABLE | p4d_phys));
+			p4d_phys += PAGE_SIZE;
+		}
+	} while (++idx_p4d < n_p4d);
 
 	/* Now copy the old p2m info to the new area. */
 	memcpy(new_p2m, xen_p2m_addr, size);
@@ -2434,8 +2462,8 @@ static void __init xen_post_allocator_init(void)
 	pv_mmu_ops.set_pte = xen_set_pte;
 	pv_mmu_ops.set_pmd = xen_set_pmd;
 	pv_mmu_ops.set_pud = xen_set_pud;
-#if CONFIG_PGTABLE_LEVELS == 4
-	pv_mmu_ops.set_pgd = xen_set_pgd;
+#if CONFIG_PGTABLE_LEVELS >= 4
+	pv_mmu_ops.set_p4d = xen_set_p4d;
 #endif
 
 	/* This will work as long as patching hasn't happened yet
@@ -2444,7 +2472,7 @@ static void __init xen_post_allocator_init(void)
 	pv_mmu_ops.alloc_pmd = xen_alloc_pmd;
 	pv_mmu_ops.release_pte = xen_release_pte;
 	pv_mmu_ops.release_pmd = xen_release_pmd;
-#if CONFIG_PGTABLE_LEVELS == 4
+#if CONFIG_PGTABLE_LEVELS >= 4
 	pv_mmu_ops.alloc_pud = xen_alloc_pud;
 	pv_mmu_ops.release_pud = xen_release_pud;
 #endif
@@ -2510,10 +2538,10 @@ static const struct pv_mmu_ops xen_mmu_ops __initconst = {
 	.make_pmd = PV_CALLEE_SAVE(xen_make_pmd),
 	.pmd_val = PV_CALLEE_SAVE(xen_pmd_val),
 
-#if CONFIG_PGTABLE_LEVELS == 4
+#if CONFIG_PGTABLE_LEVELS >= 4
 	.pud_val = PV_CALLEE_SAVE(xen_pud_val),
 	.make_pud = PV_CALLEE_SAVE(xen_make_pud),
-	.set_pgd = xen_set_pgd_hyper,
+	.set_p4d = xen_set_p4d_hyper,
 
 	.alloc_pud = xen_alloc_pmd_init,
 	.release_pud = xen_release_pmd_init,
diff --git a/include/trace/events/xen.h b/include/trace/events/xen.h
index bce990f5a35d..31acce9019a6 100644
--- a/include/trace/events/xen.h
+++ b/include/trace/events/xen.h
@@ -241,21 +241,21 @@ TRACE_EVENT(xen_mmu_set_pud,
 		      (int)sizeof(pudval_t) * 2, (unsigned long long)__entry->pudval)
 	);
 
-TRACE_EVENT(xen_mmu_set_pgd,
-	    TP_PROTO(pgd_t *pgdp, pgd_t *user_pgdp, pgd_t pgdval),
-	    TP_ARGS(pgdp, user_pgdp, pgdval),
+TRACE_EVENT(xen_mmu_set_p4d,
+	    TP_PROTO(p4d_t *p4dp, p4d_t *user_p4dp, p4d_t p4dval),
+	    TP_ARGS(p4dp, user_p4dp, p4dval),
 	    TP_STRUCT__entry(
-		    __field(pgd_t *, pgdp)
-		    __field(pgd_t *, user_pgdp)
-		    __field(pgdval_t, pgdval)
-		    ),
-	    TP_fast_assign(__entry->pgdp = pgdp;
-			   __entry->user_pgdp = user_pgdp;
-			   __entry->pgdval = pgdval.pgd),
-	    TP_printk("pgdp %p user_pgdp %p pgdval %0*llx (raw %0*llx)",
-		      __entry->pgdp, __entry->user_pgdp,
-		      (int)sizeof(pgdval_t) * 2, (unsigned long long)pgd_val(native_make_pgd(__entry->pgdval)),
-		      (int)sizeof(pgdval_t) * 2, (unsigned long long)__entry->pgdval)
+		    __field(p4d_t *, p4dp)
+		    __field(p4d_t *, user_p4dp)
+		    __field(p4dval_t, p4dval)
+		    ),
+	    TP_fast_assign(__entry->p4dp = p4dp;
+			   __entry->user_p4dp = user_p4dp;
+			   __entry->p4dval = p4d_val(p4dval)),
+	    TP_printk("p4dp %p user_p4dp %p p4dval %0*llx (raw %0*llx)",
+		      __entry->p4dp, __entry->user_p4dp,
+		      (int)sizeof(p4dval_t) * 2, (unsigned long long)pgd_val(native_make_pgd(__entry->p4dval)),
+		      (int)sizeof(p4dval_t) * 2, (unsigned long long)__entry->p4dval)
 	);
 
 TRACE_EVENT(xen_mmu_pud_clear,
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
