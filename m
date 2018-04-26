Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 16D336B000E
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 10:28:55 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id i3so4290827wmf.7
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 07:28:55 -0700 (PDT)
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id g5si969983edf.328.2018.04.26.07.28.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Apr 2018 07:28:53 -0700 (PDT)
From: Zi Yan <zi.yan@sent.com>
Subject: [RFC PATCH 9/9] mm: migrate: enable thp migration for all possible architectures.
Date: Thu, 26 Apr 2018 10:28:04 -0400
Message-Id: <20180426142804.180152-10-zi.yan@sent.com>
In-Reply-To: <20180426142804.180152-1-zi.yan@sent.com>
References: <20180426142804.180152-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, Vineet Gupta <vgupta@synopsys.com>, linux-snps-arc@lists.infradead.org, Russell King <linux@armlinux.org.uk>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Steve Capper <steve.capper@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Dan Williams <dan.j.williams@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, x86@kernel.org, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Michal Hocko <mhocko@suse.com>, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ram Pai <linuxram@us.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linuxppc-dev@lists.ozlabs.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Janosch Frank <frankja@linux.vnet.ibm.com>, linux-s390@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, "Huang, Ying" <ying.huang@intel.com>

From: Zi Yan <zi.yan@cs.rutgers.edu>

Remove CONFIG_ARCH_ENABLE_THP_MIGRATION. thp migration is enabled along
with transparent hugepage and can be toggled via
/sys/kernel/mm/transparent_hugepage/enable_thp_migration.

Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: linux-mm@kvack.org
Cc: Vineet Gupta <vgupta@synopsys.com>
Cc: linux-snps-arc@lists.infradead.org
Cc: Russell King <linux@armlinux.org.uk>
Cc: Christoffer Dall <christoffer.dall@linaro.org>
Cc: Marc Zyngier <marc.zyngier@arm.com>
Cc: linux-arm-kernel@lists.infradead.org
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Steve Capper <steve.capper@arm.com>
Cc: Kristina Martsenko <kristina.martsenko@arm.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: x86@kernel.org
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: James Hogan <jhogan@kernel.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: linux-mips@linux-mips.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Ram Pai <linuxram@us.ibm.com>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linuxppc-dev@lists.ozlabs.org
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Janosch Frank <frankja@linux.vnet.ibm.com>
Cc: linux-s390@vger.kernel.org
Cc: "David S. Miller" <davem@davemloft.net>
Cc: sparclinux@vger.kernel.org
Cc: "Huang, Ying" <ying.huang@intel.com>
---
 arch/x86/Kconfig               |  4 ----
 arch/x86/include/asm/pgtable.h |  2 --
 fs/proc/task_mmu.c             |  2 --
 include/asm-generic/pgtable.h  | 21 ++-------------------
 include/linux/huge_mm.h        |  9 ++++-----
 include/linux/swapops.h        |  4 +---
 mm/Kconfig                     |  3 ---
 mm/huge_memory.c               | 27 ++++++++++++++++++---------
 mm/migrate.c                   |  6 ++----
 mm/rmap.c                      |  5 ++---
 10 files changed, 29 insertions(+), 54 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 0fa71a78ec99..e73954e3eef7 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -2423,10 +2423,6 @@ config ARCH_ENABLE_HUGEPAGE_MIGRATION
 	def_bool y
 	depends on X86_64 && HUGETLB_PAGE && MIGRATION
 
-config ARCH_ENABLE_THP_MIGRATION
-	def_bool y
-	depends on X86_64 && TRANSPARENT_HUGEPAGE
-
 menu "Power management and ACPI options"
 
 config ARCH_HIBERNATION_HEADER
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index b444d83cfc95..f9f54d9b39e3 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -1193,7 +1193,6 @@ static inline pte_t pte_swp_clear_soft_dirty(pte_t pte)
 	return pte_clear_flags(pte, _PAGE_SWP_SOFT_DIRTY);
 }
 
-#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
 static inline pmd_t pmd_swp_mksoft_dirty(pmd_t pmd)
 {
 	return pmd_set_flags(pmd, _PAGE_SWP_SOFT_DIRTY);
@@ -1209,7 +1208,6 @@ static inline pmd_t pmd_swp_clear_soft_dirty(pmd_t pmd)
 	return pmd_clear_flags(pmd, _PAGE_SWP_SOFT_DIRTY);
 }
 #endif
-#endif
 
 #define PKRU_AD_BIT 0x1
 #define PKRU_WD_BIT 0x2
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index dd1b2aeb01e8..07a2f028d29a 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1326,7 +1326,6 @@ static int pagemap_pmd_range(pmd_t *pmdp, unsigned long addr, unsigned long end,
 				frame = pmd_pfn(pmd) +
 					((addr & ~PMD_MASK) >> PAGE_SHIFT);
 		}
-#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
 		else if (is_swap_pmd(pmd)) {
 			swp_entry_t entry = pmd_to_swp_entry(pmd);
 			unsigned long offset = swp_offset(entry);
@@ -1340,7 +1339,6 @@ static int pagemap_pmd_range(pmd_t *pmdp, unsigned long addr, unsigned long end,
 			VM_BUG_ON(!is_pmd_migration_entry(pmd));
 			page = migration_entry_to_page(entry);
 		}
-#endif
 
 		if (page && page_mapcount(page) == 1)
 			flags |= PM_MMAP_EXCLUSIVE;
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index f59639afaa39..9dacdd203131 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -674,24 +674,7 @@ static inline void ptep_modify_prot_commit(struct mm_struct *mm,
 #define arch_start_context_switch(prev)	do {} while (0)
 #endif
 
-#ifdef CONFIG_HAVE_ARCH_SOFT_DIRTY
-#ifndef CONFIG_ARCH_ENABLE_THP_MIGRATION
-static inline pmd_t pmd_swp_mksoft_dirty(pmd_t pmd)
-{
-	return pmd;
-}
-
-static inline int pmd_swp_soft_dirty(pmd_t pmd)
-{
-	return 0;
-}
-
-static inline pmd_t pmd_swp_clear_soft_dirty(pmd_t pmd)
-{
-	return pmd;
-}
-#endif
-#else /* !CONFIG_HAVE_ARCH_SOFT_DIRTY */
+#ifndef CONFIG_HAVE_ARCH_SOFT_DIRTY
 static inline int pte_soft_dirty(pte_t pte)
 {
 	return 0;
@@ -946,7 +929,7 @@ static inline int pmd_none_or_trans_huge_or_clear_bad(pmd_t *pmd)
 	 * redundant with !pmd_present().
 	 */
 	if (pmd_none(pmdval) || pmd_trans_huge(pmdval) ||
-		(IS_ENABLED(CONFIG_ARCH_ENABLE_THP_MIGRATION) && !pmd_present(pmdval)))
+		(IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) && !pmd_present(pmdval)))
 		return 1;
 	if (unlikely(pmd_bad(pmdval))) {
 		pmd_clear_bad(pmd);
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index a8a126259bc4..dc3144bdb7e5 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -59,6 +59,7 @@ enum transparent_hugepage_flag {
 	TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG,
 	TRANSPARENT_HUGEPAGE_DEFRAG_KHUGEPAGED_FLAG,
 	TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG,
+	TRANSPARENT_HUGEPAGE_MIGRATION_FLAG,
 #ifdef CONFIG_DEBUG_VM
 	TRANSPARENT_HUGEPAGE_DEBUG_COW_FLAG,
 #endif
@@ -126,6 +127,9 @@ static inline bool transparent_hugepage_enabled(struct vm_area_struct *vma)
 #else /* CONFIG_DEBUG_VM */
 #define transparent_hugepage_debug_cow() 0
 #endif /* CONFIG_DEBUG_VM */
+#define thp_migration_supported()				\
+	(transparent_hugepage_flags &					\
+	 (1<<TRANSPARENT_HUGEPAGE_MIGRATION_FLAG))
 
 extern unsigned long thp_get_unmapped_area(struct file *filp,
 		unsigned long addr, unsigned long len, unsigned long pgoff,
@@ -240,11 +244,6 @@ void mm_put_huge_zero_page(struct mm_struct *mm);
 
 #define mk_huge_pmd(page, prot) pmd_mkhuge(mk_pmd(page, prot))
 
-static inline bool thp_migration_supported(void)
-{
-	return IS_ENABLED(CONFIG_ARCH_ENABLE_THP_MIGRATION);
-}
-
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
 #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
diff --git a/include/linux/swapops.h b/include/linux/swapops.h
index 1d3877c39a00..1b723685f887 100644
--- a/include/linux/swapops.h
+++ b/include/linux/swapops.h
@@ -260,7 +260,7 @@ static inline int is_write_migration_entry(swp_entry_t entry)
 
 struct page_vma_mapped_walk;
 
-#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
 extern void set_pmd_migration_entry(struct page_vma_mapped_walk *pvmw,
 		struct page *page);
 
@@ -295,13 +295,11 @@ static inline int is_pmd_migration_entry(pmd_t pmd)
 static inline void set_pmd_migration_entry(struct page_vma_mapped_walk *pvmw,
 		struct page *page)
 {
-	BUILD_BUG();
 }
 
 static inline void remove_migration_pmd(struct page_vma_mapped_walk *pvmw,
 		struct page *new)
 {
-	BUILD_BUG();
 }
 
 static inline void pmd_migration_entry_wait(struct mm_struct *m, pmd_t *p) { }
diff --git a/mm/Kconfig b/mm/Kconfig
index c782e8fb7235..7f29c5c2a8f6 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -262,9 +262,6 @@ config MIGRATION
 config ARCH_ENABLE_HUGEPAGE_MIGRATION
 	bool
 
-config ARCH_ENABLE_THP_MIGRATION
-	bool
-
 config PHYS_ADDR_T_64BIT
 	def_bool 64BIT || ARCH_PHYS_ADDR_T_64BIT
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index a3a1815f8e11..80240bec2e11 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -55,7 +55,8 @@ unsigned long transparent_hugepage_flags __read_mostly =
 #endif
 	(1<<TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG)|
 	(1<<TRANSPARENT_HUGEPAGE_DEFRAG_KHUGEPAGED_FLAG)|
-	(1<<TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG);
+	(1<<TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG)|
+	(1<<TRANSPARENT_HUGEPAGE_MIGRATION_FLAG);
 
 static struct shrinker deferred_split_shrinker;
 
@@ -288,6 +289,21 @@ static ssize_t use_zero_page_store(struct kobject *kobj,
 static struct kobj_attribute use_zero_page_attr =
 	__ATTR(use_zero_page, 0644, use_zero_page_show, use_zero_page_store);
 
+static ssize_t thp_migration_show(struct kobject *kobj,
+		struct kobj_attribute *attr, char *buf)
+{
+	return single_hugepage_flag_show(kobj, attr, buf,
+				TRANSPARENT_HUGEPAGE_MIGRATION_FLAG);
+}
+static ssize_t thp_migration_store(struct kobject *kobj,
+		struct kobj_attribute *attr, const char *buf, size_t count)
+{
+	return single_hugepage_flag_store(kobj, attr, buf, count,
+				 TRANSPARENT_HUGEPAGE_MIGRATION_FLAG);
+}
+static struct kobj_attribute thp_migration_attr =
+	__ATTR(enable_thp_migration, 0644, thp_migration_show, thp_migration_store);
+
 static ssize_t hpage_pmd_size_show(struct kobject *kobj,
 		struct kobj_attribute *attr, char *buf)
 {
@@ -319,6 +335,7 @@ static struct attribute *hugepage_attr[] = {
 	&defrag_attr.attr,
 	&use_zero_page_attr.attr,
 	&hpage_pmd_size_attr.attr,
+	&thp_migration_attr.attr,
 #if defined(CONFIG_SHMEM) && defined(CONFIG_TRANSPARENT_HUGE_PAGECACHE)
 	&shmem_enabled_attr.attr,
 #endif
@@ -924,7 +941,6 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	ret = -EAGAIN;
 	pmd = *src_pmd;
 
-#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
 	if (unlikely(is_swap_pmd(pmd))) {
 		swp_entry_t entry = pmd_to_swp_entry(pmd);
 
@@ -943,7 +959,6 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		ret = 0;
 		goto out_unlock;
 	}
-#endif
 
 	if (unlikely(!pmd_trans_huge(pmd))) {
 		pte_free(dst_mm, pgtable);
@@ -1857,7 +1872,6 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 	preserve_write = prot_numa && pmd_write(*pmd);
 	ret = 1;
 
-#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
 	if (is_swap_pmd(*pmd)) {
 		swp_entry_t entry = pmd_to_swp_entry(*pmd);
 
@@ -1876,7 +1890,6 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 		}
 		goto unlock;
 	}
-#endif
 
 	/*
 	 * Avoid trapping faults against the zero page. The read-only
@@ -2128,7 +2141,6 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	 */
 	old_pmd = pmdp_invalidate(vma, haddr, pmd);
 
-#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
 	pmd_migration = is_pmd_migration_entry(old_pmd);
 	if (pmd_migration) {
 		swp_entry_t entry;
@@ -2136,7 +2148,6 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 		entry = pmd_to_swp_entry(old_pmd);
 		page = pfn_to_page(swp_offset(entry));
 	} else
-#endif
 		page = pmd_page(old_pmd);
 	VM_BUG_ON_PAGE(!page_count(page), page);
 	page_ref_add(page, HPAGE_PMD_NR - 1);
@@ -2870,7 +2881,6 @@ static int __init split_huge_pages_debugfs(void)
 late_initcall(split_huge_pages_debugfs);
 #endif
 
-#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
 void set_pmd_migration_entry(struct page_vma_mapped_walk *pvmw,
 		struct page *page)
 {
@@ -2934,4 +2944,3 @@ void remove_migration_pmd(struct page_vma_mapped_walk *pvmw, struct page *new)
 		mlock_vma_page(new);
 	update_mmu_cache_pmd(vma, address, pvmw->pmd);
 }
-#endif
diff --git a/mm/migrate.c b/mm/migrate.c
index 507cf9ba21bf..cb9c3af32614 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -220,14 +220,12 @@ static bool remove_migration_pte(struct page *page, struct vm_area_struct *vma,
 			new = page - pvmw.page->index +
 				linear_page_index(vma, pvmw.address);
 
-#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
 		/* PMD-mapped THP migration entry */
-		if (!pvmw.pte) {
+		if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) && !pvmw.pte) {
 			VM_BUG_ON_PAGE(PageHuge(page) || !PageTransCompound(page), page);
 			remove_migration_pmd(&pvmw, new);
 			continue;
 		}
-#endif
 
 		get_page(new);
 		pte = pte_mkold(mk_pte(new, READ_ONCE(vma->vm_page_prot)));
@@ -353,7 +351,7 @@ void migration_entry_wait_huge(struct vm_area_struct *vma,
 	__migration_entry_wait(mm, pte, ptl);
 }
 
-#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
 void pmd_migration_entry_wait(struct mm_struct *mm, pmd_t *pmd)
 {
 	spinlock_t *ptl;
diff --git a/mm/rmap.c b/mm/rmap.c
index 8d5337fed37b..f5434f4f3e06 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1369,15 +1369,14 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	mmu_notifier_invalidate_range_start(vma->vm_mm, start, end);
 
 	while (page_vma_mapped_walk(&pvmw)) {
-#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
 		/* PMD-mapped THP migration entry */
-		if (!pvmw.pte && (flags & TTU_MIGRATION)) {
+		if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) &&
+			!pvmw.pte && (flags & TTU_MIGRATION)) {
 			VM_BUG_ON_PAGE(PageHuge(page) || !PageTransCompound(page), page);
 
 			set_pmd_migration_entry(&pvmw, page);
 			continue;
 		}
-#endif
 
 		/*
 		 * If the page is mlock()d, we cannot swap it out.
-- 
2.17.0
