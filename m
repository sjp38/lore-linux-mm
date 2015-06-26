Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 1B3B46B0038
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 09:34:47 -0400 (EDT)
Received: by igbiq7 with SMTP id iq7so13374073igb.1
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 06:34:46 -0700 (PDT)
Received: from mail-ie0-x236.google.com (mail-ie0-x236.google.com. [2607:f8b0:4001:c03::236])
        by mx.google.com with ESMTPS id a11si28189971icm.68.2015.06.26.06.34.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jun 2015 06:34:46 -0700 (PDT)
Received: by iecvh10 with SMTP id vh10so75676590iec.3
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 06:34:46 -0700 (PDT)
From: Nicholas Krause <xerofoify@gmail.com>
Subject: [PATCH] memory:Make the function tlb_next_batch bool now
Date: Fri, 26 Jun 2015 09:34:37 -0400
Message-Id: <1435325677-24818-1-git-send-email-xerofoify@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: kirill.shutemov@linux.intel.com, mgorman@suse.de, hannes@cmpxchg.org, mhocko@suse.cz, raindel@mellanox.com, boaz@plexistor.com, luto@amacapital.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This makes the function tlb_next_batch bool now due to this
particular function only ever returning either one or zero
as its return value.

Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
---
 mm/memory.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 11b9ca1..02a0130 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -180,22 +180,22 @@ static void check_sync_rss_stat(struct task_struct *task)
 
 #ifdef HAVE_GENERIC_MMU_GATHER
 
-static int tlb_next_batch(struct mmu_gather *tlb)
+static bool tlb_next_batch(struct mmu_gather *tlb)
 {
 	struct mmu_gather_batch *batch;
 
 	batch = tlb->active;
 	if (batch->next) {
 		tlb->active = batch->next;
-		return 1;
+		return true;
 	}
 
 	if (tlb->batch_count == MAX_GATHER_BATCH_COUNT)
-		return 0;
+		return false;
 
 	batch = (void *)__get_free_pages(GFP_NOWAIT | __GFP_NOWARN, 0);
 	if (!batch)
-		return 0;
+		return false;
 
 	tlb->batch_count++;
 	batch->next = NULL;
@@ -205,7 +205,7 @@ static int tlb_next_batch(struct mmu_gather *tlb)
 	tlb->active->next = batch;
 	tlb->active = batch;
 
-	return 1;
+	return true;
 }
 
 /* tlb_gather_mmu
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
