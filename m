Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 902996B0253
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 02:35:46 -0500 (EST)
Received: by pasz6 with SMTP id z6so46083827pas.2
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 23:35:46 -0800 (PST)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id sz8si63813pab.238.2015.11.03.23.35.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Nov 2015 23:35:45 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so5409641pab.3
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 23:35:45 -0800 (PST)
From: yalin wang <yalin.wang2010@gmail.com>
Subject: [PATCH] mm: change tlb_finish_mmu() to be more simple
Date: Wed,  4 Nov 2015 15:35:31 +0800
Message-Id: <1446622531-316-1-git-send-email-yalin.wang2010@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mgorman@suse.de, hannes@cmpxchg.org, riel@redhat.com, raindel@mellanox.com, willy@linux.intel.com, boaz@plexistor.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: yalin wang <yalin.wang2010@gmail.com>

This patch remove unneeded *next temp variable,
make this function more simple to read.

Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
---
 mm/memory.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 7f3b9f2..f0040ed 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -270,17 +270,16 @@ void tlb_flush_mmu(struct mmu_gather *tlb)
  */
 void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
 {
-	struct mmu_gather_batch *batch, *next;
+	struct mmu_gather_batch *batch;
 
 	tlb_flush_mmu(tlb);
 
 	/* keep the page table cache within bounds */
 	check_pgt_cache();
 
-	for (batch = tlb->local.next; batch; batch = next) {
-		next = batch->next;
+	for (batch = tlb->local.next; batch; batch = batch->next)
 		free_pages((unsigned long)batch, 0);
-	}
+
 	tlb->local.next = NULL;
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
