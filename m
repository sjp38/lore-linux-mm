Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 14CB76B0089
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 11:00:32 -0500 (EST)
Date: Wed, 22 Dec 2010 17:00:29 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH -mm] thp: khugepaged: make khugepaged aware about madvise
Message-ID: <20101222160029.GU26084@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a minor enhancement to the two MADV_*HUGEPAGE vs khugepaged
(so they are more effective even if they're run after using the
memory). Without this they're full effective only if madvise is run
immediately after mmap returns which would be the normal usage.

This should apply cleanly at the end.

It's no big issue in my view and minor feature addition, so it can be
deferred for later. I'm queuing at the end of aa.git so I will
re-submit later if needed.

Thanks!
Andrea

===
Subject: thp: khugepaged: make khugepaged aware about madvise

From: Andrea Arcangeli <aarcange@redhat.com>

MADV_HUGEPAGE and MADV_NOHUGEPAGE were fully effective only if run after mmap
and before touching the memory. While this is enough for most usages, it's
little effort to make madvise more dynamic at runtime on an existing mapping by
making khugepaged aware about madvise.

MADV_HUGEPAGE: register in khugepaged immediately without waiting a page fault
(that may not ever happen if all pages are already mapped and the "enabled"
knob was set to madvise during the initial page faults).

MADV_NOHUGEPAGE: skip vmas marked VM_NOHUGEPAGE in khugepaged to stop
collapsing pages where not needed.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -105,7 +105,8 @@ extern void __split_huge_page_pmd(struct
 #if HPAGE_PMD_ORDER > MAX_ORDER
 #error "hugepages can't be allocated by the buddy allocator"
 #endif
-extern int hugepage_madvise(unsigned long *vm_flags, int advice);
+extern int hugepage_madvise(struct vm_area_struct *vma,
+			    unsigned long *vm_flags, int advice);
 extern void __vma_adjust_trans_huge(struct vm_area_struct *vma,
 				    unsigned long start,
 				    unsigned long end,
@@ -143,7 +144,8 @@ static inline int split_huge_page(struct
 	do { } while (0)
 #define wait_split_huge_page(__anon_vma, __pmd)	\
 	do { } while (0)
-static inline int hugepage_madvise(unsigned long *vm_flags, int advice)
+static inline int hugepage_madvise(struct vm_area_struct *vma,
+				   unsigned long *vm_flags, int advice)
 {
 	BUG();
 	return 0;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1389,7 +1389,8 @@ out:
 	return ret;
 }
 
-int hugepage_madvise(unsigned long *vm_flags, int advice)
+int hugepage_madvise(struct vm_area_struct *vma,
+		     unsigned long *vm_flags, int advice)
 {
 	switch (advice) {
 	case MADV_HUGEPAGE:
@@ -1404,6 +1405,13 @@ int hugepage_madvise(unsigned long *vm_f
 			return -EINVAL;
 		*vm_flags &= ~VM_NOHUGEPAGE;
 		*vm_flags |= VM_HUGEPAGE;
+		/*
+		 * If the vma become good for khugepaged to scan,
+		 * register it here without waiting a page fault that
+		 * may not happen any time soon.
+		 */
+		if (unlikely(khugepaged_enter_vma_merge(vma)))
+			return -ENOMEM;
 		break;
 	case MADV_NOHUGEPAGE:
 		/*
@@ -1417,6 +1425,12 @@ int hugepage_madvise(unsigned long *vm_f
 			return -EINVAL;
 		*vm_flags &= ~VM_HUGEPAGE;
 		*vm_flags |= VM_NOHUGEPAGE;
+		/*
+		 * Setting VM_NOHUGEPAGE will prevent khugepaged to
+		 * scan this vma even if we leave the mm registered in
+		 * khugepaged if it got registered before
+		 * VM_NOHUGEPAGE was set.
+		 */
 		break;
 	}
 
@@ -1784,7 +1798,8 @@ static void collapse_huge_page(struct mm
 	if (address < hstart || address + HPAGE_PMD_SIZE > hend)
 		goto out;
 
-	if (!(vma->vm_flags & VM_HUGEPAGE) && !khugepaged_always())
+	if ((!(vma->vm_flags & VM_HUGEPAGE) && !khugepaged_always()) ||
+	    (vma->vm_flags & VM_NOHUGEPAGE))
 		goto out;
 
 	/* VM_PFNMAP vmas may have vm_ops null but vm_file set */
@@ -2007,8 +2022,9 @@ static unsigned int khugepaged_scan_mm_s
 			break;
 		}
 
-		if (!(vma->vm_flags & VM_HUGEPAGE) &&
-		    !khugepaged_always()) {
+		if ((!(vma->vm_flags & VM_HUGEPAGE) &&
+		     !khugepaged_always()) ||
+		    (vma->vm_flags & VM_NOHUGEPAGE)) {
 			progress++;
 			continue;
 		}
diff --git a/mm/madvise.c b/mm/madvise.c
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -73,7 +73,7 @@ static long madvise_behavior(struct vm_a
 		break;
 	case MADV_HUGEPAGE:
 	case MADV_NOHUGEPAGE:
-		error = hugepage_madvise(&new_flags, behavior);
+		error = hugepage_madvise(vma, &new_flags, behavior);
 		if (error)
 			goto out;
 		break;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
