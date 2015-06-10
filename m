Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id F00706B006E
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 02:32:31 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so30922114pdb.2
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 23:32:31 -0700 (PDT)
Received: from mail-pd0-x243.google.com (mail-pd0-x243.google.com. [2607:f8b0:400e:c02::243])
        by mx.google.com with ESMTPS id f6si12335647pds.59.2015.06.09.23.32.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 23:32:30 -0700 (PDT)
Received: by pdbht2 with SMTP id ht2so7453539pdb.2
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 23:32:30 -0700 (PDT)
From: Wenwei Tao <wenweitaowenwei@gmail.com>
Subject: [RFC PATCH 2/6] mm: change the condition of identifying hugetlb vm
Date: Wed, 10 Jun 2015 14:27:15 +0800
Message-Id: <1433917639-31699-3-git-send-email-wenweitaowenwei@gmail.com>
In-Reply-To: <1433917639-31699-1-git-send-email-wenweitaowenwei@gmail.com>
References: <1433917639-31699-1-git-send-email-wenweitaowenwei@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: izik.eidus@ravellosystems.com, aarcange@redhat.com, chrisw@sous-sol.org, hughd@google.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, viro@zeniv.linux.org.uk
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, wenweitaowenwei@gmail.com

Hugetlb VMAs are not mergeable, that means a VMA couldn't have VM_HUGETLB and
VM_MERGEABLE been set in the same time. So we use VM_HUGETLB to indicate new
mergeable VMAs. Because of that a VMA which has VM_HUGETLB been set is a hugetlb
VMA only if it doesn't have VM_MERGEABLE been set in the same time.

Signed-off-by: Wenwei Tao <wenweitaowenwei@gmail.com>
---
 include/linux/hugetlb_inline.h |    2 +-
 include/linux/mempolicy.h      |    2 +-
 mm/gup.c                       |    6 ++++--
 mm/huge_memory.c               |   17 ++++++++++++-----
 mm/madvise.c                   |    6 ++++--
 mm/memory.c                    |    5 +++--
 mm/mprotect.c                  |    6 ++++--
 7 files changed, 29 insertions(+), 15 deletions(-)

diff --git a/include/linux/hugetlb_inline.h b/include/linux/hugetlb_inline.h
index 2bb681f..08dff6f 100644
--- a/include/linux/hugetlb_inline.h
+++ b/include/linux/hugetlb_inline.h
@@ -7,7 +7,7 @@
 
 static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
 {
-	return !!(vma->vm_flags & VM_HUGETLB);
+	return !!((vma->vm_flags & (VM_HUGETLB | VM_MERGEABLE)) == VM_HUGETLB);
 }
 
 #else
diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index 3d385c8..40ad136 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -178,7 +178,7 @@ static inline int vma_migratable(struct vm_area_struct *vma)
 		return 0;
 
 #ifndef CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
-	if (vma->vm_flags & VM_HUGETLB)
+	if ((vma->vm_flags & (VM_HUGETLB | VM_MERGEABLE)) == VM_HUGETLB)
 		return 0;
 #endif
 
diff --git a/mm/gup.c b/mm/gup.c
index a6e24e2..5803dab 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -166,7 +166,8 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 	pud = pud_offset(pgd, address);
 	if (pud_none(*pud))
 		return no_page_table(vma, flags);
-	if (pud_huge(*pud) && vma->vm_flags & VM_HUGETLB) {
+	if (pud_huge(*pud) &&
+		(vma->vm_flags & (VM_HUGETLB | VM_MERGEABLE)) == VM_HUGETLB) {
 		page = follow_huge_pud(mm, address, pud, flags);
 		if (page)
 			return page;
@@ -178,7 +179,8 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 	pmd = pmd_offset(pud, address);
 	if (pmd_none(*pmd))
 		return no_page_table(vma, flags);
-	if (pmd_huge(*pmd) && vma->vm_flags & VM_HUGETLB) {
+	if (pmd_huge(*pmd) &&
+		(vma->vm_flags & (VM_HUGETLB | VM_MERGEABLE)) == VM_HUGETLB) {
 		page = follow_huge_pmd(mm, address, pmd, flags);
 		if (page)
 			return page;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index fc00c8c..5a9de7f 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1910,7 +1910,6 @@ out:
 	return ret;
 }
 
-#define VM_NO_THP (VM_SPECIAL | VM_HUGETLB | VM_SHARED | VM_MAYSHARE)
 
 int hugepage_madvise(struct vm_area_struct *vma,
 		     unsigned long *vm_flags, int advice)
@@ -1929,7 +1928,9 @@ int hugepage_madvise(struct vm_area_struct *vma,
 		/*
 		 * Be somewhat over-protective like KSM for now!
 		 */
-		if (*vm_flags & (VM_HUGEPAGE | VM_NO_THP))
+		if (*vm_flags & (VM_HUGEPAGE | VM_SPECIAL |
+						VM_SHARED | VM_MAYSHARE) ||
+			(*vm_flags & (VM_HUGETLB | VM_MERGEABLE)) == VM_HUGETLB)
 			return -EINVAL;
 		*vm_flags &= ~VM_NOHUGEPAGE;
 		*vm_flags |= VM_HUGEPAGE;
@@ -1945,7 +1946,9 @@ int hugepage_madvise(struct vm_area_struct *vma,
 		/*
 		 * Be somewhat over-protective like KSM for now!
 		 */
-		if (*vm_flags & (VM_NOHUGEPAGE | VM_NO_THP))
+		if (*vm_flags & (VM_NOHUGEPAGE | VM_SPECIAL |
+						VM_SHARED | VM_MAYSHARE) ||
+			(*vm_flags & (VM_HUGETLB | VM_MERGEABLE)) == VM_HUGETLB)
 			return -EINVAL;
 		*vm_flags &= ~VM_HUGEPAGE;
 		*vm_flags |= VM_NOHUGEPAGE;
@@ -2052,7 +2055,8 @@ int khugepaged_enter_vma_merge(struct vm_area_struct *vma,
 	if (vma->vm_ops)
 		/* khugepaged not yet working on file or special mappings */
 		return 0;
-	VM_BUG_ON_VMA(vm_flags & VM_NO_THP, vma);
+	VM_BUG_ON_VMA(vm_flags & (VM_SPECIAL | VM_SHARED | VM_MAYSHARE) ||
+		(vm_flags & (VM_HUGETLB | VM_MERGEABLE)) == VM_HUGETLB, vma);
 	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
 	hend = vma->vm_end & HPAGE_PMD_MASK;
 	if (hstart < hend)
@@ -2396,7 +2400,10 @@ static bool hugepage_vma_check(struct vm_area_struct *vma)
 		return false;
 	if (is_vma_temporary_stack(vma))
 		return false;
-	VM_BUG_ON_VMA(vma->vm_flags & VM_NO_THP, vma);
+	VM_BUG_ON_VMA(vma->vm_flags &
+		(VM_SPECIAL | VM_SHARED | VM_MAYSHARE) ||
+		(vma->vm_flags & (VM_HUGETLB | VM_MERGEABLE)) ==
+		VM_HUGETLB, vma);
 	return true;
 }
 
diff --git a/mm/madvise.c b/mm/madvise.c
index d551475..ad1081e 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -278,7 +278,8 @@ static long madvise_dontneed(struct vm_area_struct *vma,
 			     unsigned long start, unsigned long end)
 {
 	*prev = vma;
-	if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
+	if (vma->vm_flags & (VM_LOCKED|VM_PFNMAP) ||
+		(vma->vm_flags & (VM_HUGETLB|VM_MERGEABLE)) == VM_HUGETLB)
 		return -EINVAL;
 
 	zap_page_range(vma, start, end - start, NULL);
@@ -299,7 +300,8 @@ static long madvise_remove(struct vm_area_struct *vma,
 
 	*prev = NULL;	/* tell sys_madvise we drop mmap_sem */
 
-	if (vma->vm_flags & (VM_LOCKED | VM_HUGETLB))
+	if (vma->vm_flags & VM_LOCKED ||
+		(vma->vm_flags & (VM_HUGETLB | VM_MERGEABLE)) == VM_HUGETLB)
 		return -EINVAL;
 
 	f = vma->vm_file;
diff --git a/mm/memory.c b/mm/memory.c
index 8068893..266456c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1021,8 +1021,9 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	 * readonly mappings. The tradeoff is that copy_page_range is more
 	 * efficient than faulting.
 	 */
-	if (!(vma->vm_flags & (VM_HUGETLB | VM_PFNMAP | VM_MIXEDMAP)) &&
-			!vma->anon_vma)
+	if (!(vma->vm_flags & (VM_PFNMAP | VM_MIXEDMAP) ||
+		(vma->vm_flags & (VM_HUGETLB | VM_MERGEABLE)) == VM_HUGETLB) &&
+		!vma->anon_vma)
 		return 0;
 
 	if (is_vm_hugetlb_page(vma))
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 4472781..09cce5b 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -273,8 +273,10 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 	 * even if read-only so there is no need to account for them here
 	 */
 	if (newflags & VM_WRITE) {
-		if (!(oldflags & (VM_ACCOUNT|VM_WRITE|VM_HUGETLB|
-						VM_SHARED|VM_NORESERVE))) {
+		if (!(oldflags &
+			(VM_ACCOUNT|VM_WRITE|VM_SHARED|VM_NORESERVE) ||
+			(oldflags & (VM_HUGETLB | VM_MERGEABLE)) ==
+							VM_HUGETLB)) {
 			charged = nrpages;
 			if (security_vm_enough_memory_mm(mm, charged))
 				return -ENOMEM;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
