Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8E0A16B038C
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 06:40:35 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id r67so27862891pfr.6
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 03:40:35 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id f188si7189337pfb.28.2017.02.24.03.40.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Feb 2017 03:40:34 -0800 (PST)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [PATCH 3/5] mm: use a dedicated workqueue for the free workers
Date: Fri, 24 Feb 2017 19:40:34 +0800
Message-Id: <20170224114036.15621-4-aaron.lu@intel.com>
In-Reply-To: <20170224114036.15621-1-aaron.lu@intel.com>
References: <20170224114036.15621-1-aaron.lu@intel.com>
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
 mm/memory.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index b98cd25075f0..eb8b17fc1b2b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -254,6 +254,18 @@ static void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
 	__tlb_reset_range(tlb);
 }
 
+static struct workqueue_struct *batch_free_wq;
+static int __init batch_free_wq_init(void)
+{
+	batch_free_wq = alloc_workqueue("batch_free_wq", WQ_UNBOUND | WQ_SYSFS, 0);
+	if (!batch_free_wq) {
+		pr_warn("failed to create workqueue batch_free_wq\n");
+		return -ENOMEM;
+	}
+	return 0;
+}
+subsys_initcall(batch_free_wq_init);
+
 static void tlb_flush_mmu_free_batches(struct mmu_gather_batch *batch_start,
 				       int free_batch_page)
 {
@@ -305,7 +317,7 @@ static void tlb_flush_mmu_free(struct mmu_gather *tlb)
 		batch_free->batch_start = tlb->local.next;
 		INIT_WORK(&batch_free->work, batch_free_work);
 		list_add(&batch_free->list, &tlb->worker_list);
-		queue_work(system_unbound_wq, &batch_free->work);
+		queue_work(batch_free_wq, &batch_free->work);
 
 		tlb->batch_count = 0;
 		tlb->local.next = NULL;
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
