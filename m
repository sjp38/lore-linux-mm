Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6130C6B0038
	for <linux-mm@kvack.org>; Thu, 28 Aug 2014 21:52:45 -0400 (EDT)
Received: by mail-qg0-f47.google.com with SMTP id z60so1660140qgd.34
        for <linux-mm@kvack.org>; Thu, 28 Aug 2014 18:52:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 20si8512105qgo.58.2014.08.28.18.52.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Aug 2014 18:52:44 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v3 6/6] mm/hugetlb: remove unused argument of follow_huge_addr()
Date: Thu, 28 Aug 2014 21:39:00 -0400
Message-Id: <1409276340-7054-7-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1409276340-7054-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1409276340-7054-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

follow_huge_addr()'s parameter write is not used, so let's remove it.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 arch/ia64/mm/hugetlbpage.c    | 2 +-
 arch/powerpc/mm/hugetlbpage.c | 2 +-
 arch/x86/mm/hugetlbpage.c     | 2 +-
 include/linux/hugetlb.h       | 5 ++---
 mm/gup.c                      | 2 +-
 mm/hugetlb.c                  | 3 +--
 6 files changed, 7 insertions(+), 9 deletions(-)

diff --git mmotm-2014-08-25-16-52.orig/arch/ia64/mm/hugetlbpage.c mmotm-2014-08-25-16-52/arch/ia64/mm/hugetlbpage.c
index 6170381bf074..524a4e001bda 100644
--- mmotm-2014-08-25-16-52.orig/arch/ia64/mm/hugetlbpage.c
+++ mmotm-2014-08-25-16-52/arch/ia64/mm/hugetlbpage.c
@@ -89,7 +89,7 @@ int prepare_hugepage_range(struct file *file,
 	return 0;
 }
 
-struct page *follow_huge_addr(struct mm_struct *mm, unsigned long addr, int write)
+struct page *follow_huge_addr(struct mm_struct *mm, unsigned long addr)
 {
 	struct page *page = NULL;
 	pte_t *ptep;
diff --git mmotm-2014-08-25-16-52.orig/arch/powerpc/mm/hugetlbpage.c mmotm-2014-08-25-16-52/arch/powerpc/mm/hugetlbpage.c
index 1d8854a56309..5b6fe8b0cde3 100644
--- mmotm-2014-08-25-16-52.orig/arch/powerpc/mm/hugetlbpage.c
+++ mmotm-2014-08-25-16-52/arch/powerpc/mm/hugetlbpage.c
@@ -674,7 +674,7 @@ void hugetlb_free_pgd_range(struct mmu_gather *tlb,
 }
 
 struct page *
-follow_huge_addr(struct mm_struct *mm, unsigned long address, int write)
+follow_huge_addr(struct mm_struct *mm, unsigned long address)
 {
 	pte_t *ptep;
 	struct page *page = ERR_PTR(-EINVAL);
diff --git mmotm-2014-08-25-16-52.orig/arch/x86/mm/hugetlbpage.c mmotm-2014-08-25-16-52/arch/x86/mm/hugetlbpage.c
index 03b8a7c11817..cab09d87ae65 100644
--- mmotm-2014-08-25-16-52.orig/arch/x86/mm/hugetlbpage.c
+++ mmotm-2014-08-25-16-52/arch/x86/mm/hugetlbpage.c
@@ -18,7 +18,7 @@
 
 #if 0	/* This is just for testing */
 struct page *
-follow_huge_addr(struct mm_struct *mm, unsigned long address, int write)
+follow_huge_addr(struct mm_struct *mm, unsigned long address)
 {
 	unsigned long start = address;
 	int length = 1;
diff --git mmotm-2014-08-25-16-52.orig/include/linux/hugetlb.h mmotm-2014-08-25-16-52/include/linux/hugetlb.h
index b3200fce07aa..cdff1bd393bb 100644
--- mmotm-2014-08-25-16-52.orig/include/linux/hugetlb.h
+++ mmotm-2014-08-25-16-52/include/linux/hugetlb.h
@@ -96,8 +96,7 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
 			unsigned long addr, unsigned long sz);
 pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr);
 int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep);
-struct page *follow_huge_addr(struct mm_struct *mm, unsigned long address,
-			      int write);
+struct page *follow_huge_addr(struct mm_struct *mm, unsigned long address);
 struct page *follow_huge_pmd(struct vm_area_struct *vma, unsigned long address,
 				pmd_t *pmd, int flags);
 struct page *follow_huge_pud(struct vm_area_struct *vma, unsigned long address,
@@ -124,7 +123,7 @@ static inline unsigned long hugetlb_total_pages(void)
 }
 
 #define follow_hugetlb_page(m,v,p,vs,a,b,i,w)	({ BUG(); 0; })
-#define follow_huge_addr(mm, addr, write)	ERR_PTR(-EINVAL)
+#define follow_huge_addr(mm, addr)	ERR_PTR(-EINVAL)
 #define copy_hugetlb_page_range(src, dst, vma)	({ BUG(); 0; })
 static inline void hugetlb_report_meminfo(struct seq_file *m)
 {
diff --git mmotm-2014-08-25-16-52.orig/mm/gup.c mmotm-2014-08-25-16-52/mm/gup.c
index 597a5e92e265..8f0550f1770d 100644
--- mmotm-2014-08-25-16-52.orig/mm/gup.c
+++ mmotm-2014-08-25-16-52/mm/gup.c
@@ -149,7 +149,7 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 
 	*page_mask = 0;
 
-	page = follow_huge_addr(mm, address, flags & FOLL_WRITE);
+	page = follow_huge_addr(mm, address);
 	if (!IS_ERR(page)) {
 		BUG_ON(flags & FOLL_GET);
 		return page;
diff --git mmotm-2014-08-25-16-52.orig/mm/hugetlb.c mmotm-2014-08-25-16-52/mm/hugetlb.c
index 0a4511115ee0..f7dcad3474ec 100644
--- mmotm-2014-08-25-16-52.orig/mm/hugetlb.c
+++ mmotm-2014-08-25-16-52/mm/hugetlb.c
@@ -3690,8 +3690,7 @@ pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
  * behavior.
  */
 struct page * __weak
-follow_huge_addr(struct mm_struct *mm, unsigned long address,
-			      int write)
+follow_huge_addr(struct mm_struct *mm, unsigned long address)
 {
 	return ERR_PTR(-EINVAL);
 }
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
