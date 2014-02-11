Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 5BA726B0037
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 12:24:32 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id rd3so7979578pab.33
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 09:24:32 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id m8si19654087pbq.269.2014.02.11.09.24.29
        for <linux-mm@kvack.org>;
        Tue, 11 Feb 2014 09:24:31 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm, thp: fix infinite loop on memcg OOM
Date: Tue, 11 Feb 2014 19:24:11 +0200
Message-Id: <1392139451-15446-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: m.mizuma@jp.fujitsu.com, mhocko@suse.cz, aarcange@redhat.com, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Masayoshi Mizuma has reported bug with hung of application under memcg
limit. It happens on write-protection fault to huge zero page

If we successfully allocate huge page to replace zero page, but hit
memcg limit we need to split zero page with split_huge_page_pmd() and
fallback to small pages.

Other part problem is that VM_FAULT_OOM has special meaning in
do_huge_pmd_wp_page() context. __handle_mm_fault() expects the page to
be split if it see VM_FAULT_OOM and it will will retry page fault
handling. It causes infinite loop if the page was not split.

do_huge_pmd_wp_zero_page_fallback() can return VM_FAULT_OOM if it failed
to allocat one small page, so fallback to small pages will not help.

The solution for this part is to replace VM_FAULT_OOM with
VM_FAULT_FALLBACK is fallback required.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
---
 mm/huge_memory.c |  9 ++++++---
 mm/memory.c      | 14 +++-----------
 2 files changed, 9 insertions(+), 14 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 82166bf974e1..65a88bef8694 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1166,8 +1166,10 @@ alloc:
 		} else {
 			ret = do_huge_pmd_wp_page_fallback(mm, vma, address,
 					pmd, orig_pmd, page, haddr);
-			if (ret & VM_FAULT_OOM)
+			if (ret & VM_FAULT_OOM) {
 				split_huge_page(page);
+				ret |= VM_FAULT_FALLBACK;
+			}
 			put_page(page);
 		}
 		count_vm_event(THP_FAULT_FALLBACK);
@@ -1179,9 +1181,10 @@ alloc:
 		if (page) {
 			split_huge_page(page);
 			put_page(page);
-		}
+		} else
+			split_huge_page_pmd(vma, address, pmd);
+		ret |= VM_FAULT_FALLBACK;
 		count_vm_event(THP_FAULT_FALLBACK);
-		ret |= VM_FAULT_OOM;
 		goto out;
 	}
 
diff --git a/mm/memory.c b/mm/memory.c
index be6a0c0d4ae0..3b57b7864667 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3703,7 +3703,6 @@ static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (unlikely(is_vm_hugetlb_page(vma)))
 		return hugetlb_fault(mm, vma, address, flags);
 
-retry:
 	pgd = pgd_offset(mm, address);
 	pud = pud_alloc(mm, pgd, address);
 	if (!pud)
@@ -3741,20 +3740,13 @@ retry:
 			if (dirty && !pmd_write(orig_pmd)) {
 				ret = do_huge_pmd_wp_page(mm, vma, address, pmd,
 							  orig_pmd);
-				/*
-				 * If COW results in an oom, the huge pmd will
-				 * have been split, so retry the fault on the
-				 * pte for a smaller charge.
-				 */
-				if (unlikely(ret & VM_FAULT_OOM))
-					goto retry;
-				return ret;
+				if (!(ret & VM_FAULT_FALLBACK))
+					return ret;
 			} else {
 				huge_pmd_set_accessed(mm, vma, address, pmd,
 						      orig_pmd, dirty);
+				return 0;
 			}
-
-			return 0;
 		}
 	}
 
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
