Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 97C4F6B038C
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 05:00:01 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e129so21331050pfh.1
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 02:00:01 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id n16si1050996pfk.309.2017.03.15.02.00.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 02:00:00 -0700 (PDT)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [PATCH v2 3/5] mm: use a dedicated workqueue for the free workers
Date: Wed, 15 Mar 2017 17:00:02 +0800
Message-Id: <1489568404-7817-4-git-send-email-aaron.lu@intel.com>
In-Reply-To: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
References: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>

Introduce a workqueue for all the free workers so that user can fine
tune how many workers can be active through sysfs interface: max_active.
More workers will normally lead to better performance, but too many can
cause severe lock contention.

Note that since the zone lock is global, the workqueue is also global
for all processes, i.e. if we set 8 to max_active, we will have at most
8 workers active for all processes that are doing munmap()/exit()/etc.

Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
 mm/memory.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index 001c7720d773..19b25bb5f45b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -253,6 +253,19 @@ static void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
 	__tlb_reset_range(tlb);
 }
 
+static struct workqueue_struct *batch_free_wq;
+static int __init batch_free_wq_init(void)
+{
+	batch_free_wq = alloc_workqueue("batch_free_wq",
+					WQ_UNBOUND | WQ_SYSFS, 0);
+	if (!batch_free_wq) {
+		pr_warn("failed to create workqueue batch_free_wq\n");
+		return -ENOMEM;
+	}
+	return 0;
+}
+subsys_initcall(batch_free_wq_init);
+
 static void tlb_flush_mmu_free_batches(struct mmu_gather_batch *batch_start,
 				       bool free_batch_page)
 {
@@ -306,7 +319,7 @@ static void tlb_flush_mmu_free(struct mmu_gather *tlb)
 		batch_free->batch_start = tlb->local.next;
 		INIT_WORK(&batch_free->work, batch_free_work);
 		list_add_tail(&batch_free->list, &tlb->worker_list);
-		queue_work(system_unbound_wq, &batch_free->work);
+		queue_work(batch_free_wq, &batch_free->work);
 
 		tlb->batch_count = 0;
 		tlb->local.next = NULL;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
