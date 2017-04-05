Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id CFD436B03AC
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 09:38:16 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id v4so6986415pgc.20
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 06:38:16 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z88si20654966pff.228.2017.04.05.06.38.15
        for <linux-mm@kvack.org>;
        Wed, 05 Apr 2017 06:38:16 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [PATCH v2 5/9] mm/hugetlb: Introduce set_huge_swap_pte_at() helper
Date: Wed,  5 Apr 2017 14:37:18 +0100
Message-Id: <20170405133722.6406-6-punit.agrawal@arm.com>
In-Reply-To: <20170405133722.6406-1-punit.agrawal@arm.com>
References: <20170405133722.6406-1-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com, will.deacon@arm.com, akpm@linux-foundation.org, mark.rutland@arm.com
Cc: Punit Agrawal <punit.agrawal@arm.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, tbaicar@codeaurora.org, kirill.shutemov@linux.intel.com, mike.kravetz@oracle.com, hillf.zj@alibaba-inc.com, steve.capper@arm.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

set_huge_pte_at(), an architecture callback to populate hugepage ptes,
does not provide the range of virtual memory that is targetted. This
leads to ambiguity when dealing with swap entries on architectures that
support hugepages consisting of contiguous ptes.

Fix the problem by introducing an overridable helper that is called when
populating the page tables with swap entries. The size of the targetted
region is provided to the helper to help determine the number of entries
to be updated.

Provide a default implementation that maintains the current behaviour.

Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
---
 include/linux/hugetlb.h |  2 ++
 mm/hugetlb.c            | 14 +++++++++++---
 2 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 23010a3b2047..fa65ad73a65f 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -127,6 +127,8 @@ int pud_huge(pud_t pud);
 unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 		unsigned long address, unsigned long end, pgprot_t newprot);
 
+void set_huge_swap_pte_at(struct mm_struct *mm, unsigned long addr,
+			  pte_t *ptep, pte_t pte, unsigned long sz);
 #else /* !CONFIG_HUGETLB_PAGE */
 
 static inline void reset_vma_resv_huge_pages(struct vm_area_struct *vma)
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 2b0f6f96f2c1..a27e926913f4 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3211,6 +3211,12 @@ static int is_hugetlb_entry_hwpoisoned(pte_t pte)
 		return 0;
 }
 
+void __weak set_huge_swap_pte_at(struct mm_struct *mm, unsigned long addr,
+				 pte_t *ptep, pte_t pte, unsigned long sz)
+{
+	set_huge_pte_at(mm, addr, ptep, pte);
+}
+
 int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 			    struct vm_area_struct *vma)
 {
@@ -3263,9 +3269,10 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 				 */
 				make_migration_entry_read(&swp_entry);
 				entry = swp_entry_to_pte(swp_entry);
-				set_huge_pte_at(src, addr, src_pte, entry);
+				set_huge_swap_pte_at(src, addr, src_pte,
+						     entry, sz);
 			}
-			set_huge_pte_at(dst, addr, dst_pte, entry);
+			set_huge_swap_pte_at(dst, addr, dst_pte, entry, sz);
 		} else {
 			if (cow) {
 				huge_ptep_set_wrprotect(src, addr, src_pte);
@@ -4283,7 +4290,8 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 
 				make_migration_entry_read(&entry);
 				newpte = swp_entry_to_pte(entry);
-				set_huge_pte_at(mm, address, ptep, newpte);
+				set_huge_swap_pte_at(mm, address, ptep,
+						     newpte, huge_page_size(h));
 				pages++;
 			}
 			spin_unlock(ptl);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
