Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id F272E6B0292
	for <linux-mm@kvack.org>; Tue, 18 Jul 2017 15:40:13 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id h2so21550203uaf.5
        for <linux-mm@kvack.org>; Tue, 18 Jul 2017 12:40:13 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 4si1210138vko.190.2017.07.18.12.40.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jul 2017 12:40:13 -0700 (PDT)
From: daniel.m.jordan@oracle.com
Subject: [PATCH] mm/hugetlb: __get_user_pages ignores certain follow_hugetlb_page errors
Date: Tue, 18 Jul 2017 12:39:55 -0700
Message-Id: <1500406795-58462-1-git-send-email-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: aarcange@redhat.com, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, james.morse@arm.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, punit.agrawal@arm.com, zhongjiang@huawei.com, linux-kernel@vger.kernel.org

Commit 9a291a7c9428 ("mm/hugetlb: report -EHWPOISON not -EFAULT when
FOLL_HWPOISON is specified") causes __get_user_pages to ignore certain
errors from follow_hugetlb_page.  After such error, __get_user_pages
subsequently calls faultin_page on the same VMA and start address that
follow_hugetlb_page failed on instead of returning the error immediately
as it should.

In follow_hugetlb_page, when hugetlb_fault returns a value covered under
VM_FAULT_ERROR, follow_hugetlb_page returns it without setting nr_pages
to 0 as __get_user_pages expects in this case, which causes the
following to happen in __get_user_pages: the "while (nr_pages)" check
succeeds, we skip the "if (!vma..." check because we got a VMA the last
time around, we find no page with follow_page_mask, and we call
faultin_page, which calls hugetlb_fault for the second time.

This issue also slightly changes how __get_user_pages works.  Before, it
only returned error if it had made no progress (i = 0).  But now,
follow_hugetlb_page can clobber "i" with an error code since its new
return path doesn't check for progress.  So if "i" is nonzero before a
failing call to follow_hugetlb_page, that indication of progress is lost
and __get_user_pages can return error even if some pages were
successfully pinned.

To fix this, change follow_hugetlb_page so that it updates nr_pages,
allowing __get_user_pages to fail immediately and restoring the "error
only if no progress" behavior to __get_user_pages.

Tested that __get_user_pages returns when expected on error from
hugetlb_fault in follow_hugetlb_page.

Fixes: 9a291a7c9428 ("mm/hugetlb: report -EHWPOISON not -EFAULT when FOLL_HWPOISON is specified")
Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: James Morse <james.morse@arm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Punit Agrawal <punit.agrawal@arm.com>
Cc: zhong jiang <zhongjiang@huawei.com>
---
 mm/hugetlb.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3eedb18..cc28993 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4095,6 +4095,7 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	unsigned long vaddr = *position;
 	unsigned long remainder = *nr_pages;
 	struct hstate *h = hstate_vma(vma);
+	int err = -EFAULT;
 
 	while (vaddr < vma->vm_end && remainder) {
 		pte_t *pte;
@@ -4170,11 +4171,7 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			}
 			ret = hugetlb_fault(mm, vma, vaddr, fault_flags);
 			if (ret & VM_FAULT_ERROR) {
-				int err = vm_fault_to_errno(ret, flags);
-
-				if (err)
-					return err;
-
+				err = vm_fault_to_errno(ret, flags);
 				remainder = 0;
 				break;
 			}
@@ -4229,7 +4226,7 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	 */
 	*position = vaddr;
 
-	return i ? i : -EFAULT;
+	return i ? i : err;
 }
 
 #ifndef __HAVE_ARCH_FLUSH_HUGETLB_TLB_RANGE
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
