Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 34AC86B027B
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 12:39:08 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id d185so424441857pgc.2
        for <linux-mm@kvack.org>; Sun, 29 Jan 2017 09:39:08 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id r5si6594539pgn.172.2017.01.29.09.39.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Jan 2017 09:39:07 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 03/12] mm: fix handling PTE-mapped THPs in page_referenced()
Date: Sun, 29 Jan 2017 20:38:49 +0300
Message-Id: <20170129173858.45174-4-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170129173858.45174-1-kirill.shutemov@linux.intel.com>
References: <20170129173858.45174-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For PTE-mapped THP page_check_address_transhuge() is not adequate: it
cannot find all relevant PTEs, only the first one. It means we can miss
some references of the page and it can result in suboptimal decisions by
vmscan.

Let's switch it to page_vma_mapped_walk().

I don't think it's subject for stable@: it's not fatal. The only side
effect is that THP can be swapped out when it shouldn't.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/rmap.c | 66 ++++++++++++++++++++++++++++++++-------------------------------
 1 file changed, 34 insertions(+), 32 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 91619fd70939..0dff8accd629 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -886,45 +886,48 @@ struct page_referenced_arg {
 static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 			unsigned long address, void *arg)
 {
-	struct mm_struct *mm = vma->vm_mm;
 	struct page_referenced_arg *pra = arg;
-	pmd_t *pmd;
-	pte_t *pte;
-	spinlock_t *ptl;
+	struct page_vma_mapped_walk pvmw = {
+		.page = page,
+		.vma = vma,
+		.address = address,
+	};
 	int referenced = 0;
 
-	if (!page_check_address_transhuge(page, mm, address, &pmd, &pte, &ptl))
-		return SWAP_AGAIN;
+	while (page_vma_mapped_walk(&pvmw)) {
+		address = pvmw.address;
 
-	if (vma->vm_flags & VM_LOCKED) {
-		if (pte)
-			pte_unmap(pte);
-		spin_unlock(ptl);
-		pra->vm_flags |= VM_LOCKED;
-		return SWAP_FAIL; /* To break the loop */
-	}
+		if (vma->vm_flags & VM_LOCKED) {
+			page_vma_mapped_walk_done(&pvmw);
+			pra->vm_flags |= VM_LOCKED;
+			return SWAP_FAIL; /* To break the loop */
+		}
 
-	if (pte) {
-		if (ptep_clear_flush_young_notify(vma, address, pte)) {
-			/*
-			 * Don't treat a reference through a sequentially read
-			 * mapping as such.  If the page has been used in
-			 * another mapping, we will catch it; if this other
-			 * mapping is already gone, the unmap path will have
-			 * set PG_referenced or activated the page.
-			 */
-			if (likely(!(vma->vm_flags & VM_SEQ_READ)))
+		if (pvmw.pte) {
+			if (ptep_clear_flush_young_notify(vma, address,
+						pvmw.pte)) {
+				/*
+				 * Don't treat a reference through
+				 * a sequentially read mapping as such.
+				 * If the page has been used in another mapping,
+				 * we will catch it; if this other mapping is
+				 * already gone, the unmap path will have set
+				 * PG_referenced or activated the page.
+				 */
+				if (likely(!(vma->vm_flags & VM_SEQ_READ)))
+					referenced++;
+			}
+		} else if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE)) {
+			if (pmdp_clear_flush_young_notify(vma, address,
+						pvmw.pmd))
 				referenced++;
+		} else {
+			/* unexpected pmd-mapped page? */
+			WARN_ON_ONCE(1);
 		}
-		pte_unmap(pte);
-	} else if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE)) {
-		if (pmdp_clear_flush_young_notify(vma, address, pmd))
-			referenced++;
-	} else {
-		/* unexpected pmd-mapped page? */
-		WARN_ON_ONCE(1);
+
+		pra->mapcount--;
 	}
-	spin_unlock(ptl);
 
 	if (referenced)
 		clear_page_idle(page);
@@ -936,7 +939,6 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 		pra->vm_flags |= vma->vm_flags;
 	}
 
-	pra->mapcount--;
 	if (!pra->mapcount)
 		return SWAP_SUCCESS; /* To break the loop */
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
