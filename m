Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 1AA9F6B0083
	for <linux-mm@kvack.org>; Sun, 28 Apr 2013 15:52:04 -0400 (EDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 29 Apr 2013 01:18:37 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id A719D394004F
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 01:21:59 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3SJptWf917796
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 01:21:55 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3SJpwvd002352
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 05:51:59 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V7 05/10] powerpc: Replace find_linux_pte with find_linux_pte_or_hugepte
Date: Mon, 29 Apr 2013 01:21:46 +0530
Message-Id: <1367178711-8232-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1367178711-8232-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1367178711-8232-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, dwg@au1.ibm.com, linux-mm@kvack.org
Cc: linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Replace find_linux_pte with find_linux_pte_or_hugepte and explicitly
document why we don't need to handle transparent hugepages at callsites.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/pgtable-ppc64.h | 24 ------------------------
 arch/powerpc/kernel/io-workarounds.c     | 10 ++++++++--
 arch/powerpc/kvm/book3s_hv_rm_mmu.c      |  2 +-
 arch/powerpc/mm/hash_utils_64.c          |  8 +++++++-
 arch/powerpc/mm/hugetlbpage.c            |  8 ++++++--
 arch/powerpc/mm/tlb_hash64.c             |  7 ++++++-
 arch/powerpc/platforms/pseries/eeh.c     |  7 ++++++-
 7 files changed, 34 insertions(+), 32 deletions(-)

diff --git a/arch/powerpc/include/asm/pgtable-ppc64.h b/arch/powerpc/include/asm/pgtable-ppc64.h
index f0effab..97fc839 100644
--- a/arch/powerpc/include/asm/pgtable-ppc64.h
+++ b/arch/powerpc/include/asm/pgtable-ppc64.h
@@ -343,30 +343,6 @@ static inline void __ptep_set_access_flags(pte_t *ptep, pte_t entry)
 
 void pgtable_cache_add(unsigned shift, void (*ctor)(void *));
 void pgtable_cache_init(void);
-
-/*
- * find_linux_pte returns the address of a linux pte for a given
- * effective address and directory.  If not found, it returns zero.
- */
-static inline pte_t *find_linux_pte(pgd_t *pgdir, unsigned long ea)
-{
-	pgd_t *pg;
-	pud_t *pu;
-	pmd_t *pm;
-	pte_t *pt = NULL;
-
-	pg = pgdir + pgd_index(ea);
-	if (!pgd_none(*pg)) {
-		pu = pud_offset(pg, ea);
-		if (!pud_none(*pu)) {
-			pm = pmd_offset(pu, ea);
-			if (pmd_present(*pm))
-				pt = pte_offset_kernel(pm, ea);
-		}
-	}
-	return pt;
-}
-
 pte_t *find_linux_pte_or_hugepte(pgd_t *pgdir, unsigned long ea,
 				 unsigned *shift);
 #endif /* __ASSEMBLY__ */
diff --git a/arch/powerpc/kernel/io-workarounds.c b/arch/powerpc/kernel/io-workarounds.c
index 50e90b7..e5263ab 100644
--- a/arch/powerpc/kernel/io-workarounds.c
+++ b/arch/powerpc/kernel/io-workarounds.c
@@ -55,6 +55,7 @@ static struct iowa_bus *iowa_pci_find(unsigned long vaddr, unsigned long paddr)
 
 struct iowa_bus *iowa_mem_find_bus(const PCI_IO_ADDR addr)
 {
+	unsigned shift;
 	struct iowa_bus *bus;
 	int token;
 
@@ -70,11 +71,16 @@ struct iowa_bus *iowa_mem_find_bus(const PCI_IO_ADDR addr)
 		if (vaddr < PHB_IO_BASE || vaddr >= PHB_IO_END)
 			return NULL;
 
-		ptep = find_linux_pte(init_mm.pgd, vaddr);
+		ptep = find_linux_pte_or_hugepte(init_mm.pgd, vaddr, &shift);
 		if (ptep == NULL)
 			paddr = 0;
-		else
+		else {
+			/*
+			 * we don't have hugepages backing iomem
+			 */
+			BUG_ON(shift);
 			paddr = pte_pfn(*ptep) << PAGE_SHIFT;
+		}
 		bus = iowa_pci_find(vaddr, paddr);
 
 		if (bus == NULL)
diff --git a/arch/powerpc/kvm/book3s_hv_rm_mmu.c b/arch/powerpc/kvm/book3s_hv_rm_mmu.c
index 19c93ba..8c345df 100644
--- a/arch/powerpc/kvm/book3s_hv_rm_mmu.c
+++ b/arch/powerpc/kvm/book3s_hv_rm_mmu.c
@@ -27,7 +27,7 @@ static void *real_vmalloc_addr(void *x)
 	unsigned long addr = (unsigned long) x;
 	pte_t *p;
 
-	p = find_linux_pte(swapper_pg_dir, addr);
+	p = find_linux_pte_or_hugepte(swapper_pg_dir, addr, NULL);
 	if (!p || !pte_present(*p))
 		return NULL;
 	/* assume we don't have huge pages in vmalloc space... */
diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
index d0eb6d4..e942ae9 100644
--- a/arch/powerpc/mm/hash_utils_64.c
+++ b/arch/powerpc/mm/hash_utils_64.c
@@ -1131,6 +1131,7 @@ EXPORT_SYMBOL_GPL(hash_page);
 void hash_preload(struct mm_struct *mm, unsigned long ea,
 		  unsigned long access, unsigned long trap)
 {
+	int shift;
 	unsigned long vsid;
 	pgd_t *pgdir;
 	pte_t *ptep;
@@ -1152,10 +1153,15 @@ void hash_preload(struct mm_struct *mm, unsigned long ea,
 	pgdir = mm->pgd;
 	if (pgdir == NULL)
 		return;
-	ptep = find_linux_pte(pgdir, ea);
+	/*
+	 * THP pages use update_mmu_cache_pmd. We don't do
+	 * hash preload there. Hence can ignore THP here
+	 */
+	ptep = find_linux_pte_or_hugepte(pgdir, ea, &shift);
 	if (!ptep)
 		return;
 
+	BUG_ON(shift);
 #ifdef CONFIG_PPC_64K_PAGES
 	/* If either _PAGE_4K_PFN or _PAGE_NO_CACHE is set (and we are on
 	 * a 64K kernel), then we don't preload, hash_page() will take
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index 081c001..1154714 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -105,6 +105,7 @@ int pgd_huge(pgd_t pgd)
 
 pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
 {
+	/* Only called for HugeTLB pages, hence can ignore THP */
 	return find_linux_pte_or_hugepte(mm->pgd, addr, NULL);
 }
 
@@ -673,11 +674,14 @@ follow_huge_addr(struct mm_struct *mm, unsigned long address, int write)
 	struct page *page;
 	unsigned shift;
 	unsigned long mask;
-
+	/*
+	 * Transparent hugepages are handled by generic code. We can skip them
+	 * here.
+	 */
 	ptep = find_linux_pte_or_hugepte(mm->pgd, address, &shift);
 
 	/* Verify it is a huge page else bail. */
-	if (!ptep || !shift)
+	if (!ptep || !shift || pmd_trans_huge((pmd_t)*ptep))
 		return ERR_PTR(-EINVAL);
 
 	mask = (1UL << shift) - 1;
diff --git a/arch/powerpc/mm/tlb_hash64.c b/arch/powerpc/mm/tlb_hash64.c
index 023ec8a..56d9b85 100644
--- a/arch/powerpc/mm/tlb_hash64.c
+++ b/arch/powerpc/mm/tlb_hash64.c
@@ -189,6 +189,7 @@ void tlb_flush(struct mmu_gather *tlb)
 void __flush_hash_table_range(struct mm_struct *mm, unsigned long start,
 			      unsigned long end)
 {
+	int shift;
 	unsigned long flags;
 
 	start = _ALIGN_DOWN(start, PAGE_SIZE);
@@ -206,11 +207,15 @@ void __flush_hash_table_range(struct mm_struct *mm, unsigned long start,
 	local_irq_save(flags);
 	arch_enter_lazy_mmu_mode();
 	for (; start < end; start += PAGE_SIZE) {
-		pte_t *ptep = find_linux_pte(mm->pgd, start);
+		pte_t *ptep = find_linux_pte_or_hugepte(mm->pgd, start, &shift);
 		unsigned long pte;
 
 		if (ptep == NULL)
 			continue;
+		/*
+		 * We won't find hugepages here, this is iomem.
+		 */
+		BUG_ON(shift);
 		pte = pte_val(*ptep);
 		if (!(pte & _PAGE_HASHPTE))
 			continue;
diff --git a/arch/powerpc/platforms/pseries/eeh.c b/arch/powerpc/platforms/pseries/eeh.c
index 6b73d6c..d2e76d2 100644
--- a/arch/powerpc/platforms/pseries/eeh.c
+++ b/arch/powerpc/platforms/pseries/eeh.c
@@ -258,12 +258,17 @@ void eeh_slot_error_detail(struct eeh_pe *pe, int severity)
  */
 static inline unsigned long eeh_token_to_phys(unsigned long token)
 {
+	int shift;
 	pte_t *ptep;
 	unsigned long pa;
 
-	ptep = find_linux_pte(init_mm.pgd, token);
+	/*
+	 * We won't find hugepages here, iomem
+	 */
+	ptep = find_linux_pte_or_hugepte(init_mm.pgd, token, &shift);
 	if (!ptep)
 		return token;
+	BUG_ON(shift);
 	pa = pte_pfn(*ptep) << PAGE_SHIFT;
 
 	return pa | (token & (PAGE_SIZE-1));
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
