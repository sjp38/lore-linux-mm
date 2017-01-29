Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1B81B6B027A
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 12:39:08 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 14so426383024pgg.4
        for <linux-mm@kvack.org>; Sun, 29 Jan 2017 09:39:08 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 85si10247570pfq.219.2017.01.29.09.39.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Jan 2017 09:39:07 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 04/12] mm: fix handling PTE-mapped THPs in page_idle_clear_pte_refs()
Date: Sun, 29 Jan 2017 20:38:50 +0300
Message-Id: <20170129173858.45174-5-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170129173858.45174-1-kirill.shutemov@linux.intel.com>
References: <20170129173858.45174-1-kirill.shutemov@linux.intel.com>
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
