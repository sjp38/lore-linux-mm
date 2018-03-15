Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id B2B4F6B0007
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 11:26:04 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id z3-v6so3367169pln.23
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 08:26:04 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id b69si3964739pfe.254.2018.03.15.08.26.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Mar 2018 08:26:03 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm/khugepaged: Convert VM_BUG_ON() to collapse fail
Date: Thu, 15 Mar 2018 18:23:53 +0300
Message-Id: <20180315152353.27989-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Laura Abbott <labbott@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

khugepaged is not yet able to convert PTE-mapped huge pages back to PMD
mapped. We do not collapse such pages. See check khugepaged_scan_pmd().

But if between khugepaged_scan_pmd() and __collapse_huge_page_isolate()
somebody managed to instantiate THP in the range and then split the PMD
back to PTEs we would have a problem -- VM_BUG_ON_PAGE(PageCompound(page))
will get triggered.

It's possible since we drop mmap_sem during collapse to re-take for
write.

Replace the VM_BUG_ON() with graceful collapse fail.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Fixes: b1caa957ae6d ("khugepaged: ignore pmd tables with THP mapped with ptes")
---
 mm/khugepaged.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index b7e2268dfc9a..c15da1ea7e63 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -530,7 +530,12 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 			goto out;
 		}
 
-		VM_BUG_ON_PAGE(PageCompound(page), page);
+		/* TODO: teach khugepaged to collapse THP mapped with pte */
+		if (PageCompound(page)) {
+			result = SCAN_PAGE_COMPOUND;
+			goto out;
+		}
+
 		VM_BUG_ON_PAGE(!PageAnon(page), page);
 
 		/*
-- 
2.16.1
