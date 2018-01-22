Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2685C800D8
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 04:22:40 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id m3so8209494pgd.20
        for <linux-mm@kvack.org>; Mon, 22 Jan 2018 01:22:40 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id u14si6084548pgo.695.2018.01.22.01.22.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jan 2018 01:22:38 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm, page_vma_mapped: Introduce pfn_in_hpage()
Date: Mon, 22 Jan 2018 12:22:30 +0300
Message-Id: <20180122092230.42908-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@kernel.org, penguin-kernel@I-love.SAKURA.ne.jp, torvalds@linux-foundation.org, aarcange@redhat.com, dave.hansen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The new helper would check if the pfn belongs to the page. For huge
pages it checks if the PFN is within range covered by the huge page.

The helper is used in check_pte(). The original code the helper replaces
had two call to page_to_pfn(). page_to_pfn() is relatively costly.

Although current GCC is able to optimize code to have one call, it's
better to do this explicitly.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/page_vma_mapped.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/mm/page_vma_mapped.c b/mm/page_vma_mapped.c
index 956015614395..ae3c2a35d61b 100644
--- a/mm/page_vma_mapped.c
+++ b/mm/page_vma_mapped.c
@@ -30,6 +30,14 @@ static bool map_pte(struct page_vma_mapped_walk *pvmw)
 	return true;
 }
 
+static inline bool pfn_in_hpage(struct page *hpage, unsigned long pfn)
+{
+	unsigned long hpage_pfn = page_to_pfn(hpage);
+
+	/* THP can be referenced by any subpage */
+	return pfn >= hpage_pfn && pfn - hpage_pfn < hpage_nr_pages(hpage);
+}
+
 /**
  * check_pte - check if @pvmw->page is mapped at the @pvmw->pte
  *
@@ -78,14 +86,7 @@ static bool check_pte(struct page_vma_mapped_walk *pvmw)
 		pfn = pte_pfn(*pvmw->pte);
 	}
 
-	if (pfn < page_to_pfn(pvmw->page))
-		return false;
-
-	/* THP can be referenced by any subpage */
-	if (pfn - page_to_pfn(pvmw->page) >= hpage_nr_pages(pvmw->page))
-		return false;
-
-	return true;
+	return pfn_in_hpage(pvmw->page, pfn);
 }
 
 /**
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
