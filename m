Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 35C696B0006
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 17:41:23 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g20-v6so2122155pfi.2
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 14:41:23 -0700 (PDT)
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id i5-v6si5233845pfe.27.2018.06.21.14.41.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jun 2018 14:41:22 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [PATCH] mm: thp: register mm for khugepaged when merging vma for shmem
Date: Fri, 22 Jun 2018 05:40:47 +0800
Message-Id: <1529617247-126312-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com, kirill.shutemov@linux.intel.com, vbabka@suse.cz, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When merging anonymous page vma, if the size of vam can fit in at least
one hugepage, the mm will be registered for khugepaged for collapsing
THP in the future.

But, it skips shmem vma. Doing so for shmem too when merging vma in
order to increase the odd to collapse hugepage by khugepaged.

Also increase the count of shmem THP collapse. It looks missed before.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
---
 mm/khugepaged.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index d7b2a4b..27f5ce2 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -440,8 +440,12 @@ int khugepaged_enter_vma_merge(struct vm_area_struct *vma,
 		 * page fault if needed.
 		 */
 		return 0;
-	if (vma->vm_ops || (vm_flags & VM_NO_KHUGEPAGED))
-		/* khugepaged not yet working on file or special mappings */
+	if ((vma->vm_ops && !shmem_file(vma->vm_file)) ||
+	    (vm_flags & VM_NO_KHUGEPAGED))
+		/*
+		 * khugepaged not yet working on non-shmem file or special
+		 * mappings
+		 */
 		return 0;
 	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
 	hend = vma->vm_end & HPAGE_PMD_MASK;
@@ -1517,6 +1521,8 @@ static void collapse_shmem(struct mm_struct *mm,
 		unlock_page(new_page);
 
 		*hpage = NULL;
+
+		khugepaged_pages_collapsed++;
 	} else {
 		/* Something went wrong: rollback changes to the radix-tree */
 		shmem_uncharge(mapping->host, nr_none);
-- 
1.8.3.1
