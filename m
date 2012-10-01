Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id D9BCC6B0071
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 09:51:49 -0400 (EDT)
From: Will Deacon <will.deacon@arm.com>
Subject: [PATCH] mm: thp: Set the accessed flag for old pages on access fault.
Date: Mon,  1 Oct 2012 14:51:45 +0100
Message-Id: <1349099505-5581-1-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, akpm@linux-foundation.org, mhocko@suse.cz, Steve Capper <steve.capper@arm.com>, Andrea Arcangeli <aarcange@redhat.com>, Chris Metcalf <cmetcalf@tilera.com>, Will Deacon <will.deacon@arm.com>

From: Steve Capper <steve.capper@arm.com>

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

Hello again,

This is another fix for an issue that we discovered when porting THP to
ARM but it somehow managed to slip through the cracks.

Will

 include/linux/huge_mm.h |    3 +++
 mm/huge_memory.c        |   12 ++++++++++++
 mm/memory.c             |    4 ++++
 3 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 4c59b11..bbc62ad 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -8,6 +8,9 @@ extern int do_huge_pmd_anonymous_page(struct mm_struct *mm,
 extern int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 			 pmd_t *dst_pmd, pmd_t *src_pmd, unsigned long addr,
 			 struct vm_area_struct *vma);
+extern void huge_pmd_set_accessed(struct mm_struct *mm, struct vm_area_struct *vma,
+				  unsigned long address, pmd_t *pmd,
+				  pmd_t orig_pmd);
 extern int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			       unsigned long address, pmd_t *pmd,
 			       pmd_t orig_pmd);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index d684934..ee9cc3b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -914,6 +914,18 @@ out_free_pages:
 	goto out;
 }
 
+void huge_pmd_set_accessed(struct mm_struct *mm, struct vm_area_struct *vma,
+			   unsigned long address, pmd_t *pmd, pmd_t orig_pmd)
+{
+	pmd_t entry;
+
+	spin_lock(&mm->page_table_lock);
+	entry = pmd_mkyoung(orig_pmd);
+	if (pmdp_set_access_flags(vma, address & HPAGE_PMD_MASK, pmd, entry, 0))
+		update_mmu_cache(vma, address, pmd);
+	spin_unlock(&mm->page_table_lock);
+}
+
 int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, pmd_t *pmd, pmd_t orig_pmd)
 {
diff --git a/mm/memory.c b/mm/memory.c
index 5736170..d5c007d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3537,7 +3537,11 @@ retry:
 				if (unlikely(ret & VM_FAULT_OOM))
 					goto retry;
 				return ret;
+			} else {
+				huge_pmd_set_accessed(mm, vma, address, pmd,
+						      orig_pmd);
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
