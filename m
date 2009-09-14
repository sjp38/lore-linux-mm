Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9F8716B004D
	for <linux-mm@kvack.org>; Mon, 14 Sep 2009 01:18:48 -0400 (EDT)
Received: by yxe12 with SMTP id 12so3917977yxe.1
        for <linux-mm@kvack.org>; Sun, 13 Sep 2009 22:18:54 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 14 Sep 2009 17:18:53 +1200
Message-ID: <202cde0e0909132218k70c31a5u922636914e603ad4@mail.gmail.com>
Subject: [PATCH 2/3] Helper which returns the huge page at a given address
	(Take 3)
From: Alexey Korolev <akorolex@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Eric Munson <linux-mm@mgebm.net>, Alexey Korolev <akorolev@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This patch provides helper function which returns the huge page at a
given address for population before the page has been faulted.
It is possible to call hugetlb_get_user_page function in file mmap
procedure to get pages before they have been requested by user level.

include/linux/hugetlb.h |    3 +++
mm/hugetlb.c            |   23 +++++++++++++++++++++++
2 files changed, 26 insertions(+)

---
Signed-off-by: Alexey Korolev <akorolev@infradead.org>

diff -aurp clean/include/linux/hugetlb.h patched/include/linux/hugetlb.h
--- clean/include/linux/hugetlb.h	2009-09-11 15:33:48.000000000 +1200
+++ patched/include/linux/hugetlb.h	2009-09-11 20:09:02.000000000 +1200
@@ -39,6 +39,8 @@ int hugetlb_reserve_pages(struct inode *
 						struct vm_area_struct *vma,
 						int acctflags);
 void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed);
+struct page *hugetlb_get_user_page(struct vm_area_struct *vma,
+						unsigned long address);

 extern unsigned long hugepages_treat_as_movable;
 extern const unsigned long hugetlb_zero, hugetlb_infinity;
@@ -100,6 +102,7 @@ static inline void hugetlb_report_meminf
 #define is_hugepage_only_range(mm, addr, len)	0
 #define hugetlb_free_pgd_range(tlb, addr, end, floor, ceiling) ({BUG(); 0; })
 #define hugetlb_fault(mm, vma, addr, flags)	({ BUG(); 0; })
+#define hugetlb_get_user_page(vma, address)	ERR_PTR(-EINVAL)

 #define hugetlb_change_protection(vma, address, end, newprot)

diff -aurp clean/mm/hugetlb.c patched/mm/hugetlb.c
--- clean/mm/hugetlb.c	2009-09-06 11:38:12.000000000 +1200
+++ patched/mm/hugetlb.c	2009-09-11 08:34:00.000000000 +1200
@@ -2187,6 +2187,29 @@ static int huge_zeropage_ok(pte_t *ptep,
 		return huge_pte_none(huge_ptep_get(ptep));
 }

+/*
+ * hugetlb_get_user_page returns the page at a given address for population
+ * before the page has been faulted.
+ */
+struct page *hugetlb_get_user_page(struct vm_area_struct *vma,
+				    unsigned long address)
+{
+	int ret;
+	int cnt = 1;
+	struct page *pg;
+	struct hstate *h = hstate_vma(vma);
+
+	address = address & huge_page_mask(h);
+	ret = follow_hugetlb_page(vma->vm_mm, vma, &pg,
+				NULL, &address, &cnt, 0, 0);
+	if (ret < 0)
+		return ERR_PTR(ret);
+	put_page(pg);
+
+	return pg;
+}
+EXPORT_SYMBOL_GPL(hugetlb_get_user_page);
+
 int follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			struct page **pages, struct vm_area_struct **vmas,
 			unsigned long *position, int *length, int i,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
