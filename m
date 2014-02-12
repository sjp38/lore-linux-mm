Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 592186B0036
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 22:43:58 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id gq1so9906025obb.35
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 19:43:58 -0800 (PST)
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com. [122.248.162.9])
        by mx.google.com with ESMTPS id tb9si11008847obc.17.2014.02.11.19.43.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Feb 2014 19:43:56 -0800 (PST)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 12 Feb 2014 09:13:53 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 3C0BFE005D
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 09:17:10 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1C3hrrO8257804
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 09:13:53 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1C3hobu020090
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 09:13:50 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V2 3/3] mm: Use ptep/pmdp_set_numa for updating _PAGE_NUMA bit
Date: Wed, 12 Feb 2014 09:13:38 +0530
Message-Id: <1392176618-23667-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1392176618-23667-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1392176618-23667-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, riel@redhat.com, mgorman@suse.de, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Archs like ppc64 doesn't do tlb flush in set_pte/pmd functions. ppc64 also doesn't implement
flush_tlb_range. ppc64 require the tlb flushing to be batched within ptl locks. The reason
to do that is to ensure that the hash page table is in sync with linux page table.
We track the hpte index in linux pte and if we clear them without flushing hash and drop the
ptl lock, we can have another cpu update the pte and can end up with double hash. We also want
to keep set_pte_at simpler by not requiring them to do hash flush for performance reason.
Hence cannot use them while updating _PAGE_NUMA bit. Add new functions for marking pte/pmd numa

Acked-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
Changes from V1:
 * Build fix for non numa balancing config
 
 arch/powerpc/include/asm/pgtable.h | 22 +++++++++++++++++++++
 include/asm-generic/pgtable.h      | 39 ++++++++++++++++++++++++++++++++++++++
 mm/huge_memory.c                   |  9 ++-------
 mm/mprotect.c                      |  4 +---
 4 files changed, 64 insertions(+), 10 deletions(-)

diff --git a/arch/powerpc/include/asm/pgtable.h b/arch/powerpc/include/asm/pgtable.h
index f83b6f3e1b39..3ebb188c3ff5 100644
--- a/arch/powerpc/include/asm/pgtable.h
+++ b/arch/powerpc/include/asm/pgtable.h
@@ -75,12 +75,34 @@ static inline pte_t pte_mknuma(pte_t pte)
 	return pte;
 }
 
+#define ptep_set_numa ptep_set_numa
+static inline void ptep_set_numa(struct mm_struct *mm, unsigned long addr,
+				 pte_t *ptep)
+{
+	if ((pte_val(*ptep) & _PAGE_PRESENT) == 0)
+		VM_BUG_ON(1);
+
+	pte_update(mm, addr, ptep, _PAGE_PRESENT, _PAGE_NUMA, 0);
+	return;
+}
+
 #define pmd_numa pmd_numa
 static inline int pmd_numa(pmd_t pmd)
 {
 	return pte_numa(pmd_pte(pmd));
 }
 
+#define pmdp_set_numa pmdp_set_numa
+static inline void pmdp_set_numa(struct mm_struct *mm, unsigned long addr,
+				 pmd_t *pmdp)
+{
+	if ((pmd_val(*pmdp) & _PAGE_PRESENT) == 0)
+		VM_BUG_ON(1);
+
+	pmd_hugepage_update(mm, addr, pmdp, _PAGE_PRESENT, _PAGE_NUMA);
+	return;
+}
+
 #define pmd_mknonnuma pmd_mknonnuma
 static inline pmd_t pmd_mknonnuma(pmd_t pmd)
 {
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 8e4f41d9af4d..34c7bdc06014 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -701,6 +701,18 @@ static inline pte_t pte_mknuma(pte_t pte)
 }
 #endif
 
+#ifndef ptep_set_numa
+static inline void ptep_set_numa(struct mm_struct *mm, unsigned long addr,
+				 pte_t *ptep)
+{
+	pte_t ptent = *ptep;
+
+	ptent = pte_mknuma(ptent);
+	set_pte_at(mm, addr, ptep, ptent);
+	return;
+}
+#endif
+
 #ifndef pmd_mknuma
 static inline pmd_t pmd_mknuma(pmd_t pmd)
 {
@@ -708,6 +720,18 @@ static inline pmd_t pmd_mknuma(pmd_t pmd)
 	return pmd_clear_flags(pmd, _PAGE_PRESENT);
 }
 #endif
+
+#ifndef pmdp_set_numa
+static inline void pmdp_set_numa(struct mm_struct *mm, unsigned long addr,
+				 pmd_t *pmdp)
+{
+	pmd_t pmd = *pmdp;
+
+	pmd = pmd_mknuma(pmd);
+	set_pmd_at(mm, addr, pmdp, pmd);
+	return;
+}
+#endif
 #else
 extern int pte_numa(pte_t pte);
 extern int pmd_numa(pmd_t pmd);
@@ -715,6 +739,8 @@ extern pte_t pte_mknonnuma(pte_t pte);
 extern pmd_t pmd_mknonnuma(pmd_t pmd);
 extern pte_t pte_mknuma(pte_t pte);
 extern pmd_t pmd_mknuma(pmd_t pmd);
+extern void ptep_set_numa(struct mm_struct *mm, unsigned long addr, pte_t *ptep);
+extern void pmdp_set_numa(struct mm_struct *mm, unsigned long addr, pmd_t *pmdp);
 #endif /* CONFIG_ARCH_USES_NUMA_PROT_NONE */
 #else
 static inline int pmd_numa(pmd_t pmd)
@@ -742,10 +768,23 @@ static inline pte_t pte_mknuma(pte_t pte)
 	return pte;
 }
 
+static inline void ptep_set_numa(struct mm_struct *mm, unsigned long addr,
+				 pte_t *ptep)
+{
+	return;
+}
+
+
 static inline pmd_t pmd_mknuma(pmd_t pmd)
 {
 	return pmd;
 }
+
+static inline void pmdp_set_numa(struct mm_struct *mm, unsigned long addr,
+				 pmd_t *pmdp)
+{
+	return ;
+}
 #endif /* CONFIG_NUMA_BALANCING */
 
 #endif /* CONFIG_MMU */
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 82166bf974e1..da23eb96779f 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1545,6 +1545,7 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 				entry = pmd_mknonnuma(entry);
 			entry = pmd_modify(entry, newprot);
 			ret = HPAGE_PMD_NR;
+			set_pmd_at(mm, addr, pmd, entry);
 			BUG_ON(pmd_write(entry));
 		} else {
 			struct page *page = pmd_page(*pmd);
@@ -1557,16 +1558,10 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			 */
 			if (!is_huge_zero_page(page) &&
 			    !pmd_numa(*pmd)) {
-				entry = *pmd;
-				entry = pmd_mknuma(entry);
+				pmdp_set_numa(mm, addr, pmd);
 				ret = HPAGE_PMD_NR;
 			}
 		}
-
-		/* Set PMD if cleared earlier */
-		if (ret == HPAGE_PMD_NR)
-			set_pmd_at(mm, addr, pmd, entry);
-
 		spin_unlock(ptl);
 	}
 
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 33eab902f10e..769a67a15803 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -69,12 +69,10 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 			} else {
 				struct page *page;
 
-				ptent = *pte;
 				page = vm_normal_page(vma, addr, oldpte);
 				if (page && !PageKsm(page)) {
 					if (!pte_numa(oldpte)) {
-						ptent = pte_mknuma(ptent);
-						set_pte_at(mm, addr, pte, ptent);
+						ptep_set_numa(mm, addr, pte);
 						updated = true;
 					}
 				}
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
