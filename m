Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 2DF9D6B0073
	for <linux-mm@kvack.org>; Thu,  4 Dec 2014 06:24:44 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id r20so35874561wiv.2
        for <linux-mm@kvack.org>; Thu, 04 Dec 2014 03:24:43 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j9si44351351wjq.47.2014.12.04.03.24.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 04 Dec 2014 03:24:43 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 05/10] mm: Convert p[te|md]_mknonnuma and remaining page table manipulations
Date: Thu,  4 Dec 2014 11:24:28 +0000
Message-Id: <1417692273-27170-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1417692273-27170-1-git-send-email-mgorman@suse.de>
References: <1417692273-27170-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@redhat.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LinuxPPC-dev <linuxppc-dev@lists.ozlabs.org>, Mel Gorman <mgorman@suse.de>

With PROT_NONE, the traditional page table manipulation functions are
sufficient.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Linus Torvalds <torvalds@linux-foundation.org>
Acked-by: Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>
Tested-by: Sasha Levin <sasha.levin@oracle.com>
---
 include/linux/huge_mm.h |  3 +--
 mm/huge_memory.c        | 33 +++++++--------------------------
 mm/memory.c             | 10 ++++++----
 mm/mempolicy.c          |  2 +-
 mm/migrate.c            |  2 +-
 mm/mprotect.c           |  2 +-
 mm/pgtable-generic.c    |  2 --
 7 files changed, 17 insertions(+), 37 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index ad9051b..554bbe3 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -31,8 +31,7 @@ extern int move_huge_pmd(struct vm_area_struct *vma,
 			 unsigned long new_addr, unsigned long old_end,
 			 pmd_t *old_pmd, pmd_t *new_pmd);
 extern int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
-			unsigned long addr, pgprot_t newprot,
-			int prot_numa);
+			unsigned long addr, pgprot_t newprot);
 
 enum transparent_hugepage_flag {
 	TRANSPARENT_HUGEPAGE_FLAG,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index f81fddf..5618e22 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1366,9 +1366,8 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	goto out;
 clear_pmdnuma:
 	BUG_ON(!PageLocked(page));
-	pmd = pmd_mknonnuma(pmd);
+	pmd = pmd_modify(pmd, vma->vm_page_prot);
 	set_pmd_at(mm, haddr, pmdp, pmd);
-	VM_BUG_ON(pmd_protnone(*pmdp));
 	update_mmu_cache_pmd(vma, addr, pmdp);
 	unlock_page(page);
 out_unlock:
@@ -1503,7 +1502,7 @@ out:
  *  - HPAGE_PMD_NR is protections changed and TLB flush necessary
  */
 int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
-		unsigned long addr, pgprot_t newprot, int prot_numa)
+		unsigned long addr, pgprot_t newprot)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	spinlock_t *ptl;
@@ -1512,29 +1511,11 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 	if (__pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
 		pmd_t entry;
 		ret = 1;
-		if (!prot_numa) {
-			entry = pmdp_get_and_clear_notify(mm, addr, pmd);
-			if (pmd_protnone(entry))
-				entry = pmd_mknonnuma(entry);
-			entry = pmd_modify(entry, newprot);
-			ret = HPAGE_PMD_NR;
-			set_pmd_at(mm, addr, pmd, entry);
-			BUG_ON(pmd_write(entry));
-		} else {
-			struct page *page = pmd_page(*pmd);
-
-			/*
-			 * Do not trap faults against the zero page. The
-			 * read-only data is likely to be read-cached on the
-			 * local CPU cache and it is less useful to know about
-			 * local vs remote hits on the zero page.
-			 */
-			if (!is_huge_zero_page(page) &&
-			    !pmd_protnone(*pmd)) {
-				pmdp_set_numa(mm, addr, pmd);
-				ret = HPAGE_PMD_NR;
-			}
-		}
+		entry = pmdp_get_and_clear_notify(mm, addr, pmd);
+		entry = pmd_modify(entry, newprot);
+		ret = HPAGE_PMD_NR;
+		set_pmd_at(mm, addr, pmd, entry);
+		BUG_ON(pmd_write(entry));
 		spin_unlock(ptl);
 	}
 
diff --git a/mm/memory.c b/mm/memory.c
index eaa46f1..2100e0f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3114,9 +3114,9 @@ static int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	* validation through pte_unmap_same(). It's of NUMA type but
 	* the pfn may be screwed if the read is non atomic.
 	*
-	* ptep_modify_prot_start is not called as this is clearing
-	* the _PAGE_NUMA bit and it is not really expected that there
-	* would be concurrent hardware modifications to the PTE.
+	* We can safely just do a "set_pte_at()", because the old
+	* page table entry is not accessible, so there would be no
+	* concurrent hardware modifications to the PTE.
 	*/
 	ptl = pte_lockptr(mm, pmd);
 	spin_lock(ptl);
@@ -3125,7 +3125,9 @@ static int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		goto out;
 	}
 
-	pte = pte_mknonnuma(pte);
+	/* Make it present again */
+	pte = pte_modify(pte, vma->vm_page_prot);
+	pte = pte_mkyoung(pte);
 	set_pte_at(mm, addr, ptep, pte);
 	update_mmu_cache(vma, addr, ptep);
 
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index f22c559..530a0da 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -627,7 +627,7 @@ unsigned long change_prot_numa(struct vm_area_struct *vma,
 {
 	int nr_updated;
 
-	nr_updated = change_protection(vma, addr, end, vma->vm_page_prot, 0, 1);
+	nr_updated = change_protection(vma, addr, end, PAGE_NONE, 0, 1);
 	if (nr_updated)
 		count_vm_numa_events(NUMA_PTE_UPDATES, nr_updated);
 
diff --git a/mm/migrate.c b/mm/migrate.c
index 11d86b4..51ce492 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1891,7 +1891,7 @@ out_fail:
 out_dropref:
 	ptl = pmd_lock(mm, pmd);
 	if (pmd_same(*pmd, entry)) {
-		entry = pmd_mknonnuma(entry);
+		entry = pmd_modify(entry, vma->vm_page_prot);
 		set_pmd_at(mm, mmun_start, pmd, entry);
 		update_mmu_cache_pmd(vma, address, &entry);
 	}
diff --git a/mm/mprotect.c b/mm/mprotect.c
index e93ddac..dc65c0f 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -141,7 +141,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 				split_huge_page_pmd(vma, addr, pmd);
 			else {
 				int nr_ptes = change_huge_pmd(vma, pmd, addr,
-						newprot, prot_numa);
+						newprot);
 
 				if (nr_ptes) {
 					if (nr_ptes == HPAGE_PMD_NR) {
diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index 4b8ad76..c25f94b 100644
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -193,8 +193,6 @@ void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
 		     pmd_t *pmdp)
 {
 	pmd_t entry = *pmdp;
-	if (pmd_protnone(entry))
-		entry = pmd_mknonnuma(entry);
 	set_pmd_at(vma->vm_mm, address, pmdp, pmd_mknotpresent(entry));
 	flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
 }
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
