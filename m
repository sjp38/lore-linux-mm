Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 8FB976B00A8
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 05:24:37 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 23/49] mm: mempolicy: Implement change_prot_numa() in terms of change_protection()
Date: Fri,  7 Dec 2012 10:23:26 +0000
Message-Id: <1354875832-9700-24-git-send-email-mgorman@suse.de>
In-Reply-To: <1354875832-9700-1-git-send-email-mgorman@suse.de>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This patch converts change_prot_numa() to use change_protection(). As
pte_numa and friends check the PTE bits directly it is necessary for
change_protection() to use pmd_mknuma(). Hence the required
modifications to change_protection() are a little clumsy but the
end result is that most of the numa page table helpers are just one or
two instructions.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/huge_mm.h |    3 +-
 include/linux/mm.h      |    4 +-
 mm/huge_memory.c        |   14 ++++-
 mm/mempolicy.c          |  137 +++++------------------------------------------
 mm/mprotect.c           |   72 +++++++++++++++++++------
 5 files changed, 85 insertions(+), 145 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index dabb510..027ad04 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -27,7 +27,8 @@ extern int move_huge_pmd(struct vm_area_struct *vma,
 			 unsigned long new_addr, unsigned long old_end,
 			 pmd_t *old_pmd, pmd_t *new_pmd);
 extern int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
-			unsigned long addr, pgprot_t newprot);
+			unsigned long addr, pgprot_t newprot,
+			int prot_numa);
 
 enum transparent_hugepage_flag {
 	TRANSPARENT_HUGEPAGE_FLAG,
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 471185e..d04c2f0 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1080,7 +1080,7 @@ extern unsigned long do_mremap(unsigned long addr,
 			       unsigned long flags, unsigned long new_addr);
 extern unsigned long change_protection(struct vm_area_struct *vma, unsigned long start,
 			      unsigned long end, pgprot_t newprot,
-			      int dirty_accountable);
+			      int dirty_accountable, int prot_numa);
 extern int mprotect_fixup(struct vm_area_struct *vma,
 			  struct vm_area_struct **pprev, unsigned long start,
 			  unsigned long end, unsigned long newflags);
@@ -1552,7 +1552,7 @@ static inline pgprot_t vm_get_page_prot(unsigned long vm_flags)
 #endif
 
 #ifdef CONFIG_ARCH_USES_NUMA_PROT_NONE
-void change_prot_numa(struct vm_area_struct *vma,
+unsigned long change_prot_numa(struct vm_area_struct *vma,
 			unsigned long start, unsigned long end);
 #endif
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index df1af09..68e0412 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1146,7 +1146,7 @@ out:
 }
 
 int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
-		unsigned long addr, pgprot_t newprot)
+		unsigned long addr, pgprot_t newprot, int prot_numa)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	int ret = 0;
@@ -1154,7 +1154,17 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 	if (__pmd_trans_huge_lock(pmd, vma) == 1) {
 		pmd_t entry;
 		entry = pmdp_get_and_clear(mm, addr, pmd);
-		entry = pmd_modify(entry, newprot);
+		if (!prot_numa)
+			entry = pmd_modify(entry, newprot);
+		else {
+			struct page *page = pmd_page(*pmd);
+
+			/* only check non-shared pages */
+			if (page_mapcount(page) == 1 &&
+			    !pmd_numa(*pmd)) {
+				entry = pmd_mknuma(entry);
+			}
+		}
 		set_pmd_at(mm, addr, pmd, entry);
 		spin_unlock(&vma->vm_mm->page_table_lock);
 		ret = 1;
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 51d3ebd..75d4600 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -568,134 +568,23 @@ static inline int check_pgd_range(struct vm_area_struct *vma,
 
 #ifdef CONFIG_ARCH_USES_NUMA_PROT_NONE
 /*
- * Here we search for not shared page mappings (mapcount == 1) and we
- * set up the pmd/pte_numa on those mappings so the very next access
- * will fire a NUMA hinting page fault.
+ * This is used to mark a range of virtual addresses to be inaccessible.
+ * These are later cleared by a NUMA hinting fault. Depending on these
+ * faults, pages may be migrated for better NUMA placement.
+ *
+ * This is assuming that NUMA faults are handled using PROT_NONE. If
+ * an architecture makes a different choice, it will need further
+ * changes to the core.
  */
-static int
-change_prot_numa_range(struct mm_struct *mm, struct vm_area_struct *vma,
-			unsigned long address)
-{
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
-	pte_t *pte, *_pte;
-	struct page *page;
-	unsigned long _address, end;
-	spinlock_t *ptl;
-	int ret = 0;
-
-	VM_BUG_ON(address & ~PAGE_MASK);
-
-	pgd = pgd_offset(mm, address);
-	if (!pgd_present(*pgd))
-		goto out;
-
-	pud = pud_offset(pgd, address);
-	if (!pud_present(*pud))
-		goto out;
-
-	pmd = pmd_offset(pud, address);
-	if (pmd_none(*pmd))
-		goto out;
-
-	if (pmd_trans_huge_lock(pmd, vma) == 1) {
-		int page_nid;
-		ret = HPAGE_PMD_NR;
-
-		VM_BUG_ON(address & ~HPAGE_PMD_MASK);
-
-		if (pmd_numa(*pmd)) {
-			spin_unlock(&mm->page_table_lock);
-			goto out;
-		}
-
-		page = pmd_page(*pmd);
-
-		/* only check non-shared pages */
-		if (page_mapcount(page) != 1) {
-			spin_unlock(&mm->page_table_lock);
-			goto out;
-		}
-
-		page_nid = page_to_nid(page);
-
-		if (pmd_numa(*pmd)) {
-			spin_unlock(&mm->page_table_lock);
-			goto out;
-		}
-
-		set_pmd_at(mm, address, pmd, pmd_mknuma(*pmd));
-		ret += HPAGE_PMD_NR;
-		/* defer TLB flush to lower the overhead */
-		spin_unlock(&mm->page_table_lock);
-		goto out;
-	}
-
-	if (pmd_trans_unstable(pmd))
-		goto out;
-	VM_BUG_ON(!pmd_present(*pmd));
-
-	end = min(vma->vm_end, (address + PMD_SIZE) & PMD_MASK);
-	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
-	for (_address = address, _pte = pte; _address < end;
-	     _pte++, _address += PAGE_SIZE) {
-		pte_t pteval = *_pte;
-		if (!pte_present(pteval))
-			continue;
-		if (pte_numa(pteval))
-			continue;
-		page = vm_normal_page(vma, _address, pteval);
-		if (unlikely(!page))
-			continue;
-		/* only check non-shared pages */
-		if (page_mapcount(page) != 1)
-			continue;
-
-		set_pte_at(mm, _address, _pte, pte_mknuma(pteval));
-
-		/* defer TLB flush to lower the overhead */
-		ret++;
-	}
-	pte_unmap_unlock(pte, ptl);
-
-	if (ret && !pmd_numa(*pmd)) {
-		spin_lock(&mm->page_table_lock);
-		set_pmd_at(mm, address, pmd, pmd_mknuma(*pmd));
-		spin_unlock(&mm->page_table_lock);
-		/* defer TLB flush to lower the overhead */
-	}
-
-out:
-	return ret;
-}
-
-/* Assumes mmap_sem is held */
-void
-change_prot_numa(struct vm_area_struct *vma,
-			unsigned long address, unsigned long end)
+unsigned long change_prot_numa(struct vm_area_struct *vma,
+			unsigned long addr, unsigned long end)
 {
-	struct mm_struct *mm = vma->vm_mm;
-	int progress = 0;
-
-	while (address < end) {
-		VM_BUG_ON(address < vma->vm_start ||
-			  address + PAGE_SIZE > vma->vm_end);
+	int nr_updated;
+	BUILD_BUG_ON(_PAGE_NUMA != _PAGE_PROTNONE);
 
-		progress += change_prot_numa_range(mm, vma, address);
-		address = (address + PMD_SIZE) & PMD_MASK;
-	}
+	nr_updated = change_protection(vma, addr, end, vma->vm_page_prot, 0, 1);
 
-	/*
-	 * Flush the TLB for the mm to start the NUMA hinting
-	 * page faults after we finish scanning this vma part
-	 * if there were any PTE updates
-	 */
-	if (progress) {
-		mmu_notifier_invalidate_range_start(vma->vm_mm, address, end);
-		flush_tlb_range(vma, address, end);
-		mmu_notifier_invalidate_range_end(vma->vm_mm, address, end);
-	}
+	return nr_updated;
 }
 #else
 static unsigned long change_prot_numa(struct vm_area_struct *vma,
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 7c3628a..8abf7c6 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -35,10 +35,11 @@ static inline pgprot_t pgprot_modify(pgprot_t oldprot, pgprot_t newprot)
 }
 #endif
 
-static unsigned long change_pte_range(struct mm_struct *mm, pmd_t *pmd,
+static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 		unsigned long addr, unsigned long end, pgprot_t newprot,
-		int dirty_accountable)
+		int dirty_accountable, int prot_numa)
 {
+	struct mm_struct *mm = vma->vm_mm;
 	pte_t *pte, oldpte;
 	spinlock_t *ptl;
 	unsigned long pages = 0;
@@ -49,19 +50,39 @@ static unsigned long change_pte_range(struct mm_struct *mm, pmd_t *pmd,
 		oldpte = *pte;
 		if (pte_present(oldpte)) {
 			pte_t ptent;
+			bool updated = false;
 
 			ptent = ptep_modify_prot_start(mm, addr, pte);
-			ptent = pte_modify(ptent, newprot);
+			if (!prot_numa) {
+				ptent = pte_modify(ptent, newprot);
+				updated = true;
+			} else {
+				struct page *page;
+
+				page = vm_normal_page(vma, addr, oldpte);
+				if (page) {
+					/* only check non-shared pages */
+					if (!pte_numa(oldpte) &&
+					    page_mapcount(page) == 1) {
+						ptent = pte_mknuma(ptent);
+						updated = true;
+					}
+				}
+			}
 
 			/*
 			 * Avoid taking write faults for pages we know to be
 			 * dirty.
 			 */
-			if (dirty_accountable && pte_dirty(ptent))
+			if (dirty_accountable && pte_dirty(ptent)) {
 				ptent = pte_mkwrite(ptent);
+				updated = true;
+			}
+
+			if (updated)
+				pages++;
 
 			ptep_modify_prot_commit(mm, addr, pte, ptent);
-			pages++;
 		} else if (IS_ENABLED(CONFIG_MIGRATION) && !pte_file(oldpte)) {
 			swp_entry_t entry = pte_to_swp_entry(oldpte);
 
@@ -83,9 +104,25 @@ static unsigned long change_pte_range(struct mm_struct *mm, pmd_t *pmd,
 	return pages;
 }
 
+#ifdef CONFIG_BALANCE_NUMA
+static inline void change_pmd_protnuma(struct mm_struct *mm, unsigned long addr,
+		pmd_t *pmd)
+{
+	spin_lock(&mm->page_table_lock);
+	set_pmd_at(mm, addr & PMD_MASK, pmd, pmd_mknuma(*pmd));
+	spin_unlock(&mm->page_table_lock);
+}
+#else
+static inline void change_pmd_protnuma(struct mm_struct *mm, unsigned long addr,
+		pmd_t *pmd)
+{
+	BUG();
+}
+#endif /* CONFIG_BALANCE_NUMA */
+
 static inline unsigned long change_pmd_range(struct vm_area_struct *vma, pud_t *pud,
 		unsigned long addr, unsigned long end, pgprot_t newprot,
-		int dirty_accountable)
+		int dirty_accountable, int prot_numa)
 {
 	pmd_t *pmd;
 	unsigned long next;
@@ -97,7 +134,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma, pud_t *
 		if (pmd_trans_huge(*pmd)) {
 			if (next - addr != HPAGE_PMD_SIZE)
 				split_huge_page_pmd(vma->vm_mm, pmd);
-			else if (change_huge_pmd(vma, pmd, addr, newprot)) {
+			else if (change_huge_pmd(vma, pmd, addr, newprot, prot_numa)) {
 				pages += HPAGE_PMD_NR;
 				continue;
 			}
@@ -105,8 +142,11 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma, pud_t *
 		}
 		if (pmd_none_or_clear_bad(pmd))
 			continue;
-		pages += change_pte_range(vma->vm_mm, pmd, addr, next, newprot,
-				 dirty_accountable);
+		pages += change_pte_range(vma, pmd, addr, next, newprot,
+				 dirty_accountable, prot_numa);
+
+		if (prot_numa)
+			change_pmd_protnuma(vma->vm_mm, addr, pmd);
 	} while (pmd++, addr = next, addr != end);
 
 	return pages;
@@ -114,7 +154,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma, pud_t *
 
 static inline unsigned long change_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
 		unsigned long addr, unsigned long end, pgprot_t newprot,
-		int dirty_accountable)
+		int dirty_accountable, int prot_numa)
 {
 	pud_t *pud;
 	unsigned long next;
@@ -126,7 +166,7 @@ static inline unsigned long change_pud_range(struct vm_area_struct *vma, pgd_t *
 		if (pud_none_or_clear_bad(pud))
 			continue;
 		pages += change_pmd_range(vma, pud, addr, next, newprot,
-				 dirty_accountable);
+				 dirty_accountable, prot_numa);
 	} while (pud++, addr = next, addr != end);
 
 	return pages;
@@ -134,7 +174,7 @@ static inline unsigned long change_pud_range(struct vm_area_struct *vma, pgd_t *
 
 static unsigned long change_protection_range(struct vm_area_struct *vma,
 		unsigned long addr, unsigned long end, pgprot_t newprot,
-		int dirty_accountable)
+		int dirty_accountable, int prot_numa)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pgd_t *pgd;
@@ -150,7 +190,7 @@ static unsigned long change_protection_range(struct vm_area_struct *vma,
 		if (pgd_none_or_clear_bad(pgd))
 			continue;
 		pages += change_pud_range(vma, pgd, addr, next, newprot,
-				 dirty_accountable);
+				 dirty_accountable, prot_numa);
 	} while (pgd++, addr = next, addr != end);
 
 	/* Only flush the TLB if we actually modified any entries: */
@@ -162,7 +202,7 @@ static unsigned long change_protection_range(struct vm_area_struct *vma,
 
 unsigned long change_protection(struct vm_area_struct *vma, unsigned long start,
 		       unsigned long end, pgprot_t newprot,
-		       int dirty_accountable)
+		       int dirty_accountable, int prot_numa)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long pages;
@@ -171,7 +211,7 @@ unsigned long change_protection(struct vm_area_struct *vma, unsigned long start,
 	if (is_vm_hugetlb_page(vma))
 		pages = hugetlb_change_protection(vma, start, end, newprot);
 	else
-		pages = change_protection_range(vma, start, end, newprot, dirty_accountable);
+		pages = change_protection_range(vma, start, end, newprot, dirty_accountable, prot_numa);
 	mmu_notifier_invalidate_range_end(mm, start, end);
 
 	return pages;
@@ -249,7 +289,7 @@ success:
 		dirty_accountable = 1;
 	}
 
-	change_protection(vma, start, end, vma->vm_page_prot, dirty_accountable);
+	change_protection(vma, start, end, vma->vm_page_prot, dirty_accountable, 0);
 
 	vm_stat_account(mm, oldflags, vma->vm_file, -nrpages);
 	vm_stat_account(mm, newflags, vma->vm_file, nrpages);
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
