Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C56296B038E
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 06:40:38 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id j5so28442621pfb.3
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 03:40:38 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id f188si7189337pfb.28.2017.02.24.03.40.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Feb 2017 03:40:37 -0800 (PST)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [PATCH 5/5] mm: add debugfs interface for parallel free tuning
Date: Fri, 24 Feb 2017 19:40:36 +0800
Message-Id: <20170224114036.15621-6-aaron.lu@intel.com>
In-Reply-To: <20170224114036.15621-1-aaron.lu@intel.com>
References: <20170224114036.15621-1-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>

Make it possible to set different values for async_free_threshold and
max_gather_batch_count through debugfs.

With this, we can do tests for different purposes:
1 Restore vanilla kernel bahaviour for performance comparison.
  Set max_gather_batch_count to a value like 20 to effectively restore
  the behaviour of vanilla kernel since this will make page gathered
  always smaller than async_free_threshold(effectively disable parallel
  free);
2 Debug purpose.
  Set async_free_threshold to a very small value(like 128) to trigger
  parallel free even on ordinary processes, ideal for debug purpose with
  a virtual machine that doesn't have much memory assigned to it;
3 Performance tuning.
  Use a different value for async_free_threshold and max_gather_batch_count
  other than the default to test if parallel free performs better or worse.

Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
 mm/memory.c | 33 +++++++++++++++++++++++++++++++--
 1 file changed, 31 insertions(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 7d1fe74084be..9ca07c59e525 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -184,6 +184,35 @@ static void check_sync_rss_stat(struct task_struct *task)
 
 #ifdef HAVE_GENERIC_MMU_GATHER
 
+static unsigned long async_free_threshold = ASYNC_FREE_THRESHOLD;
+static unsigned long max_gather_batch_count = MAX_GATHER_BATCH_COUNT;
+
+#ifdef CONFIG_DEBUG_FS
+static int __init tlb_mmu_parallel_free_debugfs(void)
+{
+	umode_t mode = S_IFREG | S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH;
+	struct dentry *dir;
+
+	dir = debugfs_create_dir("parallel_free", NULL);
+	if (!dir)
+		return -ENOMEM;
+
+	if (!debugfs_create_ulong("async_free_threshold", mode, dir,
+				&async_free_threshold))
+		goto fail;
+	if (!debugfs_create_ulong("max_gather_batch_count", mode, dir,
+				&max_gather_batch_count))
+		goto fail;
+
+	return 0;
+
+fail:
+	debugfs_remove_recursive(dir);
+	return -ENOMEM;
+}
+late_initcall(tlb_mmu_parallel_free_debugfs);
+#endif
+
 static bool tlb_next_batch(struct mmu_gather *tlb)
 {
 	struct mmu_gather_batch *batch;
@@ -194,7 +223,7 @@ static bool tlb_next_batch(struct mmu_gather *tlb)
 		return true;
 	}
 
-	if (tlb->batch_count == MAX_GATHER_BATCH_COUNT)
+	if (tlb->batch_count == max_gather_batch_count)
 		return false;
 
 	batch = (void *)__get_free_pages(GFP_NOWAIT | __GFP_NOWARN, 0);
@@ -306,7 +335,7 @@ static void tlb_flush_mmu_free(struct mmu_gather *tlb)
 {
 	struct batch_free_struct *batch_free = NULL;
 
-	if (tlb->page_nr >= ASYNC_FREE_THRESHOLD)
+	if (tlb->page_nr >= async_free_threshold)
 		batch_free = kmalloc(sizeof(*batch_free), GFP_NOWAIT | __GFP_NOWARN);
 
 	if (batch_free) {
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
