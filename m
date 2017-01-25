Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5DA636B026A
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 13:27:02 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 75so281627355pgf.3
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 10:27:02 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id g21si6581708pgh.125.2017.01.25.10.27.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 10:27:01 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 04/12] mm: fix handling PTE-mapped THPs in page_idle_clear_pte_refs()
Date: Wed, 25 Jan 2017 21:25:30 +0300
Message-Id: <20170125182538.86249-5-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170125182538.86249-1-kirill.shutemov@linux.intel.com>
References: <20170125182538.86249-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>

For PTE-mapped THP page_check_address_transhuge() is not adequate: it
cannot find all relevant PTEs, only the first one.i

Let's switch it to page_vma_mapped_walk().

I don't think it's subject for stable@: it's not fatal.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
---
 mm/page_idle.c | 34 +++++++++++++++++-----------------
 1 file changed, 17 insertions(+), 17 deletions(-)

diff --git a/mm/page_idle.c b/mm/page_idle.c
index ae11aa914e55..b0ee56c56b58 100644
--- a/mm/page_idle.c
+++ b/mm/page_idle.c
@@ -54,27 +54,27 @@ static int page_idle_clear_pte_refs_one(struct page *page,
 					struct vm_area_struct *vma,
 					unsigned long addr, void *arg)
 {
-	struct mm_struct *mm = vma->vm_mm;
-	pmd_t *pmd;
-	pte_t *pte;
-	spinlock_t *ptl;
+	struct page_vma_mapped_walk pvmw = {
+		.page = page,
+		.vma = vma,
+		.address = addr,
+	};
 	bool referenced = false;
 
-	if (!page_check_address_transhuge(page, mm, addr, &pmd, &pte, &ptl))
-		return SWAP_AGAIN;
-
-	if (pte) {
-		referenced = ptep_clear_young_notify(vma, addr, pte);
-		pte_unmap(pte);
-	} else if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE)) {
-		referenced = pmdp_clear_young_notify(vma, addr, pmd);
-	} else {
-		/* unexpected pmd-mapped page? */
-		WARN_ON_ONCE(1);
+	while (page_vma_mapped_walk(&pvmw)) {
+		addr = pvmw.address;
+		if (pvmw.pte) {
+			referenced = ptep_clear_young_notify(vma, addr,
+					pvmw.pte);
+		} else if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE)) {
+			referenced = pmdp_clear_young_notify(vma, addr,
+					pvmw.pmd);
+		} else {
+			/* unexpected pmd-mapped page? */
+			WARN_ON_ONCE(1);
+		}
 	}
 
-	spin_unlock(ptl);
-
 	if (referenced) {
 		clear_page_idle(page);
 		/*
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
