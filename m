Message-Id: <20080525143454.559452000@nick.local0.net>
References: <20080525142317.965503000@nick.local0.net>
Date: Mon, 26 May 2008 00:23:40 +1000
From: npiggin@suse.de
Subject: [patch 23/23] powerpc: support multiple hugepage sizes
Content-Disposition: inline; filename=powerpc-support-multiple-hugepage-sizes.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: kniht@us.ibm.com, andi@firstfloor.org, nacc@us.ibm.com, agl@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, Jon Tollefson <kniht@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Instead of using the variable mmu_huge_psize to keep track of the huge
page size we use an array of MMU_PAGE_* values.  For each supported
huge page size we need to know the hugepte_shift value and have a
pgtable_cache.  The hstate or an mmu_huge_psizes index is passed to
functions so that they know which huge page size they should use.

The hugepage sizes 16M and 64K are setup(if available on the
hardware) so that they don't have to be set on the boot cmd line in
order to use them.  The number of 16G pages have to be specified at
boot-time though (e.g. hugepagesz=16G hugepages=5).

Signed-off-by: Jon Tollefson <kniht@linux.vnet.ibm.com>
Signed-off-by: Nick Piggin <npiggin@suse.de>
---

 arch/powerpc/mm/hash_utils_64.c  |    9 -
 arch/powerpc/mm/hugetlbpage.c    |  272 +++++++++++++++++++++++++--------------
 arch/powerpc/mm/init_64.c        |    8 -
 arch/powerpc/mm/tlb_64.c         |    2 
 include/asm-powerpc/hugetlb.h    |    5 
 include/asm-powerpc/mmu-hash64.h |    4 
 include/asm-powerpc/page_64.h    |    1 
 include/asm-powerpc/pgalloc-64.h |    4 
 8 files changed, 192 insertions(+), 113 deletions(-)


Index: linux-2.6/arch/powerpc/mm/hash_utils_64.c
===================================================================
--- linux-2.6.orig/arch/powerpc/mm/hash_utils_64.c
+++ linux-2.6/arch/powerpc/mm/hash_utils_64.c
@@ -103,7 +103,6 @@ int mmu_kernel_ssize = MMU_SEGSIZE_256M;
 int mmu_highuser_ssize = MMU_SEGSIZE_256M;
 u16 mmu_slb_size = 64;
 #ifdef CONFIG_HUGETLB_PAGE
-int mmu_huge_psize = MMU_PAGE_16M;
 unsigned int HPAGE_SHIFT;
 #endif
 #ifdef CONFIG_PPC_64K_PAGES
@@ -460,15 +459,15 @@ static void __init htab_init_page_sizes(
 	/* Reserve 16G huge page memory sections for huge pages */
 	of_scan_flat_dt(htab_dt_scan_hugepage_blocks, NULL);
 
-/* Init large page size. Currently, we pick 16M or 1M depending
+/* Set default large page size. Currently, we pick 16M or 1M depending
 	 * on what is available
 	 */
 	if (mmu_psize_defs[MMU_PAGE_16M].shift)
-		set_huge_psize(MMU_PAGE_16M);
+		HPAGE_SHIFT = mmu_psize_defs[MMU_PAGE_16M].shift;
 	/* With 4k/4level pagetables, we can't (for now) cope with a
 	 * huge page size < PMD_SIZE */
 	else if (mmu_psize_defs[MMU_PAGE_1M].shift)
-		set_huge_psize(MMU_PAGE_1M);
+		HPAGE_SHIFT = mmu_psize_defs[MMU_PAGE_1M].shift;
 #endif /* CONFIG_HUGETLB_PAGE */
 }
 
@@ -873,7 +872,7 @@ int hash_page(unsigned long ea, unsigned
 
 #ifdef CONFIG_HUGETLB_PAGE
 	/* Handle hugepage regions */
-	if (HPAGE_SHIFT && psize == mmu_huge_psize) {
+	if (HPAGE_SHIFT && mmu_huge_psizes[psize]) {
 		DBG_LOW(" -> huge page !\n");
 		return hash_huge_page(mm, access, ea, vsid, local, trap);
 	}
Index: linux-2.6/arch/powerpc/mm/hugetlbpage.c
===================================================================
--- linux-2.6.orig/arch/powerpc/mm/hugetlbpage.c
+++ linux-2.6/arch/powerpc/mm/hugetlbpage.c
@@ -37,15 +37,30 @@
 static unsigned long gpage_freearray[MAX_NUMBER_GPAGES];
 static unsigned nr_gpages;
 
-unsigned int hugepte_shift;
-#define PTRS_PER_HUGEPTE	(1 << hugepte_shift)
-#define HUGEPTE_TABLE_SIZE	(sizeof(pte_t) << hugepte_shift)
-
-#define HUGEPD_SHIFT		(HPAGE_SHIFT + hugepte_shift)
-#define HUGEPD_SIZE		(1UL << HUGEPD_SHIFT)
-#define HUGEPD_MASK		(~(HUGEPD_SIZE-1))
+/* Array of valid huge page sizes - non-zero value(hugepte_shift) is
+ * stored for the huge page sizes that are valid.
+ */
+unsigned int mmu_huge_psizes[MMU_PAGE_COUNT];
 
-#define huge_pgtable_cache	(pgtable_cache[HUGEPTE_CACHE_NUM])
+#define hugepte_shift			mmu_huge_psizes
+#define PTRS_PER_HUGEPTE(psize)		(1 << hugepte_shift[psize])
+#define HUGEPTE_TABLE_SIZE(psize)	(sizeof(pte_t) << hugepte_shift[psize])
+
+#define HUGEPD_SHIFT(psize)		(mmu_psize_to_shift(psize) \
+						+ hugepte_shift[psize])
+#define HUGEPD_SIZE(psize)		(1UL << HUGEPD_SHIFT(psize))
+#define HUGEPD_MASK(psize)		(~(HUGEPD_SIZE(psize)-1))
+
+/* Subtract one from array size because we don't need a cache for 4K since
+ * is not a huge page size */
+#define huge_pgtable_cache(psize)	(pgtable_cache[HUGEPTE_CACHE_NUM \
+							+ psize-1])
+#define HUGEPTE_CACHE_NAME(psize)	(huge_pgtable_cache_name[psize])
+
+static const char *huge_pgtable_cache_name[MMU_PAGE_COUNT] = {
+	"unused_4K", "hugepte_cache_64K", "unused_64K_AP",
+	"hugepte_cache_1M", "hugepte_cache_16M", "hugepte_cache_16G"
+};
 
 /* Flag to mark huge PD pointers.  This means pmd_bad() and pud_bad()
  * will choke on pointers to hugepte tables, which is handy for
@@ -56,24 +71,49 @@ typedef struct { unsigned long pd; } hug
 
 #define hugepd_none(hpd)	((hpd).pd == 0)
 
+static inline int shift_to_mmu_psize(unsigned int shift)
+{
+	switch (shift) {
+#ifndef CONFIG_PPC_64K_PAGES
+	case PAGE_SHIFT_64K:
+	    return MMU_PAGE_64K;
+#endif
+	case PAGE_SHIFT_16M:
+	    return MMU_PAGE_16M;
+	case PAGE_SHIFT_16G:
+	    return MMU_PAGE_16G;
+	}
+	return -1;
+}
+
+static inline unsigned int mmu_psize_to_shift(unsigned int mmu_psize)
+{
+	if (mmu_psize_defs[mmu_psize].shift)
+		return mmu_psize_defs[mmu_psize].shift;
+	BUG();
+}
+
 static inline pte_t *hugepd_page(hugepd_t hpd)
 {
 	BUG_ON(!(hpd.pd & HUGEPD_OK));
 	return (pte_t *)(hpd.pd & ~HUGEPD_OK);
 }
 
-static inline pte_t *hugepte_offset(hugepd_t *hpdp, unsigned long addr)
+static inline pte_t *hugepte_offset(hugepd_t *hpdp, unsigned long addr,
+				    struct hstate *hstate)
 {
-	unsigned long idx = ((addr >> HPAGE_SHIFT) & (PTRS_PER_HUGEPTE-1));
+	unsigned int shift = huge_page_shift(hstate);
+	int psize = shift_to_mmu_psize(shift);
+	unsigned long idx = ((addr >> shift) & (PTRS_PER_HUGEPTE(psize)-1));
 	pte_t *dir = hugepd_page(*hpdp);
 
 	return dir + idx;
 }
 
 static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
-			   unsigned long address)
+			   unsigned long address, unsigned int psize)
 {
-	pte_t *new = kmem_cache_alloc(huge_pgtable_cache,
+	pte_t *new = kmem_cache_alloc(huge_pgtable_cache(psize),
 				      GFP_KERNEL|__GFP_REPEAT);
 
 	if (! new)
@@ -81,7 +121,7 @@ static int __hugepte_alloc(struct mm_str
 
 	spin_lock(&mm->page_table_lock);
 	if (!hugepd_none(*hpdp))
-		kmem_cache_free(huge_pgtable_cache, new);
+		kmem_cache_free(huge_pgtable_cache(psize), new);
 	else
 		hpdp->pd = (unsigned long)new | HUGEPD_OK;
 	spin_unlock(&mm->page_table_lock);
@@ -90,21 +130,22 @@ static int __hugepte_alloc(struct mm_str
 
 /* Base page size affects how we walk hugetlb page tables */
 #ifdef CONFIG_PPC_64K_PAGES
-#define hpmd_offset(pud, addr)		pmd_offset(pud, addr)
-#define hpmd_alloc(mm, pud, addr)	pmd_alloc(mm, pud, addr)
+#define hpmd_offset(pud, addr, h)	pmd_offset(pud, addr)
+#define hpmd_alloc(mm, pud, addr, h)	pmd_alloc(mm, pud, addr)
 #else
 static inline
-pmd_t *hpmd_offset(pud_t *pud, unsigned long addr)
+pmd_t *hpmd_offset(pud_t *pud, unsigned long addr, struct hstate *hstate)
 {
-	if (HPAGE_SHIFT == PAGE_SHIFT_64K)
+	if (huge_page_shift(hstate) == PAGE_SHIFT_64K)
 		return pmd_offset(pud, addr);
 	else
 		return (pmd_t *) pud;
 }
 static inline
-pmd_t *hpmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long addr)
+pmd_t *hpmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long addr,
+		  struct hstate *hstate)
 {
-	if (HPAGE_SHIFT == PAGE_SHIFT_64K)
+	if (huge_page_shift(hstate) == PAGE_SHIFT_64K)
 		return pmd_alloc(mm, pud, addr);
 	else
 		return (pmd_t *) pud;
@@ -130,7 +171,7 @@ void add_gpage(unsigned long addr, unsig
 /* Moves the gigantic page addresses from the temporary list to the
   * huge_boot_pages list.
  */
-int alloc_bootmem_huge_page(struct hstate *h)
+int alloc_bootmem_huge_page(struct hstate *hstate)
 {
 	struct huge_bootmem_page *m;
 	if (nr_gpages == 0)
@@ -138,7 +179,7 @@ int alloc_bootmem_huge_page(struct hstat
 	m = phys_to_virt(gpage_freearray[--nr_gpages]);
 	gpage_freearray[nr_gpages] = 0;
 	list_add(&m->list, &huge_boot_pages);
-	m->hstate = h;
+	m->hstate = hstate;
 	return 1;
 }
 
@@ -150,17 +191,25 @@ pte_t *huge_pte_offset(struct mm_struct 
 	pud_t *pu;
 	pmd_t *pm;
 
-	BUG_ON(get_slice_psize(mm, addr) != mmu_huge_psize);
+	unsigned int psize;
+	unsigned int shift;
+	unsigned long sz;
+	struct hstate *hstate;
+	psize = get_slice_psize(mm, addr);
+	shift = mmu_psize_to_shift(psize);
+	sz = ((1UL) << shift);
+	hstate = size_to_hstate(sz);
 
-	addr &= HPAGE_MASK;
+	addr &= hstate->mask;
 
 	pg = pgd_offset(mm, addr);
 	if (!pgd_none(*pg)) {
 		pu = pud_offset(pg, addr);
 		if (!pud_none(*pu)) {
-			pm = hpmd_offset(pu, addr);
+			pm = hpmd_offset(pu, addr, hstate);
 			if (!pmd_none(*pm))
-				return hugepte_offset((hugepd_t *)pm, addr);
+				return hugepte_offset((hugepd_t *)pm, addr,
+						      hstate);
 		}
 	}
 
@@ -173,16 +222,20 @@ pte_t *huge_pte_alloc(struct mm_struct *
 	pud_t *pu;
 	pmd_t *pm;
 	hugepd_t *hpdp = NULL;
+	struct hstate *hstate;
+	unsigned int psize;
+	hstate = size_to_hstate(sz);
 
-	BUG_ON(get_slice_psize(mm, addr) != mmu_huge_psize);
+	psize = get_slice_psize(mm, addr);
+	BUG_ON(!mmu_huge_psizes[psize]);
 
-	addr &= HPAGE_MASK;
+	addr &= hstate->mask;
 
 	pg = pgd_offset(mm, addr);
 	pu = pud_alloc(mm, pg, addr);
 
 	if (pu) {
-		pm = hpmd_alloc(mm, pu, addr);
+		pm = hpmd_alloc(mm, pu, addr, hstate);
 		if (pm)
 			hpdp = (hugepd_t *)pm;
 	}
@@ -190,10 +243,10 @@ pte_t *huge_pte_alloc(struct mm_struct *
 	if (! hpdp)
 		return NULL;
 
-	if (hugepd_none(*hpdp) && __hugepte_alloc(mm, hpdp, addr))
+	if (hugepd_none(*hpdp) && __hugepte_alloc(mm, hpdp, addr, psize))
 		return NULL;
 
-	return hugepte_offset(hpdp, addr);
+	return hugepte_offset(hpdp, addr, hstate);
 }
 
 int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
@@ -201,19 +254,22 @@ int huge_pmd_unshare(struct mm_struct *m
 	return 0;
 }
 
-static void free_hugepte_range(struct mmu_gather *tlb, hugepd_t *hpdp)
+static void free_hugepte_range(struct mmu_gather *tlb, hugepd_t *hpdp,
+			       unsigned int psize)
 {
 	pte_t *hugepte = hugepd_page(*hpdp);
 
 	hpdp->pd = 0;
 	tlb->need_flush = 1;
-	pgtable_free_tlb(tlb, pgtable_free_cache(hugepte, HUGEPTE_CACHE_NUM,
+	pgtable_free_tlb(tlb, pgtable_free_cache(hugepte,
+						 HUGEPTE_CACHE_NUM+psize-1,
 						 PGF_CACHENUM_MASK));
 }
 
 static void hugetlb_free_pmd_range(struct mmu_gather *tlb, pud_t *pud,
 				   unsigned long addr, unsigned long end,
-				   unsigned long floor, unsigned long ceiling)
+				   unsigned long floor, unsigned long ceiling,
+				   unsigned int psize)
 {
 	pmd_t *pmd;
 	unsigned long next;
@@ -225,7 +281,7 @@ static void hugetlb_free_pmd_range(struc
 		next = pmd_addr_end(addr, end);
 		if (pmd_none(*pmd))
 			continue;
-		free_hugepte_range(tlb, (hugepd_t *)pmd);
+		free_hugepte_range(tlb, (hugepd_t *)pmd, psize);
 	} while (pmd++, addr = next, addr != end);
 
 	start &= PUD_MASK;
@@ -251,6 +307,9 @@ static void hugetlb_free_pud_range(struc
 	pud_t *pud;
 	unsigned long next;
 	unsigned long start;
+	unsigned int shift;
+	unsigned int psize = get_slice_psize(tlb->mm, addr);
+	shift = mmu_psize_to_shift(psize);
 
 	start = addr;
 	pud = pud_offset(pgd, addr);
@@ -259,16 +318,18 @@ static void hugetlb_free_pud_range(struc
 #ifdef CONFIG_PPC_64K_PAGES
 		if (pud_none_or_clear_bad(pud))
 			continue;
-		hugetlb_free_pmd_range(tlb, pud, addr, next, floor, ceiling);
+		hugetlb_free_pmd_range(tlb, pud, addr, next, floor, ceiling,
+				       psize);
 #else
-		if (HPAGE_SHIFT == PAGE_SHIFT_64K) {
+		if (shift == PAGE_SHIFT_64K) {
 			if (pud_none_or_clear_bad(pud))
 				continue;
-			hugetlb_free_pmd_range(tlb, pud, addr, next, floor, ceiling);
+			hugetlb_free_pmd_range(tlb, pud, addr, next, floor,
+					       ceiling, psize);
 		} else {
 			if (pud_none(*pud))
 				continue;
-			free_hugepte_range(tlb, (hugepd_t *)pud);
+			free_hugepte_range(tlb, (hugepd_t *)pud, psize);
 		}
 #endif
 	} while (pud++, addr = next, addr != end);
@@ -336,27 +397,29 @@ void hugetlb_free_pgd_range(struct mmu_g
 	 * now has no other vmas using it, so can be freed, we don't
 	 * bother to round floor or end up - the tests don't need that.
 	 */
+	unsigned int psize = get_slice_psize((*tlb)->mm, addr);
 
-	addr &= HUGEPD_MASK;
+	addr &= HUGEPD_MASK(psize);
 	if (addr < floor) {
-		addr += HUGEPD_SIZE;
+		addr += HUGEPD_SIZE(psize);
 		if (!addr)
 			return;
 	}
 	if (ceiling) {
-		ceiling &= HUGEPD_MASK;
+		ceiling &= HUGEPD_MASK(psize);
 		if (!ceiling)
 			return;
 	}
 	if (end - 1 > ceiling - 1)
-		end -= HUGEPD_SIZE;
+		end -= HUGEPD_SIZE(psize);
 	if (addr > end - 1)
 		return;
 
 	start = addr;
 	pgd = pgd_offset((*tlb)->mm, addr);
 	do {
-		BUG_ON(get_slice_psize((*tlb)->mm, addr) != mmu_huge_psize);
+		psize = get_slice_psize((*tlb)->mm, addr);
+		BUG_ON(!mmu_huge_psizes[psize]);
 		next = pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(pgd))
 			continue;
@@ -373,7 +436,11 @@ void set_huge_pte_at(struct mm_struct *m
 		 * necessary anymore if we make hpte_need_flush() get the
 		 * page size from the slices
 		 */
-		pte_update(mm, addr & HPAGE_MASK, ptep, ~0UL, 1);
+		unsigned int psize = get_slice_psize(mm, addr);
+		unsigned int shift = mmu_psize_to_shift(psize);
+		unsigned long sz = ((1UL) << shift);
+		struct hstate *hstate = size_to_hstate(sz);
+		pte_update(mm, addr & hstate->mask, ptep, ~0UL, 1);
 	}
 	*ptep = __pte(pte_val(pte) & ~_PAGE_HPTEFLAGS);
 }
@@ -390,14 +457,19 @@ follow_huge_addr(struct mm_struct *mm, u
 {
 	pte_t *ptep;
 	struct page *page;
+	unsigned int mmu_psize = get_slice_psize(mm, address);
 
-	if (get_slice_psize(mm, address) != mmu_huge_psize)
+	/* Verify it is a huge page else bail. */
+	if (!mmu_huge_psizes[mmu_psize])
 		return ERR_PTR(-EINVAL);
 
 	ptep = huge_pte_offset(mm, address);
 	page = pte_page(*ptep);
-	if (page)
-		page += (address % HPAGE_SIZE) / PAGE_SIZE;
+	if (page) {
+		unsigned int shift = mmu_psize_to_shift(mmu_psize);
+		unsigned long sz = ((1UL) << shift);
+		page += (address % sz) / PAGE_SIZE;
+	}
 
 	return page;
 }
@@ -425,15 +497,16 @@ unsigned long hugetlb_get_unmapped_area(
 					unsigned long len, unsigned long pgoff,
 					unsigned long flags)
 {
-	return slice_get_unmapped_area(addr, len, flags,
-				       mmu_huge_psize, 1, 0);
+	struct hstate *hstate = hstate_file(file);
+	int mmu_psize = shift_to_mmu_psize(huge_page_shift(hstate));
+	return slice_get_unmapped_area(addr, len, flags, mmu_psize, 1, 0);
 }
 
 /*
  * Called by asm hashtable.S for doing lazy icache flush
  */
 static unsigned int hash_huge_page_do_lazy_icache(unsigned long rflags,
-						  pte_t pte, int trap)
+					pte_t pte, int trap, unsigned long sz)
 {
 	struct page *page;
 	int i;
@@ -446,7 +519,7 @@ static unsigned int hash_huge_page_do_la
 	/* page is dirty */
 	if (!test_bit(PG_arch_1, &page->flags) && !PageReserved(page)) {
 		if (trap == 0x400) {
-			for (i = 0; i < (HPAGE_SIZE / PAGE_SIZE); i++)
+			for (i = 0; i < (sz / PAGE_SIZE); i++)
 				__flush_dcache_icache(page_address(page+i));
 			set_bit(PG_arch_1, &page->flags);
 		} else {
@@ -462,11 +535,16 @@ int hash_huge_page(struct mm_struct *mm,
 {
 	pte_t *ptep;
 	unsigned long old_pte, new_pte;
-	unsigned long va, rflags, pa;
+	unsigned long va, rflags, pa, sz;
 	long slot;
 	int err = 1;
 	int ssize = user_segment_size(ea);
+	unsigned int mmu_psize;
+	int shift;
+	mmu_psize = get_slice_psize(mm, ea);
 
+	if(!mmu_huge_psizes[mmu_psize])
+		goto out;
 	ptep = huge_pte_offset(mm, ea);
 
 	/* Search the Linux page table for a match with va */
@@ -510,30 +588,32 @@ int hash_huge_page(struct mm_struct *mm,
 	rflags = 0x2 | (!(new_pte & _PAGE_RW));
  	/* _PAGE_EXEC -> HW_NO_EXEC since it's inverted */
 	rflags |= ((new_pte & _PAGE_EXEC) ? 0 : HPTE_R_N);
+	shift = mmu_psize_to_shift(mmu_psize);
+	sz = ((1UL) << shift);
 	if (!cpu_has_feature(CPU_FTR_COHERENT_ICACHE))
 		/* No CPU has hugepages but lacks no execute, so we
 		 * don't need to worry about that case */
 		rflags = hash_huge_page_do_lazy_icache(rflags, __pte(old_pte),
-						       trap);
+						       trap, sz);
 
 	/* Check if pte already has an hpte (case 2) */
 	if (unlikely(old_pte & _PAGE_HASHPTE)) {
 		/* There MIGHT be an HPTE for this pte */
 		unsigned long hash, slot;
 
-		hash = hpt_hash(va, HPAGE_SHIFT, ssize);
+		hash = hpt_hash(va, shift, ssize);
 		if (old_pte & _PAGE_F_SECOND)
 			hash = ~hash;
 		slot = (hash & htab_hash_mask) * HPTES_PER_GROUP;
 		slot += (old_pte & _PAGE_F_GIX) >> 12;
 
-		if (ppc_md.hpte_updatepp(slot, rflags, va, mmu_huge_psize,
+		if (ppc_md.hpte_updatepp(slot, rflags, va, mmu_psize,
 					 ssize, local) == -1)
 			old_pte &= ~_PAGE_HPTEFLAGS;
 	}
 
 	if (likely(!(old_pte & _PAGE_HASHPTE))) {
-		unsigned long hash = hpt_hash(va, HPAGE_SHIFT, ssize);
+		unsigned long hash = hpt_hash(va, shift, ssize);
 		unsigned long hpte_group;
 
 		pa = pte_pfn(__pte(old_pte)) << PAGE_SHIFT;
@@ -552,7 +632,7 @@ repeat:
 
 		/* Insert into the hash table, primary slot */
 		slot = ppc_md.hpte_insert(hpte_group, va, pa, rflags, 0,
-					  mmu_huge_psize, ssize);
+					  mmu_psize, ssize);
 
 		/* Primary is full, try the secondary */
 		if (unlikely(slot == -1)) {
@@ -560,7 +640,7 @@ repeat:
 				      HPTES_PER_GROUP) & ~0x7UL; 
 			slot = ppc_md.hpte_insert(hpte_group, va, pa, rflags,
 						  HPTE_V_SECONDARY,
-						  mmu_huge_psize, ssize);
+						  mmu_psize, ssize);
 			if (slot == -1) {
 				if (mftb() & 0x1)
 					hpte_group = ((hash & htab_hash_mask) *
@@ -597,66 +677,50 @@ void set_huge_psize(int psize)
 		(mmu_psize_defs[psize].shift > MIN_HUGEPTE_SHIFT ||
 		 mmu_psize_defs[psize].shift == PAGE_SHIFT_64K ||
 		 mmu_psize_defs[psize].shift == PAGE_SHIFT_16G)) {
-		/* Return if huge page size is the same as the
-		 * base page size. */
-		if (mmu_psize_defs[psize].shift == PAGE_SHIFT)
+		/* Return if huge page size has already been setup or is the
+		 * same as the base page size. */
+		if (mmu_huge_psizes[psize] ||
+		   mmu_psize_defs[psize].shift == PAGE_SHIFT)
 			return;
+		hugetlb_add_hstate(mmu_psize_defs[psize].shift - PAGE_SHIFT);
 
-		HPAGE_SHIFT = mmu_psize_defs[psize].shift;
-		mmu_huge_psize = psize;
-
-		switch (HPAGE_SHIFT) {
+		switch (mmu_psize_defs[psize].shift) {
 		case PAGE_SHIFT_64K:
 		    /* We only allow 64k hpages with 4k base page,
 		     * which was checked above, and always put them
 		     * at the PMD */
-		    hugepte_shift = PMD_SHIFT;
+		    hugepte_shift[psize] = PMD_SHIFT;
 		    break;
 		case PAGE_SHIFT_16M:
 		    /* 16M pages can be at two different levels
 		     * of pagestables based on base page size */
 		    if (PAGE_SHIFT == PAGE_SHIFT_64K)
-			    hugepte_shift = PMD_SHIFT;
+			    hugepte_shift[psize] = PMD_SHIFT;
 		    else /* 4k base page */
-			    hugepte_shift = PUD_SHIFT;
+			    hugepte_shift[psize] = PUD_SHIFT;
 		    break;
 		case PAGE_SHIFT_16G:
 		    /* 16G pages are always at PGD level */
-		    hugepte_shift = PGDIR_SHIFT;
+		    hugepte_shift[psize] = PGDIR_SHIFT;
 		    break;
 		}
-		hugepte_shift -= HPAGE_SHIFT;
+		hugepte_shift[psize] -= mmu_psize_defs[psize].shift;
 	} else
-		HPAGE_SHIFT = 0;
+		hugepte_shift[psize] = 0;
 }
 
 static int __init hugepage_setup_sz(char *str)
 {
 	unsigned long long size;
-	int mmu_psize = -1;
+	int mmu_psize;
 	int shift;
 
 	size = memparse(str, &str);
 
 	shift = __ffs(size);
-	switch (shift) {
-#ifndef CONFIG_PPC_64K_PAGES
-	case PAGE_SHIFT_64K:
-		mmu_psize = MMU_PAGE_64K;
-		break;
-#endif
-	case PAGE_SHIFT_16M:
-		mmu_psize = MMU_PAGE_16M;
-		break;
-	case PAGE_SHIFT_16G:
-		mmu_psize = MMU_PAGE_16G;
-		break;
-	}
-
-	if (mmu_psize >= 0 && mmu_psize_defs[mmu_psize].shift) {
+	mmu_psize = shift_to_mmu_psize(shift);
+	if (mmu_psize >= 0 && mmu_psize_defs[mmu_psize].shift)
 		set_huge_psize(mmu_psize);
-		hugetlb_add_hstate(shift - PAGE_SHIFT);
-	}
 	else
 		printk(KERN_WARNING "Invalid huge page size specified(%llu)\n", size);
 
@@ -671,16 +735,30 @@ static void zero_ctor(struct kmem_cache 
 
 static int __init hugetlbpage_init(void)
 {
+	unsigned int psize;
 	if (!cpu_has_feature(CPU_FTR_16M_PAGE))
 		return -ENODEV;
-
-	huge_pgtable_cache = kmem_cache_create("hugepte_cache",
-					       HUGEPTE_TABLE_SIZE,
-					       HUGEPTE_TABLE_SIZE,
-					       0,
-					       zero_ctor);
-	if (! huge_pgtable_cache)
-		panic("hugetlbpage_init(): could not create hugepte cache\n");
+	/* Add supported huge page sizes.  Need to change HUGE_MAX_HSTATE
+	 * and adjust PTE_NONCACHE_NUM if the number of supported huge page
+	 * sizes changes.
+	 */
+	set_huge_psize(MMU_PAGE_16M);
+	set_huge_psize(MMU_PAGE_64K);
+	set_huge_psize(MMU_PAGE_16G);
+
+	for (psize = 0; psize < MMU_PAGE_COUNT; ++psize) {
+		if (mmu_huge_psizes[psize]) {
+			huge_pgtable_cache(psize) = kmem_cache_create(
+						HUGEPTE_CACHE_NAME(psize),
+						HUGEPTE_TABLE_SIZE(psize),
+						HUGEPTE_TABLE_SIZE(psize),
+						0,
+						zero_ctor);
+			if (!huge_pgtable_cache(psize))
+				panic("hugetlbpage_init(): could not create %s"\
+				      "\n", HUGEPTE_CACHE_NAME(psize));
+		}
+	}
 
 	return 0;
 }
Index: linux-2.6/arch/powerpc/mm/init_64.c
===================================================================
--- linux-2.6.orig/arch/powerpc/mm/init_64.c
+++ linux-2.6/arch/powerpc/mm/init_64.c
@@ -153,10 +153,10 @@ static const char *pgtable_cache_name[AR
 };
 
 #ifdef CONFIG_HUGETLB_PAGE
-/* Hugepages need one extra cache, initialized in hugetlbpage.c.  We
- * can't put into the tables above, because HPAGE_SHIFT is not compile
- * time constant. */
-struct kmem_cache *pgtable_cache[ARRAY_SIZE(pgtable_cache_size)+1];
+/* Hugepages need an extra cache per hugepagesize, initialized in
+ * hugetlbpage.c.  We can't put into the tables above, because HPAGE_SHIFT
+ * is not compile time constant. */
+struct kmem_cache *pgtable_cache[ARRAY_SIZE(pgtable_cache_size)+MMU_PAGE_COUNT];
 #else
 struct kmem_cache *pgtable_cache[ARRAY_SIZE(pgtable_cache_size)];
 #endif
Index: linux-2.6/arch/powerpc/mm/tlb_64.c
===================================================================
--- linux-2.6.orig/arch/powerpc/mm/tlb_64.c
+++ linux-2.6/arch/powerpc/mm/tlb_64.c
@@ -150,7 +150,7 @@ void hpte_need_flush(struct mm_struct *m
 	 */
 	if (huge) {
 #ifdef CONFIG_HUGETLB_PAGE
-		psize = mmu_huge_psize;
+		psize = get_slice_psize(mm, addr);;
 #else
 		BUG();
 		psize = pte_pagesize_index(mm, addr, pte); /* shutup gcc */
Index: linux-2.6/include/asm-powerpc/mmu-hash64.h
===================================================================
--- linux-2.6.orig/include/asm-powerpc/mmu-hash64.h
+++ linux-2.6/include/asm-powerpc/mmu-hash64.h
@@ -193,9 +193,9 @@ extern int mmu_ci_restrictions;
 
 #ifdef CONFIG_HUGETLB_PAGE
 /*
- * The page size index of the huge pages for use by hugetlbfs
+ * The page size indexes of the huge pages for use by hugetlbfs
  */
-extern int mmu_huge_psize;
+extern unsigned int mmu_huge_psizes[MMU_PAGE_COUNT];
 
 #endif /* CONFIG_HUGETLB_PAGE */
 
Index: linux-2.6/include/asm-powerpc/page_64.h
===================================================================
--- linux-2.6.orig/include/asm-powerpc/page_64.h
+++ linux-2.6/include/asm-powerpc/page_64.h
@@ -90,6 +90,7 @@ extern unsigned int HPAGE_SHIFT;
 #define HPAGE_SIZE		((1UL) << HPAGE_SHIFT)
 #define HPAGE_MASK		(~(HPAGE_SIZE - 1))
 #define HUGETLB_PAGE_ORDER	(HPAGE_SHIFT - PAGE_SHIFT)
+#define HUGE_MAX_HSTATE		3
 
 #endif /* __ASSEMBLY__ */
 
Index: linux-2.6/include/asm-powerpc/pgalloc-64.h
===================================================================
--- linux-2.6.orig/include/asm-powerpc/pgalloc-64.h
+++ linux-2.6/include/asm-powerpc/pgalloc-64.h
@@ -22,7 +22,7 @@ extern struct kmem_cache *pgtable_cache[
 #define PUD_CACHE_NUM		1
 #define PMD_CACHE_NUM		1
 #define HUGEPTE_CACHE_NUM	2
-#define PTE_NONCACHE_NUM	3  /* from GFP rather than kmem_cache */
+#define PTE_NONCACHE_NUM	7  /* from GFP rather than kmem_cache */
 
 static inline pgd_t *pgd_alloc(struct mm_struct *mm)
 {
@@ -119,7 +119,7 @@ static inline void pte_free(struct mm_st
 	__free_page(ptepage);
 }
 
-#define PGF_CACHENUM_MASK	0x3
+#define PGF_CACHENUM_MASK	0x7
 
 typedef struct pgtable_free {
 	unsigned long val;
Index: linux-2.6/include/asm-powerpc/hugetlb.h
===================================================================
--- linux-2.6.orig/include/asm-powerpc/hugetlb.h
+++ linux-2.6/include/asm-powerpc/hugetlb.h
@@ -23,9 +23,10 @@ pte_t huge_ptep_get_and_clear(struct mm_
  */
 static inline int prepare_hugepage_range(struct file *file, unsigned long addr, unsigned long len)
 {
-	if (len & ~HPAGE_MASK)
+	struct hstate *h = hstate_file(file);
+	if (len & ~huge_page_mask(h))
 		return -EINVAL;
-	if (addr & ~HPAGE_MASK)
+	if (addr & ~huge_page_mask(h))
 		return -EINVAL;
 	return 0;
 }

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
