Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id BD0996B0279
	for <linux-mm@kvack.org>; Mon, 26 Dec 2016 20:55:06 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 5so776903315pgi.2
        for <linux-mm@kvack.org>; Mon, 26 Dec 2016 17:55:06 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id n187si26679909pga.63.2016.12.26.17.54.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Dec 2016 17:54:47 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 15/29] x86: convert the rest of the code to support p4d_t
Date: Tue, 27 Dec 2016 04:53:59 +0300
Message-Id: <20161227015413.187403-16-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
References: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch converts x86 to use proper folding of new page table level
with <asm-generic/pgtable-nop4d.h>.

TODO: split it up futher.
FIXME: XEN is broken.

Not-yet-Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/paravirt.h       |  33 +++++--
 arch/x86/include/asm/paravirt_types.h |  12 ++-
 arch/x86/include/asm/pgalloc.h        |  35 +++++++-
 arch/x86/include/asm/pgtable.h        |  75 +++++++++++++---
 arch/x86/include/asm/pgtable_64.h     |  12 ++-
 arch/x86/include/asm/pgtable_types.h  |  10 +--
 arch/x86/kernel/paravirt.c            |  10 ++-
 arch/x86/mm/init_64.c                 | 162 +++++++++++++++++++++++++++-------
 arch/x86/mm/kasan_init_64.c           |  12 ++-
 arch/x86/mm/pageattr.c                |  56 ++++++++----
 arch/x86/platform/efi/efi_64.c        |   8 +-
 arch/x86/xen/Kconfig                  |   1 +
 12 files changed, 342 insertions(+), 84 deletions(-)

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
index 54b6632723d5..398adab9a167 100644
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
 
@@ -671,12 +685,58 @@ static inline int pud_large(pud_t pud)
 }
 #endif	/* CONFIG_PGTABLE_LEVELS > 2 */
 
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
+/*
+ * the pud page can be thought of an array like this: pud_t[PTRS_PER_PUD]
+ *
+ * this macro returns the index of the entry in the pud page which would
+ * control the given virtual address
+ */
+static inline unsigned long pud_index(unsigned long address)
+{
+	return (address >> PUD_SHIFT) & (PTRS_PER_PUD - 1);
+}
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
@@ -694,14 +754,9 @@ static inline unsigned long pgd_page_vaddr(pgd_t pgd)
 #define pgd_page(pgd)		pfn_to_page(pgd_val(pgd) >> PAGE_SHIFT)
 
 /* to find an entry in a page-table-directory. */
-static inline unsigned long pud_index(unsigned long address)
-{
-	return (address >> PUD_SHIFT) & (PTRS_PER_PUD - 1);
-}
-
-static inline pud_t *pud_offset(pgd_t *pgd, unsigned long address)
+static inline p4d_t *p4d_offset(pgd_t *pgd, unsigned long address)
 {
-	return (pud_t *)pgd_page_vaddr(*pgd) + pud_index(address);
+	return (p4d_t *)pgd_page_vaddr(*pgd) + p4d_index(address);
 }
 
 static inline int pgd_bad(pgd_t pgd)
@@ -719,7 +774,7 @@ static inline int pgd_none(pgd_t pgd)
 	 */
 	return !native_pgd_val(pgd);
 }
-#endif	/* CONFIG_PGTABLE_LEVELS > 3 */
+#endif	/* CONFIG_PGTABLE_LEVELS > 4 */
 
 #endif	/* __ASSEMBLY__ */
 
diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index 62b775926045..dff070a6d27e 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -41,7 +41,7 @@ extern void paging_init(void);
 
 struct mm_struct;
 
-void set_pte_vaddr_pud(pud_t *pud_page, unsigned long vaddr, pte_t new_pte);
+void set_pte_vaddr_pud(pud_t *pud, unsigned long vaddr, pte_t new_pte);
 
 
 static inline void native_pte_clear(struct mm_struct *mm, unsigned long addr,
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
index af85b686a7b0..72527ece6130 100644
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
 	}
-	return pud_offset(pgd, vaddr);
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
+	}
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
@@ -179,18 +201,16 @@ static pte_t *fill_pte(pmd_t *pmd, unsigned long vaddr)
 		pte_t *pte = (pte_t *) spp_getpage();
 		pmd_populate_kernel(&init_mm, pmd, pte);
 		if (pte != pte_offset_kernel(pmd, 0))
-			printk(KERN_ERR "PAGETABLE BUG #02!\n");
+			printk(KERN_ERR "PAGETABLE BUG #03!\n");
 	}
 	return pte_offset_kernel(pmd, vaddr);
 }
 
-void set_pte_vaddr_pud(pud_t *pud_page, unsigned long vaddr, pte_t new_pte)
+void set_pte_vaddr_pud(pud_t *pud, unsigned long vaddr, pte_t new_pte)
 {
-	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
 
-	pud = pud_page + pud_index(vaddr);
 	pmd = fill_pmd(pud, vaddr);
 	pte = fill_pte(pmd, vaddr);
 
@@ -206,7 +226,8 @@ void set_pte_vaddr_pud(pud_t *pud_page, unsigned long vaddr, pte_t new_pte)
 void set_pte_vaddr(unsigned long vaddr, pte_t pteval)
 {
 	pgd_t *pgd;
-	pud_t *pud_page;
+	p4d_t *p4d;
+	pud_t *pud;
 
 	pr_debug("set_pte_vaddr %lx to %lx\n", vaddr, native_pte_val(pteval));
 
@@ -216,17 +237,20 @@ void set_pte_vaddr(unsigned long vaddr, pte_t pteval)
 			"PGD FIXMAP MISSING, it should be setup in head.S!\n");
 		return;
 	}
-	pud_page = (pud_t*)pgd_page_vaddr(*pgd);
-	set_pte_vaddr_pud(pud_page, vaddr, pteval);
+	p4d = fill_p4d(pgd, vaddr);
+	pud = fill_pud(p4d, vaddr);
+	set_pte_vaddr_pud(pud, vaddr, pteval);
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
 
@@ -245,6 +269,7 @@ static void __init __init_extra_mapping(unsigned long phys, unsigned long size,
 					enum page_cache_mode cache)
 {
 	pgd_t *pgd;
+	p4d_t *p4d;
 	pud_t *pud;
 	pmd_t *pmd;
 	pgprot_t prot;
@@ -255,11 +280,17 @@ static void __init __init_extra_mapping(unsigned long phys, unsigned long size,
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
@@ -563,12 +594,15 @@ kernel_physical_mapping_init(unsigned long paddr_start,
 
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
@@ -580,7 +614,7 @@ kernel_physical_mapping_init(unsigned long paddr_start,
 					   page_size_mask);
 
 		spin_lock(&init_mm.page_table_lock);
-		pgd_populate(&init_mm, pgd, pud);
+		p4d_populate(&init_mm, p4d, pud);
 		spin_unlock(&init_mm.page_table_lock);
 		pgd_changed = true;
 	}
@@ -726,6 +760,24 @@ static void __meminit free_pmd_table(pmd_t *pmd_start, pud_t *pud)
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
@@ -908,6 +960,32 @@ remove_pud_table(pud_t *pud_start, unsigned long addr, unsigned long end,
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
@@ -915,7 +993,7 @@ remove_pagetable(unsigned long start, unsigned long end, bool direct)
 	unsigned long next;
 	unsigned long addr;
 	pgd_t *pgd;
-	pud_t *pud;
+	p4d_t *p4d;
 
 	for (addr = start; addr < end; addr = next) {
 		next = pgd_addr_end(addr, end);
@@ -924,8 +1002,8 @@ remove_pagetable(unsigned long start, unsigned long end, bool direct)
 		if (!pgd_present(*pgd))
 			continue;
 
-		pud = (pud_t *)pgd_page_vaddr(*pgd);
-		remove_pud_table(pud, addr, next, direct);
+		p4d = (p4d_t *)pgd_page_vaddr(*pgd);
+		remove_p4d_table(p4d, addr, next, direct);
 	}
 
 	flush_tlb_all();
@@ -1095,6 +1173,7 @@ int kern_addr_valid(unsigned long addr)
 {
 	unsigned long above = ((long)addr) >> __VIRTUAL_MASK_SHIFT;
 	pgd_t *pgd;
+	p4d_t *p4d;
 	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
@@ -1106,7 +1185,11 @@ int kern_addr_valid(unsigned long addr)
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
 
@@ -1163,6 +1246,7 @@ static int __meminit vmemmap_populate_hugepages(unsigned long start,
 	unsigned long addr;
 	unsigned long next;
 	pgd_t *pgd;
+	p4d_t *p4d;
 	pud_t *pud;
 	pmd_t *pmd;
 
@@ -1173,7 +1257,11 @@ static int __meminit vmemmap_populate_hugepages(unsigned long start,
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
 
@@ -1241,6 +1329,7 @@ void register_page_bootmem_memmap(unsigned long section_nr,
 	unsigned long end = (unsigned long)(start_page + size);
 	unsigned long next;
 	pgd_t *pgd;
+	p4d_t *p4d;
 	pud_t *pud;
 	pmd_t *pmd;
 	unsigned int nr_pages;
@@ -1256,7 +1345,14 @@ void register_page_bootmem_memmap(unsigned long section_nr,
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
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 0493c17b8a51..2964de48e177 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -31,8 +31,16 @@ static int __init map_range(struct range *range)
 static void __init clear_pgds(unsigned long start,
 			unsigned long end)
 {
-	for (; start < end; start += PGDIR_SIZE)
-		pgd_clear(pgd_offset_k(start));
+	pgd_t *pgd;
+
+	for (; start < end; start += PGDIR_SIZE) {
+		pgd = pgd_offset_k(start);
+#ifdef __PAGETABLE_P4D_FOLDED
+		p4d_clear(p4d_offset(pgd, start));
+#else
+		pgd_clear(pgd);
+#endif
+	}
 }
 
 static void __init kasan_map_early_shadow(pgd_t *pgd)
diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index 5a287e523eab..8ec4baa84526 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -333,6 +333,7 @@ static inline pgprot_t static_protections(pgprot_t prot, unsigned long address,
 pte_t *lookup_address_in_pgd(pgd_t *pgd, unsigned long address,
 			     unsigned int *level)
 {
+	p4d_t *p4d;
 	pud_t *pud;
 	pmd_t *pmd;
 
@@ -341,7 +342,15 @@ pte_t *lookup_address_in_pgd(pgd_t *pgd, unsigned long address,
 	if (pgd_none(*pgd))
 		return NULL;
 
-	pud = pud_offset(pgd, address);
+	p4d = p4d_offset(pgd, address);
+	if (p4d_none(*p4d))
+		return NULL;
+
+	*level = PG_LEVEL_512G;
+	if (p4d_large(*p4d) || !p4d_present(*p4d))
+		return (pte_t *)p4d;
+
+	pud = pud_offset(p4d, address);
 	if (pud_none(*pud))
 		return NULL;
 
@@ -393,13 +402,18 @@ static pte_t *_lookup_address_cpa(struct cpa_data *cpa, unsigned long address,
 pmd_t *lookup_pmd_address(unsigned long address)
 {
 	pgd_t *pgd;
+	p4d_t *p4d;
 	pud_t *pud;
 
 	pgd = pgd_offset_k(address);
 	if (pgd_none(*pgd))
 		return NULL;
 
-	pud = pud_offset(pgd, address);
+	p4d = p4d_offset(pgd, address);
+	if (p4d_none(*p4d) || p4d_large(*p4d) || !p4d_present(*p4d))
+		return NULL;
+
+	pud = pud_offset(p4d, address);
 	if (pud_none(*pud) || pud_large(*pud) || !pud_present(*pud))
 		return NULL;
 
@@ -464,11 +478,13 @@ static void __set_pmd_pte(pte_t *kpte, unsigned long address, pte_t pte)
 
 		list_for_each_entry(page, &pgd_list, lru) {
 			pgd_t *pgd;
+			p4d_t *p4d;
 			pud_t *pud;
 			pmd_t *pmd;
 
 			pgd = (pgd_t *)page_address(page) + pgd_index(address);
-			pud = pud_offset(pgd, address);
+			p4d = p4d_offset(pgd, address);
+			pud = pud_offset(p4d, address);
 			pmd = pmd_offset(pud, address);
 			set_pte_atomic((pte_t *)pmd, pte);
 		}
@@ -823,9 +839,9 @@ static void unmap_pmd_range(pud_t *pud, unsigned long start, unsigned long end)
 			pud_clear(pud);
 }
 
-static void unmap_pud_range(pgd_t *pgd, unsigned long start, unsigned long end)
+static void unmap_pud_range(p4d_t *p4d, unsigned long start, unsigned long end)
 {
-	pud_t *pud = pud_offset(pgd, start);
+	pud_t *pud = pud_offset(p4d, start);
 
 	/*
 	 * Not on a GB page boundary?
@@ -991,8 +1007,8 @@ static long populate_pmd(struct cpa_data *cpa,
 	return num_pages;
 }
 
-static long populate_pud(struct cpa_data *cpa, unsigned long start, pgd_t *pgd,
-			 pgprot_t pgprot)
+static int populate_pud(struct cpa_data *cpa, unsigned long start, p4d_t *p4d,
+			pgprot_t pgprot)
 {
 	pud_t *pud;
 	unsigned long end;
@@ -1013,7 +1029,7 @@ static long populate_pud(struct cpa_data *cpa, unsigned long start, pgd_t *pgd,
 		cur_pages = (pre_end - start) >> PAGE_SHIFT;
 		cur_pages = min_t(int, (int)cpa->numpages, cur_pages);
 
-		pud = pud_offset(pgd, start);
+		pud = pud_offset(p4d, start);
 
 		/*
 		 * Need a PMD page?
@@ -1034,7 +1050,7 @@ static long populate_pud(struct cpa_data *cpa, unsigned long start, pgd_t *pgd,
 	if (cpa->numpages == cur_pages)
 		return cur_pages;
 
-	pud = pud_offset(pgd, start);
+	pud = pud_offset(p4d, start);
 	pud_pgprot = pgprot_4k_2_large(pgprot);
 
 	/*
@@ -1054,7 +1070,7 @@ static long populate_pud(struct cpa_data *cpa, unsigned long start, pgd_t *pgd,
 	if (start < end) {
 		long tmp;
 
-		pud = pud_offset(pgd, start);
+		pud = pud_offset(p4d, start);
 		if (pud_none(*pud))
 			if (alloc_pmd_page(pud))
 				return -1;
@@ -1077,33 +1093,43 @@ static int populate_pgd(struct cpa_data *cpa, unsigned long addr)
 {
 	pgprot_t pgprot = __pgprot(_KERNPG_TABLE);
 	pud_t *pud = NULL;	/* shut up gcc */
+	p4d_t *p4d;
 	pgd_t *pgd_entry;
 	long ret;
 
 	pgd_entry = cpa->pgd + pgd_index(addr);
 
+	if (pgd_none(*pgd_entry)) {
+		p4d = (p4d_t *)get_zeroed_page(GFP_KERNEL | __GFP_NOTRACK);
+		if (!p4d)
+			return -1;
+
+		set_p4d(p4d, __p4d(__pa(p4d) | _KERNPG_TABLE));
+	}
+
 	/*
-	 * Allocate a PUD page and hand it down for mapping.
+	 * Allocate a P4D page and hand it down for mapping.
 	 */
-	if (pgd_none(*pgd_entry)) {
+	p4d = p4d_offset(pgd_entry, addr);
+	if (p4d_none(*p4d)) {
 		pud = (pud_t *)get_zeroed_page(GFP_KERNEL | __GFP_NOTRACK);
 		if (!pud)
 			return -1;
 
-		set_pgd(pgd_entry, __pgd(__pa(pud) | _KERNPG_TABLE));
+		set_p4d(p4d, __p4d(__pa(pud) | _KERNPG_TABLE));
 	}
 
 	pgprot_val(pgprot) &= ~pgprot_val(cpa->mask_clr);
 	pgprot_val(pgprot) |=  pgprot_val(cpa->mask_set);
 
-	ret = populate_pud(cpa, addr, pgd_entry, pgprot);
+	ret = populate_pud(cpa, addr, p4d, pgprot);
 	if (ret < 0) {
 		/*
 		 * Leave the PUD page in place in case some other CPU or thread
 		 * already found it, but remove any useless entries we just
 		 * added to it.
 		 */
-		unmap_pud_range(pgd_entry, addr,
+		unmap_pud_range(p4d, addr,
 				addr + (cpa->numpages << PAGE_SHIFT));
 		return ret;
 	}
diff --git a/arch/x86/platform/efi/efi_64.c b/arch/x86/platform/efi/efi_64.c
index 5aabfa3690dd..67bccd946071 100644
--- a/arch/x86/platform/efi/efi_64.c
+++ b/arch/x86/platform/efi/efi_64.c
@@ -135,7 +135,7 @@ static pgd_t *efi_pgd;
 int __init efi_alloc_page_tables(void)
 {
 	pgd_t *pgd;
-	pud_t *pud;
+	p4d_t *p4d;
 	gfp_t gfp_mask;
 
 	if (efi_enabled(EFI_OLD_MEMMAP))
@@ -148,13 +148,13 @@ int __init efi_alloc_page_tables(void)
 
 	pgd = efi_pgd + pgd_index(EFI_VA_END);
 
-	pud = pud_alloc_one(NULL, 0);
-	if (!pud) {
+	p4d = p4d_alloc_one(NULL, 0);
+	if (!p4d) {
 		free_page((unsigned long)efi_pgd);
 		return -ENOMEM;
 	}
 
-	pgd_populate(NULL, pgd, pud);
+	pgd_populate(NULL, pgd, p4d);
 
 	return 0;
 }
diff --git a/arch/x86/xen/Kconfig b/arch/x86/xen/Kconfig
index c7b15f3e2cf3..2aecee939095 100644
--- a/arch/x86/xen/Kconfig
+++ b/arch/x86/xen/Kconfig
@@ -4,6 +4,7 @@
 
 config XEN
 	bool "Xen guest support"
+	depends on BROKEN
 	depends on PARAVIRT
 	select PARAVIRT_CLOCK
 	select XEN_HAVE_PVMMU
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
