Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 3C6FD6B025E
	for <linux-mm@kvack.org>; Tue,  4 Aug 2015 15:58:35 -0400 (EDT)
Received: by pdber20 with SMTP id er20so8344053pdb.1
        for <linux-mm@kvack.org>; Tue, 04 Aug 2015 12:58:35 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id b8si804520pas.112.2015.08.04.12.58.13
        for <linux-mm@kvack.org>;
        Tue, 04 Aug 2015 12:58:14 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 07/11] thp: Decrement refcount on huge zero page if it is split
Date: Tue,  4 Aug 2015 15:58:01 -0400
Message-Id: <1438718285-21168-8-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1438718285-21168-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1438718285-21168-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, willy@linux.intel.com

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The DAX code neglected to put the refcount on the huge zero page.
Also we must notify on splits.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 mm/huge_memory.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 5ffdcaa..326d17e 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2951,7 +2951,9 @@ again:
 	if (unlikely(!pmd_trans_huge(*pmd)))
 		goto unlock;
 	if (vma_is_dax(vma)) {
-		pmdp_huge_clear_flush(vma, haddr, pmd);
+		pmd_t _pmd = pmdp_huge_clear_flush_notify(vma, haddr, pmd);
+		if (is_huge_zero_pmd(_pmd))
+			put_huge_zero_page();
 	} else if (is_huge_zero_pmd(*pmd)) {
 		__split_huge_zero_page_pmd(vma, haddr, pmd);
 	} else {
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
