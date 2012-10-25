Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 245736B0072
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 12:45:01 -0400 (EDT)
From: Will Deacon <will.deacon@arm.com>
Subject: [PATCH v3] mm: thp: Set the accessed flag for old pages on access fault.
Date: Thu, 25 Oct 2012 17:44:31 +0100
Message-Id: <1351183471-14710-1-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, mhocko@suse.cz, peterz@infradead.org, akpm@linux-foundation.org, Will Deacon <will.deacon@arm.com>, Chris Metcalf <cmetcalf@tilera.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrea Arcangeli <aarcange@redhat.com>

On x86 memory accesses to pages without the ACCESSED flag set result in the
ACCESSED flag being set automatically. With the ARM architecture a page access
fault is raised instead (and it will continue to be raised until the ACCESSED
flag is set for the appropriate PTE/PMD).

For normal memory pages, handle_pte_fault will call pte_mkyoung (effectively
setting the ACCESSED flag). For transparent huge pages, pmd_mkyoung will only
be called for a write fault.

This patch ensures that faults on transparent hugepages which do not result
in a CoW update the access flags for the faulting pmd.

Cc: Chris Metcalf <cmetcalf@tilera.com>
Cc: Kirill A. Shutemov <kirill@shutemov.name>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Will Deacon <will.deacon@arm.com>
---

Ok chaps, I rebased this thing onto today's next (which basically
necessitated a rewrite) so I've reluctantly dropped my acks and kindly
ask if you could eyeball the new code, especially where the locking is
concerned. In the numa code (do_huge_pmd_prot_none), Peter checks again
that the page is not splitting, but I can't see why that is required.

Cheers,

Will

 include/linux/huge_mm.h |    4 ++++
 mm/huge_memory.c        |   22 ++++++++++++++++++++++
 mm/memory.c             |    7 ++++++-
 3 files changed, 32 insertions(+), 1 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 4f0f948..766fb27 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -8,6 +8,10 @@ extern int do_huge_pmd_anonymous_page(struct mm_struct *mm,
 extern int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 			 pmd_t *dst_pmd, pmd_t *src_pmd, unsigned long addr,
 			 struct vm_area_struct *vma);
+extern void huge_pmd_set_accessed(struct mm_struct *mm,
+				  struct vm_area_struct *vma,
+				  unsigned long address, pmd_t *pmd,
+				  pmd_t orig_pmd, int dirty);
 extern int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			       unsigned long address, pmd_t *pmd,
 			       pmd_t orig_pmd);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 3c14a96..f024d98 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -932,6 +932,28 @@ out:
 	return ret;
 }
 
+void huge_pmd_set_accessed(struct mm_struct *mm,
+			   struct vm_area_struct *vma,
+			   unsigned long address,
+			   pmd_t *pmd, pmd_t orig_pmd,
+			   int dirty)
+{
+	pmd_t entry;
+	unsigned long haddr;
+
+	spin_lock(&mm->page_table_lock);
+	if (unlikely(!pmd_same(*pmd, orig_pmd)))
+		goto unlock;
+
+	entry = pmd_mkyoung(orig_pmd);
+	haddr = address & HPAGE_PMD_MASK;
+	if (pmdp_set_access_flags(vma, haddr, pmd, entry, dirty))
+		update_mmu_cache_pmd(vma, address, pmd);
+
+unlock:
+	spin_unlock(&mm->page_table_lock);
+}
+
 static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 					struct vm_area_struct *vma,
 					unsigned long address,
diff --git a/mm/memory.c b/mm/memory.c
index f21ac1c..bcbc084 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3650,12 +3650,14 @@ retry:
 
 		barrier();
 		if (pmd_trans_huge(orig_pmd) && !pmd_trans_splitting(orig_pmd)) {
+			unsigned int dirty = flags & FAULT_FLAG_WRITE;
+
 			if (pmd_numa(vma, orig_pmd)) {
 				do_huge_pmd_numa_page(mm, vma, address, pmd,
 						      flags, orig_pmd);
 			}
 
-			if ((flags & FAULT_FLAG_WRITE) && !pmd_write(orig_pmd)) {
+			if (dirty && !pmd_write(orig_pmd)) {
 				ret = do_huge_pmd_wp_page(mm, vma, address, pmd,
 							  orig_pmd);
 				/*
@@ -3665,6 +3667,9 @@ retry:
 				 */
 				if (unlikely(ret & VM_FAULT_OOM))
 					goto retry;
+			} else {
+				huge_pmd_set_accessed(mm, vma, address, pmd,
+						      orig_pmd, dirty);
 			}
 
 			return ret;
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
