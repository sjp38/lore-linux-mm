Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id CDE636B0036
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 14:20:42 -0400 (EDT)
Received: by mail-qg0-f53.google.com with SMTP id q107so9087687qgd.12
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 11:20:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i8si1226697qch.24.2014.07.28.11.20.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jul 2014 11:20:41 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 1/3] mm/hugetlb: replace parameters of follow_huge_pmd/pud()
Date: Mon, 28 Jul 2014 14:08:29 -0400
Message-Id: <1406570911-28133-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

Currently follow_huge_pmd() and follow_huge_pud() don't use the parameter
mm or write. So let's change these to vma and flags as a preparation for
the next patch. No behavioral change.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 arch/ia64/mm/hugetlbpage.c    |  3 ++-
 arch/metag/mm/hugetlbpage.c   |  4 ++--
 arch/mips/mm/hugetlbpage.c    |  4 ++--
 arch/powerpc/mm/hugetlbpage.c |  4 ++--
 arch/s390/mm/hugetlbpage.c    |  4 ++--
 arch/sh/mm/hugetlbpage.c      |  4 ++--
 arch/sparc/mm/hugetlbpage.c   |  4 ++--
 arch/tile/mm/hugetlbpage.c    |  8 ++++----
 arch/x86/mm/hugetlbpage.c     |  4 ++--
 include/linux/hugetlb.h       | 12 ++++++------
 mm/gup.c                      |  4 ++--
 mm/hugetlb.c                  | 12 ++++++------
 12 files changed, 34 insertions(+), 33 deletions(-)

diff --git mmotm-2014-07-22-15-58.orig/arch/ia64/mm/hugetlbpage.c mmotm-2014-07-22-15-58/arch/ia64/mm/hugetlbpage.c
index 76069c18ee42..ce67cf227c37 100644
--- mmotm-2014-07-22-15-58.orig/arch/ia64/mm/hugetlbpage.c
+++ mmotm-2014-07-22-15-58/arch/ia64/mm/hugetlbpage.c
@@ -115,7 +115,8 @@ int pud_huge(pud_t pud)
 }
 
 struct page *
-follow_huge_pmd(struct mm_struct *mm, unsigned long address, pmd_t *pmd, int write)
+follow_huge_pmd(struct vm_area_struct *vma, unsigned long address,
+		pmd_t *pmd, int flags)
 {
 	return NULL;
 }
diff --git mmotm-2014-07-22-15-58.orig/arch/metag/mm/hugetlbpage.c mmotm-2014-07-22-15-58/arch/metag/mm/hugetlbpage.c
index 3c52fa6d0f8e..55d1be14cecf 100644
--- mmotm-2014-07-22-15-58.orig/arch/metag/mm/hugetlbpage.c
+++ mmotm-2014-07-22-15-58/arch/metag/mm/hugetlbpage.c
@@ -110,8 +110,8 @@ int pud_huge(pud_t pud)
 	return 0;
 }
 
-struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-			     pmd_t *pmd, int write)
+struct page *follow_huge_pmd(struct vm_area_struct *vma, unsigned long address,
+			     pmd_t *pmd, int flags)
 {
 	return NULL;
 }
diff --git mmotm-2014-07-22-15-58.orig/arch/mips/mm/hugetlbpage.c mmotm-2014-07-22-15-58/arch/mips/mm/hugetlbpage.c
index 4ec8ee10d371..3b1fb97f2fa9 100644
--- mmotm-2014-07-22-15-58.orig/arch/mips/mm/hugetlbpage.c
+++ mmotm-2014-07-22-15-58/arch/mips/mm/hugetlbpage.c
@@ -85,8 +85,8 @@ int pud_huge(pud_t pud)
 }
 
 struct page *
-follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-		pmd_t *pmd, int write)
+follow_huge_pmd(struct vm_area_struct *vma, unsigned long address,
+		pmd_t *pmd, int flags)
 {
 	struct page *page;
 
diff --git mmotm-2014-07-22-15-58.orig/arch/powerpc/mm/hugetlbpage.c mmotm-2014-07-22-15-58/arch/powerpc/mm/hugetlbpage.c
index 7e70ae968e5f..3d366b06e0c7 100644
--- mmotm-2014-07-22-15-58.orig/arch/powerpc/mm/hugetlbpage.c
+++ mmotm-2014-07-22-15-58/arch/powerpc/mm/hugetlbpage.c
@@ -699,8 +699,8 @@ follow_huge_addr(struct mm_struct *mm, unsigned long address, int write)
 }
 
 struct page *
-follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-		pmd_t *pmd, int write)
+follow_huge_pmd(struct vm_area_struct *vma, unsigned long address,
+		pmd_t *pmd, int flags)
 {
 	BUG();
 	return NULL;
diff --git mmotm-2014-07-22-15-58.orig/arch/s390/mm/hugetlbpage.c mmotm-2014-07-22-15-58/arch/s390/mm/hugetlbpage.c
index 0ff66a7e29bb..c41f51585309 100644
--- mmotm-2014-07-22-15-58.orig/arch/s390/mm/hugetlbpage.c
+++ mmotm-2014-07-22-15-58/arch/s390/mm/hugetlbpage.c
@@ -220,8 +220,8 @@ int pud_huge(pud_t pud)
 	return 0;
 }
 
-struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-			     pmd_t *pmdp, int write)
+struct page *follow_huge_pmd(struct vm_area_struct *vma, unsigned long address,
+			     pmd_t *pmdp, int flags)
 {
 	struct page *page;
 
diff --git mmotm-2014-07-22-15-58.orig/arch/sh/mm/hugetlbpage.c mmotm-2014-07-22-15-58/arch/sh/mm/hugetlbpage.c
index d7762349ea48..21e8362d535b 100644
--- mmotm-2014-07-22-15-58.orig/arch/sh/mm/hugetlbpage.c
+++ mmotm-2014-07-22-15-58/arch/sh/mm/hugetlbpage.c
@@ -83,8 +83,8 @@ int pud_huge(pud_t pud)
 	return 0;
 }
 
-struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-			     pmd_t *pmd, int write)
+struct page *follow_huge_pmd(struct vm_area_struct *vma, unsigned long address,
+			     pmd_t *pmd, int flags)
 {
 	return NULL;
 }
diff --git mmotm-2014-07-22-15-58.orig/arch/sparc/mm/hugetlbpage.c mmotm-2014-07-22-15-58/arch/sparc/mm/hugetlbpage.c
index d329537739c6..f99dc9097261 100644
--- mmotm-2014-07-22-15-58.orig/arch/sparc/mm/hugetlbpage.c
+++ mmotm-2014-07-22-15-58/arch/sparc/mm/hugetlbpage.c
@@ -231,8 +231,8 @@ int pud_huge(pud_t pud)
 	return 0;
 }
 
-struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-			     pmd_t *pmd, int write)
+struct page *follow_huge_pmd(struct vm_area_struct *vma, unsigned long address,
+			     pmd_t *pmd, int flags)
 {
 	return NULL;
 }
diff --git mmotm-2014-07-22-15-58.orig/arch/tile/mm/hugetlbpage.c mmotm-2014-07-22-15-58/arch/tile/mm/hugetlbpage.c
index e514899e1100..2eb1df67cb7d 100644
--- mmotm-2014-07-22-15-58.orig/arch/tile/mm/hugetlbpage.c
+++ mmotm-2014-07-22-15-58/arch/tile/mm/hugetlbpage.c
@@ -166,8 +166,8 @@ int pud_huge(pud_t pud)
 	return !!(pud_val(pud) & _PAGE_HUGE_PAGE);
 }
 
-struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-			     pmd_t *pmd, int write)
+struct page *follow_huge_pmd(struct vm_area_struct *vma, unsigned long address,
+			     pmd_t *pmd, int flags)
 {
 	struct page *page;
 
@@ -177,8 +177,8 @@ struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 	return page;
 }
 
-struct page *follow_huge_pud(struct mm_struct *mm, unsigned long address,
-			     pud_t *pud, int write)
+struct page *follow_huge_pud(struct vm_area_struct *vma, unsigned long address,
+			     pud_t *pud, int flags)
 {
 	struct page *page;
 
diff --git mmotm-2014-07-22-15-58.orig/arch/x86/mm/hugetlbpage.c mmotm-2014-07-22-15-58/arch/x86/mm/hugetlbpage.c
index 8b977ebf9388..416c416357df 100644
--- mmotm-2014-07-22-15-58.orig/arch/x86/mm/hugetlbpage.c
+++ mmotm-2014-07-22-15-58/arch/x86/mm/hugetlbpage.c
@@ -53,8 +53,8 @@ int pud_huge(pud_t pud)
 }
 
 struct page *
-follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-		pmd_t *pmd, int write)
+follow_huge_pmd(struct vm_area_struct *vma, unsigned long address,
+		pmd_t *pmd, int flags)
 {
 	return NULL;
 }
diff --git mmotm-2014-07-22-15-58.orig/include/linux/hugetlb.h mmotm-2014-07-22-15-58/include/linux/hugetlb.h
index 41272bcf73f8..647cc4821ac2 100644
--- mmotm-2014-07-22-15-58.orig/include/linux/hugetlb.h
+++ mmotm-2014-07-22-15-58/include/linux/hugetlb.h
@@ -97,10 +97,10 @@ pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr);
 int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep);
 struct page *follow_huge_addr(struct mm_struct *mm, unsigned long address,
 			      int write);
-struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-				pmd_t *pmd, int write);
-struct page *follow_huge_pud(struct mm_struct *mm, unsigned long address,
-				pud_t *pud, int write);
+struct page *follow_huge_pmd(struct vm_area_struct *vma, unsigned long address,
+				pmd_t *pmd, int flags);
+struct page *follow_huge_pud(struct vm_area_struct *vma, unsigned long address,
+				pud_t *pud, int flags);
 int pmd_huge(pmd_t pmd);
 int pud_huge(pud_t pmd);
 unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
@@ -132,8 +132,8 @@ static inline void hugetlb_report_meminfo(struct seq_file *m)
 static inline void hugetlb_show_meminfo(void)
 {
 }
-#define follow_huge_pmd(mm, addr, pmd, write)	NULL
-#define follow_huge_pud(mm, addr, pud, write)	NULL
+#define follow_huge_pmd(vma, addr, pmd, flags)	NULL
+#define follow_huge_pud(vma, addr, pud, flags)	NULL
 #define prepare_hugepage_range(file, addr, len)	(-EINVAL)
 #define pmd_huge(x)	0
 #define pud_huge(x)	0
diff --git mmotm-2014-07-22-15-58.orig/mm/gup.c mmotm-2014-07-22-15-58/mm/gup.c
index 91d044b1600d..ba2c933625b2 100644
--- mmotm-2014-07-22-15-58.orig/mm/gup.c
+++ mmotm-2014-07-22-15-58/mm/gup.c
@@ -165,7 +165,7 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 	if (pud_huge(*pud) && vma->vm_flags & VM_HUGETLB) {
 		if (flags & FOLL_GET)
 			return NULL;
-		page = follow_huge_pud(mm, address, pud, flags & FOLL_WRITE);
+		page = follow_huge_pud(vma, address, pud, flags);
 		return page;
 	}
 	if (unlikely(pud_bad(*pud)))
@@ -175,7 +175,7 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 	if (pmd_none(*pmd))
 		return no_page_table(vma, flags);
 	if (pmd_huge(*pmd) && vma->vm_flags & VM_HUGETLB) {
-		page = follow_huge_pmd(mm, address, pmd, flags & FOLL_WRITE);
+		page = follow_huge_pmd(vma, address, pmd, flags);
 		if (flags & FOLL_GET) {
 			/*
 			 * Refcount on tail pages are not well-defined and
diff --git mmotm-2014-07-22-15-58.orig/mm/hugetlb.c mmotm-2014-07-22-15-58/mm/hugetlb.c
index 7263c770e9b3..ade297a9c519 100644
--- mmotm-2014-07-22-15-58.orig/mm/hugetlb.c
+++ mmotm-2014-07-22-15-58/mm/hugetlb.c
@@ -3651,8 +3651,8 @@ pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
 }
 
 struct page *
-follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-		pmd_t *pmd, int write)
+follow_huge_pmd(struct vm_area_struct *vma, unsigned long address,
+		pmd_t *pmd, int flags)
 {
 	struct page *page;
 
@@ -3663,8 +3663,8 @@ follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 }
 
 struct page *
-follow_huge_pud(struct mm_struct *mm, unsigned long address,
-		pud_t *pud, int write)
+follow_huge_pud(struct vm_area_struct *vma, unsigned long address,
+		pud_t *pud, int flags)
 {
 	struct page *page;
 
@@ -3678,8 +3678,8 @@ follow_huge_pud(struct mm_struct *mm, unsigned long address,
 
 /* Can be overriden by architectures */
 struct page * __weak
-follow_huge_pud(struct mm_struct *mm, unsigned long address,
-	       pud_t *pud, int write)
+follow_huge_pud(struct vm_area_struct *vma, unsigned long address,
+	       pud_t *pud, int flags)
 {
 	BUG();
 	return NULL;
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
