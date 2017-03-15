Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AFC3B6B038E
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 05:00:03 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c23so18980503pfj.0
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 02:00:03 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id n16si1050996pfk.309.2017.03.15.02.00.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 02:00:02 -0700 (PDT)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [PATCH v2 4/5] mm: add force_free_pages in zap_pte_range
Date: Wed, 15 Mar 2017 17:00:03 +0800
Message-Id: <1489568404-7817-5-git-send-email-aaron.lu@intel.com>
In-Reply-To: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
References: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>

force_flush in zap_pte_range is set in the following 2 conditions:
1 When no more batches can be allocated (either due to no memory or
  MAX_GATHER_BATCH_COUNT has reached) to store those to-be-freed page
  pointers;
2 When a TLB_only flush is needed before dropping the PTE lock to avoid
  a race condition as explained in commit 1cf35d47712d ("mm: split
  'tlb_flush_mmu()' into tlb flushing and memory freeing parts").

Once force_flush is set, the pages accumulated thus far will all be
freed. Since there is no need to do page free for condition 2, add a new
variable named force_free_pages to decide if page free should be done
and it will only be set in condition 1.

With this change, the page accumulation will not be interrupted by
condition 2 anymore. In the meantime, rename force_flush to
force_flush_tlb for condition 2.

Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
 mm/memory.c | 20 ++++++++------------
 1 file changed, 8 insertions(+), 12 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 19b25bb5f45b..83b38823aaba 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1199,7 +1199,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 				struct zap_details *details)
 {
 	struct mm_struct *mm = tlb->mm;
-	int force_flush = 0;
+	int force_flush_tlb = 0, force_free_pages = 0;
 	int rss[NR_MM_COUNTERS];
 	spinlock_t *ptl;
 	pte_t *start_pte;
@@ -1239,7 +1239,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 
 			if (!PageAnon(page)) {
 				if (pte_dirty(ptent)) {
-					force_flush = 1;
+					force_flush_tlb = 1;
 					set_page_dirty(page);
 				}
 				if (pte_young(ptent) &&
@@ -1251,7 +1251,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 			if (unlikely(page_mapcount(page) < 0))
 				print_bad_pte(vma, addr, ptent, page);
 			if (unlikely(__tlb_remove_page(tlb, page))) {
-				force_flush = 1;
+				force_free_pages = 1;
 				addr += PAGE_SIZE;
 				break;
 			}
@@ -1279,18 +1279,14 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
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
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
