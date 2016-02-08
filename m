Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 1968C828E2
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 18:49:08 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id c10so50666091pfc.2
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 15:49:08 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id wc6si49585997pab.33.2016.02.08.15.49.07
        for <linux-mm@kvack.org>;
        Mon, 08 Feb 2016 15:49:07 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm, dax: check for pmd_none() after split_huge_pmd()
Date: Tue,  9 Feb 2016 02:48:32 +0300
Message-Id: <1454975312-27120-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <willy@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

DAX implements split_huge_pmd() by clearing pmd. This simple approach
reduces memory overhead, as we don't need to deposit page table on huge
page mapping to make split_huge_pmd() never-fail. PTE table can be
allocated and populated later on page fault from backing store.

But one side effect is that have to check if pmd is pmd_none() after
split_huge_pmd(). In most places we do this already to deal with
parallel MADV_DONTNEED.

But I found two call sites which is not affected by MADV_DONTNEED
(due down_write(mmap_sem)), but need to have the check to work with
DAX properly.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/mprotect.c | 6 ++++--
 mm/mremap.c   | 2 ++
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index 1b9597f05d7d..6ff5dfa65b33 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -160,9 +160,11 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		}
 
 		if (pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
-			if (next - addr != HPAGE_PMD_SIZE)
+			if (next - addr != HPAGE_PMD_SIZE) {
 				split_huge_pmd(vma, pmd, addr);
-			else {
+				if (pmd_none(*pmd))
+					continue;
+			} else {
 				int nr_ptes = change_huge_pmd(vma, pmd, addr,
 						newprot, prot_numa);
 
diff --git a/mm/mremap.c b/mm/mremap.c
index f1d18f8baa35..b43027a25982 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -220,6 +220,8 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 				}
 			}
 			split_huge_pmd(vma, old_pmd, old_addr);
+			if (pmd_none(*old_pmd))
+				continue;
 			VM_BUG_ON(pmd_trans_huge(*old_pmd));
 		}
 		if (pmd_none(*new_pmd) && __pte_alloc(new_vma->vm_mm, new_vma,
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
