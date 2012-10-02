Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 9C1BF6B006C
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 12:59:56 -0400 (EDT)
From: Will Deacon <will.deacon@arm.com>
Subject: [PATCH v2] mm: thp: Set the accessed flag for old pages on access fault.
Date: Tue,  2 Oct 2012 17:59:11 +0100
Message-Id: <1349197151-19645-1-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, akpm@linux-foundation.org, mhocko@suse.cz, kirill@shutemov.name, Will Deacon <will.deacon@arm.com>, Andrea Arcangeli <aarcange@redhat.com>, Chris Metcalf <cmetcalf@tilera.com>, Steve Capper <steve.capper@arm.com>

On x86 memory accesses to pages without the ACCESSED flag set result in the
ACCESSED flag being set automatically. With the ARM architecture a page access
fault is raised instead (and it will continue to be raised until the ACCESSED
flag is set for the appropriate PTE/PMD).

For normal memory pages, handle_pte_fault will call pte_mkyoung (effectively
setting the ACCESSED flag). For transparent huge pages, pmd_mkyoung will only
be called for a write fault.

This patch ensures that faults on transparent hugepages which do not result
in a CoW update the access flags for the faulting pmd.

Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Chris Metcalf <cmetcalf@tilera.com>
Signed-off-by: Steve Capper <steve.capper@arm.com>
Signed-off-by: Will Deacon <will.deacon@arm.com>
---

v2: - Use pmd_trans_huge_lock to guard against splitting pmds
    - Propogate dirty (write) flag to low-level pmd modifier

 include/linux/huge_mm.h |    2 ++
 mm/huge_memory.c        |    8 ++++++++
 mm/memory.c             |    9 ++++++++-
 3 files changed, 18 insertions(+), 1 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 4c59b11..5eb9b06 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -8,6 +8,8 @@ extern int do_huge_pmd_anonymous_page(struct mm_struct *mm,
 extern int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 			 pmd_t *dst_pmd, pmd_t *src_pmd, unsigned long addr,
 			 struct vm_area_struct *vma);
+extern void huge_pmd_set_accessed(struct vm_area_struct *vma,
+				  unsigned long address, pmd_t *pmd, int dirty);
 extern int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			       unsigned long address, pmd_t *pmd,
 			       pmd_t orig_pmd);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index d684934..1de3f9b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -914,6 +914,14 @@ out_free_pages:
 	goto out;
 }
 
+void huge_pmd_set_accessed(struct vm_area_struct *vma, unsigned long address,
+			   pmd_t *pmd, int dirty)
+{
+	pmd_t entry = pmd_mkyoung(*pmd);
+	if (pmdp_set_access_flags(vma, address & HPAGE_PMD_MASK, pmd, entry, dirty))
+		update_mmu_cache(vma, address, pmd);
+}
+
 int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, pmd_t *pmd, pmd_t orig_pmd)
 {
diff --git a/mm/memory.c b/mm/memory.c
index 5736170..f12f859 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3524,7 +3524,8 @@ retry:
 
 		barrier();
 		if (pmd_trans_huge(orig_pmd)) {
-			if (flags & FAULT_FLAG_WRITE &&
+			int dirty = flags & FAULT_FLAG_WRITE;
+			if (dirty &&
 			    !pmd_write(orig_pmd) &&
 			    !pmd_trans_splitting(orig_pmd)) {
 				ret = do_huge_pmd_wp_page(mm, vma, address, pmd,
@@ -3537,7 +3538,13 @@ retry:
 				if (unlikely(ret & VM_FAULT_OOM))
 					goto retry;
 				return ret;
+			} else if (pmd_trans_huge_lock(pmd, vma) == 1) {
+				if (likely(pmd_same(*pmd, orig_pmd)))
+					huge_pmd_set_accessed(vma, address, pmd,
+							      dirty);
+				spin_unlock(&mm->page_table_lock);
 			}
+
 			return 0;
 		}
 	}
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
