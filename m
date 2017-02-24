Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 91FFA6B038A
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 06:40:32 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 65so33254531pgi.7
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 03:40:32 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id f188si7189337pfb.28.2017.02.24.03.40.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Feb 2017 03:40:31 -0800 (PST)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [PATCH 1/5] mm: add tlb_flush_mmu_free_batches
Date: Fri, 24 Feb 2017 19:40:32 +0800
Message-Id: <20170224114036.15621-2-aaron.lu@intel.com>
In-Reply-To: <20170224114036.15621-1-aaron.lu@intel.com>
References: <20170224114036.15621-1-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>

There are two places doing page free where one is freeing pages pointed
by the mmu_gather_batch in tlb_flush_mmu_free and one for the batch page
itself in tlb_flush_mmu_finish. There will be yet another place in the
following patch to free both the pages pointed by the mmu_gather_batches
and the batch page itself in the parallel free worker thread. To avoid
code duplication, add a new function for this purpose.

Another reason to add this function is that after the following patch,
cond_resched will need to be added at places where more than 10K pages
can be freed, i.e. in tlb_flush_mmu_free and the worker function.
Instead of adding cond_resched at multiple places, using a single
function to reduce code duplication.

No functionality change.

Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
 mm/memory.c | 28 +++++++++++++++++-----------
 1 file changed, 17 insertions(+), 11 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 6bf2b471e30c..2b88196841b9 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -251,14 +251,25 @@ static void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
 	__tlb_reset_range(tlb);
 }
 
-static void tlb_flush_mmu_free(struct mmu_gather *tlb)
+static void tlb_flush_mmu_free_batches(struct mmu_gather_batch *batch_start,
+				       int free_batch_page)
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
+	tlb_flush_mmu_free_batches(&tlb->local, 0);
 	tlb->active = &tlb->local;
 }
 
@@ -274,17 +285,12 @@ void tlb_flush_mmu(struct mmu_gather *tlb)
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
+	tlb_flush_mmu_free_batches(tlb->local.next, 1);
 	tlb->local.next = NULL;
 }
 
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
