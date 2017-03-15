Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7A1936B0388
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 05:00:00 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id x127so22198428pgb.4
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 02:00:00 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id n16si1050996pfk.309.2017.03.15.01.59.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 01:59:59 -0700 (PDT)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [PATCH v2 1/5] mm: add tlb_flush_mmu_free_batches
Date: Wed, 15 Mar 2017 17:00:00 +0800
Message-Id: <1489568404-7817-2-git-send-email-aaron.lu@intel.com>
In-Reply-To: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
References: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>

There are two places doing page free related to struct mmu_gather_batch:
1 in tlb_flush_mmu_free, where pages gathered in mmu_gather_batch list
  are freed;
2 in tlb_flush_mmu_finish, where pages for the mmu_gather_batch
  structure(let's call it the batch page) are freed.

There will be yet another place in the parallel free worker thread
introduced in the following patch to free both the pages pointed to by
the mmu_gather_batch list and the batch pages themselves. To avoid code
duplication, add a new function named tlb_flush_mmu_free_batches for
this purpose.

Another reason to add this function is that after the following patch,
cond_resched will need to be added at places where more than 10K pages
can be freed, i.e. in tlb_flush_mmu_free and the worker function.
Instead of adding cond_resched at multiple places, using a single
function to reduce code duplication.

There should be no functionality change.

Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
 mm/memory.c | 28 +++++++++++++++++-----------
 1 file changed, 17 insertions(+), 11 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 14fc0b40f0bb..cdb2a53f251f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -250,14 +250,25 @@ static void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
 	__tlb_reset_range(tlb);
 }
 
-static void tlb_flush_mmu_free(struct mmu_gather *tlb)
+static void tlb_flush_mmu_free_batches(struct mmu_gather_batch *batch_start,
+				       bool free_batch_page)
 {
-	struct mmu_gather_batch *batch;
+	struct mmu_gather_batch *batch, *next;
 
-	for (batch = &tlb->local; batch && batch->nr; batch = batch->next) {
-		free_pages_and_swap_cache(batch->pages, batch->nr);
-		batch->nr = 0;
+	for (batch = batch_start; batch; batch = next) {
+		next = batch->next;
+		if (batch->nr) {
+			free_pages_and_swap_cache(batch->pages, batch->nr);
+			batch->nr = 0;
+		}
+		if (free_batch_page)
+			free_pages((unsigned long)batch, 0);
 	}
+}
+
+static void tlb_flush_mmu_free(struct mmu_gather *tlb)
+{
+	tlb_flush_mmu_free_batches(&tlb->local, false);
 	tlb->active = &tlb->local;
 }
 
@@ -273,17 +284,12 @@ void tlb_flush_mmu(struct mmu_gather *tlb)
  */
 void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
 {
-	struct mmu_gather_batch *batch, *next;
-
 	tlb_flush_mmu(tlb);
 
 	/* keep the page table cache within bounds */
 	check_pgt_cache();
 
-	for (batch = tlb->local.next; batch; batch = next) {
-		next = batch->next;
-		free_pages((unsigned long)batch, 0);
-	}
+	tlb_flush_mmu_free_batches(tlb->local.next, true);
 	tlb->local.next = NULL;
 }
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
