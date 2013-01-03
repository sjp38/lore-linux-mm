Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 12BF16B006C
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 23:28:11 -0500 (EST)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 2/8] Don't allow volatile attribute on THP and KSM
Date: Thu,  3 Jan 2013 13:28:00 +0900
Message-Id: <1357187286-18759-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1357187286-18759-1-git-send-email-minchan@kernel.org>
References: <1357187286-18759-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>

VOLATILE imply the the pages in the range isn't working set any more
so it's pointless that make them to THP/KSM.

Cc: Rik van Riel <riel@redhat.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/huge_memory.c |    9 +++++++--
 mm/ksm.c         |    3 ++-
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 40f17c3..5ddd00e 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1477,7 +1477,8 @@ out:
 	return ret;
 }
 
-#define VM_NO_THP (VM_SPECIAL|VM_MIXEDMAP|VM_HUGETLB|VM_SHARED|VM_MAYSHARE)
+#define VM_NO_THP (VM_SPECIAL|VM_MIXEDMAP|VM_HUGETLB|\
+			VM_SHARED|VM_MAYSHARE|VM_VOLATILE)
 
 int hugepage_madvise(struct vm_area_struct *vma,
 		     unsigned long *vm_flags, int advice)
@@ -1641,6 +1642,8 @@ int khugepaged_enter_vma_merge(struct vm_area_struct *vma)
 		 * page fault if needed.
 		 */
 		return 0;
+	if (vma->vm_flags & VM_VOLATILE)
+		return 0;
 	if (vma->vm_ops)
 		/* khugepaged not yet working on file or special mappings */
 		return 0;
@@ -1969,6 +1972,8 @@ static void collapse_huge_page(struct mm_struct *mm,
 		goto out;
 	if (is_vma_temporary_stack(vma))
 		goto out;
+	if (vma->vm_flags & VM_VOLATILE)
+		goto out;
 	VM_BUG_ON(vma->vm_flags & VM_NO_THP);
 
 	pgd = pgd_offset(mm, address);
@@ -2196,7 +2201,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 
 		if ((!(vma->vm_flags & VM_HUGEPAGE) &&
 		     !khugepaged_always()) ||
-		    (vma->vm_flags & VM_NOHUGEPAGE)) {
+		     (vma->vm_flags & (VM_NOHUGEPAGE|VM_VOLATILE))) {
 		skip:
 			progress++;
 			continue;
diff --git a/mm/ksm.c b/mm/ksm.c
index ae539f0..2775f59 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1486,7 +1486,8 @@ int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 		 */
 		if (*vm_flags & (VM_MERGEABLE | VM_SHARED  | VM_MAYSHARE   |
 				 VM_PFNMAP    | VM_IO      | VM_DONTEXPAND |
-				 VM_HUGETLB | VM_NONLINEAR | VM_MIXEDMAP))
+				 VM_HUGETLB | VM_NONLINEAR | VM_MIXEDMAP   |
+				 VM_VOLATILE))
 			return 0;		/* just ignore the advice */
 
 #ifdef VM_SAO
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
