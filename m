Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 693096B038D
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 06:40:37 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id j5so28441835pfb.3
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 03:40:37 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id f188si7189337pfb.28.2017.02.24.03.40.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Feb 2017 03:40:36 -0800 (PST)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [PATCH 4/5] mm: add force_free_pages in zap_pte_range
Date: Fri, 24 Feb 2017 19:40:35 +0800
Message-Id: <20170224114036.15621-5-aaron.lu@intel.com>
In-Reply-To: <20170224114036.15621-1-aaron.lu@intel.com>
References: <20170224114036.15621-1-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>

force_flush in zap_pte_range is set in the following 2 conditions:
1 When no more batches can be allocated (either due to no memory or
  MAX_GATHER_BATCH_COUNT has reached) to store those to-be-freed page
  pointers;
2 When a TLB_only flush is needed before dropping the PTE lock to avoid
  a race condition as explained in commit 1cf35d47712d
  ("mm: split 'tlb_flush_mmu()' into tlb flushing and memory freeing parts").

Once force_flush is set, the pages accumulated thus far will all be
freed. Since there is no need to do page free if condition 2 occurred,
add a new variable named force_free_pages to decide if page free should
be done and it will only only be set if condition 1 occured.

With this change, the page accumulation will not be interrupted by
condition 2 anymore. In the meantime, rename force_flush to
force_flush_tlb for condition 2.

Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
 mm/memory.c | 20 ++++++++------------
 1 file changed, 8 insertions(+), 12 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index eb8b17fc1b2b..7d1fe74084be 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1185,7 +1185,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 				struct zap_details *details)
 {
 	struct mm_struct *mm = tlb->mm;
-	int force_flush = 0;
+	int force_flush_tlb = 0, force_free_pages = 0;
 	int rss[NR_MM_COUNTERS];
 	spinlock_t *ptl;
 	pte_t *start_pte;
@@ -1232,7 +1232,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 					 */
 					if (unlikely(details && details->ignore_dirty))
 						continue;
-					force_flush = 1;
+					force_flush_tlb = 1;
 					set_page_dirty(page);
 				}
 				if (pte_young(ptent) &&
@@ -1244,7 +1244,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 			if (unlikely(page_mapcount(page) < 0))
 				print_bad_pte(vma, addr, ptent, page);
 			if (unlikely(__tlb_remove_page(tlb, page))) {
-				force_flush = 1;
+				force_free_pages = 1;
 				addr += PAGE_SIZE;
 				break;
 			}
@@ -1272,18 +1272,14 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 	arch_leave_lazy_mmu_mode();
 
 	/* Do the actual TLB flush before dropping ptl */
-	if (force_flush)
+	if (force_flush_tlb) {
+		force_flush_tlb = 0;
 		tlb_flush_mmu_tlbonly(tlb);
+	}
 	pte_unmap_unlock(start_pte, ptl);
 
-	/*
-	 * If we forced a TLB flush (either due to running out of
-	 * batch buffers or because we needed to flush dirty TLB
-	 * entries before releasing the ptl), free the batched
-	 * memory too. Restart if we didn't do everything.
-	 */
-	if (force_flush) {
-		force_flush = 0;
+	if (force_free_pages) {
+		force_free_pages = 0;
 		tlb_flush_mmu_free(tlb);
 		if (addr != end)
 			goto again;
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
