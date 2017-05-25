Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9104E6B02B4
	for <linux-mm@kvack.org>; Thu, 25 May 2017 13:13:56 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id h76so193802934pfh.15
        for <linux-mm@kvack.org>; Thu, 25 May 2017 10:13:56 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g1si779109pld.328.2017.05.25.10.13.55
        for <linux-mm@kvack.org>;
        Thu, 25 May 2017 10:13:55 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [PATCH v4.1 7/8] mm/hugetlb: Introduce set_huge_swap_pte_at() helper
Date: Thu, 25 May 2017 18:13:31 +0100
Message-Id: <20170525171331.31469-1-punit.agrawal@arm.com>
In-Reply-To: <20170524115409.31309-8-punit.agrawal@arm.com>
References: <20170524115409.31309-8-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Punit Agrawal <punit.agrawal@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, mike.kravetz@oracle.com, steve.capper@arm.com, mark.rutland@arm.com, linux-arch@vger.kernel.org, aneesh.kumar@linux.vnet.ibm.com

set_huge_pte_at(), an architecture callback to populate hugepage ptes,
does not provide the range of virtual memory that is targeted. This
leads to ambiguity when dealing with swap entries on architectures that
support hugepages consisting of contiguous ptes.

Fix the problem by introducing an overridable helper for architectures
needing this support. The helper is called when populating the page
tables with swap entries. The size of the targeted region is provided to
the helper to help determine the number of entries to be updated.

Provide a default implementation that maintains the current behaviour.

Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
Acked-by: Steve Capper <steve.capper@arm.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
---
Hi Andrew,

This update fixes the build failure reported by 0-day when
CONFIG_HUGETLB_PAGE is disabled.

Thanks,
Punit

Change from v4:

* Added an empty definition for set_huge_swap_pte_at() when
  CONFIG_HUGETLB_PAGE is disabled

 include/linux/hugetlb.h | 13 +++++++++++++
 mm/hugetlb.c            |  8 +++++---
 2 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 23010a3b2047..af859564509e 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -502,6 +502,14 @@ static inline void hugetlb_count_sub(long l, struct mm_struct *mm)
 {
 	atomic_long_sub(l, &mm->hugetlb_usage);
 }
+
+#ifndef set_huge_swap_pte_at
+static inline void set_huge_swap_pte_at(struct mm_struct *mm, unsigned long addr,
+					pte_t *ptep, pte_t pte, unsigned long sz)
+{
+	set_huge_pte_at(mm, addr, ptep, pte);
+}
+#endif
 #else	/* CONFIG_HUGETLB_PAGE */
 struct hstate {};
 #define alloc_huge_page(v, a, r) NULL
@@ -546,6 +554,11 @@ static inline void hugetlb_report_usage(struct seq_file *f, struct mm_struct *m)
 static inline void hugetlb_count_sub(long l, struct mm_struct *mm)
 {
 }
+
+static inline void set_huge_swap_pte_at(struct mm_struct *mm, unsigned long addr,
+					pte_t *ptep, pte_t pte, unsigned long sz)
+{
+}
 #endif	/* CONFIG_HUGETLB_PAGE */
 
 static inline spinlock_t *huge_pte_lock(struct hstate *h,
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ddfed20cd637..e3052c16d29a 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3263,9 +3263,10 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
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
@@ -4277,7 +4278,8 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 
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
