Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 7FA0A6B0257
	for <linux-mm@kvack.org>; Tue,  4 Aug 2015 15:58:20 -0400 (EDT)
Received: by pawu10 with SMTP id u10so16015966paw.1
        for <linux-mm@kvack.org>; Tue, 04 Aug 2015 12:58:20 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id b8si804520pas.112.2015.08.04.12.58.13
        for <linux-mm@kvack.org>;
        Tue, 04 Aug 2015 12:58:13 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 02/11] thp: Change insert_pfn's return type to void
Date: Tue,  4 Aug 2015 15:57:56 -0400
Message-Id: <1438718285-21168-3-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1438718285-21168-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1438718285-21168-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Matthew Wilcox <willy@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

It would make more sense to have all the return values from
vmf_insert_pfn_pmd() encoded in one place instead of having to follow
the convention into insert_pfn().  Suggested by Jeff Moyer.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 mm/huge_memory.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 26d0fc1..5ffdcaa 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -837,7 +837,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	return 0;
 }
 
-static int insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
+static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 		pmd_t *pmd, unsigned long pfn, pgprot_t prot, bool write)
 {
 	struct mm_struct *mm = vma->vm_mm;
@@ -855,7 +855,6 @@ static int insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 		update_mmu_cache_pmd(vma, addr, pmd);
 	}
 	spin_unlock(ptl);
-	return VM_FAULT_NOPAGE;
 }
 
 int vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
@@ -877,7 +876,8 @@ int vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 		return VM_FAULT_SIGBUS;
 	if (track_pfn_insert(vma, &pgprot, pfn))
 		return VM_FAULT_SIGBUS;
-	return insert_pfn_pmd(vma, addr, pmd, pfn, pgprot, write);
+	insert_pfn_pmd(vma, addr, pmd, pfn, pgprot, write);
+	return VM_FAULT_NOPAGE;
 }
 
 int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
