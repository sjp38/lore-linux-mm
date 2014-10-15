Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id BBB486B0069
	for <linux-mm@kvack.org>; Wed, 15 Oct 2014 17:13:06 -0400 (EDT)
Received: by mail-ie0-f170.google.com with SMTP id rd18so2160481iec.15
        for <linux-mm@kvack.org>; Wed, 15 Oct 2014 14:13:06 -0700 (PDT)
Received: from mail-ie0-x22b.google.com (mail-ie0-x22b.google.com [2607:f8b0:4001:c03::22b])
        by mx.google.com with ESMTPS id nt8si26482524igb.28.2014.10.15.14.13.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 15 Oct 2014 14:13:06 -0700 (PDT)
Received: by mail-ie0-f171.google.com with SMTP id tr6so2135030ieb.16
        for <linux-mm@kvack.org>; Wed, 15 Oct 2014 14:13:05 -0700 (PDT)
Date: Wed, 15 Oct 2014 14:13:03 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch resend] mm, thp: fix collapsing of hugepages on madvise
In-Reply-To: <alpine.DEB.2.02.1410041947080.7055@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1410151412120.3146@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1410041947080.7055@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Suleiman Souhlal <suleiman@google.com>, stable@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

If an anonymous mapping is not allowed to fault thp memory and then
madvise(MADV_HUGEPAGE) is used after fault, khugepaged will never
collapse this memory into thp memory.

This occurs because the madvise(2) handler for thp, hugepage_madvise(),
clears VM_NOHUGEPAGE on the stack and it isn't stored in vma->vm_flags
until the final action of madvise_behavior().  This causes the
khugepaged_enter_vma_merge() to be a no-op in hugepage_madvise() when the
vma had previously had VM_NOHUGEPAGE set.

Fix this by passing the correct vma flags to the khugepaged mm slot
handler.  There's no chance khugepaged can run on this vma until after
madvise_behavior() returns since we hold mm->mmap_sem.

It would be possible to clear VM_NOHUGEPAGE directly from vma->vm_flags
in hugepage_advise(), but I didn't want to introduce special case
behavior into madvise_behavior().  I think it's best to just let it
always set vma->vm_flags itself.

Cc: <stable@vger.kernel.org>
Reported-by: Suleiman Souhlal <suleiman@google.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/khugepaged.h | 17 ++++++++++-------
 mm/huge_memory.c           | 11 ++++++-----
 mm/mmap.c                  |  8 ++++----
 3 files changed, 20 insertions(+), 16 deletions(-)

diff --git a/include/linux/khugepaged.h b/include/linux/khugepaged.h
--- a/include/linux/khugepaged.h
+++ b/include/linux/khugepaged.h
@@ -6,7 +6,8 @@
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 extern int __khugepaged_enter(struct mm_struct *mm);
 extern void __khugepaged_exit(struct mm_struct *mm);
-extern int khugepaged_enter_vma_merge(struct vm_area_struct *vma);
+extern int khugepaged_enter_vma_merge(struct vm_area_struct *vma,
+				      unsigned long vm_flags);
 
 #define khugepaged_enabled()					       \
 	(transparent_hugepage_flags &				       \
@@ -35,13 +36,13 @@ static inline void khugepaged_exit(struct mm_struct *mm)
 		__khugepaged_exit(mm);
 }
 
-static inline int khugepaged_enter(struct vm_area_struct *vma)
+static inline int khugepaged_enter(struct vm_area_struct *vma,
+				   unsigned long vm_flags)
 {
 	if (!test_bit(MMF_VM_HUGEPAGE, &vma->vm_mm->flags))
 		if ((khugepaged_always() ||
-		     (khugepaged_req_madv() &&
-		      vma->vm_flags & VM_HUGEPAGE)) &&
-		    !(vma->vm_flags & VM_NOHUGEPAGE))
+		     (khugepaged_req_madv() && (vm_flags & VM_HUGEPAGE))) &&
+		    !(vm_flags & VM_NOHUGEPAGE))
 			if (__khugepaged_enter(vma->vm_mm))
 				return -ENOMEM;
 	return 0;
@@ -54,11 +55,13 @@ static inline int khugepaged_fork(struct mm_struct *mm, struct mm_struct *oldmm)
 static inline void khugepaged_exit(struct mm_struct *mm)
 {
 }
-static inline int khugepaged_enter(struct vm_area_struct *vma)
+static inline int khugepaged_enter(struct vm_area_struct *vma,
+				   unsigned long vm_flags)
 {
 	return 0;
 }
-static inline int khugepaged_enter_vma_merge(struct vm_area_struct *vma)
+static inline int khugepaged_enter_vma_merge(struct vm_area_struct *vma,
+					     unsigned long vm_flags)
 {
 	return 0;
 }
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -803,7 +803,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		return VM_FAULT_FALLBACK;
 	if (unlikely(anon_vma_prepare(vma)))
 		return VM_FAULT_OOM;
-	if (unlikely(khugepaged_enter(vma)))
+	if (unlikely(khugepaged_enter(vma, vma->vm_flags)))
 		return VM_FAULT_OOM;
 	if (!(flags & FAULT_FLAG_WRITE) &&
 			transparent_hugepage_use_zero_page()) {
@@ -1970,7 +1970,7 @@ int hugepage_madvise(struct vm_area_struct *vma,
 		 * register it here without waiting a page fault that
 		 * may not happen any time soon.
 		 */
-		if (unlikely(khugepaged_enter_vma_merge(vma)))
+		if (unlikely(khugepaged_enter_vma_merge(vma, *vm_flags)))
 			return -ENOMEM;
 		break;
 	case MADV_NOHUGEPAGE:
@@ -2071,7 +2071,8 @@ int __khugepaged_enter(struct mm_struct *mm)
 	return 0;
 }
 
-int khugepaged_enter_vma_merge(struct vm_area_struct *vma)
+int khugepaged_enter_vma_merge(struct vm_area_struct *vma,
+			       unsigned long vm_flags)
 {
 	unsigned long hstart, hend;
 	if (!vma->anon_vma)
@@ -2083,11 +2084,11 @@ int khugepaged_enter_vma_merge(struct vm_area_struct *vma)
 	if (vma->vm_ops)
 		/* khugepaged not yet working on file or special mappings */
 		return 0;
-	VM_BUG_ON_VMA(vma->vm_flags & VM_NO_THP, vma);
+	VM_BUG_ON_VMA(vm_flags & VM_NO_THP, vma);
 	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
 	hend = vma->vm_end & HPAGE_PMD_MASK;
 	if (hstart < hend)
-		return khugepaged_enter(vma);
+		return khugepaged_enter(vma, vm_flags);
 	return 0;
 }
 
diff --git a/mm/mmap.c b/mm/mmap.c
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1080,7 +1080,7 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 				end, prev->vm_pgoff, NULL);
 		if (err)
 			return NULL;
-		khugepaged_enter_vma_merge(prev);
+		khugepaged_enter_vma_merge(prev, vm_flags);
 		return prev;
 	}
 
@@ -1099,7 +1099,7 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 				next->vm_pgoff - pglen, NULL);
 		if (err)
 			return NULL;
-		khugepaged_enter_vma_merge(area);
+		khugepaged_enter_vma_merge(area, vm_flags);
 		return area;
 	}
 
@@ -2208,7 +2208,7 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
 		}
 	}
 	vma_unlock_anon_vma(vma);
-	khugepaged_enter_vma_merge(vma);
+	khugepaged_enter_vma_merge(vma, vma->vm_flags);
 	validate_mm(vma->vm_mm);
 	return error;
 }
@@ -2277,7 +2277,7 @@ int expand_downwards(struct vm_area_struct *vma,
 		}
 	}
 	vma_unlock_anon_vma(vma);
-	khugepaged_enter_vma_merge(vma);
+	khugepaged_enter_vma_merge(vma, vma->vm_flags);
 	validate_mm(vma->vm_mm);
 	return error;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
