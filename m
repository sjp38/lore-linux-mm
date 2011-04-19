Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3AF4F8D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 09:52:34 -0400 (EDT)
Date: Tue, 19 Apr 2011 15:51:19 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [Bugme-new] [Bug 33682] New: mprotect got stuck when THP is
 "always" enabled
Message-ID: <20110419135119.GA5611@random.random>
References: <bug-33682-10286@https.bugzilla.kernel.org/>
 <20110418230651.54da5b82.akpm@linux-foundation.org>
 <20110419112506.GB5641@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110419112506.GB5641@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, bugs@casparzhang.com, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>

Hi,

this should fix bug
https://bugzilla.kernel.org/show_bug.cgi?id=33682 .

====
Subject: thp: fix /dev/zero MAP_PRIVATE and vm_flags cleanups

From: Andrea Arcangeli <aarcange@redhat.com>

The huge_memory.c THP page fault was allowed to run if vm_ops was null (which
would succeed for /dev/zero MAP_PRIVATE, as the f_op->mmap wouldn't setup a
special vma->vm_ops and it would fallback to regular anonymous memory) but
other THP logics weren't fully activated for vmas with vm_file not NULL
(/dev/zero has a not NULL vma->vm_file).

So this removes the vm_file checks so that /dev/zero also can safely
use THP (the other albeit safer approach to fix this bug would have
been to prevent the THP initial page fault to run if vm_file was set).

After removing the vm_file checks, this also makes huge_memory.c
stricter in khugepaged for the DEBUG_VM=y case. It doesn't replace the
vm_file check with a is_pfn_mapping check (but it keeps checking for
VM_PFNMAP under VM_BUG_ON) because for a is_cow_mapping() mapping
VM_PFNMAP should only be allowed to exist before the first page fault,
and in turn when vma->anon_vma is null (so preventing khugepaged
registration). So I tend to think the previous comment saying if
vm_file was set, VM_PFNMAP might have been set and we could still be
registered in khugepaged (despite anon_vma was not NULL to be
registered in khugepaged) was too paranoid. The is_linear_pfn_mapping
check is also I think superfluous (as described by comment) but under
DEBUG_VM it is safe to stay.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index df29c8f..8847c8c 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -117,7 +117,7 @@ static inline void vma_adjust_trans_huge(struct vm_area_struct *vma,
 					 unsigned long end,
 					 long adjust_next)
 {
-	if (!vma->anon_vma || vma->vm_ops || vma->vm_file)
+	if (!vma->anon_vma || vma->vm_ops)
 		return;
 	__vma_adjust_trans_huge(vma, start, end, adjust_next);
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 692dbae..2348db2 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -137,7 +137,8 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_RandomReadHint(v)		((v)->vm_flags & VM_RAND_READ)
 
 /*
- * special vmas that are non-mergable, non-mlock()able
+ * Special vmas that are non-mergable, non-mlock()able.
+ * Note: mm/huge_memory.c VM_NO_THP depends on this definition.
  */
 #define VM_SPECIAL (VM_IO | VM_DONTEXPAND | VM_RESERVED | VM_PFNMAP)
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 470dcda..83326ad 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1408,6 +1408,9 @@ out:
 	return ret;
 }
 
+#define VM_NO_THP (VM_SPECIAL|VM_INSERTPAGE|VM_MIXEDMAP|VM_SAO| \
+		   VM_HUGETLB|VM_SHARED|VM_MAYSHARE)
+
 int hugepage_madvise(struct vm_area_struct *vma,
 		     unsigned long *vm_flags, int advice)
 {
@@ -1416,11 +1419,7 @@ int hugepage_madvise(struct vm_area_struct *vma,
 		/*
 		 * Be somewhat over-protective like KSM for now!
 		 */
-		if (*vm_flags & (VM_HUGEPAGE |
-				 VM_SHARED   | VM_MAYSHARE   |
-				 VM_PFNMAP   | VM_IO      | VM_DONTEXPAND |
-				 VM_RESERVED | VM_HUGETLB | VM_INSERTPAGE |
-				 VM_MIXEDMAP | VM_SAO))
+		if (*vm_flags & (VM_HUGEPAGE | VM_NO_THP))
 			return -EINVAL;
 		*vm_flags &= ~VM_NOHUGEPAGE;
 		*vm_flags |= VM_HUGEPAGE;
@@ -1436,11 +1435,7 @@ int hugepage_madvise(struct vm_area_struct *vma,
 		/*
 		 * Be somewhat over-protective like KSM for now!
 		 */
-		if (*vm_flags & (VM_NOHUGEPAGE |
-				 VM_SHARED   | VM_MAYSHARE   |
-				 VM_PFNMAP   | VM_IO      | VM_DONTEXPAND |
-				 VM_RESERVED | VM_HUGETLB | VM_INSERTPAGE |
-				 VM_MIXEDMAP | VM_SAO))
+		if (*vm_flags & (VM_NOHUGEPAGE | VM_NO_THP))
 			return -EINVAL;
 		*vm_flags &= ~VM_HUGEPAGE;
 		*vm_flags |= VM_NOHUGEPAGE;
@@ -1574,10 +1569,14 @@ int khugepaged_enter_vma_merge(struct vm_area_struct *vma)
 		 * page fault if needed.
 		 */
 		return 0;
-	if (vma->vm_file || vma->vm_ops)
+	if (vma->vm_ops)
 		/* khugepaged not yet working on file or special mappings */
 		return 0;
-	VM_BUG_ON(is_linear_pfn_mapping(vma) || is_pfn_mapping(vma));
+	/*
+	 * If is_pfn_mapping() is true is_learn_pfn_mapping() must be
+	 * true too, verify it here.
+	 */
+	VM_BUG_ON(is_linear_pfn_mapping(vma) || vma->vm_flags & VM_NO_THP);
 	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
 	hend = vma->vm_end & HPAGE_PMD_MASK;
 	if (hstart < hend)
@@ -1828,12 +1827,15 @@ static void collapse_huge_page(struct mm_struct *mm,
 	    (vma->vm_flags & VM_NOHUGEPAGE))
 		goto out;
 
-	/* VM_PFNMAP vmas may have vm_ops null but vm_file set */
-	if (!vma->anon_vma || vma->vm_ops || vma->vm_file)
+	if (!vma->anon_vma || vma->vm_ops)
 		goto out;
 	if (is_vma_temporary_stack(vma))
 		goto out;
-	VM_BUG_ON(is_linear_pfn_mapping(vma) || is_pfn_mapping(vma));
+	/*
+	 * If is_pfn_mapping() is true is_learn_pfn_mapping() must be
+	 * true too, verify it here.
+	 */
+	VM_BUG_ON(is_linear_pfn_mapping(vma) || vma->vm_flags & VM_NO_THP);
 
 	pgd = pgd_offset(mm, address);
 	if (!pgd_present(*pgd))
@@ -2066,13 +2068,16 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 			progress++;
 			continue;
 		}
-		/* VM_PFNMAP vmas may have vm_ops null but vm_file set */
-		if (!vma->anon_vma || vma->vm_ops || vma->vm_file)
+		if (!vma->anon_vma || vma->vm_ops)
 			goto skip;
 		if (is_vma_temporary_stack(vma))
 			goto skip;
-
-		VM_BUG_ON(is_linear_pfn_mapping(vma) || is_pfn_mapping(vma));
+		/*
+		 * If is_pfn_mapping() is true is_learn_pfn_mapping()
+		 * must be true too, verify it here.
+		 */
+		VM_BUG_ON(is_linear_pfn_mapping(vma) ||
+			  vma->vm_flags & VM_NO_THP);
 
 		hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
 		hend = vma->vm_end & HPAGE_PMD_MASK;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
